# Technical notes

## Versions (exact)

| Item | Value |
|---|---|
| Official release | Unvanquished **0.56.2** (`unvanquished_0.56.2.zip`, SHA-512 verified against the official `.sha512sum`) |
| Gamelogic source | https://github.com/Unvanquished/Unvanquished tag `v0.56.2` = `2d316012059a412037c517bc289884c049443d5e` |
| Dæmon engine (submodule `daemon/`) | `65ef5586f500d61829514d70bb3d35f3b3bc1bb4` |
| Compiler | MSVC 19.44.35229 (VS 2022 Build Tools), CMake + Ninja, `RelWithDebInfo` |
| External deps | `https://dl.unvanquished.net/deps/windows-amd64-msvc_11.tar.xz` (fetched automatically by CMake) |
| Software GL | Mesa 26.2.6 llvmpipe (pal1000/mesa-dist-win, MinGW build) |

CLEAN and BUGGED are built from the same Unvanquished release.

## Layout on disk (`C:\unv`, override with `UNV_ROOT`)

| Path | Content |
|---|---|
| `official\` | Official 0.56.2 Windows binaries (reference build, untouched) |
| `official\pkg\` | Official `.dpk` assets: maps, models, textures, weapons, sounds (shared by both variants via `-pakpath`) |
| `src\Unvanquished\` | CLEAN source tree (`v0.56.2` + submodules) |
| `src\Unvanquished-bugged\` | BUGGED source tree (branch `demo-bugged-v1`) |
| `build-clean\` / `build-bugged\` | `daemon.exe`, `cgame-native-dll.dll`, `sgame-native-dll.dll` per variant |
| `home-clean\` / `home-bugged\` | Separate homepaths (configs, logs, layout); no shared mutable state |

## Build

`scripts\build.bat <src> <out>` configures with
`-DBUILD_CLIENT=ON -DBUILD_SERVER=OFF -DBUILD_TTY_CLIENT=OFF -DBUILD_GAME_NACL=OFF -DBUILD_GAME_NATIVE_DLL=ON -DBUILD_GAME_NATIVE_EXE=OFF`
and builds all 639 Ninja targets. The game loads the locally built native gamelogic DLLs because the launchers pass
`-set vm.sgame.type 3 -set vm.cgame.type 3` (3 = native DLL); `daemon.log` confirms e.g.
`Loading VM module C:\unv\build-bugged/sgame-native-dll.dll...`.

## Offline scenario

The launchers run `+devmap plat23` (local listen server, cheats allowed, no network/master server) with:

- `g_layouts chaos`: `config/layouts/plat23/chaos.dat` = the map's builtin layout with the two indoor human telenodes
  replaced by a single telenode on the open-sky "23" landing pad (`0 2250 40`, facing the hangar).
- `g_neverEnd 1`, `timelimit 0`, `g_doWarmup 0`: the match never ends (no intermission/map rotation mid-demo).
- `+delay 150f "team humans" +delay 200f "class rifle"`: auto-joins Humans and spawns with the default SMG.

## Rendering on the VM

The VM has no GPU (`IddSampleDriver`), so Mesa's `opengl32.dll` + `libgallium_wgl.dll` are copied next to each
`daemon.exe` and `GALLIUM_DRIVER=llvmpipe` is set: OpenGL 4.6 core, ~15-19 fps at 1280x720. On a machine with a GPU,
delete those two DLLs from `build-*` to use the native driver.
