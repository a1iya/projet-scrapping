class Scrapper

  def get_townhall_mails
    townhall_mails = []
    i = 0
    page = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/val-d-oise.html"))
    page.xpath('//p/a').each do |url|
      mail = get_townhall_email("http://www.annuaire-des-mairies.com/"+url['href'][1..-1])
      townhall_mails << { url.text.downcase => mail }
      i += 1
    end
  end
    
  def get_townhall_urls
    urls = []
    page = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/val-d-oise.html"))
    page.xpath('//p/a').each do |url|
      urls << { url.text.downcase => "http://www.annuaire-des-mairies.com/"+url['href'][1..-1] }
    end
    return urls
  end
    
  def get_townhall_email(townhall_url)
    begin
      page = Nokogiri::HTML(open(townhall_url))
      #page.encoding = 'utf-8'
      unless page.xpath('//body').text.downcase.include?('adresse email')
          return ''
      end
      page.xpath('//td').each do |td|
        match = td.text.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
        if(match)
          return match[0]
        end
      end
    rescue StandardError => e
      return ''
    end
    return ''
  end
    
  def big_array    
    towns = get_townhall_urls    
    a = []
    i=0
    towns.each do |town|
      a << { town.keys[0] => get_townhall_email(town.values[0]) }
      i += 1
    end
    return a
  end
    
  def save_as_JSON
    File.open("db/emails.json","w") do |f|
      f.write(JSON.pretty_generate(big_array))
    end
  end
  

  def save_as_spreadsheet
    
    # Creates a session. This will prompt the credential via command line for the
    # first time and save it to config.json file for later usages.
    session = GoogleDrive::Session.from_config("config.json")
    
    # First worksheet of
    # https://docs.google.com/spreadsheet/ccc?key=pz7XtlQC-PYx-jrVMJErTcg
    # Or https://docs.google.com/a/someone.com/spreadsheets/d/pz7XtlQC-PYx-jrVMJErTcg/edit?usp=drive_web
    ws = session.spreadsheet_by_key("1EIPf8O6u0j9JHjYmdh6A9jk8xxCqENQwB3KwMO9-XwY").worksheets[0]
    
    # Gets content of A2 cell.
    p ws[2, 1]  #==> "hoge"
    
    # Changes content of cells.
    # Changes are not sent to the server until you call ws.save().
    
    towns = get_townhall_urls
    i=0
    k=1
    towns.each do |town|  
      ws[k, 1] = town.keys[0]
      ws[k, 2] = get_townhall_email(town.values[0])
      i += 1
      k += 1
    end
    
    ws.save
    
    # Dumps all cells.
    (1..ws.num_rows).each do |row|
      (1..ws.num_cols).each do |col|
        p ws[row, col]
      end
    end
    
    # Yet another way to do so.
    p ws.rows  #==> [["fuga", ""], ["foo", "bar]]
    
    # Reloads the worksheet to get changes by other clients.
    ws.reload
  end
    
  def save_as_csv   
    i = 1
    towns = get_townhall_urls
    CSV.open("db/emails.csv", "wb") do |f|
      towns.each do |town|
        f << [i,town.keys[0],get_townhall_email(town.values[0])]
        i += 1       
      end
    end
  end
end
