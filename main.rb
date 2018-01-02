Agentname = "tky"
start_level = 1
max_level   = 5

log = Log.new
log.open

http = Http.new(Agentname)

fconv = FileConvert.new

parser = Parser.new(log)

db = WebDB.new
db.open(host, userid, password, database)

(start_level..max_level).each do |n|
  res = db.select_url(n)
  res.each do |url_id, url|
    begin
      http.set_url(url)
      http.get

      if http.code != '200'
        raise "rc:#{http.code}"
      end

      f1 = http.local_file
      f2 = http.local_file + ".utf8"

      fconv.to_utf-8(f1, f2)

      parser.setup(db, fn, url_id, url)

      eofsw = parser.token()
      while eofsw do
        eofsw = parser.parse()
      end
      fh.close

      parser.finish
      log.n_msg("#{url} [#{url_id}] parsed.")

      log.flush

    rescue
      if http.local_file && File.exsit?(http.local_file)
        File.unlink(http.local_file)
      end
    end
    log.flush

    db.close

    log.n_msg("main end.")

    log.close
    
    exsit

  end
end

