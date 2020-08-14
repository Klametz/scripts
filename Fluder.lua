-- author - https://vk.com/klamet1
require "lib.sampfuncs"
require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local imgui = require 'imgui'
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8
update_state = false
local themes = import "lib/resource/imgui_themes"
local inicfg = require 'inicfg'
local initable = {
tabl = {
	flud1 = nil,
	smstime1 = 1000,
	flud2 = nil,
	smstime2 = 1000
	}
}
local tables
local ffi = require "ffi"
ffi.cdef[[
	void keybd_event(int keycode, int scancode, int flags, int extra);
]]
local keys = require "vkeys"
local script_vers = 2
local script_vers_text = "1.1"
local update_url = "https://raw.githubusercontent.com/Klametz/scripts/master/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"
local script_url = "https://github.com/Klametz/scripts/raw/master/Fluder.lua"
local script_path = thisScript().path
local main_color = 0x5A90CE
local main_color_text = "{FFFF00}"
local tag = "[������]: "
local main_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(256)
local text_buffer_2 = imgui.ImBuffer(256)
local checkbox = imgui.ImBool(false)
local checkbox_2 = imgui.ImBool(false)
local selected_item = imgui.ImInt(0)
local slider = imgui.ImFloat(1)
local slider_2 = imgui.ImFloat(1)
local sw, sh = getScreenResolution()
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("fluder", fluder)
	sampRegisterChatCommand("stopflud", stopflud)
	sampRegisterChatCommand("fludall", fludall)
	sampRegisterChatCommand("flud1", flud1)
	sampRegisterChatCommand("flud2", flud2)
	sampRegisterChatCommand("updateinfo", updateinfo)
	sampAddChatMessage(tag .. main_color_text .. "������ ����� � ������. ����� - " .. "{FFFFFF}" ..  "�����" .. main_color_text .. "! ���������: ������� " .. "{FFFFFF}" .. "HOME", main_color)
	active1 = false
	active2 = false
	imgui.Process = false
	theme = 1
	flud1 = nil
	flud2 = nil
	smstime1 = 1
	smstime2 = 1
	vr1 = false
	vr2 = false
	if not doesDirectoryExist("moonloader//lib") then
		createDirectory("moonloader//lib")
		inicfg.save(initable, "fluder")
	end
	tables = inicfg.load(nil, "fluder")
	if tables == nil then
		inicfg.save(initable, "fluder")
		tables = inicfg.load(nil, "fluder")
	end
	imgui.SwitchContext()
	themes.SwitchColorTheme(tables.tabl.theme)
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.vers) > script_vers then
				sampAddChatMessage(tag .. main_color_text .. "����� ������� �������� ����������! ����� ������: {FFFFFF}" .. updateIni.info.vers_text .. "{FFFF00}, ������� ������: {FFFFFF}" .. script_vers_text, main_color)
				update_state = true
			end
			os.remove(update_path)
		end
	end)
	while true do
	wait(0)
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage(tag .. main_color_text .. "������ ������� {FFFFFF}��������{FFFF00}!", main_color)
					thisScript():reload()
				end
			end)
			break
		end
		if active1 == true and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
			if vr1 == false then
				sampSendChat(tables.tabl.flud1)
				wait(tables.tabl.smstime1)
			else
				sampSendChat("/vr " .. tables.tabl.flud1)
				wait(500)
				sampSendChat("/vr " .. tables.tabl.flud1)
				wait(500)
				sampSendChat("/vr " .. tables.tabl.flud1)
				wait(tables.tabl.smstime1 + 1000)
			end
		end
		if active2 == true and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
			if vr2 == false then
				sampSendChat(tables.tabl.flud1)
				wait(tables.tabl.smstime1)
			else
				sampSendChat(tables.tabl.flud1)
				wait(500)
				sampSendChat(tables.tabl.flud1)
				wait(500)
				sampSendChat(tables.tabl.flud1)
				wait(tables.tabl.smstime1 + 1000)
			end
		end
		if isKeyJustPressed(VK_HOME) and not sampIsChatInputActive() and not isPauseMenuActive() then
		sampAddChatMessage(tag .. "{FFFFFF}-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------", main_color)
		sampAddChatMessage(tag .. main_color_text .. "����� ������� - " .. "{FFFFFF}" .. "https://vk.com/klamet1/" .. main_color_text .. ", ������ �� ��������� - " .. "{FFFFFF}" .. "https://vk.com/sctiptsofsomik/", main_color)
		sampAddChatMessage(tag .. main_color_text .. "��������� �������� ���� ������� - {FFFFFF}/fluder", main_color)
		sampAddChatMessage(tag .. main_color_text .. "���������/���������� ���� 1-���/2-��� ��������� - {FFFFFF}/flud1{FFFF00} | {FFFFFF}/flud2", main_color)
		sampAddChatMessage(tag .. main_color_text .. "��������� ��� ��������� ��� ����� - ������� {FFFFFF}/fludall", main_color)
		sampAddChatMessage(tag .. main_color_text .. "���������� ���� ���� - ������� {FFFFFF}/stopflud", main_color)
		sampAddChatMessage(tag .. main_color_text .. "������� ����������  - ������� {FFFFFF}/updateinfo", main_color)
		sampAddChatMessage(tag .. "{FFFFFF}-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------", main_color)
		end
	end
end
function fluder()
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end
function fludall()
	sampAddChatMessage(tag .. main_color_text .. "��� ��������� ��� ����� ���� {FFFFFF}��������{FFFF00}!", main_color)
	active1 = true
	active2 = true
end
function stopflud()
	active1 = false
	active2 = false
	sampAddChatMessage(tag .. main_color_text .. "��� ���������� ��������� ��� ����� ���� {FFFFFF}�����������{FFFF00}!", main_color)
end
function flud1()
	if active1 == true then
		active1 = false
		sampAddChatMessage(tag .. main_color_text .. "���� ������� ������������������ {FFFFFF}����������{FFFF00}!", main_color)
	else
		active1 = true
		sampAddChatMessage(tag .. main_color_text .. "���� ������� ������������������ {FFFFFF}�������{FFFF00}!", main_color)
	end
end
function flud2()
	if active2 == true then
		active2 = false
		sampAddChatMessage(tag .. main_color_text .. "���� ������� ��������� {FFFFFF}����������{FFFF00}!", main_color)
	else
		active2 = true
		sampAddChatMessage(tag .. main_color_text .. "���� ������� ��������� {FFFFFF}�������{FFFF00}!", main_color)
	end
end
function updateinfo()
	sampShowDialog(1, '{FFFF00}������� ���������� ������� "������"', "{00ff00}������ 1.1:\n{FFFFFF}- ������������� ���\n- �������� ����� ����� ����� (��� /vr)\n- ��������� ������ � �������� ����, ������� ��������� ���������� ���� � �������� ����������\n- ��������� ������� /updateinfo\n{00ff00}������ 1.0:\n{FFFFFF}- �����", "�������", "", 0)
end
function imgui.OnDrawFrame()
	if not main_window_state.v then
		imgui.Process = false
	end
	if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(565, 475), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"������", main_window_state, imgui.WindowFlags.NoResize)
		imgui.Text(u8"����� ����:")
		imgui.SameLine()
		if imgui.Combo(u8'', selected_item, {u8"����������� ����", u8"�������", u8"����������", u8"����", u8"׸����", u8"����������", u8"�����-���������"}, 7) then
			if selected_item.v == 0 then
				themes.SwitchColorTheme(1)
				theme = 1
			end
			if selected_item.v == 1 then
				themes.SwitchColorTheme(2)
				theme = 2
			end
			if selected_item.v == 2 then
				themes.SwitchColorTheme(3)
				theme = 3
			end
			if selected_item.v == 3 then
				themes.SwitchColorTheme(4)
				theme = 4
			end
			if selected_item.v == 4 then
				themes.SwitchColorTheme(5)
				theme = 5
			end
			if selected_item.v == 5 then
				themes.SwitchColorTheme(6)
				theme = 6
			end
			if selected_item.v == 6 then
				themes.SwitchColorTheme(7)
				theme = 7
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"��������� ����") then
			tables.tabl.theme = theme
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "���� ������� {FFFFFF}���������{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.InputText(u8"������ ���������", text_buffer) then
			flud1 = text_buffer.v
		end
		imgui.Text(u8"���� ���������: " .. text_buffer.v)
		function imgui.TextQuestion(text)
			imgui.TextDisabled('(?)')
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(450)
				imgui.TextUnformatted(text)
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end
		end
		if imgui.Checkbox(u8"����� ����� � /vr. ��������� �1", checkbox) then
			if checkbox.v == true then
				vr1 = true
			end
			if checkbox.v == false then
				vr1 = false
			end
		end
		imgui.SameLine()
		imgui.TextQuestion(u8'���� ����� ��� ����� � /vr �������, �� ��� ����� ��������� ���������� 3 ���� ������, � ����������� 0.5 ������. ���� ����� �������, �� /vr � ������ ����� ������ ������ �� ����.')
		if imgui.Button(u8"��������� ����������� ��������� �1") then
			if tables.tabl.flud1 == nil then
				sampAddChatMessage(tag .. main_color_text .. "�� �� ������� ������ {FFFFFF}���������{FFFF00}!", main_color)
			else
				sampAddChatMessage(tag .. main_color_text .. "� ��� �������� ��������� ����������� {FFFFFF}���������{FFFF00}:", main_color)
				sampAddChatMessage(tag .. "{FFFFFF}" .. u8:decode(tables.tabl.flud1), main_color)
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"��������� ��������� �1") then
			tables.tabl.flud1 = flud1
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "��������� �1 ������� {FFFFFF}���������{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"������� ��������� �1") then
			tables.tabl.flud1 = nil
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "��������� �1 ������� {FFFFFF}�������{FFFF00}!", main_color)
		end
		if imgui.Button(u8"��������� ���� ��������� �1") then
			active1 = true
			sampAddChatMessage(tag .. main_color_text .. "���� ������� ��������� {FFFFFF}�������{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"���������� ���� ��������� �1") then
			active1 = false
			sampAddChatMessage(tag .. main_color_text .. "���� ������� ��������� {FFFFFF}����������{FFFF00}!", main_color)
		end
		if imgui.SliderFloat(u8"�������� ������� ���������", slider, 1, 20, '%.0f') then
			smstime1 = slider.v * 1000
		end
		if imgui.Button(u8"��������� ����������� �������� 1-��� ���������") then
			sampAddChatMessage(tag .. main_color_text .. "������� �������� ��������� ������� ������: {FFFFFF}" .. tables.tabl.smstime1 / 1000 .. " {FFFF00}������(�/�)", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"��������� �������� ��������� �1") then
			tables.tabl.smstime1 = smstime1
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "����� �������� ������� {FFFFFF}���������{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.InputText(u8"������ ���������", text_buffer_2) then
			flud2 = text_buffer_2.v
		end
		imgui.Text(u8"���� ���������: " .. text_buffer_2.v)
		function imgui.TextQuestion(text)
			imgui.TextDisabled('(?)')
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(450)
				imgui.TextUnformatted(text)
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end
		end
		if imgui.Checkbox(u8"����� ����� � /vr. ��������� �2", checkbox_2) then
			if checkbox_2.v == true then
				vr2 = true
			end
			if checkbox_2.v == false then
				vr2 = false
			end
		end
		imgui.SameLine()
		imgui.TextQuestion(u8'���� ����� ��� ����� � /vr �������, �� ��� ����� ��������� ���������� 3 ���� ������, � ����������� 0.5 ������. ���� ����� �������, �� /vr � ������ ����� ������ ������ �� ����.')
		if imgui.Button(u8"��������� ����������� ��������� �2") then
			if tables.tabl.flud2 == nil then
				sampAddChatMessage(tag .. main_color_text .. "�� �� ������� ������ {FFFFFF}���������{FFFF00}!", main_color)
			else
				sampAddChatMessage(tag .. main_color_text .. "� ��� �������� ��������� ����������� {FFFFFF}���������{FFFF00}:", main_color)
				sampAddChatMessage(tag .. "{FFFFFF}" .. u8:decode(tables.tabl.flud2), main_color)
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"��������� ��������� �2") then
			tables.tabl.flud2 = flud2
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "��������� �2 ������� {FFFFFF}���������{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"������� ��������� �2") then
			tables.tabl.flud2 = nil
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "��������� �2 ������� {FFFFFF}�������{FFFF00}!", main_color)
		end
		if imgui.Button(u8"��������� ���� ��������� �2") then
			active2 = true
			sampAddChatMessage(tag .. main_color_text .. "���� ������� ��������� {FFFFFF}�������{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"���������� ���� ��������� �2") then
			active2 = false
			sampAddChatMessage(tag .. main_color_text .. "���� ������� ��������� {FFFFFF}����������{FFFF00}!", main_color)
		end
		if imgui.SliderFloat(u8"�������� ������� ���������", slider_2, 1, 20, '%.0f') then
			smstime2 = slider_2.v * 1000
		end
		if imgui.Button(u8"��������� ����������� �������� 2-��� ���������") then
			sampAddChatMessage(tag .. main_color_text .. "������� �������� ��������� ������� ������: {FFFFFF}" .. tables.tabl.smstime2 / 1000 .. " {FFFF00}������(�/�)", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"��������� �������� ��������� �2") then
			tables.tabl.smstime2 = smstime2
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "����� �������� ������� {FFFFFF}���������{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.Button(u8"��������� ���� ����� ���� ���������") then
			active1 = true
			active2 = true
			sampAddChatMessage(tag .. main_color_text .. "��� ��������� ��� ����� ���� {FFFFFF}��������{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"���������� ���� ����� ���� ���������") then
			active1 = false
			active2 = false
			sampAddChatMessage(tag .. main_color_text .. "��� ���������� ��������� ��� ����� ���� {FFFFFF}�����������{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.Button(u8"������� ���������� �������") then
			updateinfo()
			sampAddChatMessage(tag .. main_color_text .. "�� {FFFFFF}������� {FFFF00}������� ���������� ���� � �������� ���������� �������!", main_color)
		end
		imgui.Separator()
		imgui.Text(u8"������ ����� ����� ���� ��������� ����� ������� ��������������!")
		imgui.End()
	end
end