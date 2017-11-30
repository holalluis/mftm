
classdef Point < handle
	    % Definition of object "point" for the mass balance
    % "point" represents the a river stretch
 
    properties
        E                   % [g/s] Entrance load 
        S                   % [g/s] Exit load        
        id                  % id
        id_up1              % id of point of entrance 1 
        id_up2              % id of point of entrance 2
        id_down1            % id of point of exit 1
        id_down2            % id of point of exit 2
        is_calculable       % boolea (1 or 0) indicates if the mass balance is applied 


        % simulated flow and extracted flow (if so) The initial flow would be Q+Qext
        Q                   % [m3/s]
        Qext                % [m3/s]
        Concentration       % [g/m3]


		% implementation river-decay (1)
        type   % [number]  "river"=1; "lake"=2
        f      % [dimensionless]  decimal between 0 and 1: fraction of E that leaves by S(it is calculated from HRT and k)
        L      % [meters] Length of stretch associated to the exit river stretch (for "lake", this will be the volume V)
        v      % [m/s] Average velocity associated to the exit river stretch (for "lake", this will be the flow Q)
        HRT    % [s] Hydraulic Retention Time (defined by L/v)
        k      % [1/s] First order decay rate (defined)

        % implementation river-decay (2) (alternative way to calculate F)
        vf     % [m/s] Mass transfer coefficient (defined)
        HL     % [m/s] Hydraulic Load (defined by h/HRT (river) or v/A (lake))
        h      % [m] River depth (defined)
        A      % [m^2] Surface area (defined)
    end % end properties

    methods
        function calculateS(obj)
        % calculate exit S=f*E
            % calculate concentration [g/m3] dividing the entrance load [g/s] by the sum of flows [m3/s]
            obj.Concentration = obj.E/(obj.Q + obj.Qext);

		
            % We calculate the entrance after an hypothetical extraction "point"
            newE = obj.E - obj.Qext * obj.Concentration;
 
            % We calculate the new exit load
            obj.S = obj.f * newE;

		end

        function calculateHRT(obj)
        % calculate HRT from length and velocity 
            obj.HRT = obj.L / obj.v ;
        end
   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 2 ways to calculate f, we call only one (they overwrite f)%     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%

         function calculatef_k(obj)
        % we calculate f from k
            obj.f = exp(-obj.HRT * obj.k);
        end
 
        function calculatef_vf(obj)
        % we calculate f from vf
            if obj.type == 1 % for river
               obj.f = exp(-obj.vf / obj.HL);
            elseif obj.type == 2 % for lake
               obj.f = 1 / (1+(obj.vf / obj.HL));
            end
        end
 
        % End of f calculation


        % FI CÀLCUL de la F

        function calculateHL(obj)
        % HL is calculated differently depending on rivers or lakes
            if obj.type == 1       % river
               obj.HL = obj.h / obj.HRT; 
            elseif obj.type == 2   % lake
               obj.HL = obj.v / obj.A ; 
            end
        end
    end % end methods


end % end class

