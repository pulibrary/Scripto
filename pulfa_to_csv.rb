#!/usr/bin/env ruby

# README:
# This file takes a finding aids Collection/Component number as an argument.
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

def get_order(s)
  s.split('/')[-1].split('.')[0]
end

begin
	# args
	collection_component = ARGV[0]
  #todo: test for slash here...
  fail "YOU FORGOT TO SPECIFY A collection_id and/or component_id!!!  Do this at the cmd prompt: ruby pulfa_to_csv.rb {collection_id/component_id}" unless collection_component
  return fail "Bad collection/component id... one slash only!" unless collection_component.count('/') == 1

  # vars
	pulfa_url = "http://findingaids.princeton.edu/collections/" + collection_component + ".xml"
  mets_url = "http://findingaids.princeton.edu/folders/" + collection_component + ".mets"
  loris_prefix = 'http://libimages.princeton.edu/loris2/'
  loris_suffix = '/full/90,/0/default.jpg'
	csv_item_header = ["title","identifier","source","ispartof","relation","audience","files"]
  csv_file_header = ["filename","title","identifier","source","status","transcription","Omeka file order"]
  mets_ns = "http://www.loc.gov/METS/"
  xlink_ns = "http://www.w3.org/1999/xlink"

  # go get 'em!
  doc = `curl #{pulfa_url}`
  obj_xml = Nokogiri::HTML(doc)

  mets = `curl #{mets_url}`
  mets_xml = Nokogiri::XML(mets)

  #title needs quotes, remove any existing quotes
  title = obj_xml.xpath('//unittitle/text()').text().gsub('"','')
  id = collection_component.gsub('/', '_')
  source = pulfa_url
  ispartof = collection_component
  relation = ''
  audience = '000000'

  files = mets_xml.xpath('//mets:file[@USE="deliverable"]/mets:FLocat/@xlink:href', 'mets' => mets_ns, 'xlink' => xlink_ns).to_a
  #files = mets_xml.xpath('//file[@USE="deliverable"]/flocat/@xlink:href', 'xlink' => xlink_ns).to_a
  files.map! {|file| loris_prefix + file.to_s.sub('urn:pudl:images:deliverable:', "") + loris_suffix }
  #files needs quotes
  file_list = files.join("|")

  CSV.open("#{id}_items.csv", "w") do |csv|
    csv << csv_item_header
    csv << [title,id,source,ispartof,relation,audience,file_list]
  end

	#files file
  #filename,title,identifier,source,status,transcription,Omeka file order
  #http://digital.lib.uiowa.edu/utils/getfile/collection/kinnick/id/2101/filename/2269.jpg,Front,kinnick_2234_2101,http://digital.lib.uiowa.edu/cdm/ref/collection/kinnick/id/2101,Not Started,,1
	file_data = mets_xml.xpath('//mets:file[@USE="deliverable"]/mets:FLocat')
	rows = []
	file_data.each do |div|
		rows << [loris_prefix + div.attr('xlink:href').sub('urn:pudl:images:deliverable:', "") + loris_suffix,"Page " + get_order(div.attr('xlink:href')),div.attr('xlink:href').sub('urn:pudl:images:deliverable:', ""),pulfa_url,'Not Started','',get_order(div.attr('xlink:href'))]
	end

	CSV.open("#{id}_files.csv", "w") do |csv|
		csv << csv_file_header
		rows.each do |row|
			csv << row
		end
		#file_data.each do |div|
		#	csv << [loris_prefix + div.attr('img').sub('urn:pudl:images:deliverable:', "") + loris_suffix,div.attr('label'),div.attr('order'),pudl_url,'Not Started','',div.attr('order')]
		#end
	end

end
