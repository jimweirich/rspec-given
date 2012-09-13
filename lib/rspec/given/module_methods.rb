module RSpec
  module Given
    def self.html_format_disabled
      @_rg_html_format_disabled
    end

    def self.html_format_disabled=(value)
      @_rg_html_format_disabled = value
    end

    def self.detect_formatters(c)
      format_active = c.formatters.any? { |f| f.class.name !~ /ProgressFormatter/ }
      RSpec::Given.html_format_disabled = ! format_active
    end
  end
end
