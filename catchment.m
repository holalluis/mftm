function [p] = catchment(Riverdata, WWTPs, flag, kriver);;

% Format matrix " Riverdata ": each row generates a new object “point”
    %   column 01: id of point
    %   column 02: id entrance 1
    %   column 03: id entrance 2
    %   column 04: id exit 1
    %   column 05: id exit 2
    %   column 06: position x of point
    %   column 07: position y of point
    %   column 08: flow (m3/s)
    %   column 09: type (1 river, 2 lake)
    %   column 10: length stretch (m)
    %   column 11: average velocity in stretch (m/s)
    %   column 12: first order decay rate (1/s)
    %   column 13: mass transfer coeficient (m/s)
    %   column 14: depth (m)
    %   column 15: Area (m^2)
    %   column 16: Extraction of water flow from stretch (if applicable) (m3/s)


% Initial check
if(size(Riverdata,2)~=16)
	error ' The matrix "Riverdata" should have 16 columns';
end
% End initial check

% Number of points and WWTPs in the network
np=size(Riverdata,1);
nd=size(WWTPs,1);

% Create a new array "p" of np new points
p = CreatePoints(np);

% We define the properties of np objects "point" from the matrix "Riverdata"
for i=1:np
    % Information on connectivity 
    % Take the id from the first column
    id             = Riverdata(i,01);
    p(id).id       = id;
    p(id).id_up1   = Riverdata(i,02);
    p(id).id_up2   = Riverdata(i,03);
    p(id).id_down1 = Riverdata(i,04);
    p(id).id_down2 = Riverdata(i,05);


    % At first, we asume every point is not calculable 
	p(id).is_calculable = 0;
 
   

    % River decay information
    p(id).Q        = Riverdata(i,08); % flow 
    p(id).type     = Riverdata(i,09); % river(1) o lake(2)
    p(id).L        = Riverdata(i,10); % length
    p(id).v        = Riverdata(i,11); % velocity
    p(id).k        = kriver(i,1); % decay rate
    p(id).vf       = Riverdata(i,13); % mass transfer coefficient
    p(id).h        = Riverdata(i,14); % depth
    p(id).A        = Riverdata(i,15); % area
    p(id).Qext     = Riverdata(i,16); % extracted flow
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE HRT, f & HL for each point %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       for i=1:np
        % HRT
        p(i).calculateHRT();
        % We calculate HRT according to flag (it is a parameter that we used to call the function)
        if(flag==0)
            % Calculates f from k
            p(i).calculatef_k();
        else
            % Calculates HL
            p(i).calculateHL();
            % Calculates f from vf
            p(i).calculatef_vf();
        end
    end
    % testing: we write manually the f value
    % for i=1:np p(i).f = 0.5 end
% End f calculation

% Count of the initial points of the network
counting_seeds=[];
% We read every point and determine which ones correspond to the start of the 
% network (we save them) 

for i=1:length(p)
    %   if point does not have entrances:
    %   assign a pre-defined entrance (0) 
    %   mark it as calculable
    %   sum 1 to the counting of seeds (stating points)
    %   calculate the exit load
    %   if point does have entrances
    %   assign NaN (not a number) to the entrance
    %   mark it as NON calculable

    if(p(i).id_up1==0 & p(i).id_up2==0)
        p(i).E  = 0;
        p(i).is_calculable = 1;
        counting_seeds = [counting_seeds i];
        p(i).calculateS();
    else
        p(i).E  = NaN;
        p(i).is_calculable = 0;
    end
end


% WWTPs
% We need to sum the WWTP loads to the entrance load of a point
for i=1:nd
    id=WWTPs(i,1);
    % As such, we allow more than 1 WWTP to discharge on the same point
    if(isnan(p(id).E))
        p(id).E = WWTPs(i,2);
    else
        p(id).E = p(id).E + WWTPs(i,2);
    end
end


% Find false points (points without entrances nor exits)
False_point=[];
for i=1:np
    if (p(i).id_up1==0 & p(i).id_up2==0 & p(i).id_down1==0 & p(i).id_down2==0)
        False_point =[False_point i];
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   MASS BALANCE CALCULATION               %
%   stops when every node is calculated    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while (true)
	calculables=[];
	for i=1:length(p)
		if(p(i).is_calculable)
			calculables=[calculables,i];
		end
	end

	%If all the nodes are calculable, it means the loop has finished
	if(length(calculables)>=length(p)) break; end

	%Find points where entrances have calculable points
	%This will mean that those points are also calculable and thus we mark them as calculable and we can calculate them 
	for i=1:np
        %we take the ids of entrances up(1) i up(2)
		up=[p(i).id_up1 p(i).id_up2];

		%There are 4 cases: 2 entrances that can be equal or different to 0 
        % [0 0], [0 1], [1 0], [1 1] 
 
        % If both entrances are 0, these are WWTPs or cases already calculated (calculables)

		if (isequal(up,[0 0]))
		    p(i).calculateS();
            % now we can continue by the next iteration
			continue
		end

		if (up(1)==0)	
			if (p(up(2)).is_calculable)
				p(i).is_calculable=1;
				if(isnan(p(i).E))
					p(i).E=p(up(2)).S;
				else
                    p(i).E=p(i).E+p(up(2)).S;
				end
				p(i).calculateS();
			end
			continue
		end
		if (up(2)==0)
			if (p(up(1)).is_calculable)
				p(i).is_calculable=1;
				if(isnan(p(i).E))
					p(i).E=p(up(1)).S;
                else
                    p(i).E=p(i).E+p(up(1)).S;
				end
				p(i).calculateS();
			end
			continue
		end

		%If the loop reaches this step, it means that both entrances to the point i are different to 0 
		%If both entances are calculables, the point i will be calculable as well
		if (p(up(1)).is_calculable & p(up(2)).is_calculable)
			p(i).is_calculable=1;
			if(isnan(p(i).E))
				p(i).E=p(up(1)).S+p(up(2)).S;
			else
                p(i).E=p(i).E+p(up(1)).S+p(up(2)).S;
			end
			p(i).calculateS();
		end
	end
end


