#!/usr/bin/perl

if ($ARGV[0] eq "") {
    print "Usage of this script : namd.log.file\n";
    exit 1; 
}

sub TrapInt {
	my (@x) = @{$_[0]};
        my (@y) = @{$_[1]};
	my $size_x = @x;
	my $size_y = @y;
	if ($size_x != $size_y) { print "x and y must be the same size"; exit 1;}		
	$integral= 0.0;
	for ($count = 1; $count <= ($size_x -1); $count++) {
		my $delta_x = $x[$count] - $x[$old];
		my $old = $count -1;
		$integral += ($x[$count] - $x[$old]) * ($y[$count] + $y[$old]);
	}
	$integral *= 0.5;
	return ($integral);
}


@Anti_bias= ();
@Anti_angle= ();
@Syn_low_bias = ();
@Syn_low_angle = ();
@Syn_high_bias = ();
@Syn_high_angle = ();
$kb = 0.008314511212;
$T = 298;
$kbT=$kb*$T; 
open (FILE_1, "$ARGV[0]");
while ($line=<FILE_1>) {
	if ($line=~/(\S+)\s+(\S+)/) {	 
		$angle =$1;
		$angle =~s/\s+//g;
		$bias = $2;
		$bias =~s/\s+//g;
		if ( ($angle >=140 && $angle <= 340) && ($bias != 0) ) {
			$Anti = exp($bias/($kbT));
			push(@Anti_bias,$Anti );
			push(@Anti_angle,$angle);
		}
		if (($angle > 340) && ($bias != 0)) {
			$Syn = exp($bias/($kbT));
			push(@Syn_high_bias, $Syn);
			push (@Syn_high_angle, $angle);	
		}
		if (($angle < 140)  && ($bias != 0)) {
			$Syn = exp($bias/($kbT));			
			push(@Syn_low_bias, $Syn);
			push (@Syn_low_angle, $angle);
		}					
	}
}


$Anti_integral     = &TrapInt(\@Anti_angle,\@Anti_bias);
$Syn_high_integral = &TrapInt(\@Syn_high_angle,\@Syn_high_bias);
$Syn_low_integral  = &TrapInt(\@Syn_low_angle,\@Syn_low_bias);

$G_syn_anti  = -$kbT*log(($Syn_high_integral + $Syn_low_integral)/$Anti_integral);
$G_syn_anti  =  sprintf  "%.2f", $G_syn_anti;

print "Delta G Anti-Syn = $G_syn_anti\n";
close FILE_1;
