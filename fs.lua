return function(guest)
	local fs = {}
	function sanitizePath(path)
		path = string.normalizePath("ccsf/"..path)
		assert(path == "ccsf" or string.find(path, "^ccsf/"), "Invalid Path")
		if file.exists(path..".lua") then
			path = path..".lua"
		elseif file.exists(path..".ccsf.dat") then
			path = path..".ccsf.dat"
		end
		return path
	end
	function fs.combine(basePath, localPath)
		return string.normalizePath(basePath.."/"..localPath)
	end
	function fs.exists(path)
		return file.exists(sanitizePath(path))
	end
	function fs.getName(path)
		path = string.normalizePath(path)
		return path == "" and "root" or string.match(path, "[^/]+$") or path
	end
	local function isDir(path)
		local dirname = string.match(path, "[^/]+$") or path
		path = string.normalizePath("ccsf/"..path.."/..")
		if path == "ccsf" then
			return true
		end
		if not string.find(path, "^ccsf/") then
			return false
		end
		local files, dirs = file.find(path.."/"..dirname)
		return dirs[1] == dirname
	end
	fs.isDir = isDir
	function fs.list(path)
		local files, dirs = file.find(sanitizePath(path).."/*")
		for k, v in pairs(files) do
			v = string.gsub(v, "%.lua$", "")
			v = string.gsub(v, "%.ccsf%.dat$", "")
			files[k] = v
		end
		for k, v in pairs(dirs) do
			table.insert(files, v)
		end
		return files
	end
	function fs.open(path, mode)
		if isDir(path) then
			return
		end
		path = sanitizePath(path)
		local binary
		mode, binary = string.match(mode, "^([rwa])(b?)$")
		binary = binary == "b"
		assert(mode, "Unsupported mode")
		local handle = file.open(path, mode)
		if not handle then
			return
		end
		-- I'm not going to use a metatable because ComputerCraft itself doesn't. I wish I was joking.
		local output = {}
		function output.close()
			handle:close()
		end
		function output.readAll()
			return string.gsub(assert(handle:read(handle:size()), "failed to read file"), "\n$", "")
		end
		return output
	end
	guest.fs = fs
end

