package RT::Extension::AddServiceData;

use strict;

use vars qw(
	$VERSION
);

$VERSION = '0.9.0';

1;

=pod

=head1 NAME

RT-Extension-AddServiceData

=head1 DESCRIPTION

Add ticket meta data from webservices.

=head1 RT VERSION

Works with RT 4.2

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item Edit your F</opt/rt4/etc/RT_SiteConfig.pm>

Add this line:

    Plugin('RT::Extension::AddServiceData');

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 CONFIGURATION

Please combine this Action with a template and the following code:

=head2 Template Example

=over

=item - Queries the URL with the parameter configured

=item - Iterate through the results

=item - Add for each row a new requestor with email in hash

=back

	{
		Type => 'AddRequestors',

		Field => 'email',

		RequestModule => 'RT::Extension::AddServiceData::HTTPRequest',

		RequestConfig => {
			uri => 'http://localhost:10088/iddp/data/db/idoit.owner/rest?q=isys_obj__sysid="__CustomField(SysID)__"&connection=__QueueName__'
		},

		ParserModule => 'RT::Extension::AddServiceData::RESTParser'
	}

Add a CustomFieldValue

	{
		Type => 'AddCustomFieldValue',

		Field => 'accounts_id',
		CustomField => 'client',

		RequestModule => 'RT::Extension::AddServiceData::HTTPRequest',

		RequestConfig => {
			uri => 'http://localhost:10088/iddp/data/db/sugarcrm.contacts/rest?q=email_address="__RequestorAddresses__"',
			user => 'testuser',
			pass => 'testuser'
		},

		ParserModule => 'RT::Extension::AddServiceData::RESTParser'
	}

Allowed replace strings:

	__CustomField(<NAME>)__
	__QueueName__
	__RequestorAddresses__

(All other implementations of RT::Ticket -> __<METHOD>__)

=head1 AUTHOR

NETWAYS GmbH <lt>support@netways.de<gt>

=head1 BUGS

All bugs should be reported on L<GitHub|https://github.com/NETWAYS/rt-extension-addservicedata>.

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2018 by NETWAYS GmbH

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

__END__
