require 'marcel'
require 'rubyXL'
require 'berkeley_library/util/xlsx/spreadsheet'

module BerkeleyLibrary
  module Holdings
    module Spreadsheets
      class << self
        include Spreadsheets
      end

      OCLC_COL_HEADER = 'OCLC Number'.freeze

      def oclc_numbers_from(xlsx_path, &)
        ss = Util::XLSX::Spreadsheet.new(xlsx_path)
        each_oclc_number(ss, &)
      end

      private

      def each_oclc_number(ss)
        return to_enum(:each_oclc_number, ss) unless block_given?

        oclc_col_index = ss.find_header_column_index!(OCLC_COL_HEADER)
        ss.each_value(oclc_col_index, include_header: false) do |v|
          next if (v_str = v.to_s).strip == ''

          yield v_str
        end
      end

    end
  end
end
