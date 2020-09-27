return function(guest)
	local cfg = {}
	local settings = {}
	function settings.clear()
		cfg = {}
	end
	function settings.get(name, default)
		return cfg[name] or default
	end
	function settings.set(name, value)
		cfg[name] = value
	end
	function settings.unset(name)
		cfg[name] = nil
	end
	guest.settings = settings
end

