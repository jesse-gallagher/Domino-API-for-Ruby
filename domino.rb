require "rubygems"
require "ffi"

require "#{File.dirname(__FILE__)}/domino/base"
require "#{File.dirname(__FILE__)}/domino/api"
require "#{File.dirname(__FILE__)}/domino/session"
require "#{File.dirname(__FILE__)}/domino/database"
require "#{File.dirname(__FILE__)}/domino/viewentry"
require "#{File.dirname(__FILE__)}/domino/viewentrycollection"
require "#{File.dirname(__FILE__)}/domino/view"

module Domino
	NotesErrors = {
		273 => "Unable to access files directory",
		421 => "The NOTES.INI file cannot be found on the search path (PATH)",
		582 => "You are not authorized to perform that operation",
		781 => "You are not authorized to access the view",
		813 => "Collation number specified negative or greater than number of collations in view.",
		1543 => "Encountered zero length record.",
		2055 => "The server is not responding. The server may be down or you may be experiencing network problems. Contact your system administrator if this problem persists."
	}
	
	class NotesException < Exception
		def initialize(status)
			@error_code = status & API::ERR_MASK
		end
		def message
			API.error_string(@error_code)
			#puts @error_code
			#mess = FFI::MemoryPointer.new(512)
			#size = API.OSLoadString(API::NULLHANDLE, @error_code, mess, 512-1)
			#mess.read_bytes(size)
		end
	end
end