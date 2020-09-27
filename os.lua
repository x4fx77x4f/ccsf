return function(guest)
	local os = {}
	function os.reboot()
		print("reboot")
	end
	function os.run(envVars, path, ...)
		local env = {}
		for k, v in pairs(guest) do
			env[k] = v
		end
		for k, v in pairs(envVars) do
			env[k] = v
		end
		local code = file.read(sanitizePath(path))
		assert(code, "File not found")
		local func = loadstring(code, path)
		if type(func) ~= "function" then
			print("os.run: "..func)
			return false
		end
		setfenv(func, env)
		func(...)
		return true
	end
	function os.shutdown()
		print("shutdown")
	end
	function os.startTimer(time)
		timerPending = true
		timer.simple(time, function()
			timerPending = false
		end)
	end
	guest.os = os
end

