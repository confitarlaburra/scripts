#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : angle vs bias time\n";
    exit 1; 
}

$G_Syn=0.0;
$G_Anti=0.0;
$total_counter = 0.0;
$Counter_Syn=  0.0;
$Counter_Anti = 0.0;
$kb = 0.008314511212;
$T = 298;
$kbT=$kb*$T;
(@anti) =();
(@syn)  =();
(@anti_bin) = ();
(@syn_bin) = ();
open (FILE_1, "$ARGV[0]");

## Read to collect data
while ($line=<FILE_1>) {
	if ($line=~/(\S+)\s+(\S+)/) {	 
		$angle =$1;
		$angle =~s/\s+//g;
		$bias = $2;
		$bias =~s/\s+//g;
		$total_counter ++;
		#print "$snapshot $angle\n";
		if ( ($angle >=140 && $angle <= 340) && ($bias != 0) ) {
			#$elevated = exp(-$bias/($kbT));
			$a = exp($bias/($kbT)); 
			push (@anti, $a);
			push (@anti_bin, 1);
			push (@syn_bin, 0);
			$G_Anti = $G_Anti + exp($bias/($kbT));
			#print "$G_Anti\n";
			$Counter_Anti++;
			#print " $angle $bias $Counter_Anti \n";
		}
		if ( ($angle > 340 || $angle < 140) && ($bias != 0) ) {
			$a = exp($bias/($kbT));
			push (@syn, $a);
			push (@anti_bin, 0);
			push (@syn_bin, 1);
			#print "$a\n";
			$G_Syn = $G_Syn + exp($bias/($kbT));
			#print "$G_Syn\n";
			$Counter_Syn++;
			#print " $angle $bias $Counter_Syn \n";		
		}
					
	}
}

close FILE_1;

if (($Counter_Anti ==0) || ($Counter_Syn ==0))  {
    print "No syn or anti states, cannot divide by 0";
    exit 1; 
}


#Dirty trick to unbias using tcf

open (OUT_2, ">anti_exp.dat");       #exp(bias) timeseries  file
open (OUT_3, ">syn_exp.dat");  #exp(bias)_anti timeseries  file
open (OUT_4, ">anti_bin.dat");       #exp(bias) timeseries  file
open (OUT_5, ">syn_bin.dat");  #exp(bias)_anti timeseries  file
print OUT_2 "\# Timeseries of exp(bias/kbT)\n";
print OUT_3 "\# Timeseries of exp(bias/kbT)\n";
print OUT_4 "\# Timeseries of anti\n";
print OUT_5 "\# Timeseries of syn\n";
foreach (@anti) { 
	print OUT_2 "$_ \n";
}
foreach (@syn) {
	print OUT_3 "$_ \n";
}
foreach (@anti_bin) { 
	print OUT_4 "$_ \n";
}
foreach (@syn_bin) {
	print OUT_5 "$_ \n";
}

close OUT_2;
close OUT_3;
close OUT_4;
close OUT_5;

system ("tcf \@files anti_exp.dat \@distribution 1 > error_anti_exp_bias.dat");
system ("tcf \@files syn_exp.dat \@distribution 1 >  error_syn_exp_bias.dat");
system ("tcf \@files anti_bin.dat \@distribution 1 > error_anti_bias.dat");
system ("tcf \@files syn_bin.dat \@distribution 1 >  error_syn_bias.dat");


#Get the errors from tcf output
open (FILE_1, "error_anti_exp_bias.dat");      #exp(bias) anti error  file
open (FILE_2, "error_syn_exp_bias.dat");       #exp(bias) syn  error  file
open (FILE_3, "error_anti_bias.dat");      #anti error  file
open (FILE_4, "error_syn_bias.dat");       #syn error  file

$bool_line_1 = 0;
$bool_line_2 = 0;
$bool_line_3 = 0;
$bool_line_4 = 0;
while (($line_1=<FILE_1>) && ($line_2=<FILE_2>) && ($line_3=<FILE_3>) && ($line_4=<FILE_4>)) {

	if (($line_1=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_1 == 2)) {
		#print "$1\n";
                $error_anti_exp_bias =$1;
		#print "$error_anti_exp_bias\n";
		$bool_line_1 =0;
        }
	if ( $line_1=~/^STATISTICS/) {$bool_line_1++;}	
	if ( $line_1=~/^#/) {$bool_line_1++;}
	
	
	if (($line_2=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_2 == 2)) {
                $error_syn_exp_bias =$1;
		$bool_line_2 =0;
        }
	if ( $line_2=~/^STATISTICS/) {$bool_line_2++;}
	if ( $line_2=~/^#/) {$bool_line_2++;}

	if (($line_3=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_3 == 2)) {
                $anti_error =$1;
		$bool_line_3 =0;
        }
	if ( $line_3=~/^STATISTICS/) {$bool_line_3++;}
	if ( $line_3=~/^#/) {$bool_line_3++;}

	if (($line_4=~/^\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) && ($bool_line_4 == 2)) {
                $syn_error =$1;
		$bool_line_4 =0;
        }
	if ( $line_4=~/^STATISTICS/) {$bool_line_4++;}
	if ( $line_4=~/^#/) {$bool_line_4++;}
}

close FILE_1;
close FILE_2;
close FILE_3;
close FILE_4;

#Compute free energies and errors

#Errors of the unbiasing
$error_anti=($kbT*$error_anti_exp_bias)/(($G_Anti/$Counter_Anti));
$error_syn=($kbT*$error_syn_exp_bias)/(($G_Syn/$Counter_Syn));

#G of unbiasing for anti and syn
 $G_Anti = -$kbT*log($G_Anti/$Counter_Anti); 
 $G_Syn = -$kbT*log($G_Syn/$Counter_Syn);   

# G of unbiasing
$total_error_unbias = sqrt(($error_anti**2 + $error_syn**2));
$Delta_G =  $G_Syn - $G_Anti ;

## G bias
$P_anti = $Counter_Anti/$total_counter; 
$P_syn  = $Counter_Syn/$total_counter; 
$Delta_G_bias = -$kbT*log($Counter_Syn/$Counter_Anti);
$error_bias = $kbT*sqrt(($anti_error/$P_anti)**2 + ($syn_error/$P_syn)**2 );

## Delta G  (syn/anti)
$G_anti_syn = $Delta_G_bias + $Delta_G;
$total_error = sqrt ($error_bias**2 + $total_error_unbias**2);

printf   "%10s  %5s %10s  %5s %10s  %5s %10s  %5s %10s  %5s\n","# G_anti_syn_unbias", "error" ,"G_anti_unbias", "error", "G_syn_unbias", "error","G_bias_anti_syn", "error","G_anti_syn", "error";
printf   "%10.2f          %5.2f %10.2f     %5.2f %10.2f    %5.2f %10.2f       %5.2f%10.2f  %5.2f\n",$Delta_G, $total_error_unbias, $G_Anti, $error_anti, $G_Syn, $error_syn ,$Delta_G_bias,  $error_bias, $G_anti_syn, $total_error ; 	

