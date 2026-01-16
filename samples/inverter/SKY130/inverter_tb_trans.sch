v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 190 -220 230 -220 {
lab=vout}
N 230 -220 230 -120 {
lab=vout}
N 190 -120 230 -120 {
lab=vout}
N 120 -90 150 -90 {
lab=vin}
N 120 -250 120 -90 {
lab=vin}
N 120 -250 150 -250 {
lab=vin}
N 50 -170 120 -170 {
lab=vin}
N 230 -170 300 -170 {
lab=vout}
N 190 -60 190 -10 {
lab=GND}
N 190 -90 200 -90 {
lab=GND}
N 200 -90 200 -50 {
lab=GND}
N 190 -50 200 -50 {
lab=GND}
N 190 -290 200 -290 {
lab=#net1}
N 200 -290 200 -250 {
lab=#net1}
N 190 -250 200 -250 {
lab=#net1}
N -130 -150 -130 -120 {
lab=vin}
N -130 -60 -130 -20 {
lab=GND}
N -210 -60 -210 -20 {
lab=GND}
N -210 -150 -210 -120 {
lab=VDD}
N 190 -400 190 -380 {
lab=VDD}
N 190 -320 190 -290 {
lab=#net1}
N 190 -290 190 -280 {
lab=#net1}
N 300 -170 300 -100 {
lab=vout}
N 300 -40 300 -10 {
lab=GND}
C {devices/vsource.sym} -210 -90 0 0 {name=Vdd value=1.8 savecurrent=false}
C {devices/vsource.sym} -130 -90 0 0 {name=vin value="pwl 0 0 10n 0 20n 1.8 60n 1.8 70n 0" savecurrent=false}
C {devices/lab_pin.sym} 50 -170 0 0 {name=p1 sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} 300 -170 0 1 {name=p2 sig_type=std_logic lab=vout}
C {devices/lab_pin.sym} -130 -150 1 0 {name=p3 sig_type=std_logic lab=vin}
C {devices/code_shown.sym} 380 -360 0 0 {name=spice only_toplevel=false value=".option savecurrent
.control
save all

* Tran analysis
tran 0.1n 100n
plot vout vin
plot i(vd)
wrdata ~/inverter_tb_tran.txt v(vout)
write inverter_tb_trans.raw
.endc"}
C {devices/code_shown.sym} 380 -110 0 0 {name=measure only_toplevel=false value="
.measure tran td_r trig v(vin) val=0.9 fall=1 targ v(vout) val=0.9 rise=1
.measure tran td_f trig v(vin) val=0.9 rise=1 targ v(vout) val=0.9 fall=1
.measure tran trise trig v(vout) val=0.4 rise=1 targ v(vout) val=1.4 rise=1
.measure tran tfall trig v(vout) val=1.4 fall=1 targ v(vout) val=0.4 fall=1
"}
C {devices/ammeter.sym} 190 -350 0 0 {name=Vd savecurrent=true spice_ignore=0}
C {devices/capa.sym} 300 -70 0 0 {name=Cload
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {sky130_fd_pr/pfet_01v8.sym} 170 -250 0 0 {name=M1
W=1.0
L=0.15
nf=1
mult=1
ad="expr('int((@nf + 1)/2) * @W / @nf * 0.29')"
pd="expr('2*int((@nf + 1)/2) * (@W / @nf + 0.29)')"
as="expr('int((@nf + 2)/2) * @W / @nf * 0.29')"
ps="expr('2*int((@nf + 2)/2) * (@W / @nf + 0.29)')"
nrd="expr('0.29 / @W ')" nrs="expr('0.29 / @W ')"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 170 -90 0 0 {name=M2
W=0.45
L=0.15
nf=1 
mult=1
ad="expr('int((@nf + 1)/2) * @W / @nf * 0.29')"
pd="expr('2*int((@nf + 1)/2) * (@W / @nf + 0.29)')"
as="expr('int((@nf + 2)/2) * @W / @nf * 0.29')"
ps="expr('2*int((@nf + 2)/2) * (@W / @nf + 0.29)')"
nrd="expr('0.29 / @W ')" nrs="expr('0.29 / @W ')"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/code.sym} -220 -390 0 0 {
name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt
"
spice_ignore=false
      }
C {devices/vdd.sym} -210 -150 0 0 {name=l3 lab=VDD}
C {devices/vdd.sym} 190 -400 0 0 {name=l1 lab=VDD}
C {devices/gnd.sym} -210 -20 0 0 {name=l2 lab=GND}
C {devices/gnd.sym} -130 -20 0 0 {name=l4 lab=GND}
C {devices/gnd.sym} 190 -10 0 0 {name=l5 lab=GND}
C {devices/gnd.sym} 300 -10 0 0 {name=l6 lab=GND}
