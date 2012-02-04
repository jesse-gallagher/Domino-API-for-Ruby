module Domino
	class ViewEntryCollection
		def initialize(stats, entries)
			@stats = stats
			@entries = entries
		end
		def each
			@entries.each do |entry|
				yield entry
			end
		end
	end
end