%{ 
	This function generates a column with the 
    ids of points where WWTP effluents discharge 
    to the river.  It is used to create the table "WWTP" 
    as input for the catchment model
 
    WWTP
    ---+--------
    id | load
    ---+--------
       |
       |
       |

%}
function ids=ids_WWTP()
	ids=[
		1;
		6;
		10;
		11;
		15;
		16;
		18;
		20;
		24;
		28;
		32;
		35;
		38;
		43;
		44;
		46;
		53;
		58;
		62;
		63;
		70;
		72;
		79;
		82;
		84;
		94;
		97;
		101;
		103;
		106;
		110;
		111;
		113;
		114;
		116;
		117;
		123;
		125;
		128;
		130;
		131;
		133;
		134;
		137;
		137;
		139;
		139;
		140;
		141;
		142;
		144;
		150;
		150;
		151;
		153;
		157;
	];
end
