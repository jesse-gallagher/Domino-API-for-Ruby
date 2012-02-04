module Domino
	class View < Base
		def initialize(handle, noteid)
			@handle = handle
			@noteid = noteid
			
			@collection_data = false
		end
		
		def collation
			coll_num = FFI::MemoryPointer.new(:uint16)
			result = API.NIFGetCollation(@handle, coll_num)
			raise NotesException.new(result) if result != 0
			coll_num.read_uint16
		end
		def collation=(coll_num)
			result = API.NIFSetCollation(@handle, coll_num)
			raise NotesException.new(result) if result != 0
		end
		
		def update
			result = API.NIFUpdateCollection(@handle)
			raise NotesException.new(result) if result != 0
		end
		
		def doc_count
			fetch_collection_data! if not @collection_data
			@collection_data[:DocCount]
		end
		def entry_size
			fetch_collection_data! if not @collection_data
			@collection_data[:DocTotalSize]
		end
		
		def each_noteid
			position = API::COLLECTIONPOSITION.new
			position[:Level] = 0
			position[:Tumbler][0] = 0
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
		def entries
			position = API::COLLECTIONPOSITION.new
			position[:Level] = 0
			position[:Tumbler][0] = 0
			hBuffer = FFI::MemoryPointer.new(:int)
			entries_found = FFI::MemoryPointer.new(:int)
			signal_flags = FFI::MemoryPointer.new(:int)
			notes_found = 0
			stats = nil
			entries_list = []
			begin
				result = API.NIFReadEntries(
					@handle,
					position.to_ptr,
					API::NAVIGATE_NEXT,
					1,
					API::NAVIGATE_NEXT,
					0xFFFFFFFF,
						API::READ_MASK_COLLECTIONSTATS +
						API::READ_MASK_NOTEID + API::READ_MASK_NOTEUNID + API::READ_MASK_NOTECLASS +
						API::READ_MASK_INDEXSIBLINGS + API::READ_MASK_INDEXCHILDREN + API::READ_MASK_INDEXDESCENDANTS +
						API::READ_MASK_INDEXANYUNREAD + API::READ_MASK_INDENTLEVELS + API::READ_MASK_INDEXUNREAD +
						API::READ_MASK_INDEXPOSITION +
						API::READ_MASK_SUMMARYVALUES,
					hBuffer,
					nil,
					nil,
					entries_found,
					signal_flags
				)
				if result != 0
					raise NotesException.new(result)
				end
				if hBuffer.read_int == API::NULLHANDLE
					raise Exception.new("Empty buffer returned by NIFReadEntries.")
				end
				info_ptr = API.OSLockObject(hBuffer.read_int)
				
				stats = API::COLLECTIONSTATS.new(info_ptr)
				info_ptr += API::COLLECTIONSTATS.size
				
				# loop through all read entries
				1.upto(entries_found.read_int) do
					entry = ViewEntry.new
					notes_found += 1
					entry.index = notes_found
					
					# Read in the NOTEID and advance past it
					entry.noteid = info_ptr.read_int
					info_ptr += 4
					
					# Read in the UNIVERSALNOTEID and advance past it
					entry.unid = API::UNIVERSALNOTEID.new(info_ptr)
					info_ptr += API::UNIVERSALNOTEID.size
					
					# Note class, a WORD
					entry.note_class = info_ptr.read_uint16
					info_ptr += 2
					
					# Siblings, a DWORD
					entry.sibling_count = info_ptr.read_uint32
					info_ptr += 4
					
					# Children, a DWORD
					entry.child_count = info_ptr.read_uint32
					info_ptr += 4
					
					# Descendants, a DWORD
					entry.descendant_count = 4
					info_ptr += 4
					
					# Any Unread, a WORD
					entry.any_unread = info_ptr.read_uint16 == 1
					info_ptr += 2
					
					# Indent level, a WORD
					entry.indent_level = info_ptr.read_uint16
					info_ptr += 2
					
					# Unread, a WORD
					entry.unread = info_ptr.read_uint16 == 1
					info_ptr += 2
					
					# Collection Position, which is truncated (the Tumbler array at the end is only as large as need be)
					entry.position = API.read_truncated_collectionposition(info_ptr)
					info_ptr += API.read_truncated_collectionposition_size(info_ptr)
					
					# now fetch the ITEM_VALUE_TABLE and advance to the next entry
					table = API::ITEM_VALUE_TABLE.new(info_ptr)
					
					# add the size of ITEM_VALUE_TABLE to the pointer to get to the data value lengths
					summary_ptr = info_ptr + API::ITEM_VALUE_TABLE.size
					# read in an array of WORD values of length table[:Items] to get the sizes of each summary data entry
					# then increment the pointer appropriately
					size_list = summary_ptr.read_array_of_type(:uint16, :read_uint16, table[:Items])
					summary_ptr += 2 * table[:Items]
					
					# the values in size_list are 0 if the value is empty and 2 + the size of the value otherwise
					# this 2 comes from the size of the data type, which is for some reason not accounted for
					#    when the value is empty
					
					column_values = []
					0.upto(table[:Items]-1) do |i|
						if(size_list[i] == 0)
							column_values << nil
							summary_ptr += 2
						else
							item_type = summary_ptr.read_uint16
							# read in usable item types
							case item_type
							when API::TYPE_TEXT
								column_values << summary_ptr.get_bytes(2, size_list[i]-2)
							when API::TYPE_TEXT_LIST
								column_values << API.read_text_list(summary_ptr + 2)
							when API::TYPE_NUMBER
								# numbers are doubles
								column_values << summary_ptr.get_double(2)
							when API::TYPE_NUMBER_RANGE
								column_values << API.read_number_range(summary_ptr + 2)
							when API::TYPE_TIME
								column_values << API.read_time(summary_ptr + 2)
							when API::TYPE_TIME_RANGE
								column_values << API.read_time_range(summary_ptr + 2)
							else
								puts "Couldn't read item type #{item_type}"
								column_values << nil
							end

							summary_ptr += size_list[i]
						end
					end
					entry.column_values = column_values
					
					entries_list << entry.freeze
					
					info_ptr += table[:Length]
				end
				
				API.OSUnlockObject hBuffer.read_int
				API.OSMemFree hBuffer.read_int
			end while signal_flags.read_int & API::SIGNAL_MORE_TO_DO != 0
			
			ViewEntryCollection.new(stats, entries_list)
		end
		
		def close
			API.NIFCloseCollection @handle
		end
		
		private
		def fetch_collection_data!
			data_handle = FFI::MemoryPointer.new(:int)
			result = API.NIFGetCollectionData(@handle, data_handle)
			raise NotesException.new(result) if result != 0
			data_ptr = API.OSLockObject(data_handle.read_int)
			@collection_data = API::COLLECTIONDATA.new(data_ptr)
			API.OSUnlockObject(data_handle.read_int)
		end
	end
end