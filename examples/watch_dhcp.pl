#!/usr/bin/perl -w
#
#$Id: watch_dhcp.pl,v 1.3 2001/04/17 13:32:58 edelrio Exp $
#
use strict;
use diagnostics;

use Net::DHCP::Watch;

# Put server name here
my $Server = shift;
$Server ||= '127.0.0.1';
# Put the ethernet address here
# if you are not on a UNIX machine
my $Ether  = qx[ /sbin/ifconfig eth0 | tail +1 |
		 head -1 | awk '{print \$5}'];
chomp($Ether);
#
my $dhcpw = new Net::DHCP::Watch({
		server => $Server,
		ether  => $Ether
	});

# start
$dhcpw->watch();
# number of times to wait before we start/stop the local server
my $wait = 3;
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
        #  if server is off-line more than $wait times: starts local server.
	if ( $stat->{Bad} > $wait && !$local_dhcp ) {
		my $start_dhcp = qx[echo /etc/rc.d/init.d/dhcpd start];
		$local_dhcp = 1;
		print $stat->{Time},": Starting local DHCP daemon\n";
	}

        #  if server is back on-line more than $wait times: stops local server.
	if ( $stat->{Ok}  > $wait && $local_dhcp ) {
		my $stop_dhcp  = qx[ echo /etc/rc.d/init.d/dhcpd stop];
		print $stat->{Time},": Stoping local DHCP daemon\n";
		$local_dhcp = 0;
	}
        # sleep time should be ~ MAX_LEASE_TIME/(number_of_times_to_wait+1)
	sleep(5);
}
continue {
    # get status   
    $stat = $dhcpw->status;
}
