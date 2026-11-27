# Resolution Toggler

One-click toggle between your native resolution and a stretched resolution (handy for FPS games).
Pure PowerShell + Windows API. No NirCmd or other downloads needed.

## Usage

1. Put `toggle-res.bat` and `toggle-res.ps1` in the same folder (or just keep the `.bat` and set `SCRIPT_URL` so it downloads the `.ps1` from this repo).
2. Edit the values at the top of `toggle-res.bat`:
   ```bat
   set NATIVE_W=1920
   set NATIVE_H=1080
   set STRETCHED_W=1280
   set STRETCHED_H=1024
   ```
3. Run the `.bat`. If you're on the stretched resolution it switches to native; otherwise it switches to stretched. Then it exits.

Tip: make a desktop shortcut to the `.bat` and assign a shortcut key, or bind it to a macro key.

## Notes

- Affects the **primary** display only. Refresh rate and color depth are kept as-is.
- The mode is tested before being applied, so an unsupported resolution won't blank your screen.
- For your "stretched resolution" to actually look *stretched* on a 16:9 monitor, set scaling to **Full-screen / Full-panel** in your GPU control panel (NVIDIA: Adjust desktop size and position; AMD: Scaling mode). Windows itself only changes the resolution.
- Resolution is changed persistently (written to the registry), so the detection works reliably between runs.

## License

MIT
