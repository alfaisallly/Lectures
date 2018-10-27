function [Measurement,Input,tMax]=LoadTestData(arg)

tMax=30;
%%%%% TEST CASE %%%%%%%%%%%%%
for i=1:6
    Input(i,:) = [0 5 0];
end
Input(1,:)=[0 0 0];

for i=7:11
    Input(i,:)=[0 8 0];
end

Input(12,:)=[5 0 3*pi/2];

for i=13:14,
    Input(i,:)=[5 0 0];
end

for i=15:16,
    Input(i,:)=[8 0 0];
end

Input(17,:)=[0 -8 3*pi/2];

for i=18:20,
    Input(i,:)=[0 -8 0];
end

Input(21,:)=[-8 0 3*pi/2];

Input(22,:)=[-8 0 0];

Input(23,:)=[0 -8 pi/2];

Input(24,:)=[0 -5 0];

Input(25,:)=[-5 0 3*pi/2];

for i=26:28,
    Input(i,:)=[0 -5 0];
end

Input(29,:)=[-5 0 3*pi/2];


Measurement(1,:) = [0 0];
Measurement(2,:) = [0 0];
Measurement(3,:) = [0 0];
Measurement(4,:) = [5*sqrt(2)+0.2*randn pi/4+randn*pi/180];
Measurement(5,:) = [5+0.2*randn abs(randn)*pi/180];
Measurement(6,:) = [5*sqrt(2)+0.2*randn 7*pi/4+randn*pi/180];
Measurement(7,:) = [0 0];
Measurement(8,:) = [0 0];
Measurement(9,:) = [0 0];
Measurement(10,:) = [8*sqrt(2)+0.2*randn 3*pi/4+randn*pi/180];
Measurement(11,:) = [8+0.2*randn pi+randn*pi/180];
Measurement(12,:) = [8*sqrt(2)+0.2*randn 5*pi/4+randn*pi/180];
Measurement(13,:) = [0 0];
Measurement(14,:) = [0 0];
Measurement(15,:) = [8*sqrt(2)+0.2*randn 7*pi/4+randn*pi/180];
Measurement(16,:) = [8+0.2*randn 3*pi/2+randn*pi/180];
Measurement(17,:) = [8*sqrt(2)+0.2*randn 5*pi/4+randn*pi/180];
Measurement(18,:) = [8+0.2*randn pi+randn*pi/180];
Measurement(19,:) = [8*sqrt(2)+0.2*randn 3*pi/4+randn*pi/180];
Measurement(20,:) = [0 0];
Measurement(21,:) = [0 0];
Measurement(22,:) = [0 0];
Measurement(23,:) = [0 0];
Measurement(24,:) = [0 0];
Measurement(25,:) = [0 0];
Measurement(26,:) = [5*sqrt(2)+0.2*randn 5*pi/4+randn*pi/180];
Measurement(27,:) = [5+0.2*randn pi+randn*pi/180];
Measurement(28,:) = [5*sqrt(2)+0.2*randn 3*pi/4+randn*pi/180];
Measurement(29,:) = [0 0];
Measurement(30,:) = [0 0];