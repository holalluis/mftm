clear all; clc; close all;

% This script calculates loads and concentrations of diclofenac in WWTPs and in rivers (influent of WWTPs, effluent of WWTPs and river stretches)
% The user should prepare beforehand an excel file with the possible values of each parameter on each column, an excel file with the operational data in WWTPs and an excel file with river connectivity and geo-hydrological variables
% For our study, parameters values were calibrated using DREAM algorithm (Vrugt et al, 2016)

Pars = xlsread('Pars_newLlobregat_3values.xlsx');

%CALCUALTION OF MODEL INPUTS
PhC(:,1)= Pars(:,1);
PhC(:,2)= Pars(:,2);
PhC(:,3)= Pars(:,3);


[rows columns]=size(PhC)

% DESIGN ALGORITHM LOOP
for q=1:rows
    
farmac = [PhC(q,1), PhC(q,2), PhC(q,3), 0.295];
%farmac = [43.07, 0.95, 0.54, 0.0000232];
data   = xlsread('dades depu2010 - censuspop.xlsx');
dades  = xlsread('dades2010_2.xlsx'); 

%execute edar2010.m file wich uses variables: farmac, data, dades
edar2010_bayesian;

%data2   = xlsread('dades depu2011 - censuspop.xlsx');
%dades2  = xlsread('dades2011_2.xlsx'); 

%edar2011_bayesian;

%resta de processament (figures, fits) a l'arxiu "post_processing"
post_processing_2010_2011_bayesian;

%river
prediction_allloads(q,:) = prediction;
prediction_loads2010(q,:) = prediction_stat;
prediction_allconc(q,:) = concentration;
prediction_conc2010(q,:) = conc_stat;
%prediction_loads2011(q,:) = prediction_stat2;
prediction_load_sea(q,:) = downstream_load_sel;

pred_removal2010(q,:) = removal2010;
%pred_removal2011(q,:) = removal2011;

%wwtp
%for every WWTP
influent2010(q,:) = predicted_loads_inf2010;
%influent2011(q,:) = predicted_loads_inf2011;
effluent2010(q,:) = predicted_loads_eff2010;
%effluent2011(q,:) = predicted_loads_eff2011;

%for selected WWTP (where we have measurements)
prediction_loads_influent2010(q,:) = predicted_loads_inf2010_sel;
%prediction_loads_influent2011(q,:) = predicted_loads_inf2011_sel;
prediction_loads_effluent2010(q,:) = predicted_loads_eff2010_sel;
%prediction_loads_effluent2011(q,:) = predicted_loads_eff2011_sel;

end

pred_removal2010_median = median(pred_removal2010);
%pred_removal2011_median = median(pred_removal2011);

pred_influent2010_median = median(influent2010);
%pred_influent2011_median = median(influent2011);
pred_effluent2010_median = median(effluent2010);
%pred_effluent2011_median = median(effluent2011);

post_processing_post2010

concentrations = prediction_allconc*1000000;

