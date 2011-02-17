package RTx::AddServiceData::HTTPRequest;

use strict;

use Data::Dumper;

use LWP::UserAgent;

use HTTP::Request;

our $VERSION = '0.9.0';

require RTx::AddServiceData::GenericRequest;


use base qw (RTx::AddServiceData::GenericRequest);

sub new {
	
	my $type = shift;
	
	my $class = (ref $type || $type);
	
	my $config = {
		'agent' => __PACKAGE__. '/'. $VERSION,
		@_
	};
	
	my $self = $class->SUPER::new(%{ $config });
	
	$self->{'request_done'} = 0;
	
	$self->{'ua'} = LWP::UserAgent->new(
		agent => $self->getItem('agent')
	);
	
	return bless $self, $class;
}

sub getRequest {
	my $self = shift;
	my $req = HTTP::Request->new(GET => $self->getItem('uri'));
	
	if ($self->getItem('user') && $self->getItem('pass')) {
		$req->authorization_basic($self->getItem('user'), $self->getItem('pass'));
	}
	
	return $req;
}

sub doRequest {
	
	my $self = shift;
	
	use Data::Dumper;
	
	my $req = $self->getRequest();
	
	$self->{'response'} = $self->{'ua'}->request($req);
	
	if ($self->{'response'}->is_success) {
		$self->{'content'} = $self->{'response'}->content;	
	}
	else {
		push @{ $self->{'errors'} }, $self->{'response'}->status_line;
	}
	
	$self->{'request_done'} = 1;
	
}

sub getRequestData {
	
	my $self = shift;
	
	unless ($self->{'request_done'}) {
		$self->doRequest();
	}

	if (scalar @{ $self->{'errors'} }) {
		return undef;
	}
	
	return $self->{'content'};

}

1;
