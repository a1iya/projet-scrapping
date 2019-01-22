require 'bundler'
Bundler.require

class Index
    def choix
        
        puts "Quel format de fichier pour les donées scrappées ?"
        puts "taper 1 pour JSON"
        puts "taper 2 pour google spreadsheet"
        puts "taper 3 pour CSV"
        
        user_choice = gets.chomp
        if user_choice == "1"
            puts "scrapping..."
            Scrapper.new.save_as_JSON
            puts "json done"
        elsif user_choice == "2"
            puts "scrapping..."
            Scrapper.new.save_as_spreadsheet
            puts "spreadsheet done."
        elsif user_choice == "3"
            puts "scrapping..."
            Scrapper.new.save_as_csv
            puts "csv done"
        else
            puts "recommencer"
        end
    end
end
