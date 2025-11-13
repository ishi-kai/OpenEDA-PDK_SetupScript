v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 480 -680 480 -80 {}
L 4 700 -680 700 -80 {}
L 4 260 -680 260 -80 {}
L 4 40 -680 40 -80 {}
L 4 920 -680 920 -80 {}
L 4 1140 -680 1140 -80 {}
L 4 1360 -680 1360 -80 {}
T {MOSFET} 40 -720 0 0 0.5 0.5 {}
T {MP.sym} 60 -680 0 0 0.4 0.4 {}
T {MN.sym} 60 -520 0 0 0.4 0.4 {}
T {MODEL (fixme!)} 60 -360 0 0 0.4 0.4 {}
T {TR10 STDcells} 920 -720 0 0 0.5 0.5 {}
T {etc...} 1060 -110 0 0 0.5 0.5 {}
T {Capacitor} 260 -720 0 0 0.5 0.5 {}
T {CSIO.sym} 280 -680 0 0 0.4 0.4 {}
T {Resistor} 480 -720 0 0 0.5 0.5 {}
T {RR.sym} 500 -680 0 0 0.4 0.4 {}
T {RS.sym} 500 -520 0 0 0.4 0.4 {}
T {Misc} 700 -720 0 0 0.5 0.5 {}
T {ISHI-kai} 1140 -720 0 0 0.5 0.5 {}
T {DP.sym} 720 -680 0 0 0.4 0.4 {}
T {DN.sym} 720 -520 0 0 0.4 0.4 {}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="Tokairika & OpenSUSI & ISHI-kai"}
C {MP.sym} 80 -600 0 0 {name=XM1 model=PMOS w=3.4u l=1u m=1 as=0 ad=0 ps=0 pd=0 nrd=0 nrs=0}
C {devices/code.sym} 60 -280 0 0 {name=TR10_MODELS
only_toplevel=true
format="tcleval( @value )"
value=".include $::LIB/../ip62_models"
spice_ignore=false}
C {MN.sym} 80 -440 0 0 {name=XM2 model=NMOS w=3.4u l=1u m=1 as=0 ad=0 ps=0 pd=0 nrd=0 nrs=0}
C {CSIO.sym} 340 -630 0 0 {name=XC1
model=F_CSIO
c=1u
x=1u
y=1u
m=1}
C {RR.sym} 560 -630 0 0 {name=R1
w=4u
R=1
l=13u
model=F_RR
spiceprefix=X
tc1=0
tc2=0}
C {RS.sym} 560 -470 0 0 {name=R2
w=4u
R=1
l=15u
model=F_RS
spiceprefix=X
tc1=0
tc2=0}
C {DP.sym} 790 -620 0 0 {name=D1 model=DP m=1}
C {DN.sym} 790 -460 0 0 {name=D2 model=DN m=1}
C {IP62_5_stdcell/AND2_X1.sym} 980 -600 0 0 {name=x1}
C {IP62_5_stdcell/BUF_X1.sym} 980 -460 0 0 {name=x2}
C {IP62_5_stdcell/NAND2.sym} 980 -320 0 0 {name=x3}
C {IP62_5_stdcell/OR2.sym} 980 -170 0 0 {name=x4}
