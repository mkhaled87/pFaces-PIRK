#!/bin/bash
for n in {10,20,50,100,200,500,1000,2000,5000,10000,20000,50000,100000,200000,500000,1000000,2000000,5000000,10000000,20000000,50000000,100000000,200000000,500000000,1000000000}; 
do 
    sed -i.sbup -e 's://dx = dx + u\[i\];:dx = dx + u[i];:' speed_test_mc/ex_n_link_$n/dynamics.cl; 
    cp ex_n_link/bounds.cl speed_test_mc/ex_n_link_$n/bounds.cl;
done
