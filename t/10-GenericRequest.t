use Test::Simple tests => 5;

use RT::Extension::AddServiceData::GenericRequest;

$r = RT::Extension::AddServiceData::GenericRequest->new(
	test_a => '123'
);

$r->setConfig(
	test_b => '456'
);

$r->setItem('test_c', '789');

ok (defined $r);
ok (ref $r eq 'RT::Extension::AddServiceData::GenericRequest');
ok ($r->getItem('test_a') eq '123', 'new() equal');
ok ($r->getItem('test_b') eq '456', 'setConfig() equal');
ok ($r->getItem('test_c') eq '789', 'set() equal');
