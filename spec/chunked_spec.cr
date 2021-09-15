require "./spec_helper"

describe Chunked::Writer do


  it "writes data" do
    writer = Writer.new(tmp_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    writer.chunk 0i64 do |w|
      w.write_byte 1u8
      w.write_byte 2u8
      w.write_byte 3u8
    end

    writer.chunk 1i64 do |w|
      w.write_byte 4u8
      w.write_byte 5u8
      w.write_byte 6u8
    end

    writer.close

    tmp_io.to_slice.to_a.should eq([
      0u8,0u8,0u8,0u8,0u8,0u8,0u8,0u8, # INDEX = 0x0000000000000000
      3u8,0u8,0u8,0u8,0u8,0u8,0u8,0u8, # SIZE = 0x0000000000000003
      1u8,2u8,3u8,     # 3 bytes of data

      1u8,0u8,0u8,0u8,0u8,0u8,0u8,0u8, # INDEX = 0x0000000000000001
      3u8,0u8,0u8,0u8,0u8,0u8,0u8,0u8, # SIZE = 0x0000000000000003
      4u8,5u8,6u8
    ])
  end

  it "writes data using other integral types" do
    writer = Writer32.new(tmp32_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    writer.chunk 0u32 do |w|
      w.write_byte 1u8
      w.write_byte 2u8
      w.write_byte 3u8
    end

    writer.chunk 1u32 do |w|
      w.write_byte 4u8
      w.write_byte 5u8
      w.write_byte 6u8
    end

    writer.close

    tmp32_io.to_slice.to_a.should eq([
      0u8,0u8,0u8,0u8, # INDEX = 0x00000000
      3u8,0u8,0u8,0u8, # SIZE = 0x00000003
      1u8,2u8,3u8,     # 3 bytes of data

      1u8,0u8,0u8,0u8, # INDEX = 0x00000001
      3u8,0u8,0u8,0u8, # SIZE = 0x00000003
      4u8,5u8,6u8
    ])
  end

end

describe Chunked::Reader do
  it "reads data" do
    tmp_io.rewind
    reader = Reader.new(tmp_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    cdata = reader.open_chunk
    cdata.index.should eq(0i64)
    cdata.size.should eq(3i64)
    reader.current_chunk.to_a.should eq([1u8,2u8,3u8])
    reader.close_chunk
    cdata = reader.open_chunk
    cdata.index.should eq(1i64)
    cdata.size.should eq(3i64)
    reader.current_chunk.to_a.should eq([4u8,5u8,6u8])
    reader.close
  end

  it "reads data using other integral types" do
    tmp32_io.rewind
    reader = Reader32.new(tmp32_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    cdata = reader.open_chunk
    cdata.index.should eq(0i32)
    cdata.size.should eq(3i32)
    reader.current_chunk.to_a.should eq([1u8,2u8,3u8])
    reader.close_chunk
    cdata = reader.open_chunk
    cdata.index.should eq(1i32)
    cdata.size.should eq(3i32)
    reader.current_chunk.to_a.should eq([4u8,5u8,6u8])
    reader.close
  end

  it "reads chunks with blocks" do
    tmp32_io.rewind
    reader = Reader32.new(tmp32_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    reader.chunk do |io|
      io.gets_to_end.bytes.should eq([1u8,2u8,3u8])
    end
    reader.chunk do |io|
      io.gets_to_end.bytes.should eq([4u8,5u8,6u8])
    end
    reader.close
  end

  it "iterates through chunks" do
    tmp_io.rewind
    reader = Reader.new(tmp_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    reader.each_chunk do |io, chk|
      io.size.should eq(chk.size)
      io.size.should eq(3i64)
      io.gets_to_end.bytes.should eq([1u8,2u8,3u8].map{ |x| x + 3*chk.index })
    end
  end
end

describe Chunked::IndexedReader do
  it "indexes chunks" do
    tmp_io.rewind
    reader = IReader.new(tmp_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    reader.index_chunks!
    reader.info(0i64)[:size].should eq(3)
    reader.info(1i64)[:size].should eq(3)
    reader.info(0i64)[:index].should eq(0)
    reader[0i64].gets_to_end.bytes.should eq([1u8,2u8,3u8])
  end

  it "indexes chunks using other integral types" do
    tmp32_io.rewind
    reader = IReader32.new(tmp32_io, debug: ENV.has_key?("CHUNKED_DEBUG"))
    reader.index_chunks!
    reader.info(0i32)[:size].should eq(3)
    reader.info(1i32)[:size].should eq(3)
    reader.info(0i32)[:index].should eq(0)
    reader[0i32].gets_to_end.bytes.should eq([1u8,2u8,3u8])
  end

end
