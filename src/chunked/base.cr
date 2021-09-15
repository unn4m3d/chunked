require "./chunk_info"
module Chunked
  class Base(T)
    @io : IO::Positional

    def initialize(@io, @debug : Bool = false)
      @start_offsets = Array(T).new
      @end_offsets = Array(T).new
    end

    def debug(*str)
      puts *str if @debug
    end

    def close
      debug "Closing #{@io.closed?}"
      @io.close unless @io.closed?
    end

    def finalize
      debug "Finalizing"
      close
    end

    def offset
      T.new(@io.pos)
    end

    def offset=(t : T)
      @io.pos = t
    end
  end
end
