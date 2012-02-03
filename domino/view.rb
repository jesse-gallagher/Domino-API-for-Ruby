module Domino
	class View < Base
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
				result = API.NIFReadEntries(@handle, position.to_ptr, API::NAVIGATE_NEXT, 1, API::NAVIGATE_NEXT, 0xFFFFFFFF, API::READ_MASK_NOTEID, hBuffer, nil, nil, entries_found, signal_flags)
				if result != 0
					raise NotesException.new(result)
				end
				if hBuffer.read_int == API::NULLHANDLE
					raise Exception.new("Empty buffer returned by NIFReadEntries.")
				end
				idlist_ptr = API.OSLockObject(hBuffer.read_int)
				idlist = idlist_ptr.read_array_of_type(:int, :read_int, entries_found.read_int)
				idlist.each do |id|
					yield id
				end
				API.OSUnlockObject hBuffer.read_int
				API.OSMemFree hBuffer.read_int
			end while signal_flags.read_int & API::SIGNAL_MORE_TO_DO != 0
		end
		def test_entries
			position = API::COLLECTIONPOSITION.new
			position[:level] = 0
			position[:tumbler][0] = 0
			hBuffer = FFI::MemoryPointer.new(:int)
			entries_found = FFI::MemoryPointer.new(:int)
			signal_flags = FFI::MemoryPointer.new(:int)
			notes_found = 0
			begin
				result = API.NIFReadEntries(@handle, position.to_ptr, API::NAVIGATE_NEXT, 1, API::NAVIGATE_NEXT, 0xFFFFFFFF, API::READ_MASK_NOTEID + API::READ_MASK_SUMMARYVALUES, hBuffer, nil, nil, entries_found, signal_flags)
				if result != 0
					raise NotesException.new(result)
				end
				if hBuffer.read_int == API::NULLHANDLE
					raise Exception.new("Empty buffer returned by NIFReadEntries.")
				end
				info_ptr = API.OSLockObject(hBuffer.read_int)
				
				# loop through all read entries
				1.upto(entries_found.read_int) do
					puts "new entry"
					# fetch the note ID from the first part of the info, then advance 32 bits
					noteid = info_ptr.read_int
					info_ptr += 4
					
					# now fetch the ITEM_VALUE_TABLE
					table = API::ITEM_VALUE_TABLE.new(info_ptr)
					
					# add two bytes (the size of ITEM_VALUE_TABLE) to the pointer to get to the data value lengths
					summary_ptr = info_ptr + 4
					# read in an array of WORD values of length table[:items] to get the sizes of each summary data entry
					# then increment the pointer appropriately
					size_list = []
					size_ptr = summary_ptr
					1.upto(table[:items]) do |i|
						size_list << size_ptr.read_ushort
						size_ptr += 2
					end
					
					summary_ptr = size_ptr
					items = []
					0.upto(table[:items]-1) do |i|
						if(size_list[i] == 0)
							puts "#{i}: Empty"
							summary_ptr += 1
						else
							item_type = summary_ptr.read_ushort
							# read in usable item types
							case item_type
							when API::TYPE_TEXT
								puts "#{i}: Text: #{summary_ptr.get_bytes(2, size_list[i])}"
							else
								puts "#{i}: Couldn't read item type #{item_type}"
							end

							summary_ptr += size_list[i]
						end
					end
					
					
					# the table length includes the size of the ITEM_VALUE_TABLE, so no need to add 2 here
					info_ptr += table[:length]
				end
				
				API.OSUnlockObject hBuffer.read_int
				API.OSMemFree hBuffer.read_int
			end while signal_flags.read_int & API::SIGNAL_MORE_TO_DO != 0
		end
		
		def close
			API.NIFCloseCollection @handle
		end
	end
end