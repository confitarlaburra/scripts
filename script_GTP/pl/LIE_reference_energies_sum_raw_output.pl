#main

if ( ($ARGV[0] eq "") || ($ARGV[1] eq "" ) ) {
    print "Usage of this script : LIE_bias_ts energy_Reference_ts\n";
    exit 1; 
}



##Read input file to fill energy arrays.
#printf    "%10s                        %10s\n","#Time (ps)", "LIE bias + Ref ene";
$bool_line_1 = 0;
$bool_line_2 = 0;
open (FILE_1, "$ARGV[0]"); #LIE bias file ts  
open (FILE_2, "$ARGV[1]"); #OSP ref energy ts

while (($line_1=<FILE_1>) && ($line_2=<FILE_2>)) {	
	#if ($line_1=~/^#/) {$bool_line_1 = 1;}
	
	if (($line_1=~/^\S+\s+(\S+)/)) {
                $energy_A =$1;

        }

	#if ($line_2=~/^#/) {$bool_line_2 = 1;}
	
	if (($line_2=~/^(\S+)\s+(\S+)/)) {
		$angle=$1;                 
		$energy_B =$2;
		push(@Bstate_array, $energy_R);
		$Total_bias = $energy_B + $energy_A;
		#printf   "%10.2f %10.2f %10.2f %10.2f\n",$angle,"0.0","0.0",$Total_bias;
		print "$angle $Total_bias\n"
        }
	

}
close FILE_1;
close FILE_2;



