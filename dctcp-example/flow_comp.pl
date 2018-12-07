# Usage: 
#
#   perl throughput <trfile> <destNode> <srcNode.port#> <destNode.port#> 
#                   <granularity> 
#
# Example: plot the throughput of connection 2.0 - 1.0 every 0.5 sec
#
#	perl throughput  out.tr  1 2.0 1.0  0.5
# for SP-TCP
# perl throughput.pl smptcp/out.tr.gz  7 6.0  7.0  1 > smptcp/thput.tr
# perl throughput.pl smptcp/out.tr.gz  4 1.1  4.1  0.1 > smptcp/flow1.tr
# perl throughput.pl smptcp/out.tr.gz  5 2.1  5.1  0.1 > smptcp/flow2.tr
# perl throughput.pl smptcp/out.tr.gz  8 6.0  8.0  0.1 > smptcp/tcp1.tr
# perl throughput.pl smptcp/out.tr.gz  9 7.0  9.0  0.1 > smptcp/tcp2.tr

# perl throughput.pl smptcp/out.tr.gz  10 1.1  10.1  0.1 > smptcp/flow1.tr;perl throughput.pl smptcp/out.tr.gz  11 2.1  11.1  0.1 > smptcp/flow2.tr;perl throughput.pl smptcp/out.tr.gz  13 4.1  13.1  0.1 > smptcp/flow3.tr; perl throughput.pl smptcp/out.tr.gz  14 5.1  14.1  0.1 > smptcp/flow4.tr;perl throughput.pl smptcp/out.tr.gz  16 7.1  16.1  0.1 > smptcp/flow5.tr;perl throughput.pl smptcp/out.tr.gz  17 8.1  17.1  0.1 > smptcp/flow6.tr
# perl throughput.pl smptcp/out.tr.gz  11 2.1  11.1  0.1 > smptcp/flow2.tr
# perl throughput.pl smptcp/out.tr.gz  13 4.1  13.1  0.1 > smptcp/flow3.tr
# perl throughput.pl smptcp/out.tr.gz  14 5.1  14.1  0.1 > smptcp/flow4.tr
# perl throughput.pl smptcp/out.tr.gz  16 7.1  16.1  0.1 > smptcp/flow5.tr
# perl throughput.pl smptcp/out.tr.gz  17 8.1  17.1  0.1 > smptcp/flow6.tr
# #############################################################

# r 0.636963 10 2 ack 50 ------- 0 5.1 2.1 1 27 5621 0x18 50 0 A 10001

# + 1.5 1 10 tcp 1516 ---A--N 0 1.1 4.1 10001 42 1 0x98 56 0 D 20001 10001 1460

# Get input file (first arg)
 $infile=$ARGV[0];

# Get sender nodes 
  $srcnode1=$ARGV[1];
  $srcnode2=$ARGV[2];
  # flow size
  $fsize=$ARGV[3];


# #########################################################################
# We compute how many bytes were transmitted during time interval specified
# by granularity parameter in seconds

   # $clock=0;
   $fstart_t=0;
 
   $seqno=1;
   $ackno=$fsize+1;


# #########################################################################
# Open input file
   # If it is not zip file 
   # open (DATA,"<$infile") || die "Can't open $infile $!";

   # open(DATA $fh1, '-|', '/usr/bin/gzip -dc $infile') or die $!;

   open my $DATA, '-|', 'gzip', '-dc', $infile;
  
   while (<$DATA>) 
   {

     # Tokenize line using space as separator
      @x = split(' ');

      if ($x[0] eq '+' && ($x[2] eq $srcnode1 || $x[2] eq $srcnode2)) {



         if ($x[4] eq 'tcp' && $x[17] eq $seqno ) {

            $fstart_t=$x[1];
            $seqno=$seqno+$fsize;


         }
         

      } elsif ($x[0] eq 'r' && ($x[3] eq $srcnode1 || $x[3] eq $srcnode2)) {

         # print STDERR "$x[17],$ackno, $x[4]\n";

      if ($x[4] eq 'ack' && $x[17] eq $ackno) {
            $fc_time=$x[1]-$fstart_t;

            print STDOUT "$x[1] $fc_time \n";

            $ackno=$ackno+$fsize;

            

         }

   }

}

   close DATA;

   exit(0);
 