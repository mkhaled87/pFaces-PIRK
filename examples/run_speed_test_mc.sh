cd ../../bin
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_10/ex_n_link.cfg -d 2 -p | tee ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_20/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_50/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_100/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_200/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_500/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_1000/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_2000/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_5000/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_10000/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_20000/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_50000/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
./pfaces -CGH -k pirk.cpu@../examples/pirk/kernel-pack/ -cfg ../examples/pirk/speed_test_mc/ex_n_link_100000/ex_n_link.cfg -d 2 -p | tee -a ../examples/pirk/speed_test_mc/results.txt
cd ../examples/pirk
