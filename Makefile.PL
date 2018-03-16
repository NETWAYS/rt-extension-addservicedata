use inc::Module::Install;

RTx     'RT-Extension-AddServiceData';
license 'gpl_2';
repository 'https://github.com/NETWAYS/rt-extension-addservicedata';
readme_from 'lib/RT/Extension/AddServiceData.pm';

requires_rt '4.2';

sign;
WriteAll;
