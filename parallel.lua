return function(guest, font)
	local parallel = {}
	function parallel.waitForAny(...)
		assert(not parallelPending, "you cannot nest parallel")
		local threads = {...}
		local threadi = 0
		local threadj = #threads
		for i, func in pairs(threads) do
			threads[i] = coroutine.create(func)
		end
		local err
		local thread = coroutine.create(function()
			while true do
				threadi = threadi+1
				if threadi > threadj then
					threadi = 1
				end
				local thread = threads[threadi]
				pcall(coroutine.resume(thread))
				if coroutine.status(thread) == "dead" then
					break
				end
			end
		end)
		hook.add("render", "parallel", function()
			if timerPending then
				return
			end
			render.selectRenderTarget("term")
			render.setFont(font)
			coroutine.resume(thread)
			if coroutine.status(thread) == "dead" then
				hook.remove("render", "parallel")
				paused = false
			end
		end)
		parallelPending = true
		coroutine.yield()
		return threadi
	end
	guest.parallel = parallel
end

