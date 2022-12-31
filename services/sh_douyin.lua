
local SERVICE = {}

SERVICE.Name 	= "DouYin"
SERVICE.IsTimed = false

-- local DataPattern = "^"
local THEATER_URL = "https://www.douyin.com/"

function SERVICE:Match( url )
	return string.match(url.host, "www.douyin.com")
end

if (CLIENT) then

	function SERVICE:LoadProvider( Video, panel )

		panel:OpenURL( THEATER_URL )

		timer.Simple( 5, function()
			panel:Call( [[document.getElementsByClassName("xg-switch")[1].click()]] )
			panel:Call( [[document.dispatchEvent(new KeyboardEvent('keydown',{'keyCode':40,'which':40}))]] )
		end )

		panel.OnDocumentReady = function(pnl)
			self:LoadExFunctions(pnl)
		end
	end

end

function SERVICE:GetURLInfo( url )

	local info = {}
	return info

end

function SERVICE:GetVideoInfo( data, onSuccess, onFailure )

	local info = {}
	info.title = "抖音，记录美好生活~"
	-- info.thumbnail = ""
	pcall( onSuccess, info )

end

theater.RegisterService( "douyin", SERVICE )