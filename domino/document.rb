module Domino
	class Document
		attr_reader :handle, :parent, :noteid, :universalid, :modified, :note_class, :sequence, :sequence_time
		
		def initialize(parent, handle, noteid, originatorid, modified, note_class)
			@parent = parent
			@handle = handle
			@noteid = noteid
			@universalid = originatorid.universalid
			@modified = modified.to_t
			@note_class = note_class
			@sequence = originatorid.sequence
			@sequence_time = originatorid.sequence_time.to_t
		end
		
		# TODO: make this work
		def convert_to_mime!
			if !@converted_to_mime
				#cc_handle = FFI::MemoryPointer.new(API.find_type(:CCHANDLE))
				#result = API.MMCreateConvControls(cc_handle)
				#raise NotesException.new(result) if result > 0
				result = API.MIMEConvertCDParts(@handle, canonical? ? 1 : 0, 1, nil)
				raise NotesException.new(result) if result > 0
				#result = API.MMDestroyConvControls(cc_handle)
				#raise NotesException.new(result) if result > 0
			end
			nil
		end
		
		def read_only?; get_note_info(API::F_NOTE_FLAGS) & API::NOTE_FLAG_READONLY > 0; end
		def abstracted?; get_note_info(API::F_NOTE_FLAGS) & API::NOTE_FLAG_ABSTRACTED > 0; end
		def incremental?; get_note_info(API::F_NOTE_FLAGS) & API::NOTE_FLAG_INCREMENTAL > 0; end
		def linked?; get_note_info(API::F_NOTE_FLAGS) & API::NOTE_FLAG_LINKED > 0; end
		def incremental_full?; get_note_info(API::F_NOTE_FLAGS) & API::NOTE_FLAG_INCREMENTAL_FULL > 0; end
		def canonical?; get_note_info(API::F_NOTE_FLAGS) & API::NOTE_FLAG_CANONICAL > 0; end
		
		def accessed; get_note_info(API::F_NOTE_ACCESSED).to_t; end
		
		# These methods only work on databases that track heirarchy info
		def parent_id; get_note_info(API::F_NOTE_PARENT_NOTEID); end
		def response_count; get_note_info(API::F_NOTE_RESPONSE_COUNT); end
		# TODO: implement #responses
		
		def added; get_note_info(API::F_NOTE_ADDED_TO_FILE).to_t; end
		def obj_store; get_note_info(API::F_NOTE_OBJSTORE_DB); end
		
		def has_item?(item_name)
			result = API.NSFItemInfo(@handle, item_name, item_name.size, nil, nil, nil, nil)
			result == 0
		end
		def [](item_name)
			type_ptr = FFI::MemoryPointer.new(API.find_type(:WORD))
			blockid_ptr = FFI::MemoryPointer.new(API::BLOCKID)
			length_ptr = FFI::MemoryPointer.new(API.find_type(:DWORD))
			
			result = API.NSFItemInfo(@handle, item_name, item_name.size, nil, type_ptr, blockid_ptr, length_ptr)
			raise NotesException.new(result) if result != 0
			
			type = type_ptr.read_uint16
			blockid = API::BLOCKID.new(blockid_ptr)
			length = length_ptr.read_uint32
			
			# Blocks consist of an overall pool and an individual block
			# locking a block involves locking the pool and incrementing to the block
			block_ptr = API.OSLockObject(blockid[:pool]) + blockid[:block]
			if type == API::TYPE_COMPOSITE
				result_handle_ptr = FFI::MemoryPointer.new(API.find_type(:DHANDLE))
				result_length_ptr = FFI::MemoryPointer.new(API.find_type(:DWORD))
				result = API.ConvertItemToText(blockid, length, "", 0xFFFF, result_handle_ptr, result_length_ptr, 0)
				raise NotesException.new(result) if result != 0
				
				result_handle = result_handle_ptr.read_uint32
				result_ptr = API.OSLockObject(result_handle)
				value = result_ptr.get_bytes(0, result_length_ptr.read_uint32)
				API.OSUnlockObject(result_handle)
				API.OSMemFree(result_handle)
			else
				value = API.read_item_value(block_ptr, type, length, @handle)
			end
			# unlocking a block only needs the pool ID
			API.OSUnlockObject(blockid[:pool])
			
			value
		end
		def each_item
			process_item = Proc.new do |spare, flags, name, name_length, value, value_length, routine_param|
				item_name = name.read_bytes(name_length)
				
				# So... can I just read the item value from these parameters?
				type = value.read_uint16
				if type == API::TYPE_COMPOSITE
					
				else
					value = API.read_item_value(value, type, value_length, @handle)
					yield Item.new(item_name, type, value)
				end
			end
			result = API.NSFItemScan(@handle, process_item, nil)
			raise NotesException.new(result) if result != 0
		end
		
		def close
			API::NSFNoteClose @handle
		end
		
		private
		def get_note_info(member)
			case member
			when API::F_NOTE_DB
				dbhandle = FFI::MemoryPointer.new(API.find_type(:DBHANDLE))
				API.NSFNoteGetInfo(@handle, member, dbhandle)
				return dbhandle.read_uint32
			when API::F_NOTE_ID
				noteid = FFI::MemoryPointer.new(API.find_type(:NOTEID))
				API.NSFNoteGetInfo(@handle, member, noteid)
				return noteid.read_uint32
			when API::F_NOTE_OID
				oid = FFI::MemoryPointer.new(API.ORIGINATORID)
				API.NSFNoteGetInfo(@handle, member, oid)
				return API::OriginatorID.new(oid)
			when API::F_NOTE_CLASS
				note_class = FFI::MemoryPointer.new(API.find_type(:WORD))
				API.NSFNoteGetInfo(@handle, member, note_class)
				return note_class.read_uint16
			when API::F_NOTE_MODIFIED
				modified = FFI::MemoryPointer.new(API::TIMEDATE)
				API.NSFNoteGetInfo(@handle, member, modified)
				return API::TIMEDATE.new(modified)
			when API::F_NOTE_PRIVILEGES
				priv = FFI::MemoryPointer.new(API.find_type(:WORD))
				API.NSFNoteGetInfo(@handle, member, priv)
				return priv.read_uint16
			when API::F_NOTE_FLAGS
				flags = FFI::MemoryPointer.new(API.find_type(:WORD))
				API.NSFNoteGetInfo(@handle, member, flags)
				return flags.read_uint16
			when API::F_NOTE_ACCESSED
				accessed = FFI::MemoryPointer.new(API::TIMEDATE)
				API.NSFNoteGetInfo(@handle, member, accessed)
				return API::TIMEDATE.new(accessed)
			when API::F_NOTE_PARENT_NOTEID
				noteid = FFI::MemoryPointer.new(API.find_type(:NOTEID))
				API.NSFNoteGetInfo(@handle, member, noteid)
				return noteid.read_uint32
			when API::F_NOTE_RESPONSE_COUNT
				response_count = FFI::MemoryPointer.new(API.find_type(:DWORD))
				API.NSFNoteGetInfo(@handle, member, response_count)
				return response_count.read_uint32
			when API::F_NOTE_RESPONSES
				# TODO: implement this - it'll have to be an IDTable
			when API::F_NOTE_ADDED_TO_FILE
				added = FFI::MemoryPointer.new(API::TIMEDATE)
				API.NSFNoteGetInfo(@handle, member, added)
				return API::TIMEDATE.new(added)
			when API::F_NOTE_OBJSTORE_DB
				dbhandle_ptr = FFI::MemoryPointer.new(API.find_type(:DBHANDLE))
				API.NSFNoteGetInfo(@handle, member, dbhandle)
				dbhandle = dbhandle_ptr.read_uint32
				if dbhandle == 0
					return nil
				else
					return Database.new(dbhandle.read_uint32)
				end
			end
		end
	end
end