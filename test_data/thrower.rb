class Thrower
  def raise_now
    raise Exception.new
  end

  def raise_in_call
    raise_now
  end
end
