require 'marcel'
require 'rubyXL'
require 'berkeley_library/holdings/constants'
require 'berkeley_library/util/xlsx/spreadsheet'

module BerkeleyLibrary
  module Holdings
    class XLSXReader
      include Constants

      attr_reader :ss, :oclc_col_index

      def initialize(xlsx_path)
        @ss = Util::XLSX::Spreadsheet.new(xlsx_path)
        @oclc_col_index = ss.find_column_index_by_header!(OCLC_COL_HEADER)
      end

      def each_oclc_number
        return to_enum(:each_oclc_number) unless block_given?

        ss.each_value(oclc_col_index, include_header: false) do |v|
          next if (v_str = v.to_s).strip == ''

          yield v_str
        end
      end
    end
  end
end
