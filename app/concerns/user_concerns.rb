module UserConcerns
  def first_name
    name.split(' ', 2).first
  end
  
  def last_name
    name.split(' ', 2).last
  end
end