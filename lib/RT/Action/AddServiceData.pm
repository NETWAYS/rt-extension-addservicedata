package RT::Action::AddServiceData;

use strict;
use warnings;

use parent qw(RT::Action);

use Data::Dumper;

sub prepareConfig {
	my $self = shift;
	my $ref = shift;
	my $ticket = $self->TicketObj;
	
	return unless ref $ref eq 'HASH';
	
	my $out = {};
	
	while (my ($k,$v) = each(%{ $ref })) {
		
		if ($v =~ m/__(\w+)(\(([^\)]+)\))?__/) {
			my $r = $&;
			my $kw = $1;
			my $arg = $3 || undef;
			my $val = undef;
			
			if ($kw eq 'CustomField' && defined $arg) {
				$val = $ticket->CustomFieldValuesAsString($arg, Separator => ', ');
				# $RT::Logger->error("---> $val\n");
			}
			else {
				$val = $ticket->$kw;
			}
			
			if (defined $val) {				
				$v =~ s/\Q$r\E/$val/ge;
				# $RT::Logger->error(" --->> $v");
			}
			
		}
		
		$out->{$k} = $v;
	}
	
	# $RT::Logger->error(Dumper $out);
	
	return $out;
	
}

sub Prepare {
    my $self = shift;
    my $c = $self->TemplateConfig();
    
    my $rmodule = $c->{'RequestModule'};
    my $pmodule = $c->{'ParserModule'};
    
    eval("use $rmodule;");
    die $@ if ($@);
    
    eval("use $pmodule;");
    die $@ if ($@);
    
    my $requestConfig = $self->prepareConfig($c->{'RequestConfig'});
    
    $c->{'RequestConfig'} = $requestConfig;
    
    my $r = $rmodule->new(%{ $requestConfig });
    
    my $data = $r->getRequestData();
    
    return undef unless $data;
    
    my $p = $pmodule->new(content => $data);
    
    $p->parseData();
    
    $self->{'data'} = $p->getData();
    $self->{'config'} = $c;
    
    # RT::Logger->error(Dumper $self->{'data'});
    
    return 1;
}

sub Commit {
    my $self = shift;
    
    # $RT::Logger->error(Dumper $self->{'config'});
    # $RT::Logger->error(Dumper $self->{'data'});
    
    return unless ($self->{'data'});
    return unless (ref $self->{'data'} eq 'ARRAY');
    
    my $type = $self->{'config'}->{'Type'};
    my $field = $self->{'config'}->{'Field'};
    
    return unless ($field);
    
    foreach my $hash(@{ $self->{'data'} }) {
    	if (exists $hash->{$field}) {
    		
    		if ($type eq 'AddRequestors') {
    			$self->TicketObj->AddWatcher(
    				Email => $hash->{$field},
    				Type => 'Requestor'
    			);
    		}
    		
    	}
    }
    
    return 1;
}

sub TemplateContent {
    my $self = shift;
    return $self->TemplateObj->Content;
}

sub TemplateConfig {
    my $self = shift;

    my ($content, $error) = $self->TemplateContent;
    if (!defined($content)) {
        return (undef, $error);
    }

	my $data = eval($content);
	
	if (ref $data eq 'HASH') {
		return $data;
	}
	
	return undef;
	

}


1;