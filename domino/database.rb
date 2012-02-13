module Domino
	class Database < Base
		attr_reader :handle
		
		def initialize(handle)
			@handle = handle
		end
		
		def title
			if @dbinfo == nil
				dbinfo = FFI::MemoryPointer.from_string(" " * 128)
				result = API.NSFDbInfoGet(@handle, dbinfo)
				if result != 0
					raise NotesException.new(result)
				end
				@dbinfo = dbinfo.read_string
				@title = @dbinfo.split("\n").first
			end
			@title	
		end
		
		def filepath
			fetch_filepath if @filepath == nil
			@filepath
		end
		def server
			fetch_filepath if @server == nil
			@server
		end

		# TODO: fix the segfault this causes
=begin
		def get_user_info(username)
			names_list_handle = FFI::MemoryPointer.new(:int)
			result = API.NSFNamesList(username, 0, names_list_handle)
			if result == 0
				API.OSLockObject names_list_handle.read_int
				# now get the info from the ACL, if that's how it works
				result = API.NSFDbGetNamesList(@handle, 0, names_list_handle)
				if result == 0
					# fetched names list
					API::NameInfo.new(names_list_handle.read_int)
				else
					raise NotesException.raise(result)
				end
				
			else
				raise NotesException.raise(result)
			end
		end
=end
    
		def get_view(viewname)
			view_noteid = FFI::MemoryPointer.new(:int)
			result = API.find_view(@handle, viewname.to_s, view_noteid)
			if result == 0
				handle = FFI::MemoryPointer.new(:int)
				result = API.NIFOpenCollection(@handle, @handle, view_noteid.read_int, 0, API::NULLHANDLE, handle, nil, nil, nil, nil)
				if result != 0
					raise NotesException.new(result)
				end
				View.new(self, handle.read_int, view_noteid.read_int)
			else
				raise NotesException.new(result)
			end
		end
		def get_view_as_user(viewname, username)
			names_list = FFI::MemoryPointer.new(:int, API::NAMES_LIST.size + 100)
			result = API.NSFBuildNamesList(nil, 0, names_list)
			if result == 0
				names_list_obj = API::NAMES_LIST.new(API.OSLockObject(names_list.read_int))
				names_list_obj[:authenticated] = 0
				API.OSUnlockObject(names_list.read_int)
				view_noteid = FFI::MemoryPointer.new(:int)
				result = API.find_view(@handle, viewname.to_s, view_noteid)
				if result == 0
					handle = FFI::MemoryPointer.new(:int)
					result = API.NIFOpenCollectionWithUserNameList(@handle, @handle, view_noteid.read_int, 0, API::NULLHANDLE, handle, nil, nil, nil, nil, names_list.read_int)
					if result != 0
						raise NotesException.new(result)
					end
					View.new(self, handle.read_int)
				else
					raise NotesException.new(result)
				end
				
			else
				raise NotesException.new(result)
			end
		end
		
		def get_doc_by_id(noteid)
			modified_ptr = FFI::MemoryPointer.new(API::TIMEDATE)
			note_class_ptr = FFI::MemoryPointer.new(API.find_type(:WORD))
			originatorid_ptr = FFI::MemoryPointer.new(API::ORIGINATORID)
			
			# Get some header info
			result = API.NSFDbGetNoteInfo(@handle, noteid, originatorid_ptr, modified_ptr, note_class_ptr)
			raise NotesException.new(result) if result != 0
			
			originatorid = API::OriginatorID.new(originatorid_ptr)
			modified = API::TIMEDATE.new(modified_ptr)
			note_class = note_class_ptr.read_uint16
			
			# Open the note itself
			handle_ptr = FFI::MemoryPointer.new(API.find_type(:NOTEHANDLE))
			result = API.NSFNoteOpenExt(@handle, noteid, API::OPEN_RAW_MIME, handle_ptr)
			raise NotesException.new(result) if result != 0
			
			
			Document.new(self, handle_ptr.read_uint32, noteid, originatorid, modified, note_class)
		end
		def get_doc_by_unid(unid)
			if not unid.is_a?(API::UNIVERSALNOTEID)
				unid = API::UNIVERSALNOTEID.from_s(unid.to_s)
			end
			
			noteid_ptr = FFI::MemoryPointer.new(API.find_type(:NOTEID))
			originatorid_ptr = FFI::MemoryPointer.new(API::ORIGINATORID)
			modified_ptr = FFI::MemoryPointer.new(API::TIMEDATE)
			note_class_ptr = FFI::MemoryPointer.new(API.find_type(:WORD))
			# Get some header info
			result = API.NSFDbGetNoteInfoByUNID(@handle, unid.to_ptr, noteid_ptr, originatorid_ptr, modified_ptr, note_class_ptr)
			raise NotesException.new(result) if result != 0
			
			noteid = noteid_ptr.read_uint32
			originatorid = API::OriginatorID.new(originatorid_ptr)
			modified = API::TIMEDATE.new(modified_ptr)
			note_class = note_class_ptr.read_uint16
			
			# Open the note itself
			handle_ptr = FFI::MemoryPointer.new(API.find_type(:NOTEHANDLE))
			result = API.NSFNoteOpenExt(@handle, noteid, API::OPEN_RAW_MIME, handle_ptr)
			raise NotesException.new(result) if result != 0
			
			Document.new(self, handle_ptr.read_uint32, noteid, originatorid, modified, note_class)
		end
		
		def close
			API.NSFDbClose(@handle)
		end
		
		private
		def fetch_filepath
			canonical = FFI::MemoryPointer.from_string(" " * API::MAXPATH)
			expanded = FFI::MemoryPointer.from_string(" " * API::MAXPATH)
			result = API.NSFDbPathGet(@handle, canonical, expanded)
			if result != 0
				raise NotesException.new(result)
			end
			@canonical_filepath = canonical.read_string
			@expanded_filepath = expanded.read_string
			if @expanded_filepath["!!"]
				bits = @expanded_filepath.split("!!")
				@filepath = bits[0]
				@server = bits[1]
			else
				@filepath = @expanded_filepath
				@server = ""
			end
		end
	end
end