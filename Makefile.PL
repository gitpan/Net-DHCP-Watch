#
#$Id: Makefile.PL,v 1.4 2001/04/20 09:47:58 edelrio Exp $
#
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Net::DHCP::Watch',
#      'PREREQ_PM' => {
#  		'POSIX' => 1.00
#  	},
    'VERSION_FROM' => 'Watch.pm', # finds $VERSION
);
