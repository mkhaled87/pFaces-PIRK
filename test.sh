#!/bin/sh
set -e

# build kernel driver if not present
[ ! -f ./kernel-pack/pirk.driver ] && sh ./build.sh

# Testing example: ex_n_links
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

# End-to-end continuous trajectory reachability enclosure verification
python3 ./examples/ex_n_links/verify_reachability.py


