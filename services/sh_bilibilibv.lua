
local SERVICE = {}

SERVICE.Name 	= "Bilibili"
SERVICE.IsTimed = true

local DataPattern = "^/video/BV([0-9]*)"
local THEATER_URL = "https://www.bilibili.com/blackboard/player.html/?aid=%s"
local INFO_API = "https://api.bilibili.com/x/web-interface/view?bvid=%s"

function SERVICE:Match( url )
	return string.match(url.host, "bilibili.com") and string.match(url.path, DataPattern)
end

if (CLIENT) then

	function SERVICE:LoadProvider( Video, panel )

		local url = THEATER_URL:format( Video:Data() ) .. (self.IsTimed and ("&t=%s"):format( math.Round(CurTime() - Video:StartTime()) ) or "" )
		panel:OpenURL( url )

		panel.OnDocumentReady = function(pnl)
			self:LoadExFunctions(pnl)
		end
	end

end

function SERVICE:GetURLInfo( url )

	local bvid = string.match( url.path, "BV%g%g%g%g%g%g%g%g%g%g" )
	local info = {}
	info.Data = bvid
	info.StartTime = 1
	return info

end

-- local alphabet = "fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF"
-- local function BV2AV( x )
-- 	r = 0
-- 	for i, v in pairs( {11, 10, 3, 8, 4, 6} ) do

-- 		r = r + (string.find(alphabet, x[v + 1]) - 1) * math.pow(58, i - 1)

-- 	end

-- 	return bit.bxor(r - 0x2084007c0, 0x0a93b324)
-- end

function SERVICE:GetVideoInfo( bvid, onSuccess, onFailure )

	http.Fetch( INFO_API:format( bvid ), function( body )
		local data = util.JSONToTable( body ).data
		local info = {}
		info.data = data.aid
		info.title = data.title
		info.thumbnail = data.thumbnail
		info.duration = data.duration
		pcall( onSuccess, info )
	end, onFailure)

end

theater.RegisterService( "bilibiliBV", SERVICE )