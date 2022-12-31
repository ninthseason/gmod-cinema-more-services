
local SERVICE = {}

SERVICE.Name 	= "Bilibili"
SERVICE.IsTimed = true

local DataPattern = "^/bangumi/play/ss([0-9]*)"
local THEATER_URL = "https://www.bilibili.com/blackboard/player.html/?aid=%s"
local INFO_API = "https://api.bilibili.com/pgc/view/web/season?season_id=%s"

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

	local ssid = string.match( url.path, "ss(%d+)" )
	local t = 0
	if url.query and url.query.t then
		t = url.query.t
	end
	local info = {}
	info.Data = ssid
	info.StartTime = 1
	info.StartTime = info.StartTime + t
	return info

end

function SERVICE:GetVideoInfo( ssid, onSuccess, onFailure )

	http.Fetch( INFO_API:format( ssid ), function( body )
		local data = util.JSONToTable( body ).result.episodes[1]
		local info = {}
		info.data = data.aid
		info.title = data.long_title
		info.thumbnail = data.cover
		info.duration = data.duration
		pcall( onSuccess, info )
	end, onFailure)

end

theater.RegisterService( "bilibiliss", SERVICE )