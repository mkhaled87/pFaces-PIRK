      barrier(CLK_GLOBAL_MEM_FENCE);

      k0[i] = dyn_fn(final_state, input, t, i);
    
      barrier(CLK_GLOBAL_MEM_FENCE);

      tmp[i] = final_state[i] + RK4_H / 2.0*k0[i];
	
      barrier(CLK_GLOBAL_MEM_FENCE);
      
      k1[i] = dyn_fn(tmp, input, t + 0.5*step_size,  i);

      barrier(CLK_GLOBAL_MEM_FENCE);

      tmp[i] = final_state[i] + RK4_H / 2.0*k1[i];
    
      barrier(CLK_GLOBAL_MEM_FENCE);

      k2[i] = dyn_fn(tmp, input, t + 0.5*step_size, i);
    
      barrier(CLK_GLOBAL_MEM_FENCE);

      tmp[i] = final_state[i] + RK4_H * k2[i];
    
      barrier(CLK_GLOBAL_MEM_FENCE);

      k3[i] = dyn_fn(tmp, input, t +  step_size, i);
    
      barrier(CLK_GLOBAL_MEM_FENCE);

      final_state[i] = final_state[i] + (RK4_H / 6.0)*(k0[i] + 2.0*k1[i] + 2.0*k2[i] + k3[i]);
    
      barrier(CLK_GLOBAL_MEM_FENCE);
      
      t += step_size;