class Scrapper

    #la fonction retourne le tableau contenant la liste des villes avec leurs adresses mail correspondantes
  def get_townhall_mails
    townhall_mails = []
    #on récupère le contenu de la page avec Nokogiri
    page = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/val-d-oise.html"))
    #on récupère tous les liens (eng: anchors) directement sous un paragraphe n'importe où dans la page (//)
    page.xpath('//p/a').each do |url|
      #appel de la fonction récupérant l'adresse mail  d'une mairie à partir de l'url relative contenue dans le lien
      mail = get_townhall_email("http://www.annuaire-des-mairies.com/"+url['href'][1..-1])
      #on ajoute à notre tableau un hash composé du nom de la ville et de son mail
      townhall_mails << { url.text.downcase => mail }
    end
  end
  
  #la fonction retourne le tableau contenant la liste des villes avec l'url de leur page détaillée
  def get_townhall_urls
    urls = []
    page = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/val-d-oise.html"))
    page.xpath('//p/a').each do |url|
      urls << { url.text.downcase => "http://www.annuaire-des-mairies.com/"+url['href'][1..-1] }
    end
    return urls
  end

  #la fonction retourne l'adresse mail contenue dans la page dont l'url est passée en paramètre
  def get_townhall_email(townhall_url)
   #tout un code qui est susceptible de générer une exception
   begin
      page = Nokogiri::HTML(open(townhall_url))
      #page.encoding = 'utf-8'
      unless page.xpath('//body').text.downcase.include?('adresse email')
          return ''
      end
      page.xpath('//td').each do |td|
        #on vérifie que le contenu de la cellule (td) contient bien une adresse mail et pas autre chose : entre les crochets - tous les caractères possibles)
        #[A-Z]{2,4} = tout caractère entre A et Z au minimum 2 fois, au maximum 4 fois +
        # //i = non sensible à la casse (A = a)
        match = td.text.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
        if(match)
          #on prend que le 1r élément (pour ne pas avoir plusieurs adresses mail qui ont "matché"
          return match[0]
        end
      end
    #si jamais on n'arrive pas à joindre la page/s'il y a des erreurs, on passe dans la rescue
    rescue StandardError => e
      return ''
    end
    return ''
  end
    
  def big_array    
    towns = get_townhall_urls    
    a = []
    towns.each do |town|
      a << { town.keys[0] => get_townhall_email(town.values[0]) }
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
