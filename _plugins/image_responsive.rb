module Jekyll

  # Responsive Image for Bootstrap
  # See http://getbootstrap.com/css/#overview-responsive-images
  #     http://getbootstrap.com/css/#images
  #
  # Usage:
  #
  #   e.g. Plain style
  #   {% image path/to/image.jpg [alt:"responsive"] %}
  #
  #   e.g. Rounded style
  #   {% image path/to/image.jpg style:rounded [alt:"responsive"] %}
  #    
  #   e.g. Circle style
  #   {% image path/to/image.jpg style:circle [alt:"responsive"] %}
  #    
  #   e.g. Thumbnail style
  #   {% image path/to/image.jpg style:thumbnail [alt:"responsive"] %}
  #

  class ResponsiveImage < Liquid::Tag
    Syntax = /(#{Liquid::QuotedFragment}+)/o

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax

        @src = $1
        @attributes = {}

        markup.scan(Liquid::TagAttributes) do |key, value|
          @attributes[key] = value
        end

      else
        raise "Unknown syntax error."
      end
    end

    def render(context)

      style = @attributes['style']
      style = "" if style == nil
      case style
      when "rounded" then
        style = "img-rounded"
      when "circle" then
        style = "img-circle"
      when "thumbnail" then
        style = "img-thumbnail"
      else
        style = ""
      end

      alt = @attributes['alt']
      alt = "" if alt == nil

      "<img src=\"#{@src}\" alt=\"#{alt}\" class=\"img-responsive #{style}\">"

    end

  end
end

Liquid::Template.register_tag('image', Jekyll::ResponsiveImage)
