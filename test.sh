#!/bin/sh
set -e

# Build kernel driver if not present or incrementally if build exists
if [ -d build ] && [ -f ./kernel-pack/pirk.driver ]; then
    cmake --build build --config Release
else
    sh ./build.sh
fi

echo "================================================================================"
echo " Running pFaces-PIRK E2E Verification Test Suite"
echo "================================================================================"

# ==============================================================================
# Example 1: ex_n_links (10D Traffic Flow Network: GB, Mem-Eff, CTMM, MC, MCHD)
# ==============================================================================
echo "\n[Test 1/4] Running Example: ex_n_links (Traffic Network 10D)..."
cd examples/ex_n_links
pfaces -CG -d 1 -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -p -co "record_pipe=true"
cp minimal_kernel.result_gb_center.raw minimal_kernel_gb.result_gb_center.raw
cp minimal_kernel.result_gb_radius.raw minimal_kernel_gb.result_gb_radius.raw
if [ -f minimal_kernel.result_gb_center_pipe.raw ]; then
    cp minimal_kernel.result_gb_center_pipe.raw minimal_kernel_gb.result_gb_center_pipe.raw
    cp minimal_kernel.result_gb_radius_pipe.raw minimal_kernel_gb.result_gb_radius_pipe.raw
fi
pfaces -CG -d 1 -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -p -co "mem_efficient=true"
pfaces -CG -d 1 -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -p -co "method_choice=2"
pfaces -CG -d 1 -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -p -co "method_choice=3"
pfaces -CG -d 1 -k pirk.cpu@../../kernel-pack -cfg ./ex_n_link.cfg -p -co "method_choice=4"
cd ../..
python3 ./examples/ex_n_links/verify_reachability.py

# ==============================================================================
# Example 2: ex_vehicle7d (7D Autonomous Vehicle Lane-Change Maneuver)
# ==============================================================================
echo "\n[Test 2/4] Running Example: ex_vehicle7d (BMW 320i 7D Vehicle Lane-Change)..."
cd examples/ex_vehicle7d
pfaces -CG -d 1 -k pirk.cpu@../../kernel-pack -cfg ./vehicle.cfg -p -co "record_pipe=true"
cd ../..
python3 ./examples/ex_vehicle7d/verify_vehicle7d.py

# ==============================================================================
# Example 3: arch18_benchmark/vdp_oscillator (2D Van der Pol Limit Cycle)
# ==============================================================================
echo "\n[Test 3/4] Running Example: arch18_benchmark/vdp_oscillator (VDP Oscillator 2D)..."
cd examples/arch18_benchmark/vdp_oscillator
pfaces -CG -d 1 -k pirk.cpu@../../../kernel-pack -cfg ./vdp_oscillator.cfg -p -co "record_pipe=true"
cd ../../..
python3 ./examples/arch18_benchmark/vdp_oscillator/verify_vdp.py

# ==============================================================================
# Example 4: arch18_benchmark/laub_loomis (7D Laub-Loomis Enzymatic Reaction Network)
# ==============================================================================
echo "\n[Test 4/4] Running Example: arch18_benchmark/laub_loomis (Laub-Loomis 7D)..."
cd examples/arch18_benchmark/laub_loomis
pfaces -CG -d 1 -k pirk.cpu@../../../kernel-pack -cfg ./laub_loomis.cfg -p -co "record_pipe=true"
cd ../../..
python3 ./examples/arch18_benchmark/laub_loomis/verify_laub_loomis.py

echo "\n================================================================================"
echo " All pFaces-PIRK E2E Verification Tests and Plots Completed Successfully!"
echo "================================================================================"
