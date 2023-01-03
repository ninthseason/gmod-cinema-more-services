
local SERVICE = {}

SERVICE.Name 	= "Bilibili"
SERVICE.IsTimed = true

local DataPattern = "^/video/BV([0-9]*)"
local THEATER_URL = "https://www.bilibili.com/blackboard/player.html/?aid=%s&cid=%s"
local INFO_API = "https://api.bilibili.com/x/web-interface/view?bvid=%s"

function SERVICE:Match( url )
	return string.match(url.host, "bilibili.com") and string.match(url.path, DataPattern)
end

if (CLIENT) then

	function SERVICE:LoadProvider( Video, panel )
		local data = string.Split( Video:Data(), " " )
		
		local url = THEATER_URL:format( data[1], data[2] ) .. (self.IsTimed and ("&t=%s"):format( math.Round(CurTime() - Video:StartTime()) ) or "" )

		panel:OpenURL( url )

		panel.OnDocumentReady = function(pnl)
			self:LoadExFunctions(pnl)
		end
	end

end

function SERVICE:GetURLInfo( url )

	local bvid = string.match( url.path, "BV%g%g%g%g%g%g%g%g%g%g" )
	local t = 0
	local p = 0
	if url.query then
		t = url.query.t or 0
		p = url.query.p or 0
	end
	local info = {}
	info.Data = { ["bvid"]=bvid, ["p"]=p+1 }
	info.StartTime = 1
	info.StartTime = info.StartTime + t
	return info

end

function SERVICE:GetVideoInfo( d, onSuccess, onFailure )
	http.Fetch( INFO_API:format( d.bvid ), function( body )
		local data = util.JSONToTable( body ).data
		
		local info = { 
			["data"]=data.aid .. " " .. data.pages[d.p].cid,
			["title"]=data.title,
			["thumbnail"]=data.pic,
			["duration"]=data.pages[d.p].duration
		}
		
		-- PrintTable(info)
		pcall( onSuccess, info )

	end, onFailure)

end

theater.RegisterService( "bilibiliBV", SERVICE )