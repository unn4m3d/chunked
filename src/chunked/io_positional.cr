module IO::Positional
  abstract def pos
  abstract def pos=(t)
end

class IO::FileDescriptor
  include Positional
end

class IO::Memory
  include Positional

  def path
    "#<#{buffer.address.to_s(16)}>"
  end
end
