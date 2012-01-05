package RT::Action::AddServiceData;

use strict;
use warnings;
use RT::Action;

use base qw(RT::Action);

use Data::Dumper;

sub prepareConfig {
	my $self = shift;
	my $ref = shift;
	my $ticket = $self->TicketObj;
	
	return unless ref $ref eq 'HASH';
	
	my $out = {};
	
	while (my ($k,$v) = each(%{ $ref })) {
		
		
		while ($v =~ m/__(\w+)(\(([^\)]+)\))?__/) {
			my $r = $&;
			my $kw = $1;
			my $arg = $3 || undef;
			my $val = '';
			
			if ($kw eq 'CustomField' && defined $arg) {
				$val = $ticket->CustomFieldValuesAsString($arg, Separator => ', ');
				# $RT::Logger->error("---> $val\n");
			}
			elsif ($kw eq 'QueueName') {
				$val = $self->TicketObj->QueueObj->Name;
			}
			else {
				$val = $ticket->$kw;
			}
			
			$v =~ s/\Q$r\E/$val/ge;
			
			# $RT::Logger->error(" --->> $v");
		}
		
		$out->{$k} = $v;
	}
	
	# $RT::Logger->error(Dumper $out);
	
	return $out;
	
}

sub Prepare {
    my $self = shift;
    my $c = $self->TemplateConfig();
    
    $RT::Logger->debug('AddServiceData: Starting up ...');
    
    my $rmodule = $c->{'RequestModule'};
    my $pmodule = $c->{'ParserModule'};
    
    $RT::Logger->debug('AddServiceData: Request: '. $rmodule);
    $RT::Logger->debug('AddServiceData: Parser: '. $pmodule);
    
    eval("use $rmodule;");
    die $@ if ($@);
    
    eval("use $pmodule;");
    die $@ if ($@);
    
    my $requestConfig = $self->prepareConfig($c->{'RequestConfig'});
    
    $c->{'RequestConfig'} = $requestConfig;
    
    if (exists($c->{'RequestConfig'}->{'uri'})) {
    	$RT::Logger->info('AddServiceData: URI: '. $c->{'RequestConfig'}->{'uri'});
    }
    else {
    	$RT::Logger->error('AddServiceData: No service URI given');
    	return;
    }
    
    my $r = $rmodule->new(%{ $requestConfig });
    
    my $data = $r->getRequestData();
    
    unless ($data) {
    	$RT::Logger->error('AddServiceData: No request data returned!');
    	return;
    }
    
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
    		
    		if ($type =~ m/AddRequestors/) {
    			$self->TicketObj->AddWatcher(
    				Email => $hash->{$field},
    				Type => 'Requestor'
    			);
    		}
    		
    		if ($type =~ m/AddAdminCc/) {
    			$self->TicketObj->AddWatcher(
    				Email => $hash->{$field},
    				Type => 'AdminCc'
    			);
    		}
    		
    		if ($type =~ m/AddCustomFieldValue/) {
    			
    			unless (exists($self->{'config'}->{'CustomField'})) {
    				$RT::Logger->error('AddCustomFieldValue needs CustomField configuration');
    				last;
    			}
    			
    			my $cf_name = $self->{'config'}->{'CustomField'};
    			
    			my $CF = RT::CustomField->new($RT::SystemUser);
    			$CF->Load($cf_name);
    			
    			if ($CF->Id) {
    				$RT::Logger->debug('AddServiceData: Got CF: '. $cf_name);
    				
    				my $value = $hash->{$field};
    				if ($value) {
    					$self->TicketObj->AddCustomFieldValue(
    						Field => $CF,
    						Value => $value
    					);
    					last;
    				}
    			}
    			else {
    				$RT::Logger->error('AddServiceData: Error loading CustomField: '. $cf_name);
    			}
    			
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

    my $content = $self->TemplateContent;
    
	my $data = eval($content);
	
	if ($@) {
		$RT::Logger->error('Template error: '. $@);
		die($@);
	}
	
	if (ref $data eq 'HASH') {
		return $data;
	}
	
	return undef;
}


1;
