# 1 "kernel-pack/pirk.cpu.cl"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "kernel-pack/pirk.cpu.cl"
# 17 "kernel-pack/pirk.cpu.cl"
@pfaces-include:"pirk_utils.cl"

@pfaces-include:"gb_initialize_center.cl"
# 36 "kernel-pack/pirk.cpu.cl"
# 1 "kernel-pack/integrate_kfns.cl" 1
__kernel void gb_integrate_center_1(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k0[i] = dynamics_element(final_state, input, *t, i);
    tmp[i] = final_state[i] + ((@@true_step_size@@/5)) / 2.0*k0[i];
}

__kernel void gb_integrate_center_2(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k1[i] = dynamics_element(tmp, input, *t + 0.5*@@true_step_size@@, i);
    tmp[i] = final_state[i] + ((@@true_step_size@@/5)) / 2.0*k1[i];
}

__kernel void gb_integrate_center_3(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k2[i] = dynamics_element(tmp, input, *t + 0.5*@@true_step_size@@, i);
    tmp[i] = final_state[i] + ((@@true_step_size@@/5)) * k2[i];
}

__kernel void gb_integrate_center_4(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k3[i] = dynamics_element(tmp, input, *t + @@true_step_size@@, i);
    final_state[i] = final_state[i] + (((@@true_step_size@@/5)) / 6.0)*(k0[i] + 2.0*k1[i] + 2.0*k2[i] + k3[i]);
    *t += @@true_step_size@@;
}

__kernel void gb_integrate_center_5(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}

__kernel void gb_integrate_center_6(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}

__kernel void gb_integrate_center_7(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}

__kernel void gb_integrate_center_8(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}
# 37 "kernel-pack/pirk.cpu.cl" 2

@pfaces-include:"gb_initialize_radius.cl"
# 61 "kernel-pack/pirk.cpu.cl"
# 1 "kernel-pack/integrate_kfns.cl" 1
__kernel void gb_integrate_radius_1(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k0[i] = growth_bound_radius_dynamics(final_state, input, *t, i);
    tmp[i] = final_state[i] + ((@@true_step_size@@/5)) / 2.0*k0[i];
}

__kernel void gb_integrate_radius_2(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k1[i] = growth_bound_radius_dynamics(tmp, input, *t + 0.5*@@true_step_size@@, i);
    tmp[i] = final_state[i] + ((@@true_step_size@@/5)) / 2.0*k1[i];
}

__kernel void gb_integrate_radius_3(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k2[i] = growth_bound_radius_dynamics(tmp, input, *t + 0.5*@@true_step_size@@, i);
    tmp[i] = final_state[i] + ((@@true_step_size@@/5)) * k2[i];
}

__kernel void gb_integrate_radius_4(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{
    int i = get_global_id(0);
    k3[i] = growth_bound_radius_dynamics(tmp, input, *t + @@true_step_size@@, i);
    final_state[i] = final_state[i] + (((@@true_step_size@@/5)) / 6.0)*(k0[i] + 2.0*k1[i] + 2.0*k2[i] + k3[i]);
    *t += @@true_step_size@@;
}

__kernel void gb_integrate_radius_5(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}

__kernel void gb_integrate_radius_6(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}

__kernel void gb_integrate_radius_7(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}

__kernel void gb_integrate_radius_8(
    __global float *initial_state,
    __global float *final_state,
    __global float *input,
    __global float *k0,
    __global float *k1,
    __global float *k2,
    __global float *k3,
    __global float *tmp,
    __global float *t)
{

}
# 61 "kernel-pack/pirk.cpu.cl" 2
