v {xschem version=3.4.6RC file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
L 4 480 -680 480 -80 {}
L 4 700 -680 700 -80 {}
L 4 260 -680 260 -80 {}
L 4 40 -680 40 -80 {}
L 4 920 -680 920 -80 {}
L 4 1140 -680 1140 -80 {}
L 4 1360 -680 1360 -80 {}
T {MOSFET} 40 -720 0 0 0.5 0.5 {}
T {PMOS_MIN.sym} 60 -680 0 0 0.4 0.4 {}
T {NMOS_MIN.sym} 60 -520 0 0 0.4 0.4 {}
T {MODEL (fixme!)} 1160 -670 0 0 0.4 0.4 {}
T {etc...} 1060 -110 0 0 0.5 0.5 {}
T {Capacitor} 260 -720 0 0 0.5 0.5 {}
T {CAP_MIN.sym} 280 -680 0 0 0.4 0.4 {}
T {Resistor} 480 -720 0 0 0.5 0.5 {}
T {R_POLY_MIN.sym} 500 -680 0 0 0.4 0.4 {}
T {RES_MIN.sym} 500 -520 0 0 0.4 0.4 {}
T {Misc} 700 -720 0 0 0.5 0.5 {}
T {ISHI-kai} 1140 -720 0 0 0.5 0.5 {}
T {PDIO_MIN.sym} 720 -680 0 0 0.4 0.4 {}
T {NDIO_MIN.sym} 720 -520 0 0 0.4 0.4 {}
T {HVPMOS_MIN.sym} 60 -360 0 0 0.4 0.4 {}
T {HVNMOS_MIN.sym} 60 -230 0 0 0.4 0.4 {}
T {PMOS_ESD_MIN.sym} 940 -680 0 0 0.4 0.4 {}
T {NMOS_ESD_MIN.sym} 940 -440 0 0 0.4 0.4 {}
N 120 -160 130 -150 {lab=#net1}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="ISHI-kai"}
C {devices/code.sym} 1170 -600 0 0 {name=MF20_MODELS
only_toplevel=true
format="tcleval( @value )"
value=".include $::LIB/SOI_CMOS"
spice_ignore=false}
C {PMOS_MIN.sym} 100 -600 0 0 {name=M1 model=pch w=5u l=0.18u as=0 ps=0 ad=0 pd=0 m=1}
C {NMOS_MIN.sym} 90 -440 0 0 {name=M2 model=nch w=5u l=0.18u as=0 ps=0 ad=0 pd=0 m=1}
C {CAP_MIN.sym} 340 -630 0 0 {name=C1
m=1
value=1p
footprint=1206
device=ceramic}
C {HVNMOS_MIN.sym} 90 -160 0 0 {name=m3 model=n6.0 w=1u l=0.8u m=1}
C {HVPMOS_MIN.sym} 90 -290 0 0 {name=m4 model=p6.0 w=1u l=0.5u m=1}
C {NMOS_ESD_MIN.sym} 980 -380 0 0 {name=x1}
C {PMOS_ESD_MIN.sym} 980 -620 0 0 {name=x2}
C {PDIO_MIN.sym} 780 -630 0 0 {}
C {NDIO_MIN.sym} 780 -470 0 0 {}
C {RES_MIN.sym} 560 -470 0 0 {name=R1
value=1k
footprint=1206
device=resistor
m=1}
C {R_POLY_MIN.sym} 560 -630 0 0 {}
