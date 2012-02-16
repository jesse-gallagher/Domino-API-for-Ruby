module Domino
	module API
		extend FFI::Library
		#ffi_lib "libnotes"
		ffi_lib "/opt/ibm/lotus/notes/85030/linux/libnotes.so"
	
		# some handy global constants
		NULLHANDLE = 0
		MAXUSERNAME = 256
		NAMES_LIST_AUTHENTICATED = 0x0001
		NAMES_LIST_PASSWORD_AUTHENTICATED = 0x0002
		NAMES_LIST_FULL_ADMIN_ACCESS = 0x0004
		ERR_MASK = 0x3fff
		
		# define the type names Domino uses for its API calls
		typedef :uint32, :DHANDLE
		typedef :uint32, :DWORD
		typedef :uint16, :WORD
		typedef :uint32, :HANDLE
		typedef :HANDLE, :WHANDLE
		typedef :WHANDLE, :HMODULE
		typedef :WORD, :STATUS
		typedef :HANDLE, :DBHANDLE
		typedef :DWORD, :NOTEID
		typedef :WORD, :HCOLLECTION
		typedef :uint16, :USHORT
		typedef :uint8, :BYTE
		typedef :uint32, :BOOL
		typedef :uint64, :DBID
		typedef :DHANDLE, :NOTEHANDLE
		typedef :uint64, :TIMEDATE_S	# for use in structures that don't care about the TIMEDATE value (like UNIVERSALNOTEID)
		typedef :WORD, :BLOCK
		typedef :double, :NUMBER
		typedef :DWORD, :HMIMEDIRECTORY
		typedef :pointer, :PMIMEENTITY
		typedef :int, :MIMESYMBOL
		typedef :pointer, :CCHANDLE
		
		
		MAXPATH = 256
		DFLAGPAT_VIEWS_AND_FOLDERS = "-G40n^"
    
		MAXTUMBLERLEVELS = 32
		MAXTUMBLERLEVELS_V2 = 8
		COLLATION_SIGNATURE = 0x44
		PERCENTILE_COUNT = 11
		
		# view open flags
		OPEN_REBUILD_INDEX = 0x0001
		OPEN_NOUPDATE = 0x0002
		OPEN_DO_NOT_CREATE = 0x0004
		OPEN_SHARED_VIEW_NOTE = 0x0010
		OPEN_REOPEN_COLLECTION = 0x0020
		
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
		NAVIGATE_NEXT_HIT = 29
		NAVIGATE_CURRENT_HIT = 31
		NAVIGATE_MASK =			0x007F
		NAVIGATE_MINLEVEL =		0x0100
		NAVIGATE_MAXLEVEL = 	0x0200
		NAVIGATE_CONTINUE = 	0x8000
		
		# view signals
		SIGNAL_MORE_TO_DO = 0x0020
		
		# Full-text search stuff
		FT_SEARCH_SET_COLL = 0x00000001
		FT_SEARCH_RET_IDTABLE = 0x00000010
		FT_SEARCH_NUMDOCS_ONLY = 0x00000002
		FT_SEARCH_REFINE = 0x00000004
		FT_SEARCH_SCORES = 0x00000008
		FT_SEARCH_SORT_DATE = 0x00000020
		FT_SEARCH_SORT_ASCEND = 0x00000040
		FT_SEARCH_TOP_SCORES = 0x00000080
		FT_SEARCH_STEM_WORDS = 0x00000200
		FT_SEARCH_THESAURUS_WORDS = 0x00000400
		FT_SEARCH_FUZZY = 0x00004000
		FT_SEARCH_EXT_RET_URL = 0x00008000
		FT_SEARCH_SORT_DATE_CREATED = 0x00010000
		FT_SEARCH_EXT_DOMAIN = 0x00040000
		FT_SEARCH_EXT_FILESYSTEM = 0x00100000
		FT_SEARCH_EXT_DATABASE = 0x00200000
		
		# Index search
		FIND_PARTIAL = 0x0001
		FIND_CASE_INSENSITIVE = 0x0002
		FIND_RETURN_DWORD = 0x0004
		FIND_ACCENT_INSENSITIVE = 0x0008
		FIND_UPDATE_IF_NOT_FOUND = 0x0020
		FIND_LESS_THAN = 0x0040
		FIND_FIRST_EQUAL = 0x0000
		FIND_LAST_EQUAL = 0x0080
		FIND_GREATER_THAN = 0x00C0
		FIND_EQUAL = 0x0800
		FIND_COMPARE_MASK = 0x08C0
		FIND_RANGE_OVERLAP = 0x0100
		FIND_RETURN_ANY_NON_CATEGORY_MATCH = 0x0200
		
		# Documnt/note access
		OPEN_SUMMARY = 0x0001
		OPEN_NOVERIFYDEFAULT = 0x0002
		OPEN_EXPAND = 0x0004
		OPEN_NOOBJECTS = 0x0008
		OPEN_SHARE = 0x0020
		OPEN_CANONICAL = 0x0040
		OPEN_MARK_READ = 0x0100
		OPEN_ABSTRACT = 0x0200
		OPEN_RESPONSE_ID_TABLE = 0x1000
		OPEN_WITH_FOLDERS = 0x00020000
		OPEN_RAW_RFC822_TEXT = 0x01000000
		OPEN_RAW_MIME_PART = 0x02000000
		OPEN_RAW_MIME = 0x01000000 | 0x02000000
		
		# It appears that Ruby doesn't make handy class methods when it doesn't
		# follow proper constant syntax, so these constants get an "F" at the start
		F_NOTE_DB = 0
		F_NOTE_ID = 1
		F_NOTE_OID = 2
		F_NOTE_CLASS = 3
		F_NOTE_MODIFIED = 4
		F_NOTE_PRIVILEGES = 5
		F_NOTE_FLAGS = 7
		F_NOTE_ACCESSED = 8
		F_NOTE_PARENT_NOTEID = 10
		F_NOTE_RESPONSE_COUNT = 11
		F_NOTE_RESPONSES = 12
		F_NOTE_ADDED_TO_FILE = 13
		F_NOTE_OBJSTORE_DB = 14
		
		NOTE_CLASS_DOCUMENT = 0x0001
		NOTE_CLASS_DATA = NOTE_CLASS_DOCUMENT
		NOTE_CLASS_INFO = 0x0002
		NOTE_CLASS_FORM = 0x0004
		NOTE_CLASS_VIEW = 0x0008
		NOTE_CLASS_ICON = 0x0010
		NOTE_CLASS_DESIGN = 0x0020
		NOTE_CLASS_ACL = 0x0040
		NOTE_CLASS_HELP_INDEX = 0x0080
		NOTE_CLASS_HELP = 0x0100
		NOTE_CLASS_FILTER = 0x0200
		NOTE_CLASS_FIELD = 0x0400
		NOTE_CLASS_REPLFORMULA = 0x0800
		NOTE_CLASS_PRIVATE = 0x1000
		NOTE_CLASS_DEFAULT = 0x8000
		NOTE_CLASS_NOTIFYDELETION = NOTE_CLASS_DEFAULT
		NOTE_CLASS_ALL = 0x7fff
		NOTE_CLASS_ALLNODATA = 0x7ffe
		NOTE_CLASS_NONE = 0x000
		NOTE_CLASS_SINGLE_INSTANCE = NOTE_CLASS_DESIGN | NOTE_CLASS_ACL | NOTE_CLASS_INFO | NOTE_CLASS_ICON | NOTE_CLASS_HELP_INDEX
		
		NOTE_ID_SPECIAL = 0xFFFF0000
		NOTEID_CATEGORY = 0x80000000
		NOTEID_CATEGORY_TOTAL = 0xC0000000
		NOTEID_CATEGORY_INDENT = 0x3F000000
		NOTEID_CATEGORY_ID = 0x00FFFFFF
		
		NOTE_FLAG_READONLY = 0x0001
		NOTE_FLAG_ABSTRACTED = 0x0002
		NOTE_FLAG_INCREMENTAL = 0x0004
		NOTE_FLAG_LINKED = 0x0020
		NOTE_FLAG_INCREMENTAL_FULL = 0x0040
		NOTE_FLAG_CANONICAL = 0x4000
		
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
		
		# MIME part types
		MIME_PART_PROLOG = 1
		MIME_PART_BODY = 2
		MIME_PART_EPILOG = 3
		MIME_PART_RETRIEVE_INFO = 4
		MIME_PART_MESSAGE = 5
		
		MIME_PART_HAS_BOUNDARY = 0x00000001
		MIME_PART_HAS_HEADERS = 0x00000002
		MIME_PART_BODY_IN_DBOBJECT = 0x00000004
		MIME_PART_SHARED_DBOBJECT = 0x00000008
		MIME_PART_SKIP_FOR_CONVERSION = 0x00000010
	
		class COLLECTIONPOSITION < FFI::Struct
			layout :Level, :WORD,
				:MinLevel, :BYTE,
				:MaxLevel, :BYTE,
				:Tumbler, [:DWORD, MAXTUMBLERLEVELS]
		end
		class ITEM_VALUE_TABLE < FFI::Struct
			layout :Length, :USHORT,
				:Items, :USHORT
			# This is followed by :items WORD values, which are the lengths of the data items
			# Then are the data items, each of which starts with a data type, which is a USHORT
		end
		class ITEM_TABLE < FFI::Struct
			layout :Length, :USHORT,
				:Items, :USHORT
			# This is followed by :Items ITEM objects, followed by packed pairs of the item name
			# and item value. Each data value stores its type in the first USHORT
		end
		class ITEM < FFI::Struct
			layout :NameLength, :USHORT,
				:ValueLength, :USHORT
		end
		class LICENSED < FFI::Struct
			layout :ID, [:BYTE, 5],
				:Product, :BYTE,
				:Check, [:BYTE, 2]
		end
		class NAMES_LIST < FFI::Struct
			layout :num_names, :WORD,
				:licenseid, :uint64,
				:authenticated, :int32
			# This is followed by :num_names packed strings
		end
		class LIST < FFI::Struct
			layout :ListEntries, :USHORT
			# This is followed by the list entries
		end
		class RANGE < FFI::Struct
			layout :ListEntries, :USHORT,
				:RangeEntries, :USHORT
		end
		class TIMEDATE < FFI::Struct
			# This isn't meant to be used by humans, hence the super-useful field name
			layout :Innards, [:DWORD, 2]
			
			def to_time
				API.timedate_to_time(self)
			end
			def to_t
				to_time.to_t
			end
		end
		class TIMEDATE_PAIR < FFI::Struct
			layout :Lower, TIMEDATE,
				:Upper, TIMEDATE
			
			def to_r
				Range.new(API.timedate_to_time(self[:Lower]).to_t, API.timedate_to_time(self[:Upper]).to_t)
			end
			def to_s
				self.to_r.to_s
			end
		end
		class TIME < FFI::Struct
			layout :year, :int,
				:month, :int,
				:day, :int,
				:weekday, :int,
				:hour, :int,
				:minute, :int,
				:second, :int,
				:hundredth, :int,
				:dst, :int,
				:zone, :int,
				:GM, :uint64
			# GM is actually a TIMEDATE structure
			def to_t
				Time.utc(self[:year], self[:month], self[:day], self[:hour], self[:minute], self[:second])
			end
			def to_s
				self.to_t.to_s
			end
		end
		class COLLATION < FFI::Struct
			layout :BufferSize, :USHORT,
				:Items, :USHORT,
				:Flags, :BYTE,
				:signature, :BYTE
			# This is followed by :Items COLLATE_DESCRIPTOR objects, then by a string filling the rest of :BufferSize
		end
		class COLLATE_DESCRIPTOR < FFI::Struct
			layout :Flags, :BYTE,
				:signature, :BYTE,
				:keytype, :BYTE,
				:NameOffset, :WORD,
				:NameLength, :WORD
		end
		class COLLECTIONDATA < FFI::Struct
			layout :DocCount, :DWORD,
				:DocTotalSize, :DWORD,
				:BTreeLeafNodes, :DWORD,
				:BTreeDepth, :WORD,
				:Spare, :WORD,
				:KeyOffset, [:DWORD, PERCENTILE_COUNT]
		end
		class COLLECTIONSTATS < FFI::Struct
			layout :TopLevelEntries, :DWORD,
				:LastModifiedTime, :DWORD
		end
		class BLOCKID < FFI::Struct
			layout :pool, :DHANDLE,
				:block, :BLOCK
		end
		class UNIVERSALNOTEID < FFI::Struct
			layout :File, :DBID,
				:Note, :TIMEDATE_S
				
			def self.from_s(unid)
				unid = unid.to_s
				file = unid[0..15].to_i(16)
				note = unid[16..31].to_i(16)
				
				unid_struct = UNIVERSALNOTEID.new
				unid_struct[:File] = file
				unid_struct[:Note] = note
				unid_struct
			end
			
			def to_i
				(self[:File] << 64) + self[:Note]
			end
			def to_s
				"%032X" % self.to_i
			end
		end
		class ORIGINATORID < FFI::Struct
			layout :File, :DBID,
				:Note, :TIMEDATE_S,
				:Sequence, :DWORD,
				:SequenceTime, :TIMEDATE_S
		end
		class MIME_PART < FFI::Struct
			layout :Version, :WORD,
				:Flags, :DWORD,
				:PartType, :BYTE,
				:Spare, :BYTE,
				:ByteCount, :WORD,
				:BoundaryLen, :WORD,
				:HeadersLen, :WORD,
				:Spare, :WORD,
				:Spare, :DWORD
		end
		
		
		# Import methods
		# general and memory functions
		attach_function "OSLockObject", [:DHANDLE], :pointer
		attach_function "OSUnlockObject", [:DHANDLE], :bool
		attach_function "OSMemFree", [:DHANDLE], :STATUS
		attach_function "OSLoadString", [:HMODULE, :STATUS, :pointer, :WORD], :WORD
		attach_function "OSPathNetConstruct", [:string, :string, :string, :pointer], :WORD
		
		# Format functions
		attach_function "ODSReadMemory", [:pointer, :WORD, :pointer, :WORD], :void
		
		attach_function "NSFBuildNamesList", [:string, :DWORD, :pointer], :STATUS
		attach_function "SECKFMUserInfo", [:WORD, :pointer, :pointer], :STATUS

		# session management functions
		attach_function "NotesInitExtended", [:int, :pointer], :STATUS
		attach_function "NotesInitIni", [:string], :STATUS
		attach_function "NotesTerm", [], :void

		def self.err(error)
			error & 0x3fff
		end
		def self.error_string(error)
			NotesErrors[error] ? "#{NotesErrors[error]} (#{error})" : error.to_s
		end
		
		# utility functions
		attach_function "TimeGMToLocal", [:pointer], :BOOL

		# server management functions
		attach_function "NSPingServer", [:string, :pointer, :pointer], :STATUS
		
		# database functions
		attach_function "NSFDbOpen", [:string, :pointer], :STATUS
		attach_function "NSFDbOpenExtended", [:string, :WORD, :DHANDLE, :pointer, :pointer, :pointer, :pointer], :STATUS
		attach_function "NSFDbClose", [:DBHANDLE], :void
		attach_function "NSFDbInfoGet", [:DBHANDLE, :pointer], :STATUS
		attach_function "NSFDbPathGet", [:DBHANDLE, :pointer, :pointer], :STATUS
		attach_function "NIFFindDesignNoteExt", [:DBHANDLE, :string, :WORD, :string, :pointer, :DWORD], :STATUS
		attach_function "NSFDbGetNamesList", [:DBHANDLE, :DWORD, :pointer], :STATUS
		
		# view/folder functions
		def self.find_view(hFile, name, retNoteID)
			# this is a macro in the API
			#define NIFFindView(hFile,Name,retNoteID) 			  NIFFindDesignNoteExt(hFile,Name,NOTE_CLASS_VIEW, DFLAGPAT_VIEWS_AND_FOLDERS, retNoteID, 0)
			API.NIFFindDesignNoteExt(hFile, name, NOTE_CLASS_VIEW, DFLAGPAT_VIEWS_AND_FOLDERS, retNoteID, 0)
		end
		attach_function "NIFOpenCollection", [:DBHANDLE, :DBHANDLE, :NOTEID, :WORD, :DHANDLE, :pointer, :pointer, :pointer, :pointer, :pointer], :STATUS
		attach_function "NIFOpenCollectionWithUserNameList", [:DBHANDLE, :DBHANDLE, :NOTEID, :WORD, :DHANDLE, :pointer, :pointer, :pointer, :pointer, :pointer, :DHANDLE], :STATUS
		attach_function "NIFCloseCollection", [:HCOLLECTION], :STATUS
		attach_function "NIFReadEntries", [:HCOLLECTION, :pointer, :WORD, :DWORD, :WORD, :DWORD, :DWORD, :pointer, :pointer, :pointer, :pointer, :pointer], :STATUS
		attach_function "NIFGetCollation", [:HCOLLECTION, :pointer], :STATUS
		attach_function "NIFSetCollation", [:HCOLLECTION, :WORD], :STATUS
		attach_function "NIFGetCollectionData", [:HCOLLECTION, :pointer], :STATUS
		attach_function "NIFUpdateCollection", [:HCOLLECTION], :STATUS
		attach_function "NIFFindByKey", [:HCOLLECTION, :pointer, :WORD, :pointer, :pointer], :STATUS
		
		# FT Search functions
		attach_function "FTSearch", [:DBHANDLE, :pointer, :HCOLLECTION, :string, :DWORD, :WORD, :DHANDLE, :pointer, :pointer, :pointer], :STATUS
		attach_function "FTOpenSearch", [:pointer], :STATUS
		attach_function "FTCloseSearch", [:DHANDLE], :STATUS
		
		
		# Note/document functions
		attach_function "NSFNoteGetInfo", [:NOTEHANDLE, :WORD, :pointer], :void
		attach_function "NSFNoteOpenExt", [:DBHANDLE, :NOTEID, :DWORD, :pointer], :STATUS
		attach_function "NSFDbGetNoteInfo", [:DBHANDLE, :NOTEID, :pointer, :pointer, :pointer], :STATUS
		attach_function "NSFDbGetNoteInfoByUNID", [:DBHANDLE, :pointer, :pointer, :pointer, :pointer, :pointer], :STATUS
		attach_function "NSFNoteClose", [:NOTEHANDLE], :STATUS
		attach_function "NSFDbGetMultNoteInfo", [:DBHANDLE, :WORD, :WORD, :DHANDLE, :pointer, :pointer], :STATUS
		attach_function "NSFNoteHasMIME", [:NOTEHANDLE], :BOOL
		
		# Items
		attach_function "NSFItemInfo", [:NOTEHANDLE, :string, :WORD, :pointer, :pointer, :pointer, :pointer], :STATUS
		callback "NSFItemScanCallback", [:WORD, :WORD, :pointer, :WORD, :pointer, :DWORD, :pointer], :STATUS
		attach_function "NSFItemScan", [:NOTEHANDLE, "NSFItemScanCallback", :pointer], :STATUS
		
		# Rich text and MIME
		attach_function "ConvertItemToText", [BLOCKID.by_value, :DWORD, :string, :WORD, :pointer, :pointer, :BOOL], :STATUS
		
		attach_function "MIMEOpenDirectory", [:NOTEHANDLE, :pointer], :STATUS
		attach_function "MIMEEntityIsMultiPart", [:PMIMEENTITY], :BOOL
		attach_function "MIMEEntityIsMessagePart", [:PMIMEENTITY], :BOOL
		attach_function "MIMEEntityIsDiscretePart", [:PMIMEENTITY], :BOOL
		attach_function "MIMEEntityContentType", [:PMIMEENTITY], :MIMESYMBOL
		attach_function "MIMEGetDecodedEntityData", [:DHANDLE, :PMIMEENTITY, :DWORD, :DWORD, :pointer, :pointer, :pointer], :STATUS
		attach_function "MIMEEntityGetHeader", [:PMIMEENTITY, :MIMESYMBOL], :string
		attach_function "MIMEConvertCDParts", [:NOTEHANDLE, :BOOL, :BOOL, :CCHANDLE], :STATUS
		
		attach_function "MMCreateConvControls", [:CCHANDLE], :STATUS
		attach_function "MMDestroyConvControls", [:CCHANDLE], :STATUS
		
		# ID tables
		attach_function "IDCreateTable", [:DWORD, :pointer], :STATUS
		attach_function "IDInsert", [:DHANDLE, :NOTEID, :pointer], :STATUS
		attach_function "IDDestroyTable", [:DHANDLE], :STATUS
		
		# A non-struct version that parses the info into useful parts
		class OriginatorID
			attr_reader :universalid, :sequence, :sequence_time
			
			def initialize(ptr)
				@universalid = UNIVERSALNOTEID.new(ptr)
				ptr += UNIVERSALNOTEID.size
				@sequence = ptr.read_uint32
				ptr += 4
				@sequence_time = TIMEDATE.new(ptr)
			end
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
		class TimeRange
			attr_reader :timedates, :ranges
			def initialize(timedates, ranges)
				@timedates = timedates
				@ranges = ranges
			end
			def to_s
				{
					:times => @timedates.map { |timedate| API.timedate_to_time(timedate) },
					:ranges => @ranges
				}.to_s
			end
		end
		class Item
			attr_reader :name, :type, :value
			
			def initialize(name, type, value)
				@name = name
				@type = type
				@value = value
			end
			
			def to_s
				{
					:name => @name,
					:type => @type,
					:value => @value
				}.to_s
			end
		end
		class MimePart
			attr_reader :version, :flags, :part_type
			attr_reader :headers, :body
			
			def initialize(ptr, notehandle)
				mime_info = MIME_PART.new(ptr)
				
				
				@version = mime_info[:Version]
				@flags = mime_info[:Flags]
				@part_type = mime_info[:PartType]
				
				headers_ptr = ptr + 22
				@headers = headers_ptr.read_bytes(mime_info[:HeadersLen]).split "\r\n"
				
				body_ptr = headers_ptr + mime_info[:HeadersLen]
				@body = body_ptr.read_bytes(mime_info[:ByteCount] - mime_info[:HeadersLen])
				
			end
			
			def to_s
				{
					:headers => @headers,
					:body => @body
				}.to_s
			end
		end
		
		def self.read_item_value(ptr, item_type, size, notehandle)
			case item_type
			when API::TYPE_TEXT
				return ptr.get_bytes(2, size-2)
			when API::TYPE_TEXT_LIST
				return API.read_text_list(ptr + 2)
			when API::TYPE_NUMBER
				# numbers are doubles
				return ptr.get_double(2)
			when API::TYPE_NUMBER_RANGE
				return API.read_number_range(ptr + 2)
			when API::TYPE_TIME
				return API.read_time(ptr + 2)
			when API::TYPE_TIME_RANGE
				return API.read_time_range(ptr + 2)
			when API::TYPE_NOTEREF_LIST
				return API.read_ref_list(ptr+2)
			when API::TYPE_MIME_PART
				return MimePart.new(ptr, notehandle)
			else
				puts "Couldn't read item type #{item_type}"
				return nil
			end
		end
		def self.read_text_list(ptr)
			# Read the LIST struct first, which just contains the entry count
			list = LIST.new(ptr)
			ptr += LIST.size
			# Read the array of USHORT length values
			lengths = ptr.read_array_of_type(:uint16, :read_uint16, list[:ListEntries])
			ptr += 2 * list[:ListEntries]
			# Read each packed string
			lengths.map do |length|
				string = ptr.read_bytes(length)
				ptr += length
				string
			end
		end
		def self.read_ref_list(ptr)
			# Domino seems fairly confident these are always single-item, but I know better
			list = LIST.new(ptr)
			ptr += LIST.size
			lengths = ptr.read_array_of_type(:uint16, :read_uint16, list[:ListEntries])
			ptr += 2 * list[:ListEntries]
			lengths.map do |length|
				unid = UNIVERSALNOTEID.new(ptr)
				ptr += length
				unid
			end
		end
		def self.read_number_range(ptr)
			# Number "ranges" are actually just lists - real number ranges aren't actually supported in Domino
			# Nonetheless, it uses the RANGE struct type... just in case, I guess
			range = RANGE.new(ptr)
			ptr += RANGE.size
			ptr.read_array_of_type(:double, :read_double, range[:ListEntries])
		end
		
		def self.read_time(ptr)
			self.timedate_to_time(TIMEDATE.new(ptr))
		end
		def self.timedate_to_time(timedate)
			time = TIME.new
			time[:GM] = timedate.to_ptr.read_uint64
			TimeGMToLocal(time.to_ptr)
			time
		end
		def self.read_time_range(ptr)
			range = RANGE.new(ptr)
			ptr += RANGE.size
			timedates = []
			0.upto(range[:ListEntries]-1) do |i|
				timedate_ptr = ptr + (i * TIMEDATE.size)
				timedates << TIMEDATE.new(timedate_ptr)
			end
			ranges = []
			0.upto(range[:RangeEntries]-1) do |i|
				pair_ptr = ptr + (range[:ListEntries] * TIMEDATE.size) + (i * TIMEDATE_PAIR.size)
				ranges << TIMEDATE_PAIR.new(pair_ptr)
			end
			TimeRange.new(timedates, ranges)
		end
		def self.read_truncated_collectionposition(ptr)
			coll_ptr = ptr + 0
			# The collection is truncated such that the Tumbler array is of size :Level + 1
			coll = COLLECTIONPOSITION.new
			
			# read the levels
			coll[:Level] = coll_ptr.read_uint16
			coll_ptr += 2
			coll[:MinLevel] = coll_ptr.read_uint8
			coll_ptr += 1
			coll[:MaxLevel] = coll_ptr.read_uint8
			coll_ptr += 1
			0.upto(coll[:Level]) do |i|
				coll[:Tumbler][i] = coll_ptr.read_uint16
				coll_ptr += 2
			end
			coll
		end
		def self.read_truncated_collectionposition_size(ptr)
			#define COLLECTIONPOSITIONSIZE(p) (sizeof(DWORD) * ((p)->Level+2))
			4 * (ptr.read_uint16+2)
		end
		def self.create_nameless_item_table(values)
			size = ITEM_TABLE.size
			# First, figure out how much size we're going to need
			# This could probably be more efficient if done in a single loop,
			#   but I don't really want to bother at the moment
			values.each do |value|
				size += ITEM.size
				if value.is_a? String
					size += value.size
				elsif value.is_a? Number
					# Numbers are doubles
					size += 8
				end
			end
			
			table_ptr = FFI::MemoryPointer.new(size)
			
			table = ITEM_TABLE.new(table_ptr)
			table[:Length] = size
			table[:Items] = values.count
			
			# pack the values onto the end
			values_ptr = table_ptr + ITEM_TABLE.size
			values.each do |value|
				value_size = 0
				value_item = ITEM.new(values_ptr)
				value_item[:NameLength] = 0
				if value.is_a? String
					value_size = value.size
					value_item[:ValueLength] = value_size
					value_ptr = values_ptr + ITEM.size
					value_ptr.write_string(value, value.size)
				elsif value.is_a? Number
					value_size = 8
					value_item[:ValueLength] = value_size
					value_ptr = values_ptr + ITEM.size
					value_ptr.write_double(value)
				end
				values_ptr += ITEM.size + value_size
			end
			
			table_ptr
		end
	end
end
