
local SERVICE = {}

SERVICE.Name 	= "Bilibili"
SERVICE.IsTimed = false

local DataPattern = "^([0-9]*)"
local THEATER_URL = "https://www.bilibili.com/blackboard/live/live-activity-player.html?cid=%s"
local INFO_API = "https://api.live.bilibili.com/room/v1/Room/get_info?room_id=%s"

function SERVICE:Match( url )
	return string.match(url.host, "live.bilibili.com") and string.match(url.path, DataPattern)
end

if (CLIENT) then

	function SERVICE:LoadProvider( Video, panel )

		local url = THEATER_URL:format( Video:Data() )

		panel:OpenURL( url )

		panel.OnDocumentReady = function(pnl)
			self:LoadExFunctions(pnl)
		end
	end

end

function SERVICE:GetURLInfo( url )

	local cid = string.match( url.path, "^/(%d+)" )

	local info = {}
	info.Data = cid
	info.StartTime = 1
	return info

end

function SERVICE:GetVideoInfo( cid, onSuccess, onFailure )

	http.Fetch( INFO_API:format( cid ), function( body )
		local data = util.JSONToTable( body ).data
		local info = {}
		info.data = data.room_id
		info.title = data.title
		info.thumbnail = data.user_cover
		pcall( onSuccess, info )
	end, onFailure)

end

theater.RegisterService( "bilibililive", SERVICE )