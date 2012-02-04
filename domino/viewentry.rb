module Domino
	class ViewEntry
		attr_accessor :index, :noteid, :unid, :column_values, :note_class
		attr_accessor :sibling_count, :child_count, :descendant_count, :indent_level
		attr_accessor :any_unread, :unread, :position
		
		def freeze
			# TODO: actually implement this
			#undef :index=, :noteid=, :unid=, :column_values=
			self
		end
	end
end