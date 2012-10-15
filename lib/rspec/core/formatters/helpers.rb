module RSpec
  module Core
    module BacktraceFormatter
      extend self

      def format_backtrace(backtrace, options = {})
        return "" unless backtrace
        return backtrace if options[:full_backtrace] == true

        if at_exit_index = backtrace.index(RSpec::Core::Runner::AT_EXIT_HOOK_BACKTRACE_LINE)
          backtrace = backtrace[0, at_exit_index]
        end

        cleansed = backtrace.map { |line| backtrace_line(line) }.compact
        cleansed.empty? ? backtrace : cleansed
      end

    protected

      def backtrace_line(line)
        return nil if RSpec.configuration.cleaned_from_backtrace?(line)
        RSpec::Core::Metadata::relative_path(line)
      rescue SecurityError
        nil
      end
    end

    module Formatters
      module Helpers
        include BacktraceFormatter

        SUB_SECOND_PRECISION = 5
        DEFAULT_PRECISION = 2

        # @api public
        #
        # Formats seconds into a human-readable string.
        #
        # @param [Float, Fixnum] duration in seconds
        # @return [String] human-readable time
        #
        # @example
        #    format_duration(1) #=>  "1 minute 1 second"
        #    format_duration(135.14) #=> "2 minutes 15.14 seconds"
        def format_duration(duration)
          if duration > 60
            minutes = duration.to_i / 60
            seconds = duration - minutes * 60

            "#{pluralize(minutes, 'minute')} #{pluralize(format_seconds(seconds), 'second')}"
          else
            pluralize(format_seconds(duration), 'second')
          end
        end

        # @api public
        #
        # Formats seconds to have 5 digits of precision with trailing zeros removed if the number
        # if less than 1 or with 2 digits of precision if the number is greater than zero.
        #
        # @param [Float] float
        # @return [String] formatted float
        #
        # @example
        #    format_seconds(0.000006) #=> "0.00001"
        #    format_seconds(0.020000) #=> "0.02"
        #    format_seconds(1.00000000001) #=> "1"
        #
        # The precision used is set in {Helpers::SUB_SECOND_PRECISION} and {Helpers::DEFAULT_PRECISION}.
        #
        # @see #strip_trailing_zeroes
        def format_seconds(float)
          precision ||= (float < 1) ? SUB_SECOND_PRECISION : DEFAULT_PRECISION
          formatted = sprintf("%.#{precision}f", float)
          strip_trailing_zeroes(formatted)
        end

        # @api public
        #
        # Remove trailing zeros from a string.
        #
        # @param [String] string string with trailing zeros
        # @return [String] string with trailing zeros removed
        def strip_trailing_zeroes(string)
          stripped = string.sub(/[^1-9]+$/, '')
          stripped.empty? ? "0" : stripped
        end

        # @api publix
        #
        # Pluralize a word based on a count.
        #
        # @param [Fixnum] count number of objects
        # @param [String] string word to be pluralized
        # @return [String] pluralized word
        def pluralize(count, string)
          "#{count} #{string}#{'s' unless count.to_f == 1}"
        end
      end

    end
  end
end
