return function(guest)
	local transparent = Color(0, 0, 0, 0)
	local colors = {
		[1] = Color(240, 240, 240),
		[2] = Color(242, 178, 51),
		[4] = Color(229, 127, 216),
		[8] = Color(153, 178, 242),
		[16] = Color(222, 222, 108),
		[32] = Color(127, 204, 25),
		[64] = Color(242, 178, 204),
		[128] = Color(76, 76, 76),
		[256] = Color(153, 153, 153),
		[512] = Color(76, 153, 178),
		[1024] = Color(178, 102, 229),
		[2048] = Color(51, 102, 204),
		[4096] = Color(127, 102, 76),
		[8192] = Color(87, 166, 78),
		[16384] = Color(204, 76, 76),
		[32768] = Color(25, 25, 25)
	}
	local backgroundCode = 32768
	local backgroundColor = colors[backgroundCode]
	local textCode = 1
	local textColor = colors[textCode]
	local termBlink = true
	local termColor = true
	local termX = 0
	local termY = 0
	local termW, termH = 51, 19
	local font = render.createFont("DejaVu Sans Mono", 24)
	render.setFont(font)
	local fontWidth, fontHeight = render.getTextSize("A")
	local termWReal, termHReal = termW*fontWidth, termH*fontHeight
	local u, v = termWReal/1024, termHReal/1024
	local termWRender, termHRender = termWReal, termHReal
	if termWRender > termHRender then
		if termWRender > 512 then
			termHRender = (512/termWRender)*termHRender
			termWRender = 512
		end
	else
		if termHRender > 512 then
			termWRender = (512/termHRender)*termWRender
			termHRender = 512
		end
	end
	local termXRender, termYRender = (512-termWRender)/2, (512-termHRender)/2
	render.createRenderTarget("term")
	termInitPending = true
	hook.add("render", "term", function()
		termInitPending = false
		render.selectRenderTarget("term")
		render.clear(transparent)
		hook.add("render", "term", function()
			render.setColor(backgroundColor)
			render.drawRect(termXRender, termYRender, termWRender, termHRender)
			render.setRGBA(255, 255, 255, 255)
			render.setRenderTargetTexture("term")
			render.drawTexturedRectUV(termXRender, termYRender, termWRender, termHRender, 0, 0, u, v)
			if termBlink and timer.systime() % 1 < 0.5 then
				render.setColor(textColor)
				render.drawText(termX*fontWidth+termXRender, termY*fontHeight+termYRender, "_")
			end
		end)
	end)
	
	guest.colors = {
		white = 1,
		orange = 2,
		magenta = 4,
		lightBlue = 8,
		yellow = 16,
		lime = 32,
		pink = 64,
		gray = 128,
		lightGray = 256,
		cyan = 512,
		purple = 1024,
		blue = 2048,
		brown = 4096,
		green = 8192,
		red = 16384,
		black = 32768
	}
	guest.colours = {
		white = 1,
		orange = 2,
		magenta = 4,
		lightBlue = 8,
		yellow = 16,
		lime = 32,
		pink = 64,
		grey = 128,
		lightGrey = 256,
		cyan = 512,
		purple = 1024,
		blue = 2048,
		brown = 4096,
		green = 8192,
		red = 16384,
		black = 32768
	}
	local paint = {
		["0"] = 1,
		["1"] = 2,
		["2"] = 4,
		["3"] = 8,
		["4"] = 16,
		["5"] = 32,
		["6"] = 64,
		["7"] = 128,
		["8"] = 256,
		["9"] = 512,
		["a"] = 1024,
		["b"] = 2048,
		["c"] = 4096,
		["d"] = 8192,
		["e"] = 16384,
		["f"] = 32768
	}
	
	local term = {}
	function term.blit(text, textColors, backgroundColors)
		local i = 0
		for char in text:gmatch(".") do
			i = i+1
			render.setColor(colors[paint[backgroundColors:sub(i, i)]])
			render.drawRect(termX*fontWidth, termY*fontHeight, fontWidth, fontHeight)
			render.setColor(colors[paint[textColors:sub(i, i)]])
			render.drawText(termX*fontWidth, termY*fontHeight, text:sub(i, i))
			termX = termX+1
		end
	end
	function term.clear()
		render.clear(transparent)
	end
	function term.current()
		return term
	end
	function term.getBackgroundColor()
		return backgroundCode
	end
	function term.getBackgroundColour()
		return backgroundCode
	end
	function term.getCursorBlink()
		return termBlink
	end
	function term.getCursorPos()
		return termX+1, termY+1
	end
	function term.getTextColor()
		return textCode
	end
	function term.getTextColour()
		return textCode
	end
	function term.getSize()
		return termW, termH
	end
	function term.isColor()
		return termColor
	end
	function term.isColour()
		return termColor
	end
	function term.native()
		return term
	end
	function term.redirect(terminal)
		
	end
	local lineV = v/termH
	function term.scroll(n)
		if n == 0 then
			return
		end
		render.setRenderTargetTexture("term")
		if n > 0 then
			render.drawTexturedRectUV(0, (termH-n)*fontHeight, termWReal, termHReal, 0, lineV*n, u, v)
		else
			render.drawTexturedRectUV(0, (termH-n)*fontHeight, termWReal, termHReal, 0, 0, u, lineV*math.abs(n))
		end
	end
	function term.setBackgroundColor(color)
		backgroundCode = color
		backgroundColor = colors[color]
	end
	function term.setBackgroundColour(color)
		backgroundCode = color
		backgroundColor = colors[color]
	end
	function term.setCursorBlink(bool)
		termBlink = bool and true
	end
	function term.setCursorPos(x, y)
		local t = type(x)
		assert(t == "number", "bad argument: double expected, got "..t)
		t = type(y)
		assert(t == "number", "bad argument: double expected, got "..t)
		termX, termY = x-1, y-1
	end
	function term.setTextColor(color)
		textCode = color
		textColor = colors[textCode]
	end
	function term.setTextColour(color)
		textCode = color
		textColor = colors[color]
	end
	function term.write(text)
		render.setColor(textColor)
		text = string.gsub(text, "[%z0\t]", " ")
		render.drawText(termX*fontWidth, termY*fontHeight, text)
		termX = termX+#text
	end
	guest.term = term
	
	return font
end

