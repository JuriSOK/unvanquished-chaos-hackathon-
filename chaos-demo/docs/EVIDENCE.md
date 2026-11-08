# Evidence (captured on the demo VM, 2026-11-07)

All captures below come from the real game running on the VM (Windows Server 2022, Mesa llvmpipe), not from mockups.

## Executables

| Variant | Path | SHA-256 |
|---|---|---|
| CLEAN engine | `C:\unv\build-clean\daemon.exe` | `37e41c6fd17263b0fc3cc8ab74422e99c0e96c7102a506185c0cc54872177c3b` |
| CLEAN cgame | `C:\unv\build-clean\cgame-native-dll.dll` | `865b6d81af79b7599713f61210aeb6223aff813aefa055cae7e4a1a338afba3a` |
| CLEAN sgame | `C:\unv\build-clean\sgame-native-dll.dll` | `b11e4f7a6af6fd9e247f94ac22a2634626f98e8539d0e202e412e1a215c43ce7` |

Source: Unvanquished `2d316012059a412037c517bc289884c049443d5e` (v0.56.2), Dæmon `65ef5586f500d61829514d70bb3d35f3b3bc1bb4`.
(The engine hashes differ only because each tree embeds its own build paths; the engine source is identical.)

## Logs

- `logs/build-clean.log`: full CMake configure + 639/639 Ninja targets, no errors
  (download progress lines stripped).
- `logs/runtime-*-vm-load.txt`: `daemon.log` lines proving each variant loads **its own** native
  `cgame-native-dll.dll` / `sgame-native-dll.dll` from `build-clean` / `build-bugged`.

## Gameplay

| File | What it shows |
|---|---|
| `screenshots/clean_spawn_outdoor_pad.jpg` | CLEAN: human soldier with SMG spawned outdoors on plat23 |
| `screenshots/clean_mouse_aim.jpg` | CLEAN: mouse aiming turned the view |
| `screenshots/clean_fire_no_launch.jpg` | CLEAN: walked forward (W), fired 3 shots: bullet holes, ammo 30 -> 27, player stays on the ground |
| `screenshots/clean_autospawn_from_desktop_shortcut.jpg` | CLEAN via the "Unvanquished CLEAN" desktop shortcut: auto-joined Humans and spawned with the SMG on the pad, without any UI clicks |
