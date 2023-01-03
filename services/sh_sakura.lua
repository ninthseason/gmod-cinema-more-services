
local SERVICE = {}

SERVICE.Name 	= "SakuraComic"
SERVICE.IsTimed = false

local DataPattern = "^/vp/"
local THEATER_URL = "https://www.yhdmp.cc/vp/%s.html"
local COVER_URL = "https://www.yhdmp.cc/showp/%s.html"

function SERVICE:Match( url )
	return string.match(url.host, "yhdmp.cc") and string.match(url.path, DataPattern)
end

if (CLIENT) then

	function SERVICE:LoadProvider( Video, panel )
		local data = string.Split( Video:Data(), " " )
		local url = THEATER_URL:format( data[1] )

		panel:OpenURL( url )

		panel.OnDocumentReady = function(pnl)

			timer.Simple( 1, function()
				panel:Call( [[document.location=document.getElementById("yh_playfram").src]] )

				timer.Simple( 1, function()
					panel:Call( [[document.getElementsByTagName('video')[0].currentTime=]] .. math.Round(CurTime() - data[2]) )	
				end )

			end )
			
			self:LoadExFunctions(pnl)
		end

	end

end

function SERVICE:GetURLInfo( url )

	local id = string.match( url.path, "/vp/(.*)%.html" )
	local t = 1
	if url.query then
		t = url.query.t or 0
	end
	local info = {}
	info.Data = { ["id"]=id, ["t"]=t }
	return info

end

function SERVICE:GetVideoInfo( data, onSuccess, onFailure )
	local id = data.id

	local comic_id = string.match( id, "^(.-)%-" )
	local episode = string.match( id, "%-.*%-(.-)$" )
	http.Fetch( COVER_URL:format( comic_id ), function( body )

		local info = {
			["data"] = id .. " " .. (CurTime() - data.t),
			["title"] = string.match( body, "<h1>(.*)</h1>" ) .. "-第" .. episode+1 .. "集",
			["thumbnail"] = nil,
		}

		pcall( onSuccess, info )

	end, onFailure)

end

theater.RegisterService( "SakuraComic", SERVICE )