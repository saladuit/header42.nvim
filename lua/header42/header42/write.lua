require "header42.header42.asciiart"			-- a file that contain the ascii art for every school
require "header42.header42.file"			-- 
-- creating the header and returning it back

-- extracts the filename from the filepath
function fname(filepath)
	filename = split(filepath, "/")
	if filename == nil then		-- there is no / in the filepath
		-- adding support for windows file system
		filename = split(filepath,'\\')
		if filename == nil then
			filename = filepath
		end
	end
	return filename
end 

-- grabing the user informations from environement variables 
function infos()
	local infos = {}
	-- getting the our infos from env variables
	local user = os.getenv("USER42")
	local email = os.getenv("EMAIL42")
	local school = os.getenv("SCHOOL42")

	-- making sure that everything is alright 
	if user == nil or email == nil then 
		print("User informations arent set please read README.md")
		do return end
	end 

	-- inserting infos into a table 
	-- 1 username , 2 email, 3 school ascii art
	table.insert(infos, user)
	table.insert(infos, email)

	-- if school isnt provided it is automatically 42
	if school == nil then
		school = "42"
	elseif school == "42" then
		table.insert(infos, fortytwo)
	elseif school == "1337" then
		table.insert(infos, leet)
	elseif school == "19" then
		table.insert(infos, ninety)
	elseif school == "21" then
		table.insert(infos, twentyone)
	else 			-- school isnt right so we gonna go witht the default which is 42
		table.insert(infos, fortytwo)
	end
	return infos
end

-- generate those infos in the badge
function badge_page(infos, filepath)
	date = os.date("%d/%m/%Y %X")
	filename = fname(filepath)
	identity = string.format("By: %s <%s>", infos[1], infos[2])
	created = string.format("Created: %s by %s",date, infos[1])
	updated = string.format("Updated: %s by %s",date, infos[1])
	list = {string.len(filename),string.len(identity),string.len(created)}
	table.sort(list)
	biggestlen = list[3]
	return {		-- trying to make all the args in one lenght
		string.format("%s%s", filename, string.rep(" ", biggestlen- string.len(filename))),
		string.rep(" ", biggestlen),
		string.format("%s%s", identity, string.rep(" ", biggestlen- string.len(identity))),
		string.rep(" ", biggestlen),
		string.format("%s%s", created, string.rep(" ", biggestlen- string.len(created))),
		string.format("%s%s", updated, string.rep(" ", biggestlen- string.len(updated)))
	}
end

-- builds the logo in the badge
function logo(line, logo)
	badge = {}
	for i=1, #logo do
		l = string.format("%s%s%s",string.sub(line,1,string.len(line)-string.len(logo[1])-2), logo[i],string.sub(line,string.len(line)-2, string.len(line)) )
		table.insert(badge, l)
	end
	return badge
end

-- include the infos 
function pbadge(badge,pbadge_var)
	fbadge = {}
	table.insert(fbadge,badge[1])
	for i =1, #pbadge_var do 
		line = string.format("%s%s%s", string.sub(badge[i+1],1,4), pbadge_var[i], string.sub(badge[i+1],string.len(pbadge_var[i]) + 4,string.len(badge[i+1]))) 
		table.insert(fbadge, line)
	end
	return fbadge
end

-- generating the badge
function badge(filepath, infos, comments)
	pbadge_var = badge_page(infos, filepath)
	-- generating the frame of the badge using the comments 
	header = string.format("%s %s %s",comments[1],string.rep(comments[2], 6+string.len(infos[3][1])+string.len(pbadge_var[1]) ), comments[3])	-- the first and the last line of the header
	empty_line = string.format("%s %s %s",comments[1],string.rep(' ',  6+string.len(infos[3][1])+string.len(pbadge_var[1])), comments[3])
	-- adding the header
	xbadge = {} 			-- the badge table
	table.insert(xbadge,header)
	table.insert(xbadge,empty_line)
	-- inserting the complete badge to the badge var
	fbadge = pbadge(logo(empty_line,infos[3]),pbadge_var) 			-- the core of the badge	
	for i=1,#fbadge do
		table.insert(xbadge, fbadge[i])
	end
	-- adding the last touches
	table.insert(xbadge,empty_line)
	table.insert(xbadge,header)
	return xbadge
end 

local M = {}

-- write the header to the file 
function M.write()
	filepath = vim.api.nvim_buf_get_name(0)		-- current filename
	comments = comments(filepath)
	badge = badge(filepath,infos(),comments )			-- getting the badge
	current_file = io.open(filepath, "a+")
	current_file:seek('set',0)			-- setting the cursor to the beginning
	for i=1,#badge do 		-- writing the badge to the beginning of the file
		current_file:write(badge[i])
		current_file:write('\n')			-- newline
	end
	-- closing the current file
	io.close(current_file)
end

-- insert string 2 to string 1 in index pos
function string.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

return M