function y=Mutate(x,mu,VarMin,VarMax)

    nVar=numel(x);
    
    nmu=ceil(mu*nVar);
    
    j=randsample(nVar,nmu);
    j=j(1);
    sigma=0.1*(VarMax(1)-VarMin(1));
    
    y=x;
    y(j)=x(j)+sigma*randn(size(j));
    
    y=max(y,VarMin(1));
    y=min(y,VarMax(1));

end