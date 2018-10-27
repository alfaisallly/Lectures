%% EE557 - Estimation Theory - TakeHome - Kalman Filtering %%
%% Salim SIRTKAYA - 112346
%% Fall 205-2006

%% this function creates a trajectory for the target tracking
%% application
%% The system model is as follows
%% X(k+1) = A.X(k) + GW(k)
%% Y(k) = C.X(k) + V(k)
%% the function takes .... as input and outputs ....

%% Wm = initial mean of process noise
%% Vm = initial mean of observation noise
%% Xm0 = initial mean of the state
%% S0 = initial covariance matrix of the state
%% T = time interval between the samples
%% N = total number of the points

function [X,Y,figNo] =  trajectory(A,G,C,Wm,Q,Vm,R,S0,Xm0,T,N,figNo)

rect_trajectory = [250 250 300 300];
rect_err = [150 150 700 500];
rect_gain = [250 250 400 300];

% the initial point and velocities in x-y plane
X(:,:,1) = mvnrnd(Xm0,S0)';
Y(:,:,1) = C * X(:,:,1) + mvnrnd(Vm,R)';

for k=2:N
    X(:,:,k) = A * X(:,:,k-1) + G * mvnrnd(Wm,Q)';
    Y(:,:,k) = C * X(:,:,k) + mvnrnd(Vm,R)';
end

x_observed(1:N) = Y(1,1,:);
y_observed(1:N) = Y(2,1,:);
figure('position',rect_trajectory);
plot(x_observed,y_observed);
TITLE('Part F - observed trajectory');
XLABEL(['FIGURE - ',num2str(figNo)]);
figNo = figNo+1;

x_actual(1:N) = X(1,1,:);
y_actual(1:N) = X(3,1,:);

figure('position',rect_trajectory);
plot(x_actual,y_actual);
TITLE('Part F - actual trajectory');
XLABEL(['FIGURE - ',num2str(figNo)]);
figNo = figNo+1;

