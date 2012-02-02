module Domino
	class View
		def initialize(handle)
			@handle = handle
		end
		
		def each_noteid
			position = API::COLLECTIONPOSITION.new
			position[:level] = 0
			position[:tumbler][0] = 0
			hBuffer = FFI::MemoryPointer.new(:int)
			entries_found = FFI::MemoryPointer.new(:int)
			signal_flags = FFI::MemoryPointer.new(:int)
			notes_found = 0
			begin
				result = API.read_entries(@handle, position.to_ptr, API::NAVIGATE_NEXT, 1, API::NAVIGATE_NEXT, 0xFFFFFFFF, API::READ_MASK_NOTEID, hBuffer, nil, nil, entries_found, signal_flags)
				if result != 0
					raise NotesException.new(result)
				end
				if hBuffer.read_int == API::NULLHANDLE
					raise Exception.new("Empty buffer returned by NIFReadEntries.")
				end
				idlist_ptr = API.lock_object(hBuffer.read_int)
				idlist = idlist_ptr.read_array_of_type(:int, :read_int, entries_found.read_int)
				idlist.each do |id|
					yield id
				end
				API.unlock_object hBuffer.read_int
				API.mem_free hBuffer.read_int
			end while signal_flags.read_int & API::SIGNAL_MORE_TO_DO != 0
		end
		
		def close
			API.close_collection @handle
		end
	end
end