# Encoding: utf-8

module Formulas
  class Home < Formula

    HEADING = { css: '.heading' }

    def initialize(driver)
      super
      visit '/'
      verify_page
    end

    def heading
      text_of HEADING
    end

    private

      def verify_page
        wait_for(6) { displayed? HEADING }
        title.should =~ /The Internet/
      end

  end # SignIn
end # Formulas
