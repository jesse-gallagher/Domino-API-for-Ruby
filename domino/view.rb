module Domino
	class View < Base
		attr_reader :handle
		
		def initialize(parent, handle, noteid)
			@parent = parent
			@handle = handle
			@noteid = noteid
			
			@collection_data = false
			@ft_searched = false
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
		def actual_entry_count
			if ft_searched?
				@ft_search_count
			else
				doc_count
			end
		end
		
		def ft_search(query, max_docs=0)
			# to search, first create a search handle, then execute the search
			
			close_search!
			
			handle_ptr = FFI::MemoryPointer.new(:uint)
			result = API.FTOpenSearch(handle_ptr)
			raise NotesException.new(result) if result != 0
			@search_handle = handle_ptr.read_int
			
			num_docs = FFI::MemoryPointer.new(:uint32)
			results_handle = FFI::MemoryPointer.new(:uint32)
			
			result = API.FTSearch(
				@parent.handle,
				handle_ptr,
				@handle,
				query.to_s,
				API::FT_SEARCH_SET_COLL | API::FT_SEARCH_SCORES,
				max_docs,
				API::NULLHANDLE,
				num_docs,
				nil,
				results_handle
			)
			raise NotesException.new(result) if result != 0
			
			@ft_searched = true
			@ft_search_count = num_docs.read_uint32
			
			@ft_search_count
		end
		def ft_searched?; @ft_searched; end
		def ft_search_count(query, max_docs=0)
			handle_ptr = FFI::MemoryPointer.new(:uint)
			result = API.FTOpenSearch(handle_ptr)
			raise NotesException.new(result) if result != 0
			
			num_docs = FFI::MemoryPointer.new(:uint32)
			results_handle = FFI::MemoryPointer.new(:uint32)
			result = API.FTSearch(
				@parent.handle,
				handle_ptr,
				@handle,
				query.to_s,
				API::FT_SEARCH_SET_COLL | API::FT_SEARCH_NUMDOCS_ONLY,
				max_docs,
				API::NULLHANDLE,
				num_docs,
				nil,
				results_handle
			)
			raise NotesException.new(result) if result != 0
			
			API.FTCloseSearch(handle_ptr.read_int)
			
			num_docs.read_uint32
		end
		
		def entries
			position = API::COLLECTIONPOSITION.new
			position[:Level] = 0
			position[:Tumbler][0] = 0
			
			ViewEntryCollection.new(self, position, 0xFFFFFFFF)
		end
		
		def close
			close_search!
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
		def close_search!
			API.FTCloseSearch @search_handle if @search_handle
			@search_handle = nil
			@ft_search_count = 0
			@ft_searched = false
		end
	end
end