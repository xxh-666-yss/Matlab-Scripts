function [Cost out]=TrainAnnCost(wb,net,data)
wb=wb';
x=data.Inputs;
t=data.Targets;
net = setwb(net, wb);
y= net(x);
error = t - y;
MSE=mean(error(:).^2);
RMSE=sqrt(MSE);
Cost=RMSE;
out.net=net;
out.y=y;
out.erorr=error;
out.MSE=MSE;
out.RMSE=RMSE;
end