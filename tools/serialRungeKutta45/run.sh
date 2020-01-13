#!/bin/bash

EXAMPLE_FOLDER=../../examples/arch18_benchmark/laub_loomis/
EXAMPLE_CFG=$EXAMPLE_FOLDER/laub_loomis.cfg
SS_DIM=7
IS_DIM=7

INITIAL_TIME=$(grep -oP 'initial_time = "\K.*?(?=")' $EXAMPLE_CFG)
FINAL_TIME=$(grep -oP 'final_time = "\K.*?(?=")' $EXAMPLE_CFG)
STEP_SIZE=$(grep -oP 'step_size = "\K.*?(?=")' $EXAMPLE_CFG)

rm ./serialRungeKutta45.exe
g++ serialRungeKutta45.cpp -I$EXAMPLE_FOLDER -DSS_DIM=$SS_DIM -DIS_DIM=$IS_DIM -DINITIAL_TIME=$INITIAL_TIME -DFINAL_TIME=$FINAL_TIME -DSTEP_SIZE=$STEP_SIZE -o serialRungeKutta45.exe
./serialRungeKutta45.exe