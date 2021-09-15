require "spec"
require "../src/chunked"

alias Writer = Chunked::Writer(Int64)
alias Writer32 = Chunked::Writer(UInt32)
alias Reader = Chunked::Reader(Int64)
alias Reader32 = Chunked::Reader(Int32)
alias IReader = Chunked::IndexedReader(Int64)
alias IReader32 = Chunked::IndexedReader(Int32)

class TmpIO
    @@tmp_io = IO::Memory.new
    @@tmp32_io = IO::Memory.new
    class_getter tmp_io, tmp32_io
end

delegate tmp32_io, tmp_io, to: TmpIO

class IO::Memory
    def close
    end
end
