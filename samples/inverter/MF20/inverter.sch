v {xschem version=3.4.6RC file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 190 -220 230 -220 {
lab=Q}
N 230 -220 230 -120 {
lab=Q}
N 190 -120 230 -120 {
lab=Q}
N 120 -90 150 -90 {
lab=A}
N 120 -250 120 -90 {
lab=A}
N 120 -250 150 -250 {
lab=A}
N 50 -170 120 -170 {
lab=A}
N 230 -170 300 -170 {
lab=Q}
N 190 -340 190 -280 {
lab=VDD}
N 190 -60 190 -10 {
lab=VSS}
N 190 -90 200 -90 {
lab=VSS}
N 200 -90 200 -50 {
lab=VSS}
N 190 -50 200 -50 {
lab=VSS}
N 190 -290 200 -290 {
lab=VDD}
N 200 -290 200 -250 {
lab=VDD}
N 190 -250 200 -250 {
lab=VDD}
C {PMOS_MIN.sym} 150 -250 0 0 {name=M1 model=pch w=20u l=6u as=0 ps=0 ad=0 pd=0 m=1}
C {NMOS_MIN.sym} 150 -90 0 0 {name=M2 model=nch w=15u l=6u as=0 ps=0 ad=0 pd=0 m=1}
C {iopin.sym} 190 -340 2 0 {name=p3 lab=VDD}
C {iopin.sym} 190 -10 0 0 {name=p4 lab=VSS}
C {iopin.sym} 300 -170 0 0 {name=p2 lab=Q}
C {iopin.sym} 50 -170 2 0 {name=p1 lab=A}
