--
-- os.lua
-- Additions to the OS namespace.
-- Copyright (c) 2002-2014 Jess Perkins and the Premake project
--


---
-- Extend Lua's built-in os.execute() with token expansion and
-- path normalization.
--

	premake.override(os, "execute", function(base, cmd)
		cmd = os.translateCommands(cmd)
		return base(cmd)
	end)



---
-- Same as os.execute(), but accepts string formatting arguments.
---

	function os.executef(cmd, ...)
		cmd = string.format(cmd, ...)
		return os.execute(cmd)
	end



--
-- Scan the well-known system locations for a particular library.
--

	local function parse_ld_so_conf(conf_file)
		-- Linux ldconfig file parser to find system library locations
		local first, last
		local dirs = { }
		for line in io.lines(conf_file) do
			-- ignore comments
			first = line:find("#", 1, true)
			if first ~= nil then
				line = line:sub(1, first - 1)
			end

			if line ~= "" then
				-- check for include files
				first, last = line:find("include%s+")
				if first ~= nil then
					-- found include glob
					local include_glob = line:sub(last + 1)
					local includes = os.matchfiles(include_glob)
					for _, v in ipairs(includes) do
						dirs = table.join(dirs, parse_ld_so_conf(v))
					end
				else
					-- found an actual ld path entry
					table.insert(dirs, line)
				end
			end
		end
		return dirs
	end

	local function get_library_search_path()
		local path
		if os.istarget("windows") then
			path = os.getenv("PATH") or ""
		elseif os.istarget("haiku") then
			path = os.getenv("LIBRARY_PATH") or ""
		else
			if os.istarget("darwin") then
				path = os.getenv("DYLD_LIBRARY_PATH") or ""
			else
				path = os.getenv("LD_LIBRARY_PATH") or ""

				for _, prefix in ipairs({"", "/opt"}) do
					local conf_file = prefix .. "/etc/ld.so.conf"
					if os.isfile(conf_file) then
						for _, v in ipairs(parse_ld_so_conf(conf_file)) do
							if (#path > 0) then
								path = path .. ":" .. v
							else
								path = v
							end
						end
					end
				end
			end

			path = path or ""
			local archpath = "/lib:/usr/lib:/usr/local/lib"
			if os.is64bit() and not (os.istarget("darwin")) then
				archpath = "/lib64:/usr/lib64/:usr/local/lib64" .. ":" .. archpath
			end
			if (#path > 0) then
				path = path .. ":" .. archpath
			else
				path = archpath
			end
		end

		return path
	end


---
-- Attempt to locate and return the path to a shared library.
--
-- This function does not work to locate system libraries on macOS 11 or later; it may still
-- be used to locate user libraries: _"New in macOS Big Sur 11.0.1, the system ships with
-- a built-in dynamic linker cache of all system-provided libraries. As part of this change,
-- copies of dynamic libraries are no longer present on the filesystem. Code that attempts to
-- check for dynamic library presence by looking for a file at a path or enumerating a directory
-- will fail."
-- https://developer.apple.com/documentation/macos-release-notes/macos-big-sur-11_0_1-release-notes
--
-- @param libname
--    The library name with or without prefix and suffix.
-- @param libdirs
--    An array of paths to be searched.
-- @returns
--    The full path to the library if found; `nil` otherwise.
---
	function os.findlib(libname, libdirs)
		local path = get_library_search_path()
		local formats

		-- assemble a search path, depending on the platform
		if os.istarget("windows") then
			formats = { "%s.dll", "%s" }
		elseif os.istarget("haiku") then
			formats = { "lib%s.so", "%s.so" }
		else
			if os.istarget("darwin") then
				formats = { "lib%s.dylib", "%s.dylib" }
			else
				formats = { "lib%s.so", "%s.so" }
			end

			table.insert(formats, "%s")
		end

		local userpath = ""

		if type(libdirs) == "string" then
			userpath = libdirs
		elseif type(libdirs) == "table" then
			userpath = table.implode(libdirs, "", "", ":")
		end

		if (#userpath > 0) then
			if (#path > 0) then
				path = userpath .. ":" .. path
			else
				path = userpath
			end
		end

		for _, fmt in ipairs(formats) do
			local name = string.format(fmt, libname)
			local result = os.pathsearch(name, path)
			if result then return result end
		end
	end

	function os.findheader(headerpath, headerdirs)
		-- headerpath: a partial header file path
		-- headerdirs: additional header search paths

		local path = get_library_search_path()

		-- replace all /lib by /include
		path = path .. ':'
		path = path:gsub ('/lib[0-9]*([:/])', '/include%1')
		path = path:sub (1, #path - 1)

		local userpath = ""

		if type(headerdirs) == "string" then
			userpath = headerdirs
		elseif type(headerdirs) == "table" then
			userpath = table.implode(headerdirs, "", "", ":")
		end

		if (#userpath > 0) then
			if (#path > 0) then
				path = userpath .. ":" .. path
			else
				path = userpath
			end
		end

		local result = os.pathsearch (headerpath, path)
		return result
	end

--
-- Retrieve the current target operating system ID string.
--

	function os.target()
		return _OPTIONS.os or _TARGET_OS
	end

--
-- Retrieve the current target architecture ID string.
--

	function os.targetarch()
		return _OPTIONS.arch or _TARGET_ARCH
	end

	function os.get()
		local caller = filelineinfo(2)
		premake.warnOnce(caller, "os.get() is deprecated, use 'os.target()' or 'os.host()'.\n   @%s\n", caller)
		return os.target()
	end

	-- deprecate _OS
	_G_metatable = {
		__index = function(t, k)
			if (k == '_OS') then
				premake.warnOnce("_OS+get", "_OS is deprecated, use '_TARGET_OS'.")
				return rawget(t, "_TARGET_OS")
			else
				return rawget(t, k)
			end
		end,

		__newindex = function(t, k, v)
			if (k == '_OS') then
				premake.warnOnce("_OS+set", "_OS is deprecated, use '_TARGET_OS'.")
				rawset(t, "_TARGET_OS", v)
			else
				rawset(t, k, v)
			end
		end
	}
	setmetatable(_G, _G_metatable)



--
-- Check the current target operating system; may be set with the /os command line flag.
--

	function os.istarget(id)
		local tags = os.getSystemTags(os.target())
		return table.contains(tags, id:lower())
	end

	function os.is(id)
		local caller = filelineinfo(2)
		premake.warnOnce(caller, "os.is() is deprecated, use 'os.istarget()' or 'os.ishost()'.\n   @%s\n", caller)
		return os.istarget(id)
	end


--
-- Check the current host operating system.
--

	function os.ishost(id)
		local tags = os.getSystemTags(os.host())
		return table.contains(tags, id:lower())
	end

--
-- Retrieve the current target shell ID string.
--

	function os.shell()
		return _OPTIONS.shell or iif(os.target() == "windows", "cmd", "posix")
	end

---
-- Determine if a directory exists on the file system, and that it is a
-- directory and not a file.
--
-- @param p
--    The path to check.
-- @return
--    True if a directory exists at the given path.
---

	premake.override(os, "isdir", function(base, p)
		p = path.normalize(p)
		return base(p)
	end)



---
-- Determine if a file exists on the file system, and that it is a
-- file and not a directory.
--
-- @param p
--    The path to check.
-- @return
--    True if a file exists at the given path.
---

	premake.override(os, "isfile", function(base, p)
		p = path.normalize(p)
		return base(p)
	end)



--
-- Determine if the current system is running a 64-bit architecture.
--

	local _is64bit

	local _64BitHostTypes = {
		"x86_64",
		"ia64",
		"amd64",
		"ppc64",
		"powerpc64",
		"sparc64"
	}

	function os.is64bit()
		-- This can be expensive to compute, so cache and reuse the response
		if _is64bit ~= nil then
			return _is64bit
		end

		_is64bit = false

		-- Call the native code implementation. If this returns true then
		-- we're 64-bit, otherwise do more checking locally
		if (os._is64bit()) then
			_is64bit = true
		else
			-- Identify the system
			local arch
			if os.ishost("windows") then
				arch = os.getenv("PROCESSOR_ARCHITECTURE")
			elseif os.ishost("macosx") then
				arch = os.outputof("echo $HOSTTYPE")
			else
				arch = os.outputof("uname -m")
			end

			-- Check our known 64-bit identifiers
			arch = arch:lower()
			for _, hosttype in ipairs(_64BitHostTypes) do
				if arch:find(hosttype) then
					_is64bit = true
				end
			end
		end

		return _is64bit
	end


---
-- Perform a wildcard search for files and directories.
--
-- @param mask
--    The file search pattern. Use "*" to match any part of a file or
--    directory name, "**" to recurse into subdirectories.
-- @param matchType 
--		folder will match only folders
--		file will match only files
--		if not set it will match both
-- @return
--    A table containing the matched file or directory names.
---

	function os.match(mask, matchType)
		mask = path.normalize(mask)
		local starpos = mask:find("%*")
		local before = path.getdirectory(starpos and mask:sub(1, starpos - 1) or mask)
		local slashpos = starpos and mask:find("/", starpos)
		local after = slashpos and mask:sub(slashpos + 1)

		-- Only recurse for path components starting with '**':
		local recurse = starpos and
			mask:sub(starpos + 1, starpos + 1) == '*' and
			(starpos == 1 or mask:sub(starpos - 1, starpos - 1) == '/')

		local results = { }

		if recurse then
			local submask = mask:sub(1, starpos) .. mask:sub(starpos + 2)
			results = os.match(submask, matchType)

			local pattern = mask:sub(1, starpos)
			local m = os.matchstart(pattern)
			while os.matchnext(m) do
				if not os.matchisfile(m) then
					local matchpath = path.join(before, os.matchname(m), mask:sub(starpos))
					results = table.join(results, os.match(matchpath, matchType))
				end
			end
			os.matchdone(m)
		else
			local pattern = mask:sub(1, slashpos and slashpos - 1)
			local m = os.matchstart(pattern)
				while os.matchnext(m) do
				if not (slashpos and os.matchisfile(m)) then
					local matchpath = path.join(before, matchpath, os.matchname(m))
					
					if after then
						results = table.join(results, os.match(path.join(matchpath, after), matchType))
					else
						if matchType == "file" and os.matchisfile(m) then
							table.insert(results, matchpath)
						elseif matchType == "folder" and not os.matchisfile(m) then
							table.insert(results, matchpath)
						else -- keep previous behaviour
							table.insert(results, matchpath)	
						end	
						end
					end
				end
				os.matchdone(m)
			end

		return results
	end


---
-- Perform a wildcard search for directories.
--
-- @param mask
--    The search pattern. Use "*" to match any part of a directory
--    name, "**" to recurse into subdirectories.
-- @return
--    A table containing the matched directory names.
---

	function os.matchdirs(mask)
		local results = os.match(mask, "folder")
		return results
	end


---
-- Perform a wildcard search for files.
--
-- @param mask
--    The search pattern. Use "*" to match any part of a file
--    name, "**" to recurse into subdirectories.
-- @return
--    A table containing the matched directory names.
---

	function os.matchfiles(mask)
		local results = os.match(mask, "file")
		return results
	end

--
-- An overload of the os.mkdir() function, which will create any missing
-- subdirectories along the path.
--

	local builtin_mkdir = os.mkdir
	function os.mkdir(p)
		p = path.normalize(p)

		local dir = iif(p:startswith("/"), "/", "")
		for part in p:gmatch("[^/]+") do
			dir = dir .. part

			if (part ~= "" and not path.isabsolute(part) and not os.isdir(dir)) then
				local ok, err = builtin_mkdir(dir)
				if (not ok) then
					return nil, err
				end
			end

			dir = dir .. "/"
		end

		return true
	end


--
-- Run a shell command and return the output.
--
-- @param cmd Command to execute
-- @param streams Standard stream(s) to output
-- 		Must be one of
--		- "both" (default)
--		- "output" Return standard output stream content only
--		- "error" Return standard error stream content only
--

	function os.outputof(cmd, streams)
		cmd = path.normalize(cmd)
		streams = streams or "both"
		local redirection
		if streams == "both" then
			redirection = " 2>&1"
		elseif streams == "output" then
			redirection = " 2>/dev/null"
		elseif streams == "error" then
			redirection = " 2>&1 1>/dev/null"
		else
			error ('Invalid stream(s) selection. "output", "error", or "both" expected.')
		end

		local pipe = io.popen(cmd .. redirection)
		local result = pipe:read('*a')
		local success, what, code = pipe:close()
		if success then
			-- chomp trailing newlines
			if result then
				result = string.gsub(result, "[\r\n]+$", "")
			end

			return result, code, what
		else
			return nil, code, what
		end
	end


--
-- @brief An overloaded os.remove() that will be able to handle list of files,
--        as well as wildcards for files. Uses the syntax os.matchfiles() for
--        matching pattern wildcards.
--
-- @param f A file, a wildcard, or a list of files or wildcards to be removed
--
-- @return true on success, false and an appropriate error message on error
--
-- @example     ok, err = os.remove{"**.bak", "**.log"}
--              if not ok then
--                  error(err)
--              end
--

	local builtin_remove = os.remove
	function os.remove(f)
		-- in case of string, just match files
		if type(f) == "string" then
			local p = os.matchfiles(f)
			for _, v in pairs(p) do
				local ok, err, code = builtin_remove(v)
				if not ok then
					return ok, err, code
				end
			end
			if #p == 0 then
				return nil, "Couldn't find any file matching: " .. f, 1
			end
		-- in case of table, match files for every table entry
		elseif type(f) == "table" then
			for _, v in pairs(f) do
				local ok, err, code = os.remove(v)
				if not ok then
					return ok, err, code
				end
			end
		end

		return true
	end


--
-- Remove a directory, along with any contained files or subdirectories.
--
-- @return true on success, false and an appropriate error message on error

	local builtin_rmdir = os.rmdir
	function os.rmdir(p)
		-- Only delete children if the path is not a symlink
		if not os.islink(p) then
			-- recursively remove subdirectories
			local dirs = os.matchdirs(p .. "/*")
			for _, dname in ipairs(dirs) do
				local ok, err = os.rmdir(dname)
				if not ok then
					return ok, err
				end
			end

			-- remove any files
			local files = os.matchfiles(p .. "/*")
			for _, fname in ipairs(files) do
				local ok, err = os.remove(fname)
				if not ok then
					return ok, err
				end
			end
		end

		-- remove this directory
		return builtin_rmdir(p)
	end


---
-- Return information about a file.
---

	premake.override(os, "stat", function(base, p)
		p = path.normalize(p)
		return base(p)
	end)



---
-- Translate command tokens into their OS or action specific equivalents.
---

	os.commandTokens = {
		posix = {
			chdir = function(v)
				return "cd " .. path.normalize(v)
			end,
			copy = function(v)
				return "cp -rf " .. path.normalize(v)
			end,
			copyfile = function(v)
				return "cp -f " .. path.normalize(v)
			end,
			copydir = function(v)
				return "cp -rf " .. path.normalize(v)
			end,
			delete = function(v)
				return "rm -f " .. path.normalize(v)
			end,
			echo = function(v)
				return "echo " .. v
			end,
			linkdir = function(v)
				-- split the source and target
				-- source and target may be quoted with spaces
				-- if the source or target was quoted, retain the quotes
				local src, tgt = v:match("^%s*\"(.-)\"%s+\"(.-)\"%s*$")
				if not src then
					src, _ = v:match("^%s*(.-)%s+(.-)%s*$")
				else
					src = '"' .. src .. '"'
				end
				if not tgt then
					_, tgt = v:match("^%s*(.-)%s+(.-)%s*$")
				else
					tgt = '"' .. tgt .. '"'
				end
				return "ln -s " .. path.normalize(tgt) .. " " .. path.normalize(src)
			end,
			linkfile = function(v)
				-- split the source and target
				-- source and target may be quoted with spaces
				-- if the source or target was quoted, retain the quotes
				local src, tgt = v:match("^%s*\"(.-)\"%s+\"(.-)\"%s*$")
				if not src then
					src, _ = v:match("^%s*(.-)%s+(.-)%s*$")
				else
					src = '"' .. src .. '"'
				end
				if not tgt then
					_, tgt = v:match("^%s*(.-)%s+(.-)%s*$")
				else
					tgt = '"' .. tgt .. '"'
				end
				return "ln -s " .. path.normalize(tgt) .. " " .. path.normalize(src)
			end,
			mkdir = function(v)
				return "mkdir -p " .. path.normalize(v)
			end,
			move = function(v)
				return "mv -f " .. path.normalize(v)
			end,
			rmdir = function(v)
				return "rm -rf " .. path.normalize(v)
			end,
			touch = function(v)
				return "touch " .. path.normalize(v)
			end,
		},
		cmd = {
			chdir = function(v)
				return "chdir " .. path.translate(path.normalize(v))
			end,
			copy = function(v)
				v = path.translate(path.normalize(v))

				-- Detect if there's multiple parts to the input, if there is grab the first part else grab the whole thing
				local src = string.match(v, '^".-"') or string.match(v, '^.- ') or v

				-- Strip the trailing space from the second condition so that we don't have a space between src and '\\NUL'
				src = string.match(src, '^.*%S')

				return "IF EXIST " .. src .. "\\ (xcopy /Q /E /Y /I " .. v .. " > nul) ELSE (xcopy /Q /Y /I " .. v .. " > nul)"
			end,
			copyfile = function(v)
				v = path.translate(path.normalize(v))
				-- XCOPY doesn't have a switch to assume destination is a file when it doesn't exist.
				-- A trailing * will suppress the prompt but requires the file extensions be the same length.
				-- Just use COPY instead, it actually works.
				return "copy /B /Y " .. v
			end,
			copydir = function(v)
				v = path.translate(path.normalize(v))
				return "xcopy /Q /E /Y /I " .. v
			end,
			delete = function(v)
				return "del " .. path.translate(path.normalize(v))
			end,
			echo = function(v)
				return "echo " .. v
			end,
			linkdir = function(v)
				return "mklink /d " .. path.translate(path.normalize(v))
			end,
			linkfile = function(v)
				return "mklink " .. path.translate(path.normalize(v))
			end,
			mkdir = function(v)
				v = path.translate(path.normalize(v))
				return "IF NOT EXIST " .. v .. " (mkdir " .. v .. ")"
			end,
			move = function(v)
				return "move /Y " .. path.translate(path.normalize(v))
			end,
			rmdir = function(v)
				return "rmdir /S /Q " .. path.translate(path.normalize(v))
			end,
			touch = function(v)
				v = path.translate(path.normalize(v))
				return string.format("type nul >> %s && copy /b %s+,, %s", v, v, v)
			end,
		}
	}

	function os.translateCommands(cmd, map)
		map = map or os.shell()
		if type(map) == "string" then
			if map == "windows" then -- For retro compatibility
				map = "cmd"
			end
			map = os.commandTokens[map] or os.commandTokens["posix"]
		end

		local processOne = function(cmd)
			local i, j, prev
			repeat
				i, j = cmd:find("{.-}")
				if i then
					if i == prev then
						break
					end

					local token = cmd:sub(i + 1, j - 1):lower()
					local args = cmd:sub(j + 2)
					local func = map[token] or os.commandTokens["posix"][token]
					if func then
						cmd = cmd:sub(1, i -1) .. func(args)
					end

					prev = i
				end
			until i == nil
			return cmd
		end

		if type(cmd) == "table" then
			local result = {}
			for i = 1, #cmd do
				result[i] = processOne(cmd[i])
			end
			return result
		else
			return processOne(cmd)
		end
	end



---
-- Apply os slashes for decorated command paths.
---
	function os.translateCommandAndPath(dir, map)
		if map == 'windows' or map == 'cmd' then
			return path.translate(dir)
		end
		return dir
	end

---
-- Translate decorated command paths into their OS equivalents.
---
	function os.translateCommandsAndPaths(cmds, basedir, location, map)
		map = map or os.shell()
		location = path.getabsolute(location)
		basedir = path.getabsolute(basedir)

		local translateFunction = function(value)
			local result = path.getrelative(location, path.join(basedir, value))
			result = os.translateCommandAndPath(result, map)
			if value:endswith('/') or value:endswith('\\') or -- if original path ends with a slash then ensure the same
			   value:endswith('/"') or value:endswith('\\"') then
				result = result .. '/'
			end
			return result
		end

		local processOne = function(cmd)
			local replaceFunction = function(value)
				value = value:sub(3, #value - 1)
				return '"' .. translateFunction(value) .. '"'
			end
			return string.gsub(cmd, "%%%[[^%]\r\n]*%]", replaceFunction)
		end

		if type(cmds) == "table" then
			local result = {}
			for i = 1, #cmds do
				result[i] = processOne(cmds[i])
			end
			return os.translateCommands(result, map)
		else
			return os.translateCommands(processOne(cmds), map)
		end
	end


--
-- Generate a UUID.
--

	os._uuids = {}

	local builtin_uuid = os.uuid
	function os.uuid(name)
		local id = builtin_uuid(name)
		if name then
			if os._uuids[id] and os._uuids[id] ~= name then
				premake.warnOnce(id, "UUID clash between %s and %s", os._uuids[id], name)
			end
			os._uuids[id] = name
		end
		return id
	end


--
-- Get a set of tags for different 'platforms'
--

	os.systemTags =
	{
		["aix"]        = { "aix",     "posix", "desktop" },
		["android"]    = { "android", "mobile" },
		["bsd"]        = { "bsd",     "posix", "desktop" },
		["emscripten"] = { "emscripten", "web" },
		["haiku"]      = { "haiku",   "posix", "desktop" },
		["ios"]        = { "ios",     "darwin", "posix", "mobile" },
		["linux"]      = { "linux",   "posix", "desktop" },
		["macosx"]     = { "macosx",  "darwin", "posix", "desktop" },
		["solaris"]    = { "solaris", "posix", "desktop" },
		["uwp"]        = { "uwp", "windows", "desktop" },
		["windows"]    = { "windows", "win32", "desktop" },
	}

	function os.getSystemTags(name)
		return os.systemTags[name:lower()] or { name:lower() }
	end
