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
# Get input file (first arg)
   $infile=$ARGV[0];

# #############################################################
# Get node that receives packets (second arg)
   $destnode=$ARGV[1];
   $fromport=$ARGV[2];
   $toport=$ARGV[3];
# Mib 
   $mib=1.0/(1000*1000);

# #############################################################
# Get time granularity (time interval width
   $granularity=$ARGV[4];

# #########################################################################
# We compute how many bytes were transmitted during time interval specified
# by granularity parameter in seconds

   $sum=0;
   $grantsum=0;
   $clock=0;

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

# column 1 is time 
      if ($x[1]-$clock <= $granularity)
      {

# checking if the event (column 0) corresponds to a reception 
         if ($x[0] eq 'r') 
         { 

# checking if the destination (column 3) corresponds to node in arg 1
            if ($x[3] eq $destnode && $x[8] eq $fromport && $x[9] eq $toport) 
            { 
#checking if the packet type is TCP
               if ($x[4] eq 'tcp') 
               {
                  $sum=$sum+$x[5];
		  $grantsum=$grantsum+$x[5];
               }
            }
         }
      }
      else
# One interval has passed, compute throughput
      {   
         $throughput=8*$sum*$mib/$granularity;
         print STDOUT "$clock $throughput\n";

         $clock=$clock+$granularity;

	 if ($x[0] eq 'r' && $x[3] eq $destnode && $x[8] eq $fromport 
	     && $x[9] eq $toport && $x[4] eq 'tcp')
         {
	    $sum=$x[5];
	    $grantsum=$grantsum+$x[5];
	 }
	 else
         {
	    $sum=0;
	 }

         while ($x[1]-$clock > $granularity)
         {
            print STDOUT "$clock 0.0\n";
            $clock=$clock+$granularity;
         }
      }   
   }

   $throughput=8*$mib*$sum/$granularity;
   print STDOUT "$clock $throughput\n";
   $clock=$clock+$granularity;

   # print STDERR "Avg throughput $fromport - $toport = ",
	  #        8*$mib*$grantsum/$clock,"MBytes/sec \n";

   close DATA;

   exit(0);
 