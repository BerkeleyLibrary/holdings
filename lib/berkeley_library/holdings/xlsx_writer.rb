require 'berkeley_library/logging'
require 'berkeley_library/holdings/constants'

module BerkeleyLibrary
  module Holdings
    class XLSXWriter
      include Constants
      include BerkeleyLibrary::Logging

      COL_NRLF = 'NRLF'.freeze
      COL_SRLF = 'SRLF'.freeze
      COL_OTHER_UC = 'Other UC'.freeze
      COL_HATHI_TRUST = 'Hathi Trust'.freeze

      V_NRLF = 'nrlf'.freeze
      V_SRLF = 'srlf'.freeze

      attr_reader :ss, :rlf, :uc, :hathi_trust

      def initialize(ss, rlf: true, uc: true, hathi_trust: true)
        @ss = ss
        @rlf = rlf
        @uc = uc
        @hathi_trust = hathi_trust

        ensure_columns!
      end

      def <<(result)
        r_index = row_index_for(result.oclc_number)
        write_rlf(r_index, result) if rlf
        write_uc(r_index, result) if uc
        write_hathi(r_index, result) if hathi_trust
        # TODO: should we do anything with wc_error and ht_error?
      end

      private

      def ensure_columns!
        if rlf
          nrlf_col_index
          srlf_col_index
        end
        uc_col_index if uc
        ht_col_index if hathi_trust
      end

      def row_index_for(oclc_number)
        row_index = row_index_by_oclc_number[oclc_number]
        return row_index if row_index

        raise ArgumentError, "Unknown OCLC number: #{oclc_number}"
      end

      def write_rlf(r_index, result)
        ss.set_value_at(r_index, nrlf_col_index, V_NRLF) if result.nrlf?
        ss.set_value_at(r_index, srlf_col_index, V_SRLF) if result.srlf?
      end

      def write_uc(r_index, result)
        return if (uc_symbols = result.uc_symbols).empty?

        ss.set_value_at(r_index, uc_col_index, uc_symbols.join(','))
      end

      def write_hathi(r_index, result)
        return unless (ht_record_url = result.ht_record_url)

        ss.set_value_at(r_index, ht_col_index, ht_record_url)
      end

      def oclc_col_index
        @oclc_col_index ||= ss.find_column_index_by_header!(OCLC_COL_HEADER)
      end

      def nrlf_col_index
        @nrlf_col_index ||= ss.ensure_column!(COL_NRLF)
      end

      def srlf_col_index
        @srlf_col_index ||= ss.ensure_column!(COL_SRLF)
      end

      def uc_col_index
        @uc_col_index ||= ss.ensure_column!(COL_OTHER_UC)
      end

      def ht_col_index
        @ht_col_index ||= ss.ensure_column!(COL_HATHI_TRUST)
      end

      def row_index_by_oclc_number
        # Start at 1 to skip header row
        @row_index_by_oclc_number ||= (1...ss.row_count).each_with_object({}) do |r_index, r_indices|
          oclc_number_raw = ss.value_at(r_index, oclc_col_index)
          next unless oclc_number_raw

          oclc_number = oclc_number_raw.to_s
          if r_indices.key?(oclc_number)
            logger.warn("Skipping duplicate OCLC number #{oclc_number} in row #{r_index}")
          else
            r_indices[oclc_number] = r_index
          end
        end
      end
    end
  end
end
