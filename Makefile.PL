use strict;

use inc::Module::Install;

RTx('RT-Extension-AddServiceData');

author('Marius Hein <marius.hein@netways.de');
version('0.0');
license('gpl');

perl_version('5.10.0');

no_index directory => 'inc';

all_from('lib/RT/Action/AddServiceData.pm');

&WriteAll;
