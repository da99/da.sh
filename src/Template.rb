# frozen_string_literal: true

# Uses templates/ dir.
class Template
  DIR = File.join File.dirname(File.dirname(__FILE__)), 'templates'
  class << self
    def compile(name, pairs)
      template_content = File.read(File.join(Template::DIR, name))
      pairs.each_pair do |k, v|
        template_content = template_content.gsub("$#{k}", v)
      end
      template_content
    end
  end # class << self
end # class Template
