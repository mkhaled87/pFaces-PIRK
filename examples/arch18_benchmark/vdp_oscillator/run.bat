del *.raw
del out.txt

pfaces -C -k pirk.cpu@..\..\..\kernel-pack -cfg .\vdp_oscillator.cfg -d 1 -p > gb.txt

pause