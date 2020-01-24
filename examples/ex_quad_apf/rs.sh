if [ "$1" = "" ]
then
  echo "testing system with 1 quadrotor."
  let n=12
  let nrows=3
else
  echo "testing system with $1 quadrotor(s)."
  let n=12*$1
  let nrows=3*$1+3  
fi
echo $n

pfaces -CG -d 1 -p -k pirk.cpu@../../kernel-pack -cfg ./ex_quad_apf.cfg -co "save_result=false,mem_efficient=false,method_choice=3,states.dim=$n,inputs.dim=$n,row_max=$nrows"
