class String
  def is_number?
    to_i.to_s.eql?(self)
  end

  def is_float?
    to_f.to_s.eql?(self)
  end
end