#!/bin/bash

# Flashy by Tico - Styled Bash Version
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'
CLEAR_LINE="\033[2K"
HIDE_CURSOR="\033[?25l"
SHOW_CURSOR="\033[?25h"

FLASHY_DIR="$HOME/Downloads/flashy"
mkdir -p "$FLASHY_DIR"
cd "$FLASHY_DIR" || exit 1

draw_header() {
  clear
  echo -e "${YELLOW}⚡⚡⚡==============================================⚡⚡⚡"
  echo -e "               ${RED}FLASHY by Tico${YELLOW}"
  echo -e "⚡⚡⚡==============================================⚡⚡⚡${NC}"
  echo -e "      ___     "
  echo -e "     (  o)>   ${BLUE}Flashrom Backup & Restore Tool${NC}"
  echo -e "     //\\     Chromebook-safe & Simple"
  echo -e "     V_/_     "
  echo -e "${YELLOW}==============================================${NC}"
  echo
}

flash_choice() {
  local line=$1
  local text=$2
  for i in {1..4}; do
    tput cup $line 0
    echo -ne "${CLEAR_LINE}${BLUE}${text}${NC}"
    sleep 0.2
    tput cup $line 0
    echo -ne "${CLEAR_LINE}${text}"
    sleep 0.2
  done
}

scroll_exit_message() {
  local msg="  Thanks for using FLASHY by Tico  "
  local width=$(tput cols)
  local len=${#msg}
  echo -ne "$HIDE_CURSOR"
  for ((i=0; i<=$width+len; i++)); do
    tput cup $(($(tput lines)-1)) 0
    printf "%${i}s" "${msg:0:$((width-i<0?0:width-i))}"
    sleep 0.05
  done
  echo -e "$SHOW_CURSOR"
}

# Function to handle EOLDB (Dual Boot Setup)
eoldb() {
  echo ""
  echo "======================================"
  echo "        EOLDB by Tico - Safe          "
  echo "     Chromebook Dual Boot Enabler     "
  echo "        (SeaBIOS + Dev Mode)          "
  echo "======================================"
  echo ""

  echo "[!] WARNING: This script modifies boot flags on your Chromebook."
  echo "    I am NOT responsible for any damage or data loss."
  echo "    Use this at your own risk."
  echo ""

  echo "Press Enter to continue or Ctrl+C to abort."
  read

  # Confirm Developer Mode Tools
  if ! command -v crossystem &> /dev/null; then
    echo "[!] crossystem not found. Make sure you're in Developer Mode."
    exit 1
  fi

  # Show current settings
  usb_boot=$(crossystem dev_boot_usb)
  legacy_boot=$(crossystem dev_boot_legacy)
  altfw_boot=$(crossystem dev_boot_altfw)

  echo ""
  echo "[*] Current boot settings:"
  echo "    USB boot:     $usb_boot"
  echo "    Legacy boot:  $legacy_boot"
  echo "    AltFW boot:   $altfw_boot"
  echo ""

  # Ask to proceed with enabling or disabling dual boot
  echo "Select an option:"
  echo "  [1] Enable/refresh Dual Boot (USB + Legacy + AltFW)"
  echo "  [2] Disable Dual Boot (USB + Legacy + AltFW)"
  echo "  [3] Just view current settings and exit"
  read -p "Enter your choice (1/2/3): " choice

  if [[ "$choice" == "1" ]]; then
    echo ""
    echo "[*] Proceeding to set dev_boot_usb=1, dev_boot_legacy=1, dev_boot_altfw=1"
    read -p "Are you sure? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
      sudo crossystem dev_boot_usb=1 dev_boot_legacy=1 dev_boot_altfw=1
      echo "[*] Settings updated."
    else
      echo "[!] Operation cancelled."
    fi

  elif [[ "$choice" == "2" ]]; then
    echo ""
    echo "[*] Proceeding to set dev_boot_usb=0, dev_boot_legacy=0, dev_boot_altfw=0"
    read -p "Are you sure you want to disable dual boot? (y/n): " disable_confirm
    if [[ "$disable_confirm" == "y" || "$disable_confirm" == "Y" ]]; then
      sudo crossystem dev_boot_usb=0 dev_boot_legacy=0 dev_boot_altfw=0
      echo "[*] Settings disabled."
    else
      echo "[!] Operation cancelled."
    fi

  else
    echo "[*] Exiting without making changes."
  fi

  echo ""
  echo "[*] Done! If changes were made, reboot and press Ctrl+L at the white screen to launch SeaBIOS."
  echo "         Thank you for using EOLDB by Tico!"
  echo ""
}

# Function to inspect RW_L slot
inspect_rw_l() {
  echo "==========================================="
  echo "         Inspecting RW_L Slot"
  echo "==========================================="
  echo ""
  
  # Show information about RW_L slot (assuming you want to check device properties)
  if command -v crossystem &> /dev/null; then
    echo "[*] RW_L Slot Information:"
    crossystem rw_l
    echo "[*] Current RW_L status:"
    crossystem rw_l
  else
    echo "[!] crossystem command not found. Please ensure you're in Developer Mode."
    exit 1
  fi
}

while true; do
  draw_header
  echo "  1) Backup firmware"   # Line 9
  echo "  2) Restore firmware"  # Line 10
  echo "  3) List saved ROMs"   # Line 11
  echo "  4) Inspector (RW_L)"  # New Inspector option
  echo "  5) Exit"              # Line 12 (Exit moved to 5)
  echo
  read -rp "Enter choice [1–5]: " choice

  case "$choice" in
    1)
      flash_choice 9 "  1) Backup firmware"
      filename="firmware_backup_$(date +%Y%m%d_%H%M%S).rom"
      echo "Backing up firmware to $FLASHY_DIR/$filename..."
      if sudo flashrom -p internal -r "$filename"; then
        echo "Backup complete: $filename"
      else
        echo "Backup failed. Check write protection or permissions."
      fi
      ;;
    2)
      flash_choice 10 "  2) Restore firmware"
      echo "Available ROM files in $FLASHY_DIR:"
      ls *.rom 2>/dev/null || { echo "No ROM files found."; read -rp "Press enter to continue..."; continue; }
      read -rp "Enter the name of the ROM file to restore: " romfile
      if [ -f "$romfile" ]; then
        echo "WARNING: Flashing firmware can brick your device."
        read -rp "Are you sure you want to continue? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
          if sudo flashrom -p internal -f -w "$romfile"; then
            echo "Firmware restored successfully from $romfile"
          else
            echo "Restore failed. Check write protection or firmware validity."
          fi
        else
          echo "Restore canceled."
        fi
      else
        echo "File $romfile not found."
      fi
      ;;
    3)
      flash_choice 11 "  3) List saved ROMs"
      echo "Saved ROM backups:"
      ls *.rom 2>/dev/null || echo "No ROM files found."
      ;;
    4)
      flash_choice 12 "  4) Inspector (RW_L)"
      inspect_rw_l  # Call the RW_L inspection function
      ;;
    5)
      flash_choice 13 "  5) Exit"
      clear
      scroll_exit_message
      echo -e "\nGoodbye!"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please enter 1–5.${NC}"
      ;;
  esac

  echo
  echo "----------------------------------------------"
  echo "[X] Exit   (or press Enter to return to menu)"
  read -rp ""
done