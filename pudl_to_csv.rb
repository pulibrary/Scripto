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

def pad_order(number)
  pad_digits = 6 - number.to_s.length
  pad_string = "0" * pad_digits
  "#{pad_string}#{number.to_s}"
end

begin
	# args
	pudlno = ARGV[0]
  fail "YOU FORGOT TO SPECIFY A PUDL NUMBER!!!  Do this at the cmd prompt: ./get_csv.rb {mypudlnumber}" unless pudlno

  # vars
	pudl_url = "http://pudl.princeton.edu:8080/exist/pudl/Objects/" + pudlno
  loris_prefix = 'http://libimages.princeton.edu/loris/'
  loris_suffix = '/full/90,/0/native.jpg'
	csv_item_header = ["title","identifier","source","ispartof","relation","audience","files"]
  csv_file_header = ["filename","title","identifier","source","status","transcription","Omeka file order"]

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
  file_list = files.join("|")

  CSV.open("#{pudlno}_items.csv", "w") do |csv|
    csv << csv_item_header
    csv << [title,id,source,ispartof,relation,audience,file_list]
  end

	#files file
  #filename,title,identifier,source,status,transcription,Omeka file order
  #http://digital.lib.uiowa.edu/utils/getfile/collection/kinnick/id/2101/filename/2269.jpg,Front,kinnick_2234_2101,http://digital.lib.uiowa.edu/cdm/ref/collection/kinnick/id/2101,Not Started,,1
	file_data = obj_xml.xpath('//structure[@type="RelatedObjects"]/div/orderedlist/div')
	rows = []
	file_data.each do |div|
		rows << [loris_prefix + div.attr('img').sub('urn:pudl:images:deliverable:', "") + loris_suffix,div.attr('label'),div.attr('img').sub('urn:pudl:images:deliverable:', ""),pudl_url,'Not Started','',pad_order(div.attr('order'))]
	end

	CSV.open("#{pudlno}_files.csv", "w") do |csv|
		csv << csv_file_header
		rows.each do |row|
			csv << row
		end
		#file_data.each do |div|
		#	csv << [loris_prefix + div.attr('img').sub('urn:pudl:images:deliverable:', "") + loris_suffix,div.attr('label'),div.attr('order'),pudl_url,'Not Started','',div.attr('order')]
		#end
	end

end
