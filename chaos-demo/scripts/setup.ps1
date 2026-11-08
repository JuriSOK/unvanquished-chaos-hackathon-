# Idempotent setup for the Unvanquished chaos demo on Windows (x64).
# Downloads only official upstream artifacts; nothing large is stored in this repository.
param([string]$Root = "C:\unv", [switch]$SkipToolchain, [switch]$SkipBuild)
$ErrorActionPreference = "Stop"
$Repo     = Split-Path -Parent $PSScriptRoot
$Version  = "0.56.2"
$Tag      = "v$Version"
$Commit   = "2d316012059a412037c517bc289884c049443d5e"
$GameZip  = "https://github.com/Unvanquished/Unvanquished/releases/download/$Tag/unvanquished_$Version.zip"
$GameSum  = "https://github.com/Unvanquished/Unvanquished/releases/download/$Tag/unvanquished_$Version.sha512sum"
$MesaUrl  = "https://github.com/pal1000/mesa-dist-win/releases/download/26.2.6/mesa3d-26.2.6-release-mingw.7z"
$SevenZr  = "https://www.7-zip.org/a/7zr.exe"
$ProgressPreference = "SilentlyContinue"
New-Item -ItemType Directory -Force -Path $Root | Out-Null

function Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Fetch($url, $out) { if (-not (Test-Path $out)) { Step "Downloading $url"; Invoke-WebRequest -Uri $url -OutFile $out } }

# 1. Toolchain: VS 2022 Build Tools (MSVC), CMake, Ninja, Git, Python + pyyaml/jinja2
if (-not $SkipToolchain) {
  if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw "Chocolatey is required (https://chocolatey.org/install)." }
  $vcvars = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
  if (-not (Test-Path $vcvars)) {
    Step "Installing Visual Studio 2022 Build Tools (C++ workload)"
    choco install -y visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive"
  }
  if (-not (Test-Path "C:\Program Files\CMake\bin\cmake.exe")) { Step "Installing CMake"; choco install -y cmake }
  foreach ($p in "ninja", "git", "python") {
    if (-not (Get-Command $p -ErrorAction SilentlyContinue)) { Step "Installing $p"; choco install -y $p }
  }
  python -m pip install --quiet pyyaml jinja2
}

# 2. Official release 0.56.2 (engine + all official .dpk assets), checksum-verified
$zip = Join-Path $Root "unvanquished_$Version.zip"
$sum = Join-Path $Root "unvanquished_$Version.sha512sum"
Fetch $GameZip $zip; Fetch $GameSum $sum
if (-not (Test-Path "$Root\official\pkg")) {
  $expected = ((Get-Content $sum) -split '\s+')[0].ToLower()
  $actual = (Get-FileHash $zip -Algorithm SHA512).Hash.ToLower()
  if ($expected -ne $actual) { throw "Checksum mismatch for $zip" }
  Step "Checksum OK, extracting official release"
  Expand-Archive -Path $zip -DestinationPath "$Root\release" -Force
  $inner = Get-ChildItem "$Root\release\unvanquished_$Version" -Filter "windows-amd64.zip" -Recurse | Select-Object -First 1
  Expand-Archive -Path $inner.FullName -DestinationPath "$Root\official" -Force
  New-Item -ItemType Directory -Force -Path "$Root\official\pkg" | Out-Null
  Copy-Item "$Root\release\unvanquished_$Version\pkg\*" "$Root\official\pkg\" -Force
}

# 3. Mesa llvmpipe software OpenGL (only needed on VMs without a GPU)
$sz = Join-Path $Root "7zr.exe"; Fetch $SevenZr $sz
$mesa = Join-Path $Root "mesa-mingw.7z"; Fetch $MesaUrl $mesa
if (-not (Test-Path "$Root\mesa-gl\x64\opengl32.dll")) { & $sz x $mesa "-o$Root\mesa-gl" x64 -y | Out-Null }
function Copy-Mesa($dest) { foreach ($f in "opengl32.dll", "libgallium_wgl.dll") { if (-not (Test-Path "$dest\$f")) { Copy-Item "$Root\mesa-gl\x64\$f" $dest } } }
Copy-Mesa "$Root\official"

# 4. Source at the exact release commit (+ submodules); CLEAN and BUGGED trees
$clean = "$Root\src\Unvanquished"; $bugged = "$Root\src\Unvanquished-bugged"
if (-not (Test-Path $clean)) {
  Step "Cloning Unvanquished $Tag with submodules"
  git clone --recurse-submodules --branch $Tag https://github.com/Unvanquished/Unvanquished.git $clean
}
$head = (git -C $clean rev-parse HEAD).Trim()
if ($head -ne $Commit) { throw "Unexpected source commit $head (expected $Commit)" }
if (-not (Test-Path $bugged)) {
  Step "Creating BUGGED tree (branch demo-bugged-v1)"
  git clone --quiet --no-hardlinks $clean $bugged
  git -C $bugged fetch --quiet https://github.com/JuriSOK/unvanquished-chaos-hackathon-.git demo-bugged-v1
  git -C $bugged checkout --quiet FETCH_HEAD
  git -C $bugged submodule update --init --recursive --reference $clean
}

# 5. Build both variants (native engine + native cgame/sgame DLLs)
if (-not $SkipBuild) {
  foreach ($v in "clean", "bugged") {
    $src = if ($v -eq "clean") { $clean } else { $bugged }
    $out = "$Root\build-$v"
    if (-not (Test-Path "$out\sgame-native-dll.dll")) {
      Step "Building $v -> $out (log: $Root\build-$v.log)"
      cmd /c "`"$Repo\scripts\build.bat`" `"$src`" `"$out`" > `"$Root\build-$v.log`" 2>&1"
      if ($LASTEXITCODE -ne 0) { throw "Build of $v failed, see $Root\build-$v.log" }
    }
    Copy-Mesa $out
  }
}

# 6. Desktop shortcuts (persist across VM restarts)
$ws = New-Object -ComObject WScript.Shell
foreach ($v in "CLEAN", "BUGGED") {
  $lnk = $ws.CreateShortcut("$env:PUBLIC\Desktop\Unvanquished $v.lnk")
  $lnk.TargetPath = "$Repo\LAUNCH_$v.bat"; $lnk.WorkingDirectory = $Repo
  $lnk.IconLocation = "$Root\official\daemon.exe,0"; $lnk.Save()
}
Step "Done. Double-click 'Unvanquished CLEAN' or 'Unvanquished BUGGED' on the desktop."
