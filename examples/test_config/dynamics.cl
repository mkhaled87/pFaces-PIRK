
float dynamics_element(__global float* x, __global float* u, float t, int i) {
  return x[i];
}