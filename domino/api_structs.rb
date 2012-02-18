module Domino
	module API
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
			
			attr_reader :values
			# This convenience method will read in the table's values
			# This shouldn't happen automatically on construction, since Domino
			# may use "stub" versions from time to time, if I recall correctly
			def read_values!
				# add the size of ITEM_VALUE_TABLE to the pointer to get to the data value lengths
				summary_ptr = self.to_ptr + self.size
				# read in an array of WORD values of length table[:Items] to get the sizes of each summary data entry
				# then increment the pointer appropriately
				size_list = summary_ptr.read_array_of_type(:uint16, :read_uint16, self[:Items])
				summary_ptr += 2 * self[:Items]

				# the values in size_list are 0 if the value is empty and 2 + the size of the value otherwise
				# this 2 comes from the size of the data type, which is for some reason not accounted for
				#    when the value is empty

				column_values = []
				0.upto(self[:Items]-1) do |i|
					if(size_list[i] == 0)
						column_values << nil
						summary_ptr += 2
					else
						# read in usable item types
						column_values << API::read_item_value(summary_ptr, size_list[i], nil)

						summary_ptr += size_list[i]
					end
				end
				@values = column_values
				
				self
			end
		end
		class ITEM_TABLE < FFI::Struct
			layout :Length, :USHORT,
				:Items, :USHORT
			# This is followed by :Items ITEM objects, followed by packed pairs of the item name
			# and item value. Each data value stores its type in the first USHORT
			
			attr_reader :items
			# This convenience method will read in the table's items
			# This shouldn't happen automatically on construction, since Domino
			# may use "stub" versions from time to time, if I recall correctly
			def read_items!
				# Advance to the table's ITEM structures and read them in
				summary_ptr = self.to_ptr + self.size
				item_info = []
				1.upto(self[:Items]) do
					item_info << API::ITEM.new(summary_ptr)
					summary_ptr += API::ITEM.size
				end
				
				# Now that we have the name and data size values for the ITEMS, read them in
				column_items = []
				0.upto(self[:Items]-1) do |i|
					# Read in the name
					name = summary_ptr.get_bytes(0, item_info[i][:NameLength])
					summary_ptr += item_info[i][:NameLength]
					
					# Presumably, this works like SUMMARYVALUES, in that a 0 item size means no data entry
					type = 0
					value = nil
					if item_info[i][:ValueLength] > 0
						value = API::read_item_value(summary_ptr, item_info[i][:ValueLength], nil)
						
						summary_ptr += item_info[i][:ValueLength]
					end
					
					column_items << API::Item.new(name, item_type, value)
					#column_items[name] = value
				end
				@items = column_items
				
				self
			end
			
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
			
			def to_i
				(self[:Innards][0] << 32) + self[:Innards][1]
			end
			
			def to_replicaid
				("%08X" % self[:Innards][1]) + ":" + ("%08X" % self[:Innards][0])
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
		class DBREPLICAINFO < FFI::Struct
			layout :ID, TIMEDATE,
				:Flags, :WORD,
				:CutoffInterval, :WORD,
				:Cutoff, TIMEDATE
		end
	end
end