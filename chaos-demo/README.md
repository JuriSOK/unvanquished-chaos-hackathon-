# Unvanquished Chaos Hackathon

Live AI-debugging demo built on the **real** open-source FPS [Unvanquished](https://unvanquished.net) 0.56.2
(DÃ¦mon engine). Two builds of the exact same upstream commit:

- **CLEAN**: unmodified `v0.56.2`. Movement, aiming, shooting behave normally.
- **BUGGED**: the same game with **one** intentional gameplay defect.

The bug is intentionally **not fixed** here. The plan is that the H Company agent plays the game and discovers it, Devin fixes the source, and H verifies the fix.

## Branches

| Ref | Content |
|---|---|
| `demo-clean-v1` | **CLEAN** game: full Unvanquished source at the official `v0.56.2` commit `2d31601` (upstream history kept, Dæmon engine and libs as submodules) plus this demo tooling in `chaos-demo/` |
| `demo-bugged-v1` | **BUGGED** game |

```bat
git clone --recurse-submodules -b demo-bugged-v1 https://github.com/JuriSOK/unvanquished-chaos-hackathon-.git
chaos-demo\scripts\build.bat <checkout> <build_dir>
```

## Quick start (Windows x64)

```bat
SETUP.bat            :: idempotent: toolchain, official release + assets, Mesa, source, both builds, desktop shortcuts
LAUNCH_CLEAN.bat     :: or desktop shortcut "Unvanquished CLEAN"
LAUNCH_BUGGED.bat    :: or desktop shortcut "Unvanquished BUGGED"
```

Each launcher closes any running instance, starts a local offline `devmap plat23`, auto-joins Humans and spawns the
soldier with the default SMG on the open-sky "23" landing pad. Installed under `C:\unv` (set `UNV_ROOT` to change).
On the prepared VM, everything is already installed and lives on the persistent disk, so after a reboot you only need to double-click a shortcut.

## Repository contents

| Path | Purpose |
|---|---|
| `LAUNCH_CLEAN.bat`, `LAUNCH_BUGGED.bat`, `scripts/_launch.bat` | Launchers (native gamelogic via `vm.sgame.type 3` / `vm.cgame.type 3`) |
| `SETUP.bat`, `scripts/setup.ps1` | Downloads official artifacts, verifies the release checksum, clones `v0.56.2` with submodules, checks out `demo-bugged-v1` for BUGGED, builds both variants |
| `scripts/build.bat` | CMake/Ninja/MSVC build of engine + native cgame/sgame DLLs |
| `config/layouts/plat23/chaos.dat` | Offline demo layout (human telenode on the outdoor pad) |
| `docs/DEMO_SCRIPT.md` | Step-by-step demo for the computer-use agent |
| `docs/TECHNICAL.md` | Versions, paths, build flags, offline scenario, rendering |
| `docs/EVIDENCE.md`, `evidence/` | Screenshots, recording, build logs, binary hashes |
| `NOTICE.md`, `licenses/` | Upstream attribution and licenses |

No game assets or binaries are committed. They are downloaded from the official upstream releases.

## License

Scripts and docs: GPL-3.0-or-later, the same as Unvanquished. The `demo-bugged-v1` branch modifies GPL Unvanquished code. See `NOTICE.md`.
