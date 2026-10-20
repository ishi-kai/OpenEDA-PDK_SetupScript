v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -80 -80 -40 -80 {lab=A}
N -80 -80 -80 70 {lab=A}
N -80 70 -40 70 {lab=A}
N 0 -50 -0 40 {lab=Q}
N 0 -160 0 -110 {lab=VDD}
N -0 100 -0 140 {lab=VSS}
N -0 70 20 70 {lab=VSS}
N 20 70 20 120 {lab=VSS}
N 0 120 20 120 {lab=VSS}
N -0 -80 20 -80 {lab=VDD}
N 20 -130 20 -80 {lab=VDD}
N 0 -130 20 -130 {lab=VDD}
N 0 -0 110 -0 {lab=Q}
N -140 0 -80 0 {lab=A}
C {devices/opin.sym} 110 0 0 0 {name=p1 lab=Q}
C {devices/ipin.sym} -140 0 0 0 {name=p2 lab=A}
C {devices/iopin.sym} 0 -160 0 0 {name=p3 lab=VDD}
C {devices/iopin.sym} 0 140 0 0 {name=p4 lab=VSS}
C {symbols/pfet_03v3.sym} -20 -80 0 0 {name=M1
L=0.28u
W=0.42u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} -20 70 0 0 {name=M2
L=0.28u
W=0.42u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
