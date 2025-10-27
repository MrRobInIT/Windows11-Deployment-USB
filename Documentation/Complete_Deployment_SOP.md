# Windows 11 Deployment USB - Complete Standard Operating Procedure

## Overview
This SOP covers creating a bootable WinPE USB with split image files on the boot partition and drivers/apps/BIOS on a second partition for offline deployment to Dell Latitude, Precision laptops, and OptiPlex, Precision desktops.

---

## Part 1: WinPE USB Creation

### Prerequisites
- Windows ADK and WinPE add-on installed
- 64GB USB drive (will create two 32GB partitions)
- Administrative privileges

### Steps

1. **Open Deployment and Imaging Tools Environment as Administrator**

2. **Create WinPE working directory:**
```cmd
copype amd64 C:\WinPE_amd64
```

3. **Mount WinPE image:**
```cmd
Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /Index:1 /MountDir:"C:\WinPE_amd64\mount"
```

4. **Add optional components:**
```cmd
Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFx.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
```

5. **Create startnet.cmd:**
```cmd
notepad C:\WinPE_amd64\mount\Windows\System32\startnet.cmd
```

**startnet.cmd contents:**
```batch
@echo off
wpeinit
color 1F
echo.
echo ============================================
echo   Windows 11 Deployment - Dell Systems
echo ============================================
echo.
echo Starting deployment script...
echo.
D:\Deploy\apply.cmd
```

6. **Commit changes and unmount:**
```cmd
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /Commit
```

7. **Prepare USB drive with two partitions:**
```cmd
diskpart
```

In DiskPart:
```
list disk
select disk # (your USB disk number)
clean
create partition primary size=32000
format fs=fat32 quick label="WinPE_Boot"
active
assign letter=P
create partition primary
format fs=ntfs quick label="Drivers_Apps"
assign letter=D
exit
```

8. **Copy WinPE files to boot partition:**
```cmd
xcopy C:\WinPE_amd64\media\*.* P:\ /E /H /F
```

9. **Make USB bootable:**
```cmd
bootsect /nt60 P: /force /mbr
```

---

## Part 2: Image Preparation and Capture

### VM Configuration
- Hyper-V Gen 2 VM
- 4 CPU cores, 8GB RAM
- 128GB VHDX
- Secure Boot enabled

### Steps

1. **Install Windows 11 Enterprise in VM**
   - Complete OOBE with local account
   - Set computer name: GOLD-IMAGE
   - Skip all privacy/telemetry options

2. **Install Dell Command | Update:**
   - Download latest version from Dell
   - Install silently: `Dell-Command-Update_xxxxx.exe /s`
   - Run updates: `dcu-cli.exe /applyUpdates -reboot=disable`

3. **Install applications:**
   - Install all required enterprise applications
   - Configure default settings
   - Remove desktop shortcuts
   - Clear temp files

4. **Run Windows Updates:**
   - Install all critical and security updates
   - Reboot as needed
   - Repeat until no updates remain

5. **Clean up system:**
```cmd
cleanmgr /sageset:1
cleanmgr /sagerun:1
```

6. **Run Sysprep:**
```cmd
C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown
```

7. **Mount VHDX on host after shutdown:**
```powershell
Mount-VHD -Path "C:\Hyper-V\GOLD-IMAGE.vhdx"
```

8. **Capture image with DISM:**

Identify mounted drive letter (assume E:):
```cmd
Dism /Capture-Image /ImageFile:E:\GOLD_IMAGE\Deploy\Images\install.wim /CaptureDir:E:\ /Name:"Windows 11 Enterprise Gold" /Description:"Windows 11 with Apps and Updates" /Compress:max
```

9. **Split image for FAT32:**
```cmd
Dism /Split-Image /ImageFile:E:\GOLD_IMAGE\Deploy\Images\install.wim /SWMFile:E:\GOLD_IMAGE\Deploy\Images\install.swm /FileSize:4000
```

10. **Dismount VHDX:**
```powershell
Dismount-VHD -Path "C:\Hyper-V\GOLD-IMAGE.vhdx"
```

---

## Part 3: USB Structure and Scripts

### Boot Partition (P:\ - FAT32) Structure:
```
P:\
├── Boot\
├── EFI\
├── sources\
│   └── boot.wim
├── Deploy\
│   ├── apply.cmd
│   ├── createdisk_GPT.txt
│   ├── unattend.xml
│   ├── Images\
│   │   ├── Win11Gold.swm
│   │   ├── Win11Gold2.swm
│   │   ├── Win11Gold3.swm
│   │   └── Win11Gold4.swm
│   └── PostOOBE\
│       └── PostOOBE.cmd
└── bootmgr
```

### Second Partition (D:\ - NTFS) Structure:
```
D:\
├── Drivers\
|   ├── Dell\
│   |   ├── Latitude-5440\
│   |   ├── Latitude-5540\
│   |   ├── Latitude-5550\
│   |   ├── Latitude-PRO16250\
│   |   ├── PRO-QCM1250\
│   |  └── OptiPlex-7020Micro\
├── Apps\
│   └── (additional apps if needed)
└── BIOS\
    └── (BIOS update packages)
```

### Script Files
All script files are provided in the Boot_Partition and Data_Partition folders.

---

## Part 4: Deployment Process

### Steps

1. **Copy files to USB:**
   - Copy split image files (install*.swm) to `P:\Deploy\Images\`
   - Copy apply.cmd to `P:\Deploy\`
   - Copy createdisk_GPT.txt to `P:\Deploy\`
   - Copy unattend.xml to `P:\Deploy\`
   - Copy PostOOBE.cmd to `P:\Deploy\PostOOBE\`
   - Copy all driver folders to `D:\Drivers\`
   - Copy BIOS updates to `D:\BIOS\` (organized by model)
   - Copy additional apps to `D:\Apps\` if needed

2. **Boot target system from USB:**
   - Insert USB into target Dell system
   - Power on and press F12 for boot menu
   - Select USB drive (UEFI boot)

3. **Automated deployment:**
   - WinPE boots automatically
   - startnet.cmd launches apply.cmd
   - Script detects both USB partitions
   - Disk is partitioned (GPT/UEFI)
   - Image is applied from split files
   - Drivers are injected from second partition
   - unattend.xml copied to Windows\Panther
   - PostOOBE scripts are copied
   - System reboots automatically

4. **First boot (OOBE):**
   - Complete Windows OOBE
   - PostOOBE.cmd runs automatically during specialize pass
   - Remaining drivers installed via PnPUtil
   - BIOS updates applied
   - PostOOBE folder self-deletes

5. **Verification:**
   - Check Device Manager for missing drivers
   - Verify BIOS version
   - Confirm all applications present
   - Review `C:\Windows\Temp\PostOOBE.log`

---

## Troubleshooting

**Issue:** USB partitions not detected
- **Solution:** Verify both partitions have correct labels and files

**Issue:** Driver injection fails
- **Solution:** Check model name matches folder name exactly (case-sensitive)

**Issue:** Image application fails
- **Solution:** Verify all install*.swm files are present and not corrupted

**Issue:** System won't boot after deployment
- **Solution:** Verify UEFI boot mode enabled in BIOS, Secure Boot may need to be disabled temporarily

**Issue:** PostOOBE doesn't run
- **Solution:** Verify unattend.xml was copied to W:\Windows\Panther, keep USB connected during OOBE

**Issue:** unattend.xml not found during setup
- **Solution:** Windows Setup looks in \Windows\Panther for unattend.xml during specialize pass

---

## Notes

- Total deployment time: 30-45 minutes depending on hardware
- Drivers are injected twice: offline during deployment and online during PostOOBE
- BIOS updates require system restart after PostOOBE
- Keep USB connected through entire OOBE process
- unattend.xml is applied from Windows\Panther during first boot
- Test on each Dell model before production deployment
