require "#{File.dirname(__FILE__)}/api_constants"
require "#{File.dirname(__FILE__)}/api_structs"

module Domino
	module API
		extend FFI::Library
		#ffi_lib "libnotes"
		ffi_lib "/opt/ibm/lotus/notes/85030/linux/libnotes.so"
		
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
		attach_function "NSFRemoteConsole", [:string, :string, :pointer], :STATUS
		
		# database functions
		attach_function "NSFDbOpen", [:string, :pointer], :STATUS
		attach_function "NSFDbOpenExtended", [:string, :WORD, :DHANDLE, :pointer, :pointer, :pointer, :pointer], :STATUS
		attach_function "NSFDbClose", [:DBHANDLE], :void
		attach_function "NSFDbInfoGet", [:DBHANDLE, :pointer], :STATUS
		attach_function "NSFDbPathGet", [:DBHANDLE, :pointer, :pointer], :STATUS
		attach_function "NIFFindDesignNoteExt", [:DBHANDLE, :string, :WORD, :string, :pointer, :DWORD], :STATUS
		attach_function "NSFDbGetNamesList", [:DBHANDLE, :DWORD, :pointer], :STATUS
		attach_function "NSFDbReplicaInfoGet", [:DBHANDLE, :pointer], :STATUS
		
		# Formula/evaluate functions
		attach_function "NSFFormulaCompile", [:string, :WORD, :string, :WORD, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :STATUS
		attach_function "NSFComputeStart", [:WORD, :pointer, :pointer], :STATUS
		attach_function "NSFComputeEvaluate", [:HCOMPUTE, :NOTEHANDLE, :pointer, :pointer, :pointer, :pointer, :pointer], :STATUS
		attach_function "NSFComputeStop", [:HCOMPUTE], :STATUS
		
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
		
		# Rich text, MIME, and HTML
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
		
		attach_function "HTMLProcessInitialize", [], :STATUS
		attach_function "HTMLProcessTerminate", [], :STATUS
		attach_function "HTMLCreateConverter", [:pointer], :STATUS
		attach_function "HTMLDestroyConverter", [:HTMLHANDLE], :STATUS
		attach_function "HTMLGetText", [:HTMLHANDLE, :DWORD, :pointer, :pointer], :STATUS
		attach_function "HTMLGetProperty", [:HTMLHANDLE, :HTMLAPI_PROP_TYPE, :pointer], :STATUS
		attach_function "HTMLSetHTMLOptions", [:HTMLHANDLE, :pointer], :STATUS
		attach_function "HTMLConvertItem", [:HTMLHANDLE, :DBHANDLE, :NOTEHANDLE, :string], :STATUS
		attach_function "HTMLConvertNote", [:HTMLHANDLE, :DBHANDLE, :NOTEHANDLE, :DWORD, :string], :STATUS
		
		# DXL
		attach_function "DXLCreateExporter", [:pointer], :STATUS
		attach_function "DXLDeleteExporter", [:DXLEXPORTHANDLE], :void
		attach_function "DXLSetExporterProperty", [:DXLEXPORTHANDLE, :DXL_EXPORT_PROPERTY, :pointer], :STATUS
		callback "DXLExportCallback", [:pointer, :DWORD, :pointer], :void
		attach_function "DXLExportNote", [:DXLEXPORTHANDLE, "DXLExportCallback", :NOTEHANDLE, :pointer], :STATUS
		attach_function "DXLExportDatabase", [:DXLEXPORTHANDLE, "DXLExportCallback", :DBHANDLE, :pointer], :STATUS
		
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
		
		def self.read_item_value(ptr, size, notehandle)
			item_type = ptr.read_uint16
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
				# Also take into account the type field
				size += ITEM.size + 2
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
					value_size = value.size + 2
					value_item[:ValueLength] = value_size
					value_ptr = values_ptr + ITEM.size
					value_ptr.write_uint16(TYPE_TEXT)
					value_ptr += 2
					value_ptr.write_string(value, value.size)
				elsif value.is_a? Number
					value_size = 8 + 2
					value_item[:ValueLength] = value_size
					value_ptr = values_ptr + ITEM.size
					value_ptr.write_uint16(TYPE_NUMBER)
					value_ptr += 2
					value_ptr.write_double(value)
				end
				values_ptr += ITEM.size + value_size
			end
			
			
			table_ptr
		end
	end
end
