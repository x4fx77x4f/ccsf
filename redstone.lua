return function(guest)
	local redstone = {}
	function redstone.getSides()
		return {
			"bottom",
			"top",
			"back",
			"front",
			"right",
			"left"
		}
	end
	guest.redstone = redstone
	guest.rs = redstone
end
