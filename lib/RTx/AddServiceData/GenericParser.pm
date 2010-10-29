package RTx::AddServiceData::GenericParser;

use strict;

sub new {
	my $type = shift;
	my $class = (ref $type || $type);
	return bless {
		'content'	=> '',
		'data'		=> [],
		'parse_ok'	=> 0,
		@_
	} => $type;
}

sub setContent {
	my $self = shift;
	$self->{'content'} = $_[0];
}

sub parseData {
	die('STUB TO IMPLEMENT');
}

sub getData {
	my $self = shift;
	
	unless ($self->{'parse_ok'}) {
		$self->parseData();
	}
	
	return $self->{'data'};
}

1;