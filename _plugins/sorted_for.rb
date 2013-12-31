module Jekyll

  # Sorted for 
  #
  # Usage:
  #
  #   e.g. Tag size sorted for
  #   {% sorted_for tag in site.tags sort_by:size %}
  #
  #   e.g. Tag name sorted for
  #   {% sorted_for tag in site.tags sort_by:name %}
  #

  class SortedFor < Liquid::For
    def render(context)

      collections = context[@collection_name].dup
      return if collections.empty?

      sort_by = @attributes['sort_by'] 
      sort_by = "name" if sort_by == nil 

      sorted_collections = nil
      case sort_by
      when 'size'
        sorted_collections = collections.sort { | (k1, v1), (k2, v2) | v2.size <=> v1.size }  
      when 'name'
        sorted_collections = collections.sort { | (k1, v1), (k2, v2) | k1 <=> k2 }
      else
        sorted_collections = collections
      end

      original_name = @collection_name
      result = nil
      context.stack do 
        sorted_collection_name = "sorted_#{@collection_name}".sub('.', '_')  
        context[sorted_collection_name] = sorted_collections
        @collection_name = sorted_collection_name
        result = super
        @collection_name = original_name
      end
      result

    end

    def end_tag
      'endsorted_for'
    end

  end
end

Liquid::Template.register_tag('sorted_for', Jekyll::SortedFor)
