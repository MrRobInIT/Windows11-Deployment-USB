# SOP: Burn Deployment ISO to 64GB USB Drives (Rufus)

## Purpose
This SOP describes how to write the Windows 11 deployment ISO to additional 64GB USB drives using Rufus and validate the media.

## Prerequisites
- Deployment ISO generated per ImgBurn SOP, e.g., `Win11_Deploy_USB_vYYYY.MM.DD.iso`.
- Windows 10/11 admin workstation with local admin rights.
- Tools:
  - Rufus latest stable: https://rufus.ie/
- Hardware:
  - Blank 64GB USB 3.0 drives.
  - USB 3.x ports (and optional multi-port hub).

## 1. Write ISO to USB with Rufus
1. Launch Rufus as Administrator.
2. Device: Select the target 64GB USB drive.
3. Boot selection: Click “SELECT” → choose the ISO (`Win11_Deploy_USB_vYYYY.MM.DD.iso`).
4. Partition scheme / Target system (choose based on fleet):
   - Standard modern Dell UEFI-only (recommended):
     - Partition scheme: GPT
     - Target system: UEFI (non CSM)
   - Legacy compatibility batch (older hardware):
     - Partition scheme: MBR
     - Target system: BIOS (or UEFI-CSM)
5. Volume label: `WIN11_DEPLOY`.
6. File system:
   - Prefer FAT32 if all files <4GB (split WIMs).
   - If ISO requires NTFS, Rufus will default to NTFS and enable UEFI:NTFS automatically.
7. Cluster size: Default.
8. Advanced format options:
   - Check “Quick format”.
   - Check “Create extended label and icon files”.
9. Click Start, confirm the data-destruction prompt, and wait for completion.

## 2. Repeat for Additional USBs
- Swap the “Device” and repeat the steps.
- You may run multiple Rufus instances in parallel (I/O bound).

## 3. Post-Write Validation
### 3.1 Quick Content Check
- In Explorer, confirm expected folder structure and files:
  - `startnet.cmd`, `apply.cmd`, `createdisk_GPT.txt`, `Drivers`, `\sources\boot.wim`, `install.swm` parts.

### 3.2 Boot Test on Dell Hardware
1. F2 → BIOS/UEFI setup:
   - UEFI boot enabled, Secure Boot as per standard.
2. F12 → One-time Boot Menu → select the USB.
3. Confirm WinPE boots and `startnet.cmd` initiates your deployment workflow.

## Troubleshooting
- USB not listed in F12 menu:
  - Recreate with GPT/UEFI scheme for modern systems.
  - Try a different port; avoid through-dock ports for initial tests.
- Secure Boot issues (NTFS media):
  - Prefer FAT32 by splitting WIMs.
  - Otherwise, Rufus UEFI:NTFS is usually supported on modern Dell systems.
- Slow writes:
  - Use known-good 3.0 media and ports; avoid mixed-speed hubs.

## Versioning and Distribution
- Name USBs and labels with the ISO version, e.g., `WIN11_DEPLOY_2025.10.26`.
- Track ISO SHA-256 alongside release notes in the repo or artifact store.

## Change Log
- 2025-10-26: Initial version.
