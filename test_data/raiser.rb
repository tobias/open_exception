require File.expand_path(File.dirname(__FILE__) + '/../lib/open_exception')

class Raiser
  def raise_now
    raise Exception.new
  end

  def raise_first_level
    raise_now
  end

  def raise_second_level
    raise_first_level
  end

  def file
    __FILE__
  end
  
  def self.raise_and_open(options = {})
    Raiser.new.raise_now
  rescue Exception
    OpenException.open($!, options)
  end
end
