clear
dbstop if error
addpath('basic_tool'); 
addpath('OCSC');
addpath('3DMatrixMul');
addpath('mtimesx');%**
%% set para
A = rand(100,100,12100);
B = rand(100, 1 ,12100);
C = MuitiplyOfMatrix(A,B);