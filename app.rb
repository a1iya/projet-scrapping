require 'csv'
require 'bundler'
Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper.rb'
require 'views/index'
require 'views/done'

Index.new.choix
Done.new.recommencer
