# Flashy

**Firmware Backup & Restore Tool for Chromebooks – by Tico**

Flashy is a terminal-based tool that allows you to back up and restore the RW_LEGACY firmware slot on Chromebooks. It also helps configure dual boot support safely using ChromeOS Developer Mode settings.

## Features

- Backup stock RW_LEGACY enabling you to return to a previous state after installing custom firmware
- Backup custom firmware
- Restore backed-up firmware safely
- Inspect RW_L slot and boot flags

## Usage

1. Copy and paste the script into a file called `flashy.sh`
2. Save it to your Chromebook’s `Downloads` folder
3. Open Crosh (Ctrl+Alt+T), type `shell`, and run:


cd ~/Downloads

bash flashy.sh
