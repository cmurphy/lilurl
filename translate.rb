require 'rubygems'
require 'sqlite3'
require 'digest/sha1'

$dbfile = 'lilurl.db'

def geturl(hash)
  urldb = SQLite3::Database.open $dbfile
  statement = urldb.prepare "SELECT url FROM urls WHERE hash = ?"
  #hash = '000001'
  statement.bind_param 1, hash
  response = statement.execute
  row = response.next # since hash is a primary key this query should only return one result
  return row.join "\s"
rescue SQLite3::Exception => e
  puts "An error occured: " + e
ensure
  statement.close if statement
  urldb.close if urldb
end

def makeurl(oldurl)
#  oldurl + "hi"
  hash = Digest::SHA1.hexdigest oldurl
  hash = hash[0..5]
  urldb = SQLite3::Database.open $dbfile
  urldb.execute "CREATE TABLE IF NOT EXISTS urls(hash varchar(6) primary key, url varchar(100))"
  statement = urldb.prepare "INSERT INTO urls VALUES (?, ?)"
  statement.bind_param 1, hash
  statement.bind_param 2, oldurl
  response = statement.execute
  return hash
rescue SQLite3::Exception => e
  puts "An error occured: " + e
ensure
  statement.close if statement
  urldb.close if urldb
end
