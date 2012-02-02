module Domino
	class Session
		def initialize(program, ini)
			argv = string_array_to_inoutptr([program, ini])
			
			result = API.init_extended(2, argv)
			if result != 0
				raise API.error_string(result)
			end
		end
		
		def term; API.term; end
		
		def ping(server)
			result = API.ping_server(server, nil, nil)
			if result != 0
				raise NotesException.new(result)
			end
			true
		end
		
		def username
			username = FFI::MemoryPointer.new(:char, API::MAXUSERNAME+1)
			result = API.user_info(1, username, nil)
			if result == 0
				username.read_string
			else
				raise NotesException.new(result)
			end
		end
		def get_user_info(username)
			names_list_handle = FFI::MemoryPointer.new(:int)
			result = API.build_names_list(username, 0, names_list_handle)
			if result == 0
				API::NameInfo.new(names_list_handle.read_int)
			else
				raise NotesException.raise(result)
			end
		end
		
		def get_database(server, path)
			db_handle = FFI::MemoryPointer.new(:int)
			result = API.db_open(construct_path(server, path), db_handle)
			if result != 0
				raise NotesException.new(result)
			end
			Database.new(db_handle.read_int)
		end
		def get_database_as_user(server, path, username)
			names_list = FFI::MemoryPointer.new(:int, API::NAMES_LIST.size + 100)
			result = API.build_names_list(username, 0, names_list)
			if result == 0
				names_list_obj = API::NAMES_LIST.new(API::lock_object(names_list.read_int))
				names_list_obj[:authenticated] = API::NAMES_LIST_AUTHENTICATED | API::NAMES_LIST_PASSWORD_AUTHENTICATED
				puts names_list_obj[:authenticated]
				
				#API::unlock_object(names_list.read_int)
				
				
				db_handle = FFI::MemoryPointer.new(:int)
				result = API.db_open_extended(construct_path(server, path), 0, names_list.read_int, nil, db_handle, nil, nil)
				if result != 0
					raise NotesException.new(result)
				end
				Database.new(db_handle.read_int)
			else
				raise NotesException.new(result)
			end
		end
		
		def construct_path(server, path)
			if server == nil or server == ""
				path
			else
				"#{server}!!#{path}"
			end
		end
	end
  
end