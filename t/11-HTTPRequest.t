use Test::More tests => 6;

BEGIN {
	use_ok('RT::Extension::AddServiceData::HTTPRequest');
}

my $h = RT::Extension::AddServiceData::HTTPRequest->new(
	'uri'	=> 'http://localhost:10088/iddp',
	'user'	=> 'testuser',
	'pass'	=> 'testuser'
);

ok(defined $h, 'Object created');

isa_ok($h, 'RT::Extension::AddServiceData::GenericRequest');

ok($h->getItem('uri') eq 'http://localhost:10088/iddp', 'Right URI');

$data = $h->getRequestData();

ok (scalar $h->getRequestErrors() eq 0, 'No http errors');

ok (defined $data && length $data > 0, 'HTTP response ok');
