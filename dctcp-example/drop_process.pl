#!/usr/bin/perl
# process ns-2 trace file and list dropped packets from given sender to receiver
# perl drop_process.pl tracefilename.tr fromport toport 
# e.g. perl drop_process.pl smptcp/out.tr.gz 1.1 4.1 
use :strict;
if($#ARGV<0){
printf("Usage: <trace-file>\n");
exit 1;
}


# to open the given trace file
# open my $DATA, '-|', 'gzip', '-dc', $infile;
# $destnode=$ARGV[1];
$fromport=$ARGV[1];
$toport=$ARGV[2];
open(Trace, '-|', 'gzip', '-dc', $ARGV[0]) or die "Cannot open the trace file";
# open(Trace, $ARGV[0]) or die "Cannot open the trace file";
# my $sc = 0; # sending counter
# my $rc = 0; # receiving counter
# my $rp = 0;
# my $mc =0;
# my $d_udp = 0;
my $d_tcp = 0;
# my %pkt_fc = (); #packet forwarding counter
while(<Trace>){ # read one line in from the file
my @line = split; #split the line with delimin as space

# if($line[0] eq "d" && $line[4] eq "cbr"){
#  $d_udp++;
# }
 
if($line[0] eq "d" && $line[4] eq "tcp" &&  $line[8] eq $fromport && $line[9] eq $toport){
 $d_tcp++;

 print STDOUT "$line[1] $d_tcp\n";
}
# else {
# 	print STDOUT "$line[1] $d_tcp\n";
# }

# if($line[0] eq "d" && $line[4] eq "tcp"){
#  $d_tcp++;
#  print STDOUT "$line[1] $d_tcp\n"
# }

}
# printf("Dropped tcp length %f\n",$d_tcp);
# printf("Dropped udp length %f\n",$d_udp);