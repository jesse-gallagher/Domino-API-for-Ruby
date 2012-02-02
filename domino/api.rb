module Domino
	module API
		NULLHANDLE = 0
		MAXUSERNAME = 256
		NAMES_LIST_AUTHENTICATED = 0x0001
		NAMES_LIST_PASSWORD_AUTHENTICATED = 0x0002
		NAMES_LIST_FULL_ADMIN_ACCESS = 0x0004
		
		extend FFI::Library
		ffi_lib "libnotes"
		
		# general and memory functions
		attach_function :lock_object, "OSLockObject", [:int], :pointer
		attach_function :unlock_object, "OSUnlockObject", [:int], :bool
		attach_function :mem_free, "OSMemFree", [:int], :int
		
		attach_function :build_names_list, "NSFBuildNamesList", [:string, :int, :pointer], :int
		attach_function :user_info, "SECKFMUserInfo", [:int, :pointer, :pointer], :int

		# session management functions
		attach_function :init_extended, "NotesInitExtended", [:int, :pointer], :int
		attach_function :init_ini, "NotesInitIni", [:string], :int
		attach_function :term, "NotesTerm", [], :void

		def self.err(error)
			error & 0x3fff
		end
		def self.error_string(error)
			NotesErrors[error] ? "#{NotesErrors[error]} (#{error})" : error.to_s
		end
		
		# utility functions
		attach_function :load_string, "OSLoadString", [:long, :int, :pointer, :int], :int
		attach_function :construct_path, "OSPathNetConstruct", [:string, :string, :string, :pointer], :int

		# server management functions
		attach_function :ping_server, "NSPingServer", [:string, :pointer, :pointer], :int

		# database functions
		MAXPATH = 256
		NOTE_CLASS_VIEW = 0x0008
		DFLAGPAT_VIEWS_AND_FOLDERS = "-G40n^"
		attach_function :db_open, "NSFDbOpen", [:string, :pointer], :int
		attach_function :db_open_extended, "NSFDbOpenExtended", [:string, :int8, :int, :pointer, :pointer, :pointer, :pointer], :int
		attach_function :db_close, "NSFDbClose", [:int], :void
		attach_function :db_info, "NSFDbInfoGet", [:int, :pointer], :int
		attach_function "NSFDbPathGet", [:int, :pointer, :pointer], :int
		attach_function :find_design_note_ext, :NIFFindDesignNoteExt, [:int, :string, :int, :string, :pointer, :int], :int
    attach_function :get_names_list, "NSFDbGetNamesList", [:int, :int, :pointer], :int
    
		# view/folder functions
		MAXTUMBLERLEVELS = 32
		MAXTUMBLERLEVELS_V2 = 8
		NOTEID_CATEGORY = 0x80000000
		
		# view read masks
		READ_MASK_NOTEID = 				0x00000001
		READ_MASK_NOTEUNID = 			0x00000002
		READ_MASK_NOTECLASS = 			0x00000004
		READ_MASK_INDEXSIBLINGS = 		0x00000008
		READ_MASK_INDEXCHILDREN = 		0x00000010
		READ_MASK_INDEXDESCENDANTS =	0x00000020
		READ_MASK_INDEXANYUNREAD =		0x00000040
		READ_MASK_INDENTLEVELS =		0x00000080
		READ_MASK_SCORE	=				0x00000200
		READ_MASK_INDEXUNREAD =			0x00000400
		READ_MASK_COLLECTIONSTATS = 	0x00000100
		READ_MASK_INDEXPOSITION = 		0x00004000
		READ_MASK_SUMMARYVALUES = 		0x00002000
		READ_MASK_SUMMARY = 			0x00008000
		
		# view navigator options
		NAVIGATE_CURRENT = 0
		NAVIGATE_NEXT = 1
		NAVIGATE_PARENT = 3
		NAVIGATE_CHILD = 4
		NAVIGATE_FIRST_PEER = 7
		NAVIGATE_LAST_PEER = 8
		NAVIGATE_CURRENT_MAIN = 11
		NAVIGATE_ALL_DESCENDANTS = 17
		NAVIGATE_CURRENT_HIT = 31
		NAVIGATE_MASK =			0x007F
		NAVIGATE_MINLEVEL =		0x0100
		NAVIGATE_MAXLEVEL = 	0x0200
		NAVIGATE_CONTINUE = 	0x8000
		
		# view signals
		SIGNAL_MORE_TO_DO = 0x0020
		
		def self.find_view(hFile, name, retNoteID)
			# this is a macro in the API
			#define NIFFindView(hFile,Name,retNoteID) 			  NIFFindDesignNoteExt(hFile,Name,NOTE_CLASS_VIEW, DFLAGPAT_VIEWS_AND_FOLDERS, retNoteID, 0)
			API.find_design_note_ext(hFile, name, NOTE_CLASS_VIEW, DFLAGPAT_VIEWS_AND_FOLDERS, retNoteID, 0)
		end
		attach_function :open_collection, "NIFOpenCollection", [:int, :int, :int, :int, :int, :pointer, :pointer, :pointer, :pointer, :pointer], :int
		attach_function :open_collection_with_user_name_list, "NIFOpenCollectionWithUserNameList", [:int, :int, :int, :int, :int, :pointer, :pointer, :pointer, :pointer, :pointer, :int], :int
		attach_function :close_collection, "NIFCloseCollection", [:int], :int
		attach_function :read_entries, "NIFReadEntries", [:int, :pointer, :int, :int, :int, :uint, :int, :pointer, :pointer, :pointer, :pointer, :pointer], :int
		
	
		class COLLECTIONPOSITION < FFI::Struct
			layout :level, :int,
				:min_level, :short,
				:max_level, :short,
				:tumbler, [:int, MAXTUMBLERLEVELS]
		end
		class NAMES_LIST < FFI::Struct
			layout :num_names, :uint16,
				:licenseid, :uint64,
				:authenticated, :int32
		end
		class NameInfo
			attr_reader :num_names, :licenseid, :authenticated, :names
			
			def initialize(handle)
				ptr = API::lock_object(handle)
				@struct = NAMES_LIST.new(ptr)
				
				# read in :num_names names, which are null-terminated strings, one after the other in memory
				# offset it by the size of the main structure, which I guess is 16
				offset = 2 + 8 + 4 + 2
				@names = []
				0.upto(@struct[:num_names]-1) do |i|
					string = ""
					counter = 0
					char = ptr.get_bytes(offset, 1)
					while char != "\0" and counter < 200 do
						string << char
						counter = counter + 1
						offset = offset + 1
						char = ptr.get_bytes(offset, 1)
					end
					offset = offset + 1
					@names << string
				end
			end
		end
	end
end
