#
#$id$
#

######################### We start with some black magic to print on failure.
BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use Net::DHCP::Watch;
$loaded = 1;
print "ok 1\n";
######################### End of black magic.

# 2: create object
my $dhcpw = new Net::DHCP::Watch({
		client => '127.0.0.1',
		server => '127.0.0.1',
		ether  => '00:00:00:00:00:00'
	});

print "ok 2\n" if $dhcpw;

# 3: open connection
$dhcpw->watch();

print "ok 3\n";

# 4: get status
my $s = $dhcpw->status();

print "Status: ",$s->{Time}," ";
print "ok" if $s->{Ok};
print $s->{Bad}," bad attempts." if $s->{Bad};
print "\n";

print "ok 4\n";




