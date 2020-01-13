#!/bin/bash

EXAMPLE_FOLDER=../../examples/ex_quadrotor_swarm/

g++ sparse_matrix_tester.cpp -I $EXAMPLE_FOLDER -o sparse_matrix_tester.exe
./sparse_matrix_tester.exe