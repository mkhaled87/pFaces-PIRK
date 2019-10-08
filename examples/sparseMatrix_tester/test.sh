#!/bin/bash

EXAMPLE_FOLDER=../ex_quadrotor_swarm/

g++ sparse_matrix_tester.cpp -I $EXAMPLE_FOLDER -o sparse_matrix_tester
./sparse_matrix_tester