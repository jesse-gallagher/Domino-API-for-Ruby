module Domino
	module API
		extend FFI::Library
		ffi_lib "libnotes"
	
		# some handy global constants
		NULLHANDLE = 0
		MAXUSERNAME = 256
		NAMES_LIST_AUTHENTICATED = 0x0001
		NAMES_LIST_PASSWORD_AUTHENTICATED = 0x0002
		NAMES_LIST_FULL_ADMIN_ACCESS = 0x0004
		
		# define the type names Domino uses for its API calls
		typedef :uint, :dhandle
		typedef :uint, :dword
		typedef :uint16, :word
		typedef :long, :hmodule
		typedef :uint16, :status
		typedef :uint, :dbhandle
		typedef :uint, :noteid
		typedef :uint16, :hcollection
		
		# general and memory functions
		attach_function "OSLockObject", [:dhandle], :pointer
		attach_function "OSUnlockObject", [:dhandle], :bool
		attach_function "OSMemFree", [:dhandle], :status
		
		attach_function "NSFBuildNamesList", [:string, :dword, :pointer], :status
		attach_function "SECKFMUserInfo", [:word, :pointer, :pointer], :status

		# session management functions
		attach_function "NotesInitExtended", [:int, :pointer], :status
		attach_function "NotesInitIni", [:string], :status
		attach_function "NotesTerm", [], :void

		def self.err(error)
			error & 0x3fff
		end
		def self.error_string(error)
			NotesErrors[error] ? "#{NotesErrors[error]} (#{error})" : error.to_s
		end
		
		# utility functions
		attach_function "OSLoadString", [:hmodule, :status, :pointer, :word], :word
		attach_function "OSPathNetConstruct", [:string, :string, :string, :pointer], :status

		# server management functions
		attach_function "NSPingServer", [:string, :pointer, :pointer], :status

		# database functions
		MAXPATH = 256
		NOTE_CLASS_VIEW = 0x0008
		DFLAGPAT_VIEWS_AND_FOLDERS = "-G40n^"
		attach_function "NSFDbOpen", [:string, :pointer], :status
		attach_function "NSFDbOpenExtended", [:string, :word, :dhandle, :pointer, :pointer, :pointer, :pointer], :status
		attach_function "NSFDbClose", [:dbhandle], :void
		attach_function "NSFDbInfoGet", [:dbhandle, :pointer], :status
		attach_function "NSFDbPathGet", [:dbhandle, :pointer, :pointer], :status
		attach_function "NIFFindDesignNoteExt", [:dbhandle, :string, :word, :string, :pointer, :dword], :status
		attach_function "NSFDbGetNamesList", [:dbhandle, :dword, :pointer], :status
    
		# view/folder functions
		MAXTUMBLERLEVELS = 32
		MAXTUMBLERLEVELS_V2 = 8
		NOTEID_CATEGORY = 0x80000000
		
		# view read masks
		READ_MASK_NOTEID = 			0x00000001
		READ_MASK_NOTEUNID = 			0x00000002
		READ_MASK_NOTECLASS = 			0x00000004
		READ_MASK_INDEXSIBLINGS = 		0x00000008
		READ_MASK_INDEXCHILDREN = 		0x00000010
		READ_MASK_INDEXDESCENDANTS =		0x00000020
		READ_MASK_INDEXANYUNREAD =		0x00000040
		READ_MASK_INDENTLEVELS =		0x00000080
		READ_MASK_SCORE	=			0x00000200
		READ_MASK_INDEXUNREAD =			0x00000400
		READ_MASK_COLLECTIONSTATS = 		0x00000100
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
			API.NIFFindDesignNoteExt(hFile, name, NOTE_CLASS_VIEW, DFLAGPAT_VIEWS_AND_FOLDERS, retNoteID, 0)
		end
		attach_function "NIFOpenCollection", [:dbhandle, :dbhandle, :noteid, :word, :dhandle, :pointer, :pointer, :pointer, :pointer, :pointer], :status
		attach_function "NIFOpenCollectionWithUserNameList", [:dbhandle, :dbhandle, :noteid, :word, :dhandle, :pointer, :pointer, :pointer, :pointer, :pointer, :dhandle], :status
		attach_function "NIFCloseCollection", [:hcollection], :status
		attach_function "NIFReadEntries", [:hcollection, :pointer, :word, :dword, :word, :dword, :dword, :pointer, :pointer, :pointer, :pointer, :pointer], :status
		
		# item types, along with the CLASS_xxx constants they're based on
		CLASS_ERROR = (1 << 8)
		CLASS_UNAVAILABLE = (2 << 8)
		CLASS_TEXT = (5 << 8)
		CLASS_NUMBER = (3 << 8)
		CLASS_TIME = (4 << 8)
		CLASS_FORMULA = (6 << 8)
		CLASS_USERID = (7 << 8)
		CLASS_NOCOMPUTE = (0 << 8)
		
		TYPE_ERROR = 0 + CLASS_ERROR
		TYPE_UNAVAILABLE = 0 + CLASS_UNAVAILABLE
		TYPE_TEXT = 0 + CLASS_TEXT
		TYPE_TEXT_LIST = 1 + CLASS_TEXT
		TYPE_NUMBER = 0 + CLASS_NUMBER
		TYPE_NUMBER_RANGE = 1 + CLASS_NUMBER
		TYPE_TIME = 0 + CLASS_TIME
		TYPE_TIME_RANGE = 1 + CLASS_TIME
		TYPE_FORMULA = 0 + CLASS_FORMULA
		TYPE_USERID = 0 + CLASS_USERID
		TYPE_RFC822_TEXT = 2 + CLASS_TEXT
		
		TYPE_INVALID = 0 + CLASS_NOCOMPUTE
		TYPE_COMPOSITE = 1 + CLASS_NOCOMPUTE
		TYPE_COLLATION = 2 + CLASS_NOCOMPUTE
		TYPE_OBJECT = 3 + CLASS_NOCOMPUTE
		TYPE_NOTEREF_LIST = 4 + CLASS_NOCOMPUTE
		TYPE_VIEW_FORMAT = 5 + CLASS_NOCOMPUTE
		TYPE_ICON = 6 + CLASS_NOCOMPUTE
		TYPE_NOTELINK_LIST = 7 + CLASS_NOCOMPUTE
		TYPE_SIGNATURE = 8 + CLASS_NOCOMPUTE
		TYPE_SEAL = 9 + CLASS_NOCOMPUTE
		TYPE_SEALDATA = 10 + CLASS_NOCOMPUTE
		TYPE_SEAL_LIST = 11 + CLASS_NOCOMPUTE
		TYPE_HIGHLIGHTS = 12 + CLASS_NOCOMPUTE
		TYPE_WORKSHEET_DATA = 13 + CLASS_NOCOMPUTE
		TYPE_USERDATA = 14 + CLASS_NOCOMPUTE
		TYPE_QUERY = 15 + CLASS_NOCOMPUTE
		TYPE_ACTION = 16 + CLASS_NOCOMPUTE
		TYPE_ASSISTANT_INFO = 17 + CLASS_NOCOMPUTE
		TYPE_VIEWMAP_DATASET = 18 + CLASS_NOCOMPUTE
		TYPE_VIEWMAP_LAYOUT = 19 + CLASS_NOCOMPUTE
		TYPE_LSOBJECT = 20 + CLASS_NOCOMPUTE
		TYPE_HTML = 21 + CLASS_NOCOMPUTE
		TYPE_SCHED_LIST = 22 + CLASS_NOCOMPUTE
		TYPE_CALENDAR_FORMAT = 24 + CLASS_NOCOMPUTE
		TYPE_MIME_PART = 25 + CLASS_NOCOMPUTE
		
	
		class COLLECTIONPOSITION < FFI::Struct
			layout :level, :int,
				:min_level, :short,
				:max_level, :short,
				:tumbler, [:int, MAXTUMBLERLEVELS]
		end
		class ITEM_VALUE_TABLE < FFI::Struct
			layout :length, :uint16,
				:items, :uint16
			# This is followed by :items WORD values, which are the lengths of the data items
			# Then are the data items, each of which starts with a data type, which is a USHORT
		end
		class NAMES_LIST < FFI::Struct
			layout :num_names, :uint16,
				:licenseid, :uint64,
				:authenticated, :int32
			# This is followed by :num_names packed strings
		end
		class NameInfo
			attr_reader :num_names, :licenseid, :authenticated, :names
			
			def initialize(handle)
				ptr = API.OSLockObject(handle)
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
