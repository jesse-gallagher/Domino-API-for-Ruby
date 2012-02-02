require "rubygems"
require "ffi"

require "./domino/api"
require "./domino/session"
require "./domino/database"
require "./domino/view"

NotesErrors = {
	273 => "Unable to access files directory",
	421 => "The NOTES.INI file cannot be found on the search path (PATH)",
  582 => "You are not authorized to perform that operation",
  781 => "You are not authorized to access the view",
	1543 => "Encountered zero length record.",
	2055 => "The server is not responding. The server may be down or you may be experiencing network problems. Contact your system administrator if this problem persists."
}

module Domino
	class NotesException < Exception
		def initialize(error)
			@error_code = error
		end
		def message
			API.error_string(@error_code)
		end
	end
end



def string_array_to_inoutptr(ary)
	ptrs = ary.map { |a| FFI::MemoryPointer.from_string(a) }
	block = FFI::MemoryPointer.new(:pointer, ptrs.length)
	block.write_array_of_pointer ptrs
	#argv = FFI::MemoryPointer.new(:pointer)
	#argv.write_pointer block
	#argv
	block
end
def int_to_inoutptr(val)
	ptr = FFI::MemoryPointer.new(:int)
	ptr.write_int val
	ptr
end