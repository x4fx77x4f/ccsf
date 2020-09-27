return function(guest)
	local peripheral = {}
	function peripheral.isPresent(side)
		return false
	end
	guest.peripheral = peripheral
end
