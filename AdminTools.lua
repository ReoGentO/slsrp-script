script_name('AdminMode')
script_author('Fox_Yotanhaim')
script_description('Óíèâåðñàëüíûé ñêðèïò äëÿ àäìèíîâ ñåðâåðà SLS RP')
script_version('1.2')


require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local samp = require 'lib.samp.events'
local key = require 'vkeys'
local imgui = require 'imgui'
local encoding = require 'encoding'
local inicfg = require 'inicfg'

local spec_id = -1
local t1 = {}
local t2 = {}
local reports = {}
local admactn = {}
local admactn2 = {}
local vipchatf = {}
local connectplayerslog = {}
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local script_vers = 1.2
local script_vers_text = "1.2"


local update_url = "https://raw.githubusercontent.com/ReoGentO/slsrp-script/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://github.com/ReoGentO/slsrp-script/blob/main/AdminTools%20%5B1.2%5D.luac?raw=true"
local script_path = thisScript().path


local colorThemes = {u8"Êðàñíàÿ òåìà", u8"Ñèíÿÿ òåìà", u8"Àêâà òåìà", u8"Òåìíàÿ òåìà", u8"Îðàíæåâàÿ òåìà", u8"Ò¸ìíî-ñâåòëàÿ òåìà", u8"Ñâåòëî-Ñèíÿÿ òåìà", u8"Ìîíîõðîì òåìà", u8"Òåìíî-ëóííàÿ òåìà", u8"Çåëåíàÿ", u8"Ôèîëåòîâàÿ"}

function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}

img = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\amode\\amode.png")

local tags = {
	tag = 0,
	tab = 1,
	ghetto = 1,
	catalog = 1,
	info = 1
}

local buffers = {
	kick = imgui.ImBuffer(256),
	ban = imgui.ImBuffer(256),
	ban2 = imgui.ImBuffer(256),
	warnoff = imgui.ImBuffer(256),
	warnoff2 = imgui.ImBuffer(256),
	banoff = imgui.ImBuffer(256),
	banoff1 = imgui.ImBuffer(256),
	banoff2 = imgui.ImBuffer(256),
	sethp = imgui.ImBuffer(256),
	setskin = imgui.ImBuffer(256),
	lvlinpt = imgui.ImBuffer(256),
	lvlinpt2 = imgui.ImBuffer(256),
	zakoninpt = imgui.ImBuffer(256),
	zakoninpt2 = imgui.ImBuffer(256),
	matsinpt = imgui.ImBuffer(256),
	matsinpt2 = imgui.ImBuffer(256),
	killsinpt = imgui.ImBuffer(256),
	killsinpt2 = imgui.ImBuffer(256),
	xpinpt = imgui.ImBuffer(256),
	xpinpt2 = imgui.ImBuffer(256),
	vipinpt = imgui.ImBuffer(256),
	vipinpt2 = imgui.ImBuffer(256),
	moneybankinpt = imgui.ImBuffer(256),
	moneybankinpt2 = imgui.ImBuffer(256),
	moneyhandinpt = imgui.ImBuffer(256),
	moneyhandinpt2 = imgui.ImBuffer(256),
	drugsinpt = imgui.ImBuffer(256),
	drugsinpt2 = imgui.ImBuffer(256),
	autoinpt = imgui.ImBuffer(256),
	autoinpt2 = imgui.ImBuffer(256),
	narkozavinpt = imgui.ImBuffer(256),
	narkozavinpt2 = imgui.ImBuffer(256)
}

local chk = {
	chathelpinput = imgui.ImBuffer(256),
	chatadminput = imgui.ImBuffer(256),
	infmen = imgui.ImBool(false),
	chatenbl = imgui.ImBool(false),
	chatsmsenbl = imgui.ImBool(false),
	aclist = imgui.ImBool(false),
	offhchat = imgui.ImBool(false),
	offachat = imgui.ImBool(false),
	admactionsmenu = imgui.ImBool(false),
	reportsmenu = imgui.ImBool(false),
	vipchatmenu = imgui.ImBool(false),
	connectedplayers = imgui.ImBool(false)
}

local bool = {
	apanel = imgui.ImBool(false),
	changetheme = imgui.ImBool(false),
	fractionsmenu = imgui.ImBool(false),
	lvl = imgui.ImBool(false),
	zakon = imgui.ImBool(false),
	mats = imgui.ImBool(false),
	kills = imgui.ImBool(false),
	xp = imgui.ImBool(false),
	vip = imgui.ImBool(false),
	moneybank = imgui.ImBool(false),
	moneyhand = imgui.ImBool(false),
	drugs = imgui.ImBool(false),
	auto = imgui.ImBool(false),
	narkozav = imgui.ImBool(false),
	msetstat = imgui.ImBool(false),
	remenu = imgui.ImBool(false),
	menuoffban = imgui.ImBool(false),
	menuoffwarn = imgui.ImBool(false),
	giveweapon = imgui.ImBool(false),
	ruleswindow = imgui.ImBool(false),
	blist = imgui.ImBool(false),
	window = imgui.ImBool(false),
	chathelpers = imgui.ImBool(false),
	chatadmins = imgui.ImBool(false)
}

local iStyle = imgui.ImInt(0)

function samp.onSetPlayerPos(position)
	if isCharInAnyCar(PLAYER_PED) then
		return false
	end
end

function samp.onServerMessage(color, text)
	if text:find("%[HC%] .+") then
		table.insert(t1, text:match('%[HC%] (.+)'))
	end
	local nick2, id2, nextt = text:match("%[A%] (%w+_%w+)%[(%d+)%] ñîçäàë àâòîìîáèëü (.+)")
	if nick2 and id2 and nextt then
		return {color, string.format("[A] Àäìèíèñòðàòîð %s[%d] ñîçäàë àâòîìîáèëü %s", nick2, id2, nextt)}
	end
	local nick3, id3, num = text:match("Admin: (%w+_%w+)%[(%d+)%] gzcolor: (%d+)")
	if nick3 and id3 and num then
		return {color, string.format("[A] Àäìèíèñòðàòîð %s[%d] ïåðåêðàñèë çîíó âî öâåò áàíäû %d", nick3, id3, num)}
	end
	local nick4, id44, text4 = text:match("%[A%] Àäìèíèñòðàòîð (%w+_%w+)%[(%d+)%] {FFFFFF}ñíÿë ëèäåðà (.+)")
	if nick4 and id44 and text4 then
		return {color, string.format("{E14747}[A] Àäìèíèñòðàòîð %s[%d] ñíÿë ëèäåðà %s", nick4, id44, text4)}
	end
	local nick5, id55, text5 = text:match("%[A%] Àäìèíèñòðàòîð (%w+_%w+)%[(%d+)%] {FFFFFF}óâîëèë èãðîêà (.+)")
	if nick5 and id55 and text5 then
		return {color, string.format("{E14747}[A] Àäìèíèñòðàòîð %s[%d] óâîëèë èãðîêà %s", nick5, id55, text5)}
	end
	if text:find("(*.+ %w+_%w+%[%d+%]: .+)") then
		table.insert(t2, text:match('(*.+ %w+_%w+%[%d+%]: .+)'))
	end
	if text:find("^(%[A%] Àäìèíèñòðàòîð .+)") then
		table.insert(admactn, text:match('^(%[A%] Àäìèíèñòðàòîð .+)'))
	end
	if text:find("^(%[A%] Ïîäêëþ÷èëñÿ èãðîê: .+)") then
		table.insert(connectplayerslog, text:match('^(%[A%] Ïîäêëþ÷èëñÿ èãðîê: .+)'))
	end
	if text:find("^({d53e07}%[Æàëîáà%] îò %w+_%w+%[%d+%]: .+)") then
		table.insert(reports, text:match('^({d53e07}%[Æàëîáà%] îò %w+_%w+%[%d+%]: .+)'))
	end
	if text:find("^(%[V% I% P%] | {FEBC41}.+. {FFFF00}| Îòïðàâèë: %w+_%w+%[%d+%]. Òåëåôîí: %d+)") then
		table.insert(vipchatf, text:match('^(%[V% I% P%] | {FEBC41}.+. {FFFF00}| Îòïðàâèë: %w+_%w+%[%d+%]. Òåëåôîí: %d+)'))
	end
	if text:find("^Àäìèíèñòðàòîð ñëåäèò çà èãðîêîì %w+_%w+%[%d+%]") then
		remenu.v = false
	end
	if text:find("Íåâîçìîæíî èñïîëüçîâàòü íà ñàìîãî ñåáÿ.") then
		remenu.v = false
	end
	if chk.offhchat.v == true then
	   if text:find("%[HC%]") then
			return false
		end
	end
	if chk.offachat.v == true then
		if text:find("*((.+)) (%w+_%w+)%[(%d+)%]:") then
			return false
		end
	end
	if text:match('%w+_%w+%[%d+%]{ffffff}: mq') then
        local id = text:match('%w+_%w+%[(%d+)%]{ffffff}: mq')
        sampSendChat("/iban "..id.." Óïîì")
    end
	if text:match('%w+_%w+%[%d+%]: mq') then
        local id = text:match('%w+_%w+%[(%d+)%]: mq')
        sampSendChat("/iban "..id.." Óïîì")
    end
end

function samp.onSendCommand(param)
	if param:find('/re') then
		bool.remenu.v = false
	end
	if param:match('/re (%d+)') then
		spec_id = param:match('/re (%d+)')
		bool.remenu.v = true
		sampTextdrawDelete(100)
		sampTextdrawDelete(101)
	end
end

function samp.onTogglePlayerSpectating(state)
	if spec_id ~= -1 then
		bool.remenu.v = state
	end
end

function samp.onSpectatePlayer(playerid, camtype)
	spec_id = playerid
end

function samp.onConnectionRejected()
	spec_id = -1
end

function imgui.OnDrawFrame()
	if bool.remenu.v then
		if isKeyJustPressed(key.VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
			imgui.ShowCursor = not imgui.ShowCursor
		end
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(20, sh / 2.4))
		imgui.SetNextWindowSize(imgui.ImVec2(269, 394))
		imgui.Begin(u8' ', bool.remenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.MenuBar + imgui.WindowFlags.NoScrollbar)
			imgui.BeginMenuBar()
				if imgui.MenuItem(u8'Îñíîâíîå') then
					tags.tag = 0
					remenu.v = true
				end
				if imgui.MenuItem(u8'Íàêàçàíèå') then
					tags.tag = 1
					remenu.v = true
				end
			imgui.EndMenuBar()
		if tags.tag == 0 then
			if imgui.Button(u8'GOTOSP', imgui.ImVec2(80, 40)) then
				sampSendChat('/gotosp '..spec_id)
			end
			imgui.SameLine(94)
			if imgui.Button(u8'GMTEST', imgui.ImVec2(80, 40)) then
				sampSendChat('/gm '..spec_id)
			end
			imgui.SameLine(180)
			if imgui.Button(u8'STATS', imgui.ImVec2(80, 40)) then
				sampSendChat('/getstats '..spec_id)
			end
			
			if imgui.Button(u8'GETIP', imgui.ImVec2(80, 40)) then
				sampSendChat('/getip '..spec_id)
			end
			imgui.SameLine(94)
			if imgui.Button(u8'DM', imgui.ImVec2(80, 40)) then
				sampSendChat('/prison '..spec_id..' 30 ÄÌ')
			end
			imgui.SameLine(180)
			if imgui.Button(u8'DB', imgui.ImVec2(80, 40)) then
				sampSendChat('/prison '..spec_id..' 30 ÄÁ')
			end
			
			if imgui.Button(u8'SBIV', imgui.ImVec2(80, 40)) then
				sampSendChat('/prison '..spec_id..' 10 Ñáèâ (×àò)')
			end
			imgui.SameLine(94)
			if imgui.Button(u8'×åëîâåê èç\n×Ñ ïðîåêòà', imgui.ImVec2(80, 40)) then
				sampSendChat('/iban '..spec_id..' ×Ñ ñåðâåðà')
			end
			imgui.SameLine(180)
			if imgui.Button(u8'SLAP', imgui.ImVec2(80, 40)) then
				sampSendChat('/slap '..spec_id)
			end
			
			if imgui.Button(u8'FREEZE', imgui.ImVec2(80, 40)) then
				sampSendChat('/freeze '..spec_id)
			end
			imgui.SameLine(94)
			if imgui.Button(u8'UNFREEZE', imgui.ImVec2(80, 40)) then
				sampSendChat('/unfreeze '..spec_id)
			end
			imgui.SameLine(180)
			if imgui.Button(u8'UNJAIL', imgui.ImVec2(80, 40)) then
				sampSendChat('/unjail '..spec_id)
			end
			
			if imgui.Button(u8'UNPRISON', imgui.ImVec2(80, 40)) then
				sampSendChat('/unprison '..spec_id)
			end
			imgui.SameLine(94)
			if imgui.Button(u8'DELLTEXT', imgui.ImVec2(80, 40)) then
				sampSendChat('/delltext '..spec_id)
			end
			imgui.SameLine(180)
			if imgui.Button(u8'GETDONATE', imgui.ImVec2(80, 40)) then
				sampSendChat('/getdonate '..spec_id)
			end
			
			if imgui.Button(u8'IWEP', imgui.ImVec2(80, 40)) then
				sampSendChat('/iwep '..spec_id)
			end
			imgui.SameLine(94)
			if imgui.Button(u8'PGETIP', imgui.ImVec2(80, 40)) then
				lua_thread.create(function()
					sampSendChat("/ags "..sampGetPlayerNickname(spec_id))
					wait(100)
					sampCloseCurrentDialogWithButton(2)
					wait(1000)
					sampSendChat("/pgetip "..getClipboardText())
				end)
			end
			imgui.SameLine(180)
			if imgui.Button(u8'CHEAT', imgui.ImVec2(80, 40)) then
				sampSendChat('/ban '..spec_id..' 7 ×èòû')
			end
			
			if imgui.Button(u8'VRED', imgui.ImVec2(80, 40)) then
				sampSendChat('/iban '..spec_id..' Âðåä. ×èòû')
			end
			imgui.SameLine(94)
			if imgui.Button(u8'IPCHEAT', imgui.ImVec2(80, 40)) then
				sampSendChat('/iban '..spec_id..' ×èòû')
			end
			imgui.SameLine(180)
			if imgui.Button(u8'Îñê. Èãðîêà', imgui.ImVec2(80, 40)) then
				sampSendChat('/mute '..spec_id..' 30 Îñê. Èãðîêà')
			end
			
			if imgui.Button(u8'Áàãîþç', imgui.ImVec2(80, 26.5)) then
				sampSendChat('/prison '..spec_id..' 60 Áàãîþç')
			end
			imgui.SameLine(94)
			if imgui.Button(u8'Êðàøíóòü', imgui.ImVec2(80, 26.5)) then
				sampSendChat('/crash '..spec_id)
			end
			imgui.SameLine(180)
			if imgui.Button(u8'AFK (Äîðîãà)', imgui.ImVec2(80, 26.5)) then
				sampSendChat('/kick '..spec_id..' AFK íà äîðîãå')
			end
			
			imgui.SetCursorPos(imgui.ImVec2(8, 367))
			if imgui.Button(u8'REOFF', imgui.ImVec2(80, 0)) then
				sampSendChat('/re')
				bool.remenu.v = false
			end
			imgui.SameLine(94)
			if imgui.Button("<< BACK", imgui.ImVec2(80, 0)) then
				spec_id = spec_id - 1
				if sampIsPlayerConnected(spec_id) then
					sampSendChat("/re " .. spec_id)
				else
					sampSendChat("/re " .. spec_id - 1)
				end
			end
			imgui.SameLine(180)
			if imgui.Button("NEXT >>", imgui.ImVec2(80, 0)) then
				spec_id = spec_id + 1
				if sampIsPlayerConnected(spec_id) then
					sampSendChat("/re " .. spec_id)
				else
					sampSendChat("/re " .. spec_id + 1)
				end
			end
			
		end
		if tags.tag == 1 then
			if imgui.Button(u8'TK', imgui.ImVec2(40, 40)) then
				sampSendChat('/warn '..spec_id..' TK')
			end
			imgui.SameLine(52)
			if imgui.Button(u8'ÑÊ', imgui.ImVec2(40, 40)) then
				sampSendChat('/warn '..spec_id..' ÑÊ')
			end
			imgui.SameLine(96)
			if imgui.Button(u8'ÏÃ', imgui.ImVec2(40, 40)) then
				sampSendChat('/warn '..spec_id..' ÏÃ')
			end
			imgui.SameLine(140)
			if imgui.Button(u8'ÐÊ', imgui.ImVec2(40, 40)) then
				sampSendChat('/warn '..spec_id..' ÐÊ')
			end
			imgui.SameLine(185)
			if imgui.Button(u8'ÄÌ â ÇÇ', imgui.ImVec2(53, 40)) then
				sampSendChat('/warn '..spec_id..' ÄÌ â ÇÇ')
			end
			if imgui.Button(u8'Íåàäåêâàò', imgui.ImVec2(172, 40)) then
				sampSendChat('/warn '..spec_id..' Íåàäåêâàò')
			end
			if imgui.Button(u8'Îáñóæäåíèå äåéñòâèé àäì.', imgui.ImVec2(172, 40)) then
				sampSendChat('/warn '..spec_id..' Îáñóæäåíèå äåéñòâèé àäì.')
			end
		end
		imgui.End()
	end
	
	if bool.changetheme.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(269, 70))
		imgui.Begin(u8'Ïîìåíÿòü òåìó', bool.changetheme, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		if imgui.Combo(u8"Ñìåíà òåìû", iStyle, colorThemes, #colorThemes) then
			SwitchTheStyle(iStyle.v)
		end
		imgui.End()
	end
	
	if bool.remenu.v then
		local resX, resY = getScreenResolution()
        local sizeX, sizeY = 180, 160 -- WINDOW SIZE
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 1.1 - sizeX / 3, resY / 2.3 - sizeY / 3))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
        imgui.Begin('1##reconInfo', bool.remenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
		local isPed, pPed = sampGetCharHandleBySampPlayerId(spec_id)
		local speed, health, armor, interior, model, carSpeed, carHealth, carHundle, carModel
		local score, ping = sampGetPlayerScore(spec_id), sampGetPlayerPing(spec_id)
		if isPed and doesCharExist(pPed) then
			speed = getCharSpeed(pPed)
			health = sampGetPlayerHealth(spec_id)
			armor = sampGetPlayerArmor(spec_id)
			model = getCharModel(pPed)
			interior = getCharActiveInterior(playerPed)
			if isCharInAnyCar(pPed) then
				carHundle = storeCarCharIsInNoSave(pPed)
				carSpeed = getCarSpeed(carHundle) * 1.98
				carModel = getCarModel(carHundle)
				carHealth = getCarHealth(carHundle)
			end
		end
		imgui.Text(u8"Íèê: "..sampGetPlayerNickname(spec_id))
		imgui.Text(u8"ID: "); imgui.SameLine(90); imgui.Text(tostring(spec_id))
		imgui.Text(u8"Æèçíè:"); imgui.SameLine(90); imgui.Text(isPed and tostring(health) or u8"Íåò")
		imgui.Text(u8"Áðîíÿ:"); imgui.SameLine(90); imgui.Text(isPed and tostring(armor) or u8"Íåò")
		imgui.Text(u8"Óðîâåíü:"); imgui.SameLine(90); imgui.Text(tostring(score))
		imgui.Text(u8"Ïèíã:"); imgui.SameLine(90); imgui.Text(tostring(ping))
		imgui.Text(u8"Ñêèí:"); imgui.SameLine(90); imgui.Text(isPed and tostring(model) or u8"Íåò")
		imgui.Text(u8"Èíòåðüåð:"); imgui.SameLine(90); imgui.Text(isPed and tostring(interior) or u8"Íåò")
		if isPed and doesCharExist(pPed) and isCharInAnyCar(pPed) then
			imgui.SetNextWindowPos(imgui.ImVec2(resX / 1.1 - sizeX / 3, resY / 1.47 - sizeY / 3))
			imgui.SetNextWindowSize(imgui.ImVec2(180, 85))
			imgui.Begin('1##reconCarInfo', remenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
			imgui.Text(u8"Òðàíñïîðò:"); imgui.SameLine(90); imgui.Text(isPed and tostring(tCarsName[carModel-399]) or u8"Íåò")
			imgui.Text(u8"Æèçíè:"); imgui.SameLine(90); imgui.Text(isPed and tostring(carHealth) or u8"Íåò")
			imgui.Text(u8"Ìîäåëü:"); imgui.SameLine(90); imgui.Text(isPed and tostring(carModel) or u8"Íåò")
			imgui.Text(u8"Ñêîðîñòü:"); imgui.SameLine(90); imgui.Text(isPed and tostring(math.ceil(carSpeed)) or u8"Íåò")
			imgui.End()
        end
		imgui.End()
	end
	
	if bool.menuoffwarn.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.6, sh / 2.6))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 200))
		imgui.Begin(u8' ', bool.menuoffwarn, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
		imgui.SetCursorPos(imgui.ImVec2(51, 1))
		imgui.TextColored(imgui.ImVec4(1.0, 0.0, 0.0, 1.0), u8'Âûäàòü âàðí èãðîêó â îôôëàéíå')
		imgui.InputText(u8'Èìÿ èãðîêà##1', buffers.warnoff)
		imgui.InputText(u8'Ïðè÷èíà##1', buffers.warnoff2)
		imgui.SetCursorPos(imgui.ImVec2(4, 170))
		if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(150, 25)) then
			bool.menuoffwarn.v = false
		end
		imgui.SetCursorPos(imgui.ImVec2(158, 170))
		if imgui.Button(u8'Âûäàòü âàðí', imgui.ImVec2(138, 25)) then
			sampSendChat(u8:decode('/offwarn '..buffers.warnoff.v..' '..buffers.warnoff2.v))
			bool.menuoffwarn.v = false
		end
		imgui.End()
	end
	
	if bool.menuoffban.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.6, sh / 2.6))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 200))
		imgui.Begin(u8' ', bool.menuoffban, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
		imgui.SetCursorPos(imgui.ImVec2(51, 1))
		imgui.TextColored(imgui.ImVec4(1.0, 0.0, 0.0, 1.0), u8'Âûäàòü áàí èãðîêó â îôôëàéíå')
		imgui.InputText(u8'Èìÿ èãðîêà##1', buffers.banoff)
		imgui.InputText(u8'Âðåìÿ##2', buffers.banoff1)
		imgui.InputText(u8'Ïðè÷èíà##3', buffers.banoff2)
		imgui.SetCursorPos(imgui.ImVec2(4, 170))
		if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(150, 25)) then
			bool.menuoffban.v = false
		end
		imgui.SetCursorPos(imgui.ImVec2(158, 170))
		if imgui.Button(u8'Âûäàòü áàí', imgui.ImVec2(138, 25)) then
			sampSendChat(u8:decode('/offban '..buffers.banoff.v..' '..buffers.banoff1.v..' '..buffers.banoff2.v))
			bool.menuoffban.v = false
		end
		imgui.End()
	end
	
	if bool.giveweapon.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 3.8))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 400))
		imgui.Begin(u8'Âûäà÷à îðóæèÿ', bool.giveweapon, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		if imgui.Button(u8'Êàñòåò', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(1, 1000000)
		end
		if imgui.Button(u8'Êëþøêà äëÿ ãîëüôà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(2, 1000000)
		end
		if imgui.Button(u8'Ïîëèöåéñêàÿ äóáèíêà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(3, 1000000)
		end
		if imgui.Button(u8'Íîæ', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(4, 1000000)
		end
		if imgui.Button(u8'Áåéñáîëüíàÿ áèòà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(5, 1000000)
		end
		if imgui.Button(u8'Ëîïàòà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(6, 1000000)
		end
		if imgui.Button(u8'Êèé', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(7, 1000000)
		end
		if imgui.Button(u8'Êàòàíà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(8, 1000000)
		end
		if imgui.Button(u8'Áåíçîïèëà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(9, 1000000)
		end
		if imgui.Button(u8'Äâóõñòîðîííèé äèëäî', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(10, 1000000)
		end
		if imgui.Button(u8'Äèëäî', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(11, 1000000)
		end
		if imgui.Button(u8'Âèáðàòîð', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(12, 1000000)
		end
		if imgui.Button(u8'Ñåðåáðÿíûé âèáðàòîð', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(13, 1000000)
		end
		if imgui.Button(u8'Áóêåò öâåòîâ', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(14, 1000000)
		end
		if imgui.Button(u8'Òðîñòü', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(15, 1000000)
		end
		if imgui.Button(u8'Ãðàíàòà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(16, 1000000)
		end
		if imgui.Button(u8'Ñëåçîòî÷èâûé ãàç', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(17, 1000000)
		end
		if imgui.Button(u8'Êîêòåéëü Ìîëîòîâà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(18, 1000000)
		end
		
		if imgui.Button(u8'Ïèñòîëåò 9ìì', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(22, 1000000)
		end
		if imgui.Button(u8'Ïèñòîëåò 9ìì ñ ãëóøèòåëåì', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(23, 1000000)
		end
		if imgui.Button(u8'Ïèñòîëåò Äåçåðò Èãë', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(24, 1000000)
		end
		if imgui.Button(u8'Îáû÷íûé äðîáîâèê', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(25, 1000000)
		end
		if imgui.Button(u8'Îáðåç', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(26, 1000000)
		end
		if imgui.Button(u8'Ñêîðîñòðåëüíûé äðîáîâèê', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(27, 1000000)
		end
		if imgui.Button(u8'Óçè', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(28, 1000000)
		end
		if imgui.Button(u8'MP5', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(29, 1000000)
		end
		if imgui.Button(u8'Àâòîìàò Êàëàøíèêîâà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(30, 1000000)
		end
		if imgui.Button(u8'Âèíòîâêà M4', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(31, 1000000)
		end
		if imgui.Button(u8'Tec-9', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(32, 1000000)
		end
		if imgui.Button(u8'Îõîòíè÷üå ðóæüå', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(33, 1000000)
		end
		if imgui.Button(u8'Ñíàéïåðñêàÿ âèíòîâêà', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(34, 1000000)
		end
		if imgui.Button(u8'ÐÏÃ', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(35, 1000000)
		end
		if imgui.Button(u8'Ñàìîíàâîäÿùèåñÿ ðàêåòû HS', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(36, 1000000)
		end
		if imgui.Button(u8'Îãíåìåò', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(37, 1000000)
		end
		if imgui.Button(u8'Ìèíèãàí', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(38, 1000000)
		end
		if imgui.Button(u8'Ñóìêà ñ òðîòèëîì', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(39, 1000000)
		end
		if imgui.Button(u8'Äåòîíàòîð ê ñóìêå', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(40, 1000000)
		end
		if imgui.Button(u8'Áàëëîí÷èê ñ êðàñêîé', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(41, 1000000)
		end
		if imgui.Button(u8'Îãíåòóøèòåëü', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(42, 1000000)
		end
		if imgui.Button(u8'Ôîòîàïïàðàò', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(43, 1000000)
		end
		if imgui.Button(u8'Ïðèáîð íî÷íîãî âèäåíèÿ', imgui.ImVec2(-0.1, 0)) then
			sampAddChatMessage("Íåëüçÿ âûäàâàòü î÷êè, åáàòü òû óìíûé", 0xAA3333)
		end
		if imgui.Button(u8'Òåïëîâèçîð', imgui.ImVec2(-0.1, 0)) then
			sampAddChatMessage("Íåëüçÿ âûäàâàòü î÷êè, ïîíÿë íå?", 0xAA3333)
		end
		if imgui.Button(u8'Ïàðàøþò', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(46, 1000000)
		end
		imgui.End()
	end
	
	if bool.msetstat.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 3.09))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 295))
		imgui.Begin(u8'Ìåíþ /setstat', bool.msetstat, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		if imgui.Button(u8"Óðîâåíü", imgui.ImVec2(-0.1, 0)) then
			bool.lvl.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Çàêîíîïîñëóøíîñòü", imgui.ImVec2(-0.1, 0)) then
			bool.zakon.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Ìàòû", imgui.ImVec2(-0.1, 0)) then
			bool.mats.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Óáèéñòâà", imgui.ImVec2(-0.1, 0)) then
			bool.kills.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Îïûò", imgui.ImVec2(-0.1, 0)) then -- mats.v or kills.v or xp.v or vip.v or moneybank.v or moneyhand.v or drugs.v or auto.v or narkozav.v
			bool.xp.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"ÂÈÏ", imgui.ImVec2(-0.1, 0)) then
			bool.vip.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Äåíüãè â áàíêå", imgui.ImVec2(-0.1, 0)) then
			bool.moneybank.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Äåíüãè íà ðóêàõ", imgui.ImVec2(-0.1, 0)) then
			bool.moneyhand.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Íàðêîòèêè", imgui.ImVec2(-0.1, 0)) then
			bool.drugs.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Ìàøèíà", imgui.ImVec2(-0.1, 0)) then
			bool.auto.v = true
			bool.msetstat.v = false
		end
		if imgui.Button(u8"Íàðêîçàâèñèìîñòü", imgui.ImVec2(-0.1, 0)) then
			bool.narkozav.v = true
			bool.msetstat.v = false
		end
		imgui.End()
	end
	
	if bool.lvl.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Óðîâåíü', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.lvlinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Óðîâåíü (îò 1 äî 999)##2", buffers.lvlinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.lvlinpt.v.." 1 "..buffers.lvlinpt2.v)
		end
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.lvl.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.zakon.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Çàêîíîïîñëóøíîñòü', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.zakoninpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Çàêîíîïîñëóøíîñòü##2", buffers.zakoninpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.zakoninpt.v.." 2 "..buffers.zakoninpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 2 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 2 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.zakon.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.mats.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Ìàòû', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.matsinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Ìàòû##2", buffers.matsinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.matsinpt.v.." 3 "..buffers.matsinpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 3 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 3 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.mats.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.kills.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Óáèéñòâà', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.killsinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Óáèéñòâà##2", buffers.killsinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.killsinpt.v.." 5 "..buffers.killsinpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 5 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 5 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.kills.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.xp.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Îïûò', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.xpinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Êîë-âî îïûòà##2", buffers.xpinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.xpinpt.v.." 7 "..buffers.xpinpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 7 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 7 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.xp.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.vip.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'ÂÈÏ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.vipinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Ââåäèòå 0 èëè 1##2", buffers.vipinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.vipinpt.v.." 10 "..buffers.vipinpt2.v)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.vip.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.moneybank.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Äåíüãè â áàíêå', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.moneybankinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Êîë-âî äåíåã##2", buffers.moneybankinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.moneybankinpt.v.." 13 "..buffers.moneybankinpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 13 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 13 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.moneybank.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.moneyhand.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Äåíüãè íà ðóêàõ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.moneyhandinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Êîë-âî äåíåã##2", buffers.moneyhandinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.moneyhandinpt.v.." 15 "..buffers.moneyhandinpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 15 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 15 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.moneyhand.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.drugs.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Íàðêîòèêè', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.drugsinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Êîë-âî íàðêîòèêîâ##2", buffers.drugsinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.drugsinpt.v.." 17 "..buffers.drugsinpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 17 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 17 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.drugs.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.auto.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Àâòî', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.autoinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID òðàíñïîðòà##2", buffers.autoinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.autoinpt.v.." 26 "..buffers.autoinpt2.v)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.auto.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.narkozav.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'Íàðêîçàâèñèìîñòü', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"Âàø ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.narkozavinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"Êîë-âî íàðêî-ìîñòè##2", buffers.narkozavinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"Ïîñòàâèòü", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.narkozavinpt.v.." 29 "..buffers.narkozavinpt2.v)
		end
		if imgui.Button(u8"Ïîñòàâèòü 2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 29 2147483647")
		end
		if imgui.Button(u8"Ïîñòàâèòü -2 147 483 647 ñåáå!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 29 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"Íàçàä", imgui.ImVec2(-0.1, 0)) then
			bool.narkozav.v = false
			bool.msetstat.v = true
		end
		imgui.End()
	end
	
	if bool.ruleswindow.v then
		imgui.ShowCursor = true
		local x, y = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(x / 4, y / 4.4))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 470))
		imgui.Begin(u8'Ñïèñîê ïðàâèë', bool.ruleswindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		if imgui.Button(u8'    Ïðàâèëà\näëÿ àäìèíîâ', imgui.ImVec2(100, 40)) then
			tags.catalog = 1
		end
		imgui.SameLine()
		if imgui.Button(u8'    Ïðàâèëà\näëÿ õåëïåðîâ', imgui.ImVec2(100, 40)) then
			tags.catalog = 2
		end
		imgui.SameLine()
		if imgui.Button(u8'Ïðàâèëà\nãåòòî', imgui.ImVec2(100, 40)) then
			tags.catalog = 3
		end
		imgui.SameLine()
		if imgui.Button(u8'Ïðàâèëà UNINV\nâ ãîñ. ôðàêöèÿõ', imgui.ImVec2(100, 40)) then
			tags.catalog = 4
		end
		imgui.SameLine()
		if imgui.Button(u8'Íàêàçàíèÿ', imgui.ImVec2(100, 40)) then
			tags.catalog = 5
		end
		imgui.Separator()
		if tags.catalog == 1 then
			imgui.BeginChild('Ãëàâû', imgui.ImVec2(115, 390), false, imgui.WindowFlags.NoScrollbar)
			if imgui.Button(u8'Îáùåíèå', imgui.ImVec2(100, 40)) then
				tags.tab = 1
			end
			if imgui.Button(u8'Îáÿçàííîñòè', imgui.ImVec2(100, 40)) then
				tags.tab = 2
			end
			if imgui.Button(u8'Îòâåòû íà\nðåïîðòû', imgui.ImVec2(100, 40)) then
				tags.tab = 3
			end
			if imgui.Button(u8'Íàêàçàíèÿ', imgui.ImVec2(100, 40)) then
				tags.tab = 4
			end
			if imgui.Button(u8'Æàëîáû', imgui.ImVec2(100, 40)) then
				tags.tab = 5
			end
			if imgui.Button(u8'Àêêàóíò', imgui.ImVec2(100, 40)) then
				tags.tab = 6
			end
			if imgui.Button(u8'ÐÏ ïðîöåññ', imgui.ImVec2(100, 40)) then
				tags.tab = 7
			end
			if imgui.Button(u8'Áåñåäà àäìèíîâ', imgui.ImVec2(100, 40)) then
				tags.tab = 8
			end
			if imgui.Button(u8'Îñí. ïðàâèëà', imgui.ImVec2(100, 40)) then
				tags.tab = 9
			end
			if imgui.Button(u8'Êîìàíäû', imgui.ImVec2(100, 40)) then
				tags.tab = 10
			end
			if imgui.Button(u8'×èòû', imgui.ImVec2(100, 40)) then
				tags.tab = 11
			end
			if imgui.Button(u8'Ìåðîïðèÿòèÿ', imgui.ImVec2(100, 40)) then
				tags.tab = 12
			end
			if imgui.Button(u8'/ao è /o', imgui.ImVec2(100, 40)) then
				tags.tab = 13
			end
			if imgui.Button(u8'Ôðàêöèè', imgui.ImVec2(100, 40)) then
				tags.tab = 14
			end
			if imgui.Button(u8'Îáùåíèå â\nñîö. ñåòÿõ', imgui.ImVec2(100, 40)) then
				tags.tab = 15
			end
			imgui.EndChild()
			imgui.SameLine(120)
			imgui.VerticalSeparator()
			imgui.SameLine()
			
			if tags.tab == 1 then
				imgui.BeginChild('1', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("1.1 - Àäìèíèñòðàòîðó çàïðåùåíî èñïîëüçîâàòü \níåíîðìàòèâíóþ ëåêñèêó â ÷àò, â âèï ÷àò, à â îñîáåííîñòè â ñòîðîíó èãðîêîâ. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n1.2 - Àäìèíèñòðàòîðó çàïðåùåíî óãðîæàòü èãðîêó/àäìèíó. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n1.3 - Àäìèíèñòðàòîðó çàïðåùåíî \náàíèòü/âàðíèòü/êèêàòü/ìóòèòü èãðîêîâ/àäìèíîâ èç-çà ëè÷íîé íåïðèÿçíè. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð ëèáî æå ñíÿòèå.{FFFFFF}\n1.4 - Àäìèíèñòðàòîðó çàïðåùåíî âûäàâàòü èãðîêó/àäìèíó \nçàïðåùåííîå îðóæèå. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n1.5 - Àäìèíèñòðàòîðó çàïðåùåíî èãíîðèðîâàòü ðåïîðò. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð{FFFFFF} \n{00FF00}> (Èñêëþ÷åíèå: ÐÏ ïî âîçìîæíîñòè îòâå÷àòü íà 2-3 ðåïîðòà){FFFFFF}\n1.6 - Àäìèíèñòðàòîðó ñòðîãî çàïðåùåíî óïîìèíàòü/îñêîðáëÿòü \nðîäíþ èãðîêà/äðóãîãî àäìèíèñòðàòîðà. \n> {FF0000}Íàêàçàíèå: ñíÿòèå ñ ïîñòà Àäìèíèñòðàòîðà + IP ban{FFFFFF}\n1.6 - Àäìèíèñòðàòîðó çàïðåùåíî íàêàçûâàòü èãðîêîâ \níå ïî ñèñòåìå íàêàçàíèé. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n1.7 - Àäìèíèñòðàòîðó çàïðåùåíî ãðóáîå èëè íåàäåêâàòíîå îáùåíèå ñ \nèãðîêîì èëè Àäìèíèñòðàòîðîì. [Ïðèìåð: «ñëûøü òû», «àõðåíåë?»]. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð » ñíÿòèå ñ Àäìèíèñòðàòèâíûõ ïðàâ{FFFFFF}\n1.8 - Àäìèíèñòðàòîðó çàïðåùåíî ôëóäèòü ñîîáùåíèÿìè/êîìàíäàìè è ò.ï. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð{FFFFFF}\n")
				imgui.EndChild()
			elseif tags.tab == 2 then
				imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("2.1 - Àäìèíèñòðàòîð îáÿçàí ñëåäèòü çà \nïîðÿäêîì íà ñåðâåðå [Ïðåäîòâðàùàòü ëþáûå íàðóøåíèÿ]\n2.2 - Àäìèíèñòðàòîð ñåðâåðà äîëæåí ñîîáùàòü Ñòàðøåé Àäìèíèñòðàöèè \nî íàðóøåíèÿõ ñî ñòîðîíû äðóãèõ àäìèíèñòðàòîðîâ\n2.3 - Àäìèíèñòðàòîð îáÿçàí îòâå÷àòü íà æàëîáû [Ïðåäîòâðàùàòü offtop â ðåïîðò] \n{00FF00}Èñêëþ÷åíèå: Æàëîáû êîòîðûå íåëüçÿ ðàçîáðàòü, ÿâëÿþòñÿ íåïîíÿòíûìè.{FFFFFF}\n2.4 - Ïðè ñèñòåìàòè÷åñêîì íåâûïîëíåíèè îáÿçàííîñòåé \nÀäìèíèñòðàòîðà âû áóäåòå ñíÿòû ñ ïîñòà Àäìèíèñòðàòîðà.\n")
				imgui.EndChild()
			elseif tags.tab == 3 then
				imgui.BeginChild('3', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("3.1 - Àäìèíèñòðàòîð äîëæåí îáùàòüñÿ ñ èãðîêàìè íà «Âû»\nè íå îòâå÷àòü òàêèì îáðàçîì:\n	Íåëüçÿ:\n	1) Èñïîëüçîâàòü íåöåíçóðíûå âûðàæåíèÿ â ñâîèõ ñëîâàõ.\n	2) Íåëüçÿ îòâå÷àòü èãðîêàì òðàíñëèòîì [Privet]\n	3) Îòâåò äîëæåí áûòü Ìàêñèìàëüíî ïîäðîáåí è \n	ðàçâåðíóò, ÷òîá èãðîê âàñ ïîíÿë.\n	4) Íåëüçÿ èñïîëüçîâàòü «CapsLock» â ñâîèõ ñëîâàõ, ïîìèìî çàãëàâíîé\n	áóêâû.\n	{FF0000}Íàêàçàíèå çà íàðóøåíèå äàííûõ ïóíêòîâ: ïèñüìåííûé âûãîâîð.{FFFFFF}")
				imgui.EndChild()
			elseif tags.tab == 4 then
				imgui.BeginChild('4', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("4.1 - Àäìèíèñòðàòîð îáÿçàí âûäàâàòü íàêàçàíèÿ çà íàðóøåíèÿ òîëüêî \nïî ñèñòåìå íàêàçàíèé [Èñêëþ÷åíèé íåòó]\n4.2 - Àäìèíèñòðàòîð äîëæåí õðàíèòü äîêàçàòåëüñòâà íà ñâîè íàêàçàíèÿ â \nòå÷åíèè 3-õ äíåé, äàëüøå îí ìîæåò èõ óäàëÿòü.")
				imgui.EndChild()
			elseif tags.tab == 5 then
				imgui.BeginChild('5', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("5.1 - Çàïðåùåíî çàêðûâàòü æàëîáó ïîäàííóþ íà âàñ è \nïîäàííóþ íà Àäìèíèñòðàòîðà \n{0000FF}[Çàêðûâàòü æàëîáó íà Àäìèíèñòðàöèþ ìîæåò òîëüêî ÃÀ/ÇÃÀ]{FFFFFF}\n5.2 - Àäìèíèñòðàòîð èìååò ïðàâî îòêëîíèòü æàëîáó, \nâ êîòîðîé íå ïðèñóòñòâóåò äîê-â íàðóøåíèÿ, \nâ êîòîðîé ïðèñóòñòâóåò íåöåíçóðíàÿ ëåêñèêà è ò.ï\n5.3 - Àäìèíèñòðàòîð îáÿçàí çàêðûâàòü æàëîáó òîëüêî ïî îáðàçöó!\n5.4 - Àäìèíèñòðàòîð îáÿçàí ïðåäîñòàâèòü äîê-âû íàðóøåíèÿ, \nåñëè åãî ïîïðîñèëà Ñò.Àäìèíèñòðàöèÿ â òå÷åíèè 24õ ÷àñîâ")
				imgui.EndChild()
			elseif tags.tab == 6 then
				imgui.BeginChild('6', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("6.1 - Àäìèíèñòðàòîðó çàïðåùåíî ïåðåäàâàòü àêêàóíò 3-èì ëèöàì. \n> {FF0000}Íàêàçàíèå: ñíÿòèå ñ Àäìèíèñòðàòèâíûõ ïðàâ. \n> {00FF00}[Èñêëþ÷åíèå: ðàçðåøåíèå Ñò.Àäìèíèñòðàöèè]{FFFFFF}\n6.2 - Àäìèíèñòðàòîð äîëæåí ïîñòàâèòü íàäåæíûé ïàðîëü\n6.3 - Àäìèíèñòðàòîðó çàïðåùåíî ïðîäàâàòü ñâîé àêêàóíò - \n> {FF0000}Ñíÿòèå âñåõ ïðèâåëåãèé.{FFFFFF}\n6.4 - Àäìèíèñòðàòîðó çàïðåùåíî ñëèâàòü àäì.ïðàâà/ëèä.ïðàâà/õåëï.ïðàâà \níà àêêàóíò. \n> {FF0000}Íàêàçàíèå: Ñíÿòèå ñ àäì ïðàâ + áàí íàâñåãäà")
				imgui.EndChild()
			elseif tags.tab == 7 then
				imgui.BeginChild('7', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("7.1 - Àäìèíèñòðàòîðó çàïðåùåíî ïðåïÿòñòâîâàòü Role Play ïðîöåññó\n7.2 - Àäìèíèñòðàòîðó çàïðåùåíî èñïîëüçîâàòü àäì.êîìàíäû â ÐÏ ïðîöåññå.\n7.3 - Àäìèíèñòðàòîðó çàïðåùåíî èñïîëüçîâàòü ÷èòû â Role Play ïðîöåññå.")
				imgui.EndChild()
			elseif tags.tab == 8 then
				imgui.BeginChild('8', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("8.1 - Àäìèíèñòðàòîðó çàïðåùåíî ñëèâàòü èíôîðìàöèþ ñ àäì.áåñåäû \n3-èì ëèöàì. \n> {FF0000}Íàêàçàíèå: ñíÿòèå ñ àäìèíèñòðàòèâíûõ ïðàâ{FFFFFF}\n8.2 - Àäìèíèñòðàòîðó çàïðåùåíî îñêîðáëÿòü äðóãèõ \nàäìèíèñòðàòîðîâ â áåñåäå.\n8.3 - Àäìèíèñòðàòîðó çàïðåùåíî óïîìèíàòü/îñêîðáëÿòü ðîäèòåëåé \nàäìèíîâ/èãðîêîâ â àäì áåñåäå.\n8.4 - Àäìèíèñòðàòîðó çàïðåùåíî ðåêëàìèðîâàòü èíûå ïðîåêòû\n8.5 - Àäìèíèñòðàòîðó çàïðåùåíî îñêîðáëÿòü îñíîâàòåëÿ ñåðâåðà")
				imgui.EndChild()
			elseif tags.tab == 9 then
				imgui.BeginChild('9', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("9.1 - Àäìèíèñòðàòîðó Çàïðåùåíî èñïîëüçîâàòü ÷èòû íèæå 10LVL. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n9.2 - Àäìèíèñòðàòîðó çàïðåùåíî ñëåäèòü çà Àäìèíèñòðàòîðîì 12LVL \náåç åãî ðàçðåøåíèÿ. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n9.3 - Àäìèíèñòðàòîðó çàïðåùåíî èìåòü ñâîé ñåðâåð/áûòü Àäìèíèñòðàòîðîì \níà èíîì ñåðâåðå/ïèàðèòü äðóãèå ñåðâåðà. \n> {FF0000}Íàêàçàíèå: ñíÿòèå ñ àäì.ïðàâ+âñåõ ïðèâèëåãèé.{FFFFFF}\n9.4 - Àäìèíèñòðàòîðó çàïðåùåíî òåëåïîðòèðîâàòüñÿ ê \nÑò.Àäìèíèñòðàöèè/òåëåïîðòèðîâàòü Ñò.Àäìèíèñòðàöèþ áåç èõ ðàçðåøåíèÿ.\n8.5 - Àäìèíèñòðàòîðó çàïðåùåíî äìèòü èãðîêîâ \n> {00FF00}Òîëüêî åñëè ýòî íå ÿâëÿåòñÿ ñàìîîáîðîíîé èëè æå \n{00FF00}íå ÿâëÿåòñÿ ÷àñòüþ ðï ñèòóàöèè, â êîòîðîé îí ó÷àñòâóåò.{FFFFFF} \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n9.6 - Çàïðåùåíî ðàñïðîñòðàíÿòü ïîñòîðîííèå ïðîãðàììû èãðîêàì. \n> {FF0000}Íàêàçàíèå: óñòíûé » ïèñüìåííûé âûãîâîð.{FFFFFF}\n9.8 - Àäìèíèñòðàòîðó çàïðåùåíî áëàòèòü êîãî ëèáî. \n> {FF0000}Íàêàçàíèå: ñíÿòèå ñ Àäìèíèñòðàòèâíûõ ïðàâ{FFFFFF}\n9.9 - Ïîêðûâàòåëüñòâî èãðîêîâ ÷åðíîãî ñïèñêà \nñåðâåðà ðàñöåíèâàåòñÿ êàê áëàò. \n> {FF0000}Íàêàçàíèå: Ñíÿòèå ñ àäìèíèñòðàòèâíûõ ïðàâ.{FFFFFF}")
				imgui.EndChild()
			elseif tags.tab == 10 then
				imgui.BeginChild('10', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("10.1 - Çàïðåùåíî èñïîëüçîâàòü êîìàíäó [/mp] âíå ìåðîïðèÿòèÿ. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.{FFFFFF}\n10.2 - Çàïðåùåíî âûäàâàòü èãðîêó áîëüøå ÷åì 50HP [/sethp]. \n> {FF0000}Íàêàçàíèå: óñòíûé âûãîâîð » ïèñüìåííûé âûãîâîð. \n> {00FF00}Ìîæíî ïîìî÷ü â ÐÏ åñëè áûëè ïîìåõè \n{00FF00}ñîçäàííûå èãðîêàìè èëè äðóãèìè ïðè÷èíàìè{FFFFFF}\n10.3 - Çàïðåùåíî îòïðàâëÿòü èãðîêîâ íà ñïàâí [/gotosp], \nñíà÷àëà íóæíî ïðîâåðèòü, ÷åì îí çàíèìàåòñÿ, ÷òîáû íå íàðóøèòü \nRP ïðîöåññ. \n> {FF0000}Íàêàçàíèå: óñòíûé âûãîâîð » ïèñüìåííûé âûãîâîð. \n> {00FF00}Çàñïàâíèòü èãðîêà ìîæíî â ñëó÷àå åñëè èãðîê çàñòðÿë, \n{00FF00}èëè ñîçäàåò ïîìåõó äðóãèì\n10.4 - Çàïðåùåíî âûäàâàòü ñåáå/äðóãîìó ÷åëîâåêó ëèäåðñêèé ïîñò/ïîñò \nçàìåñòèòåëÿ FBI, StreetRacers, Hitman ñ ïîìîùüþ êîìàíäû \n/leader, /makezam, /agiverank\n>{00FF00} Èñêëþ÷åíèå: Äàíî ðàçðåøåíèå îò ñëåäÿùèõ çà ôðàêöèåé íà âûäà÷ó ñåáå \n{00FF00}ëèäåðñêîãî ïîñòà, ïîñòà çàìåñòèòåëÿ èõ ôðàêöèè. \n> {FF0000}Íàêàçàíèå: óñòíûé âûãîâîð » ïèñüìåííûé âûãîâîð.{FFFFFF}\n10.5 - Ðàçðåøåíî âûäàâàòü DP èãðîêó ðàç â \näâå íåäåëè íà ñìåíó èãðîâîãî íèêà.")
				imgui.EndChild()
			elseif tags.tab == 11 then
				imgui.BeginChild('11', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("11.1 - Çàïðåùåíî èñïîëüçîâàíèå ÷èòîâ ïðè èãðîêàõ. \n> {FF0000}Íàêàçàíèå: óñòíûé âûãîâîð » ïèñüìåííûé âûãîâîð.{FFFFFF}\n11.2 - Çàïðåùåíî èñïîëüçîâàíèå ÷èòîâ â RolePlay ïðîöåññå. \n> {FF0000}Íàêàçàíèå: ïèñüìåííûé âûãîâîð.")
				imgui.EndChild()
			elseif tags.tab == 12 then
				imgui.BeginChild('12', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("12.1 - ÌÏ ìîæíî ïðîâîäèòü ñ 7LvL àäìèíêè îò îíëàéíà âûøå {FFFF00}25{FFFFFF} ÷åëîâåê. \nDP íå âûøå 30.000. Ìàøèíû ñ ðàçðåøåíèÿ ãë.àäìèíèñòðàöèè\n12.2 - Çàïðåùåíî áðàòü ñåáå â ïîìîùíèêè èãðîêîâ\n12.3 - Çàïðåùåíî èãíîðèðîâàòü íàðóøåíèÿ íà ÌÏ\n12.4 - Ïîìîùíèêîì ïðîâîäÿùåãî ìîæåò áûòü \nòîëüêî Àäìèíèñòðàòîð [Èñêëþ÷åíèé íåòó]\n12.5 - Àäìèíèñòðàòîðó çàïðåùåíî íàõîäèòñÿ íà ìåðîïðèÿòèè\n>{00FF00} [Èñêëþ÷åíèå: ðàçðåøåíèå ïðîâîäÿùåãî]\n12.6 - Çàïðåùåíî ïðîâîäèòü ÌÏ íà äîíàò ìàøèíû\n> {00FF00}[Èñêëþ÷åíèå: Ðàçðåøåíèå ÃÀ]\n11.7 - Çàïðåùåíî äåëàòü ÃÐÏ áåç ðàçðåøåíèÿ ÃÀ.")
				imgui.EndChild()
			elseif tags.tab == 13 then
				imgui.BeginChild('13', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("13.1 - Êîìàíäà /o èñïîëüçóåòñÿ òîëüêî äëÿ \nîïîâåùåíèÿ èãðîêîâ âàæíîé èíôîðìàöèåé, \nèëè æå äëÿ îïîâåùåíèÿ çàìîâ/ëèäåðîâ ÷òîáû äåëàëè íàáîðû.\n13.2 - Êîìàíäà /ao èñïîëüçóåòñÿ äëÿ îïîâåùåíèÿ \nèãðîêîâ î ïðåäñòîÿùåì ìåðîïðèÿòèè.")
				imgui.EndChild()
			elseif tags.tab == 14 then
				imgui.BeginChild('14', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("14.1 - Àäìèíèñòðàòîðó çàïðåùåíî íàõîäèòüñÿ âî ôðàêöèÿõ ãåòòî\n> {00FF00}[Èñêëþ÷åíèå: 1-4LVL àäìèíèñòðàòîðà]")
				imgui.EndChild()
			elseif tags.tab == 15 then
				imgui.BeginChild('15', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("14.1 Àäìèíèñòðàöèè çàïðåùåíî îñêîðáëÿòü/óïîìèíàòü ðîäíþ \nâ ëþáîé ôîðìå ïî îòíîøåíèþ ê èãðîêàì â ñîöèàëüíûõ ñåòÿõ \n(Ïîäñëóøêà/îôô.ãðóïïà/ïðîâåðêà äèñêîðä)\n> {FF0000}Íàêàçàíèå: Ñíÿòèå ñ àäìèí. ïðàâ")
				imgui.EndChild()
			end
		end
		if tags.catalog == 2 then
			imgui.BeginChild('Helpers', imgui.ImVec2(580, 393), false, imgui.WindowFlags.NoScrollbar)
			imgui.TextColoredRGB("{FFFF00}1. Õåëïåðû îáÿçàíû:{FFFFFF}\n\n1.1 - Îòâå÷àòü íà âñå âîïðîñû îò èãðîêîâ (Êðîìå íåàäåêâàòíûõ/îñêîðáèòåëüíûõ)\n1.2 - Îòëè÷íî çíàòü ïðàâèëà ñåðâåðà\n1.4 - Îòíîñèòüñÿ êî âñåì èãðîêàì íà ðàâíûõ. Íå èìåòü ïðåäâçÿòîñòè íè ê êîìó èç íèõ.\n1.5 - Îáúÿñíÿòü ïðè÷èíó íàêàçàíèÿ â ñëó÷àå åãî âûäà÷è.\n1.6 - Îáúÿñíÿòü/ðàçúÿñíÿòü àñïåêòû èãðû èãðîêàì. (Ïðàâèëà, ñóòü èãðû, ïåðâûå øàãè)\n{FFFFFF}\n{FF0000}2. Õåëïåðàì çàïðåùàåòñÿ:{FFFFFF}\n2.1 - Èãíîðèðîâàòü âîïðîñû. {FF0000}Íàêàçàíèå: ïîíèæåíèå â ëâë+âûãîâîð.{FFFFFF}\n2.2 - Ïðîâîöèðîâàòü èãðîêîâ íà îñêîðáëåíèÿ, ññîðû è ðîçíè, à òàêæå ñàìèì îñêîðáëÿòü èãðîêîâ \n{FF0000}Íàêàçàíèå: âûãîâîð/ñíÿòèå ñ õåëï.ïîñòà{FFFFFF}\n2.3 - Ïîëüçîâàòüñÿ ïðàâàìè â ëè÷íûõ öåëÿõ, ïðåâûøàòü ñâîè ïîëíîìî÷èÿ \n{FF0000}Íàêàçàíèå: âûãîâîð/ñíÿòèå ñ õåëï.ïîñòà{FFFFFF}\n2.4 - Íàêàçûâàòü èãðîêîâ ïî ëè÷íûì ïðè÷èíàì; {FF0000}Íàêàçàíèå: âûãîâîð/ñíÿòèå ñ õåëï.ïîñòà{FFFFFF}\n2.5 - Ïîëüçîâàòüñÿ ÷èò-ïðîãðàììàìè - {FF0000}Íàêàçàíèå: Ñíÿòèå ñ õåëïåðñêèõ ïðàâ{FFFFFF}\n2.6 - Îñêîðáëÿòü, óíèæàòü, ïðîâîöèðîâàòü èãðîêîâ/õåëïåðîâ/àäìèíîâ. {FF0000}Íàêàçàíèå: âûãîâîð.{FFFFFF}\n2.7 - Äàâàòü ëîæíûå/íåàäåêâàòíûå îòâåòû èãðîêàì. {FF0000}Íàêàçàíèå: Âûãîâîð/ñíÿòèå ñ õåëï.ïîñòà")
			imgui.EndChild()
		end
		if tags.catalog == 3 then
			imgui.BeginChild('Ïóíêòû', imgui.ImVec2(115, 390), false, imgui.WindowFlags.NoScrollbar)
			if imgui.Button(u8'Îáùèå\nïðàâèëà', imgui.ImVec2(100, 40)) then
				tags.ghetto = 1
			end
			if imgui.Button(u8'Ëåêñèêà', imgui.ImVec2(100, 40)) then
				tags.ghetto = 2
			end
			if imgui.Button(u8'Ïîåçäêà\nçà áîåïðèï.', imgui.ImVec2(100, 40)) then
				tags.ghetto = 3
			end
			if imgui.Button(u8'Ñîôòû', imgui.ImVec2(100, 40)) then
				tags.ghetto = 4
			end
			if imgui.Button(u8'Ðàöèÿ (/f)', imgui.ImVec2(100, 40)) then
				tags.ghetto = 5
			end
			if imgui.Button(u8'Ñîñòàâ', imgui.ImVec2(100, 40)) then
				tags.ghetto = 6
			end
			if imgui.Button(u8'Êàïò', imgui.ImVec2(100, 40)) then
				tags.ghetto = 7
			end
			imgui.EndChild()
			imgui.SameLine(120)
			imgui.VerticalSeparator()
			imgui.SameLine()
			if tags.ghetto == 1 then
				imgui.BeginChild('1', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}Çàïðåùåíî:{FFFFFF}\nÂûõîäèòü èç èãðû/â AFK ïðè ÐÏ îáûñêå îò ïîëèöèè. \n{FF0000}[Íàêàçàíèå: /warn]{FFFFFF}\n{FFFFFF}\nÓáèâàòü ìèðíûõ æèòåëåé íà ãëàâíîì ðàéîíå áàíäû áåç ÐÏ ïðè÷èíû. \n{FF0000}[Íàêàçàíèå: /warn]{FFFFFF}\n{FFFFFF}\nÓáèâàòü ìèðíûõ æèòåëåé íà òåððèòîðèè âðàæåñêîé áàíäû. \n{FF0000}[Íàêàçàíèå: /warn]{FFFFFF}\n{FFFFFF}\nÂûõîä âî âðåìÿ êàïòà \n{FF0000}[Íàêàçàíèå: /warn, ïåðåêðàñ òåððèòîðèè]{FFFFFF}\n{FFFFFF}\nÓâîëüíÿòü ÃÑ/ÇÃÑ ãåòòî. Åñëè îí çàø¸ë â áàíäó ÷åðåç /ainvite \n{FF0000}[Íàêàçàíèå: âûãîâîð/âàðí]{FFFFFF}\n{FFFFFF}\n{00FF00}Ðàçðåøåíî:{FFFFFF}\nÓñòðàèâàòü òî÷êè ïî ñáûòó íàðêîòèêîâ íà ñâîåé òåððèòîðèè\nÏðîãîíÿòü ìèðíûõ æèòåëåé ñ ãëàâíîãî ðàéîíà ÐÏ ïóò¸ì")
				imgui.EndChild()
			elseif tags.ghetto == 2 then
				imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}Çàïðåùåíî:{FFFFFF}\nÈñïîëüçîâàòü êàïñ. {FF0000}[Íàêàçàíèå: /mute íà 10 ìèíóò]{FFFFFF}\nÈñïîëüçîâàòü òðàíñëèò. {FF0000}[Íàêàçàíèå: /mute íà 10 ìèíóò]\n{00FF00}Ðàçðåøåíî:\nÈñïîëüçîâàòü ÌÃ íà òåððèòîðèè ãåòòî, åñëè íå ïðîèñõîäèò ÐÏ ñèòóàöèÿ.\n{FFFFFF}\nÂûðàæåíèå ýìîöèé ñìåõà, \níàïðèìåð 'ÀÕÕÀÕÀÕÀÕÀ' íå çàïðåùåíî, è íå íàêàçûâàåòñÿ ìóòîì.\n{FFFFFF}\nÈñïîëüçîâàíèå ìàòîâ, íå ñîäåðæàùèõ îñêîðáëåíèÿ èãðîêîâ èëè \nàäìèíèñòðàöèè.")
				imgui.EndChild()
			elseif tags.ghetto == 3 then
				imgui.BeginChild('3', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}Çàïðåùåíî:{FFFFFF}\nÓáèâàòü âîåííûõ çà ïðåäåëàìè âîåííîé áàçû. {FF0000}[Íàêàçàíèå: /prison 30 ìèíóò]{FFFFFF}\nÁåæàòü îäíîìó íà òîëïó âîåííûõ. {FF0000}[Íàêàçàíèå: /prison íà 20 ìèíóò]{FFFFFF}\nÈñïîëüçîâàòü áàãè ñåðâåðà. {FF0000}[Íàêàçàíèå: /prison íà 60 ìèíóò]{FFFFFF}\n\n{00FF00}Ðàçðåøåíî:{FFFFFF}\nÓáèâàòü âîåííûõ çà ïðåäåëàìè áàçû, åñëè âû áåæàëè çà íèì îò íå¸")
				imgui.EndChild()
			elseif tags.ghetto == 4 then
				imgui.BeginChild('4', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}Çàïðåùåíî:{FFFFFF}\nÈñïîëüçîâàòü ëþáîé ñîôò, äàþùèé ïðåèìóùåñòâî íàä èãðîêàìè. \n{FF0000}[Íàêàçàíèå: /prison 120 ìèíóò èëè áëîêèðîâêà àêêàóíòà]{FFFFFF}")
				imgui.EndChild()
			elseif tags.ghetto == 5 then
				imgui.BeginChild('5', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}Çàïðåùåíî:{FFFFFF}\nÔëóäèòü â ðàöèþ. {FF0000}[Íàêàçàíèå: /mute íà 10 ìèíóò]{FFFFFF}\nÊàïñèòü â ðàöèþ. {FF0000}[Íàêàçàíèå: /mute íà 10 ìèíóò]{FFFFFF}\nÏèñàòü òðàíñëèòîì â ðàöèþ. {FF0000}[Íàêàçàíèå: /mute íà 10 ìèíóò]{FFFFFF}\n{00FF00}Ðàçðåøåíî:\nÌÃ â ÷àòå ôðàêöèè.")
				imgui.EndChild()
			elseif tags.ghetto == 6 then
				imgui.BeginChild('6', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}Çàïðåùåíî:{FFFFFF}\nÈìåòü ëèäåðó â ñîñòàâå áàíäû áîëåå 3-õ çàìåñòèòåëåé. {FF0000}[Íàêàçàíèå: âûãîâîð]{FFFFFF}\nÌèíèìàëüíîå êîëè÷åñòâî ÷ëåíîâ áàíäû íà êàïò [2-7].\nÇàìåñòèòåëü ìîæåò áûòü ïîñòàâëåí ïî äîâåðèþ.")
				imgui.EndChild()
			elseif tags.ghetto == 7 then
				imgui.BeginChild('7', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}Çàïðåùåíî:{FFFFFF}\n> Íàõîäèòñÿ íà êðûøå/ìàøèíå âî âðåìÿ êàïòà. {FF0000}[Íàêàçàíèå: êèê]{FFFFFF}\n> Oñêîðáëÿòü èãðîêîâ è èõ ðîäíûõ. {FF0000}\n[Íàêàçàíèÿ: Îñê. Èãðîêà - /mute íà 30 ìèíóò; Îñê. Ðîäíè - áàí ïî IP]{FFFFFF}\n> DB, SK, TK. {FFFFFF}\n> Êàïò ðåñïû. {FF0000}[Íàêàçàíèå: âûãîâîð ëèäåðó èëè /warn òîìó êòî íà÷àë êàïò]{FFFFFF}\n> Ñòîÿòü â AFK íà êàïòå. {FF0000}[Íàêàçàíèå: êèê]{FFFFFF}\n> Çàïðåùåíî èñïîëüçîâàòü êîìàíäó /clist íà êàïòå. {FF0000}[Íàêàçàíèå: /warn, /kick]{FFFFFF}\n> Ïîìåõà êàïòó. {FF0000}[Íàêàçàíèå: êèê/îòïðàâëåíèå íà ñïàâí]{FFFFFF}\n> Êèëëû âíå êâ. {FF0000}[Íàêàçàíèå: ïðåäóïðåæäåíèå íà âàø àêêàóíò]{FFFFFF}\n> Àíòè êàïò ðàçðåø¸í çà ìèíóòó äî íà÷àëà êàïòà. \nÅñëè àíòè êàïò èä¸ò ïîçæå, òî èãðîê ïîëó÷àåò {FF0000}âàðí.{FFFFFF}\n> Íåÿâêà íà êàïò. {FF0000}[Íàêàçàíèå: ïðåäóïðåæäåíèå íà âàø àêêàóíò]{FFFFFF}\n> /mask íà êàïòå. {FF0000}[Íàêàçàíèå: ïðåäóïðåæäåíèå íà âàø àêêàóíò]{FFFFFF}\n> Êàïò êóñêîì. \n{FF0000}[Íàêàçàíèå: ïðåäóïðåæäåíèå íà âàø àêêàóíò, ïåðåêðàñ òåððèòîðèè]{FFFFFF}\n{FFFFFF}\nÇàõâàòû [ÊÏÏ, Áàíêà] ðàçðåøåíû ñ 10:00 - 00:00.\nÊÏÏ - îò 5õ ÷åëîâåê\nÁàíê - îò 3õ ÷åëîâåê.\nÂñå çàõâàò÷èêè äîëæíû áûòü èç îäíîé ãðóïïèðîâêè, \nãðàæäàíñêèìè ëèöàì è ãîñ.ñîòðóäíèêàì, çàïðåùåíî çàõâàòûâàòü ÊÏÏ: \nÍàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò.")
				imgui.EndChild()
			end
		end
		if tags.catalog == 4 then
			imgui.BeginChild('uninvitegov', imgui.ImVec2(580, 393), false, imgui.WindowFlags.NoScrollbar)
			imgui.TextColoredRGB("{FFFF00}Ïðè÷èíû ïî êîòîðûì óâîëüíÿþò èãðîêà:\n{00FF00}1.{FFFFFF} Metagaming - Áðåä\n{00FF00}2.{FFFFFF} Non RP - Ïðîô.íå ïðèãîäíîñòü.\n{00FF00}3.{FFFFFF} Team Kill ( TK ) - Íàïàäàíèå íà ñîòðóäíèêîâ.\n{00FF00}4.{FFFFFF} Îòñóòñòâèå â ñòðîþ - Íåò â ñòðîþ.\n{00FF00}5.{FFFFFF} Îñêîðáëåíèå - Îñêîðáëåíèå ñîòðóäíèêîâ.\n{00FF00}6.{FFFFFF} Íåïîä÷èíåíèå - Íàðóøåíèÿ óñòàâà.\n{00FF00}7.{FFFFFF} Ñìåíà ñêèíà - Ñìåíà ôîðìû.\n{00FF00}8.{FFFFFF} Ïî ñîáñòâåííîìó æåëàíèþ - C/Æ.\n\n{FF0000}Ïðàâèëà óâîëüíåíèÿ.{FFFFFF}\n{00FF00}1.{FFFFFF} Íå èñïîëüçîâàòü íå íîðìàòèâíóþ ëåêñèêó ïðè óâîëüíåíèè.\n{00FF00}2.{FFFFFF} Íå îñêîðáëÿòü.\n{00FF00}3.{FFFFFF} Íå ïèñàòü áðåä.\n{00FF00}4.{FFFFFF} Íå èñïîëüçîâàòü êàïñ.")
			imgui.EndChild()
		end
		if tags.catalog == 5 then
			imgui.BeginChild('Ïóíêòû', imgui.ImVec2(115, 390), false, imgui.WindowFlags.NoScrollbar)
				if imgui.Button(u8'Äåìîðãàí', imgui.ImVec2(100, 40)) then
					tags.info = 1
				end
				if imgui.Button(u8'Áàí', imgui.ImVec2(100, 40)) then
					tags.info = 2
				end
				if imgui.Button(u8'Ìóò', imgui.ImVec2(100, 40)) then
					tags.info = 3
				end
				if imgui.Button(u8'Âàðí', imgui.ImVec2(100, 40)) then
					tags.info = 4
				end
				imgui.EndChild()
				imgui.SameLine(120)
				imgui.VerticalSeparator()
				imgui.SameLine()
				if tags.info == 1 then
					imgui.BeginChild('1', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("1.2 DeathMatch (DM). \n{FF0000}Íàêàçàíèå - /prison íà 30 ìèíóò\n{FFFFFF}\n1.3 DriveBy (DB). \n{FF0000}Íàêàçàíèå - /prison íà 30 ìèíóò.\n{FFFFFF}\n1.4 Èñïîëüçîâàíèå áàãîâ èãðû. \n{FF0000}Íàêàçàíèå - /prison 60 ìèíóò .\n{FFFFFF}\n1.5 Ñáèâ [×àòîì]. \n{FF0000}Íàêàçàíèå - /prison 10 ìèíóò\n{FFFFFF}\n1.6 Òàðàí êîâøîì. \n{FF0000}Íàêàçàíèå - 80 ìèíóò Äå-Ìîðãàíà.\n{FFFFFF}\n1.7 Òàðàí ìàøèíîé.\n{FF0000}Íàêàçàíèå - 30 ìèíóò äåìîðãàíà")
					imgui.EndChild()
				elseif tags.info == 2 then
					imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("2.2 Óãðîçû. \n{FF0000}Íàêàçàíèå: áëîêèðîâêà àêêàóíòà íà 3 äíÿ.\n{FFFFFF}\n2.3 Ïðîäàæà èãðîâîé âàëþòû/ïðèâèëåãèé è ò.ï çà ðåàëüíûå äåíüãè. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà àêêàóíòà íàâñåãäà.\n{FFFFFF}\n2.4 Îòêàç îò ïðîâåðêè íà ÷èòû. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà âàøåãî àêêàóíòà\n{FFFFFF}\n2.5 Âûäà÷à ñåáÿ çà Àäìèíèñòðàöèþ. \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò // next \n{FF0000}áëîêèðîâêà âàøåãî èãðîâîãî àêêàóíòà.\n{FFFFFF}\n2.6 Ïðîâîêàöèÿ. \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò\n{FFFFFF}\n2.7 Îñêîðáëåíèå ïðîåêòà. \n{FF0000}Íàêàçàíèå - /iban - áëîêèðîâêà ïî iP àäðåñó.\n{FFFFFF}\n2.8 Íèê ñîäåðæàùèé îñêîðáëåíèå/ìàò. \n{FF0000}Íàêàçàíèå - /ban\n{FFFFFF}\n2.9 Ðåêëàìà ñâîèõ YouTube/twitch/ãðóïï è ò.ä \nîòíîñÿùèõñÿ ê ñåðâåðó áåç îáñóæäåíèÿ ñî ñòàðøåé Àäìèíèñòðàöèåé. \n{FF0000}Íàêàçàíèå - /ban\n{FFFFFF}\n2.10 Çà ðåêëàìó ïîñòîðîííèõ ñåðâåðîâ, ãðóïï äðóãèõ ñåðâåðîâ è ò.ä. \n{FF0000}Íàêàçàíèå -/iban - áëîêèðîâêà ïî iP àäðåñó.\n{FFFFFF}\n2.11 Îñêîðáëåíèå îñíîâàòåëÿ ñåðâåðà. \n{FF0000}Íàêàçàíèå - /iban - áëîêèðîâêà ïî iP àäðåñó.\n{FFFFFF}\n2.12 Óïîìèíàíèå ðîäíè (ò.å îñêîðáëåíèå) \n{FF0000}Íàêàçàíèå - /iban - áëîêèðîâêà ïî iP àäðåñó.\n{FFFFFF}\n2.13 Íåàäåêâàòíîå ïîâåäåíèe. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà ÷àòà 30 ìèíóò => ïðåäóïðåæäåíèå íà âàø àêêàóíò\n{FFFFFF}\n2.14 Ìíîãîêðàòíîå DM. \n{FF0000}Íàêàçàíèå - Áëîêèðîâêà àêêàóíòà íà 2 äíÿ.\n{FFFFFF}\n2.15 Ìíîãîêðàòíîå DB. \n{FF0000}Íàêàçàíèå - Áëîêèðîâêà àêêàóíòà íà 2 äíÿ.\n{FFFFFF}\n2.16 Èñïîëüçîâàíèå ÷èò-ïðîãðàìì (Cheat). \n{FF0000}Íàêàçàíèå - Àäìèíèñòðàòîðû íå èìåþùèå êîìàíäó \n{FF0000}/ban, /offban, âûäàþò /prison íà 120 ìèíóò; \n{FF0000}Àäìèíèñòðàòîðû èìåþùèå /ban, /offban - \n{FF0000}âûäàþò áëîêèðîâêó àêêàóíòà íà 7 äíåé\n{FFFFFF}\n2.17 Èñïîëüçîâàíèå âðåäèòåëüñêèõ ÷èò-ïðîãðàìì. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà èãðîâîãî ïî iP + âíåñåíèè âàñ â ÷ñ ñåðâåðà.")
					imgui.EndChild()
				elseif tags.info == 3 then
					imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("3.2 MetaGaming (MG) - èñïîëüçîâàíèå ÎÎÑ èíôîðìàöèè \n(èç ëè÷íîé æèçíè) â IC (èãðîâîé) ÷àò. \n{FF0000}Íàêàçàíèå - /mute íà 30 ìèíóò.\n{FFFFFF}\n3.3 Íåöåíçóðíàÿ ëåêñèêà (Íåö.ëåêñèêà) \n{FF0000}Íàêàçàíèå - áëîêèðîâêà ÷àòà íà 10 ìèíóò.\n{FFFFFF}\n3.4 Íåöåíçóðíàÿ ëåêñèêà â /vad. \n{FF0000}Íàêàçàíèå - 30 ìèíóò ìóòà.\n{FFFFFF}\n3.5 Íåàäåêâàòíîå ïîâåäåíè. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà ÷àòà 30 ìèíóò èëè âàðí (ïî ìåðå íåàäåêâàòíîñòè) \n{FF0000}ëèáî áëîêèðîâêà àêêàóíòà îò 3 äíåé, äî âå÷íîãî áàíà.\n{FFFFFF}\n3.6 Translit - ïèñàòü ðóññêèå ñëîâà èñïîëüçóÿ àíãëèéñêèå áóêâû \n(ïðèìåð: privet, ya artur ). \n{FF0000}Íàêàçàíèå - /mute íà 10 ìèíóò . (Çàïðåùåíî â ëþáîì ÷àòå)\n{FFFFFF}\n3.7 CapsLock - ïèñàòü áîëüøèìè áóêâàìè (ïðèìåð: ÏÐÈÂÅÒ). \n{FF0000}Íàêàçàíèå - /mute íà 10 ìèíóò. Çàïðåùåíî â ëþáîì ÷àòå.\n{FF0000}Çàïðåùåíî ÷åðåçìåðíîå óïîòðåáëåíèå êàïñà â «/s» \n{FF0000}êîòîðîå íå çàêðåïëåíî ÐÏ ñèòóàöèåé (Ïðèìåð: ÂÑÅÌ ÊÓ ÎÒ ÂÈÒÀËÈÊÀ)\n{FF0000}(Ðàçðåøåíî : /s ËÅÆÈ ÍÀ ÇÅÌËÅ, ÈËÈ ß ÑÒÐÅËßÞ! \n{FF0000}êàïñîì ïîêàçàíî ÷òî ïåðñîíàæ íàñòðîåí àãðåññèâíî è íàìåðåíèÿ ñåðü¸çíûå.)\n{FFFFFF}\n3.8 Offtop - æàëîáà // âîïðîñ, êîòîðûå íå íåñóò çà ñîáîé ñìûñë. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà ÷àòà äëÿ ïîäà÷è æàëîá/âîïðîñîâ íà 10 ìèíóò.\n{FFFFFF}\n3.9 Îñêîðáëåíèå àäìèíèñòðàöèè (IC, OOC). \n{FF0000}Íàêàçàíèå - /mute íà 60 ìèíóò.\n{FFFFFF}\n3.10 Flood ( áîëüøå 3-õ ñîîáùåíèé). \n{FF0000}Íàêàçàíèå - /mute 10\n{FFFFFF}\n3.11Ïðîÿâëåíèå ðàñèçìà è íàöèîíàëèçìà. \n{FF0000}Íàêàçàíèå - /mute 30\n{FFFFFF}\n3.12 Îñêîðáëåíèå íàöèè (÷óðêà, õîõîë è.ò.ä).\n{FF0000}Íàêàçàíèå - /mute 60\n{FFFFFF}\n3.13 Îñêîðáëåíèå èãðîêà. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà ÷àòà íà 30 ìèíóò.\n{FFFFFF}\n3.14 Ïîïðîøàéíè÷åñòâî. \n{FF0000}Íàêàçàíèå - áëîêèðîâêà ÷àòà íà 40 ìèíóò.\n{FFFFFF}\n3.15 Ìàò â /report. \n{FF0000}Íàêàçàíèå - 60 ìèíóò ìóòà ðåïîðòà.\n{FFFFFF}\n3.16 Îòñóòñòâèå òåãîâ â ÷àòå äåïàðòàìåíòà (Ïðèìåð: [FBI] to [LSPD]). \n{FF0000}Íàêàçàíèå - áàí ÷àòà 10 ìèíóò.\n{FFFFFF}\n")
					imgui.EndChild()
				elseif tags.info == 4 then
					imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("4.2 DM in GreenZone (DM in GZ) - óáèéñòâî/íàíåñåíèå óðîíà â çåë¸íîé çîíå. \n{FF0000}Íàêàçàíèå - /warn.\n{FFFFFF}\n4.3 Spawn Kill (SK) - óáèéñòâî/íàíåñåíèå óðîíà äðóãîãî/äðóãîìó\nèãðîêà/êó íà ðåñïå (ñïàâíå). \n{FF0000}Íàêàçàíèå - /warn.\n{FFFFFF}\n4.4 Repeat Kill (RK) - âîçâðàùåíèå íà ìåñòî ñìåðòè. \n{FF0000}Íàêàçàíèå - /warn.\n{FFFFFF}\n4.5 Team Kil (TK) - óáèéñòâî/íàíåñåíèå óðîíà òèìåéòà/òó \n(èãðîêà èç Âàøåé æå îðãàíèçàöèè). \n{FF0000}Íàêàçàíèå - /warn.\n{FFFFFF}\n4.6 Ñáèâ [CLEO]. {FF0000}Íàêàçàíèå - /warn.\n{FFFFFF}\n4.7 Ïîìåõà êàïòóðó/ñòðåëå (Ïîìåõà). \n{FF0000}Íàêàçàíèå - /kick // next warn\n{FFFFFF}\n4.8 Ñðûâ êàïòà/ñòðåëû. \n{FF0000}Íàêàçàíèå - /warn\n{FFFFFF}\n4.9 Óõîä â AFK âî âðåìÿ àðåñòà // ïîõèùåíèÿ (Óõîä îò RP ñèòóàöèè). \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò.\n{FFFFFF}\n4.10 Ëþáîå NonRP äåéñòâèå. \n{FF0000}Íàêàçàíèå - /warn\n{FFFFFF}\n4.11 PowerGaming (PG) - Ïåðåîöåíêà ñèë ñâîåãî ïåðñîíàæà. \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò\n{FFFFFF}\n4.12 Îáìàí àäìèíèñòðàöèè/õåëïåðîâ. \n{FF0000}Íàêàçàíèå - /warn (â çàâèñèìîñòè îò ñòåïåíè îáìàíà);\n{FF0000}/ban 3 - áëîêèðîâêà íàâñåãäà \n{FF0000}(Óòî÷íèòü, â çàâèñèìîñòè îò ñòåïåíè òÿæåñòè îáìàíà)\n{FFFFFF}\n4.13 Îáìàí èãðîêîâ. \n{FF0000}Íàêàçàíèå - Íàêàçàíèå - /warn (â çàâèñèìîñòè îò ñòåïåíè îáìàíà);\n{FF0000}/ban 3 + ÷àñòè÷íîå îáíóëåíèå ñòàòèñòèêè\n{FFFFFF}\n4.14 Âûäà÷à ñåáÿ çà Àäìèíèñòðàöèþ. \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò // next \náëîêèðîâêà âàøåãî èãðîâîãî àêêàóíòà.\n{FFFFFF}\n4.15 Êàïò ðåñïû â ãåòòî. \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò.\n{FFFFFF}\n4.16 Ñðûâ íàáîðà/ðï/ñîáåñåäîâàíèÿ/ïðèçûâà/ñòðåëû/êàïòà. \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò.\n{FFFFFF}\n4.17 Îáñóæäåíèå äåéñòâèé àäìèíèñòðàòîðà. \n{FF0000}Íàêàçàíèå - ïðóäóïðåæäåíèå íà âàø àêêàóíò\n{FFFFFF}\n4.18 Áëàò âî ôðàêöèè. \n{FF0000}Íàêàçàíèå - âàðí (ëèäåðó 2 âûãîâîðà)\n{FFFFFF}\n4.19 NonRP NickName âî ôðàêöèè. \n{FF0000}Íàêàçàíèå - óâîëüíåíèå ñî ôðàêöèè // next \nïðåäóïðåæäåíèå íà âàø àêêàóíò.\n{FFFFFF}\n4.20 Óõîä îò íàêàçàíèÿ ëþáûì ñïîñîáîì. \n{FF0000}Íàêàçàíèå - /warn\n{FFFFFF}\n4.21 Çàõâàòû [ÊÏÏ, Áàíêà] ðàçðåøåíû ñ 10:00 - 00:00. \n{FF0000}Íàêàçàíèå - /warn\n{FFFFFF}\nÊÏÏ - îò 5õ ÷åëîâåê\nÁàíê - îò 3õ ÷åëîâåê.\nÂñå çàõâàò÷èêè äîëæíû áûòü èç îäíîé ãðóïïèðîâêè, ãðàæäàíñêèìè ëèöàì\nè ãîñ.ñîòðóäíèêàì, çàïðåùåíî çàõâàòûâàòü ÊÏÏ: \n{FF0000}Íàêàçàíèå - ïðåäóïðåæäåíèå íà âàø àêêàóíò.")
					imgui.EndChild()
				end
			end
			imgui.End()
		end
	
	if bool.fractionsmenu.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.4, sh / 3.5))
		imgui.SetNextWindowSize(imgui.ImVec2(200, 400))
		imgui.Begin(u8'Ôðàêöèè', bool.fractionsmenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0.12, 1, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.12, 0.2, 0.77, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.25, 1, 1.0))
		if imgui.Button(u8"1. LSPD", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 1')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.16, 0.16, 0.16, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.32, 0.32, 0.32, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.16, 0.16, 0.16, 1.0))
		if imgui.Button(u8"2. FBI", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 2')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.2, 0.67, 0.2, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.08, 0.48, 0.08, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.67, 0.2, 1.0))
		if imgui.Button(u8"3. Àðìèÿ: Àâèàíîñåö", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 3')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.67, 0.2, 0.2, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.51, 0.16, 0.16, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.67, 0.2, 0.2, 1.0))
		if imgui.Button(u8"4. Ì×Ñ", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 4')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.87, 0.65, 0, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.69, 0.52, 0, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.87, 0.65, 0, 1.0))
		if imgui.Button(u8"5. LCN", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 5')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1, 0.02, 0.02, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.74, 0.05, 0.05, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 0.02, 0.02, 1.0))
		if imgui.Button(u8"6. Yakuza", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 6')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.07, 0.3, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.04, 0.22, 0.33, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.07, 0.3, 0.44, 1.0))
		if imgui.Button(u8"7. Ìåðèÿ", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 7')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.Button(u8"8. Îòñóòñòâóåò", imgui.ImVec2(-0.1, 0))
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.Button(u8"9. Îòñóòñòâóåò", imgui.ImVec2(-0.1, 0))
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0.12, 1, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.12, 0.2, 0.77, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.25, 1, 1.0))
		if imgui.Button(u8"10. SFPD", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 10')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.07, 0.61, 0.93, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.08, 0.5, 0.75, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.07, 0.61, 0.93, 1.0))
		if imgui.Button(u8"11. Èíñòðóêòîðû", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 11')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.53, 0.07, 0.91, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.39, 0.07, 0.65, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.53, 0.07, 0.91, 1.0))
		if imgui.Button(u8"12. Ballas Gang", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 12')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.86, 0.84, 0.02, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.63, 0.62, 0.03, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.86, 0.84, 0.02, 1.0))
		if imgui.Button(u8"13. Vagos Gang", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 13')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.71, 0.71, 0.72, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.57, 0.57, 0.57, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.71, 0.71, 0.72, 1.0))
		if imgui.Button(u8"14. Ðóññêàÿ Ìàôèÿ", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 14')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0.62, 0, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.01, 0.41, 0.01, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0.62, 0, 1.0))
		if imgui.Button(u8"15. Groove Gang", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 15')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.25, 0.52, 0.55, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.18, 0.37, 0.39, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.52, 0.55, 1.0))
		if imgui.Button(u8"16. San News", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 16')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0.91, 0.93, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0.84, 0.85, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0.99, 1, 1.0))
		if imgui.Button(u8"17. Aztecas Gang", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 17')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0.12, 1, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.12, 0.2, 0.77, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.25, 1, 1.0))
		if imgui.Button(u8"18. Rifa Gang", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 18')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.2, 0.67, 0.2, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.08, 0.48, 0.08, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.67, 0.2, 1.0))
		if imgui.Button(u8"19. Àðìèÿ: Çîíà 51", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 19')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.Button(u8"20. Îòñóòñòâóåò", imgui.ImVec2(-0.1, 0))
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0.12, 1, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.12, 0.2, 0.77, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.25, 1, 1.0))
		if imgui.Button(u8"21. LVPD", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 21')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.Button(u8"22. Îòñóòñòâóåò", imgui.ImVec2(-0.1, 0))
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.5, 0.54, 0.59, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.35, 0.39, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.5, 0.56, 1.0))
		if imgui.Button(u8"23. Õèòìàíû", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 23')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.96, 0.31, 0, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.62, 0.21, 0.01, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.96, 0.31, 0, 1.0))
		if imgui.Button(u8"24. Street Racers", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 24')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.18, 0.55, 0.34, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.14, 0.39, 0.25, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.18, 0.55, 0.34, 1.0))
		if imgui.Button(u8"25. S.W.A.T", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 25')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.44, 0.5, 0.56, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.32, 0.35, 0.38, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.5, 0.56, 1.0))
		if imgui.Button(u8"26. Ïðàâèòåëüñòâî", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 26')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1, 0.39, 0.28, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.73, 0.31, 0.23, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 0.39, 0.28, 1.0))
		if imgui.Button(u8"27. Ïîæàðíèêè", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 27')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.86, 0.86, 0.4, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.65, 0.65, 0.31, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.86, 0.86, 0.4, 1.0))
		if imgui.Button(u8"28. Áàéêåðû", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 28')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		
		imgui.End()
	end

	if bool.blist.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.4, sh / 3.5))
		imgui.SetNextWindowSize(imgui.ImVec2(250, 400))
		imgui.Begin(u8'×åðíûé ñïèñîê èãðîêîâ SLS RP', bool.blist, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB("1. Àíòîí_Òóìàíîâ\n2. Dexter_Young\n3. Aleksey_Dolmatov\n4. Miha_Chakhov\n5. Ñàøà_Êàâàëüãèðîâ\n6. Ðóñëàí_Ìèðîíîâ\n7. Êóçÿ_Ïåòå÷êèí\n8. Gangsta_Rep\n9. Christian_Clemence\n10. German_Shegay\n11. Steffen_Kobel\n12. Federico_Selamonto\n13. Ôèëèïï_Ëîðåí\n14. Ïðîêóðåííàÿ_Øíÿãà\n15. Makcim_Cherevat\n16. Ninja_Lorin\n17. Ôîìà_Ïèòåðñêèé\n18. Ïñèõ_Ïèòåðñêèé\n19. Cenky_Salvatore\n20. Mickey_Silver\n21. Kiruwa_Kalash\n22. Êîò_Âàñüêà\n23. Àëè_Ìèðîíîâ \n24. Ali_Mironov\n25. Sava_Killer\n26. Vlad_Kadilac\n27. Vlad_Kaigorodov\n28. Õèòðûé_Âîëê\n29. Damon_Salvatore \n30. Niklaus_Mikaelson\n31. Åãîð_Êàðïîâ\n32. Momoshiki_Ootsutsuki\n33. Lorenz_Darkness\n34. Queen_Guerra \n35. Olya_Kotik\n36. Hidan_Matsurasi\n37. Dmitrii_Perekam\n38. Brixton_Mikaelson\n39. Svetlana_Basaeva \n40. Qaiyana_Maithe \n41. Anna_Basaeva\n42. Todoroki_Milfhunter\n43. Kaitlin_Zolotova\n44. Kesha_Salvatore\n45. Jaba_Davit\n46. Halva_Underground\n47. Alimbek_Bermudov\n48. Dante_Maretti\n49. Alex_Salvatore\n50. Estampillas_Hokanje \n51. Pelmsaha_Estampillas\n52. Ilya_Sadov\n53. Huge_Rain\n54. Max_Lingberg\n55. Stwix_Hexcore\n56. Givenchy_Paris\n58. Yashimoto_Gulev \n59. Polina_Dream \n60. James_Dream\n61. Egor_Safronov\n62. Yarik_Melnitsky\n63. Young_Strixx\n64. Ren_Martinez\n65. Alexei_Cheetov\n66. Holod_Shelby\n67. Alex_Main\n68. Vladislav_Milkovskei\n69. Aloevich_Yanee \n70. Morty_Lemeg \n71. Morgan_Jokson\n72. Horatio_Nelson\n73. Husen_Diorov\n74. Quartz_Jostkiy\n75. Korban_Krimov\n76. Caydam_Killaz\n77. Maksim_Bashkin\n78. Richard_Gir \n79. Warp_Inferno\n80. Yasha_Tenside\n81. Yasha_Inferno\n82. Treyz_Skillsize\n83. Lowka_Skillsize\n84. Lera_Rakova\n85. Dragon_Owo\n86. Santiz_Syndicate")
		imgui.End()
	end
	
	if bool.apanel.v then
		if isKeyJustPressed(key.VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
			imgui.ShowCursor = not imgui.ShowCursor
		end
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 1.3, sh / 4.2))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 400))
		imgui.Begin(u8' ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.SetCursorPos(imgui.ImVec2(10, 30))
		imgui.Image(img, imgui.ImVec2(280, 60))
		if imgui.Checkbox(u8'Âêëþ÷èòü ïðîñëóøèâàíèå ÷àòà', chk.chatenbl) then
			if chk.chatenbl.v == true then
				sampSendChat("/chat")
			else
				sampSendChat("/chat")
			end
		end
		if imgui.Checkbox(u8'Âêëþ÷èòü ïðîñëóøèâàíèå ñîîáùåíèé', chk.chatsmsenbl) then
			if chk.chatsmsenbl.v == true then
				sampSendChat("/chatsms")
			else
				sampSendChat("/chatsms")
			end
		end
		if imgui.Checkbox(u8'Âêëþ÷èòü àäìèíñêèé êëèñò', chk.aclist) then
			if chk.aclist.v == true then
			   sampSendChat("/aclist")
			else
			   sampSendChat("/aclist")
			end
        end
		imgui.Checkbox(u8'Ñêðûòü ÷àò õåëïåðîâ', chk.offhchat)
		imgui.Checkbox(u8'Ñêðûòü ÷àò àäìèíîâ', chk.offachat)
		if imgui.Button(u8"Óâîëèòü ñåáÿ", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/uvalme")
		end
		if imgui.Button(u8"Âçÿòü íàáîð îðóæèÿ", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/ls")
		end
		if imgui.Button(u8"Òåëåïîðò íà êàðòó äåðáè", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/gotoderby")
		end
		if imgui.Button(u8"Òåëåïîðò â ëèáåðòè ñèòè", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/liberty")
			sampAddChatMessage("Ëèáåðòè Ñèòè", 0xB4B5B7)
		end
		if imgui.Button(u8"Òåëåïîðò íà ñïàâí", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/sp")
			sampAddChatMessage("Òî÷êà ñïàâíà", 0xB4B5B7)
		end
		if imgui.Button(u8"Óáðàòü ñåáå çâåçäû", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/aclear "..myid)
		end
		if imgui.Button(u8"Ëèñò âàðíîâ", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/warnlist")
		end
		imgui.End()
	end

	if bool.chathelpers.v then
		imgui.LockPlayer = true
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'×àò õåëïåðîâ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild(' 4', imgui.ImVec2(700, 340), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB(table.concat(t1, '\n'))
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(10, 370))
		if imgui.InputText(u8'Ââîä', chk.chathelpinput, imgui.InputTextFlags.EnterReturnsTrue) then
			sampSendChat('/hc '..u8(chk.chathelpinput.v))
			chk.chathelpinput.v = ''
		end
		imgui.End()
	end
	
	if bool.chatadmins.v then
		imgui.LockPlayer = true
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'×àò àäìèíîâ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('3 ', imgui.ImVec2(700, 340), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB(table.concat(t2, '\n'))
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(10, 370))
		if imgui.InputText(u8'Ââîä', chk.chatadminput, imgui.InputTextFlags.EnterReturnsTrue) then
			sampSendChat('/a '..u8(chk.chatadminput.v))
			chk.chatadminput.v = ''
		end
		imgui.End()
	end
	
	if chk.admactionsmenu.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'Âñå äåéñòâèÿ àäìèíèñòðàöèè', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('2 ', imgui.ImVec2(700, 360), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB("{AA3333}"..table.concat(admactn, '\n{AA3333}'))
		imgui.TextColoredRGB("{AA3333}"..table.concat(admactn2, '\n{AA3333}'))
		imgui.EndChild()
		imgui.End()
	end

	if chk.reportsmenu.v then
		local sw, sh = getScreenResolution()
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'Âñå çàïèñàíûå æàëîáû èãðîêîâ íà ñåðâåðå', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('1 ', imgui.ImVec2(700, 360), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB(table.concat(reports, '\n'))
		imgui.EndChild()
		imgui.End()
	end
	
	if chk.vipchatmenu.v then
		local sw, sh = getScreenResolution()
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'Ëîã âèï ÷àòà', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('6 ', imgui.ImVec2(700, 360), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB("{FFFF00}".. table.concat(vipchatf, '\n{FFFF00}'))
		imgui.EndChild()
		imgui.End()
	end
	
	if chk.connectedplayers.v then
		local sw, sh = getScreenResolution()
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'Ëîã ïîäêëþ÷àþùèõñÿ èãðîêîâ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('6 ', imgui.ImVec2(700, 360), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB("{B4B5B7}".. table.concat(connectplayerslog, '\n{B4B5B7}'))
		imgui.EndChild()
		imgui.End()
	end
end

function samp.onShowMenu()
	if bool.remenu.v then
		return false
	end
end

function samp.onShowTextDraw(id, data)
	if bool.remenu.v then
		return false
	end
end

function samp.onHideMenu()
	if bool.remenu.v then
		return false
	end
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B and not isPauseMenuActive() and not sampIsChatInputActive() and not sampIsDialogActive() then
		if chk.connectedplayers.v or chk.vipchatmenu.v or chk.reportsmenu.v or chk.admactionsmenu.v or bool.chatadmins.v or bool.chathelpers.v or bool.apanel.v or bool.blist.v or bool.menuoffban.v or bool.menuoffwarn.v or bool.msetstat.v or bool.fractionsmenu.v or bool.giveweapon.v or bool.changetheme.v or bool.ruleswindow.v then
			consumeWindowMessage(true, false)
			if msg == 0x101 then
				chk.vipchatmenu.v = false
				bool.apanel.v = false
				bool.blist.v = false
				bool.menuoffban.v = false
				bool.menuoffwarn.v = false
				bool.msetstat.v = false
				bool.fractionsmenu.v = false
				bool.giveweapon.v = false
				bool.changetheme.v = false
				bool.ruleswindow.v = false
				bool.chathelpers.v = false
				bool.chatadmins.v = false
				chk.admactionsmenu.v = false
				chk.reportsmenu.v = false
				chk.connectedplayers.v = false
			end
		end
		if bool.lvl.v or bool.zakon.v or bool.mats.v or bool.kills.v or bool.xp.v or bool.vip.v or bool.moneybank.v or bool.moneyhand.v or bool.drugs.v or bool.auto.v or bool.narkozav.v then
			consumeWindowMessage(true, false)
			if msg == 0x101 then
				bool.lvl.v = false
				bool.zakon.v = false
				bool.mats.v = false 
				bool.kills.v = false
				bool.xp.v = false
				bool.vip.v = false
				bool.moneybank.v = false
				bool.moneyhand.v = false
				bool.drugs.v = false
				bool.auto.v = false
				bool.narkozav.v = false
				bool.msetstat.v = true
			end
		end
	end
end

function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Îáíàðóæåíî îáíîâëåíèå. Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Çàãðóæåíî %d èç %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')
                      sampAddChatMessage((prefix..'Îáíîâëåíèå çàâåðøåíî!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóñêàþ óñòàðåâøóþ âåðñèþ..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Îáíîâëåíèå íå òðåáóåòñÿ.')
            end
          end
        else
          print('v'..thisScript().version..': Íå ìîãó ïðîâåðèòü îáíîâëåíèå. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	blue()
	
	sampRegisterChatCommand('az', teleport)
	sampRegisterChatCommand('chath', hchat)
	sampRegisterChatCommand('chata', achat)
	sampRegisterChatCommand('mstat', mstats)
	sampRegisterChatCommand('weapon', weapon)
	sampRegisterChatCommand('ah', ahelp)
	sampRegisterChatCommand('cmds', cmds)
	sampRegisterChatCommand('ver', vert)
	sampRegisterChatCommand('bl', blacklist)
	sampRegisterChatCommand('stadm', stadm)
	sampRegisterChatCommand('frac', fractions)
	sampRegisterChatCommand('offwarn', offwarn)
	sampRegisterChatCommand('uns', sysmute)
	sampRegisterChatCommand('cheat', cheat)
	sampRegisterChatCommand('offban', offban)
	sampRegisterChatCommand('gd', givedonate)
	sampRegisterChatCommand('dm', dm)
	sampRegisterChatCommand('rul', rules)
	sampRegisterChatCommand('theme', theme)
	sampRegisterChatCommand('admact', admactions)
	sampRegisterChatCommand('co', contract)
	sampRegisterChatCommand('db', db)
	sampRegisterChatCommand('wa', warns)
	sampRegisterChatCommand('ip', ipget)
	sampRegisterChatCommand('cname', nameget)
	sampRegisterChatCommand('offtop', offtop)
	sampRegisterChatCommand("deletetd", del)
	sampRegisterChatCommand("showtdid", show)
	sampRegisterChatCommand("createtd", test1)
	sampRegisterChatCommand("repchat", repmenu)
	sampRegisterChatCommand("vipchat", vipchatcommand)
	sampRegisterChatCommand("cnplayers", connectedplayerscommand)
	sampRegisterChatCommand('apn', apn)
	sampRegisterChatCommand("bank", function()
		setCharCoordinates(PLAYER_PED, 1416.41, -1700.23, 13.54)
	end)
	sampRegisterChatCommand("sit", function()
		sampSendChat("/anim 57")
	end)
	sampRegisterChatCommand("addmessage", function(b)
		if #b == 0 then
			sampAddChatMessage("/addmessage [Òåêñò] (Ìîæíî èñïîëüçîâàòü RRGGBB êîäû)", -1)
		else
			sampAddChatMessage(b, -1)
		end
	end)
	sampRegisterChatCommand("aclist", function()
		sampSendChat("/aclist")
		chk.aclist.v = not chk.aclist.v
	end)
	sampRegisterChatCommand("chat", function()
		sampSendChat("/chat")
		chk.chatenbl.v = not chk.chatenbl.v
	end)
	sampRegisterChatCommand("chatsms", function()
		sampSendChat("/chatsms")
		chk.chatsmsenbl.v = not chk.chatsmsenbl.v
	end)
	sampRegisterChatCommand("ballas", function()
		sampSendChat("/gzcolor 12")
	end)
	sampRegisterChatCommand("vagos", function()
		sampSendChat("/gzcolor 13")
	end)
	sampRegisterChatCommand("grove", function()
		sampSendChat("/gzcolor 15")
	end)
	sampRegisterChatCommand("aztec", function()
		sampSendChat("/gzcolor 17")
	end)
	sampRegisterChatCommand("rifa", function()
		sampSendChat("/gzcolor 18")
	end)
	
	
	while true do
		wait(0)
		
		_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		nick = sampGetPlayerNickname(id)
		
		sampTextdrawCreate(102, "a¥ ID: ~g~"..id, 438.156, 2.835)
		sampTextdrawSetLetterSizeAndColor(102, 0.342, 2.074, 0xFFFFFFFF)
		sampTextdrawSetBoxColorAndSize(102, 1, 0x00000000, 640, 640)
		sampTextdrawSetStyle(102, 1)
		sampTextdrawSetAlign(102, 1)
		sampTextdrawSetOutlineColor(102, 1, 0xFF000000)
				
		
			
		imgui.Process = chk.connectedplayers.v or chk.vipchatmenu.v or chk.reportsmenu.v or chk.admactionsmenu.v or bool.chatadmins.v or bool.chathelpers.v or bool.window.v or bool.fractionsmenu.v or bool.blist.v or bool.remenu.v or bool.menuoffwarn.v or bool.menuoffban.v or bool.giveweapon.v or bool.msetstat.v or bool.lvl.v or bool.zakon.v or bool.mats.v or bool.kills.v or bool.xp.v or bool.vip.v or bool.moneybank.v or bool.moneyhand.v or bool.drugs.v or bool.auto.v or bool.narkozav.v or bool.ruleswindow.v or bool.changetheme.v or bool.apanel.v
		
		if not sampIsChatInputActive() and not sampIsDialogActive() then
			if isKeyDown(key.VK_R) then
				while isKeyDown(key.VK_R) do wait(80) end
				sampSendChat('/alock')
			end
		end
		
	end
end


function connectedplayerscommand()
	chk.connectedplayers.v = true
end

function vipchatcommand()
	chk.vipchatmenu.v = true
end

function repmenu()
	chk.reportsmenu.v = true
end

function admactions()
	chk.admactionsmenu.v = true
end

function del(n)
	sampTextdrawDelete(n)
end

function achat()
	bool.chatadmins.v = true
end

function show()
	for a = 0, 2304	do --cycle trough all textdeaw id
		if sampTextdrawIsExists(a) then --if textdeaw exists then
			x, y = sampTextdrawGetPos(a) --we get it's position. value returns in game coords
			x1, y1 = convertGameScreenCoordsToWindowScreenCoords(x, y) --so we convert it to screen cuz render needs screen coords
			sampAddChatMessage(a, -1) --and then we draw it's id on textdeaw position
		end
	end
end

function teleport()
    setCharCoordinates(PLAYER_PED, 1535.49, -1355.96, 169.72)
end

function blacklist()
	bool.blist.v = not bool.blist.v
end

function mstats()
	bool.msetstat.v = true
end

function ahelp()
	sampShowDialog(30, "Êîìàíäû àäìèíèñòðàòîðîâ", "{66FFCC}Òóò ïîêàçàíû âñå ÀÊÒÓÀËÜÍÛÅ êîìàíäû àäìèíèñòðàòîðîâ\n{66FFCC}Íåêîòîðûå êîìàíäû ïîêàçàíûå â /ahelp íå ðàáîòàþò.\n {33AA33}< 1 > {FFFFFF}/hp, /skin, /togphone, /pm, /re, /reoff, /iwep\n{33AA33}< 1 > {FFFFFF}(/a)dmin, /jail, /unjail /mute, /mp, /uvalme\n{33AA33}< 1 > {FFFFFF}/offreport, /alogin, /tp, /ap, /mutelist, /warnlist, /knocklist, /wantedlist\n\n{33AA33}< 2 > {FFFFFF}/getstats, /fstyle, /chat, /(g)oto, /gethere, (/o)oc, /prison /unprison\n{33AA33}< 2 > {FFFFFF}(/sp)awn, /freeze, /unfreeze, /liberty\n\n{33AA33}< 3 > {FFFFFF}/slap, /warehouse\n{33AA33}< 3 > {FFFFFF}/mark, /gotomark\n{33AA33}< 4 > {FFFFFF}/spveh, /atune, /agetstats\n\n{33AA33}< 5 > {FFFFFF}/clearchat, /givegun, /(am)embers, /ao, /delveh\n\n{33CCFF}< 6 > {FFFFFF}/balance, /getdonate\n\n{33CCFF}< 7 > {FFFFFF}/setskin, /ls, /kick, /salut\n\n{FF9900}< 8 > {FFFFFF}/setbizprod, /aclear, /gotoderby\n{FF9900}< 8 > {FFFFFF}/money, /biz\n\n{FF9900}< 9 > {FFFFFF}/offgoto, /house\n{FF9900}< 9 > {FFFFFF}/offwarn, /givecash, /freehouses\n\n{D900D3}< 10 > {FFFFFF}/warn, /unwarn, /aclist, /object, /gotosp, /jetpack, /cord, /getban\n\n{EAC700}< 11 > {FFFFFF}/sethp, /location, /setclist\n{EAC700}< 11 > {FFFFFF}/agl, /aoffline, /delltext\n\n{FF0000}< 12 > {FFFFFF}/chatsms, /setskill, /weather\n{FF0000}< 12 > {FFFFFF}/unban, /pgetip, /getip", "Çàêðûòü", "Çàêðûòü", 0)
end

function giveWeapon(id, ammo)
  local model = getWeapontypeModel(id)
  if model ~= 0 then
    if not hasModelLoaded(model) then
      requestModel(model)
      loadAllModelsNow()
      while not hasModelLoaded(model) do wait(0) end
    end
    giveWeaponToChar(playerPed, id, ammo)
    setCurrentCharWeapon(playerPed, id)
  end
end

function cmds()
	sampShowDialog(101, "Êîìàíäû {FF0000}AdminMode", "{00FF00}1. {FFFFFF}/theme 		{FFFFFF}- èçìåíèòü òåìó\n{00FF00}2. {FFFFFF}/az 			{FFFFFF}- ìîìåíòàëüíûé òåëåïîðò â àäìèí-çîíó\n{00FF00}3. {FFFFFF}/mstat 		{FFFFFF}- ìåíþ êîìàíäû /setstat\n{00FF00}4. {FFFFFF}/weapon 		{FFFFFF}- âûäà÷à îðóæèÿ\n{00FF00}5. {FFFFFF}/ah 			{FFFFFF}- àêòóàëüíûå êîìàíäû àäìèíèñòðàöèè\n{00FF00}6. {FFFFFF}/apn 			{FFFFFF}- ìåíþ ñêðèïòà\n{00FF00}7. {FFFFFF}/cmds 		{FFFFFF}- ïîêàçûâàåò âñå êîìàíäû ñêðèïòà\n{00FF00}8. {FFFFFF}/bl 			{FFFFFF}- ÷åðíûé ñïèñîê ñåðâåðà\n{00FF00}9. {FFFFFF}/stadm 		{FFFFFF}- ñïèñîê Ñòàðøåé Àäìèíèñòðàöèè\n{00FF00}10. {FFFFFF}/frac 		{FFFFFF}- ôðàêöèè\n{00FF00}11. {FFFFFF}/rul 			{FFFFFF}- ïîêàçûâàåò ìåíþ ïðàâèë ñåðâåðà\n{00FF00}12. {FFFFFF}/cheat [ID] 		{FFFFFF}- áàí èãðîêà ñ ïðè÷èíîé << ×èòû >>\n{00FF00}13. {FFFFFF}/uns 		{FFFFFF}- ðàçìóòèòü èãðîêà êîòîðûé ïîëó÷èë ñèñòåìíûé ìóò\n{00FF00}14. {FFFFFF}/offwarn 		{FFFFFF}- âàðí â îôôëàéíå\n{00FF00}15. {FFFFFF}/offban 		{FFFFFF}- áàí â îôôëàéíå\n{00FF00}16. {FFFFFF}/gd [ID] [ÄÏ] 	{FFFFFF}- ñîêðàùåííàÿ êîìàíäà âûäà÷è äîíàòà (ðàáîòàåò åñëè ó âàñ îíà êóïëåíà!)\n{00FF00}17. {FFFFFF}/dm [ID] 		{FFFFFF}- ïîñàäèòü èãðîêà â äåìîðãàí çà << ÄÌ >>\n{00FF00}18. {FFFFFF}/db [ID] 		{FFFFFF}- ïîñàäèòü èãðîêà â äåìîðãàí ñ ïðè÷èíîé << ÄÁ >>\n{00FF00}19. {FFFFFF}/wa 		{FFFFFF}- âûäàòü âàðí èãðîêó\n{00FF00}20. {FFFFFF}/ip [ID] 		{FFFFFF}- ñêîïèðîâàòü IP èãðîêà\n{00FF00}21. {FFFFFF}/cname [ID] 	{FFFFFF}- ñêîïèðîâàòü íèê èãðîêà\n{00FF00}22. {FFFFFF}/offtop [ID] 		{FFFFFF}- ìóò ðåïîðòà èãðîêà êîòîðûé îôôòîïèò\n{00FF00}23. {FFFFFF}/admact 		{FFFFFF}- ïîêàçûâàåò äåéñòâèÿ àäìèíèñòðàöèè ñ ìîìåíòà çàõîäà íà ñåðâåð\n{00FF00}24. {FFFFFF}/chata 		{FFFFFF}- ÷àò àäìèíîâ (Ìîæíî îòêëþ÷èòü åãî â /apn)\n{00FF00}25. {FFFFFF}/chath 		{FFFFFF}- ÷àò õåëïåðîâ (Ìîæíî îòêëþ÷èòü åãî â /apn)\n{00FF00}26. {FFFFFF}/vipchat 		{FFFFFF}- ïîêàçûâàåò âèï ÷àò ñ ìîìåíòà çàõîäà íà ñåðâåð\n{00FF00}27. {FFFFFF}/repchat 		{FFFFFF}- ïîêàçûâàåò âñå ðåïîðòû ñ ìîìåíòà çàõîäà íà ñåðâåð\n{00FF00}28. {FFFFFF}/cnplayers 		{FFFFFF}- ïîêàçûâàåò ïîäêëþ÷àþùèõñÿ ñ ìîìåíòà çàõîäà íà ñåðâåð\n{00FF00}29. {FFFFFF}/bank 		{FFFFFF}- òåëåïîðò ê áàíêó ËÑ", "Çàêðûòü", "", 0)
end

function vert()
	sampSendChat("/veh 497 1 0")
end

function stadm()
	sampShowDialog(45, "{FF0000}Ñòàðøàÿ Àäìèíèñòðàöèÿ", "{FFFFFF}Íèê Àäìèíèñòðàòîðà\t{FFFFFF}Äîëæíîñòü\nIsa_Kirimov\t{FF0000}Ñîçäàòåëü{FFFFFF}\nJesse_Martinez\t{FFFF00}Ðóêîâîäèòåëü{FFFFFF}\nMorgan_Krimov\t{0000FF}Ãëàâíûé Àäìèíèñòðàòîð{FFFFFF}\nMonika_Lomb\t{339900}ÃÑ ïî ãåòòî{FFFFFF}\nLucas_Stanley\t{0000FF}ÃÑ ïî ãîññ.{FFFFFF}\nDanil_Malyshev\t{3366FF}Ñò. Àäìèíèñòðàòîð{FFFFFF}\nHiashi_Salamander\t{3366FF}Ñò. Àäìèíèñòðàòîð{FFFFFF}\nFox_Yotanhaim\t{3366FF}Ñò. Àäìèíèñòðàòîð", "Çàêðûòü", "", 5)
end

function fractions()
	bool.fractionsmenu.v = not bool.fractionsmenu.v
end

function sysmute(param)
local id = string.match(param, "(%d+)")

	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /uns (ID Èãðîêà)", -1)
	else
		lua_thread.create(function()
		sampSendChat("/unmute "..id)
		wait(1000)
		sampSendChat("/o sys")
		end)
	end
	
end

function cheat(param)
local id = string.match(param, "(%d+)")

	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /cheat [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/ban "..id.." 7 ×èòû")
		end)
	end
	
end

function givedonate(arg)
local id, az = string.match(arg, "(.+) (.+)")

	if id == nil or id == "" or az == nil or az == "" then
		sampAddChatMessage("Ââåäèòå /gd [ID] [Êîë-âî]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/givedonate " .. id .. " " .. az)
		end)
	end
	
end

function dm(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /dm [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/prison "..id.." 30 DM")
		end)
	end
end

function rules()
	bool.ruleswindow.v = not bool.ruleswindow.v 
end

function contract(param)
local id = string.match(param, "(%d+)")

	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /co [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/contract "..id.." 10000000")
		end)
	end
	
end

function apn()
	bool.apanel.v = true
end

function db(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /db [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/prison "..id.." 30 DB")
		end)
	end
end

function warns(param)
local id, id2 = string.match(param, "(.+) (.+)")
	if id == nil or id == "" or id2 == "" or id2 == nil and id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /wa [ID] [Ïðè÷èíà èç ñïèñêà]", -1)
		sampAddChatMessage("{FFFFFF}Ïðè÷èíû: iz (nRP /iznas), sex (nRP /sex), rk, tk, sk, pg, ned (íåàäåêâàò)", -1)
	elseif id2 == "iz" then
		lua_thread.create(function()
		sampSendChat("/warn "..id.." nRP /iznas")
		end)
	elseif id2 == "sex" then
		lua_thread.create(function()
		sampSendChat("/warn "..id.." nRP /sex")
		end)
	elseif id2 == "rk" then
		lua_thread.create(function()
		sampSendChat("/warn "..id.." RK")
		end)
	elseif id2 == "tk" then
		lua_thread.create(function()
		sampSendChat("/warn "..id.." TK")
		end)
	elseif id2 == "sk" then
		lua_thread.create(function()
		sampSendChat("/warn "..id.." SK")
		end)
	elseif id2 == "pg" then
		lua_thread.create(function()
		sampSendChat("/warn "..id.." PG")
		end)
	elseif id2 == "ned" then
		lua_thread.create(function()
		sampSendChat("/warn "..id.." Íåàäåêâàò")
		end)
	end
end

function theme()
	bool.changetheme.v = true
end

function samp.onShowDialog(dialogId, s, t, b1, b2, text)
    for line in text:gmatch("[^\n]+") do
        if line:find('IP:		(%d+).(%d+).(%d+).(%d+)') then
            local ip11, ip22, ip33, ip44 = line:match('IP:		(%d+).(%d+).(%d+).(%d+)')
            setClipboardText(ip11.."."..ip22.."."..ip33.."."..ip44)
        end
     end
end

function hchat()
	bool.chathelpers.v = true
end

function ipget(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /ip [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/ags "..sampGetPlayerNickname(id))
		wait(100)
		sampCloseCurrentDialogWithButton(0)
		end)
	end
	sampAddChatMessage("IP èãðîêà "..sampGetPlayerNickname(id).." ["..id.. "] ñêîïèðîâàí!", 0xFFFF00)
end

function nameget(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /cname [ID]", -1)
	else
		lua_thread.create(function()
		setClipboardText(sampGetPlayerNickname(id))
		end)
	end
	sampAddChatMessage("Èìÿ èãðîêà "..sampGetPlayerNickname(id).." ["..id.. "] ñêîïèðîâàí!", 0xFFFF00)
end

function offtop(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}Ââåäèòå /offtop [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/rmute "..id.." 10 ÎôôÒîï")
		end)
	end
end

function offwarn()
	bool.menuoffwarn.v = true
end

function offban()
	bool.menuoffban.v = true
end

function weapon()
	bool.giveweapon.v = not bool.giveweapon.v
end

function blue()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function SwitchTheStyle(i)
    if i == 0 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

		style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0

        colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
        colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
        colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
        colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.ComboBg]                = colors[clr.PopupBg]
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
        colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
        -- code of blue style
    elseif i == 1 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0
		
        colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
        colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.ComboBg]                = colors[clr.PopupBg]
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
        colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
        -- code of red style
    elseif i == 2 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0

        colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
        colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
        colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
        colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
        colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
        colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
        colors[clr.Separator]              = colors[clr.Border]
        colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
        colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
        colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
        colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
        colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.ComboBg]                = colors[clr.PopupBg]
        colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
        colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35) 
    elseif i == 3 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0

        colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
        colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
        colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
        colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
        colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
        colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
        colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif i == 4 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0

        colors[clr.Text] = ImVec4(0.90, 0.90, 0.90, 1.00)
        colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
        colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
        colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
        colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
        colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
        colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
        colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
        colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
        colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
        colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif i == 5 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0

        colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
        colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
        colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
        colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
        colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
        colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
        colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
        colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
        colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
        colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
        colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
        colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
        colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
        colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
        colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
        colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
        colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
        colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
        colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
        colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
        colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
        colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
        colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
        colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
        colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
        colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
        colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
        colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
        colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
	elseif i == 6 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0

		colors[clr.Text]   = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TextDisabled]   = ImVec4(0.24, 0.24, 0.24, 1.00)
		colors[clr.WindowBg]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.ChildWindowBg]         = ImVec4(0.96, 0.96, 0.96, 1.00)
		colors[clr.PopupBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.Border]                = ImVec4(0.86, 0.86, 0.86, 1.00)
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]               = ImVec4(0.88, 0.88, 0.88, 1.00)
		colors[clr.FrameBgHovered]        = ImVec4(0.82, 0.82, 0.82, 1.00)
		colors[clr.FrameBgActive]         = ImVec4(0.76, 0.76, 0.76, 1.00)
		colors[clr.TitleBg]               = ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgCollapsed]      = ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgActive]         = ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.MenuBarBg]             = ImVec4(0.00, 0.37, 0.78, 1.00)
		colors[clr.ScrollbarBg]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ScrollbarGrab]         = ImVec4(0.00, 0.35, 1.00, 0.78)
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.00, 0.33, 1.00, 0.84)
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.00, 0.31, 1.00, 0.88)
		colors[clr.ComboBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.CheckMark]             = ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrab]            = ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrabActive]      = ImVec4(0.00, 0.39, 1.00, 0.71)
		colors[clr.Button]                = ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.ButtonHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.ButtonActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Header]                = ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.HeaderHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.HeaderActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.ResizeGrip]            = ImVec4(0.00, 0.39, 1.00, 0.59)
		colors[clr.ResizeGripHovered]     = ImVec4(0.00, 0.27, 1.00, 0.59)
		colors[clr.ResizeGripActive]      = ImVec4(0.00, 0.25, 1.00, 0.63)
		colors[clr.CloseButton]           = ImVec4(0.00, 0.35, 0.96, 0.71)
		colors[clr.CloseButtonHovered]    = ImVec4(0.00, 0.31, 0.88, 0.69)
		colors[clr.CloseButtonActive]     = ImVec4(0.00, 0.25, 0.88, 0.67)
		colors[clr.PlotLines]             = ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotLinesHovered]      = ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogram]         = ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogramHovered]  = ImVec4(0.00, 0.35, 0.92, 0.78)
		colors[clr.TextSelectedBg]        = ImVec4(0.00, 0.47, 1.00, 0.59)
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35)
	elseif i == 7 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
		
		style.Alpha = 1.0
        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0
		

		colors[clr.Text] = ImVec4(0.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.00, 0.40, 0.41, 1.00)
		colors[clr.WindowBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.Border] = ImVec4(0.00, 1.00, 1.00, 0.65)
		colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg] = ImVec4(0.44, 0.80, 0.80, 0.18)
		colors[clr.FrameBgHovered] = ImVec4(0.44, 0.80, 0.80, 0.27)
		colors[clr.FrameBgActive] = ImVec4(0.44, 0.81, 0.86, 0.66)
		colors[clr.TitleBg] = ImVec4(0.14, 0.18, 0.21, 0.73)
		colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.54)
		colors[clr.TitleBgActive] = ImVec4(0.00, 1.00, 1.00, 0.27)
		colors[clr.MenuBarBg] = ImVec4(0.00, 0.00, 0.00, 0.20)
		colors[clr.ScrollbarBg] = ImVec4(0.22, 0.29, 0.30, 0.71)
		colors[clr.ScrollbarGrab] = ImVec4(0.00, 1.00, 1.00, 0.44)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 1.00, 1.00, 0.74)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.00, 1.00, 1.00, 1.00)
		colors[clr.ComboBg] = ImVec4(0.16, 0.24, 0.22, 0.60)
		colors[clr.CheckMark] = ImVec4(0.00, 1.00, 1.00, 0.68)
		colors[clr.SliderGrab] = ImVec4(0.00, 1.00, 1.00, 0.36)
		colors[clr.SliderGrabActive] = ImVec4(0.00, 1.00, 1.00, 0.76)
		colors[clr.Button] = ImVec4(0.00, 0.65, 0.65, 0.46)
		colors[clr.ButtonHovered] = ImVec4(0.01, 1.00, 1.00, 0.43)
		colors[clr.ButtonActive] = ImVec4(0.00, 1.00, 1.00, 0.62)
		colors[clr.Header] = ImVec4(0.00, 1.00, 1.00, 0.33)
		colors[clr.HeaderHovered] = ImVec4(0.00, 1.00, 1.00, 0.42)
		colors[clr.HeaderActive] = ImVec4(0.00, 1.00, 1.00, 0.54)
		colors[clr.ResizeGrip] = ImVec4(0.00, 1.00, 1.00, 0.54)
		colors[clr.ResizeGripHovered] = ImVec4(0.00, 1.00, 1.00, 0.74)
		colors[clr.ResizeGripActive] = ImVec4(0.00, 1.00, 1.00, 1.00)
		colors[clr.CloseButton] = ImVec4(0.00, 0.78, 0.78, 0.35)
		colors[clr.CloseButtonHovered] = ImVec4(0.00, 0.78, 0.78, 0.47)
		colors[clr.CloseButtonActive] = ImVec4(0.00, 0.78, 0.78, 1.00)
		colors[clr.PlotLines] = ImVec4(0.00, 1.00, 1.00, 1.00)
		colors[clr.PlotLinesHovered] = ImVec4(0.00, 1.00, 1.00, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.00, 1.00, 1.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(0.00, 1.00, 1.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.00, 1.00, 1.00, 0.22)
		colors[clr.ModalWindowDarkening] = ImVec4(0.04, 0.10, 0.09, 0.51)
	elseif i == 8 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
		
        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0
		
		colors[clr.Text]                   = ImVec4(0.01, 0.36, 1.00, 1.00);
		colors[clr.TextDisabled]           = ImVec4(0.00, 0.60, 0.67, 0.97);
		colors[clr.WindowBg]               = ImVec4(0.02, 0.00, 0.06, 1.00);
		colors[clr.ChildWindowBg]          = ImVec4(0.09, 0.01, 0.15, 0.26);
		colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00);
		colors[clr.Border]                 = ImVec4(0.07, 0.10, 0.15, 0.56);
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.49);
		colors[clr.FrameBg]                = ImVec4(0.06, 0.19, 0.46, 0.29);
		colors[clr.FrameBgHovered]         = ImVec4(0.03, 0.00, 0.06, 0.22);
		colors[clr.FrameBgActive]          = ImVec4(0.00, 0.00, 0.00, 0.10);
		colors[clr.TitleBg]                = ImVec4(0.01, 0.01, 0.05, 1.00);
		colors[clr.TitleBgActive]          = ImVec4(0.14, 0.26, 0.55, 1.00);
		colors[clr.TitleBgCollapsed]       = ImVec4(0.40, 0.40, 0.90, 0.20);
		colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80);
		colors[clr.ScrollbarBg]            = ImVec4(0.27, 0.00, 1.00, 0.19);
		colors[clr.ScrollbarGrab]          = ImVec4(0.00, 1.00, 0.95, 0.30);
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.00, 0.00, 0.40);
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.02, 0.98, 1.00, 0.40);
		colors[clr.ComboBg]                = ImVec4(0.00, 0.00, 0.00, 0.99);
		colors[clr.CheckMark]              = ImVec4(0.00, 0.58, 1.00, 1.00);
		colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.30);
		colors[clr.SliderGrabActive]       = ImVec4(0.80, 0.50, 0.50, 1.00);
		colors[clr.Button]                 = ImVec4(0.09, 0.06, 0.20, 1.00);
		colors[clr.ButtonHovered]          = ImVec4(0.08, 0.03, 0.21, 0.27);
		colors[clr.ButtonActive]           = ImVec4(0.00, 0.54, 1.00, 1.00);
		colors[clr.Header]                 = ImVec4(0.35, 0.02, 1.00, 0.45);
		colors[clr.HeaderHovered]          = ImVec4(0.06, 0.39, 0.40, 0.80);
		colors[clr.HeaderActive]           = ImVec4(0.00, 0.86, 1.00, 0.80);
		colors[clr.Separator]              = ImVec4(0.07, 0.30, 0.52, 1.00);
		colors[clr.SeparatorHovered]       = ImVec4(0.00, 0.00, 0.00, 1.00);
		colors[clr.SeparatorActive]        = ImVec4(0.06, 0.06, 0.90, 1.00);
		colors[clr.ResizeGrip]             = ImVec4(0.02, 0.01, 0.27, 0.30);
		colors[clr.ResizeGripHovered]      = ImVec4(0.24, 0.00, 0.87, 0.60);
		colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.00, 0.00, 0.90);
		colors[clr.CloseButton]            = ImVec4(0.00, 0.00, 0.00, 0.90);
		colors[clr.CloseButtonHovered]     = ImVec4(1.00, 0.16, 0.00, 0.26);
		colors[clr.CloseButtonActive]      = ImVec4(1.00, 0.05, 0.05, 1.00);
		colors[clr.PlotLines]              = ImVec4(0.45, 0.00, 0.73, 1.00);
		colors[clr.PlotLinesHovered]       = ImVec4(0.07, 0.02, 0.39, 1.00);
		colors[clr.PlotHistogram]          = ImVec4(0.06, 0.05, 0.12, 1.00);
		colors[clr.PlotHistogramHovered]   = ImVec4(0.10, 0.06, 0.27, 1.00);
		colors[clr.TextSelectedBg]         = ImVec4(0.17, 0.06, 0.41, 0.35);
		colors[clr.ModalWindowDarkening]   = ImVec4(0.28, 0.05, 0.59, 0.35);
	elseif i == 9 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
		
        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0
		
		colors[clr.Text]                 = ImVec4(0.83, 0.83, 0.83, 1.00)
		colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.73, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
		colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.43, 0.71, 0.39, 0.54)
		colors[clr.FrameBgHovered]       = ImVec4(0.66, 0.84, 0.66, 0.40)
		colors[clr.FrameBgActive]        = ImVec4(0.68, 0.84, 0.66, 0.67)
		colors[clr.TitleBg]              = ImVec4(0.24, 0.47, 0.22, 0.67)
		colors[clr.TitleBgActive]        = ImVec4(0.28, 0.47, 0.22, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.26, 0.47, 0.22, 0.67)
		colors[clr.MenuBarBg]            = ImVec4(0.18, 0.34, 0.16, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.45, 0.71, 0.39, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.70, 0.84, 0.66, 1.00)
		colors[clr.Button]               = ImVec4(0.27, 0.47, 0.22, 0.65)
		colors[clr.ButtonHovered]        = ImVec4(0.39, 0.71, 0.39, 0.65)
		colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.Header]               = ImVec4(0.39, 0.71, 0.41, 0.54)
		colors[clr.HeaderHovered]        = ImVec4(0.68, 0.84, 0.66, 0.65)
		colors[clr.HeaderActive]         = ImVec4(0.66, 0.84, 0.66, 0.00)
		colors[clr.Separator]            = ImVec4(0.43, 0.50, 0.43, 0.50)
		colors[clr.SeparatorHovered]     = ImVec4(0.39, 0.71, 0.42, 0.54)
		colors[clr.SeparatorActive]      = ImVec4(0.43, 0.71, 0.39, 0.54)
		colors[clr.ResizeGrip]           = ImVec4(0.46, 0.71, 0.39, 0.54)
		colors[clr.ResizeGripHovered]    = ImVec4(0.66, 0.84, 0.66, 0.66)
		colors[clr.ResizeGripActive]     = ImVec4(0.67, 0.84, 0.66, 0.66)
		colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.CloseButtonHovered]   = ImVec4(0.42, 0.98, 0.36, 1.00)
		colors[clr.CloseButtonActive]    = ImVec4(0.38, 0.98, 0.36, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(0.52, 1.00, 0.35, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.16, 0.90, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(0.13, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.30, 0.98, 0.26, 0.35)
		colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
		
	elseif i == 10 then
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
		
        style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.50)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0
		
		colors[clr.WindowBg] = ImVec4(0.14, 0.12, 0.16, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.30, 0.20, 0.39, 0.00)
		colors[clr.PopupBg] = ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border] = ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg] = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.41, 0.19, 0.63, 0.68)
		colors[clr.FrameBgActive] = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBg] = ImVec4(0.41, 0.19, 0.63, 0.45)
		colors[clr.TitleBgCollapsed] = ImVec4(0.41, 0.19, 0.63, 0.35)
		colors[clr.TitleBgActive] = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.MenuBarBg] = ImVec4(0.30, 0.20, 0.39, 0.57)
		colors[clr.ScrollbarBg] = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.41, 0.19, 0.63, 0.31)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.CheckMark] = ImVec4(0.56, 0.61, 1.00, 1.00)
		colors[clr.SliderGrab] = ImVec4(0.41, 0.19, 0.63, 0.24)
		colors[clr.SliderGrabActive] = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button] = ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered] = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive] = ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header] = ImVec4(0.41, 0.19, 0.63, 0.76)
		colors[clr.HeaderHovered] = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.HeaderActive] = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.41, 0.19, 0.63, 0.20)
		colors[clr.ResizeGripHovered] = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ResizeGripActive] = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotLines] = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.41, 0.19, 0.63, 0.43)
    end
end
