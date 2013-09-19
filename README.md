# lilurl

## About

This is a simple URL shortener written in ruby on Sinatra
and using SQLite as the backend database.

Working example at http://krinkle.nom.co/lilurl

## Dependencies:

**Gems:** sqlite3, sinatra, bundler

## Usage

### Development

To **start** the web server, run:

    ruby lilurl.rb

To **view** the site, navigate to:

    http://localhost:4567

or:

    http://your.domain:4567

### Production 

Install apache and the passenger gem, install the passenger module in apache,
and follow passenger's instructions to modify your apache configuration
and create a virtual host.

### API

lilurl can accept a POST request with parameter 'oldurl' and optional
parameter 'postfix' and returns a JSON result.
