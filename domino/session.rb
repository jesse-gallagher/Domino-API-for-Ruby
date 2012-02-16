module Domino
	class Session < Base
		def initialize(program, ini)
			argv = string_array_to_inoutptr([program, ini])
			
			result = API.NotesInitExtended(2, argv)
			if result != 0
				raise API.error_string(result)
			end
		end
		
		def term; API.NotesTerm; end
		
		def ping(server)
			result = API.NSPingServer(server, nil, nil)
			if result != 0
				raise NotesException.new(result)
			end
			true
		end
		
		def evaluate(formula, context=nil)
			# First, compile the formula
			rethFormula = FFI::MemoryPointer.new(API.find_type(:FORMULAHANDLE))
			retFormulaLength = FFI::MemoryPointer.new(API.find_type(:WORD))
			retCompileError = FFI::MemoryPointer.new(API.find_type(:STATUS))
			retCompileErrorLine = FFI::MemoryPointer.new(API.find_type(:WORD))
			retCompileErrorColumn = FFI::MemoryPointer.new(API.find_type(:WORD))
			retCompileErrorOffset = FFI::MemoryPointer.new(API.find_type(:WORD))
			retCompileErrorLength = FFI::MemoryPointer.new(API.find_type(:WORD))
			
			result = API.NSFFormulaCompile(
				nil,
				0,
				formula.to_s,
				formula.to_s.size,
				rethFormula,
				retFormulaLength,
				retCompileError,
				retCompileErrorLine,
				retCompileErrorColumn,
				retCompileErrorOffset,
				retCompileErrorLength
			)
			raise NotesException.new(result) if result != 0
			
			compile_error = retCompileError.read_uint16
			if compile_error != 0
				raise Exception.new("Formula compile error: " + {
					:code => compile_error,
					:line => retCompileErrorLine.read_uint16,
					:column => retCompileErrorColumn.read_unt16,
					:offset => retCompileErrorOffset.read_uint16,
					:length => retCompileErrorLength.read_uint16
				}.to_s)
			end
			
			compiled_formula = API.OSLockObject(rethFormula.read_uint32)
			
			# Start the formula environment
			rethCompute = FFI::MemoryPointer.new(API.find_type(:HCOMPUTE))
			result = API.NSFComputeStart(0, compiled_formula, rethCompute)
			raise NotesException.new(result) if result != 0
			
			# Evaluate the formula
			rethResult = FFI::MemoryPointer.new(API.find_type(:DHANDLE))
			retResultLength = FFI::MemoryPointer.new(API.find_type(:WORD))
			retNoteModified = FFI::MemoryPointer.new(API.find_type(:WORD))
			result = API.NSFComputeEvaluate(
				rethCompute.read_pointer,
				context == nil ? 0 : context.handle,
				rethResult,
				retResultLength,
				nil,
				nil,
				retNoteModified
			)
			raise NotesException.new(result) if result != 0
			
			formula_result_ptr = API.OSLockObject(rethResult.read_uint32)
			formula_result = API.read_item_value(formula_result_ptr, formula_result_ptr.read_uint16, retResultLength.read_uint16, nil)
			
			API.OSUnlockObject(rethResult.read_uint32)
			API.OSMemFree(rethResult.read_uint32)
			
			# Close down the formula environment
			result = API.NSFComputeStop(rethCompute.read_pointer)
			raise NotesException.new(result) if result != 0
			
			API.OSUnlockObject(rethFormula.read_uint32)
			
			return formula_result
		end
		
		def username
			username = FFI::MemoryPointer.new(:char, API::MAXUSERNAME+1)
			result = API.SECKFMUserInfo(1, username, nil)
			if result == 0
				username.read_string
			else
				raise NotesException.new(result)
			end
		end
		def get_user_info(username)
			names_list_handle = FFI::MemoryPointer.new(:int)
			result = API.NSFBuildNamesList(username, 0, names_list_handle)
			if result == 0
				API::NameInfo.new(names_list_handle.read_int)
			else
				raise NotesException.raise(result)
			end
		end
		
		def get_database(server, path)
			db_handle = FFI::MemoryPointer.new(:int)
			result = API.NSFDbOpen(construct_path(server, path), db_handle)
			if result != 0
				raise NotesException.new(result)
			end
			Database.new(db_handle.read_int)
		end
		def get_database_as_user(server, path, username)
			names_list = FFI::MemoryPointer.new(:int, API::NAMES_LIST.size + 100)
			result = API.NSFBuildNamesList(username, 0, names_list)
			if result == 0
				names_list_obj = API::NAMES_LIST.new(API.OSLockObject(names_list.read_int))
				names_list_obj[:authenticated] = API::NAMES_LIST_AUTHENTICATED | API::NAMES_LIST_PASSWORD_AUTHENTICATED
				puts names_list_obj[:authenticated]
				
				#API.OSUnockObject(names_list.read_int)
				
				
				db_handle = FFI::MemoryPointer.new(:int)
				result = API.NSFDbOpenExtended(construct_path(server, path), 0, names_list.read_int, nil, db_handle, nil, nil)
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
		
		
		private
		def string_array_to_inoutptr(ary)
			ptrs = ary.map { |a| FFI::MemoryPointer.from_string(a) }
			block = FFI::MemoryPointer.new(:pointer, ptrs.length)
			block.write_array_of_pointer ptrs
			#argv = FFI::MemoryPointer.new(:pointer)
			#argv.write_pointer block
			#argv
			block
		end
		def int_to_inoutptr(val)
			ptr = FFI::MemoryPointer.new(:int)
			ptr.write_int val
			ptr
		end
	end
  
end