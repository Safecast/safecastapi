module UserConcerns
  def first_name
    name.split(' ', 2).first if name
  end

  def last_name
    name.split(' ', 2).last if name
  end
end
