module ApplicationHelper
  #this isn't used anywhere anymore
  def hash_to_haml(hash, indentation_level = 0)
    indent = '  '
    result = ["#{indent * indentation_level}%ul"]
    hash.each do |key, value|
      result << "#{indent * indentation_level}%li #{key}"
      result << hash_to_haml(value, indentation_level + 2) if value.is_a?(Hash)
    end
    result.join("\n")
  end

  def newline_to_br(string)
    string.sub(/\n/, "<br />\n")
  end



end
