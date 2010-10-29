use Test::More tests => 6;

use_ok('RTx::AddServiceData::HTTPRequest');
use_ok('RTx::AddServiceData::RESTParser');

my $h = RTx::AddServiceData::HTTPRequest->new(
	'uri'	=> 'http://localhost:10088/iddp/data/db/idoit.owner/rest'
);

my $data = $h->getRequestData();

ok(defined $data && length $data > 0, 'Got response data');

my $parser = RTx::AddServiceData::RESTParser->new(
	content => $data
);

$parser->parseData();

my @data = $parser->getData();

ok(scalar @data >0, 'Got array data');

my $hashref = shift @data;

ok (ref $hashref eq 'HASH', 'Item is HASH');

ok (scalar keys(%{ $hashref }) > 0, 'Hash has values');

RT::Init;