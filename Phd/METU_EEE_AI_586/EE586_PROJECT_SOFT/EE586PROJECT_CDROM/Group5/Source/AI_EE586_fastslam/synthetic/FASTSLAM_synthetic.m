function FASTSLAM_synthetic(port,baud,time)
%close all;


SensorData=[];
EstimateMap = [];
global no_of_particles;
no_of_particles = 100;
curr_particle_no = 1;
total_no_of_landmarks = 0;
curr_no_of_landmarks = 0;

i=1;
t=1;
www=1;

% Initialize the particle set

% PARTICLE_SET(1).no_of_landmarks = 0;
t=1;
for i=1:no_of_particles
    PARTICLE_SET(1).particles(i).pose(1) = 0; % x position
    PARTICLE_SET(1).particles(i).pose(2) = 0; % y position
    PARTICLE_SET(1).particles(i).pose(3) = pi/2; % orientation
    PARTICLE_SET(1).particles(i).no_of_landmarks = 0;
    PARTICLE_SET(1).particles(i).impFact = 1;
end

% Measurement Covariance (precalculated)
R= [0.5 0;0 5*pi/180];


[Measurement,poseUpdate,tMax] = LoadTestData(0);
figure;
hold;
poseNoisy(1,:) = [0 0 pi/2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%while (kiks_ktime(port)<time)
while(t<tMax)  
    %%%%fastSlam algorithm 
    poseNoisy(t+1,:) = UpdatePose(poseNoisy(t,:),poseUpdate(t,:));
    if (Measurement(t+1,1) > 0.2)  % if there is valuable measurement
        for m=1:no_of_particles
            %update the pose according to the motion model
            PARTICLE_SET(t+1).particles(m).pose = UpdatePose(PARTICLE_SET(t).particles(m).pose,poseUpdate(t,:));
             
            %% calculate measurement likelihood of the observed landmarks
            for n=0:PARTICLE_SET(t).particles(m).no_of_landmarks-1
                %%calculate the measurement prediction
                deltaX = (PARTICLE_SET(t).particles(m).landmark(n+1).mean(1) - PARTICLE_SET(t+1).particles(m).pose(1));
                deltaY = (PARTICLE_SET(t).particles(m).landmark(n+1).mean(2) - PARTICLE_SET(t+1).particles(m).pose(2));
                mCap(1) = sqrt(deltaX^2 + deltaY^2);
                mCap(2) = mod(atan2(deltaY,deltaX)-PARTICLE_SET(t+1).particles(m).pose(3) , 2*pi);
                %                 if mCap(2)<0
                %                     mCap(2) = mCap(2)+2*pi;
                %                 end
                %%Calculate Jacobian
                G = [deltaX/mCap(1) deltaY/mCap(1) ; -deltaY/(mCap(1)^2) deltaX/(mCap(1)^2)];
                %%Calculate the measurement covariance 
                Q=G'*PARTICLE_SET(t).particles(m).landmark(n+1).cov*G + R;
                
                %Calculate the likelihood of correspondence
                A=Measurement(t+1,:)-mCap;
                
                if abs(A(2)) > pi,
                    if A(2) < 0,
                        A(2) = A(2) + 2*pi;                  
                    elseif A(2) > 0,
                        A(2) = -A(2) + 2*pi;
                    end;
                end;
                
                %% 
                www(n+1) = 1/(A*A');
                
                PARTICLE_SET(t+1).particles(m).weight(n+1)=exp(-2*0.5*A*inv(Q)*A')/(2*pi*sqrt(det(Q)));
            end;
            %set importance factor for new landmark ss 0.5 may not be true
            PARTICLE_SET(t+1).particles(m).weight(PARTICLE_SET(t).particles(m).no_of_landmarks+1) = 0.0001;
            % calculate the new number of features
            [ttemp,nCap] = max(PARTICLE_SET(t+1).particles(m).weight);
            %prev_no_of_particles = PARTICLE_SET.particles(m).no_of_landmarks;
            PARTICLE_SET(t+1).particles(m).no_of_landmarks = max(nCap,PARTICLE_SET(t).particles(m).no_of_landmarks);
            
            %%We know the new number of particles.Thus, we're ready for Kalman
            %%Filter Update 
            for n=1:PARTICLE_SET(t+1).particles(m).no_of_landmarks            
                if n==PARTICLE_SET(t).particles(m).no_of_landmarks+1  %is new feature
                    %initialize the mean of new landmark %% ss will be
                    %rearranged
                    PARTICLE_SET(t+1).particles(m).landmark(n).mean(1) = PARTICLE_SET(t+1).particles(m).pose(1) + Measurement(t+1,1) * cos(Measurement(t+1,2)+PARTICLE_SET(t+1).particles(m).pose(3));
                    PARTICLE_SET(t+1).particles(m).landmark(n).mean(2) = PARTICLE_SET(t+1).particles(m).pose(2) + Measurement(t+1,1) * sin(Measurement(t+1,2)+PARTICLE_SET(t+1).particles(m).pose(3));
                    
                    deltaX = (PARTICLE_SET(t+1).particles(m).landmark(n).mean(1) - PARTICLE_SET(t+1).particles(m).pose(1));
                    deltaY = (PARTICLE_SET(t+1).particles(m).landmark(n).mean(2) - PARTICLE_SET(t+1).particles(m).pose(2));
                    mCap(1) = sqrt(deltaX^2 + deltaY^2);
                    mCap(2) = mod(atan2(deltaY,deltaX)-PARTICLE_SET(t+1).particles(m).pose(3) , 2*pi);
                    %                     if mCap(2)<0
                    %                         mCap(2) = mCap(2)+2*pi;
                    %                     end
                    %%Calculate Jacobian
                    G = [deltaX/mCap(1) deltaY/mCap(1) ; -deltaY/(mCap(1)^2) deltaX/(mCap(1)^2)];
                    
                    PARTICLE_SET(t+1).particles(m).landmark(n).cov = inv(G)*R*inv(G)';
                    
                    %%initialize counter
                    PARTICLE_SET(t+1).particles(m).landmark(n).existence=1;
                    
                elseif n==nCap  %is observed feature
                    deltaX = (PARTICLE_SET(t).particles(m).landmark(n).mean(1) - PARTICLE_SET(t+1).particles(m).pose(1));
                    deltaY = (PARTICLE_SET(t).particles(m).landmark(n).mean(2) - PARTICLE_SET(t+1).particles(m).pose(2));
                    mCap(1) =  sqrt(deltaX^2 + deltaY^2);
                    mCap(2) = mod(atan2(deltaY,deltaX)-PARTICLE_SET(t+1).particles(m).pose(3) , 2*pi);
                    %                     if mCap(2)<0
                    %                         mCap(2) = mCap(2)+2*pi;
                    %                     end
                    %%Calculate Jacobian
                    G = [deltaX/mCap(1) deltaY/mCap(1) ; -deltaY/(mCap(1)^2) deltaX/(mCap(1)^2)];
                    
                    Q = G'*PARTICLE_SET(t).particles(m).landmark(n).cov*G + R;
                    
                    %Calculate Kalman Gain %% ss will be rearranged
                    K = PARTICLE_SET(t).particles(m).landmark(n).cov*G*inv(Q);
                    A=Measurement(t+1,:)-mCap;
                    if abs(A(2)) > pi,
                        if A(2) < 0,
                            A(2) = A(2) + 2*pi;                  
                        elseif A(2) > 0,
                            A(2) = -A(2) + 2*pi;
                        end;
                    end;
                    %Update mean
                    PARTICLE_SET(t+1).particles(m).landmark(n).mean = PARTICLE_SET(t).particles(m).landmark(n).mean +...
                        (K*A')';
                    
                    %Update Covariance
                    PARTICLE_SET(t+1).particles(m).landmark(n).cov = (eye(2) - K*G')*PARTICLE_SET(t).particles(m).landmark(n).cov;   
                    
                    PARTICLE_SET(t+1).particles(m).landmark(n).existence = PARTICLE_SET(t).particles(m).landmark(n).existence+1;
                    %%End of Kalman Filter Update
                else % all other features copy old mean and variance
                    PARTICLE_SET(t+1).particles(m).landmark(n).mean = PARTICLE_SET(t).particles(m).landmark(n).mean;
                    PARTICLE_SET(t+1).particles(m).landmark(n).cov = PARTICLE_SET(t).particles(m).landmark(n).cov;
                    PARTICLE_SET(t+1).particles(m).landmark(n).existence = PARTICLE_SET(t).particles(m).landmark(n).existence;
                    
                    %%negative filtering implementation ss
                end; % end of  if n==PARTICLE_SET(t).particles(m).no_of_landmarks+1
            end; % end of for n=1:PARTICLE_SET(t+1).particles(m).no_of_landmarks
            
            %             sum = 0;
            %             for a=1:PARTICLE_SET(t+1).particles(m).no_of_landmarks
            %                 sum = sum + PARTICLE_SET(t+1).particles(m).landmark(a).weight;
            %             end;
            %importance factor of the particle is calculated by averaging the weight
            %for each landmark.
            PARTICLE_SET(t+1).particles(m).impFact = max(www);%max(PARTICLE_SET(t+1).particles(m).weight); 
        end %end of for m=1:no_of_particles      
        %Resampling
        auxPARTICLE_SET = PARTICLE_SET(t+1);
        PARTICLE_SET(t+1) = ResampleParticles(auxPARTICLE_SET);
        
        for jj=1:no_of_particles,
            for q=1:PARTICLE_SET(t+1).particles(jj).no_of_landmarks,
                xm = PARTICLE_SET(t+1).particles(jj).landmark(q).mean;
                plot(xm(1),xm(2),'*')
            end;
        end;
        
    elseif (Measurement(t+1,1)<=0.2)
        %update the pose according to the motion model
        for m=1:no_of_particles
            PARTICLE_SET(t+1).particles(m).impFact = 1;
            PARTICLE_SET(t+1).particles(m).pose = UpdatePose(PARTICLE_SET(t).particles(m).pose,poseUpdate(t,:));
            PARTICLE_SET(t+1).particles(m).no_of_landmarks  = PARTICLE_SET(t).particles(m).no_of_landmarks ;
            for k=1:PARTICLE_SET(t).particles(m).no_of_landmarks
                PARTICLE_SET(t+1).particles(m).landmark(k) = PARTICLE_SET(t).particles(m).landmark(k);
            end
            %%negative filtering
            
        end; % end of for m=1:...
    end;% end of if (Measurement(t,1) > 0.2)  
    
    t=t+1;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% PLOT %%%%%%%%%%%%%%%
    
    for jj=1:no_of_particles,
        
        pp=PARTICLE_SET(t).particles(jj).pose;
        
        plot(pp(1),pp(2),'r.')
    end
    
    
    grid on
end

%%%%%%%%%%%%%%%%%end of while (kiks_ktime(port)<time


%%%%%%%%%%%%%%PLOT the FINAL MAP%%%%%%%%%%%%%%%%
%%estimate the weighted average for the pose and the landmark positions
weightedPose =[];
pp=0;
totWeight=0;
for t=1:tMax
    pp=0;
    totWeight=0;
    for jj=1:no_of_particles,       
        pp = pp + PARTICLE_SET(t).particles(jj).pose*PARTICLE_SET(t).particles(jj).impFact;
        totWeight = totWeight + PARTICLE_SET(t).particles(jj).impFact;
    end
    weightedPose(t,:) = pp / totWeight;
end

figure;
plot(weightedPose(:,1),weightedPose(:,2),'b');
hold on;
AXIS([-15 40 -15 80]);
grid;
plot(weightedPose(:,1),weightedPose(:,2),'kX','lineWidth',2);

for jj=1:no_of_particles,
    for q=1:PARTICLE_SET(tMax).particles(jj).no_of_landmarks,
        xm = PARTICLE_SET(tMax).particles(jj).landmark(q).mean;
        plot(xm(1),xm(2),'*')
    end;
end;

