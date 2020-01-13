del *.raw
del *.txt

pfaces -CG -k pirk.cpu@..\..\..\kernel-pack -cfg .\vdp_oscillator.cfg -d 2 -p > gb.txt

pause