#!/usr/bin/perl -w
#
#$Id: watch_dhcp.pl,v 1.4 2001/04/20 09:48:10 edelrio Exp $
#
use strict;
use diagnostics;

use Net::DHCP::Watch;
use Getopt::Long;

# Parameters
my ($Server, $Ether, $Timeout, $Sleep, $Wait, $Start, $Stop, $help);

GetOptions(
	   'server:s'  => \$Server,
	   'ether:s'   => \$Ether,
	   'timeout:s' => \$Timeout,
	   'sleep:s'   => \$Sleep,
	   'try:s'     => \$Wait, 
	   'start:s'   => \$Start, 
	   'stop:s'    => \$Stop,
	   'help!'     => \$help
);

&usage if ($help);

$Server ||= '127.0.0.1'; # server name
# if you are NOT on a UNIX machine
$Ether  ||= qx[ /sbin/ifconfig eth0 | tail +1 |
		 head -1 | awk '{print \$5}']; # ethernet address here
chomp($Ether);
$Timeout ||= 10;                             # network timeout
$Sleep   ||= 300;                            # sleep between checks
$Wait    ||= 4;                              # tries before action
$Start   ||= '/etc/rc.d/init.d/dhcpd start'; # start dhcp server
$Stop    ||= '/etc/rc.d/init.d/dhcpd stop';  # stop  dhcp server
#
# Init Monitor
#
my $dhcpw = new Net::DHCP::Watch({
		server  => $Server,
		ether   => $Ether,
		tiemout => $Timeout
	});

# start
$dhcpw->watch();
# make an infinite loop watching for availability of server,
# with the following rules:
my $stat = $dhcpw->status;
my $local_dhcp = 0;
while (1) {
       #  if server is on-line: just sleep.
	if ( $stat->{Bad} ) { 
	    print 
		$stat->{Time},
		": Remote DHCP on $Server unavailable (",
		$stat->{Bad},
		").\n";
	}

	if ( $stat->{Ok}  ) {
	    print $stat->{Time},
	    ": Remote DHCP on $Server online (".$stat->{Ok}.").\n";
	}
        #  if server is off-line more than $Wait times: starts local server.
	if ( $stat->{Bad} > $Wait && !$local_dhcp ) {
		my $start_dhcp = qx[ $Start ];
		$local_dhcp = 1;
		print $stat->{Time},": Starting local DHCP daemon\n";
	}

        #  if server is back on-line more than $Wait times: stops local server.
	if ( $stat->{Ok}  > $Wait && $local_dhcp ) {
		my $stop_dhcp  = qx[ $Stop ];
		print $stat->{Time},": Stoping local DHCP daemon\n";
		$local_dhcp = 0;
	}
        # sleep time should be ~ MAX_LEASE_TIME/(number_of_times_to_wait+1)
	sleep($Sleep);
}
continue {
    # get status   
    $stat = $dhcpw->status;
}

sub usage {
    print 
	"\n$0:\tmonitor a remote DHCP server and launch",
	" a local server when needed.\n\n";
    print
	"Usage: $0 [--server=server] [--ether=ether]\n",
	"\t[--timeout=timeout] [--sleep=sleep] [--wait=wait]\n",
	"\t[--start=start] [--stop=stop]\n";

    print
	"\n",
	" server:  DHCP server name or IP.\n",
	" ether:   Local ethernet address.\n",
	" timeout: Timeout for network operations.\n",
	" sleep:   Interval between monitoring.\n",
	" try:     Number of successive (bad/ok) tries before taking action (start/stop).\n",
	" start:   Command to start the local DHCP daemon.\n",
	" stop:    Command to stop  the local DHCP daemon.\n";
    print "\nAll options have reasonable values on a UNIX machine.\n";
    exit(0);
}
