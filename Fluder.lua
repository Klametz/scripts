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
local tag = "[Флудер]: "
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
	sampAddChatMessage(tag .. main_color_text .. "Скрипт готов к работе. Автор - " .. "{FFFFFF}" ..  "СоМиК" .. main_color_text .. "! Подробнее: клавиша " .. "{FFFFFF}" .. "HOME", main_color)
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
				sampAddChatMessage(tag .. main_color_text .. "Автор скрипта выпустил обновление! Новая версия: {FFFFFF}" .. updateIni.info.vers_text .. "{FFFF00}, текущая версия: {FFFFFF}" .. script_vers_text, main_color)
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
					sampAddChatMessage(tag .. main_color_text .. "Скрипт успешно {FFFFFF}обновлен{FFFF00}!", main_color)
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
		sampAddChatMessage(tag .. main_color_text .. "Автор скрипта - " .. "{FFFFFF}" .. "https://vk.com/klamet1/" .. main_color_text .. ", группа со скриптами - " .. "{FFFFFF}" .. "https://vk.com/sctiptsofsomik/", main_color)
		sampAddChatMessage(tag .. main_color_text .. "Запустить основное окно скрипта - {FFFFFF}/fluder", main_color)
		sampAddChatMessage(tag .. main_color_text .. "Запустить/остановить флуд 1-ого/2-ого сообщения - {FFFFFF}/flud1{FFFF00} | {FFFFFF}/flud2", main_color)
		sampAddChatMessage(tag .. main_color_text .. "Запустить все сообщения для флуда - команда {FFFFFF}/fludall", main_color)
		sampAddChatMessage(tag .. main_color_text .. "Остановить весь флуд - команда {FFFFFF}/stopflud", main_color)
		sampAddChatMessage(tag .. main_color_text .. "История обновлений  - команда {FFFFFF}/updateinfo", main_color)
		sampAddChatMessage(tag .. "{FFFFFF}-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------", main_color)
		end
	end
end
function fluder()
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end
function fludall()
	sampAddChatMessage(tag .. main_color_text .. "Все сообщения для флуда были {FFFFFF}запущены{FFFF00}!", main_color)
	active1 = true
	active2 = true
end
function stopflud()
	active1 = false
	active2 = false
	sampAddChatMessage(tag .. main_color_text .. "Все запущенные сообщения для флуда были {FFFFFF}остановлены{FFFF00}!", main_color)
end
function flud1()
	if active1 == true then
		active1 = false
		sampAddChatMessage(tag .. main_color_text .. "Флуд первого сообщениясообщения {FFFFFF}остановлен{FFFF00}!", main_color)
	else
		active1 = true
		sampAddChatMessage(tag .. main_color_text .. "Флуд первого сообщениясообщения {FFFFFF}запущен{FFFF00}!", main_color)
	end
end
function flud2()
	if active2 == true then
		active2 = false
		sampAddChatMessage(tag .. main_color_text .. "Флуд второго сообщения {FFFFFF}остановлен{FFFF00}!", main_color)
	else
		active2 = true
		sampAddChatMessage(tag .. main_color_text .. "Флуд второго сообщения {FFFFFF}запущен{FFFF00}!", main_color)
	end
end
function updateinfo()
	sampShowDialog(1, '{FFFF00}История обновлений скрипта "Флудер"', "{00ff00}Версия 1.1:\n{FFFFFF}- оптимизирован код\n- добавлен новый режим флуда (для /vr)\n- добавлена кнопка в основном меню, которая открывает диалоговое окно с историей обновлений\n- добавлена команда /updateinfo\n{00ff00}Версия 1.0:\n{FFFFFF}- релиз", "Закрыть", "", 0)
end
function imgui.OnDrawFrame()
	if not main_window_state.v then
		imgui.Process = false
	end
	if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(565, 475), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Флудер", main_window_state, imgui.WindowFlags.NoResize)
		imgui.Text(u8"Выбор темы:")
		imgui.SameLine()
		if imgui.Combo(u8'', selected_item, {u8"Стандартная тема", u8"Красная", u8"Коричневая", u8"Аква", u8"Чёрная", u8"Фиолетовая", u8"Черно-оранжевая"}, 7) then
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
		if imgui.Button(u8"сохранить тему") then
			tables.tabl.theme = theme
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "Тема успешно {FFFFFF}сохранена{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.InputText(u8"первое сообщение", text_buffer) then
			flud1 = text_buffer.v
		end
		imgui.Text(u8"Ваше сообщение: " .. text_buffer.v)
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
		if imgui.Checkbox(u8"режим флуда в /vr. Сообщение №1", checkbox) then
			if checkbox.v == true then
				vr1 = true
			end
			if checkbox.v == false then
				vr1 = false
			end
		end
		imgui.SameLine()
		imgui.TextQuestion(u8'Если режим для флуда в /vr включен, то при флуде сообщение отправится 3 раза подряд, с промежутком 0.5 секунд. Если режим включен, то /vr в строке ввода текста писать не надо.')
		if imgui.Button(u8"последнее сохраненное сообщение №1") then
			if tables.tabl.flud1 == nil then
				sampAddChatMessage(tag .. main_color_text .. "Вы не указали первое {FFFFFF}сообщение{FFFF00}!", main_color)
			else
				sampAddChatMessage(tag .. main_color_text .. "В чат выведено последнее сохраненное {FFFFFF}сообщение{FFFF00}:", main_color)
				sampAddChatMessage(tag .. "{FFFFFF}" .. u8:decode(tables.tabl.flud1), main_color)
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"сохранить сообщение №1") then
			tables.tabl.flud1 = flud1
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "Сообщение №1 успешно {FFFFFF}сохранено{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"удалить сообщение №1") then
			tables.tabl.flud1 = nil
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "Сообщение №1 успешно {FFFFFF}удалено{FFFF00}!", main_color)
		end
		if imgui.Button(u8"запустить флуд сообщения №1") then
			active1 = true
			sampAddChatMessage(tag .. main_color_text .. "Флуд первого сообщения {FFFFFF}запущен{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"остановить флуд сообщения №1") then
			active1 = false
			sampAddChatMessage(tag .. main_color_text .. "Флуд первого сообщения {FFFFFF}остановлен{FFFF00}!", main_color)
		end
		if imgui.SliderFloat(u8"задержка первого сообщения", slider, 1, 20, '%.0f') then
			smstime1 = slider.v * 1000
		end
		if imgui.Button(u8"последняя сохраненная задержка 1-ого сообщения") then
			sampAddChatMessage(tag .. main_color_text .. "Текущая задержка сообщений первого текста: {FFFFFF}" .. tables.tabl.smstime1 / 1000 .. " {FFFF00}секунд(а/ы)", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"сохранить задержку сообщению №1") then
			tables.tabl.smstime1 = smstime1
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "Новая задержка успешно {FFFFFF}сохранена{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.InputText(u8"второе сообщение", text_buffer_2) then
			flud2 = text_buffer_2.v
		end
		imgui.Text(u8"Ваше сообщение: " .. text_buffer_2.v)
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
		if imgui.Checkbox(u8"режим флуда в /vr. Сообщение №2", checkbox_2) then
			if checkbox_2.v == true then
				vr2 = true
			end
			if checkbox_2.v == false then
				vr2 = false
			end
		end
		imgui.SameLine()
		imgui.TextQuestion(u8'Если режим для флуда в /vr включен, то при флуде сообщение отправится 3 раза подряд, с промежутком 0.5 секунд. Если режим включен, то /vr в строке ввода текста писать не надо.')
		if imgui.Button(u8"последнее сохраненное сообщение №2") then
			if tables.tabl.flud2 == nil then
				sampAddChatMessage(tag .. main_color_text .. "Вы не указали второе {FFFFFF}сообщение{FFFF00}!", main_color)
			else
				sampAddChatMessage(tag .. main_color_text .. "В чат выведено последнее сохраненное {FFFFFF}сообщение{FFFF00}:", main_color)
				sampAddChatMessage(tag .. "{FFFFFF}" .. u8:decode(tables.tabl.flud2), main_color)
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"сохранить сообщение №2") then
			tables.tabl.flud2 = flud2
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "Сообщение №2 успешно {FFFFFF}сохранено{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"удалить сообщение №2") then
			tables.tabl.flud2 = nil
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "Сообщение №2 успешно {FFFFFF}удалено{FFFF00}!", main_color)
		end
		if imgui.Button(u8"запустить флуд сообщения №2") then
			active2 = true
			sampAddChatMessage(tag .. main_color_text .. "Флуд второго сообщения {FFFFFF}запущен{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"остановить флуд сообщения №2") then
			active2 = false
			sampAddChatMessage(tag .. main_color_text .. "Флуд второго сообщения {FFFFFF}остановлен{FFFF00}!", main_color)
		end
		if imgui.SliderFloat(u8"задержка второго сообщения", slider_2, 1, 20, '%.0f') then
			smstime2 = slider_2.v * 1000
		end
		if imgui.Button(u8"последняя сохраненная задержка 2-ого сообщения") then
			sampAddChatMessage(tag .. main_color_text .. "Текущая задержка сообщений второго текста: {FFFFFF}" .. tables.tabl.smstime2 / 1000 .. " {FFFF00}секунд(а/ы)", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"сохранить задержку сообщению №2") then
			tables.tabl.smstime2 = smstime2
			inicfg.save(tables, "fluder")
			sampAddChatMessage(tag .. main_color_text .. "Новая задержка успешно {FFFFFF}сохранена{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.Button(u8"запустить флуд сразу двух сообщений") then
			active1 = true
			active2 = true
			sampAddChatMessage(tag .. main_color_text .. "Все сообщения для флуда были {FFFFFF}запущены{FFFF00}!", main_color)
		end
		imgui.SameLine()
		if imgui.Button(u8"остановить флуд сразу всех сообщений") then
			active1 = false
			active2 = false
			sampAddChatMessage(tag .. main_color_text .. "Все запущенные сообщения для флуда были {FFFFFF}остановлены{FFFF00}!", main_color)
		end
		imgui.Separator()
		if imgui.Button(u8"история обновлений скрипта") then
			updateinfo()
			sampAddChatMessage(tag .. main_color_text .. "Вы {FFFFFF}успешно {FFFF00}открыли диалоговое окно с историей обновлений скрипта!", main_color)
		end
		imgui.Separator()
		imgui.Text(u8"Запуск флуда сразу всех сообщений может вызвать нестабильность!")
		imgui.End()
	end
end