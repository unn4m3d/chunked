module IO::Positional
  abstract def pos
  abstract def pos=(t)
end

class IO::FileDescriptor
  include Positional
end
