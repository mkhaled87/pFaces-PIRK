#!/bin/bash

# defines for the targeted example
EXAMPLE_FOLDER=../../examples/arch18_benchmark/laub_loomis/
EXAMPLE_CFG=$EXAMPLE_FOLDER/laub_loomis.cfg
SS_DIM=7
IS_DIM=7
INITIAL_STATE=0.330970,0.244649,-0.133796,5.046261,-0.002903,0.044322,0.046198

# extract some stuff form the exampl's config file
INITIAL_TIME=$(grep -oP 'initial_time = "\K.*?(?=")' $EXAMPLE_CFG)
FINAL_TIME=$(grep -oP 'final_time = "\K.*?(?=")' $EXAMPLE_CFG)
STEP_SIZE=$(grep -oP 'step_size = "\K.*?(?=")' $EXAMPLE_CFG)

# build the serial RK tester
BIN_FILE=./serialRungeKutta45.exe
if test -f "$BIN_FILE"; then
rm $BIN_FILE
fi
g++ serialRungeKutta45.cpp -I$EXAMPLE_FOLDER -DSS_DIM=$SS_DIM -DIS_DIM=$IS_DIM -DINITIAL_STATE=$INITIAL_STATE -DINITIAL_TIME=$INITIAL_TIME -DFINAL_TIME=$FINAL_TIME -DSTEP_SIZE=$STEP_SIZE -o $BIN_FILE

# run it
$BIN_FILE