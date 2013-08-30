# lilurl

## About

This is a simple URL shortener written in ruby on Sinatra
and using SQLite as the backend database.

## Dependencies:

**Gems:** sqlite3, sinatra

## Usage

### Development

To **start** the web server, run:

    ruby lilurl.rb

To **view** the site, navigate to:

    http://localhost:4567

or:

    http://your.domain:4567

### Production (deploying with Rack on Apache)

Install apache and the passenger gem. Then install the passenger module in apache.

Add the following to your apache configuration file:

    LoadModule passenger_module /Library/Ruby/Gems/1.8/gems/passenger-3.0.19/ext/apache2/mod_passenger.so
    PassengerRoot /Library/Ruby/Gems/1.8/gems/passenger-3.0.19
    PassengerRuby /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby

    <VirtualHost *:80>
       ServerName example.com
       DocumentRoot /somewhere/public
       <Directory /somewhere/public>
          order allow,deny
          Allow from all
          AllowOverride all
          Options -MultiViews
       </Directory>
    </VirtualHost>
