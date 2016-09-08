#!/usr/bin/perl -w

$usage=" 

#########################################################################
### createdir_charm.pl [type] [snap dir]
###          under the dir where snaps are sit
###
### example: createdir_charm.pl nat s1 s2 s3
###          createdir_charm.pl mut s*
#########################################################################
\n";

sub get_last_timestep {
   my ($filename) = @_;

   my ($timestep,@fft);
   open(IN,"<$filename") || die "Cannot open input xsc file $filename\n";

   #skip two header lines
   $_ = <IN>;
   $_ = <IN>;

   $_ = <IN>;
   @fft = split;
   $timestep = $fft[0];

   return $timestep;

}


sub bydir 
    {
    ($a_num) = $a =~ /(\d+)$/;
    ($b_num) = $b =~ /(\d+)$/;
    $a_num <=> $b_num;
    }

$len =0;
if(($len=$#ARGV+1) < 2) {
  print $usage;
  exit(1);
}

$TYPE=shift;

@dirs=@ARGV;


foreach $dir (@dirs)
  {
    $dirname = $dir;

    opendir(DIR, "$dirname") or die "couldn't read directory $dirname: $!\n";

    @subdirs = grep(/^r\d+/, readdir(DIR));

    @subdirs = sort bydir @subdirs;

    $last_dir = $subdirs[-1];

    ($last_num) = $last_dir =~ /(\d+)$/;

    print "last dir is $last_num\n";

    $new_num = $last_num + 1;
 
    $new_dir = "r" . $new_num;

    mkdir("$dir/$new_dir", 0777) or warn "couldn't mkdir $new_dir: $!\n";

    # figure out timestep last run has finished
    $timestep = get_last_timestep("$dir/$last_dir/$TYPE.$last_num.rstr.xsc");    

    # generate a new input file from template
    system("sed 's/OLD/$last_num/g' $TYPE.template | sed 's/NEW/$new_num/g' | sed 's/TIMESTEP/$timestep/g' > $dir/$new_dir/$TYPE.$new_num.in");

    # copy old files from last_dir 
    system("cp $dir/$last_dir/$TYPE.$last_num.rstr.coor $dir/$new_dir/");
    system("cp $dir/$last_dir/$TYPE.$last_num.rstr.vel $dir/$new_dir/");
    system("cp $dir/$last_dir/$TYPE.$last_num.rstr.xsc $dir/$new_dir/");
    system("cp $dir/$last_dir/par*.inp $dir/$new_dir/");
    system("cp $dir/$last_dir/par*.prm $dir/$new_dir/");
    system("cp $dir/$last_dir/toppar*.str $dir/$new_dir/");
    system("cp $dir/$last_dir/*.psf $dir/$new_dir/");
    system("cp $dir/$last_dir/*.ref $dir/$new_dir/");
    system("cp $dir/$last_dir/*.pdb $dir/$new_dir/");


}


