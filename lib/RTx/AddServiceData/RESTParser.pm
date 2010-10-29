package RTx::AddServiceData::RESTParser;

use strict;

require RTx::AddServiceData::GenericParser;

use base qw(RTx::AddServiceData::GenericParser);

sub parseData {
	my $self = shift;
	my @content = split(chr(10), $_[0] || $self->{'content'});
	
	$self->{'data'} = ();
	my $tmp = {};
	
	while (defined(my $line = shift @content)) {
		if ($line =~ /^([^:]+):\s+([^\$]+)$/) {
			my $key = $1;
			my $val = $2;
			chomp($key);
			chomp($val);
			$tmp->{$key} = $val
		}
		
		if ($line =~ /--/ || scalar @content <= 0) {
			push @{ $self->{'data'} }, $tmp;
			$tmp = {};
		}
	}
	
	return 1;
	
}

1;
