#
#$Id: Makefile.PL,v 1.3 2001/04/17 13:32:46 edelrio Exp $
#
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Net::DHCP::Watch',
    'VERSION_FROM' => 'Watch.pm', # finds $VERSION
);
