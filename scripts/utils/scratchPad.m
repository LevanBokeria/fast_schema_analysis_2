clear; clc;

dbstop if error;

load carbig
tbl = table(Horsepower,Weight,MPG);

modelfun = @(b,x)b(1) + b(2)*x(:,1).^b(3) + b(4)*x(:,2).^b(5);

beta0 = [-50 500 -1 500 -1];
mdl = fitnlm(tbl,modelfun,beta0)

X = [Horsepower,Weight];
y = MPG;
modelfun = @(b,x)b(1) + b(2)*x(:,1).^b(3) + b(4)*x(:,2).^b(5);

beta0 = [-50 500 -1 500 -1];

mdl = fitnlm(X,y,modelfun,beta0)