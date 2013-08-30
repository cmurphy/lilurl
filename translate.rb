require 'rubygems'
require 'sqlite3'
require 'digest/sha1'
require 'uri'

$dbfile = 'lilurl.db'

def geturl(hash)
  urldb = open_or_create_db($dbfile)
  statement = urldb.prepare "SELECT url FROM urls WHERE hash = ?"
  statement.bind_param 1, dbstring(hash)
  response = statement.execute
  row = response.next # since hash is a primary key this query should only return one result
  if !row.nil?
    return row.join "\s"
  else
    raise ArgumentError.new('LilUrl didn\'t find that URL. Are you sure you copied it right?')
  end

rescue SQLite3::Exception => e
  statement.close if statement
  urldb.close if urldb
  raise SQLite3::Exception.new(e.to_s)
ensure
  statement.close if statement
  urldb.close if urldb
end


def makeurl(oldurl, postfix = nil)
  validate_url(oldurl)
  if postfix.to_s.empty?
    hash = generate_hash(oldurl)
  else
    validate_postfix(postfix)
    hash = postfix
  end
  urldb = open_or_create_db($dbfile)
  statement = urldb.prepare "INSERT INTO urls VALUES (?, ?)"
  statement.bind_param 1, dbstring(hash)
  statement.bind_param 2, dbstring(oldurl)
  response = statement.execute
  statement.close if statement
  urldb.close if urldb
  return hash

rescue SQLite3::ConstraintException => e
  # column hash is not unique
  # 1) URL already exists in the database and will hash to the same index
  # 2) someone already tried to use that postfix
  # 3) by random chance a new URL hashed to an existing index

  # First, see if the postfix was set and is already in there
  if !postfix.to_s.empty?
    statement = urldb.prepare "SELECT hash FROM urls WHERE hash = ?"
    statement.bind_param 1, dbstring(postfix)
    response = statement.execute
    row = response.next
    statement.close if statement
    unless row.nil? # returned at least one row
      raise ArgumentError.new('That postfix has already been taken. Please use a different one or let me generate one.')
    end
    urldb.close if urldb
  elsif url_exists?(oldurl)
     #URL already exists in the database, don't bother to generate a new one
    return hash
  else # URL doesn't exist in the database but the hash does -> collision resolution needed
    b = 1
    e = 6
    until url_exists?(oldurl)
      hash = sha[b..e]
      statement = urldb.prepare "SELECT hash FROM urls WHERE hash = ?"
      statement.bind_param 1, dbstring(hash)
      response = statement.execute
      row = response.next
      statement.close if statement
      if row.nil? # We resolved the collision, insert it there
        statement = urldb.prepare "INSERT INTO urls VALUES (?, ?)"
        statement.bind_param 1, dbstring(hash)
        statement.bind_param 2, dbstring(oldurl)
        response = statement.execute
        statement.close if statement
      end
      ++b
      ++e
    end
    return hash
  end

rescue SQLite3::Exception => e
  statement.close if statement
  urldb.close if urldb
  raise SQLite3::Exception.new(e.to_s)
end

def dbstring(s)
  if s.respond_to?(:encode)
    return s.encode("UTF-8")
  else
    return s
  end
end

def generate_hash(url)
  sha = Digest::SHA1.hexdigest url
  return sha[0..5]
end

def open_or_create_db(filename)
  db = SQLite3::Database.open filename
  db.execute "CREATE TABLE IF NOT EXISTS urls(hash varchar(20) primary key, url varchar(500))"
  return db
end

def url_exists?(url)
  urldb = SQLite3::Database.open $dbfile
  statement = urldb.prepare "SELECT hash FROM urls WHERE url = ?"
  statement.bind_param 1, dbstring(url)
  response = statement.execute
  row = response.next
  statement.close if statement
  if !row.nil?
    return true
  end
  return false
end

def validate_postfix(postfix)
  if postfix.length > 20
    raise ArgumentError.new('Your postfix must be 20 characters or less.')
  end
end

def validate_url(url)
  uri = URI(url)
  if uri.scheme.nil?
    raise ArgumentError.new('Please submit a valid URL.')
  end
  rescue URI::InvalidURIError => e
    raise ArgumentError.new('Please submit a valid URL.')
end
