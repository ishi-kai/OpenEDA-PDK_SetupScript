v {xschem version=3.4.5 file_version=1.2
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
T {pmos.sym} 60 -680 0 0 0.4 0.4 {}
T {nmos.sym} 60 -520 0 0 0.4 0.4 {}
T {MODEL (fixme!)} 60 -360 0 0 0.4 0.4 {}
T {OR1 STDcells} 920 -720 0 0 0.5 0.5 {}
T {etc...} 1060 -110 0 0 0.5 0.5 {}
T {*Ndiff_cap.sym} 280 -360 0 0 0.4 0.4 {}
T {*Pdiff_cap.sym} 280 -520 0 0 0.4 0.4 {}
T {Capacitor} 260 -720 0 0 0.5 0.5 {}
T {Poly_cap.sym} 280 -680 0 0 0.4 0.4 {}
T {Resistor} 480 -720 0 0 0.5 0.5 {}
T {R_poly.sym} 500 -680 0 0 0.4 0.4 {}
T {R_pdiff.sym} 500 -520 0 0 0.4 0.4 {}
T {*R_ndiff.sym} 500 -360 0 0 0.4 0.4 {}
T {*HR_poly.sym} 500 -200 0 0 0.4 0.4 {}
T {Misc} 700 -720 0 0 0.5 0.5 {}
T {ISHI-kai} 1140 -720 0 0 0.5 0.5 {}
T {*) Sim model unavailable} 1200 -80 0 0 0.5 0.5 {}
T {**) No Pcells in klayout} 1200 -40 0 0 0.5 0.5 {}
T {**pts_np.sym} 720 -680 0 0 0.4 0.4 {}
T {**R_nwell.sym} 720 -520 0 0 0.4 0.4 {}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="MakeLSI & ISHI-kai"}
C {primitives/nfet.sym} 100 -430 0 0 {name=M2
model=nmos
W=1u
L=1u
m=1
}
C {primitives/pfet.sym} 100 -590 0 0 {name=M1 
model=pmos
W=2u
L=1u
m=1
}
C {devices/code.sym} 70 -300 0 0 {name=PTC06_MODELS
only_toplevel=true
format="tcleval( @value )"
value=".include $::LIB/mos.lib
.include $::LIB/passive.lib
.include $::LIB/diode.lib"
spice_ignore=false}
C {stdcells/an31.sym} 1020 -510 0 0 {name=x2 VDD=VDD VSS=GND
models=".include $::LIB/stdcells_sim/an31.lib"}
C {stdcells/an41.sym} 1020 -370 0 0 {name=x3 VDD=VDD VSS=GND
models=".include $::LIB/stdcells_sim/an41.lib"}
C {stdcells/buf1.sym} 1000 -250 0 0 {name=x4 VDD=VDD VSS=GND
models=".include $::LIB/stdcells_sim/buf1.lib"}
C {stdcells/an21.sym} 1020 -610 0 0 {name=x1 VDD=VDD VSS=GND
models=".include $::LIB/stdcells_sim/an21.lib"}
C {stdcells/fill.sym} 1000 -130 0 0 {name=x5 VDD=VDD VSS=GND}
C {primitives/Ndiff_cap.sym} 360 -270 0 0 {name=C2 model=Ndiff_cap W=1 L=1}
C {primitives/Pdiff_cap.sym} 360 -430 0 0 {name=C3 model=Pdiff_cap W=1 L=1 spiceprefix=X}
C {primitives/Poly_cap.sym} 360 -590 0 0 {name=C1 model=Poly_cap W=1 L=1}
C {primitives/R_poly.sym} 580 -590 0 0 {name=R1 model=R_Poly W=1 L=1}
C {primitives/R_pdiff.sym} 580 -430 0 0 {name=R2 model=R_pdiff W=1 L=1}
C {primitives/R_ndiff.sym} 580 -270 0 0 {name=R3 model=R_ndiff W=1 L=1}
C {stdcells/dff1.sym} 1030 -180 0 0 {name=x6 VDD=VDD VSS=GND
models=".include $::LIB/stdcells_sim/dff1.lib"}
C {primitives/pts_np.sym} 800 -590 0 0 {name=D1
model=pts_np_b
area=1e12
}
C {primitives/HR_poly.sym} 580 -110 0 0 {name=R4 model=HR_Poly W=1 L=1}
C {primitives/R_nwell.sym} 800 -430 0 0 {name=R5 model=R_nwell W=1 L=1}
