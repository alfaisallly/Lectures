%% Initial pose of khepera
function [initialPose, poseUpdate, INPUT_kiks] = Kinematic(a)

rot=41.65;

initialPose = [0 0 3*pi/2];

currPose = initialPose;

index_1 = 10;
index_2 = index_1 + 10;
index_3 = index_2 + 10;
index_4 = index_3 + 10;
index_5 = index_4 + 10;

poseUpdate = [];

%% Generate an input sequence for the wheel commands i mm
%% first entry for left wheel im mm, second entry for right wheel

%% Bulundu�un y�nde 10 defa 10'ar mm ile hareket et
for i=1:index_1
    INPUT_kiks(i,:) = [10 10];
    % calculate the pose update (input to kinematic model)
    poseUpdate(i,1) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*cos(currPose(3))/2;
    poseUpdate(i,2) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*sin(currPose(3))/2;
    poseUpdate(i,3) = (INPUT_kiks(i,1) - INPUT_kiks(i,2) ) * pi/2/2/rot;
    currPose = currPose + poseUpdate(i,:);
end

%% 9 derecelik 10 d�n�� yap
for i=index_1+1:index_2
    INPUT_kiks(i,:) = [rot/10 -rot/10];
    % calculate the pose update (input to kinematic model)
    poseUpdate(i,1) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*cos(currPose(3))/2;
    poseUpdate(i,2) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*sin(currPose(3))/2;
    poseUpdate(i,3) = (INPUT_kiks(i,2) - INPUT_kiks(i,1) ) * pi/2/2/rot;
    currPose = currPose + poseUpdate(i,:);
end

%% bulundu�un y�nde 10 defa 10'ar mm ile hareket et
for i=index_2+1:index_3
    INPUT_kiks(i,:) = [10 10];
    % calculate the pose update (input to kinematic model)
    poseUpdate(i,1) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*cos(currPose(3))/2;
    poseUpdate(i,2) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*sin(currPose(3))/2;
    poseUpdate(i,3) = (INPUT_kiks(i,2) - INPUT_kiks(i,1) ) * pi/2/2/rot;
    currPose = currPose + poseUpdate(i,:);
end

%% 9 derecelik 10 d�n�� yap
for i=index_3+1:index_4
    INPUT_kiks(i,:) = [rot/10 -rot/10];
    % calculate the pose update (input to kinematic model)
    poseUpdate(i,1) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*cos(currPose(3))/2;
    poseUpdate(i,2) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*sin(currPose(3))/2;
    poseUpdate(i,3) = (INPUT_kiks(i,2) - INPUT_kiks(i,1) ) * pi/2/2/rot;
    currPose = currPose + poseUpdate(i,:);
end

%% bulundu�un y�nde 10 defa 10'ar mm ile hareket et
for i=index_4+1:index_5
    INPUT_kiks(i,:) = [10 10];
    % calculate the pose update (input to kinematic model)
    poseUpdate(i,1) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*cos(currPose(3))/2;
    poseUpdate(i,2) = (INPUT_kiks(i,1)+INPUT_kiks(i,2))*sin(currPose(3))/2;
    poseUpdate(i,3) = (INPUT_kiks(i,2) - INPUT_kiks(i,1) ) * pi/2/2/rot;
    currPose = currPose + poseUpdate(i,:);
end