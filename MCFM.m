[a,b] = size(WWTPdata);
Pop = zeros(a,1); %census population connected to each WWTP 
Lin = zeros(a,1); %influent loads g/d
Leff = zeros(a,1); %effluent loads g/d
Cin = zeros(a,1); %influent concentrations mg/l
Ceff = zeros(a,1); %effluent concentrations mg/l
Sales = 534; %mg/y/person;

%We calculate the loads of pharamceutical at the effluent of each WWTP

    for i = 1:a
      F(i) = diclofenac(1); %dimensionless
      Pop(i) = WWTPdata(i,6); %census population connected to each WWTP
      Lin(i) = (F(i)*Pop(i)*Sales)/(365*1000); %units = g/d
      Cin(i) =  Lin(i)/ WWTPdata(i,4); %units = mg/l	

      %load and concentration in the effluent:
      kWWTP(i) = diclofenac(2)/1000; %units l/mg/d
      A = isnan(WWTPdata(:,2));
      if A(i)==1; %WWTP without data of HRT and MLSS, take average diclofenac WWTP removal
        Removal=1-diclofenac(4);
        Ceff(i) = Cin(i)*Removal; %mg/l
        Leff(i) = Ceff(i)*WWTPdata(i,5)/(24*60*60); %g/s (eflfuent loads in g/s are required as input for river mass balance code)    
      else %WWTP with data of HRT and MLSS - we can use formula
        HRT(i) = WWTPdata(i,2); %days
        MLSS(i) = WWTPdata(i,3); %mg/l
        %model Joss et al., 2006
        Ceff(i) = Cin(i)*(1/(1+kWWTP(i)*HRT(i)*MLSS(i))); %mg/l
        Leff(i) = Ceff(i)*WWTPdata(i,5)/(24*60*60); %g/s
      end      
end
%Effluent loads are stored under Leff
 
%recall river mass balance model:

WWTPs =[ids_WWTP(), Leff];
flag=0; %flag=zero means "calculate F from k"
np=size(Riverdata,1);
for i= 1:np
    kriver(i,1) = diclofenac(3);%units 1/s
end


River_Results = catchment(Riverdata,WWTPs,flag,kriver);

%Extract information from River_results

aa = length(River_Results);
prediction = zeros(aa,1);
concentration = zeros(aa,1);
 for i = 1:aa
   prediction(i) = River_Results(i).E; %diclofenac load (g/s) at every upstream part of a stretch
   concentration(i) = River_Results(i).Concentration; %diclofenac concentration (g/m3) calculated as the upstream load(sum of mass balance)/flow
   end

