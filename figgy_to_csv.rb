#!/usr/bin/env ruby

# README:
# This file takes a Figgy number as an argument.
# The output is:
#  1 csv file for the item and
#  1 csv file for the files
# These files can be imported into the Omeka Scripto plugin
# For more details on the import, go here: https://github.com/Daniel-KM/CsvImport

require 'rubygems'
require 'parseconfig'
require 'json'
#require 'nokogiri'
require 'csv'

def pad_order(number)
  pad_digits = 6 - number.to_s.length
  pad_string = "0" * pad_digits
  "#{pad_string}#{number.to_s}"
end

begin
	# args
	figgy_num = ARGV[0]
  fail "YOU FORGOT TO SPECIFY A FIGGY NUMBER!!!  Do this at the cmd prompt: ./figgy_to_csv.rb {MyFiggyNumber}" unless figgy_num

  # vars
	manifest_url = "https://figgy.princeton.edu/collections/" + figgy_num + "/manifest"
  img_server_prefix = "https://iiif.princeton.edu/loris/figgy_prod"
  img_server_suffix = "/full/1000,/0/default.jpg"
  loris_prefix = 'http://libimages.princeton.edu/loris2/'
  loris_suffix = '/full/90,/0/default.jpg'
	csv_item_header = ["title","identifier","source","ispartof","relation","audience","files"]
  csv_file_header = ["filename","title","identifier","source","status","transcription","Omeka file order"]

  # go get 'em!
  manifest = `curl #{manifest_url}`
  parsed = JSON.parse(manifest)


  title = parsed['label'].first
  id = parsed["@id"]
  source = ""
  ispartof = ""
  relation = ""
  audience = "000000"
  canvases = parsed["sequences"][0]["canvases"]
  files = canvases.map {|canvas| canvas["images"][0]["resource"]["@id"] }
  #files needs quotes
  file_list = files.join("|")

  CSV.open("#{figgy_num}_items.csv", "w", force_quotes: true) do |csv|
    csv << csv_item_header
    csv << ["#{title}",id,source,ispartof,relation,audience,file_list]
  end

	#files file
  #filename,title,identifier,source,status,transcription,Omeka file order
  #http://digital.lib.uiowa.edu/utils/getfile/collection/kinnick/id/2101/filename/2269.jpg,Front,kinnick_2234_2101,http://digital.lib.uiowa.edu/cdm/ref/collection/kinnick/id/2101,Not Started,,1

  #file_data = obj_xml.xpath('//structure[@type="RelatedObjects"]/div/orderedlist/div')
	rows = []
  i = 0
	canvases.each do |canvas, index|
    i=i+1
		rows << [
      canvas["images"][0]["resource"]["@id"],
      canvas['label'],
      canvas["images"][0]["@id"],
      "https://figgy.princeton.edu/catalog/" + figgy_num,
      "Not Started",
      "",
      pad_order(i)
    ]
	end

	CSV.open("#{figgy_num}_files.csv", "w", force_quotes: true) do |csv|
		csv << csv_file_header
		rows.each do |row|
			csv << row
		end
	end

end
