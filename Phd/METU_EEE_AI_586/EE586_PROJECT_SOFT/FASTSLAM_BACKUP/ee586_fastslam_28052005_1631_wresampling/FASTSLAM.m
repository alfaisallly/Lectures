function FASTSLAM(port,baud,time)
close all;
if nargin<3 time=10; end;
if nargin<2 baud=9600; end;
if nargin<1 port=-1; end;


SensorData=[];
EstimateMap = [];
global no_of_particles;
no_of_particles = 100;
curr_particle_no = 1;
total_no_of_landmarks = 0;
curr_no_of_landmarks = 0;

%Define the map
MAP = zeros(250,200);
MAP(30,100)=-270;
MAP(20:50,20:50) = 1;
MAP(160:190,140:170) = 1;

kiks(MAP);

ref = kiks_kopen([port,baud,1]);
kSetEncoders(ref,0,0);

reflex = 0;
%initially stationary
speed=[2 2];

t0=clock;
loops=0;
i=1;
t=1;

% Initialize the particle set

% PARTICLE_SET(1).no_of_landmarks = 0;
t=1;
for i=1:no_of_particles
    PARTICLE_SET(1).particles(i).pose(1) = 0; % x position
    PARTICLE_SET(1).particles(i).pose(2) = 0; % y position
    PARTICLE_SET(1).particles(i).pose(3) = pi/2; % orientation
    PARTICLE_SET(1).particles(i).no_of_landmarks = 0;
end

% Measurement Covariance (precalculated)
R= [0.2 0;0 2*pi/180];


[Measurement,Input,tMax] = LoadTestData2(0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%while (kiks_ktime(port)<time)
while(t<tMax)
    %    loops=loops+1;
    %    reflex = kProximity(ref);
    %    lights = kAmbient(ref);
    %    weightsL = [10 2 4 6 6 4 2 4 4];
    %    weightsR = [10 -2 -4 -6 -6 -4 -2 4 4];
    %    speed = calcSpd(weightsL,weightsR,reflex)/4;
    kSetSpeed(ref,speed(1),speed(2));   
    SensorData(:,i)=kProximity(ref);
    i=i+1;
    
    %%%%fastSlam algorithm 
    
    if (Measurement(t+1,1) > 0.2)  % if there is valuable measurement
        for m=1:no_of_particles
            %update the pose according to the motion model
            PARTICLE_SET(t+1).particles(m).pose = UpdatePose(PARTICLE_SET(t).particles(m).pose,Input(t,:));
            
            %weight=[];
            %% calculate measurement likelihood of the observed landmarks
            for n=0:PARTICLE_SET(t).particles(m).no_of_landmarks-1
                %%calculate the measurement prediction
                deltaX = (PARTICLE_SET(t).particles(m).landmark(n+1).mean(1) - PARTICLE_SET(t+1).particles(m).pose(1));
                deltaY = (PARTICLE_SET(t).particles(m).landmark(n+1).mean(2) - PARTICLE_SET(t+1).particles(m).pose(2));
                mCap(1) = sqrt(deltaX^2 + deltaY^2);
                mCap(2) = atan2(deltaY,deltaX);
                if mCap(2)<0
                    mCap(2) = mCap(2)+2*pi;
                end
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
                
                PARTICLE_SET(t+1).particles(m).weight(n+1)=exp(-0.5*A*inv(Q)*A')/ sqrt(det(Q));
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
                    PARTICLE_SET(t+1).particles(m).landmark(n).mean(1) = PARTICLE_SET(t+1).particles(m).pose(1) + Measurement(t+1,1) * cos(Measurement(t+1,2));
                    PARTICLE_SET(t+1).particles(m).landmark(n).mean(2) = PARTICLE_SET(t+1).particles(m).pose(2) + Measurement(t+1,1) * sin(Measurement(t+1,2));
                    
                    deltaX = (PARTICLE_SET(t+1).particles(m).landmark(n).mean(1) - PARTICLE_SET(t+1).particles(m).pose(1));
                    deltaY = (PARTICLE_SET(t+1).particles(m).landmark(n).mean(2) - PARTICLE_SET(t+1).particles(m).pose(2));
                    mCap(1) = sqrt(deltaX^2 + deltaY^2);
                    mCap(2) = atan2(deltaY,deltaX);
                    if mCap(2)<0
                        mCap(2) = mCap(2)+2*pi;
                    end
                    %%Calculate Jacobian
                    G = [deltaX/mCap(1) deltaY/mCap(1) ; -deltaY/(mCap(1)^2) deltaX/(mCap(1)^2)];
                    
                    PARTICLE_SET(t+1).particles(m).landmark(n).cov = inv(G)*R*inv(G)';
                    
                    %%initialize counter
                    PARTICLE_SET(t+1).particles(m).landmark(n).existence=1;
                    
                elseif n==nCap  %is observed feature
                    deltaX = (PARTICLE_SET(t).particles(m).landmark(n).mean(1) - PARTICLE_SET(t+1).particles(m).pose(1));
                    deltaY = (PARTICLE_SET(t).particles(m).landmark(n).mean(2) - PARTICLE_SET(t+1).particles(m).pose(2));
                    mCap(1) =  sqrt(deltaX^2 + deltaY^2);
                    mCap(2) = atan2(deltaY,deltaX);
                    if mCap(2)<0
                        mCap(2) = mCap(2)+2*pi;
                    end
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
            PARTICLE_SET(t+1).particles(m).impFact = mean(PARTICLE_SET(t+1).particles(m).weight); 
        end %end of for m=1:no_of_particles      
        %Resampling
        auxPARTICLE_SET = PARTICLE_SET(t+1);
        PARTICLE_SET(t+1) = ResampleParticles(auxPARTICLE_SET);      
    elseif (Measurement(t+1,1)<=0.2)
        %update the pose according to the motion model
        for m=1:no_of_particles
            PARTICLE_SET(t+1).particles(m).pose = UpdatePose(PARTICLE_SET(t).particles(m).pose,Input(t,:));
            PARTICLE_SET(t+1).particles(m).no_of_landmarks  = PARTICLE_SET(t).particles(m).no_of_landmarks ;
            for k=1:PARTICLE_SET(t).particles(m).no_of_landmarks
                PARTICLE_SET(t+1).particles(m).landmark(k) = PARTICLE_SET(t).particles(m).landmark(k);
            end
            %%negative filtering
            
        end; % end of for m=1:...
        
        
    end;% end of if (Measurement(t,1) > 0.2)  
    
    t=t+1;
end

%%%%%%%%%%%%%%%%%end of while (kiks_ktime(port)<time

kSetSpeed(ref,0,0);
kiks_kclose(ref);

function out = calcSpd(weightsL, weightsR, reflex)

mL = weightsL(1);
mR = weightsR(1);
for i=2:9
    mL = weightsL(i)*(1/400)*reflex(i-1)+mL;
    mR = weightsR(i)*(1/400)*reflex(i-1)+mR;
end
if sum(reflex(1:4)) > sum(reflex(5:8)) 
    out = [round(mL) round(mR)];
else
    out = [round(mR) round(mL)];
end;