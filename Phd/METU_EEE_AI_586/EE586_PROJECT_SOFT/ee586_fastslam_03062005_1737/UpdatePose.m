function newPose = UpdatePose(oldPose,input)

newPose(1) = oldPose(1) + input(1) + 0.1*randn; 
newPose(2) = oldPose(2) + input(2) + 0.1*randn; 
newPose(3) = oldPose(3) + input(3) + 0.5*randn*pi/180; 