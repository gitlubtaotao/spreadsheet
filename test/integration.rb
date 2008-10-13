#!/usr/bin/env ruby
# TestIntegration -- Spreadheet -- 08.10.2007 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require 'spreadsheet'
require 'fileutils'

module Spreadsheet
  class TestIntegration < Test::Unit::TestCase
    @@iconv = Iconv.new('UTF-16LE', 'UTF8')
    def setup
      @var = File.expand_path 'var', File.dirname(__FILE__)
      FileUtils.mkdir_p @var
      @data = File.expand_path 'data', File.dirname(__FILE__)
      FileUtils.mkdir_p @data
    end
    def teardown
      Spreadsheet.client_encoding = 'UTF8'
      FileUtils.rm_r @var
    end
    def test_copy__identical__file_paths
      path = File.join @data, 'test_copy.xls'
      copy = File.join @data, 'test_copy1.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      book.write copy
      assert_equal File.read(path), File.read(copy)
    ensure
      File.delete copy if File.exist? copy
    end
    def test_version_excel97__ooffice__utf16
      Spreadsheet.client_encoding = 'UTF-16LE'
      assert_equal 'UTF-16LE', Spreadsheet.client_encoding
      path = File.join @data, 'test_version_excel97.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 8, book.biff_version
      assert_equal @@iconv.iconv('Microsoft Excel 97/2000/XP'), 
                   book.version_string
      enc = 'UTF-16LE'
      if defined? Encoding
        enc = Encoding.find enc
      end
      assert_equal enc, book.encoding
      assert_equal 23, book.formats.size
      assert_equal 4, book.fonts.size
      str1 = book.shared_string 0
      assert_equal @@iconv.iconv('Shared String'), str1
      str2 = book.shared_string 1
      assert_equal @@iconv.iconv('Another Shared String'), str2
      str3 = book.shared_string 2
      long = @@iconv.iconv('1234567890 ' * 1000)
      if str3 != long
        long.size.times do |idx|
          len = idx.next
          if str3[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str3[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str3
      str4 = book.shared_string 3
      long = @@iconv.iconv('9876543210 ' * 1000)
      if str4 != long
        long.size.times do |idx|
          len = idx.next
          if str4[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str4[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str4
      sheet = book.worksheet 0
      assert_equal 10, sheet.row_count
      assert_equal 11, sheet.column_count
      useds = [0,0,0,0,0,0,0,1,0,0]
      unuseds = [2,2,1,1,1,2,1,11,1,1]
      sheet.each do |row|
        assert_equal useds.shift, row.first_used
        assert_equal unuseds.shift, row.first_unused
      end
      assert unuseds.empty?, "not all rows were visited in Spreadsheet#each"
      row = sheet.row 0
      assert_equal str1, row[0]
      assert_equal str1, sheet[0,0]
      assert_equal str1, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal str2, row[0]
      assert_equal str2, sheet[1,0]
      assert_equal str2, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      date = Date.new 1975, 8, 21
      assert_equal date, row[1]
      assert_equal date, sheet[5,1]
      assert_equal date, sheet.cell(5,1)
      row = sheet.row 6
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
      row = sheet.row 8
      assert_equal 0.0001, row[0]
      row = sheet.row 9
      assert_equal 0.00009, row[0]
    end
    def test_version_excel97__ooffice
      path = File.join @data, 'test_version_excel97.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 8, book.biff_version
      assert_equal 'Microsoft Excel 97/2000/XP', book.version_string
      enc = 'UTF-16LE'
      if defined? Encoding
        enc = Encoding.find enc
      end
      assert_equal enc, book.encoding
      assert_equal 23, book.formats.size
      assert_equal 4, book.fonts.size
      str1 = book.shared_string 0
      assert_equal 'Shared String', str1
      str2 = book.shared_string 1
      assert_equal 'Another Shared String', str2
      str3 = book.shared_string 2
      long = '1234567890 ' * 1000
      if str3 != long
        long.size.times do |idx|
          len = idx.next
          if str3[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str3[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str3
      str4 = book.shared_string 3
      long = '9876543210 ' * 1000
      if str4 != long
        long.size.times do |idx|
          len = idx.next
          if str4[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str4[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str4
      sheet = book.worksheet 0
      assert_equal 10, sheet.row_count
      assert_equal 11, sheet.column_count
      useds = [0,0,0,0,0,0,0,1,0,0]
      unuseds = [2,2,1,1,1,2,1,11,1,1]
      sheet.each do |row|
        assert_equal useds.shift, row.first_used
        assert_equal unuseds.shift, row.first_unused
      end
      assert unuseds.empty?, "not all rows were visited in Spreadsheet#each"
      row = sheet.row 0
      assert_equal str1, row[0]
      assert_equal str1, sheet[0,0]
      assert_equal str1, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal str2, row[0]
      assert_equal str2, sheet[1,0]
      assert_equal str2, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      date = Date.new 1975, 8, 21
      assert_equal date, row[1]
      assert_equal date, sheet[5,1]
      assert_equal date, sheet.cell(5,1)
      row = sheet.row 6
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
      row = sheet.row 8
      assert_equal 0.0001, row[0]
      row = sheet.row 9
      assert_equal 0.00009, row[0]
    end
    def test_version_excel95__ooffice__utf16
      Spreadsheet.client_encoding = 'UTF-16LE'
      path = File.join @data, 'test_version_excel95.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 5, book.biff_version
      assert_equal @@iconv.iconv('Microsoft Excel 95'), book.version_string
      enc = 'WINDOWS-1252'
      if defined? Encoding
        enc = Encoding.find enc
      end
      assert_equal enc, book.encoding
      str1 = @@iconv.iconv('Shared String')
      str2 = @@iconv.iconv('Another Shared String')
      str3 = @@iconv.iconv(('1234567890 ' * 26)[0,255])
      str4 = @@iconv.iconv(('9876543210 ' * 26)[0,255])
      sheet = book.worksheet 0
      assert_equal 8, sheet.row_count
      assert_equal 11, sheet.column_count
      useds = [0,0,0,0,0,0,0,1]
      unuseds = [2,2,1,1,1,1,1,11]
      sheet.each do |row|
        assert_equal useds.shift, row.first_used
        assert_equal unuseds.shift, row.first_unused
      end
      assert unuseds.empty?, "not all rows were visited in Spreadsheet#each"
      row = sheet.row 0
      assert_equal str1, row[0]
      assert_equal str1, sheet[0,0]
      assert_equal str1, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal str2, row[0]
      assert_equal str2, sheet[1,0]
      assert_equal str2, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal 510, row[0].size
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal 510, row[0].size
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      row = sheet.row 6
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
    end
    def test_version_excel95__ooffice
      path = File.join @data, 'test_version_excel95.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 5, book.biff_version
      assert_equal 'Microsoft Excel 95', book.version_string
      enc = 'WINDOWS-1252'
      if defined? Encoding
        enc = Encoding.find enc
      end
      assert_equal enc, book.encoding
      str1 = 'Shared String'
      str2 = 'Another Shared String'
      str3 = ('1234567890 ' * 26)[0,255]
      str4 = ('9876543210 ' * 26)[0,255]
      sheet = book.worksheet 0
      assert_equal 8, sheet.row_count
      assert_equal 11, sheet.column_count
      useds = [0,0,0,0,0,0,0,1]
      unuseds = [2,2,1,1,1,1,1,11]
      sheet.each do |row|
        assert_equal useds.shift, row.first_used
        assert_equal unuseds.shift, row.first_unused
      end
      assert unuseds.empty?, "not all rows were visited in Spreadsheet#each"
      row = sheet.row 0
      assert_equal str1, row[0]
      assert_equal str1, sheet[0,0]
      assert_equal str1, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal str2, row[0]
      assert_equal str2, sheet[1,0]
      assert_equal str2, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal 255, row[0].size
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal 255, row[0].size
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      row = sheet.row 6
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
    end
    def test_version_excel5__ooffice
      path = File.join @data, 'test_version_excel5.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 5, book.biff_version
      assert_equal 'Microsoft Excel 95', book.version_string
      enc = 'WINDOWS-1252'
      if defined? Encoding
        enc = Encoding.find enc
      end
      assert_equal enc, book.encoding
      str1 = 'Shared String'
      str2 = 'Another Shared String'
      str3 = ('1234567890 ' * 26)[0,255]
      str4 = ('9876543210 ' * 26)[0,255]
      sheet = book.worksheet 0
      assert_equal 8, sheet.row_count
      assert_equal 11, sheet.column_count
      useds = [0,0,0,0,0,0,0,1]
      unuseds = [2,2,1,1,1,1,1,11]
      sheet.each do |row|
        assert_equal useds.shift, row.first_used
        assert_equal unuseds.shift, row.first_unused
      end
      assert unuseds.empty?, "not all rows were visited in Spreadsheet#each"
      row = sheet.row 0
      assert_equal str1, row[0]
      assert_equal str1, sheet[0,0]
      assert_equal str1, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal str2, row[0]
      assert_equal str2, sheet[1,0]
      assert_equal str2, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal 255, row[0].size
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal 255, row[0].size
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      row = sheet.row 6
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
    end
    def test_worksheets
      path = File.join @data, 'test_copy.xls'
      book = Spreadsheet.open path
      sheets = book.worksheets
      assert_equal 3, sheets.size
      sheet = book.worksheet 0
      assert_instance_of Excel::Worksheet, sheet
      assert_equal sheet, book.worksheet('Sheet1')
    end
    def test_worksheets__utf16
      Spreadsheet.client_encoding = 'UTF-16LE'
      path = File.join @data, 'test_copy.xls'
      book = Spreadsheet.open path
      sheets = book.worksheets
      assert_equal 3, sheets.size
      sheet = book.worksheet 0
      assert_instance_of Excel::Worksheet, sheet
      assert_equal sheet, book.worksheet("S\000h\000e\000e\000t\0001\000")
    end
    def test_change_encoding
      path = File.join @data, 'test_version_excel95.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 5, book.biff_version
      assert_equal 'Microsoft Excel 95', book.version_string
      enc = 'WINDOWS-1252'
      if defined? Encoding
        enc = Encoding.find enc
      end
      assert_equal enc, book.encoding
      enc = 'WINDOWS-1256'
      if defined? Encoding
        enc = Encoding.find enc
      end
      book.encoding = enc
      path = File.join @var, 'test_change_encoding.xls'
      book.write path
      assert_nothing_raised do book = Spreadsheet.open path end
      assert_equal enc, book.encoding
    end
    def test_change_cell
      path = File.join @data, 'test_version_excel97.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 8, book.biff_version
      assert_equal 'Microsoft Excel 97/2000/XP', book.version_string
      path = File.join @var, 'test_change_cell.xls'
      str1 = book.shared_string 0
      assert_equal 'Shared String', str1
      str2 = book.shared_string 1
      assert_equal 'Another Shared String', str2
      str3 = book.shared_string 2
      long = '1234567890 ' * 1000
      if str3 != long
        long.size.times do |idx|
          len = idx.next
          if str3[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str3[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str3
      str4 = book.shared_string 3
      long = '9876543210 ' * 1000
      if str4 != long
        long.size.times do |idx|
          len = idx.next
          if str4[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str4[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str4
      sheet = book.worksheet 0 
      sheet[0,0] = 4
      row = sheet.row 1
      row[0] = 3
      book.write path
      assert_nothing_raised do book = Spreadsheet.open path end
      sheet = book.worksheet 0 
      assert_equal 10, sheet.row_count
      assert_equal 11, sheet.column_count
      useds = [0,0,0,0,0,0,0,1,0,0]
      unuseds = [2,2,1,1,1,2,1,11,1,1]
      sheet.each do |row|
        assert_equal useds.shift, row.first_used
        assert_equal unuseds.shift, row.first_unused
      end
      assert unuseds.empty?, "not all rows were visited in Spreadsheet#each"
      row = sheet.row 0
      assert_equal 4, row[0]
      assert_equal 4, sheet[0,0]
      assert_equal 4, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal 3, row[0]
      assert_equal 3, sheet[1,0]
      assert_equal 3, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      date = Date.new 1975, 8, 21
      assert_equal date, row[1]
      assert_equal date, sheet[5,1]
      assert_equal date, sheet.cell(5,1)
      row = sheet.row 6
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
      row = sheet.row 8
      assert_equal 0.0001, row[0]
      row = sheet.row 9
      assert_equal 0.00009, row[0]
    end
    def test_change_cell__complete_sst_rewrite
      path = File.join @data, 'test_version_excel97.xls'
      book = Spreadsheet.open path
      assert_instance_of Excel::Workbook, book
      assert_equal 8, book.biff_version
      assert_equal 'Microsoft Excel 97/2000/XP', book.version_string
      path = File.join @var, 'test_change_cell.xls'
      str1 = book.shared_string 0
      assert_equal 'Shared String', str1
      str2 = book.shared_string 1
      assert_equal 'Another Shared String', str2
      str3 = book.shared_string 2
      long = '1234567890 ' * 1000
      if str3 != long
        long.size.times do |idx|
          len = idx.next
          if str3[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str3[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str3
      str4 = book.shared_string 3
      long = '9876543210 ' * 1000
      if str4 != long
        long.size.times do |idx|
          len = idx.next
          if str4[0,len] != long[0,len]
            assert_equal long[idx - 5, 10], str4[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal long, str4
      sheet = book.worksheet 0 
      sheet[0,0] = 4
      str5 = 'A completely different String'
      sheet[0,1] = str5
      row = sheet.row 1
      row[0] = 3
      book.write path
      assert_nothing_raised do book = Spreadsheet.open path end
      assert_equal str5, book.shared_string(0)
      assert_equal str2, book.shared_string(1)
      assert_equal str3, book.shared_string(2)
      assert_equal str4, book.shared_string(3)
      sheet = book.worksheet 0 
      assert_equal 10, sheet.row_count
      assert_equal 11, sheet.column_count
      useds = [0,0,0,0,0,0,0,1,0,0]
      unuseds = [2,2,1,1,1,2,1,11,1,1]
      sheet.each do |row|
        assert_equal useds.shift, row.first_used
        assert_equal unuseds.shift, row.first_unused
      end
      assert unuseds.empty?, "not all rows were visited in Spreadsheet#each"
      row = sheet.row 0
      assert_equal 4, row[0]
      assert_equal 4, sheet[0,0]
      assert_equal 4, sheet.cell(0,0)
      assert_equal str5, row[1]
      assert_equal str5, sheet[0,1]
      assert_equal str5, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal 3, row[0]
      assert_equal 3, sheet[1,0]
      assert_equal 3, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      date = Date.new 1975, 8, 21
      assert_equal date, row[1]
      assert_equal date, sheet[5,1]
      assert_equal date, sheet.cell(5,1)
      row = sheet.row 6
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
      row = sheet.row 8
      assert_equal 0.0001, row[0]
      row = sheet.row 9
      assert_equal 0.00009, row[0]
    end
    def test_write_new_workbook
      book = Spreadsheet::Excel::Workbook.new
      path = File.join @var, 'test_write_workbook.xls'
      sheet1 = book.create_worksheet
      str1 = 'Shared String'
      str2 = 'Another Shared String'
      str3 = '1234567890 ' * 1000
      str4 = '9876543210 ' * 1000
      sheet1[0,0] = str1
      sheet1.row(0).push str1
      sheet1.row(1).concat [str2, str2]
      sheet1[2,0] = str3
      sheet1[3,0] = str4
      fmt = Format.new :color => 'red'
      sheet1[4,0] = 0.25
      sheet1.row(4).set_format 0, fmt
      fmt = Format.new :color => 'aqua'
      sheet1[5,0] = 0.75
      sheet1.row(5).set_format 0, fmt
      sheet1[6,0] = 1
      fmt = Format.new :color => 'green'
      sheet1.row(6).set_format 0, fmt
      sheet1[6,1] = Date.new 2008, 10, 10
      sheet1[6,2] = Date.new 2008, 10, 12
      fmt = Format.new :number_format => 'DD.MM.YYYY'
      sheet1.row(6).set_format 1, fmt
      sheet1.update_row 7, nil, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
      sheet1[8,0] = 0.0005
      sheet1[8,1] = 0.005
      sheet1[8,2] = 0.05
      sheet1[8,3] = 10.5
      sheet1[8,4] = 1.05
      sheet1[8,5] = 100.5
      sheet1[8,6] = 10.05
      sheet1[8,7] = 1.005
      sheet1[9,0] = 100.5
      sheet1[9,1] = 10.05
      sheet1[9,2] = 1.005
      sheet1[9,3] = 1000.5
      sheet1[9,4] = 100.05
      sheet1[9,5] = 10.005
      sheet1[9,6] = 1.0005
      sheet1[10,0] = 10000.5
      sheet1[10,1] = 1000.05
      sheet1[10,2] = 100.005
      sheet1[10,3] = 10.0005
      sheet1[10,4] = 1.00005
      sheet1.insert_row 9, ['a', 'b', 'c']
      assert_equal 'a', sheet1[9,0]
      assert_equal 'b', sheet1[9,1]
      assert_equal 'c', sheet1[9,2]
      sheet1.delete_row 9
      sheet2 = book.create_worksheet :name => 'my name'
      book.write path
      Spreadsheet.client_encoding = 'UTF-16LE'
      str1 = @@iconv.iconv str1
      str2 = @@iconv.iconv str2
      str3 = @@iconv.iconv str3
      str4 = @@iconv.iconv str4
      assert_nothing_raised do book = Spreadsheet.open path end
      assert_equal 'UTF-16LE', book.encoding
      assert_equal str1, book.shared_string(0)
      assert_equal str2, book.shared_string(1)
      test = book.shared_string 2
      if test != str3
        str3.size.times do |idx|
          len = idx.next
          if test[0,len] != str3[0,len]
            assert_equal str3[idx - 5, 10], test[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal str3, test
      test = book.shared_string 3
      if test != str4
        str4.size.times do |idx|
          len = idx.next
          if test[0,len] != str4[0,len]
            assert_equal str4[idx - 5, 10], test[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal str4, test
      assert_equal 2, book.worksheets.size
      sheet = book.worksheets.first
      assert_instance_of Spreadsheet::Excel::Worksheet, sheet
      assert_equal "W\000o\000r\000k\000s\000h\000e\000e\000t\0001\000", 
                   sheet.name
      assert_not_nil sheet.offset
      row = sheet.row 0
      assert_equal str1, row[0]
      assert_equal str1, sheet[0,0]
      assert_equal str1, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal str2, row[0]
      assert_equal str2, sheet[1,0]
      assert_equal str2, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal :red, row.format(0).font.color
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal :cyan, row.format(0).font.color
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      row = sheet.row 6
      assert_equal :green, row.format(0).font.color
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      assert_equal @@iconv.iconv('DD.MM.YYYY'), row.format(1).number_format
      date = Date.new 2008, 10, 10
      assert_equal date, row[1]
      assert_equal date, sheet[6,1]
      assert_equal date, sheet.cell(6,1)
      assert_equal @@iconv.iconv('M/D/YY'), row.format(2).number_format
      date = Date.new 2008, 10, 12
      assert_equal date, row[2]
      assert_equal date, sheet[6,2]
      assert_equal date, sheet.cell(6,2)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
      assert_equal 0.0005, sheet1[8,0]
      assert_equal 0.005, sheet1[8,1]
      assert_equal 0.05, sheet1[8,2]
      assert_equal 10.5, sheet1[8,3]
      assert_equal 1.05, sheet1[8,4]
      assert_equal 100.5, sheet1[8,5]
      assert_equal 10.05, sheet1[8,6]
      assert_equal 1.005, sheet1[8,7]
      assert_equal 100.5, sheet1[9,0]
      assert_equal 10.05, sheet1[9,1]
      assert_equal 1.005, sheet1[9,2]
      assert_equal 1000.5, sheet1[9,3]
      assert_equal 100.05, sheet1[9,4]
      assert_equal 10.005, sheet1[9,5]
      assert_equal 1.0005, sheet1[9,6]
      assert_equal 10000.5, sheet1[10,0]
      assert_equal 1000.05, sheet1[10,1]
      assert_equal 100.005, sheet1[10,2]
      assert_equal 10.0005, sheet1[10,3]
      assert_equal 1.00005, sheet1[10,4]
      assert_instance_of Spreadsheet::Excel::Worksheet, sheet
      sheet = book.worksheets.last
      assert_equal "m\000y\000 \000n\000a\000m\000e\000", 
                   sheet.name
      assert_not_nil sheet.offset
    end
    def test_write_new_workbook__utf16
      Spreadsheet.client_encoding = 'UTF-16LE'
      book = Spreadsheet::Excel::Workbook.new
      path = File.join @var, 'test_write_workbook.xls'
      sheet1 = book.create_worksheet
      str1 = @@iconv.iconv 'Shared String'
      str2 = @@iconv.iconv 'Another Shared String'
      str3 = @@iconv.iconv('1234567890 ' * 1000)
      str4 = @@iconv.iconv('9876543210 ' * 1000)
      sheet1[0,0] = str1
      sheet1.row(0).push str1
      sheet1.row(1).concat [str2, str2]
      sheet1[2,0] = str3
      sheet1[3,0] = str4
      fmt = Format.new :color => 'red'
      sheet1[4,0] = 0.25
      sheet1.row(4).set_format 0, fmt
      fmt = Format.new :color => 'aqua'
      sheet1[5,0] = 0.75
      sheet1.row(5).set_format 0, fmt
      sheet1[6,0] = 1
      fmt = Format.new :color => 'green'
      sheet1.row(6).set_format 0, fmt
      sheet1[6,1] = Date.new 2008, 10, 10
      sheet1[6,2] = Date.new 2008, 10, 12
      fmt = Format.new :number_format => "D\0D\0.\0M\0M\0.\0Y\0Y\0Y\0Y\0"
      sheet1.row(6).set_format 1, fmt
      sheet1.update_row 7, nil, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
      sheet2 = book.create_worksheet :name => "m\0y\0 \0n\0a\0m\0e\0"
      book.write path
      Spreadsheet.client_encoding = 'UTF8'
      str1 = 'Shared String'
      str2 = 'Another Shared String'
      str3 = '1234567890 ' * 1000
      str4 = '9876543210 ' * 1000
      assert_nothing_raised do book = Spreadsheet.open path end
      assert_equal 'UTF-16LE', book.encoding
      assert_equal str1, book.shared_string(0)
      assert_equal str2, book.shared_string(1)
      test = book.shared_string 2
      if test != str3
        str3.size.times do |idx|
          len = idx.next
          if test[0,len] != str3[0,len]
            assert_equal str3[idx - 5, 10], test[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal str3, test
      test = book.shared_string 3
      if test != str4
        str4.size.times do |idx|
          len = idx.next
          if test[0,len] != str4[0,len]
            assert_equal str4[idx - 5, 10], test[idx - 5, 10], "in position #{idx}"
          end
        end
      end
      assert_equal str4, test
      assert_equal 2, book.worksheets.size
      sheet = book.worksheets.first
      assert_instance_of Spreadsheet::Excel::Worksheet, sheet
      assert_equal "Worksheet1", sheet.name
      assert_not_nil sheet.offset
      row = sheet.row 0
      assert_equal str1, row[0]
      assert_equal str1, sheet[0,0]
      assert_equal str1, sheet.cell(0,0)
      assert_equal str1, row[1]
      assert_equal str1, sheet[0,1]
      assert_equal str1, sheet.cell(0,1)
      row = sheet.row 1
      assert_equal str2, row[0]
      assert_equal str2, sheet[1,0]
      assert_equal str2, sheet.cell(1,0)
      assert_equal str2, row[1]
      assert_equal str2, sheet[1,1]
      assert_equal str2, sheet.cell(1,1)
      row = sheet.row 2
      assert_equal str3, row[0]
      assert_equal str3, sheet[2,0]
      assert_equal str3, sheet.cell(2,0)
      assert_nil row[1]
      assert_nil sheet[2,1]
      assert_nil sheet.cell(2,1)
      row = sheet.row 3
      assert_equal str4, row[0]
      assert_equal str4, sheet[3,0]
      assert_equal str4, sheet.cell(3,0)
      assert_nil row[1]
      assert_nil sheet[3,1]
      assert_nil sheet.cell(3,1)
      row = sheet.row 4
      assert_equal :red, row.format(0).font.color
      assert_equal 0.25, row[0]
      assert_equal 0.25, sheet[4,0]
      assert_equal 0.25, sheet.cell(4,0)
      row = sheet.row 5
      assert_equal :cyan, row.format(0).font.color
      assert_equal 0.75, row[0]
      assert_equal 0.75, sheet[5,0]
      assert_equal 0.75, sheet.cell(5,0)
      row = sheet.row 6
      assert_equal :green, row.format(0).font.color
      assert_equal 1, row[0]
      assert_equal 1, sheet[6,0]
      assert_equal 1, sheet.cell(6,0)
      assert_equal 'DD.MM.YYYY', row.format(1).number_format
      date = Date.new 2008, 10, 10
      assert_equal date, row[1]
      assert_equal date, sheet[6,1]
      assert_equal date, sheet.cell(6,1)
      assert_equal 'M/D/YY', row.format(2).number_format
      date = Date.new 2008, 10, 12
      assert_equal date, row[2]
      assert_equal date, sheet[6,2]
      assert_equal date, sheet.cell(6,2)
      row = sheet.row 7
      assert_nil row[0]
      assert_equal [1,2,3,4,5,6,7,8,9,0], row[1,10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet[7,1..10]
      assert_equal [1,2,3,4,5,6,7,8,9,0], sheet.cell(7,1..10)
      assert_instance_of Spreadsheet::Excel::Worksheet, sheet
      sheet = book.worksheets.last
      assert_equal "my name", 
                   sheet.name
      assert_not_nil sheet.offset
    end
    def test_read_bsv
      book = Spreadsheet.open '/home/hwyss/cogito/oddb.org/data/xls/BSV_per_2008.10.01.xls'
      sheet = book.worksheet 0
      assert_equal Date.new(2000), sheet[1,6]
    end
  end
end
