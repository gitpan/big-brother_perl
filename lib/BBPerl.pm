package BBPerl;
use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter);
$VERSION = sprintf "%d.%03d", q$Revision: 1.3 $ =~ /: (\d+)\.(\d+)/;


sub new {
	my $class = shift;
	my $tname = shift;
	my $HOSTNAME=`hostname`;
	chomp $HOSTNAME;
	my $self =
	{
		_debug => 0,
		_testName => "My_Test",
		_status => "green",
		_bbmsgs => "",
		_bbhome => $ENV{BBHOME},
		_bbtmp => $ENV{BBTMP},
		_bbcmd => $ENV{BB},
		_bbdisp => $ENV{BBDISP},
		_localhost =>$HOSTNAME,
	};

	if ($tname) {
		$tname =~ s/ /_/g;
		$self->{_testName} = $tname;
	}
	die "BBHOME is not set.... Exiting\n" if ! $ENV{BBHOME};
	die "BBTMP is not set... Make sure to run \". \$BBHOME/etc/bbdef.sh\"\n" if ! $ENV{BBTMP};
	bless $self,$class;
	return $self;
}

sub debugLevel {
	my $self=shift;
	if (@_)
	{
		$self->{_debug} = shift;
	}
	return $self->{_debug};
}

sub testName {
	my ($self,$tname) = @_;
	if ($tname)
	{
		$tname =~ s/ /_/g;
		$self->{_testName} = $tname;
	}
	return $self->{_testName};
}

sub status {
	my $self = shift;
	if (@_)
	{
		my $stat=shift;
		$stat =~ tr/A-Z/a-z/;
		$self->{_status} = $stat if $stat =~ /red|yellow|green|purple|blue/;
	}
	return $self->{_status};
}

sub addMsg {
	my ($self,$msg) = @_;
#	$self->{_bbmsgs} .= "<br />".$msg if defined($msg);
	$self->{_bbmsgs} .= "\n".$msg if defined($msg);
	return $self->{_bbmsgs};
}

sub bbdisp {
	my $self = shift;
	if (@_) {
		$self->{_bbdisp} = shift;
	}
	return $self->{_bbdisp};
}

sub localhost {
	my $self = shift;
	if (@_) {
		$self->{_localhost} = shift;
	}
	return $self->{_localhost};
}

sub bbhome {
	my $self = shift;
	if (@_) {
		$self->{_bbhome} = shift;
	}
	return $self->{_bbhome};
}

sub bbcmd {
	my $self = shift;
	if (@_) {
		$self->{_bbcmd} = shift;
	}
	return $self->{_bbcmd};
}

sub bbtmp {
	my $self = shift;
	if (@_) {
		$self->{_bbtmp} = shift;
	}
	return $self->{_bbtmp};
}


sub send {
	my $self = shift;
	my $debug = $self->{_debug};
	my $cmdline = $self->{_bbcmd}." ".$self->{_bbdisp};
	my $statusline = "status ".$self->{_localhost}.".".$self->{_testName}." ".$self->{_status}." ".`date`;
	chomp ($statusline);
	if ($debug > 0) {
		print "The following will be sent using command:\n";
		print $cmdline;
		print "\n---------------------------------------------------------\n";
		print $statusline;
		print $self->{_bbmsgs};
		print "---------------------------------------------------------\n";
	}
	if ($debug < 2) {
		my $bbmsgs=$self->{_bbmsgs};
# Like this would ever work.
#		open (BBPIPE,"| ${cmdline} -") or die "Cannot open STDOUT to report\n";
#		print BBPIPE "$statusline $bbmsgs";
#		print BBPIPE $self->{_bbmsgs};
#		close (BBPIPE);
#		system("$self->{_bbhome}/bin/bb-combo.sh","add","\"$statusline\n$bbmsgs\n\"");
		my $bsvar=`${cmdline} "${statusline}
${bbmsgs}
"`;
	} else {
		print "Debug level $debug prevents me from sending to the Big Brother Server.\n";
	}
}

1;

__END__

=pod

=head1 NAME

BBPerl - Perl module for the ease of writing Perl based big brother monitors.

=head1 SYNOPSIS

use BBPerl;

$bbmonitor = new BBPerl ('My_Monitor');
$bbmonitor->debugLevel(1);
$bbmonitor->testName('My_Monitor');
$bbmonitor->status('red');

$bbmonitor->addMsg('Something is very wrong');
$bbmonitor->send;

=head1 DESCRIPTION

This module is designed to ease the ability to send Big Brother style
monitor messages.

It will check to make sure it is running with a proper environment by 
making sure the environment variables BBHOME and BBTMP are set. If they
are not, it will cause the program to abort with a message explaining
the reason for the failure.

=head2 Methods

=over 4

=item * $bbmonitor->debugLevel()

When called with a parameter, this sets the debug level. When no argument
is used, returns the debug level.

=item * $bbmonitor->testName("My_Test")

When called with a parameter, this sets the name of the test, or otherwise known
as the column name under which to report the results of the monitor test. When no
arguement is used, it returns the name of the test.

=item * $bbmonitor->status("red")

While anything can be set here, the only valid stati for Big Brother are 
(green, yellow, red, purple). When called with a parameter, this sets the 
status of the report. When no arguement is used, it returns the current status.

=item * $bbmonitor->addMsg("I have something else to report")

Adds more information to the report sent back to the Big Brother server. Each
time this is called, the message is appended with an automatic line feed.

=item * $bbmonitor->bbdisp

This method will tell you what the BB Display server is set to, or if you 
call it with a parameter, it will override what the current BB environment
has set for the Big Brother Pager.

=item * $bbmonitor->localhost

This method will tell you what will be reported to the Big Brother server as 
the originating host name. If you set this, it will report to big brother as
if it were coming from a different host.

=item * $bbmonitor->bbhome

This method will tell you what the BBHOME environment variable is set to. 
You can change this by passing a parameter with a new path, but this is
HIGHLY not recommended.

=item * $bbmonitor->bbcmd

This method will tell you the full path to the big brother client executable.
You can change this by passing a parameter with a new path. I saw no need for 
this, however in the spirit of flexibility, I put this in here.

=item * $bbmonitor->bbtmp

This method will tell you the full path to Big Brother temp directory. You can
change the temp directory by setting this parameter, however it is highly
discouraged.

=item * $bbmonitor->send

This method should be called last to send the message to the Big Brother server. 

=back

=head1 AUTHOR

Eirik Toft (grep_boy@yahoo.com)

=cut
