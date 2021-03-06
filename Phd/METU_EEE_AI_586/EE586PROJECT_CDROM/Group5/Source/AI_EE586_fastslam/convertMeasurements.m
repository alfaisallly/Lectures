function [MEASUREMENT_distbear]  = convertMeasurements(mean_sensor_data)

MEASUREMENT_mean_filt = mean_sensor_data(1:6);

MEAS_mean_thr=(MEASUREMENT_mean_filt>200).*MEASUREMENT_mean_filt;
MEAS_mean_thr=(MEASUREMENT_mean_filt>200 & MEASUREMENT_mean_filt<=300 )*40;
MEAS_mean_thr=(MEASUREMENT_mean_filt>300 & MEASUREMENT_mean_filt<=400 )*30 + MEAS_mean_thr;
MEAS_mean_thr=(MEASUREMENT_mean_filt>400 & MEASUREMENT_mean_filt<=600 )*20 + MEAS_mean_thr;
MEAS_mean_thr=(MEASUREMENT_mean_filt>600 & MEASUREMENT_mean_filt<=800 )*10 + MEAS_mean_thr;
MEAS_mean_thr=(MEASUREMENT_mean_filt>800)*5 + MEAS_mean_thr;

DISTBEAR_mean=[];

angle_mapping=[80 45 5 -5 -45 -80]'*(pi/180);

if nnz(MEAS_mean_thr)~=0
    MEASUREMENT_distbear(1)=sum(MEAS_mean_thr)/nnz(MEAS_mean_thr) + 25;
    
    vect=1-(MEAS_mean_thr==0);
    map_vect = angle_mapping.*vect;
    
    MEASUREMENT_distbear(2)=sum(map_vect./(MEAS_mean_thr+0.001))/sum(1./nonzeros(MEAS_mean_thr));   
else
    MEASUREMENT_distbear(1)=0;
    MEASUREMENT_distbear(2)=0;
end

% %%
% clear all;
% 
% load MEASUREMENT_mean;
% load MEASUREMENT_imp;
% 
% MEASUREMENT_mean_filt=MEASUREMENT_mean(:,1:6);
% MEASUREMENT_imp_filt=MEASUREMENT_imp(:,1:6);
% 
% [s a]=size(MEASUREMENT_imp);
% 
% MEAS_mean_thr=(MEASUREMENT_mean_filt>200).*MEASUREMENT_mean_filt;
% MEAS_mean_thr=(MEASUREMENT_mean_filt>200 & MEASUREMENT_mean_filt<=300 )*40;
% MEAS_mean_thr=(MEASUREMENT_mean_filt>300 & MEASUREMENT_mean_filt<=400 )*30 + MEAS_mean_thr;
% MEAS_mean_thr=(MEASUREMENT_mean_filt>400 & MEASUREMENT_mean_filt<=600 )*20 + MEAS_mean_thr;
% MEAS_mean_thr=(MEASUREMENT_mean_filt>600 & MEASUREMENT_mean_filt<=800 )*10 + MEAS_mean_thr;
% MEAS_mean_thr=(MEASUREMENT_mean_filt>800)*5 + MEAS_mean_thr;
% 
% MEAS_imp_thr=(MEASUREMENT_imp_filt>200).*MEASUREMENT_imp_filt;
% MEAS_imp_thr=(MEASUREMENT_imp_filt>200 & MEASUREMENT_imp_filt<=300 )*40;
% MEAS_imp_thr=(MEASUREMENT_imp_filt>300 & MEASUREMENT_imp_filt<=400 )*30 + MEAS_imp_thr;
% MEAS_imp_thr=(MEASUREMENT_imp_filt>400 & MEASUREMENT_imp_filt<=600 )*20 + MEAS_imp_thr;
% MEAS_imp_thr=(MEASUREMENT_imp_filt>600 & MEASUREMENT_imp_filt<=800 )*10 + MEAS_imp_thr;
% MEAS_imp_thr=(MEASUREMENT_imp_filt>800)*5 + MEAS_imp_thr;
% 
% 
% DISTBEAR_mean=[];
% DISTBEAR_imp=[];
% angle_mapping=[80 45 5 355 315 280]*(pi/180);
% 
% for i=1:s
%     if nnz(MEAS_mean_thr(i,:))~=0
%         DISTBEAR_mean(i,1)=sum(MEAS_mean_thr(i,:))/nnz(MEAS_mean_thr(i,:)) + 25;
%         
%         vect=1-(MEAS_mean_thr(i,:)==0);
%         map_vect = angle_mapping.*vect;
%         
%         DISTBEAR_mean(i,2)=sum(map_vect./(MEAS_mean_thr(i,:)+0.001))/sum(1./nonzeros(MEAS_mean_thr(i,:)));   
%     else
%         DISTBEAR_mean(i,1)=0;
%         DISTBEAR_mean(i,2)=0;
%     end
% end
% 
% for i=1:s
%     if nnz(MEAS_imp_thr(i,:))~=0
%         DISTBEAR_imp(i,1)=sum(MEAS_imp_thr(i,:))/nnz(MEAS_imp_thr(i,:)) + 25;
%         
%         vect=1-(MEAS_imp_thr(i,:)==0);
%         map_vect = angle_mapping.*vect;
%         
%         DISTBEAR_imp(i,2)=sum(map_vect./(MEAS_imp_thr(i,:)+0.001))/sum(1./nonzeros(MEAS_imp_thr(i,:)));   
%     else
%         DISTBEAR_imp(i,1)=0;
%         DISTBEAR_imp(i,2)=0;
%     end
% end
% 
% save DISTBEAR_imp DISTBEAR_imp;
% save DISTBEAR_mean DISTBEAR_mean;