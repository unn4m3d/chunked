require "./chunk_info"
require "./base"
module Chunked
  class Reader(T) < Base(T)
    def open_chunk
      cdata = ChunkInfo(T,T).read(@io)
      pos = offset
      @start_offsets << pos
      @end_offsets << pos + cdata.size
      cdata
    end

    def close_chunk
      sp = @start_offsets.pop
      ep = @end_offsets.pop
      pos = offset
      unless sp <= pos && ep >= pos
        @start_offsets << sp
        @end_offsets << ep
        raise "Current position [#{pos}] is outside of chunk [#{sp}...#{ep}]"
      end
      self.offset = ep
    end

    def current_chunk
      raise "Chunk is not read!" if @start_offsets.empty?
      pos = offset
      self.offset = @start_offsets.last
      slice = Bytes.new(@end_offsets.last - @start_offsets.last)
      @io.read(slice)
      slice
    end

    def find_next(idx : T)
      begin
        while true
          cdata = open_chunk
          raise "Cannot find chunk #{idx.to_s(16)}" if cdata.index == 0 && cdata.size == 0
          return cdata if cdata.index == idx
          close_chunk
        end
      rescue e : IO::EOFError
        raise "Cannot find chunk #{idx.to_s(16)}"
      end
    end

    def current_chunk_data(cdata : ChunkInfo(T,T))
      return {info: cdata, offset: offset}
    end
  end
end
