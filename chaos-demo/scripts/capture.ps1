param([string]$Out, [int]$Seconds = 8, [int]$IntervalMs = 150)
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
New-Item -ItemType Directory -Force -Path $Out | Out-Null
$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$end = (Get-Date).AddSeconds($Seconds); $i = 0
while ((Get-Date) -lt $end) {
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
  $bmp.Save((Join-Path $Out ("f{0:D4}.png" -f $i)), [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose(); $i++
  Start-Sleep -Milliseconds $IntervalMs
}
"frames=$i"
