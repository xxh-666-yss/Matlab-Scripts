function bestfis=GAR(Problem,Params)
disp('           ...                   ')
disp('===== ANN-GA =====')
disp('           ...                   ')
func=Problem.CostFunction;        % Cost Function
nVar=Problem.nVar;          % Number of Decision Variables
dimension=nVar;           % Size of Decision Variables Matrix
lb=Problem.VarMin;      % Lower Bound of Variables
up=Problem.VarMax;      % Upper Bound of Variables
MaxIt=Params.MaxIt;      % Maximum Number of Iterations
nPop=Params.nPop;        % Population Size
%% invoking GA Function
[BestRepGA,BestRepPGAPOS]=GA(nPop,MaxIt,lb,up,dimension,func);
bestfis.BestSol=BestRepPGAPOS;
bestfis.BestCost=BestRepGA;
end
