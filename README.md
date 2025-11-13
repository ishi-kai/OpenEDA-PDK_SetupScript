# What's This?
This is an environment setup script for creating layouts for the ISHI-kai version of OpenMPW.  
It runs on Ubuntu 22.04 and Ubuntu 24.04 on WSL2 (Windows Subsystem for Linux), as well as Ubuntu 22.04 and Ubuntu 24.04 on macOS.  

# Method of Execution
Simply execute the command below.  

## Common Commands
`bash eda-setup.sh`

## Installing the PDK
You must install the PDK tailored to the shuttle. Please select and install **only one** PDK tailored to the shuttle.  
In the case of changing the PDK, please delete it once and then reinstall it.  

### In the case of the Phenitec Shuttle PDK
`bash pdk_PTC06-setup.sh`

### In the case of the Tokai Rika Shuttle PDK
`bash pdk_TR10-setup.sh`

### In the case of the Minimal Fab Shuttle PDK
`bash pdk_MF20-setup.sh`

### In the case of the IHP Shuttle PDK
`bash pdk_ihp-sg13g2-setup.sh`

### In the case of the TinyTapeout(Skywater130) PDK
`bash pdk_sky130-setup.sh`

### In the case of the Wafer.Space(GF180MCU) Shuttle PDK
`bash pdk_gf180-setup.sh`

## Deleting the PDK
`bash uninstall.sh`

If you wish to change the PDK, please delete the existing PDK and then install only the PDK.

## About macOS
macOS installations may fail due to subtle version differences.  
Furthermore, as various tools and libraries are installed directly into your environment, this may impact your development setup. If you wish to avoid this, a VMware image is provided for your use.  
- [Image for Apple Silicon version of OR1 (Phenitec)](https://www.noritsuna.jp/download/ISHI-kai_EDA_vmware_OR1.tar.xz)
- [Image for Apple Silicon version of TR10 (Tokai Rika)](https://www.noritsuna.jp/download/ISHI-kai_EDA_vmware_TR10.tar.xz)
- [Image for Apple Silicon version of MF20](https://www.noritsuna.jp/download/ISHI-kai_EDA_vmware_MF20.tar.xz)
- [Image for Apple Silicon version of IHP](https://www.noritsuna.jp/download/ISHI-kai_EDA_vmware_iHP130.tar.xz)
- [Image for Apple Silicon version of TinyTapeout](https://www.noritsuna.jp/download/ISHI-kai_EDA_vmware_TT.tar.xz)
- [Image for Intel-based OR1 (Phenetic)](https://www.noritsuna.jp/download/ISHI-kai_EDA_Intel.vmwarevm.tar.xz)
- [Image for Intel version of TR10 (Tokai Rika)](https://www.noritsuna.jp/download/ISHI-kai_EDA_Intel.vmwarevm_TR10.tar.xz)
    - ID: ishi-kai
    - Pass: ishi-kai

## WSL Image
Depending on your WSL environment, installation may not be possible; therefore, we have also prepared an image for WSL.  

- [Image for WSL version of OR1 (Phenitec)](https://www.noritsuna.jp/download/ubuntu2204_ishi-kai_EDA.WSL.tar.xz)
    - ID: ishi-kai
    - Pass: ishi-kai
- [Image for WSL version of TR10 (Tokai Rika)](https://www.noritsuna.jp/download/ubuntu2204_ishi-kai_EDA.WSL_TR10.tar.xz)
    - ID: ishi-kai
    - Pass: ishi-kai

### Installing WSL Images
`wsl --import-in-place ubuntu2204_ishi-kai_EDA .\ubuntu2204_ishi-kai_EDA\ext4.vhdx`

The above command will be recognised. To execute it, please use the included "ubuntu2204_ishi-kai_EDA.lnk".  


### Deleting WSL Images
Please note that image files will also be deleted.  

`wsl --unregister ubuntu2204_ishi-kai_EDA`


# xschem
## Phenitec Shuttle PDK
### Resistance and capacitance values obtained from TEG (23 September 2017: akita11)
#### Sheet resistance obtained from TEG (Resistance and L/W obtained from TEG's V-I characteristics are shown in brackets)
- Poly : 20Ω□(500Ω, 45um/1.8um)
- Nwell : 1.1kΩ□(10kΩ, 45um/4.8um)
- Nact : - (- , 45um/3.0um)※Diode characteristics, rendering measurement impossible
- Pact : 42Ω□(625Ω, 45um/3.0um)

#### Capacity determined from TEG (in brackets: capacity and L/W determined from TEG's C-f characteristics)
- Poly-Metal (ACTEG15) 3.06fF/um^2 (44pF, 120um/120um)
- nMOS Cap (ACTEG14) 5.42fF(Accumulation and Strong Reversal)/3.82fF(Weak Reversal) (78pF/55pF, 120um/120um)
- pMOS Cap (ACTEG07) 5.34fF(Accumulation and Strong Reversal)/3.54fF(Weak Reversal) (77pF/51pF, 120um/120um)

## Tokai Rika Shuttle PDK
### Various PDK Manuals
- [Reference Manual](https://github.com/ishi-kai/OpenIP62/blob/main/IP62/Technology/doc/OS00_%E3%83%AA%E3%83%95%E3%82%A1%E3%83%AC%E3%83%B3%E3%82%B9%E3%83%9E%E3%83%8B%E3%83%A5%E3%82%A2%E3%83%AB.pdf)
- [Installation Manual](https://github.com/ishi-kai/OpenIP62/blob/main/IP62/Technology/doc/OS01_%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%83%9E%E3%83%8B%E3%83%A5%E3%82%A2%E3%83%AB.pdf)
- [Circuit Simulation Guidelines](https://github.com/ishi-kai/OpenIP62/blob/main/IP62/Technology/doc/OS02_%E5%9B%9E%E8%B7%AFsim%E3%82%AC%E3%82%A4%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3.pdf)
- [Layout Verification Guidelines](https://github.com/ishi-kai/OpenIP62/blob/main/IP62/Technology/doc/OS03_%E3%83%AC%E3%82%A4%E3%82%A2%E3%82%A6%E3%83%88%E6%A4%9C%E8%A8%BC%E3%82%AC%E3%82%A4%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3.pdf)
- [ESD Protection Device Guidelines](https://github.com/ishi-kai/OpenIP62/blob/main/IP62/Technology/doc/OS04_ESD%E4%BF%9D%E8%AD%B7%E7%B4%A0%E5%AD%90%E3%82%AC%E3%82%A4%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3.pdf)
- [Standard Cell Lineup](https://github.com/ishi-kai/OpenIP62/blob/main/IP62/Technology/doc/OS05_%E3%82%B9%E3%82%BF%E3%83%B3%E3%83%80%E3%83%BC%E3%83%89%E3%82%BB%E3%83%AB%E3%83%A9%E3%82%A4%E3%83%B3%E3%83%8A%E3%83%83%E3%83%97.pdf)
- [Element Connection Guidelines](https://github.com/ishi-kai/OpenIP62/blob/main/IP62/Technology/doc/OS06_%E7%B4%A0%E5%AD%90%E6%8E%A5%E7%B6%9A%E3%82%AC%E3%82%A4%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3.pdf)

### Calculation of Resistance and Capacitance
Please calculate the resistance values and capacitor capacitance using the tools below.  

- [Resistance and Capacitance Calculation Tool.xlsx](https://github.com/ishi-kai/OpenIP62/raw/main/IP62/Tools/%E6%8A%B5%E6%8A%97%E3%83%BB%E5%AE%B9%E9%87%8F%E8%A8%88%E7%AE%97%E3%83%84%E3%83%BC%E3%83%AB(%E3%82%AA%E3%83%BC%E3%83%97%E3%83%B3%E7%89%88).xlsx)

When calculating by hand, please use the values below.  

![Resistance Value Table](./images/TR10_res_cal.png)  
![Capacity Table](./images/TR10_cap_cal.png)  


### Available Metal Layer
Only Metal Layer 1 (ML1) and Metal Layer 2 (ML2) are available for use. Metal Layer 3 (ML3) also exists as a layer, but is reserved for placement and routing and therefore cannot be used.  


## In the case of Minimal Fab PDK
### Schematic for the first part of the contest
Mr.URA has provided the schematic for the first part of the contest; please use it when performing LVS and similar tasks.  

[Schematic for the first part of the contest](./schematic/MF20/base_contest2024_maze_de_inverter.sch)  

![Schematic for the first part of the contest](./images/MF20_contest_1part_schematic.png)


## In the case of IHP Shuttle PDK

## In the case of TinyTapeout PDK


# klayout
## Technology Selection
### In the case of the Phenitec Shuttle PDK and Tokai Rika Shuttle PDK
Select "OpenRule1umPDK" under Technology.

![Technology Selection](./images/klayout_tech_OR1.png)

### In the case of Minimal Fab Shuttle PDK
Select 'ICPS2023_5' via the technology.

![Technology Selection](./images/klayout_tech_MF20.png)


## Frame
### Phenitec Shuttle PDK
This is the pad layout. Please base your design on this.  
Pin numbers are counted counter-clockwise, starting from the bottom left corner (south face, west edge) as pin 1.  

[GDS file for frames](./GDS/PTC06/top_frame.gds)
![GDS file for frames](./images/PTC06_frame.png)

#### Pad
The production pads incorporate ESD protection. (Although they may appear to be plain metal pads, they will be replaced with ESD-protected pads for the final submission.)  
If ESD protection is unnecessary for your implementation (e.g., for analogue circuits) or you wish to implement it yourself, please follow the steps below to use the non-ESD-protected pads.  

![Pad Replacement Procedure 1](./images/PTC06_pad_noesd_1.jpg)
![Pad Replacement Procedure 2](./images/PTC06_pad_noesd_2.jpg)


### Tokai Rika Shuttle PDK
[GDS file for frames](./GDS/TR10/top_frame.gds)
![GDS file for frames](./images/TR10_frame.png)


### Minimal Fab Shuttle PDK
[GDS file for frames](https://github.com/mineda-support/ICPS2023_5/blob/main/Samples/Semicon2023/base_contest2023.GDS)
![GDS file for frames](./images/minimalfab_2024_frame.png)


### IHP Shuttle PDK
There are no frames provided for the iHP shuttle. You will need to design your own to suit the bonding machine and package supplier.  


### TinyTapeout PDK
* [GDS file for frames](TT/gds/tt_um_username_projectname.gds)
![GDS file for frames](./images/TT_frame.png)


# Sample
Various samples are available within [Samples](/samples).

# Method for Generating an Inductor
An automated generation tool is available.  
Generates files for the [FastHenry2](https://www.fastfieldsolvers.com/fasthenry2.htm) inductor simulator and GDS files.  

- [./generator/inductor_generator.py](./generator/inductor_generator.py) 

## Various Settings
- R
    - Inner I.D.[um]
- S
    - Space between wires[um]
- W
    - Wire Width[um]
- N
    - Number of rolls
- T
    - Wire Thickness[um]
- GuardRing_S
    - Distance from inductor to guard ring[um]
- GuardRing_W
    - Guard ring wire thickness[um]
- GuardRing
    - Because inductors are very susceptible to other wires, wire enclosures are provided as a safety distance.


# Option
Setup scripts for tools that will not be used in the hands-on but may be needed in some situations.  
Set up as needed.  
## QFlow
```
bash eda-qflow-option.sh
```


## Qucs-S
```
bash eda-Qucs-S-option.sh
```


## Xyce
```
bash eda-xyce-option.sh
```


# LICENSE
[LICENSE File](LICENSE)
