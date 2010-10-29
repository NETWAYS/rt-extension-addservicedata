package RTx::AddServiceData::GenericRequest;

use strict;

our $VERSION = '0.9.0';

use Data::Dumper;

sub new {
	my $type = shift;
	
	my $config = { @_ };
	
	return bless {
		'config' => $config,
		'errors' => []
	} => (ref $type || $type);
}

sub setConfig {
	my $self = shift;
	my $d = {@_};
	while (my($k,$v) = each(%{$d})) {
		$self->{'config'}->{$k} = $v;
	}
	return 1;
}

sub getItem {
	my $self = shift;
	my $arg = shift;
	my $return = shift || undef;
	if (exists $self->{'config'}->{$arg}) {
		return $self->{'config'}->{$arg};
	}
	
	return $return;
}

sub setItem {
	my $self = shift;
	my ($k,$v) = @_;
	$self->{'config'}->{$k} = $v;
}

sub getRequestData {
	die("STUB TO IMPLEMENT");
}

sub getRequestErrors {
	my $self = shift;
	return @{ $self->{'errors'} };
}

1;