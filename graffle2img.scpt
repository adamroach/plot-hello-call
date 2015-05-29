on run argv
	tell application "OmniGraffle Professional 5"
		set inputFile to item 1 of argv
		set outputFile to item 2 of argv
		set fileFormat to item 3 of argv
		set dpi to item 4 of argv
		
		ignoring application responses
			import inputFile
		end ignoring
		
		set resolution of current export settings to (dpi / 72)
		set draws background of current export settings to false
		set theDocument to front document
		save theDocument as fileFormat in (outputFile as POSIX file)
		close theDocument
	end tell
end run
