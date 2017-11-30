clear all; clc; close all;

% This script calculates loads and concentrations of diclofenac in WWTPs and in rivers (influent of WWTPs, effluent of WWTPs and river stretches)
% The user should prepare beforehand an excel file with the possible values of each parameter on each column, an excel file with the operational data in WWTPs and an excel file with river connectivity and geo-hydrological variables
% For our study, parameters values were calibrated using DREAM algorithm (Vrugt et al, 2016)

Pars = xlsread('Parameters_calibrated.xlsx');

PhC(:,1)= Pars(1:3,1); %F
PhC(:,2)= Pars(1:3,2);%kWWTP
PhC(:,3)= Pars(1:3,3); %kriver


[rows columns]=size(PhC);

% DESIGN ALGORITHM LOOP: simulates MCFM with one set of parameter values at
% a time
for q=1:rows
    
diclofenac = [PhC(q,1), PhC(q,2), PhC(q,3), 0.295]; %29.5 is WWTP average removal for diclofenac 

WWTPdata   = xlsread('WWTP_data.xlsx'); %WWTPs data
Riverdata  = xlsread('River_data.xlsx'); %river data

%execute MCFM.m file which uses diclofenac, WWTPdata, Riverdata
%we obtain data of influent and effluent loads and concentrations and loads and concentrations at defined river points

MCFM;

%Put together results of every q simulation in matrix format 
%river
prediction_loads(q,:) = prediction; %predicted diclofenac load (g/s) at every upstream part of river stretches 
prediction_conc(q,:) = concentration; %predicted diclofenac concentration (g/m3)

%wwtp
Influent_loads(q,:) = Lin; %influent load of every WWTP (g/d) 
Effluent_loads(q,:) = Leff*86400; %effluent load of every WWTP (g/d) 

end







