--@name ComputerCraft
--@client
--@includedir ccsf

local function init()
	local guest = {}
	
	guest._G = guest
	guest._ENV = guest
	guest._VERSION = "Lua 5.1"
	guest._HOST = "ComputerCraft 1.79 (Minecraft 1.8.9)"
	guest._CC_DEFAULT_SETTINGS = ""
	guest._CC_DISABLE_LUA51_FEATURES = nil
	
	guest._SF_PRINT = print
	
	guest.error = error
	guest.pcall = function(func, ...)
		local retvals = {pcall(func, ...)}
		if not retvals[1] then
			print("pcall: "..tostring(retvals[2]))
		end
		return unpack(retvals)
	end
	guest.xpcall = function(func, callback, ...)
		return xpcall(func, function(err, st)
			print("xpcall: "..tostring(err))
			callback(err)
		end, ...)
	end
	guest.type = type
	guest.tonumber = tonumber
	guest.tostring = tostring
	local fakeStringMetatable = {}
	function guest.getmetatable(v)
		if type(v) == "string" then
			return fakeStringMetatable
		end
		return getmetatable(v)
	end
	guest.setmetatable = setmetatable
	
	function guest.getfenv(func)
		if func == string.gsub then
			return {}
		end
		return guest
	end
	guest.setfenv = setfenv
	function guest.loadstring(x, name)
		if type(x) == "string" then
			local func = loadstring(x, name)
			if type(func) == "function" then
				setfenv(func, guest)
				return func
			else
				return nil, func
			end
		elseif type(x) == "function" then
			local str = ""
			while true do
				local output = x()
				if output == nil then
					break
				end
				local t = type(output)
				if t ~= "string" and t ~= "number" then
					return nil, "bios.lua:25: strValue expected, got "..t
				end
				str = str..output
			end
			local func = loadstring(str, name)
			if type(func) == "function" then
				setfenv(func, guest)
				return func
			else
				return nil, func
			end
		else
			error("bad argument: function expected, got nil", 2)
		end
	end
	
	guest.string = {
		byte = string.byte,
		char = string.char,
		dump = string.dump,
		find = string.find,
		gmatch = string.gmatch,
		gsub = string.gsub,
		len = string.len,
		lower = string.lower,
		match = string.match,
		rep = string.rep,
		reverse = string.reverse,
		sub = string.sub,
		upper = string.upper
	}
	
	guest.select = select
	guest.next = next
	guest.pairs = pairs
	guest.ipairs = ipairs
	guest.unpack = unpack
	guest.table = {
		concat = table.concat,
		foreach = table.foreach,
		foreachi = table.foreachi,
		getn = table.getn,
		insert = table.insert,
		remove = table.remove,
		maxn = table.maxn,
		sort = table.sort
	}
	
	guest.bit = {
		band = bit.band,
		blogic_rshift = bit.rshift,
		blshift = bit.lshift,
		bnot = bit.bnot,
		bor = bit.bor,
		brshift = bit.arshift,
		bxor = bit.bxor
	}
	
	guest.math = {
		abs = math.abs,
		acos = math.acos,
		asin = math.asin,
		atan = math.atan,
		atan2 = math.atan2,
		ceil = math.ceil,
		cos = math.cos,
		cosh = math.cosh,
		deg = math.deg,
		exp = math.exp,
		floor = math.floor,
		fmod = math.fmod,
		frexp = math.frexp,
		huge = math.huge,
		ldexp = math.ldexp,
		log = math.log,
		log10 = math.log10,
		max = math.max,
		min = math.min,
		modf = math.modf,
		pi = math.pi,
		pow = math.pow,
		rad = math.rad,
		random = math.random,
		randomseed = math.randomseed,
		sin = math.sin,
		sinh = math.sinh,
		sqrt = math.sqrt,
		tan = math.tan,
		tanh = math.tanh
	}
	
	local font = require("ccsf/term.lua")(guest)
	
	require("ccsf/fs.lua")(guest)
	require("ccsf/os.lua")(guest)
	require("ccsf/parallel.lua")(guest, font)
	require("ccsf/peripheral.lua")(guest)
	require("ccsf/redstone.lua")(guest)
	require("ccsf/settings.lua")(guest)
	
	guest.coroutine = {
		create = coroutine.create,
		resume = function(thread)
			return {pcall(coroutine.resume, thread)}
		end,
		running = coroutine.running,
		status = coroutine.status,
		wrap = coroutine.wrap,
		yield = coroutine.yield
	}
	
	local func = loadstring(getScripts()["ccsf/bios.lua"], "bios.lua")
	assert(type(func) == "function", func)
	setfenv(func, guest)
	local thread = coroutine.create(func)
	hook.add("render", "main", function()
		if timerPending or parallelPending or termInitPending then
			return
		end
		render.selectRenderTarget("term")
		render.setFont(font)
		coroutine.resume(thread)
	end)
end

local function preinit()
	if
		hasPermission("file.exists") and
		hasPermission("file.find") and
		hasPermission("file.open") and
		hasPermission("file.read") and
		hasPermission("file.write")
	then
		hook.remove("render", "preinit")
		hook.remove("permissionrequest", "preinit")
		init()
	else
		local p = 8
		local markup = render.parseMarkup("<font=DermaDefault>Press E on the screen for a permission prompt. Make sure you have a copy of the ComputerCraft ROM in <font=DebugFixed>sf_filedata/ccsf/rom</font>.</font>", 512-p-p)
		hook.add("render", "preinit", function()
			markup:draw(p, p)
		end)
		hook.add("permissionrequest", "preinit", preinit)
		setupPermissionRequest({
			"file.exists",
			"file.find",
			"file.open",
			"file.read",
			"file.write"
		}, "CCSF", true)
	end
end
preinit()

