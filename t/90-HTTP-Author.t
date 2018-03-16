use Test::More tests => 6;

use_ok('RT::Extension::AddServiceData::HTTPRequest');
use_ok('RT::Extension::AddServiceData::RESTParser');

my $h = RT::Extension::AddServiceData::HTTPRequest->new(
	'uri'	=> 'http://localhost:10088/iddp/data/db/sugarcrm.contacts/rest',
	'user'	=> 'testuser',
	'pass'	=> 'testuser'
);

my $data = $h->getRequestData();

ok(defined $data && length $data > 0, 'Got response data');

my $parser = RT::Extension::AddServiceData::RESTParser->new(
	content => $data
);

$parser->parseData();

my $arr_ref = $parser->getData();

ok(scalar @{$arr_ref}>0, 'Got array data');

my $hashref = shift @{$arr_ref};

ok (ref $hashref eq 'HASH', 'Item is HASH');

ok (scalar keys(%{ $hashref }) > 0, 'Hash has values');
