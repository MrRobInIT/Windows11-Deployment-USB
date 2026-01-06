# Windows 11 Deployment USB for Dell & Lenovo Systems

## Overview
Complete offline USB deployment solution for Dell Latitude, Precision laptops and OptiPlex, Precision desktops with automated driver injection and BIOS updates.

## Features
- Dual-partition USB design (FAT32 boot + NTFS data)
- Split WIM image support for FAT32 compatibility
- Automated model detection and driver injection
- Post-OOBE driver installation and BIOS updates
- Unattended deployment with minimal user interaction

## USB Structure - 128GB

### Boot Partition (FAT32 - 32GB)
- WinPE bootable environment
- Split image files (install*.swm)
- Deployment scripts
- PostOOBE automation scripts

### Data Partition (NTFS - 96GB)
- Model-specific driver packages (50GB)
- BIOS update packages
- Additional applications

## Quick Start

1. **Review Documentation**
   - Read [Complete_Deployment_SOP.md](https://github.com/MrRobInIT/Windows11-Deployment-USB/blob/main/Documentation/Complete_Deployment_SOP.md) for full instructions
   - Review all scripts before deployment

2. **Prepare USB Drive**
   - Use 64GB USB drive
   - Follow WinPE USB creation steps in SOP

3. **Copy Files**
   - Boot Partition: Copy contents from `Boot_Partition/` folder
   - Data Partition: Copy contents from `Data_Partition/` folder
   - Add your split image files to `Deploy/Images/`
   - Add your drivers to `Drivers/` (organized by model)

4. **Deploy**
   - Boot target system from USB
   - Follow automated deployment process
   - Keep USB connected through OOBE

## Requirements
- Windows ADK with WinPE add-on
- 64GB USB drive
- Dell Latitude/Precision/OptiPlex systems
- UEFI boot mode enabled

## Supported Models
- Dell Latitude 3440
- Dell Latitude 5440
- Dell Latitude 5540
- Dell Latitude 5550
- Dell Pro 14 PC14250
- Dell Pro 16 PC16250
- Dell Pro 16 Plus PB16250
- Dell PRO QCM1250
- Dell Pro Micro QCM1250
- Dell Pro Slim Plus QBS1250
- Dell Pro Slim QCS1250
- Dell Pro Slim QCS1255
- Dell OptiPlex 7020Micro
- Lenovo X1

(Add additional models by creating corresponding driver folders)

## File Locations

### Your Image Files (Not Included)
Place your split image files in:
- `Boot_Partition/Deploy/Images/Win11Gold.swm`
- `Boot_Partition/Deploy/Images/Win11Gold2.swm`
- `Boot_Partition/Deploy/Images/Win11Gold3.swm`
- etc.

### Your Driver Files (Not Included)
Organize drivers by model in:
- `Data_Partition/Drivers/Latitude-3440/`
- `Data_Partition/Drivers/Latitude-5440/`
- `Data_Partition/Drivers/Latitude-3520/`
- `Data_Partition/Drivers/Latitude-5540/`
- `Data_Partition/Drivers/Latitude-5550/`
- `Data_Partition/Drivers/OptiPlex-7020Micro/`
- `Data_Partition/Drivers/PC14250/`
- `Data_Partition/Drivers/PC16250/`
- `Data_Partition/Drivers/PRO16250/`
- `Data_Partition/Drivers/PRO-QCM1250/`
- `Data_Partition/Drivers/PRO-QxS1250/`
- `Data_Partition/Drivers/Lenovo/`

### Your BIOS Updates (Not Included)
Organize BIOS updates by model in:
- `Data_Partition/BIOS/Latitude-5440/`
- `Data_Partition/BIOS/Latitude-5550/`
- etc.

## Deployment Time
- Image application: 15-30 minutes
- Driver injection: 10-20 minutes
- Total deployment: 30-45 minutes

## Documentation

- Complete Deployment SOP: [Documentation/Complete_Deployment_SOP.md](https://github.com/MrRobInIT/Windows11-Deployment-USB/blob/main/Documentation/Complete_Deployment_SOP.md)

Related:
- Master USB Build SOP (WinPE, image prep/capture, `startnet.cmd`, `apply.cmd`, `createdisk_GPT.txt`, drivers, split WIMs).

## Troubleshooting
See [Complete_Deployment_SOP.md](https://github.com/MrRobInIT/Windows11-Deployment-USB/blob/main/Documentation/Complete_Deployment_SOP.md) for detailed troubleshooting steps.

## License
MIT License - Feel free to modify and distribute

## Contributing
Pull requests welcome for additional model support or improvements.

## Author
RM 24OCT2025

## Version
1.0.0 - Initial Release
