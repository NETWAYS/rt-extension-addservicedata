# RT-Extension-AddServiceData

#### Table of Contents

1. [About](#about)
2. [License](#license)
3. [Support](#support)
4. [Requirements](#requirements)
5. [Installation](#installation)
6. [Configuration](#configuration)

## About

Add ticket meta data from webservices.

## License

This project is licensed under the terms of the GNU General Public License Version 2.

This software is Copyright (c) 2018 by NETWAYS GmbH [support@netways.de](mailto:support@netways.de).

## Support

For bugs and feature requests please head over to our [issue tracker](https://github.com/NETWAYS/rt-extension-addservicedata/issues).
You may also send us an email to [support@netways.de](mailto:support@netways.de) for general questions or to get technical support.

## Requirements

- RT 4.2

## Installation

Extract this extension to a temporary location.

Git clone:

    cd /usr/local/src
    git clone https://github.com/NETWAYS/rt-extension-addservicedata

Tarball download:

    cd /usr/local/src
    wget https://github.com/NETWAYS/rt-extension-addservicedata/archive/master.zip
    unzip master.zip

Navigate into the source directory and install the extension. (May need root permissions.)

    perl Makefile.PL
    make
    make install

Edit your `/opt/rt4/etc/RT_SiteConfig.pm`

Add this line:

    Plugin('RT::Extension::AddServiceData');

Clear your mason cache:

    rm -rf /opt/rt4/var/mason_data/obj

Restart your webserver.

## Configuration

Please combine this Action with a template and the following code:

### Template Example

- Queries the URL with the parameter configured
- Iterate through the results
- Add for each row a new requestor with email in hash

    {
        Type => 'AddRequestors',

        Field => 'email',

        RequestModule => 'RT::Extension::AddServiceData::HTTPRequest',

        RequestConfig => {
            uri => 'http://localhost:10088/iddp/data/db/idoit.owner/rest?q=isys_obj__sysid="\__CustomField(SysID)\__"&connection=\__QueueName\__'
        },

        ParserModule => 'RT::Extension::AddServiceData::RESTParser'
    }

Add a CustomFieldValue:

    {
        Type => 'AddCustomFieldValue',

        Field => 'accounts_id',
        CustomField => 'client',

        RequestModule => 'RT::Extension::AddServiceData::HTTPRequest',

        RequestConfig => {
            uri => 'http://localhost:10088/iddp/data/db/sugarcrm.contacts/rest?q=email_address="\__RequestorAddresses\__"',
            user => 'testuser',
            pass => 'testuser'
        },

        ParserModule => 'RT::Extension::AddServiceData::RESTParser'
    }

Allowed replace strings:

    \__CustomField(<NAME>)\__
    \__QueueName\__
    \__RequestorAddresses\__

(All other implementations of RT::Ticket - \__<METHOD>\__)
