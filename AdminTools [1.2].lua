script_name('AdminMode')
script_author('Fox_Yotanhaim')
script_description('������������� ������ ��� ������� ������� SLS RP')


require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local samp = require 'lib.samp.events'
local key = require 'vkeys'
local imgui = require 'imgui'
local encoding = require 'encoding'

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


local colorThemes = {u8"������� ����", u8"����� ����", u8"���� ����", u8"������ ����", u8"��������� ����", u8"Ҹ���-������� ����", u8"������-����� ����", u8"�������� ����", u8"�����-������ ����", u8"�������", u8"����������"}

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

local apanel = imgui.ImBool(false)
local changetheme = imgui.ImBool(false)
local fractionsmenu = imgui.ImBool(false)
local playercontrol = imgui.ImBool(false)
local lvl = imgui.ImBool(false)
local zakon = imgui.ImBool(false)
local mats = imgui.ImBool(false)
local kills = imgui.ImBool(false)
local xp = imgui.ImBool(false)
local vip = imgui.ImBool(false)
local moneybank = imgui.ImBool(false)
local moneyhand = imgui.ImBool(false)
local drugs = imgui.ImBool(false)
local auto = imgui.ImBool(false)
local narkozav = imgui.ImBool(false)
local msetstat = imgui.ImBool(false)
local remenu = imgui.ImBool(false)
local menuoffban = imgui.ImBool(false)
local menuoffwarn = imgui.ImBool(false)
local giveweapon = imgui.ImBool(false)
local ruleswindow = imgui.ImBool(false)
local iStyle = imgui.ImInt(0)
local blist = imgui.ImBool(false)
local window = imgui.ImBool(false)
local chathelpers = imgui.ImBool(false)
local chatadmins = imgui.ImBool(false)

function samp.onSetPlayerPos(position)
	if isCharInAnyCar(PLAYER_PED) then
		return false
	end
end

function samp.onServerMessage(color, text)
	if text:find("%[HC%] .+") then
		table.insert(t1, text:match('%[HC%] (.+)'))
	end
	local nick2, id2, nextt = text:match("%[A%] (%w+_%w+)%[(%d+)%] ������ ���������� (.+)")
	if nick2 and id2 and nextt then
		return {color, string.format("[A] ������������� %s[%d] ������ ���������� %s", nick2, id2, nextt)}
	end
	local nick3, id3, num = text:match("Admin: (%w+_%w+)%[(%d+)%] gzcolor: (%d+)")
	if nick3 and id3 and num then
		return {color, string.format("[A] ������������� %s[%d] ���������� ���� �� ���� ����� %d", nick3, id3, num)}
	end
	local nick4, id44, text4 = text:match("%[A%] ������������� (%w+_%w+)%[(%d+)%] {FFFFFF}���� ������ (.+)")
	if nick4 and id44 and text4 then
		return {color, string.format("{E14747}[A] ������������� %s[%d] ���� ������ %s", nick4, id44, text4)}
	end
	local nick5, id55, text5 = text:match("%[A%] ������������� (%w+_%w+)%[(%d+)%] {FFFFFF}������ ������ (.+)")
	if nick5 and id55 and text5 then
		return {color, string.format("{E14747}[A] ������������� %s[%d] ������ ������ %s", nick5, id55, text5)}
	end
	if text:find("(*.+ %w+_%w+%[%d+%]: .+)") then
		table.insert(t2, text:match('(*.+ %w+_%w+%[%d+%]: .+)'))
	end
	if text:find("^(%[A%] ������������� .+)") then
		table.insert(admactn, text:match('^(%[A%] ������������� .+)'))
	end
	if text:find("^(%[A%] ����������� �����: .+)") then
		table.insert(connectplayerslog, text:match('^(%[A%] ����������� �����: .+)'))
	end
	if text:find("^({d53e07}%[������%] �� %w+_%w+%[%d+%]: .+)") then
		table.insert(reports, text:match('^({d53e07}%[������%] �� %w+_%w+%[%d+%]: .+)'))
	end
	if text:find("^(%[V% I% P%] | {FEBC41}.+. {FFFF00}| ��������: %w+_%w+%[%d+%]. �������: %d+)") then
		table.insert(vipchatf, text:match('^(%[V% I% P%] | {FEBC41}.+. {FFFF00}| ��������: %w+_%w+%[%d+%]. �������: %d+)'))
	end
	if text:find("^������������� ������ �� ������� %w+_%w+%[%d+%]") then
		remenu.v = false
	end
	if text:find("���������� ������������ �� ������ ����.") then
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
        sampSendChat("/iban "..id.." ����")
    end
	if text:match('%w+_%w+%[%d+%]: mq') then
        local id = text:match('%w+_%w+%[(%d+)%]: mq')
        sampSendChat("/iban "..id.." ����")
    end
end

function samp.onSendCommand(param)
	if param:find('/re') then
		remenu.v = false
		playercontrol.v = false
	end
	if param:match('/re (%d+)') then
		spec_id = param:match('/re (%d+)')
		remenu.v = true
		sampTextdrawDelete(100)
		sampTextdrawDelete(101)
	end
end

function samp.onTogglePlayerSpectating(state)
	if spec_id ~= -1 then
		remenu.v = state
	end
end

function samp.onSpectatePlayer(playerid, camtype)
	spec_id = playerid
end

function samp.onConnectionRejected()
	spec_id = -1
end

function imgui.OnDrawFrame()
	if remenu.v then
		if isKeyJustPressed(key.VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
			imgui.LockPlayer = false
			imgui.ShowCursor = not imgui.ShowCursor
		end
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(20, sh / 2.4))
		imgui.SetNextWindowSize(imgui.ImVec2(269, 394))
		imgui.Begin(u8' ', remenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.MenuBar + imgui.WindowFlags.NoScrollbar)
			imgui.BeginMenuBar()
				if imgui.MenuItem(u8'��������') then
					tags.tag = 0
					remenu.v = true
				end
				if imgui.MenuItem(u8'���������') then
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
				sampSendChat('/prison '..spec_id..' 30 ��')
			end
			imgui.SameLine(180)
			if imgui.Button(u8'DB', imgui.ImVec2(80, 40)) then
				sampSendChat('/prison '..spec_id..' 30 ��')
			end
			
			if imgui.Button(u8'SBIV', imgui.ImVec2(80, 40)) then
				sampSendChat('/prison '..spec_id..' 10 ���� (���)')
			end
			imgui.SameLine(94)
			if imgui.Button(u8'������� ��\n�� �������', imgui.ImVec2(80, 40)) then
				sampSendChat('/iban '..spec_id..' �� �������')
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
				sampSendChat('/ban '..spec_id..' 7 ����')
			end
			
			if imgui.Button(u8'VRED', imgui.ImVec2(80, 40)) then
				sampSendChat('/iban '..spec_id..' ����. ����')
			end
			imgui.SameLine(94)
			if imgui.Button(u8'IPCHEAT', imgui.ImVec2(80, 40)) then
				sampSendChat('/iban '..spec_id..' ����')
			end
			imgui.SameLine(180)
			if imgui.Button(u8'���. ������', imgui.ImVec2(80, 40)) then
				sampSendChat('/mute '..spec_id..' 30 ���. ������')
			end
			
			if imgui.Button(u8'������', imgui.ImVec2(80, 26.5)) then
				sampSendChat('/prison '..spec_id..' 60 ������')
			end
			imgui.SameLine(94)
			if imgui.Button(u8'��������', imgui.ImVec2(80, 26.5)) then
				sampSendChat('/crash '..spec_id)
			end
			imgui.SameLine(180)
			if imgui.Button(u8'AFK (������)', imgui.ImVec2(80, 26.5)) then
				sampSendChat('/kick '..spec_id..' AFK �� ������')
			end
			
			imgui.SetCursorPos(imgui.ImVec2(8, 367))
			if imgui.Button(u8'REOFF', imgui.ImVec2(80, 0)) then
				sampSendChat('/re')
				remenu.v = false
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
			if imgui.Button(u8'��', imgui.ImVec2(40, 40)) then
				sampSendChat('/warn '..spec_id..' ��')
			end
			imgui.SameLine(96)
			if imgui.Button(u8'��', imgui.ImVec2(40, 40)) then
				sampSendChat('/warn '..spec_id..' ��')
			end
			imgui.SameLine(140)
			if imgui.Button(u8'��', imgui.ImVec2(40, 40)) then
				sampSendChat('/warn '..spec_id..' ��')
			end
			imgui.SameLine(185)
			if imgui.Button(u8'�� � ��', imgui.ImVec2(53, 40)) then
				sampSendChat('/warn '..spec_id..' �� � ��')
			end
			if imgui.Button(u8'���������', imgui.ImVec2(172, 40)) then
				sampSendChat('/warn '..spec_id..' ���������')
			end
			if imgui.Button(u8'���������� �������� ���.', imgui.ImVec2(172, 40)) then
				sampSendChat('/warn '..spec_id..' ���������� �������� ���.')
			end
		end
		imgui.End()
	end
	
	if changetheme.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(269, 70))
		imgui.Begin(u8'�������� ����', changetheme, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		if imgui.Combo(u8"����� ����", iStyle, colorThemes, #colorThemes) then
			SwitchTheStyle(iStyle.v)
		end
		imgui.End()
	end
	
	if remenu.v then
		local resX, resY = getScreenResolution()
        local sizeX, sizeY = 180, 160 -- WINDOW SIZE
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 1.1 - sizeX / 3, resY / 2.3 - sizeY / 3))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
        imgui.Begin('1##reconInfo', remenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
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
		imgui.Text(u8"���: "..sampGetPlayerNickname(spec_id))
		imgui.Text(u8"ID: "); imgui.SameLine(90); imgui.Text(tostring(spec_id))
		imgui.Text(u8"�����:"); imgui.SameLine(90); imgui.Text(isPed and tostring(health) or u8"���")
		imgui.Text(u8"�����:"); imgui.SameLine(90); imgui.Text(isPed and tostring(armor) or u8"���")
		imgui.Text(u8"�������:"); imgui.SameLine(90); imgui.Text(tostring(score))
		imgui.Text(u8"����:"); imgui.SameLine(90); imgui.Text(tostring(ping))
		imgui.Text(u8"����:"); imgui.SameLine(90); imgui.Text(isPed and tostring(model) or u8"���")
		imgui.Text(u8"��������:"); imgui.SameLine(90); imgui.Text(isPed and tostring(interior) or u8"���")
		if isPed and doesCharExist(pPed) and isCharInAnyCar(pPed) then
			imgui.SetNextWindowPos(imgui.ImVec2(resX / 1.1 - sizeX / 3, resY / 1.47 - sizeY / 3))
			imgui.SetNextWindowSize(imgui.ImVec2(180, 85))
			imgui.Begin('1##reconCarInfo', remenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
			imgui.Text(u8"���������:"); imgui.SameLine(90); imgui.Text(isPed and tostring(tCarsName[carModel-399]) or u8"���")
			imgui.Text(u8"�����:"); imgui.SameLine(90); imgui.Text(isPed and tostring(carHealth) or u8"���")
			imgui.Text(u8"������:"); imgui.SameLine(90); imgui.Text(isPed and tostring(carModel) or u8"���")
			imgui.Text(u8"��������:"); imgui.SameLine(90); imgui.Text(isPed and tostring(math.ceil(carSpeed)) or u8"���")
			imgui.End()
        end
		imgui.End()
	end
	
	if menuoffwarn.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.6, sh / 2.6))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 200))
		imgui.Begin(u8' ', menuoffwarn, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
		imgui.SetCursorPos(imgui.ImVec2(51, 1))
		imgui.TextColored(imgui.ImVec4(1.0, 0.0, 0.0, 1.0), u8'������ ���� ������ � ��������')
		imgui.InputText(u8'��� ������##1', buffers.warnoff)
		imgui.InputText(u8'�������##1', buffers.warnoff2)
		imgui.SetCursorPos(imgui.ImVec2(4, 170))
		if imgui.Button(u8'�������', imgui.ImVec2(150, 25)) then
			menuoffwarn.v = false
		end
		imgui.SetCursorPos(imgui.ImVec2(158, 170))
		if imgui.Button(u8'������ ����', imgui.ImVec2(138, 25)) then
			sampSendChat(u8:decode('/offwarn '..buffers.warnoff.v..' '..buffers.warnoff2.v))
			menuoffwarn.v = false
		end
		imgui.End()
	end
	
	if menuoffban.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.6, sh / 2.6))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 200))
		imgui.Begin(u8' ', menuoffban, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
		imgui.SetCursorPos(imgui.ImVec2(51, 1))
		imgui.TextColored(imgui.ImVec4(1.0, 0.0, 0.0, 1.0), u8'������ ��� ������ � ��������')
		imgui.InputText(u8'��� ������##1', buffers.banoff)
		imgui.InputText(u8'�����##2', buffers.banoff1)
		imgui.InputText(u8'�������##3', buffers.banoff2)
		imgui.SetCursorPos(imgui.ImVec2(4, 170))
		if imgui.Button(u8'�������', imgui.ImVec2(150, 25)) then
			menuoffban.v = false
		end
		imgui.SetCursorPos(imgui.ImVec2(158, 170))
		if imgui.Button(u8'������ ���', imgui.ImVec2(138, 25)) then
			sampSendChat(u8:decode('/offban '..buffers.banoff.v..' '..buffers.banoff1.v..' '..buffers.banoff2.v))
			menuoffban.v = false
		end
		imgui.End()
	end
	
	if giveweapon.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 3.8))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 400))
		imgui.Begin(u8'������ ������', giveweapon, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		if imgui.Button(u8'������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(1, 1000000)
		end
		if imgui.Button(u8'������ ��� ������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(2, 1000000)
		end
		if imgui.Button(u8'����������� �������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(3, 1000000)
		end
		if imgui.Button(u8'���', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(4, 1000000)
		end
		if imgui.Button(u8'����������� ����', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(5, 1000000)
		end
		if imgui.Button(u8'������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(6, 1000000)
		end
		if imgui.Button(u8'���', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(7, 1000000)
		end
		if imgui.Button(u8'������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(8, 1000000)
		end
		if imgui.Button(u8'���������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(9, 1000000)
		end
		if imgui.Button(u8'������������� �����', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(10, 1000000)
		end
		if imgui.Button(u8'�����', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(11, 1000000)
		end
		if imgui.Button(u8'��������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(12, 1000000)
		end
		if imgui.Button(u8'���������� ��������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(13, 1000000)
		end
		if imgui.Button(u8'����� ������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(14, 1000000)
		end
		if imgui.Button(u8'������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(15, 1000000)
		end
		if imgui.Button(u8'�������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(16, 1000000)
		end
		if imgui.Button(u8'������������ ���', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(17, 1000000)
		end
		if imgui.Button(u8'�������� ��������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(18, 1000000)
		end
		
		if imgui.Button(u8'�������� 9��', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(22, 1000000)
		end
		if imgui.Button(u8'�������� 9�� � ����������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(23, 1000000)
		end
		if imgui.Button(u8'�������� ������ ���', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(24, 1000000)
		end
		if imgui.Button(u8'������� ��������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(25, 1000000)
		end
		if imgui.Button(u8'�����', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(26, 1000000)
		end
		if imgui.Button(u8'�������������� ��������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(27, 1000000)
		end
		if imgui.Button(u8'���', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(28, 1000000)
		end
		if imgui.Button(u8'MP5', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(29, 1000000)
		end
		if imgui.Button(u8'������� �����������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(30, 1000000)
		end
		if imgui.Button(u8'�������� M4', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(31, 1000000)
		end
		if imgui.Button(u8'Tec-9', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(32, 1000000)
		end
		if imgui.Button(u8'��������� �����', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(33, 1000000)
		end
		if imgui.Button(u8'����������� ��������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(34, 1000000)
		end
		if imgui.Button(u8'���', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(35, 1000000)
		end
		if imgui.Button(u8'��������������� ������ HS', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(36, 1000000)
		end
		if imgui.Button(u8'�������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(37, 1000000)
		end
		if imgui.Button(u8'�������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(38, 1000000)
		end
		if imgui.Button(u8'����� � ��������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(39, 1000000)
		end
		if imgui.Button(u8'��������� � �����', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(40, 1000000)
		end
		if imgui.Button(u8'��������� � �������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(41, 1000000)
		end
		if imgui.Button(u8'������������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(42, 1000000)
		end
		if imgui.Button(u8'�����������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(43, 1000000)
		end
		if imgui.Button(u8'������ ������� �������', imgui.ImVec2(-0.1, 0)) then
			sampAddChatMessage("������ �������� ����, ����� �� �����", 0xAA3333)
		end
		if imgui.Button(u8'����������', imgui.ImVec2(-0.1, 0)) then
			sampAddChatMessage("������ �������� ����, ����� ��?", 0xAA3333)
		end
		if imgui.Button(u8'�������', imgui.ImVec2(-0.1, 0)) then
			giveWeapon(46, 1000000)
		end
		imgui.End()
	end
	
	if msetstat.v then
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 3.09))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 295))
		imgui.Begin(u8'���� /setstat', msetstat, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		if imgui.Button(u8"�������", imgui.ImVec2(-0.1, 0)) then
			lvl.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"�����������������", imgui.ImVec2(-0.1, 0)) then
			zakon.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"����", imgui.ImVec2(-0.1, 0)) then
			mats.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"��������", imgui.ImVec2(-0.1, 0)) then
			kills.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"����", imgui.ImVec2(-0.1, 0)) then -- mats.v or kills.v or xp.v or vip.v or moneybank.v or moneyhand.v or drugs.v or auto.v or narkozav.v
			xp.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"���", imgui.ImVec2(-0.1, 0)) then
			vip.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"������ � �����", imgui.ImVec2(-0.1, 0)) then
			moneybank.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"������ �� �����", imgui.ImVec2(-0.1, 0)) then
			moneyhand.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			drugs.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"������", imgui.ImVec2(-0.1, 0)) then
			auto.v = true
			msetstat.v = false
		end
		if imgui.Button(u8"����������������", imgui.ImVec2(-0.1, 0)) then
			narkozav.v = true
			msetstat.v = false
		end
		imgui.End()
	end
	
	if lvl.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'�������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.lvlinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"������� (�� 1 �� 999)##2", buffers.lvlinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.lvlinpt.v.." 1 "..buffers.lvlinpt2.v)
		end
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			lvl.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if zakon.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'�����������������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.zakoninpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"�����������������##2", buffers.zakoninpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.zakoninpt.v.." 2 "..buffers.zakoninpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 2 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 2 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			zakon.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if mats.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'����', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.matsinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"����##2", buffers.matsinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.matsinpt.v.." 3 "..buffers.matsinpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 3 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 3 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			mats.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if kills.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'��������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.killsinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"��������##2", buffers.killsinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.killsinpt.v.." 5 "..buffers.killsinpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 5 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 5 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			kills.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if xp.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'����', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.xpinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"���-�� �����##2", buffers.xpinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.xpinpt.v.." 7 "..buffers.xpinpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 7 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 7 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			xp.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if vip.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'���', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.vipinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"������� 0 ��� 1##2", buffers.vipinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.vipinpt.v.." 10 "..buffers.vipinpt2.v)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			vip.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if moneybank.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'������ � �����', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.moneybankinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"���-�� �����##2", buffers.moneybankinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.moneybankinpt.v.." 13 "..buffers.moneybankinpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 13 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 13 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			moneybank.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if moneyhand.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'������ �� �����', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.moneyhandinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"���-�� �����##2", buffers.moneyhandinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.moneyhandinpt.v.." 15 "..buffers.moneyhandinpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 15 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 15 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			moneyhand.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if drugs.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'���������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.drugsinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"���-�� ����������##2", buffers.drugsinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.drugsinpt.v.." 17 "..buffers.drugsinpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 17 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 17 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			drugs.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if auto.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'����', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.autoinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID ����������##2", buffers.autoinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.autoinpt.v.." 26 "..buffers.autoinpt2.v)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			auto.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if narkozav.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2.5))
		imgui.SetNextWindowSize(imgui.ImVec2(249, 200))
		imgui.Begin(u8'����������������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8"��� ID: "); imgui.SameLine(); imgui.Text(tostring(myid))
		
		imgui.PushItemWidth(90)
		imgui.InputText(u8"ID##1", buffers.narkozavinpt)
		imgui.PopItemWidth()
		imgui.PushItemWidth(90)
		imgui.InputText(u8"���-�� �����-�����##2", buffers.narkozavinpt2)
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..buffers.narkozavinpt.v.." 29 "..buffers.narkozavinpt2.v)
		end
		if imgui.Button(u8"��������� 2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 29 2147483647")
		end
		if imgui.Button(u8"��������� -2 147 483 647 ����!", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/setstat "..myid.." 29 -2147483647")
		end
		
		imgui.SetCursorPos(imgui.ImVec2(9, 175))
		if imgui.Button(u8"�����", imgui.ImVec2(-0.1, 0)) then
			narkozav.v = false
			msetstat.v = true
		end
		imgui.End()
	end
	
	if ruleswindow.v then
		imgui.ShowCursor = true
		local x, y = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(x / 4, y / 4.4))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 470))
		imgui.Begin(u8'������ ������', ruleswindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		if imgui.Button(u8'    �������\n��� �������', imgui.ImVec2(100, 40)) then
			tags.catalog = 1
		end
		imgui.SameLine()
		if imgui.Button(u8'    �������\n��� ��������', imgui.ImVec2(100, 40)) then
			tags.catalog = 2
		end
		imgui.SameLine()
		if imgui.Button(u8'�������\n�����', imgui.ImVec2(100, 40)) then
			tags.catalog = 3
		end
		imgui.SameLine()
		if imgui.Button(u8'������� UNINV\n� ���. ��������', imgui.ImVec2(100, 40)) then
			tags.catalog = 4
		end
		imgui.SameLine()
		if imgui.Button(u8'���������', imgui.ImVec2(100, 40)) then
			tags.catalog = 5
		end
		imgui.Separator()
		if tags.catalog == 1 then
			imgui.BeginChild('�����', imgui.ImVec2(115, 390), false, imgui.WindowFlags.NoScrollbar)
			if imgui.Button(u8'�������', imgui.ImVec2(100, 40)) then
				tags.tab = 1
			end
			if imgui.Button(u8'�����������', imgui.ImVec2(100, 40)) then
				tags.tab = 2
			end
			if imgui.Button(u8'������ ��\n�������', imgui.ImVec2(100, 40)) then
				tags.tab = 3
			end
			if imgui.Button(u8'���������', imgui.ImVec2(100, 40)) then
				tags.tab = 4
			end
			if imgui.Button(u8'������', imgui.ImVec2(100, 40)) then
				tags.tab = 5
			end
			if imgui.Button(u8'�������', imgui.ImVec2(100, 40)) then
				tags.tab = 6
			end
			if imgui.Button(u8'�� �������', imgui.ImVec2(100, 40)) then
				tags.tab = 7
			end
			if imgui.Button(u8'������ �������', imgui.ImVec2(100, 40)) then
				tags.tab = 8
			end
			if imgui.Button(u8'���. �������', imgui.ImVec2(100, 40)) then
				tags.tab = 9
			end
			if imgui.Button(u8'�������', imgui.ImVec2(100, 40)) then
				tags.tab = 10
			end
			if imgui.Button(u8'����', imgui.ImVec2(100, 40)) then
				tags.tab = 11
			end
			if imgui.Button(u8'�����������', imgui.ImVec2(100, 40)) then
				tags.tab = 12
			end
			if imgui.Button(u8'/ao � /o', imgui.ImVec2(100, 40)) then
				tags.tab = 13
			end
			if imgui.Button(u8'�������', imgui.ImVec2(100, 40)) then
				tags.tab = 14
			end
			if imgui.Button(u8'������� �\n���. �����', imgui.ImVec2(100, 40)) then
				tags.tab = 15
			end
			imgui.EndChild()
			imgui.SameLine(120)
			imgui.VerticalSeparator()
			imgui.SameLine()
			
			if tags.tab == 1 then
				imgui.BeginChild('1', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("1.1 - �������������� ��������� ������������ \n������������� ������� � ���, � ��� ���, � � ����������� � ������� �������. \n> {FF0000}���������: ���������� �������.{FFFFFF}\n1.2 - �������������� ��������� �������� ������/������. \n> {FF0000}���������: ���������� �������.{FFFFFF}\n1.3 - �������������� ��������� \n������/�������/������/������ �������/������� ��-�� ������ ���������. \n> {FF0000}���������: ���������� ������� ���� �� ������.{FFFFFF}\n1.4 - �������������� ��������� �������� ������/������ \n����������� ������. \n> {FF0000}���������: ���������� �������.{FFFFFF}\n1.5 - �������������� ��������� ������������ ������. \n> {FF0000}���������: ���������� �������{FFFFFF} \n{00FF00}> (����������: �� �� ����������� �������� �� 2-3 �������){FFFFFF}\n1.6 - �������������� ������ ��������� ���������/���������� \n����� ������/������� ��������������. \n> {FF0000}���������: ������ � ����� �������������� + IP ban{FFFFFF}\n1.6 - �������������� ��������� ���������� ������� \n�� �� ������� ���������. \n> {FF0000}���������: ���������� �������.{FFFFFF}\n1.7 - �������������� ��������� ������ ��� ������������ ������� � \n������� ��� ���������������. [������: ������ ���, ��������?�]. \n> {FF0000}���������: ���������� ������� � ������ � ���������������� ����{FFFFFF}\n1.8 - �������������� ��������� ������� �����������/��������� � �.�. \n> {FF0000}���������: ���������� �������{FFFFFF}\n")
				imgui.EndChild()
			elseif tags.tab == 2 then
				imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("2.1 - ������������� ������ ������� �� \n�������� �� ������� [������������� ����� ���������]\n2.2 - ������������� ������� ������ �������� ������� ������������� \n� ���������� �� ������� ������ ���������������\n2.3 - ������������� ������ �������� �� ������ [������������� offtop � ������] \n{00FF00}����������: ������ ������� ������ ���������, �������� �����������.{FFFFFF}\n2.4 - ��� ��������������� ������������ ������������ \n�������������� �� ������ ����� � ����� ��������������.\n")
				imgui.EndChild()
			elseif tags.tab == 3 then
				imgui.BeginChild('3', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("3.1 - ������������� ������ �������� � �������� �� ����\n� �� �������� ����� �������:\n	������:\n	1) ������������ ����������� ��������� � ����� ������.\n	2) ������ �������� ������� ���������� [Privet]\n	3) ����� ������ ���� ����������� �������� � \n	���������, ���� ����� ��� �����.\n	4) ������ ������������ �CapsLock� � ����� ������, ������ ���������\n	�����.\n	{FF0000}��������� �� ��������� ������ �������: ���������� �������.{FFFFFF}")
				imgui.EndChild()
			elseif tags.tab == 4 then
				imgui.BeginChild('4', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("4.1 - ������������� ������ �������� ��������� �� ��������� ������ \n�� ������� ��������� [���������� ����]\n4.2 - ������������� ������ ������� �������������� �� ���� ��������� � \n������� 3-� ����, ������ �� ����� �� �������.")
				imgui.EndChild()
			elseif tags.tab == 5 then
				imgui.BeginChild('5', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("5.1 - ��������� ��������� ������ �������� �� ��� � \n�������� �� �������������� \n{0000FF}[��������� ������ �� ������������� ����� ������ ��/���]{FFFFFF}\n5.2 - ������������� ����� ����� ��������� ������, \n� ������� �� ������������ ���-� ���������, \n� ������� ������������ ����������� ������� � �.�\n5.3 - ������������� ������ ��������� ������ ������ �� �������!\n5.4 - ������������� ������ ������������ ���-�� ���������, \n���� ��� ��������� ��.������������� � ������� 24� �����")
				imgui.EndChild()
			elseif tags.tab == 6 then
				imgui.BeginChild('6', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("6.1 - �������������� ��������� ���������� ������� 3-�� �����. \n> {FF0000}���������: ������ � ���������������� ����. \n> {00FF00}[����������: ���������� ��.�������������]{FFFFFF}\n6.2 - ������������� ������ ��������� �������� ������\n6.3 - �������������� ��������� ��������� ���� ������� - \n> {FF0000}������ ���� ����������.{FFFFFF}\n6.4 - �������������� ��������� ������� ���.�����/���.�����/����.����� \n�� �������. \n> {FF0000}���������: ������ � ��� ���� + ��� ��������")
				imgui.EndChild()
			elseif tags.tab == 7 then
				imgui.BeginChild('7', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("7.1 - �������������� ��������� �������������� Role Play ��������\n7.2 - �������������� ��������� ������������ ���.������� � �� ��������.\n7.3 - �������������� ��������� ������������ ���� � Role Play ��������.")
				imgui.EndChild()
			elseif tags.tab == 8 then
				imgui.BeginChild('8', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("8.1 - �������������� ��������� ������� ���������� � ���.������ \n3-�� �����. \n> {FF0000}���������: ������ � ���������������� ����{FFFFFF}\n8.2 - �������������� ��������� ���������� ������ \n��������������� � ������.\n8.3 - �������������� ��������� ���������/���������� ��������� \n�������/������� � ��� ������.\n8.4 - �������������� ��������� ������������� ���� �������\n8.5 - �������������� ��������� ���������� ���������� �������")
				imgui.EndChild()
			elseif tags.tab == 9 then
				imgui.BeginChild('9', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("9.1 - �������������� ��������� ������������ ���� ���� 10LVL. \n> {FF0000}���������: ���������� �������.{FFFFFF}\n9.2 - �������������� ��������� ������� �� ��������������� 12LVL \n��� ��� ����������. \n> {FF0000}���������: ���������� �������.{FFFFFF}\n9.3 - �������������� ��������� ����� ���� ������/���� ��������������� \n�� ���� �������/������� ������ �������. \n> {FF0000}���������: ������ � ���.����+���� ����������.{FFFFFF}\n9.4 - �������������� ��������� ����������������� � \n��.�������������/��������������� ��.������������� ��� �� ����������.\n8.5 - �������������� ��������� ����� ������� \n> {00FF00}������ ���� ��� �� �������� ������������ ��� �� \n{00FF00}�� �������� ������ �� ��������, � ������� �� ���������.{FFFFFF} \n> {FF0000}���������: ���������� �������.{FFFFFF}\n9.6 - ��������� �������������� ����������� ��������� �������. \n> {FF0000}���������: ������ � ���������� �������.{FFFFFF}\n9.8 - �������������� ��������� ������� ���� ����. \n> {FF0000}���������: ������ � ���������������� ����{FFFFFF}\n9.9 - ��������������� ������� ������� ������ \n������� ������������� ��� ����. \n> {FF0000}���������: ������ � ���������������� ����.{FFFFFF}")
				imgui.EndChild()
			elseif tags.tab == 10 then
				imgui.BeginChild('10', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("10.1 - ��������� ������������ ������� [/mp] ��� �����������. \n> {FF0000}���������: ���������� �������.{FFFFFF}\n10.2 - ��������� �������� ������ ������ ��� 50HP [/sethp]. \n> {FF0000}���������: ������ ������� � ���������� �������. \n> {00FF00}����� ������ � �� ���� ���� ������ \n{00FF00}��������� �������� ��� ������� ���������{FFFFFF}\n10.3 - ��������� ���������� ������� �� ����� [/gotosp], \n������� ����� ���������, ��� �� ����������, ����� �� �������� \nRP �������. \n> {FF0000}���������: ������ ������� � ���������� �������. \n> {00FF00}���������� ������ ����� � ������ ���� ����� �������, \n{00FF00}��� ������� ������ ������\n10.4 - ��������� �������� ����/������� �������� ��������� ����/���� \n����������� FBI, StreetRacers, Hitman � ������� ������� \n/leader, /makezam, /agiverank\n>{00FF00} ����������: ���� ���������� �� �������� �� �������� �� ������ ���� \n{00FF00}���������� �����, ����� ����������� �� �������. \n> {FF0000}���������: ������ ������� � ���������� �������.{FFFFFF}\n10.5 - ��������� �������� DP ������ ��� � \n��� ������ �� ����� �������� ����.")
				imgui.EndChild()
			elseif tags.tab == 11 then
				imgui.BeginChild('11', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("11.1 - ��������� ������������� ����� ��� �������. \n> {FF0000}���������: ������ ������� � ���������� �������.{FFFFFF}\n11.2 - ��������� ������������� ����� � RolePlay ��������. \n> {FF0000}���������: ���������� �������.")
				imgui.EndChild()
			elseif tags.tab == 12 then
				imgui.BeginChild('12', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("12.1 - �� ����� ��������� � 7LvL ������� �� ������� ���� {FFFF00}25{FFFFFF} �������. \nDP �� ���� 30.000. ������ � ���������� ��.�������������\n12.2 - ��������� ����� ���� � ��������� �������\n12.3 - ��������� ������������ ��������� �� ��\n12.4 - ���������� ����������� ����� ���� \n������ ������������� [���������� ����]\n12.5 - �������������� ��������� ��������� �� �����������\n>{00FF00} [����������: ���������� �����������]\n12.6 - ��������� ��������� �� �� ����� ������\n> {00FF00}[����������: ���������� ��]\n11.7 - ��������� ������ ��� ��� ���������� ��.")
				imgui.EndChild()
			elseif tags.tab == 13 then
				imgui.BeginChild('13', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("13.1 - ������� /o ������������ ������ ��� \n���������� ������� ������ �����������, \n��� �� ��� ���������� �����/������� ����� ������ ������.\n13.2 - ������� /ao ������������ ��� ���������� \n������� � ����������� �����������.")
				imgui.EndChild()
			elseif tags.tab == 14 then
				imgui.BeginChild('14', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("14.1 - �������������� ��������� ���������� �� �������� �����\n> {00FF00}[����������: 1-4LVL ��������������]")
				imgui.EndChild()
			elseif tags.tab == 15 then
				imgui.BeginChild('15', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("14.1 ������������� ��������� ����������/��������� ����� \n� ����� ����� �� ��������� � ������� � ���������� ����� \n(���������/���.������/�������� �������)\n> {FF0000}���������: ������ � �����. ����")
				imgui.EndChild()
			end
		end
		if tags.catalog == 2 then
			imgui.BeginChild('Helpers', imgui.ImVec2(580, 393), false, imgui.WindowFlags.NoScrollbar)
			imgui.TextColoredRGB("{FFFF00}1. ������� �������:{FFFFFF}\n\n1.1 - �������� �� ��� ������� �� ������� (����� ������������/��������������)\n1.2 - ������� ����� ������� �������\n1.4 - ���������� �� ���� ������� �� ������. �� ����� ������������ �� � ���� �� ���.\n1.5 - ��������� ������� ��������� � ������ ��� ������.\n1.6 - ���������/���������� ������� ���� �������. (�������, ���� ����, ������ ����)\n{FFFFFF}\n{FF0000}2. �������� �����������:{FFFFFF}\n2.1 - ������������ �������. {FF0000}���������: ��������� � ���+�������.{FFFFFF}\n2.2 - ������������� ������� �� �����������, ����� � �����, � ����� ����� ���������� ������� \n{FF0000}���������: �������/������ � ����.�����{FFFFFF}\n2.3 - ������������ ������� � ������ �����, ��������� ���� ���������� \n{FF0000}���������: �������/������ � ����.�����{FFFFFF}\n2.4 - ���������� ������� �� ������ ��������; {FF0000}���������: �������/������ � ����.�����{FFFFFF}\n2.5 - ������������ ���-����������� - {FF0000}���������: ������ � ���������� ����{FFFFFF}\n2.6 - ����������, �������, ������������� �������/��������/�������. {FF0000}���������: �������.{FFFFFF}\n2.7 - ������ ������/������������ ������ �������. {FF0000}���������: �������/������ � ����.�����")
			imgui.EndChild()
		end
		if tags.catalog == 3 then
			imgui.BeginChild('������', imgui.ImVec2(115, 390), false, imgui.WindowFlags.NoScrollbar)
			if imgui.Button(u8'�����\n�������', imgui.ImVec2(100, 40)) then
				tags.ghetto = 1
			end
			if imgui.Button(u8'�������', imgui.ImVec2(100, 40)) then
				tags.ghetto = 2
			end
			if imgui.Button(u8'�������\n�� �������.', imgui.ImVec2(100, 40)) then
				tags.ghetto = 3
			end
			if imgui.Button(u8'�����', imgui.ImVec2(100, 40)) then
				tags.ghetto = 4
			end
			if imgui.Button(u8'����� (/f)', imgui.ImVec2(100, 40)) then
				tags.ghetto = 5
			end
			if imgui.Button(u8'������', imgui.ImVec2(100, 40)) then
				tags.ghetto = 6
			end
			if imgui.Button(u8'����', imgui.ImVec2(100, 40)) then
				tags.ghetto = 7
			end
			imgui.EndChild()
			imgui.SameLine(120)
			imgui.VerticalSeparator()
			imgui.SameLine()
			if tags.ghetto == 1 then
				imgui.BeginChild('1', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}���������:{FFFFFF}\n�������� �� ����/� AFK ��� �� ������ �� �������. \n{FF0000}[���������: /warn]{FFFFFF}\n{FFFFFF}\n������� ������ ������� �� ������� ������ ����� ��� �� �������. \n{FF0000}[���������: /warn]{FFFFFF}\n{FFFFFF}\n������� ������ ������� �� ���������� ��������� �����. \n{FF0000}[���������: /warn]{FFFFFF}\n{FFFFFF}\n����� �� ����� ����� \n{FF0000}[���������: /warn, �������� ����������]{FFFFFF}\n{FFFFFF}\n��������� ��/��� �����. ���� �� ����� � ����� ����� /ainvite \n{FF0000}[���������: �������/����]{FFFFFF}\n{FFFFFF}\n{00FF00}���������:{FFFFFF}\n���������� ����� �� ����� ���������� �� ����� ����������\n��������� ������ ������� � �������� ������ �� ����")
				imgui.EndChild()
			elseif tags.ghetto == 2 then
				imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}���������:{FFFFFF}\n������������ ����. {FF0000}[���������: /mute �� 10 �����]{FFFFFF}\n������������ ��������. {FF0000}[���������: /mute �� 10 �����]\n{00FF00}���������:\n������������ �� �� ���������� �����, ���� �� ���������� �� ��������.\n{FFFFFF}\n��������� ������ �����, \n�������� '����������' �� ���������, � �� ������������ �����.\n{FFFFFF}\n������������� �����, �� ���������� ����������� ������� ��� \n�������������.")
				imgui.EndChild()
			elseif tags.ghetto == 3 then
				imgui.BeginChild('3', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}���������:{FFFFFF}\n������� ������� �� ��������� ������� ����. {FF0000}[���������: /prison 30 �����]{FFFFFF}\n������ ������ �� ����� �������. {FF0000}[���������: /prison �� 20 �����]{FFFFFF}\n������������ ���� �������. {FF0000}[���������: /prison �� 60 �����]{FFFFFF}\n\n{00FF00}���������:{FFFFFF}\n������� ������� �� ��������� ����, ���� �� ������ �� ��� �� ��")
				imgui.EndChild()
			elseif tags.ghetto == 4 then
				imgui.BeginChild('4', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}���������:{FFFFFF}\n������������ ����� ����, ������ ������������ ��� ��������. \n{FF0000}[���������: /prison 120 ����� ��� ���������� ��������]{FFFFFF}")
				imgui.EndChild()
			elseif tags.ghetto == 5 then
				imgui.BeginChild('5', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}���������:{FFFFFF}\n������� � �����. {FF0000}[���������: /mute �� 10 �����]{FFFFFF}\n������� � �����. {FF0000}[���������: /mute �� 10 �����]{FFFFFF}\n������ ���������� � �����. {FF0000}[���������: /mute �� 10 �����]{FFFFFF}\n{00FF00}���������:\n�� � ���� �������.")
				imgui.EndChild()
			elseif tags.ghetto == 6 then
				imgui.BeginChild('6', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}���������:{FFFFFF}\n����� ������ � ������� ����� ����� 3-� ������������. {FF0000}[���������: �������]{FFFFFF}\n����������� ���������� ������ ����� �� ���� [2-7].\n����������� ����� ���� ��������� �� �������.")
				imgui.EndChild()
			elseif tags.ghetto == 7 then
				imgui.BeginChild('7', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
				imgui.TextColoredRGB("{FF0000}���������:{FFFFFF}\n> ��������� �� �����/������ �� ����� �����. {FF0000}[���������: ���]{FFFFFF}\n> O��������� ������� � �� ������. {FF0000}\n[���������: ���. ������ - /mute �� 30 �����; ���. ����� - ��� �� IP]{FFFFFF}\n> DB, SK, TK. {FFFFFF}\n> ���� �����. {FF0000}[���������: ������� ������ ��� /warn ���� ��� ����� ����]{FFFFFF}\n> ������ � AFK �� �����. {FF0000}[���������: ���]{FFFFFF}\n> ��������� ������������ ������� /clist �� �����. {FF0000}[���������: /warn, /kick]{FFFFFF}\n> ������ �����. {FF0000}[���������: ���/����������� �� �����]{FFFFFF}\n> ����� ��� ��. {FF0000}[���������: �������������� �� ��� �������]{FFFFFF}\n> ���� ���� �������� �� ������ �� ������ �����. \n���� ���� ���� ��� �����, �� ����� �������� {FF0000}����.{FFFFFF}\n> ������ �� ����. {FF0000}[���������: �������������� �� ��� �������]{FFFFFF}\n> /mask �� �����. {FF0000}[���������: �������������� �� ��� �������]{FFFFFF}\n> ���� ������. \n{FF0000}[���������: �������������� �� ��� �������, �������� ����������]{FFFFFF}\n{FFFFFF}\n������� [���, �����] ��������� � 10:00 - 00:00.\n��� - �� 5� �������\n���� - �� 3� �������.\n��� ���������� ������ ���� �� ����� �����������, \n������������ ����� � ���.�����������, ��������� ����������� ���: \n��������� - �������������� �� ��� �������.")
				imgui.EndChild()
			end
		end
		if tags.catalog == 4 then
			imgui.BeginChild('uninvitegov', imgui.ImVec2(580, 393), false, imgui.WindowFlags.NoScrollbar)
			imgui.TextColoredRGB("{FFFF00}������� �� ������� ��������� ������:\n{00FF00}1.{FFFFFF} Metagaming - ����\n{00FF00}2.{FFFFFF} Non RP - ����.�� �����������.\n{00FF00}3.{FFFFFF} Team Kill ( TK ) - ��������� �� �����������.\n{00FF00}4.{FFFFFF} ���������� � ����� - ��� � �����.\n{00FF00}5.{FFFFFF} ����������� - ����������� �����������.\n{00FF00}6.{FFFFFF} ������������ - ��������� ������.\n{00FF00}7.{FFFFFF} ����� ����� - ����� �����.\n{00FF00}8.{FFFFFF} �� ������������ ������� - C/�.\n\n{FF0000}������� ����������.{FFFFFF}\n{00FF00}1.{FFFFFF} �� ������������ �� ����������� ������� ��� ����������.\n{00FF00}2.{FFFFFF} �� ����������.\n{00FF00}3.{FFFFFF} �� ������ ����.\n{00FF00}4.{FFFFFF} �� ������������ ����.")
			imgui.EndChild()
		end
		if tags.catalog == 5 then
			imgui.BeginChild('������', imgui.ImVec2(115, 390), false, imgui.WindowFlags.NoScrollbar)
				if imgui.Button(u8'��������', imgui.ImVec2(100, 40)) then
					tags.info = 1
				end
				if imgui.Button(u8'���', imgui.ImVec2(100, 40)) then
					tags.info = 2
				end
				if imgui.Button(u8'���', imgui.ImVec2(100, 40)) then
					tags.info = 3
				end
				if imgui.Button(u8'����', imgui.ImVec2(100, 40)) then
					tags.info = 4
				end
				imgui.EndChild()
				imgui.SameLine(120)
				imgui.VerticalSeparator()
				imgui.SameLine()
				if tags.info == 1 then
					imgui.BeginChild('1', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("1.2 DeathMatch (DM). \n{FF0000}��������� - /prison �� 30 �����\n{FFFFFF}\n1.3 DriveBy (DB). \n{FF0000}��������� - /prison �� 30 �����.\n{FFFFFF}\n1.4 ������������� ����� ����. \n{FF0000}��������� - /prison 60 ����� .\n{FFFFFF}\n1.5 ���� [�����]. \n{FF0000}��������� - /prison 10 �����\n{FFFFFF}\n1.6 ����� ������. \n{FF0000}��������� - 80 ����� ��-�������.\n{FFFFFF}\n1.7 ����� �������.\n{FF0000}��������� - 30 ����� ���������")
					imgui.EndChild()
				elseif tags.info == 2 then
					imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("2.2 ������. \n{FF0000}���������: ���������� �������� �� 3 ���.\n{FFFFFF}\n2.3 ������� ������� ������/���������� � �.� �� �������� ������. \n{FF0000}��������� - ���������� �������� ��������.\n{FFFFFF}\n2.4 ����� �� �������� �� ����. \n{FF0000}��������� - ���������� ������ ��������\n{FFFFFF}\n2.5 ������ ���� �� �������������. \n{FF0000}��������� - �������������� �� ��� ������� // next \n{FF0000}���������� ������ �������� ��������.\n{FFFFFF}\n2.6 ����������. \n{FF0000}��������� - �������������� �� ��� �������\n{FFFFFF}\n2.7 ����������� �������. \n{FF0000}��������� - /iban - ���������� �� iP ������.\n{FFFFFF}\n2.8 ��� ���������� �����������/���. \n{FF0000}��������� - /ban\n{FFFFFF}\n2.9 ������� ����� YouTube/twitch/����� � �.� \n����������� � ������� ��� ���������� �� ������� ��������������. \n{FF0000}��������� - /ban\n{FFFFFF}\n2.10 �� ������� ����������� ��������, ����� ������ �������� � �.�. \n{FF0000}��������� -/iban - ���������� �� iP ������.\n{FFFFFF}\n2.11 ����������� ���������� �������. \n{FF0000}��������� - /iban - ���������� �� iP ������.\n{FFFFFF}\n2.12 ���������� ����� (�.� �����������) \n{FF0000}��������� - /iban - ���������� �� iP ������.\n{FFFFFF}\n2.13 ������������ ��������e. \n{FF0000}��������� - ���������� ���� 30 ����� => �������������� �� ��� �������\n{FFFFFF}\n2.14 ������������ DM. \n{FF0000}��������� - ���������� �������� �� 2 ���.\n{FFFFFF}\n2.15 ������������ DB. \n{FF0000}��������� - ���������� �������� �� 2 ���.\n{FFFFFF}\n2.16 ������������� ���-�������� (Cheat). \n{FF0000}��������� - �������������� �� ������� ������� \n{FF0000}/ban, /offban, ������ /prison �� 120 �����; \n{FF0000}�������������� ������� /ban, /offban - \n{FF0000}������ ���������� �������� �� 7 ����\n{FFFFFF}\n2.17 ������������� ������������� ���-��������. \n{FF0000}��������� - ���������� �������� �� iP + �������� ��� � �� �������.")
					imgui.EndChild()
				elseif tags.info == 3 then
					imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("3.2 MetaGaming (MG) - ������������� ��� ���������� \n(�� ������ �����) � IC (�������) ���. \n{FF0000}��������� - /mute �� 30 �����.\n{FFFFFF}\n3.3 ����������� ������� (���.�������) \n{FF0000}��������� - ���������� ���� �� 10 �����.\n{FFFFFF}\n3.4 ����������� ������� � /vad. \n{FF0000}��������� - 30 ����� ����.\n{FFFFFF}\n3.5 ������������ ��������. \n{FF0000}��������� - ���������� ���� 30 ����� ��� ���� (�� ���� ��������������) \n{FF0000}���� ���������� �������� �� 3 ����, �� ������� ����.\n{FFFFFF}\n3.6 Translit - ������ ������� ����� ��������� ���������� ����� \n(������: privet, ya artur ). \n{FF0000}��������� - /mute �� 10 ����� . (��������� � ����� ����)\n{FFFFFF}\n3.7 CapsLock - ������ �������� ������� (������: ������). \n{FF0000}��������� - /mute �� 10 �����. ��������� � ����� ����.\n{FF0000}��������� ����������� ������������ ����� � �/s� \n{FF0000}������� �� ���������� �� ��������� (������: ���� �� �� ��������)\n{FF0000}(��������� : /s ���� �� �����, ��� � �������! \n{FF0000}������ �������� ��� �������� �������� ���������� � ��������� ���������.)\n{FFFFFF}\n3.8 Offtop - ������ // ������, ������� �� ����� �� ����� �����. \n{FF0000}��������� - ���������� ���� ��� ������ �����/�������� �� 10 �����.\n{FFFFFF}\n3.9 ����������� ������������� (IC, OOC). \n{FF0000}��������� - /mute �� 60 �����.\n{FFFFFF}\n3.10 Flood ( ������ 3-� ���������). \n{FF0000}��������� - /mute 10\n{FFFFFF}\n3.11���������� ������� � ������������. \n{FF0000}��������� - /mute 30\n{FFFFFF}\n3.12 ����������� ����� (�����, ����� �.�.�).\n{FF0000}��������� - /mute 60\n{FFFFFF}\n3.13 ����������� ������. \n{FF0000}��������� - ���������� ���� �� 30 �����.\n{FFFFFF}\n3.14 ����������������. \n{FF0000}��������� - ���������� ���� �� 40 �����.\n{FFFFFF}\n3.15 ��� � /report. \n{FF0000}��������� - 60 ����� ���� �������.\n{FFFFFF}\n3.16 ���������� ����� � ���� ������������ (������: [FBI] to [LSPD]). \n{FF0000}��������� - ��� ���� 10 �����.\n{FFFFFF}\n")
					imgui.EndChild()
				elseif tags.info == 4 then
					imgui.BeginChild('2', imgui.ImVec2(455, 390), false, imgui.WindowFlags.NoScrollbar)
					imgui.TextColoredRGB("4.2 DM in GreenZone (DM in GZ) - ��������/��������� ����� � ������ ����. \n{FF0000}��������� - /warn.\n{FFFFFF}\n4.3 Spawn Kill (SK) - ��������/��������� ����� �������/�������\n������/�� �� ����� (������). \n{FF0000}��������� - /warn.\n{FFFFFF}\n4.4 Repeat Kill (RK) - ����������� �� ����� ������. \n{FF0000}��������� - /warn.\n{FFFFFF}\n4.5 Team Kil (TK) - ��������/��������� ����� �������/�� \n(������ �� ����� �� �����������). \n{FF0000}��������� - /warn.\n{FFFFFF}\n4.6 ���� [CLEO]. {FF0000}��������� - /warn.\n{FFFFFF}\n4.7 ������ �������/������ (������). \n{FF0000}��������� - /kick // next warn\n{FFFFFF}\n4.8 ���� �����/������. \n{FF0000}��������� - /warn\n{FFFFFF}\n4.9 ���� � AFK �� ����� ������ // ��������� (���� �� RP ��������). \n{FF0000}��������� - �������������� �� ��� �������.\n{FFFFFF}\n4.10 ����� NonRP ��������. \n{FF0000}��������� - /warn\n{FFFFFF}\n4.11 PowerGaming (PG) - ���������� ��� ������ ���������. \n{FF0000}��������� - �������������� �� ��� �������\n{FFFFFF}\n4.12 ����� �������������/��������. \n{FF0000}��������� - /warn (� ����������� �� ������� ������);\n{FF0000}/ban 3 - ���������� �������� \n{FF0000}(��������, � ����������� �� ������� ������� ������)\n{FFFFFF}\n4.13 ����� �������. \n{FF0000}��������� - ��������� - /warn (� ����������� �� ������� ������);\n{FF0000}/ban 3 + ��������� ��������� ����������\n{FFFFFF}\n4.14 ������ ���� �� �������������. \n{FF0000}��������� - �������������� �� ��� ������� // next \n���������� ������ �������� ��������.\n{FFFFFF}\n4.15 ���� ����� � �����. \n{FF0000}��������� - �������������� �� ��� �������.\n{FFFFFF}\n4.16 ���� ������/��/�������������/�������/������/�����. \n{FF0000}��������� - �������������� �� ��� �������.\n{FFFFFF}\n4.17 ���������� �������� ��������������. \n{FF0000}��������� - �������������� �� ��� �������\n{FFFFFF}\n4.18 ���� �� �������. \n{FF0000}��������� - ���� (������ 2 ��������)\n{FFFFFF}\n4.19 NonRP NickName �� �������. \n{FF0000}��������� - ���������� �� ������� // next \n�������������� �� ��� �������.\n{FFFFFF}\n4.20 ���� �� ��������� ����� ��������. \n{FF0000}��������� - /warn\n{FFFFFF}\n4.21 ������� [���, �����] ��������� � 10:00 - 00:00. \n{FF0000}��������� - /warn\n{FFFFFF}\n��� - �� 5� �������\n���� - �� 3� �������.\n��� ���������� ������ ���� �� ����� �����������, ������������ �����\n� ���.�����������, ��������� ����������� ���: \n{FF0000}��������� - �������������� �� ��� �������.")
					imgui.EndChild()
				end
			end
			imgui.End()
		end
	
	if fractionsmenu.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.4, sh / 3.5))
		imgui.SetNextWindowSize(imgui.ImVec2(200, 400))
		imgui.Begin(u8'�������', fractionsmenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
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
		if imgui.Button(u8"3. �����: ���������", imgui.ImVec2(-0.1, 0)) then
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
		if imgui.Button(u8"4. ���", imgui.ImVec2(-0.1, 0)) then
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
		if imgui.Button(u8"7. �����", imgui.ImVec2(-0.1, 0)) then
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
		imgui.Button(u8"8. �����������", imgui.ImVec2(-0.1, 0))
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.44, 0.44, 1.0))
		imgui.Button(u8"9. �����������", imgui.ImVec2(-0.1, 0))
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
		if imgui.Button(u8"11. �����������", imgui.ImVec2(-0.1, 0)) then
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
		if imgui.Button(u8"14. ������� �����", imgui.ImVec2(-0.1, 0)) then
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
		if imgui.Button(u8"19. �����: ���� 51", imgui.ImVec2(-0.1, 0)) then
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
		imgui.Button(u8"20. �����������", imgui.ImVec2(-0.1, 0))
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
		imgui.Button(u8"22. �����������", imgui.ImVec2(-0.1, 0))
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(-1, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.5, 0.54, 0.59, 1.0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.35, 0.39, 0.44, 1.0))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.44, 0.5, 0.56, 1.0))
		if imgui.Button(u8"23. �������", imgui.ImVec2(-0.1, 0)) then
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
		if imgui.Button(u8"26. �������������", imgui.ImVec2(-0.1, 0)) then
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
		if imgui.Button(u8"27. ���������", imgui.ImVec2(-0.1, 0)) then
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
		if imgui.Button(u8"28. �������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat('/ainvite '..myid..' 28')
		end
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleColor(1)
		imgui.PopStyleVar(1)
		
		imgui.End()
	end

	if blist.v then
		imgui.ShowCursor = true
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.4, sh / 3.5))
		imgui.SetNextWindowSize(imgui.ImVec2(250, 400))
		imgui.Begin(u8'������ ������ ������� SLS RP', blist, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB("1. �����_�������\n2. Dexter_Young\n3. Aleksey_Dolmatov\n4. Miha_Chakhov\n5. ����_�����������\n6. ������_�������\n7. ����_��������\n8. Gangsta_Rep\n9. Christian_Clemence\n10. German_Shegay\n11. Steffen_Kobel\n12. Federico_Selamonto\n13. ������_�����\n14. �����������_�����\n15. Makcim_Cherevat\n16. Ninja_Lorin\n17. ����_���������\n18. ����_���������\n19. Cenky_Salvatore\n20. Mickey_Silver\n21. Kiruwa_Kalash\n22. ���_������\n23. ���_������� \n24. Ali_Mironov\n25. Sava_Killer\n26. Vlad_Kadilac\n27. Vlad_Kaigorodov\n28. ������_����\n29. Damon_Salvatore \n30. Niklaus_Mikaelson\n31. ����_������\n32. Momoshiki_Ootsutsuki\n33. Lorenz_Darkness\n34. Queen_Guerra \n35. Olya_Kotik\n36. Hidan_Matsurasi\n37. Dmitrii_Perekam\n38. Brixton_Mikaelson\n39. Svetlana_Basaeva \n40. Qaiyana_Maithe \n41. Anna_Basaeva\n42. Todoroki_Milfhunter\n43. Kaitlin_Zolotova\n44. Kesha_Salvatore\n45. Jaba_Davit\n46. Halva_Underground\n47. Alimbek_Bermudov\n48. Dante_Maretti\n49. Alex_Salvatore\n50. Estampillas_Hokanje \n51. Pelmsaha_Estampillas\n52. Ilya_Sadov\n53. Huge_Rain\n54. Max_Lingberg\n55. Stwix_Hexcore\n56. Givenchy_Paris\n58. Yashimoto_Gulev \n59. Polina_Dream \n60. James_Dream\n61. Egor_Safronov\n62. Yarik_Melnitsky\n63. Young_Strixx\n64. Ren_Martinez\n65. Alexei_Cheetov\n66. Holod_Shelby\n67. Alex_Main\n68. Vladislav_Milkovskei\n69. Aloevich_Yanee \n70. Morty_Lemeg \n71. Morgan_Jokson\n72. Horatio_Nelson\n73. Husen_Diorov\n74. Quartz_Jostkiy\n75. Korban_Krimov\n76. Caydam_Killaz\n77. Maksim_Bashkin\n78. Richard_Gir \n79. Warp_Inferno\n80. Yasha_Tenside\n81. Yasha_Inferno\n82. Treyz_Skillsize\n83. Lowka_Skillsize\n84. Lera_Rakova\n85. Dragon_Owo\n86. Santiz_Syndicate")
		imgui.End()
	end
	
	if apanel.v then
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
		if imgui.Checkbox(u8'�������� ������������� ����', chk.chatenbl) then
			if chk.chatenbl.v == true then
				sampSendChat("/chat")
			else
				sampSendChat("/chat")
			end
		end
		if imgui.Checkbox(u8'�������� ������������� ���������', chk.chatsmsenbl) then
			if chk.chatsmsenbl.v == true then
				sampSendChat("/chatsms")
			else
				sampSendChat("/chatsms")
			end
		end
		if imgui.Checkbox(u8'�������� ��������� �����', chk.aclist) then
			if chk.aclist.v == true then
			   sampSendChat("/aclist")
			else
			   sampSendChat("/aclist")
			end
        end
		imgui.Checkbox(u8'������ ��� ��������', chk.offhchat)
		imgui.Checkbox(u8'������ ��� �������', chk.offachat)
		if imgui.Button(u8"������� ����", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/uvalme")
		end
		if imgui.Button(u8"����� ����� ������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/ls")
		end
		if imgui.Button(u8"�������� �� ����� �����", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/gotoderby")
		end
		if imgui.Button(u8"�������� � ������� ����", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/liberty")
			sampAddChatMessage("������� ����", 0xB4B5B7)
		end
		if imgui.Button(u8"�������� �� �����", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/sp")
			sampAddChatMessage("����� ������", 0xB4B5B7)
		end
		if imgui.Button(u8"������ ���� ������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/aclear "..myid)
		end
		if imgui.Button(u8"���� ������", imgui.ImVec2(-0.1, 0)) then
			sampSendChat("/warnlist")
		end
		imgui.End()
	end

	if chathelpers.v then
		imgui.LockPlayer = true
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'��� ��������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild(' 4', imgui.ImVec2(700, 340), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB(table.concat(t1, '\n'))
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(10, 370))
		if imgui.InputText(u8'����', chk.chathelpinput, imgui.InputTextFlags.EnterReturnsTrue) then
			sampSendChat('/hc '..u8(chk.chathelpinput.v))
			chk.chathelpinput.v = ''
		end
		imgui.End()
	end
	
	if chatadmins.v then
		imgui.LockPlayer = true
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 4.4, sh / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400))
		imgui.Begin(u8'��� �������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('3 ', imgui.ImVec2(700, 340), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB(table.concat(t2, '\n'))
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(10, 370))
		if imgui.InputText(u8'����', chk.chatadminput, imgui.InputTextFlags.EnterReturnsTrue) then
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
		imgui.Begin(u8'��� �������� �������������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
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
		imgui.Begin(u8'��� ��������� ������ ������� �� �������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
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
		imgui.Begin(u8'��� ��� ����', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
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
		imgui.Begin(u8'��� �������������� �������', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('6 ', imgui.ImVec2(700, 360), false, imgui.WindowFlags.NoScrollbar)
		imgui.TextColoredRGB("{B4B5B7}".. table.concat(connectplayerslog, '\n{B4B5B7}'))
		imgui.EndChild()
		imgui.End()
	end
end


function samp.onShowMenu()
	if remenu.v then
		return false
	end
end

function samp.onShowTextDraw(id, data)
	if remenu.v then
		return false
	end
end

function samp.onHideMenu()
	if remenu.v then
		return false
	end
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B and not isPauseMenuActive() and not sampIsChatInputActive() and not sampIsDialogActive() then
		if chk.connectedplayers.v or chk.vipchatmenu.v or chk.reportsmenu.v or chk.admactionsmenu.v or chatadmins.v or chathelpers.v or apanel.v or blist.v or menuoffban.v or menuoffwarn.v or msetstat.v or changetheme.v or giveweapon.v or fractionsmenu.v or ruleswindow.v then
			consumeWindowMessage(true, false)
			if msg == 0x101 then
				chk.vipchatmenu.v = false
				apanel.v = false
				blist.v = false
				menuoffban.v = false
				menuoffwarn.v = false
				msetstat.v = false
				changetheme.v = false
				giveweapon.v = false
				fractionsmenu.v = false
				ruleswindow.v = false
				chathelpers.v = false
				chatadmins.v = false
				chk.admactionsmenu.v = false
				chk.reportsmenu.v = false
				chk.connectedplayers.v = false
			end
		end
		if lvl.v or zakon.v or mats.v or kills.v or xp.v or vip.v or moneybank.v or moneyhand.v or drugs.v or auto.v or narkozav.v then
			consumeWindowMessage(true, false)
			if msg == 0x101 then
				lvl.v = false
				zakon.v = false
				mats.v = false 
				kills.v = false
				xp.v = false
				vip.v = false
				moneybank.v = false
				moneyhand.v = false
				drugs.v = false
				auto.v = false
				narkozav.v = false
				msetstat.v = true
			end
		end
	end
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
	
	sampRegisterChatCommand("bank", function()
		setCharCoordinates(PLAYER_PED, 1416.41, -1700.23, 13.54)
	end)
	sampRegisterChatCommand("sit", function()
		sampSendChat("/anim 57")
	end)
	sampRegisterChatCommand("addmessage", function(b)
		if #b == 0 then
			sampAddChatMessage("/addmessage [�����] (����� ������������ RRGGBB ����)", -1)
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
	sampRegisterChatCommand('apn', apn)
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
	
	printStringNow("~r~AdminMode: ~w~�a�py�e�o", 10000)
	
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
		updateFile = inicfg.load(nil, update_path)
            if tonumber(updateFile.info.vers) > script_vers then
				updateFile = inicfg.load(nil, update_path)
                sampAddChatMessage("���� ����������! ������: " .. updateFile.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
	
	while true do
		wait(0)
		
			_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			nick = sampGetPlayerNickname(id)
		
		if isCharInAnyCar(PLAYER_PED) and not isCharInAnyPlane(PLAYER_PED) or isCharInAnyHeli(PLAYER_PED) then
			local car = storeCarCharIsInNoSave(PLAYER_PED)
			local carHealth = getCarHealth(car)
			wait(15)
			sampTextdrawCreate(100, "CAR HP: ~g~"..carHealth, 149.4, 359.5)
			sampTextdrawSetBoxColorAndSize(100, 1, 0x00000000, 279.5, 199)
			sampTextdrawSetLetterSizeAndColor(100, 0.251, 1.276, 0xFFC0C0C0)
			sampTextdrawSetStyle(100, 2)
			sampTextdrawSetAlign(100, 1)
			sampTextdrawSetOutlineColor(100, 1, 0x33000000)
		else
			wait(11)
			sampTextdrawDelete(100)
		end
		
		if isCharInAnyPlane(PLAYER_PED) or isCharInAnyHeli(PLAYER_PED) then
			local car = storeCarCharIsInNoSave(PLAYER_PED)
			local carSpeed = getCarSpeed(car) * 2
			local carHealth = getCarHealth(car)
			sampTextdrawCreate(101, "PLANE OR HELI SPEED: ~g~"..math.ceil(carSpeed), 149.4, 376)
			sampTextdrawSetBoxColorAndSize(101, 1, 0x65000000, 286.5, 199)
			sampTextdrawSetLetterSizeAndColor(101, 0.251, 1.276, 0xFFC0C0C0)
			sampTextdrawSetStyle(101, 2)
			sampTextdrawSetAlign(101, 1)
			sampTextdrawSetOutlineColor(101, 1, 0x33000000)
			sampTextdrawCreate(100, "CAR HP: ~g~"..carHealth, 149.4, 359.6)
			sampTextdrawSetBoxColorAndSize(100, 1, 0x65000000, 286.5, 199)
			sampTextdrawSetLetterSizeAndColor(100, 0.251, 1.276, 0xFFC0C0C0)
			sampTextdrawSetStyle(100, 2)
			sampTextdrawSetAlign(100, 1)
			sampTextdrawSetOutlineColor(100, 1, 0x33000000)
		else
			sampTextdrawDelete(101)
			sampTextdrawDelete(102)
		end
		
		sampTextdrawCreate(102, "�a� ID: ~g~"..id, 438.156, 2.835)
		sampTextdrawSetLetterSizeAndColor(102, 0.342, 2.074, 0xFFFFFFFF)
		sampTextdrawSetBoxColorAndSize(102, 1, 0x00000000, 640, 640)
		sampTextdrawSetStyle(102, 1)
		sampTextdrawSetAlign(102, 1)
		sampTextdrawSetOutlineColor(102, 1, 0xFF000000)
				
		
			
		imgui.Process = chk.connectedplayers.v or chk.vipchatmenu.v or chk.reportsmenu.v or chk.admactionsmenu.v or chatadmins.v or chathelpers.v or window.v or changetheme.v or blist.v or remenu.v or playercontrol.v or menuoffwarn.v or menuoffban.v or giveweapon.v or msetstat.v or lvl.v or zakon.v or mats.v or kills.v or xp.v or vip.v or moneybank.v or moneyhand.v or drugs.v or auto.v or narkozav.v or ruleswindow.v or fractionsmenu.v or apanel.v
		
		if not sampIsChatInputActive() and not sampIsDialogActive() then
			if isKeyDown(key.VK_R) then
				while isKeyDown(key.VK_R) do wait(80) end
				sampSendChat('/alock')
			end
		end
		
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("������ ������� ��������!", -1)
                    thisScript():reload()
                end
            end)
            break
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
	chatadmins.v = true
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
	blist.v = not blist.vend
end

function mstats()
	msetstat.v = true
end

function ahelp()
	sampShowDialog(30, "������� ���������������", "{66FFCC}��� �������� ��� ���������� ������� ���������������\n{66FFCC}��������� ������� ��������� � /ahelp �� ��������.\n {33AA33}< 1 > {FFFFFF}/hp, /skin, /togphone, /pm, /re, /reoff, /iwep\n{33AA33}< 1 > {FFFFFF}(/a)dmin, /jail, /unjail /mute, /mp, /uvalme\n{33AA33}< 1 > {FFFFFF}/offreport, /alogin, /tp, /ap, /mutelist, /warnlist, /knocklist, /wantedlist\n\n{33AA33}< 2 > {FFFFFF}/getstats, /fstyle, /chat, /(g)oto, /gethere, (/o)oc, /prison /unprison\n{33AA33}< 2 > {FFFFFF}(/sp)awn, /freeze, /unfreeze, /liberty\n\n{33AA33}< 3 > {FFFFFF}/slap, /warehouse\n{33AA33}< 3 > {FFFFFF}/mark, /gotomark\n{33AA33}< 4 > {FFFFFF}/spveh, /atune, /agetstats\n\n{33AA33}< 5 > {FFFFFF}/clearchat, /givegun, /(am)embers, /ao, /delveh\n\n{33CCFF}< 6 > {FFFFFF}/balance, /getdonate\n\n{33CCFF}< 7 > {FFFFFF}/setskin, /ls, /kick, /salut\n\n{FF9900}< 8 > {FFFFFF}/setbizprod, /aclear, /gotoderby\n{FF9900}< 8 > {FFFFFF}/money, /biz\n\n{FF9900}< 9 > {FFFFFF}/offgoto, /house\n{FF9900}< 9 > {FFFFFF}/offwarn, /givecash, /freehouses\n\n{D900D3}< 10 > {FFFFFF}/warn, /unwarn, /aclist, /object, /gotosp, /jetpack, /cord, /getban\n\n{EAC700}< 11 > {FFFFFF}/sethp, /location, /setclist\n{EAC700}< 11 > {FFFFFF}/agl, /aoffline, /delltext\n\n{FF0000}< 12 > {FFFFFF}/chatsms, /setskill, /weather\n{FF0000}< 12 > {FFFFFF}/unban, /pgetip, /getip", "�������", "�������", 0)
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
	sampShowDialog(101, "������� {FF0000}AdminMode", "{00FF00}1. {FFFFFF}/theme 		{FFFFFF}- �������� ����\n{00FF00}2. {FFFFFF}/az 			{FFFFFF}- ������������ �������� � �����-����\n{00FF00}3. {FFFFFF}/mstat 		{FFFFFF}- ���� ������� /setstat\n{00FF00}4. {FFFFFF}/weapon 		{FFFFFF}- ������ ������\n{00FF00}5. {FFFFFF}/ah 			{FFFFFF}- ���������� ������� �������������\n{00FF00}6. {FFFFFF}/apn 			{FFFFFF}- ���� �������\n{00FF00}7. {FFFFFF}/cmds 		{FFFFFF}- ���������� ��� ������� �������\n{00FF00}8. {FFFFFF}/bl 			{FFFFFF}- ������ ������ �������\n{00FF00}9. {FFFFFF}/stadm 		{FFFFFF}- ������ ������� �������������\n{00FF00}10. {FFFFFF}/frac 		{FFFFFF}- �������\n{00FF00}11. {FFFFFF}/rul 			{FFFFFF}- ���������� ���� ������ �������\n{00FF00}12. {FFFFFF}/cheat [ID] 		{FFFFFF}- ��� ������ � �������� << ���� >>\n{00FF00}13. {FFFFFF}/uns 		{FFFFFF}- ��������� ������ ������� ������� ��������� ���\n{00FF00}14. {FFFFFF}/offwarn 		{FFFFFF}- ���� � ��������\n{00FF00}15. {FFFFFF}/offban 		{FFFFFF}- ��� � ��������\n{00FF00}16. {FFFFFF}/gd [ID] [��] 	{FFFFFF}- ����������� ������� ������ ������ (�������� ���� � ��� ��� �������!)\n{00FF00}17. {FFFFFF}/dm [ID] 		{FFFFFF}- �������� ������ � �������� �� << �� >>\n{00FF00}18. {FFFFFF}/db [ID] 		{FFFFFF}- �������� ������ � �������� � �������� << �� >>\n{00FF00}19. {FFFFFF}/wa 		{FFFFFF}- ������ ���� ������\n{00FF00}20. {FFFFFF}/ip [ID] 		{FFFFFF}- ����������� IP ������\n{00FF00}21. {FFFFFF}/cname [ID] 	{FFFFFF}- ����������� ��� ������\n{00FF00}22. {FFFFFF}/offtop [ID] 		{FFFFFF}- ��� ������� ������ ������� ��������", "�������", "", 0)
end

function vert()
	sampSendChat("/veh 497 1 0")
end

function stadm()
	sampShowDialog(45, "{FF0000}������� �������������", "{FFFFFF}��� ��������������\t{FFFFFF}���������\nIsa_Kirimov\t{FF0000}���������{FFFFFF}\nJesse_Martinez\t{FFFF00}������������{FFFFFF}\nMorgan_Krimov\t{0000FF}������� �������������{FFFFFF}\nMonika_Lomb\t{339900}�� �� �����{FFFFFF}\nLucas_Stanley\t{0000FF}�� �� ����.{FFFFFF}\nDanil_Malyshev\t{3366FF}��. �������������{FFFFFF}\nHiashi_Salamander\t{3366FF}��. �������������{FFFFFF}\nFox_Yotanhaim\t{3366FF}��. �������������", "�������", "", 5)
end

function fractions()
	fractionsmenu.v = not fractionsmenu.v
end

function sysmute(param)
local id = string.match(param, "(%d+)")

	if id == nil then
		sampAddChatMessage("{FFFFFF}������� /uns (ID ������)", -1)
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
		sampAddChatMessage("{FFFFFF}������� /cheat [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/ban "..id.." 30 ����")
		end)
	end
	
end

function givedonate(arg)
local id, az = string.match(arg, "(.+) (.+)")

	if id == nil or id == "" or az == nil or az == "" then
		sampAddChatMessage("������� /gd [ID] [���-��]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/givedonate " .. id .. " " .. az)
		end)
	end
	
end

function dm(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}������� /dm [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/prison "..id.." 30 DM")
		end)
	end
end

function rules()
	ruleswindow.v = not ruleswindow.v 
end

function contract(param)
local id = string.match(param, "(%d+)")

	if id == nil then
		sampAddChatMessage("{FFFFFF}������� /co [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/contract "..id.." 10000000")
		end)
	end
	
end

function apn()
	apanel.v = true
end

function db(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}������� /db [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/prison "..id.." 30 DB")
		end)
	end
end

function warns(param)
local id, id2 = string.match(param, "(.+) (.+)")
	if id == nil or id == "" or id2 == "" or id2 == nil and id == nil then
		sampAddChatMessage("{FFFFFF}������� /wa [ID] [������� �� ������]", -1)
		sampAddChatMessage("{FFFFFF}�������: iz (nRP /iznas), sex (nRP /sex), rk, tk, sk, pg, ned (���������)", -1)
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
		sampSendChat("/warn "..id.." ���������")
		end)
	end
end

function theme()
	changetheme.v = true
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
	chathelpers.v = true
end

function ipget(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}������� /ip [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/ags "..sampGetPlayerNickname(id))
		wait(100)
		sampCloseCurrentDialogWithButton(0)
		end)
	end
	sampAddChatMessage("IP ������ "..sampGetPlayerNickname(id).." ["..id.. "] ����������!", 0xFFFF00)
end

function nameget(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}������� /cname [ID]", -1)
	else
		lua_thread.create(function()
		setClipboardText(sampGetPlayerNickname(id))
		end)
	end
	sampAddChatMessage("��� ������ "..sampGetPlayerNickname(id).." ["..id.. "] ����������!", 0xFFFF00)
end

function offtop(param)
local id = string.match(param, "(%d+)")
	if id == nil then
		sampAddChatMessage("{FFFFFF}������� /offtop [ID]", -1)
	else
		lua_thread.create(function()
		sampSendChat("/rmute "..id.." 10 ������")
		end)
	end
end

function offwarn()
	menuoffwarn.v = true
end

function offban()
	menuoffban.v = true
end

function weapon()
	giveweapon.v = not giveweapon.v
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