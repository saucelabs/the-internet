# Encoding: utf-8

module Formulas
  class Upload < Formula

    FILE_UPLOAD_FORM = { id: 'file-upload' }

    def initialize(driver)
      super
      visit '/upload'
    end

    def file(filename)
      wait_for { displayed? FILE_UPLOAD_FORM }
      type FILE_UPLOAD_FORM, filename
      submit FILE_UPLOAD_FORM
    end

    def uploaded_file_attribute
      attribute_for({css: 'img'}, 'src')
    end

  end
end
