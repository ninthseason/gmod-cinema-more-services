
local SERVICE = {}

SERVICE.Name 	= "Bilibili"
SERVICE.IsTimed = true

local DataPattern = "^/bangumi/play/ep([0-9]*)"
local THEATER_URL = "https://www.bilibili.com/blackboard/player.html/?aid=%s"
local INFO_API = "https://api.bilibili.com/pgc/view/web/season?ep_id=%s"

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

	local epid = string.match( url.path, "ep(%d+)" )
	local t = 0
	if url.query and url.query.t then
		t = url.query.t
	end
	local info = {}
	info.Data = epid
	info.StartTime = 1
	info.StartTime = info.StartTime + t
	return info

end

function SERVICE:GetVideoInfo( epid, onSuccess, onFailure )

	http.Fetch( INFO_API:format( epid ), function( body )
		local start_id = util.JSONToTable( body ).result.episodes[1].id
		local data = util.JSONToTable( body ).result.episodes[( epid - start_id ) + 1]
		local info = {}
		info.data = data.aid
		info.title = data.share_copy
		info.thumbnail = data.cover
		info.duration = data.duration / 1000
		pcall( onSuccess, info )
	end, onFailure)

end

theater.RegisterService( "bilibiliep", SERVICE )