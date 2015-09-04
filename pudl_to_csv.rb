#!/usr/bin/env ruby

# README:
# This file takes a pudl number as an argument.
# The output is:
#  1 csv file for the item and
#  1 csv file for the files
# These files can be imported into the Omeka Scripto plugin
# For more details on the import, go here: https://github.com/Daniel-KM/CsvImport

require 'rubygems'
require 'parseconfig'
require 'nokogiri'
require 'csv'

begin
	# args
	pudlno = ARGV[0]
  fail "YOU FORGOT TO SPECIFY A PUDL NUMBER!!!  Do this at the cmd prompt: ./get_csv.rb {mypudlnumber}" unless pudlno

  # vars
	pudl_url = "http://pudl.princeton.edu:8080/exist/pudl/Objects/" + pudlno
  loris_prefix = 'http://libimages.princeton.edu/loris/'
  loris_suffix = '/full/full/0/native.jpg'
  csv_header = ["title","identifier","source","ispartof","relation","audience","files"]

  # go get 'em!
  doc = `curl #{pudl_url}`
  obj_xml = Nokogiri::HTML(doc)

  #title needs quotes
  title = obj_xml.xpath('//property/label[text()[contains(.,"Title:")]]/following-sibling::valuegrp/value/text()')
  id = pudlno
  source = pudl_url
  ispartof = obj_xml.xpath('//object/collections/collection/text()')
  relation = ''
  audience = '000000'
  files = obj_xml.xpath('//structure[@type="RelatedObjects"]/div/orderedlist/div/@img').to_a
  files.map! {|file| loris_prefix + file.to_s.sub('urn:pudl:images:deliverable:', "") + loris_suffix }
  #files needs quotes
  file_list = files.join(",")

  CSV.open("import_items.csv", "w") do |csv|
    csv << csv_header
    csv << [title,id,source,ispartof,relation,audience,file_list]
  end

end
