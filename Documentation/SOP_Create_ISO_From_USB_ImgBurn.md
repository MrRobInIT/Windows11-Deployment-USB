# SOP: Create a Windows 11 Deployment ISO from USB (ImgBurn)

## Purpose
This SOP describes how to:
- Create an ISO image from the master Windows 11 deployment USB using ImgBurn.
- Validate the ISO’s integrity and contents.

This complements the Windows Provisioning SOP for building the master deployment USB.

## Prerequisites
- Master Windows 11 deployment USB built per project SOP (WinPE, `startnet.cmd`, `apply.cmd`, `createdisk_GPT.txt`, drivers, `install.swm` split images, etc.).
- Windows 10/11 admin workstation with local admin rights.
- Tools:
  - ImgBurn (latest stable).
  - Optional: Windows ADK (Deployment Tools) for `etfsboot.com` (and `oscdimg` if using advanced build).
  - Optional: PowerShell for hashing (`Get-FileHash`).
- Hardware:
  - The master USB (source).
  - Fast local disk for staging.

> Notes
> - Ensure the source USB is error-free (e.g., `chkdsk /f`).
> - Temporarily disable antivirus if it interferes with raw device reads/writes.

## 1. Install and Configure ImgBurn
1. Install ImgBurn and run as Administrator.
2. Tools → Settings:
   - Read: Enable “Calculate MD5” and “Calculate SHA-1” (optional).
   - I/O: Interface = “SPTI - Microsoft”.
   - General: Enable updates (optional).

## 2. Stage the USB Contents
1. Create a staging folder, e.g., `D:\MasterUSB_Staging`.
2. Copy all files/folders from the master USB to the staging folder:
   ```powershell
   # Replace E: with your master USB letter
   robocopy E:\ D:\MasterUSB_Staging /E /COPY:DAT /R:2 /W:2 /MT:16
   ```

## 3. Build the ISO from Files/Folders
1. Open ImgBurn → “Create image file from files/folders”.
2. Source: Select `D:\MasterUSB_Staging`.
3. Destination: e.g., `D:\Images\Win11_Deploy_USB_vYYYY.MM.DD.iso`.
4. Right-side panels:
   - Options:
     - File System: “ISO9660 + UDF” (recommended) or “UDF” for long paths/Unicode.
     - Recurse Subdirectories: Enabled.
     - Include Hidden/System Files: Enabled.
     - Preserve Full Pathnames: Enabled.
   - Labels:
     - Set both UDF and ISO9660 volume label, e.g., `WIN11_DEPLOY_USB`.
   - Advanced → Bootable Disc:
     - Check “Make Image Bootable”.
     - Emulation Type: “None (Custom)”.
     - Boot Image (El Torito): point to `etfsboot.com` (if installed with Windows ADK):
       - Typical path (example): `C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\etfsboot.com`
     - Developer ID: `Microsoft Corporation` (or your org).
     - Load Segment: `07C0`
     - Sectors to Load: `8` (standard BIOS El Torito)
5. Click Build and approve any prompts to adjust restrictions.

> UEFI note
> - For our workflow, Rufus will produce a UEFI-bootable USB from this ISO. If you require a dual BIOS+UEFI El Torito ISO itself, consider `oscdimg` with dual boot entries (see Appendix A).

## 4. Validate the ISO
1. Compute and save a hash:
   ```powershell
   Get-FileHash D:\Images\Win11_Deploy_USB_vYYYY.MM.DD.iso -Algorithm SHA256 | Format-List
   ```
2. Mount the ISO (right-click → Mount) and verify presence of:
   - `\sources\boot.wim`
   - `\EFI\Microsoft\Boot\` (if included in your build)
   - `startnet.cmd`, `apply.cmd`, `createdisk_GPT.txt`, `Drivers\...`, `install.swm` parts.

## Troubleshooting
- Missing files after build:
  - Ensure “Include Hidden/System Files” and “Recurse Subdirectories” were enabled.
  - Re-copy via `robocopy /E`.
- ISO not booting (when written to USB):
  - Use Rufus with GPT/UEFI settings (see Rufus SOP).
- Files >4GB:
  - Keep `install.wim` split into `install.swm` (<4GB each) on the master USB.

## Appendix A — Alternative ISO Creation with Oscdimg (Advanced)
For dual BIOS+UEFI El Torito ISO:
```cmd
oscdimg -m -o -u2 -bootdata:2#p0,e,b"C:\ADK\etfsboot.com"#pEF,e,b"C:\ADK\efisys.bin" D:\MasterUSB_Staging D:\Images\Win11_Deploy_USB_vYYYY.MM.DD.iso
```

## Change Log
- 2025-10-26: Initial version.
