script_name("MedicalHelper")
script_authors("Rebern by GiVKa")
script_description("Script for the Ministries of Health Arizona Role Play")
script_version("3.2.0")
script_properties("work-in-pause")

local text_err_and_read = {
	[1] = [[
 Не обнаружен файл SAMPFUNCS.asi в корне игры, установите его
согласно инструкции.

		Как это сделать:
1. Скачать файл;
2. Переместить в папку "игры".
Если папки "игры" нет, создайте её в корне "Moonloader" и назовите "библиотеки".
После установки перезагрузите игру или перезапустите скрипт. 

Если у вас всё равно не работает, обращайтесь в поддержку:
		vk.com/marseloy

Если всё работает, можете удалить это сообщение. 
]],
	[2] = [[
		  Внимание! 
Не обнаружены следующие файлы для работы скрипта.
В корне игры, также скачать и установить.
	Список недостающих файлов:
		%s

		Как это сделать:
1. Скачать файлы;
2. Переместить в папку "игры".
Если папки "игры" нет, создайте её в корне "Moonloader" и назовите "библиотеки".
После установки перезагрузите игру или перезапустите скрипт.

Если у вас всё равно не работает, обращайтесь в поддержку:
		vk.com/marseloy

Если всё работает, можете удалить это сообщение. 
]],
	[3] = {
		"/lib/imgui.lua",
		"/lib/samp/events.lua",
		"/lib/rkeysMH.lua",
		"/lib/faIcons.lua",
		"/lib/crc32ffi.lua",
		"/lib/bitex.lua",
		"/lib/MoonImGui.dll",
		"/lib/matrix3x3.lua"
	},
	[4] = {}
}

if doesFileExist(getWorkingDirectory().."/lib/rkeysMH.lua") then
	print("{82E28C}Найден файл rkeysMH...")
	local f = io.open(getWorkingDirectory().."/lib/rkeysMH.lua")
	f:close()
else
	print("{F54A4A}Ошибка. Отсутствует файл rkeysMH. {82E28C}Создаю новый файл rkeysMH...")
	local textrkeys = [[
local vkeys = require 'vkeys'

vkeys.key_names[vkeys.VK_LMENU] = "LAlt"
vkeys.key_names[vkeys.VK_RMENU] = "RAlt"
vkeys.key_names[vkeys.VK_LSHIFT] = "LShift"
vkeys.key_names[vkeys.VK_RSHIFT] = "RShift"
vkeys.key_names[vkeys.VK_LCONTROL] = "LCtrl"
vkeys.key_names[vkeys.VK_RCONTROL] = "RCtrl"

local tHotKey = {}
local tKeyList = {}
local tKeysCheck = {}
local iCountCheck = 0
local tBlockKeys = {[vkeys.VK_LMENU] = true, [vkeys.VK_RMENU] = true, [vkeys.VK_RSHIFT] = true, [vkeys.VK_LSHIFT] = true, [vkeys.VK_LCONTROL] = true, [vkeys.VK_RCONTROL] = true}
local tModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true}
local tBlockNext = {}
local module = {}
module._VERSION = "1.0.7"
module._MODKEYS = tModKeys
module._LOCKKEYS = false

local function getKeyNum(id)
   for k, v in pairs(tKeyList) do
      if v == id then
         return k
      end
   end
   return 0
end

function module.blockNextHotKey(keys)
   local bool = false
   if not module.isBlockedHotKey(keys) then
      tBlockNext[#tBlockNext + 1] = keys
      bool = true
   end
   return bool
end

function module.isHotKeyHotKey(keys, keys2)
   local bool
   for k, v in pairs(keys) do
      local lBool = true
      for i = 1, #keys2 do
         if v ~= keys2[i] then
            lBool = false
            break
         end
      end
      if lBool then
         bool = true
         break
      end
   end
   return bool
end


function module.isBlockedHotKey(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tBlockNext) do
      if module.isHotKeyHotKey(keys, v) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end

function module.unBlockNextHotKey(keys)
   local result = false
   local count = 0
   while module.isBlockedHotKey(keys) do
      local _, id = module.isBlockedHotKey(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   for k, v in pairs(tBlockNext) do
      tBlockNext[id] = v
      id = id + 1
   end
   return result, count
end

function module.isKeyModified(id)
   return (tModKeys[id] or false) or (tBlockKeys[id] or false)
end

function module.isModifiedDown()
   local bool = false
   for k, v in pairs(tModKeys) do
      if isKeyDown(k) then
         bool = true
         break
      end
   end
   return bool
end

lua_thread.create(function ()
   while true do
      wait(0)
      local tDownKeys = module.getCurrentHotKey()
      for k, v in pairs(tHotKey) do
         if #v.keys > 0 then
            local bool = true
            for i = 1, #v.keys do
               if i ~= #v.keys and (getKeyNum(v.keys[i]) > getKeyNum(v.keys[i + 1]) or getKeyNum(v.keys[i]) == 0) then
                  bool = false
                  break
               elseif i == #v.keys and (v.pressed and not wasKeyPressed(v.keys[i]) or not v.pressed and not isKeyDown(v.keys[i])) or (#v.keys == 1 and module.isModifiedDown()) then
                  bool = false
                  break
               end
            end
            if bool and ((module.onHotKey and module.onHotKey(k, v.keys) ~= false) or module.onHotKey == nil) then
               local result, id = module.isBlockedHotKey(v.keys)
               if not result then
                  v.callback(k, v.keys)
               else
                  tBlockNext[id] = nil
               end
            end
         end
      end
   end
end)

function module.registerHotKey(keys, pressed, callback)
   tHotKey[#tHotKey + 1] = {keys = keys, pressed = pressed, callback = callback}
   return true, #tHotKey
end

function module.getAllHotKey()
   return tHotKey
end

function module.unRegisterHotKey(keys)

   local result = false
   local count = 0
   while module.isHotKeyDefined(keys) do
      local _, id = module.isHotKeyDefined(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   local tNewHotKey = {}
   for k, v in pairs(tHotKey) do
      tNewHotKey[id] = v
      id = id + 1
   end
   tHotKey = tNewHotKey
   return result, count
 
end

function module.isHotKeyDefined(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tHotKey) do
      if module.isHotKeyHotKey(keys, v.keys) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end

function module.getKeysName(keys)
   local tKeysName = {}
   for k, v in ipairs(keys) do
      tKeysName[k] = vkeys.id_to_name(v)
   end
   return tKeysName
end

function module.getCurrentHotKey(type)
   local type = type or 0
   local tCurKeys = {}
   for k, v in pairs(vkeys) do
      if tBlockKeys[v] == nil then
         local num, down = getKeyNum(v), isKeyDown(v)
         if down and num == 0 then
            tKeyList[#tKeyList + 1] = v
         elseif num > 0 and not down then
            tKeyList[num] = nil
         end
      end
   end
   local i = 1
   for k, v in pairs(tKeyList) do
      tCurKeys[i] = type == 0 and v or vkeys.id_to_name(v)
      i = i + 1
   end
   return tCurKeys
end

return module

]]
	local f = io.open(getWorkingDirectory().."/lib/rkeysMH.lua", "w")
	f:write(textrkeys)
	f:close()			
end

for i,v in ipairs(text_err_and_read[3]) do
	if not doesFileExist(getWorkingDirectory()..v) then
		table.insert(text_err_and_read[4], v)
	end
end

local ffi = require 'ffi'
ffi.cdef [[
		typedef int BOOL;
		typedef unsigned long HANDLE;
		typedef HANDLE HWND;
		typedef const char* LPCSTR;
		typedef unsigned UINT;
		
        void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
        uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		
		BOOL ShowWindow(HWND hWnd, int  nCmdShow);
		HWND GetActiveWindow();
		
		
		int MessageBoxA(
		  HWND   hWnd,
		  LPCSTR lpText,
		  LPCSTR lpCaption,
		  UINT   uType
		);
		
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
  ]]

require "lib.sampfuncs"
require "lib.moonloader"
local mem = require "memory"
local vkeys = require "vkeys"

local encoding = require "encoding"
if not doesFileExist(getWorkingDirectory().."/lib/effil.lua") then
	effilNOT = true
else
	effil = require "effil"
	effilNOT = false
end
if not doesFileExist(getWorkingDirectory().."/lib/bass.lua") then
	bassNOT = true
else
	bass = require "bass"
	bass.BASS_Stop()
	bass.BASS_Start()
	bassNOT = false
end
encoding.default = "CP1251"
local u8 = encoding.UTF8
local dlstatus = require("moonloader").download_status
local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)

if not doesFileExist(getGameDirectory().."/SAMPFUNCS.asi") then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[1], "MedicalHelper", 0x00000030 + 0x00010000)
end
if #text_err_and_read[4] > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[2]:format(table.concat(text_err_and_read[4], "\n\t\t")), "MedicalHelper", 0x00000030 + 0x00010000)
end
text_err_and_read = nil

local res, hook = pcall(require, 'lib.samp.events')
assert(res, "Ошибка загрузки SAMP Event.")
---------------------------------------------------
local res, imgui = pcall(require, "imgui")
assert(res, "Ошибка загрузки Imgui.")
---------------------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, "Ошибка загрузки faIcons.")
---------------------------------------------------
local res, rkeys = pcall(require, 'rkeysMH')
assert(res, "Ошибка загрузки Rkeys.")
vkeys.key_names[vkeys.VK_RBUTTON] = "RBut"
vkeys.key_names[vkeys.VK_XBUTTON1] = "XBut1"
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'

imgRECORD = {}
function download_image()
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/record.png") then
		print("{F54A4A}Ошибка. Не найден файл.{82E28C} Начинаю загрузку png.")
		download_id = downloadUrlToFile('https://i.imgur.com/gPNNH1g.png', getWorkingDirectory().."/MedicalHelper/record.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				print("{82E28C}Загрузка успешно завершена!")
			end
		end)
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/recordMegamix.png") then
		download_id = downloadUrlToFile('https://i.imgur.com/Hv3PIen.png', getWorkingDirectory().."/MedicalHelper/recordMegamix.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRecordMegamix = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/recordMegamix.png")
			end
		end)
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/recordparty.png") then
		download_id = downloadUrlToFile('https://i.imgur.com/JEIc2L1.png', getWorkingDirectory().."/MedicalHelper/recordparty.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRecordParty = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/recordparty.png")
			end
		end)
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/nolabel.png") then
		download_id = downloadUrlToFile('https://ru.apporange.space/static/images/no-cover-150.jpg', getWorkingDirectory().."/MedicalHelper/nolabel.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
				local texture_im = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
				imgRECORD = {texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im}
			end
		end)
	end

	if not doesDirectoryExist(getWorkingDirectory().."/MedicalHelper/картинки/") then
		print("{F54A4A}Ошибка. Нет папки. {82E28C}Создаю папку для картинок...")
		createDirectory(getWorkingDirectory().."/MedicalHelper/картинки/")
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/DANCE.png") then
		download_id = downloadUrlToFile('https://i.imgur.com/F6hxtdC.png', getWorkingDirectory().."/MedicalHelper/картинки/DANCE.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[1] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/DANCE.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/MEGAMIX.png") then
		download_id = downloadUrlToFile('https://imgur.com/lsYixKr.png', getWorkingDirectory().."/MedicalHelper/картинки/MEGAMIX.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[2] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/MEGAMIX.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/PARTY.png") then
		download_id = downloadUrlToFile('https://imgur.com/lEpOpLy.png', getWorkingDirectory().."/MedicalHelper/картинки/PARTY.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[3] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/PARTY.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/PHONK.png") then
		download_id = downloadUrlToFile('https://imgur.com/UWHK1nN.png', getWorkingDirectory().."/MedicalHelper/картинки/PHONK.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[4] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/PHONK.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/GOPFM.png") then
		download_id = downloadUrlToFile('https://imgur.com/GkovIZT.png', getWorkingDirectory().."/MedicalHelper/картинки/GOPFM.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[5] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/GOPFM.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/RUKIVVERH.png") then
		download_id = downloadUrlToFile('https://imgur.com/ZftaAuK.png', getWorkingDirectory().."/MedicalHelper/картинки/RUKIVVERH.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[6] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/RUKIVVERH.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/DUPSTEP.png") then
		download_id = downloadUrlToFile('https://imgur.com/Q8Jed4R.png', getWorkingDirectory().."/MedicalHelper/картинки/DUPSTEP.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[7] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/DUPSTEP.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/BIGHITS.png") then
		download_id = downloadUrlToFile('https://imgur.com/OeGdMu8.png', getWorkingDirectory().."/MedicalHelper/картинки/BIGHITS.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[8] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/BIGHITS.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/ORGANIC.png") then
		download_id = downloadUrlToFile('https://imgur.com/xuOZVCU.png', getWorkingDirectory().."/MedicalHelper/картинки/ORGANIC.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[9] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/ORGANIC.png")
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/картинки/RUSSIANHITS.png") then
		download_id = downloadUrlToFile('https://imgur.com/SnA1FR8.png', getWorkingDirectory().."/MedicalHelper/картинки/RUSSIANHITS.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[10] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/RUSSIANHITS.png")
			end
		end)
	end
end
download_image()
deck = getFolderPath(0)
doc = getFolderPath(5)
dirml = getWorkingDirectory() 
dirGame = getGameDirectory()
scr = thisScript()
font = renderCreateFont("Trebuchet MS", 14, 5)
fontPD = renderCreateFont("Trebuchet MS", 12, 5)
fontH =  renderGetFontDrawHeight(font)
sx, sy = getScreenResolution()

mainWin	= imgui.ImBool(false)
paramWin = imgui.ImBool(false)
actingOutWind = imgui.ImBool(false)
spurBig = imgui.ImBool(false)
sobWin = imgui.ImBool(false)
depWin = imgui.ImBool(false)
updWin = imgui.ImBool(false) 
iconwin	= imgui.ImBool(false)
profbWin = imgui.ImBool(false)
choiceWin	= imgui.ImBool(false)
select_menu = {true, false, false, false, false, false, false, false, false, false}
getposcur = 2
poshovbut = 2
poshovbuttr = {false, false, false, false, false, false, false, false, false, false}
visbut = 0.00

update_available = false
current_version = "3.2.1"
GITHUB_RAW_URL = "https://raw.githubusercontent.com/liror4ech/MHelpers/refs/heads/main/"
VERSION_FILE = "version.txt"
CHANGELOG_FILE = "changelog.txt"
SCRIPT_FILE = "MedicalHelper.lua"
DOWNLOAD_URL = GITHUB_RAW_URL .. SCRIPT_FILE

local trstl1 = { ['ph'] = 'ф', ['Ph'] = 'Ф', ['Ch'] = 'Ч', ['ch'] = 'ч', ['Th'] = 'Т', ['th'] = 'т', ['Sh'] = 'Ш', ['sh'] = 'ш', ['ea'] = 'е', ['Ae'] = 'Э', ['ae'] = 'э', ['size'] = 'сайз', ['Jj'] = 'джей', ['Whi'] = 'ви', ['lack'] = 'лак', ['whi'] = 'ви', ['Ck'] = 'к', ['ck'] = 'к', ['Kh'] = 'Х', ['kh'] = 'х', ['hn'] = 'н', ['Hen'] = 'Хен', ['Zh'] = 'Ж', ['zh'] = 'ж', ['Yu'] = 'Ю', ['yu'] = 'ю', ['Yo'] = 'Ё', ['yo'] = 'ё', ['Cz'] = 'Ц', ['cz'] = 'ц', ['ia'] = 'я', ['Ya'] = 'Я', ['ya'] = 'я', ['ove'] = 'ов', ['ay'] = 'ай', ['rise'] = 'райз', ['oo'] = 'у', ['Oo'] = 'У', ['Ee'] = 'И', ['ee'] = 'и', ['Un'] = 'Ун', ['un'] = 'ун', ['Ci'] = 'Си', ['ci'] = 'си', ['yse'] = 'из', ['cate'] = 'кейт', ['eow'] = 'еу', ['rown'] = 'раун', ['yev'] = 'ев', ['Babe'] = 'Бэйб', ['Jason'] = 'Джейсон', ['liy'] = 'лий', ['ane'] = 'ейн', ['ame'] = 'ейм'}
local trstl = { ['B'] = 'Б', ['Z'] = 'З', ['T'] = 'Т', ['Y'] = 'Ы', ['P'] = 'П', ['J'] = 'Дж', ['X'] = 'Кс', ['G'] = 'Г', ['V'] = 'В', ['H'] = 'Х', ['N'] = 'Н', ['E'] = 'Е', ['I'] = 'И', ['D'] = 'Д', ['O'] = 'О', ['K'] = 'К', ['F'] = 'Ф', ['y`'] = 'й', ['e`'] = 'э', ['A'] = 'А', ['C'] = 'Ц', ['L'] = 'Л', ['M'] = 'М', ['W'] = 'В', ['Q'] = 'К', ['U'] = 'У', ['R'] = 'Р', ['S'] = 'С', ['zm'] = 'зм', ['h'] = 'х', ['q'] = 'к', ['y'] = 'ы', ['a'] = 'а', ['w'] = 'в', ['b'] = 'б', ['v'] = 'в', ['g'] = 'г', ['d'] = 'д', ['e'] = 'е', ['z'] = 'з', ['i'] = 'и', ['j'] = 'дж', ['k'] = 'к', ['l'] = 'л', ['m'] = 'м', ['n'] = 'н', ['o'] = 'о', ['p'] = 'п', ['r'] = 'р', ['s'] = 'с', ['t'] = 'т', ['u'] = 'у', ['f'] = 'ф', ['x'] = 'кс', ['c'] = 'ц', ['``'] = 'ъ', ['`'] = 'ь', ['_'] = ' ' }
local trsliterCMD = { ['q'] = 'й', ['w'] = 'ц', ['e'] = 'у', ['r'] = 'к', ['t'] = 'е', ['y'] = 'н', ['u'] = 'г', ['i'] = 'ш', ['o'] = 'щ', ['p'] = 'з', ['a'] = 'ф', ['s'] = 'ы', ['d'] = 'в', ['f'] = 'а', ['g'] = 'п', ['h'] = 'р', ['j'] = 'о', ['k'] = 'л', ['l'] = 'д', ['z'] = 'я', ['x'] = 'ч', ['c'] = 'с', ['v'] = 'м', ['b'] = 'и', ['n'] = 'т', ['m'] = 'ь', ['/'] = '.' }
local trsliterEng = { ['а'] = 'a', ['б'] = 'b', ['в'] = 'v', ['г'] = 'g', ['д'] = 'd', ['е'] = 'e', ['ё'] = 'e', ['ж'] = 'zh', ['з'] = 'z', ['и'] = 'i', ['й'] = 'i', ['к'] = 'k', ['л'] = 'l', ['м'] = 'm', ['н'] = 'n', ['о'] = 'o', ['п'] = 'p', ['р'] = 'r', ['с'] = 's', ['т'] = 't', ['у'] = 'u', ['ф'] = 'f', ['х'] = 'kh', ['ц'] = 'ts', ['ч'] = 'ch', ['ш'] = 'sh', ['щ'] = 'shch', ['ъ'] = 'ie', ['ы'] = 'y',  ['ь'] = '', ['э'] = 'e', ['ю'] = 'iu', ['я'] = 'ia', ['А'] = 'a', ['Б'] = 'b', ['В'] = 'v', ['Г'] = 'g', ['Д'] = 'd', ['Е'] = 'e', ['Ё'] = 'e', ['Ж'] = 'zh', ['З'] = 'z', ['И'] = 'i', ['Й'] = 'i', ['К'] = 'k',  ['Л'] = 'l', ['М'] = 'm', ['Н'] = 'n', ['О'] = 'o', ['П'] = 'p', ['Р'] = 'r', ['С'] = 's', ['Т'] = 't', ['У'] = 'u', ['Ф'] = 'f', ['Х'] = 'kh', ['Ц'] = 'ts', ['Ч'] = 'ch', ['Ш'] = 'sh', ['Щ'] = 'shch', ['Ъ'] = 'ie', ['Ы'] = 'y', ['Ь'] = '', ['Э'] = 'e', ['Ю'] = 'iu', ['Я'] = 'ia'}

function getPlayerNickName(idplayer)
	if sampGetGamestate() == 3 then
		end_nick = sampGetPlayerNickname(idplayer)
	else
		end_nick = "Nick_Name"
		return end_nick
	end
	return end_nick
end

function trst(name)
if name:match('%a+') then
        for k, v in pairs(trstl1) do
            name = name:gsub(k, v) 
        end
		for k, v in pairs(trstl) do
            name = name:gsub(k, v) 
        end
        return name
    end
 return name
end

setting = {
	nick = "",
	teg = "",
	org = 0,
	sex = 0,
	rank = 0,
	time = false,
	timeDo = false, 
	timeTx = "",
	rac = false,
	racTx = "",
	lec = "",
	mede = {"20000", "40000", "60000", "80000"},
	upmede = {"40000", "60000", "80000", "100000"},
	rec = "",
	narko = "",
	tatu = "",
	ant = "",
	chat1 = false,
	chat2 = false,
	chat3 = false,
	chathud = false,
	arp = false,
	setver = 1,
	imageUp = false,
	imageDis = false,
	theme = 0,
	themAngle = true,
	spawn = false,
	autolec = false,
	prikol = false
}
setdepteg = {
    tegtext_one = u8"[",
    tegtext_two = u8" ",
    tegtext_three = ":",
    tegpref_one = 0,
    tegpref_two = 2,
    prefix = {u8"Глав", u8"Зам-гл", u8"Гл", u8"Вр", u8"Вр", u8"Зам", u8"Нач", u8"Зам", u8"Пом", u8"Глав", u8"Глав", u8"Глав", u8"Глав", u8"Глав", u8"Глав", u8"Глав", u8"Глав", u8"Мед инт", u8"Мед инт", u8"Мед инт", u8"Вр", u8"Вр", u8"Вр", u8"Вр"}
}
buf_nick	= imgui.ImBuffer(256)
buf_teg 	= imgui.ImBuffer(256)
your_tag = imgui.ImBuffer(256)
num_org		= imgui.ImInt(0)
num_sex		= imgui.ImInt(0)
num_dep		= imgui.ImInt(0)
num_dep2		= imgui.ImInt(0)
num_dep3		= imgui.ImInt(0)
num_pref		= imgui.ImInt(0)
num_theme		= imgui.ImInt(0)
num_rank	= imgui.ImInt(0)
chgName = {}
chgDepSetD = {imgui.ImBuffer(128),imgui.ImBuffer(128),imgui.ImBuffer(128)}
chgDepSetTeg = imgui.ImBuffer(128)
chgDepSetPref = imgui.ImBuffer(128)
chgName.inp = imgui.ImBuffer(100)
chgName.org = {u8"Медицинский LS", u8"Медицинский SF", u8"Медицинский LV", u8"Медицинский Jafferson"}
chgName.rank = {u8"Стажёр", u8"Младший врач", u8"Врач", u8"Хирург", u8"Терапевт", u8"Психиатр", u8"Невролог", u8"Зав. отделением", u8"Зам. гл. врача", u8"Глав. врач", u8"Министр здравоохранения"}
list_cmd = {u8"mh", u8"r", u8"rb", u8"mb", u8"hl", u8"post", u8"mc", u8"narko", u8"recep", u8"osm", u8"dep", u8"sob", u8"tatu", u8"vig", u8"unvig", u8"muteorg", u8"unmuteorg", u8"gr", u8"inv", u8"unv", u8"time", u8"exp", u8"vac", u8"info", u8"za", u8"zd", u8"ant", u8"strah", u8"cur", u8"hall", u8"hilka", u8"shpora", u8"hme", u8"show", u8"cam"}
prefix_end = {"","","","",""}
positbut = 0
positbut2 = 0
positbut3 = 0
prikol = imgui.ImBool(false)
activebutanim = {false, false, 1}
activebutanim2 = {false, false, 1}
activebutanim3 = {false, false, 1}
local ReminderWin = imgui.ImBool(false)
local reminder = {}
local reminder_buf = {
	timer = {year = imgui.ImInt(0), mon = imgui.ImInt(0), day = imgui.ImInt(0), hour = imgui.ImFloat(1.0), min = imgui.ImFloat(1.0)},
	text = imgui.ImBuffer(1024),
	repeats = {imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false)},
	sound = imgui.ImBool(true)
}

local list_org_BL = {"Медицинский LS", "Медицинский SF", "Медицинский LV", "Медицинский Jafferson"} 
local list_org = {u8"Медицинский LS", u8"Медицинский SF", u8"Медицинский LV", u8"Медицинский Jafferson"}
local list_org_en = {"Los-Santos Medical Center","San-Fierro Medical Center","Las-Venturas Medical Center","Jafferson Medical Center"}
local list_sex = {fa.ICON_MALE .. u8" Мужской", fa.ICON_FEMALE .. u8" Женский"} 
local list_rank = {u8"Стажёр", u8"Младший врач", u8"Врач", u8"Хирург", u8"Терапевт", u8"Психиатр", u8"Невролог", u8"Зав. отделением", u8"Зам. гл. врача", u8"Глав. врач", u8"Министр здравоохранения"}
local list_theme = {u8"Классическая", u8"Тёмная", u8"Светлая", u8"Зелёная", u8"Синяя", u8"׸железо-синяя", u8"Красная", u8"Фиолетовая"}
local list_dep_pref_one = { u8"Гл. врач \nбез тега", u8"Гл. врач \nс тегом", u8"Зам. гл. \nбез тега", u8"Зам. гл. \nс тегом", u8"Без тега"}
local list_dep_pref_two = { u8"Гл. врач \nбез тега", u8"Гл. врач \nс тегом", u8"Зам. гл. \nбез тега", u8"Зам. гл. \nс тегом", u8"Без тега" }
local cb_chat1	= imgui.ImBool(false)
local cb_chat2	= imgui.ImBool(false)
local cb_chat3	= imgui.ImBool(false)
local cb_hud		= imgui.ImBool(false)
local hudPing = false
local cb_hudTime	= imgui.ImBool(false)
local theme_Angle = imgui.ImBool(true)
local accept_spawn = imgui.ImBool(false)
local accept_autolec = imgui.ImBool(false)
local healme = false
local deadgov = false
local searchtext = imgui.ImBuffer(256)
local textes
local select_menu_money = true
local cb_time		= imgui.ImBool(false)
local cb_timeDo	= imgui.ImBool(false)
local cb_rac		= imgui.ImBool(false)
local buf_time	= imgui.ImBuffer(256)
local buf_rac		= imgui.ImBuffer(256)
local buf_lec		= imgui.ImBuffer(10);
local buf_mede = {imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10)}
local buf_upmede = {imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10)}
local buf_rec		= imgui.ImBuffer(10);
local buf_narko	= imgui.ImBuffer(10);
local buf_tatu	= imgui.ImBuffer(10);
local buf_ant	= imgui.ImBuffer(10);
buf_mede[1].v = "20000"
buf_mede[2].v = "40000"
buf_mede[3].v = "60000"
buf_mede[4].v = "80000"
buf_upmede[1].v = "40000"
buf_upmede[2].v = "60000"
buf_upmede[3].v = "80000"
buf_upmede[4].v = "100000"
local lectime = false
local statusvac = false
local errorspawn = false
local session_clean = imgui.ImInt(0)
local session_afk = imgui.ImInt(0)
local session_all = imgui.ImInt(0)
local spur = {
text = imgui.ImBuffer(51200),
name = imgui.ImBuffer(256),
list = {},
select_spur = -1,
edit = false
}

function translatizator(name)
	if name:match('%a+') then
        for k, v in pairs(trsliterCMD) do
            name = name:gsub(k, v) 
        end
        return name
    end
 return name
end
function translatizatorEng(name)
	if name:match('%A+') then
        for k, v in pairs(trsliterEng) do
            name = name:gsub(k, v)
        end
        return name
    end
 return name
end
local online_stat = {
	clean = {0, 0, 0, 0, 0, 0, 0},
	afk = {0, 0, 0, 0, 0, 0, 0},
	all = {0, 0, 0, 0, 0, 0, 0},
	total_week = 0,
	total_all = 0,
	date_num = {0, 0},
	date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
	date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
	date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""}
}

function round(num, step)
  return math.ceil(num / step) * step
end

local sw, sh = getScreenResolution()
local membScr = {
	func = false,
	pos = {x = round(sw - 30, 1), y = round(sh / 3, 1)},
	forma = true,
	numrank = true,
	id = true,
	afk = true,
	dialog = false,
	vergor = false,
	font = {
		size = 12.0,
		flag = 5.0,
		distance = 21.0,
		visible = 200
	},
	color = {
    	col_title 	= 0xFFFFAAAA,
    	col_default = 0xFFFFFFFF,
    	col_no_work = 0xFFAA3333
	}
}
local await = {
	members = false,
	next_page = {
		bool = false,
		i = 0
	}
}
local members = {}
local org = {
	name = 'Организация',
	online = 0,
	afk = 0
}
local myforma = false
local dontShowMeMembers = false
local lastDialogWasActive = 0
local script_cursor = false

local PlayerSet = {}
function PlayerSet.name()
	if buf_nick.v ~= "" then
		return buf_nick.v
	else
		return u8"Не указано"
	end
end
function PlayerSet.org()
	return chgName.org[num_org.v+1]
end
function PlayerSet.rank()
	return chgName.rank[num_rank.v+1]
end
function PlayerSet.sex()
	return list_sex[num_sex.v+1]
end
function PlayerSet.dep()
	return list_dep_pref_one[num_dep.v+1]
end
function PlayerSet.depTwo()
	return setdepteg.prefix[num_org.v+14]
end
function PlayerSet.theme()
	return list_theme[num_theme.v+1]
end
function DepTxtEnd(textbox)
	if setdepteg.tegtext_one ~= "" then
		spacetext_one = setdepteg.tegtext_one.." "
	else
		spacetext_one = ""
	end
	if setdepteg.tegtext_two ~= "" then
		if setdepteg.tegpref_two ~= 4 then
			spacetext_two = setdepteg.tegtext_two
		else
			spacetext_two = setdepteg.tegtext_two.." "
		end
	elseif setdepteg.tegpref_one ~= 4 and setdepteg.tegpref_two ~= 4 then
		spacetext_two = " "
	elseif setdepteg.tegpref_one < 5 or setdepteg.tegpref_two < 5 then
		spacetext_two = ""
	end
	if setdepteg.tegtext_three ~= "" then
		spacetext_three = setdepteg.tegtext_three.." "
	elseif setdepteg.tegpref_two < 4 then
		spacetext_three = " "
	else
		spacetext_three = ""
	end
	if setdepteg.tegtext_two == "" and setdepteg.tegtext_three == "" and setdepteg.tegpref_one < 4 and setdepteg.tegpref_two == 4 then
		spacetext_three = " "
	end
	if select_depart == 2 then
		if setdepteg.tegpref_one < 2 then
			if your_tag.v == "" or your_tag.v == nil then
				if setdepteg.tegpref_one == 0 then
					oneteg = "[".. setdepteg.prefix[num_dep3.v + 1] .."]"
				else
					oneteg = setdepteg.prefix[num_dep3.v + 1]
				end
			else
				if setdepteg.tegpref_one == 0 then
					oneteg = "[".. your_tag.v .."]"
				else
					oneteg = your_tag.v
				end
			end
		elseif setdepteg.tegpref_one == 4 then
			oneteg = u8""
		elseif setdepteg.tegpref_one ~= 4 then
			if setdepteg.tegpref_one == 2 then
				if num_rank.v == 10 then
					oneteg = "[".. setdepteg.prefix[23] .."]"
				else
					oneteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
				end
			else
				if num_rank.v == 10 then
					oneteg = setdepteg.prefix[23]
				else
					oneteg = setdepteg.prefix[num_org.v + 14]
				end
			end
		end
		if setdepteg.tegpref_two < 2 then
			if your_tag.v == "" or your_tag.v == nil then
				if setdepteg.tegpref_two == 0 then
					twoteg = "[".. setdepteg.prefix[num_dep3.v + 1] .."]"
				else
					twoteg = setdepteg.prefix[num_dep3.v + 1]
				end
			else
				if setdepteg.tegpref_two == 0 then
					twoteg = "[".. your_tag.v .."]"
				else
					twoteg = your_tag.v
				end
			end
		elseif setdepteg.tegpref_two == 4 then
			twoteg = u8""
		elseif setdepteg.tegpref_two ~= 4 then
			if setdepteg.tegpref_two == 2 then
				if num_rank.v == 10 then
					twoteg = "[".. setdepteg.prefix[23] .."]"
				else
					twoteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
				end
			else
				if num_rank.v == 10 then
					twoteg = setdepteg.prefix[23]
				else
					twoteg = setdepteg.prefix[num_org.v + 14]
				end
			end
		end
	else
		if setdepteg.tegpref_one < 2 then
			if setdepteg.tegpref_one == 0 then
				oneteg = "[".. setdepteg.prefix[1] .."]"
			else
				oneteg = setdepteg.prefix[1]
			end
		elseif setdepteg.tegpref_one == 4 then
			oneteg = u8""
		elseif setdepteg.tegpref_one ~= 4 then
			if setdepteg.tegpref_one == 2 then
				oneteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			else
				oneteg = setdepteg.prefix[num_org.v + 14]
			end
		end
		if setdepteg.tegpref_two < 2 then
			if setdepteg.tegpref_two == 0 then
				twoteg = "[".. setdepteg.prefix[1] .."]"
			else
				twoteg = setdepteg.prefix[1]
			end
		elseif setdepteg.tegpref_two == 4 then
			twoteg = u8""
		elseif setdepteg.tegpref_two ~= 4 then
			if setdepteg.tegpref_two == 2 then
				twoteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			else
				twoteg = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	textbox = spacetext_one.. oneteg ..spacetext_two.. twoteg ..spacetext_three
	return textbox
end
function DepTxtEndSetting(textbox)
	if chgDepSetD[1].v ~= "" then
		spacetext_oneset = chgDepSetD[1].v.." "
	else
		spacetext_oneset = ""
	end
	if chgDepSetD[2].v ~= "" then
		if num_dep2.v ~= 4 then
			spacetext_twoset = chgDepSetD[2].v
		else
			spacetext_twoset = chgDepSetD[2].v.." "
		end
	elseif num_dep.v ~= 4 and num_dep2.v ~= 4 then
		spacetext_twoset = " "
	elseif num_dep.v < 5 or num_dep2.v < 5 then
		spacetext_twoset = ""
	end
	if chgDepSetD[3].v ~= "" then
		spacetext_threeset = chgDepSetD[3].v.." "
	elseif num_dep2.v < 4 then
		spacetext_threeset = " "
	else
		spacetext_threeset = ""
	end
	if chgDepSetD[2].v == "" and chgDepSetD[3].v == "" and num_dep.v < 4 and num_dep2.v == 4 then
		spacetext_threeset = " "
	end
	if num_dep.v < 2 then
		if num_dep.v == 0 then
			onetegset = "[".. setdepteg.prefix[9] .."]"
		else
			onetegset = setdepteg.prefix[9]
		end
	elseif num_dep.v == 4 then
		onetegset = u8""
	elseif num_dep.v ~= 4 then
		if num_dep.v == 2 then
			if num_rank.v == 10 then
				onetegset = "[".. setdepteg.prefix[23] .."]"
			else
				onetegset = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			end
		else
			if num_rank.v == 10 then
				onetegset = setdepteg.prefix[23]
			else
				onetegset = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	if num_dep2.v < 2 then
		if num_dep2.v == 0 then
			twotegset = "[".. setdepteg.prefix[9] .."]"
		else
			twotegset = setdepteg.prefix[9]
		end
	elseif num_dep2.v == 4 then
		twotegset = u8""
	elseif num_dep2.v ~= 4 then
		if num_dep2.v == 2 then
			if num_rank.v == 10 then
				twotegset = "[".. setdepteg.prefix[23] .."]"
			else
				twotegset = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			end
		else
			if num_rank.v == 10 then
				twotegset = setdepteg.prefix[23]
			else
				twotegset = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	textbox = spacetext_oneset.. onetegset ..spacetext_twoset.. twotegset ..spacetext_threeset
	return textbox
end

local selected_cmd = 1
local currentKey	= {"",{}}
local cb_RBUT		= imgui.ImBool(false)
local cb_x1		= imgui.ImBool(false)
local cb_x2		= imgui.ImBool(false)
local isHotKeyDefined = false
local p_open = false
local helpd = {}
helpd.exp = imgui.ImBuffer(256)
binder = {
	list = {},
	select_bind,
	edit = false,
	sleep = imgui.ImFloat(0.5),
	name = imgui.ImBuffer(256),
	cmd = imgui.ImBuffer(256),
	text = imgui.ImBuffer(51200),
	key = {}
}
helpd.exp.v = u8[[{dialog}
[name]=Тест диалога
[1]=Первая опция
Вариант 1
Вариант 2
[2]=Вторая опция 
Вариант 1
Вариант 2
{dialogEnd}
]]
helpd.key = {
	{k = "MBUTTON", n = 'Средняя кнопка'},
	{k = "XBUTTON1", n = 'Доп. кнопка мыши 1'},
	{k = "XBUTTON2", n = 'Доп. кнопка мыши 2'},
	{k = "BACK", n = 'Backspace'},
	{k = "SHIFT", n = 'Shift'},
	{k = "CONTROL", n = 'Ctrl'},
	{k = "PAUSE", n = 'Pause'},
	{k = "CAPITAL", n = 'Caps Lock'},
	{k = "SPACE", n = 'Space'},
	{k = "PRIOR", n = 'Page Up'},
	{k = "NEXT", n = 'Page Down'},
	{k = "END", n = 'End'},
	{k = "HOME", n = 'Home'},
	{k = "LEFT", n = 'Стрелка влево'},
	{k = "UP", n = 'Стрелка вверх'},
	{k = "RIGHT", n = 'Стрелка вправо'},
	{k = "DOWN", n = 'Стрелка вниз'},
	{k = "SNAPSHOT", n = 'Print Screen'},
	{k = "INSERT", n = 'Insert'},
	{k = "DELETE", n = 'Delete'},
	{k = "0", n = '0'},
	{k = "1", n = '1'},
	{k = "2", n = '2'},
	{k = "3", n = '3'},
	{k = "4", n = '4'},
	{k = "5", n = '5'},
	{k = "6", n = '6'},
	{k = "7", n = '7'},
	{k = "8", n = '8'},
	{k = "9", n = '9'},
	{k = "A", n = 'A'},
	{k = "B", n = 'B'},
	{k = "C", n = 'C'},
	{k = "D", n = 'D'},
	{k = "E", n = 'E'},
	{k = "F", n = 'F'},
	{k = "G", n = 'G'},
	{k = "H", n = 'H'},
	{k = "I", n = 'I'},
	{k = "J", n = 'J'},
	{k = "K", n = 'K'},
	{k = "L", n = 'L'},
	{k = "M", n = 'M'},
	{k = "N", n = 'N'},
	{k = "O", n = 'O'},
	{k = "P", n = 'P'},
	{k = "Q", n = 'Q'},
	{k = "R", n = 'R'},
	{k = "S", n = 'S'},
	{k = "T", n = 'T'},
	{k = "U", n = 'U'},
	{k = "V", n = 'V'},
	{k = "W", n = 'W'},
	{k = "X", n = 'X'},
	{k = "Y", n = 'Y'},
	{k = "Z", n = 'Z'},
	{k = "NUMPAD0", n = 'Numpad 0'},
	{k = "NUMPAD1", n = 'Numpad 1'},
	{k = "NUMPAD2", n = 'Numpad 2'},
	{k = "NUMPAD3", n = 'Numpad 3'},
	{k = "NUMPAD4", n = 'Numpad 4'},
	{k = "NUMPAD5", n = 'Numpad 5'},
	{k = "NUMPAD6", n = 'Numpad 6'},
	{k = "NUMPAD7", n = 'Numpad 7'},
	{k = "NUMPAD8", n = 'Numpad 8'},
	{k = "NUMPAD9", n = 'Numpad 9'},
	{k = "MULTIPLY", n = 'Numpad *'},
	{k = "ADD", n = 'Numpad +'},
	{k = "SEPARATOR", n = 'Separator'},
	{k = "SUBTRACT", n = 'Numpad -'},
	{k = "DECIMAL", n = 'Numpad .'},
	{k = "DIVIDE", n = 'Numpad /'},
	{k = "F1", n = 'F1'},
	{k = "F2", n = 'F2'},
	{k = "F3", n = 'F3'},
	{k = "F4", n = 'F4'},
	{k = "F5", n = 'F5'},
	{k = "F6", n = 'F6'},
	{k = "F7", n = 'F7'},
	{k = "F8", n = 'F8'},
	{k = "F9", n = 'F9'},
	{k = "F10", n = 'F10'},
	{k = "F11", n = 'F11'},
	{k = "F12", n = 'F12'},
	{k = "F13", n = 'F13'},
	{k = "F14", n = 'F14'},
	{k = "F15", n = 'F15'},
	{k = "F16", n = 'F16'},
	{k = "F17", n = 'F17'},
	{k = "F18", n = 'F18'},
	{k = "F19", n = 'F19'},
	{k = "F20", n = 'F20'},
	{k = "F21", n = 'F21'},
	{k = "F22", n = 'F22'},
	{k = "F23", n = 'F23'},
	{k = "F24", n = 'F24'},
	{k = "LSHIFT", n = 'Левый Shift'},
	{k = "RSHIFT", n = 'Правый Shift'},
	{k = "LCONTROL", n = 'Левый Ctrl'},
	{k = "RCONTROL", n = 'Правый Ctrl'},
	{k = "LMENU", n = 'Левый Alt'},
	{k = "RMENU", n = 'Правый Alt'},
	{k = "OEM_1", n = '; :'},
	{k = "OEM_PLUS", n = '= +'},
	{k = "OEM_MINUS", n = '- _'},
	{k = "OEM_COMMA", n = ', <'},
	{k = "OEM_PERIOD", n = '. >'},
	{k = "OEM_2", n = '/ ?'},
	{k = "OEM_4", n = ' { '},
	{k = "OEM_6", n = ' } '},
	{k = "OEM_5", n = '\\ |'},
	{k = "OEM_8", n = '! Ё'},
	{k = "OEM_102", n = '> <'}
}

local vactimer = {59, 1}
local vaccine_two = false
local vaccine_id

local dep = {
	list = {"nil", "Гл. врач. отделения", "nil", "nil", "Заместитель", "[Глав] - гл. врач", "/gov - госпиталь"},
	sel_all = {u8"Гл. врач", u8"Заместитель", u8"Зав. отделением", u8"Ст. врач", u8"Мед. брат", u8"Врач LS", u8"Врач SF", u8"Вр", u8"Вр", u8"Ст. медсестра", u8"Медсестра LS", u8"Медсестра SF", u8"Медсестра LV", u8"Санитар LS", u8"Санитар SF", u8"Санитар LV", u8"Санитар Jafferson", u8"Гл LS", u8"Гл SF", u8"Гл LV", u8"Ст. медсестра", u8"Ст. медсестра", u8"Ст. медсестра", u8"Ст. медсестра"},
	sel_chp = { u8"Гл. врач", u8"Заместитель", u8"Зав. отделением", u8"Ст. врач", u8"Мед. брат", u8"Врач LS", u8"Врач SF", u8"Вр", u8"Вр", u8"Ст. медсестра", u8"Медсестра LS", u8"Медсестра SF", u8"Медсестра LV", u8"Санитар LS", u8"Санитар SF", u8"Санитар LV", u8"Санитар Jafferson", u8"Гл LS", u8"Гл SF", u8"Гл LV", u8"Ст. медсестра", u8"Ст. медсестра", u8"Ст. медсестра", u8"Ст. медсестра"},
	sel_tsr = {u8"Врач LS", u8"Старший врач"},
	sel_mzmomu = {u8"Врач LS", u8"Вр", u8"Врач SF", u8"Врач LV", u8"Врач LS", u8"Врач LS", u8"Ст. медсестра", u8"Вр", u8"Старший врач", u8"Старший врач"},
	sel = imgui.ImInt(0),
	select_dep = {0, 0},
	input = imgui.ImBuffer(256),
	bool = {false, false, false, false, false, false},
	time = {0,0}, 
	newsN = imgui.ImInt(0),
	news = {},
	dlog = {}
}
prefixDefolt = {u8"Гл.", u8"Зам.", u8"Зав.", u8"Ст.", u8"Мед.", u8"Вр.", u8"Вр.", u8"Вр.", u8"Вр.", u8"Ст. мед.", u8"Мед.", u8"Мед.", u8"Мед.", u8"Санитар", u8"Санитар", u8"Санитар", u8"Санитар", u8"Гл.", u8"Гл.", u8"Гл.", u8"Ст. мед.", u8"Ст. мед.", u8"Ст. мед.", u8"Ст. мед."}
trtxt = {}
trtxt = {imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000)}
local buf_mcedit = imgui.ImBuffer(51200) 
local error_mce = ""

local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
local textFont = renderCreateFont("Trebuchet MS", 12, FCR_BORDER + FCR_BOLD)
local fontPing = renderCreateFont("Trebuchet MS", 10, 5)
local pingLog = {}
local musicHUD = imgui.ImBool(false)

lua_thread.create(function()
	while true do
		repeat wait(100) until isSampAvailable()
		repeat wait(100) until sampIsLocalPlayerSpawned()
		wait(1500)
		if sampIsLocalPlayerSpawned() then
			local ping = sampGetPlayerPing(myid)
			table.insert(pingLog, ping)
			if #pingLog == 41 then table.remove(pingLog, 1) end
		end
	end
end)

local week = {"Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"}
local month = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"}
editKey = false
keysList = {}
arep = false
newversion = ""
updinfo = ""
needSave = false
urlupd = ""
vacplayer = {"Error_nickname", "2"}
local BlockKeys = {{vkeys.VK_T}, {vkeys.VK_F6}, {vkeys.VK_F8}, {vkeys.VK_RETURN}, {vkeys.VK_OEM_3}, {vkeys.VK_LWIN}, {vkeys.VK_RWIN}}

rkeys.isBlockedHotKey = function(keys)
	local bool, hkId = false, -1
	for k, v in pairs(BlockKeys) do
	   if rkeys.isHotKeyHotKey(keys, v) then
		  bool = true
		  hkId = k
		  break
	   end
	end
	return bool, hkId
end

function rkeys.isHotKeyExist(keys)
local bool = false
	for i,v in ipairs(keysList) do
		if table.concat(v,"+") == table.concat(keys, "+") then
			if #keys ~= 0 then
				bool = true
				break
			end
		end
	end
	return bool
end

function unRegisterHotKey(keys)
	for i,v in ipairs(keysList) do
		if v == keys then
			keysList[i] = nil
			break
		end
	end
	local listRes = {}
	for i,v in ipairs(keysList) do
		if #v > 0 then
			listRes[#listRes+1] = v
		end
	end
	keysList = listRes
end

function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str
end

local stream_music
local site_link = 'ru.apporange.space'
local selectis = 0
local menu_play_track = {false, false, false}
local status_track_pl = "STOP"
local player_HUD = imgui.ImBool(true)
local volume_music = imgui.ImFloat(1.0)
local buf_find_music = imgui.ImBuffer(256)
local repeatmusic = imgui.ImBool(false)
local trackplaysave = false
local sel_menu_set = 1
local select_music = 0
local select_menu_music = 1
local timetr = {0, 0}
local track_time_hc = 0
local url_track_pack
local anim_hud_tr = {1, 6, 3}
local active_anim_hud = {true, false, true}
local sectime_track = imgui.ImFloat(1.0)
local Y_rewind = 5
local record_text_name = { 'Record Dance', 'Megamix', 'Party 24/7', 'Phonk', 'GOP FM', 'Руки Вверх', 'Dubstep', 'Big Hits', 'Organic', 'Russian Hits'}
local tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}
local save_tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}

function rewind_song(time_position)
	if status_track_pl ~= "STOP" and not menu_play_track[3] and get_status_potok_song() ~= 0 then
		local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
		length = tostring(length)
		length = length:gsub("(%D+)", "")
		length = tonumber(length)
		local poslt = ((length/track_time_hc) * time_position) - 100
		bass.BASS_ChannelSetPosition(stream_music, poslt, BASS_POS_BYTE)
		local time_song = 0
		time_song = time_song_position(track_time_hc)
		time_song = round(time_song, 1)
		timetr[1] = time_song % 60
		timetr[2] = math.floor(time_song / 60)
	end
end

function time_song_position(song_length)
	song_length = tonumber(song_length)
	local posByte = bass.BASS_ChannelGetPosition(stream_music, BASS_POS_BYTE)
	posByte = tostring(posByte)
	posByte = posByte:gsub("(%D+)", "")
	posByte = tonumber(posByte)
	local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
	length = tostring(length)
	length = length:gsub("(%D+)", "")
	length = tonumber(length)
	local postrack = posByte / (length / song_length)
	return postrack
end

function get_status_potok_song()
	local status_potok
	if stream_music ~= nil then
		status_potok = bass.BASS_ChannelIsActive(stream_music)
		status_potok = tonumber(status_potok)
	else
		status_potok = 0
	end
	return status_potok
end

function get_track_length()
	local len_song = 0
	if menu_play_track[1] or menu_play_track[2] then
		local min_tr = 0
		local sec_tr = 0
		if menu_play_track[1] then
			min_tr = tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = tracks.time[selectis]:gsub('(.+):', '')
		else
			min_tr = save_tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = save_tracks.time[selectis]:gsub('(.+):', '')
		end
		min_tr = tonumber(min_tr)
		sec_tr = tonumber(sec_tr)
		len_song = (min_tr * 60) + sec_tr
	end
	return len_song
end

function play_song(url_track, loop_track)
	if imgLabel then
    imgui.DestroyTexture(imgLabel)
    imgLabel = nil
	end
	imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
	timetr = {0, 0}
	track_time_hc = 0
	status_track_pl = "PLAY"
	url_track_pack = url_track
	if menu_play_track[1] or menu_play_track[2] then
		select_music = 0
		if menu_play_track[1] then
			local tri = tracks.time[selectis]:gsub(":(.+)$", "")
			local tri2 = tracks.time[selectis]:gsub("^(.+):", "")
			timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		else
			local tri = save_tracks.time[selectis]:gsub(":(.+)$", "")
			local tri2 = save_tracks.time[selectis]:gsub("^(.+):", "")
			timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		end
		track_time_hc = get_track_length()
	end
	if get_status_potok_song() ~= 0 then
		bass.BASS_ChannelStop(stream_music)
	end
	stream_music = bass.BASS_StreamCreateURL(url_track, 0, BASS_STREAM_AUTOFREE, nil, nil)
	if loop_track ~= true then
		bass.BASS_ChannelPlay(stream_music, false)
	elseif loop_track == true then
		bass.BASS_ChannelPlay(stream_music, BASS_SAMPLE_LOOP)
	end
	bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_music.v)
	if menu_play_track[1] then
		download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				statusimage = selectis
				imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
			end
		end)
	elseif menu_play_track[2] then
		download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				statusimage = selectis
				imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
			end
		end)
	end
end

function action_song(action_music)
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		if action_music == "PLAY" then
			status_track_pl = 'PLAY'
			bass.BASS_ChannelPlay(stream_music, false)
		elseif action_music == "PAUSE" then
			status_track_pl = 'PAUSE'
			bass.BASS_ChannelPause(stream_music)
		elseif action_music == "STOP" then
			selectis = 0
			select_music = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
			bass.BASS_ChannelStop(stream_music)
		end
	end
end

function volume_song(volume_music)
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_music)
	end
end

function find_track_link(search_text)
	asyncHttpRequest('GET', 'https://'..site_link..'/search?q='..urlencode(u8(u8:decode(search_text))), nil,
		function(response)
			for link in string.gmatch(u8:decode(response.text), 'по вашему запросу ничего не найдено') do
    			tracks.link[1] = 'error404'
    			tracks.artist[1] = 'Не найдено'
			end
			for link in string.gmatch(u8:decode(response.text), 'href="(.-)" class=') do
				if link:find('https://'..site_link..'/get/music/') then
					track = link:match('(.+).mp3')
					tracks.link[#tracks.link + 1] = track..'.mp3'
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_title"%>(.-)%</div') do
				if link:find('(.+)') then
					nametrack = link:match('(.+)')
					nametrack = nametrack:gsub('^%s+', '')
					tracks.name[#tracks.name + 1] = nametrack:gsub('%s+$', '')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_desc"%>(.-)%</div') do
				if link:find('(.+)') then
					tracks.artist[#tracks.artist + 1] = link:match('(.+)')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_fulltime"%>(.-)%</div') do
				if link:find('(.+)') then
					tracks.time[#tracks.time + 1] = link:match('(.+)')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_img" style="background%-image: url%(\'(.-)\'%)%;"%>%</div%>') do
				if link:find('(.+)') then
					tracks.image[#tracks.image + 1] = 'https://'..site_link..link:match('(.+)')
				end
			end
		end,
		function(err)
		print(err)
	end)
end


local acting_buf = {}
local arg_options = {u8"Числовой аргумент", u8"Текстовый аргумент"}
local type_options = {u8"Отправить в чат", u8"Нажать клавишу Enter", u8"Подменить диалог", u8"Отправить в рацию", u8"Выполнить команду"}
local acting = {
	[5] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do Осматриваю тело пациента на наличие повреждений."},
			{0, u8"/me доста{sex:|ю} аптечку и начина{sex:|ю} оказывать первую помощь пациен{sex:|ту}."},
			{0, u8"/me начинаю лечение на месте, чтобы стабилизироват{sex:|ь} состояние пациента"},
			{0, u8"/heal {arg1} {pricelec}"},
			{0, u8"/todo Лечу, выписываю рецепт, надеюсь на лучшее!*Ввожу лекарство"}
		},
		sec = 2.0
	},
	[7] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = true,
		var = {u8"0", u8"0", u8"0", u8"0", u8"0", u8"0", u8"0"},
		chatopen = false,
		typeAct = {
			{0, u8"Как вы себя чувствуете после полученных травм?"},
			{0, u8"Мне необходимо сверить ваши данные с картой, чтобы убедиться."},
			{0, u8'/b Ты можешь показать /showpass {myID}'},
			{1, u8""},
			{0, u8"/me бер{sex:|у} ручку и заполня{sex:|ю} бланк первичного осмотр{sex:|а}"},
			{2, {u8"Обычная мед. карта", u8"Расширенная мед. карта"}},
			{0, u8"{dialog1}Выберите тип мед. карты для дальнейшей работы."},
			{0, u8"{dialog1}7 дней: {med7}$. 14 дней: {med14}$"},
			{0, u8"{dialog1}30 дней: {med30}$. 60 дней: {med60}$"},
			{4, 0, u8"{med7}"},
			{4, 1, u8"{med14}"},
			{4, 2, u8"{med30}"},
			{4, 3, u8"{med60}"},
			{0, u8"{dialog2}Выберите тип расширенной мед. карты для дальнейшей работы."},
			{0, u8"{dialog2}7 дней: {medup7}$. 14 дней: {medup14}$"},
			{0, u8"{dialog2}30 дней: {medup30}$. 60 дней: {medup60}$"},
			{4, 0, u8"{medup7}"},
			{4, 1, u8"{medup14}"},
			{4, 2, u8"{medup30}"},
			{4, 3, u8"{medup60}"},
			{0, u8"/n Обращаю внимание на общее состояние пациента, чтобы выявить проблемы."},
			{0, u8"У вас есть какие-либо хронические заболевания?"},
			{2, {u8"7 дней", u8"14 дней", u8"30 дней", u8"60 дней"}},
			{0, u8"{dialog1}"},
			{4, 4, u8"{var1}"},
			{4, 5, u8"0"},
			{0, u8"{dialog2}"},
			{4, 4, u8"{var2}"},
			{4, 5, u8"1"},
			{0, u8"{dialog3}"},
			{4, 4, u8"{var3}"},
			{4, 5, u8"2"},
			{0, u8"{dialog4}"},
			{4, 4, u8"{var4}"},
			{4, 5, u8"3"},
			{0, u8"Хорошо, теперь я заполню карту, подождите немного."},
			{0, u8"Вы не против, если я задам вам несколько вопросов?"},
			{1, u8""},
			{0, u8"Какие-либо ещё симптомы?"},
			{2, {u8"Головная боль", u8"Тошнота и рвота", u8"Повышенная температура", u8"Не беспокоит"}},
			{0, u8"{dialog1}"},
			{4, 6, u8"3"},
			{0, u8"{dialog2}"},
			{4, 6, u8"2"},
			{0, u8"{dialog3}"},
			{4, 6, u8"1"},
			{0, u8"{dialog4}"},
			{4, 6, u8"0"},
			{0, u8"/me вношу данные в мед. карту и завершаю осмотр, выдаю пациенту справку"},
			{0, u8"/do Врач передаёт карту на подпись."},
			{0, u8"/me беру карту в руки, чтобы заполнить оставшиеся поля и поставить печать"},
			{0, u8"/do Процедура успешно завершена, карта готова."},
			{0, u8"/me вношу заключительные данные в электронную базу"},
			{0, u8"/medcard {arg1} {var7} {var6} {var5}"}
		},
		sec = 2.0
	},
	[8] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Вам необходимо пройти обследование у нарколога."},
			{0, u8"Стоимость процедуры составляет {pricenarko}$"},
			{0, u8'Пожалуйста, заполните анкету, указав "Наркотики". После этого вы сможете пройти тестирование.'},
			{0, u8"Вы согласны? Если да, то подпишите договор и оплатите."},
			{1, u8""},
			{0, u8"/do На столе лежат несколько бланков с анализами."},
			{0, u8"/me беру в руки шприц для забора крови, чтобы провери{sex:|ть} пациента"},
			{0, u8"/todo Провожу экспресс-тест на наркотики*Ввожу препарат. Беру образец мочи"},
			{0, u8"/me бер{sex:|у} пробирку, чтобы взят{sex:|ь} кровь на анализ"},
			{0, u8"/me записыва{sex:|ю} результаты, визуально оценива{sex:|ю} состояние"},
			{0, u8"/do Результаты анализов готовы к интерпретации."},
			{0, u8"/me бер{sex:|у} препарат и ввож{sex:|у} пациенту антидот"},
			{0, u8"/healbad {arg1}"},
			{0, u8"/todo Фух, я спас пациента от передозировки!*Ввожу антидот и ставлю капельницу"}
		},
		sec = 2.0
	},
	[9] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = true,
		var = {u8"1"},
		chatopen = false,
		typeAct = {
			{0, u8"Выписываю вам рецепт на основе ваших жалоб."},
			{0, u8"/n В течение 5 дней соблюдайте постельный режим."},
			{0, u8"Стоимость рецепта составляет {pricerecept}$"},
			{0, u8"Вы согласны? Если да, то оплатите на ресепшене?"},
			{3, u8"Пожалуйста, подождите, я подготовлю бланк рецепта."},
			{2, {u8"1 таблетка", u8"2 таблетки", u8"3 таблетки", u8"4 таблетки", u8"5 уколов"}},
			{0, u8"{dialog1}"},
			{4, 0, u8"1"},
			{0, u8"{dialog2}"},
			{4, 0, u8"2"},
			{0, u8"{dialog3}"},
			{4, 0, u8"3"},
			{0, u8"{dialog4}"},
			{4, 0, u8"4"},
			{0, u8"{dialog5}"},
			{4, 0, u8"5"},
			{0, u8"/do На столе лежит готовый бланк с подписью врача."},
			{0, u8"/me беру бланк и заполняю необходимые поля, затем передаю пациенту"},
			{0, u8"/do Бланк рецепта имеет все необходимые печати."},
			{0, u8"/todo Рецепт готов, передаю пациенту!*Бланк с рецептом и рекомендациями"},
			{0, u8"/recept {arg1} {var1}"}
		},
		sec = 2.0
	},
	[10] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Здравствуйте, меня зовут доктор Смит. Я ваш лечащий врач."},
			{0, u8"Расскажите, что именно вас беспокоит."},
			{1, u8""},
			{0, u8"/me смотр{sex:|ю} на пациента и слуша{sex:|ю} его жалобы"},
			{0, u8"/do Осмотр начинается с измерения давления и пульса."},
			{0, u8"Итак, давайте я задам вам несколько вопросов о вашем состоянии."},
			{0, u8"Вы когда-нибудь ранее проходили подобное обследование?"},
			{1, u8""},
			{0, u8"Что именно вас беспокоит?"},
			{1, u8""},
			{0, u8"Принимали ли вы какие-либо лекарства в последнее время?"},
			{1, u8""},
			{0, u8"/me записыва{sex:|ю} ответы в медицинскую карту"},
			{0, u8"Хорошо, понял вас."},
			{0, u8"/b /me слушаю(ю) пациента"},
			{1, u8""},
			{0, u8"/do Осмотр завершён."},
			{0, u8"/me даю пациенту направление на анализы"},
			{0, u8"/me назначаю лечение и выписываю рецепт"},
			{0, u8"Приходите через неделю на повторный приём."},
			{0, u8"/me записываю дату следующего визита в карту"},
			{0, u8"/do Пациент получает все необходимые инструкции."},
			{0, u8"/me выписываю рекомендации по режиму питания"},
			{0, u8"Извините, но я должен вас предупредить, что ваше состояние требует внимания."},
			{1, u8""},
			{0, u8"До свидания."},
			{0, u8"/me закрываю карту и передаю пациенту"},
			{0, u8"/me записываю свой номер в карту пациента"},
			{0, u8"Спасибо, приходите, если что-то изменится."}
		},
		sec = 2.0
	},
	[13] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Вам необходимо сделать татуировку для маскировки шрама."},
			{0, u8"Подготовьте место для процедуры, пожалуйста."},
			{1, u8""},
			{0, u8"/me бер{sex:|у} тату-машинку и готовлю эскиз"},
			{0, u8"/do На коже пациента видно место для нанесения рисунка."},
			{0, u8"/me наношу контур и начинаю заполнять его краской"},
			{0, u8"Стоимость этой татуировки составит {pricetatu}$. Вы согласны?"},
			{0, u8"/n Обратите внимание на стерильность инструментов."},
			{0, u8"/b Дополнительную информацию можно узнать через /showtatu"},
			{1, u8""},
			{0, u8"Хорошо, я начинаю, постарайтесь не двигаться, чтобы я мог{sex:|а} выполнить работу."},
			{0, u8"/do В кабинете слышен гул тату-машинки."},
			{0, u8"/do Мастер делает перерыв, чтобы пациент мог отдохнуть."},
			{0, u8"/me заканчиваю последние штрихи и обрабатываю кожу"},
			{0, u8"/me протираю тату, заклеиваю плёнкой для заживления"},
			{0, u8"/unstuff {arg1} {pricetatu}"}
		},
		sec = 2.0
	},
	[14] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете слышен звук печатающей машинки."},
			{0, u8"/me бер{sex:|у} лист бумаги, чтобы выписыва{sex:|ть} предупреждение {sex:пациенту|пациентке} нашей клиники {myHospEn}"},
			{0, u8"/me выписыва{sex:|ю} официальное предупреждение {namePlayerRus[{arg1}]}"},
			{0, u8"/fwarn {arg1} {arg2}"},
			{0, u8"/r {namePlayerRus[{arg1}]} получил дисциплинарное взыскание! Причина: {arg2}"}
		},
		sec = 2.0
	},
	[15] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете слышен звук печатающей машинки."},
			{0, u8"/me бер{sex:|у} лист бумаги, чтобы отменить предупреждение {sex:пациенту|пациентке} нашей клиники {myHospEn}"},
			{0, u8"/me выписыва{sex:|ю} уведомление об отмене {namePlayerRus[{arg1}]}"},
			{0, u8"/unfwarn {arg1}"},
			{0, u8"/r Предупреждение {namePlayerRus[{arg1}]} было снято!"}
		},
		sec = 2.0
	},
	[16] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {0, u8"время мута в минутах"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do Мутации запрещены на территории клиники."},
			{0, u8"/me выписыва{sex:|ю} предписание, чтобы ограничи{sex:|ть} {sex:пациента|пациентку} в правах"},
			{0, u8"/me вношу запись в журнал мутаций для {namePlayerRus[{arg1}]}"},
			{0, u8"/fmute {arg1} {arg2} {arg3}"},
			{0, u8"/r {namePlayerRus[{arg1}]} получил мут на время {arg3}. Причина: {arg2}"},
			{0, u8"/me снимаю мутацию по истечении срока"}
		},
		sec = 2.0
	},
	[17] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do Мутации запрещены на территории клиники."},
			{0, u8"/me выписываю разрешение на снятие мута для {namePlayerRus[{arg1}]}"},
			{0, u8"/me аннулирую запись о мутации {namePlayerRus[{arg1}]}"},
			{0, u8"/funmute {arg1}"},
			{0, u8"/r {namePlayerRus[{arg1}]} больше не мутирован!"},
			{0, u8"/me удаляю запись из журнала"}
		},
		sec = 2.0
	},
	[18] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {0, u8"номер ранга"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете раздаётся стук печати и шелест бумаг."},
			{0, u8"/me достаю бланк повышения, заполняю {sex:его|её} и подписываю"},
			{0, u8"/me вручаю приказ о повышении, поздравляю коллегу"},
			{0, u8"/me записываю новый ранг в личное дело"},
			{0, u8"/giverank {arg1} {arg2}"},
			{0, u8"/r Поздравляем {namePlayerRus[{arg1}]} с повышением! Так держать!"}
		},
		sec = 2.0
	},
	[19] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете тихо, слышно только дыхание."},
			{0, u8"/me приглашаю {sex:пациента|пациентку} зайти в кабинет"},
			{0, u8"/me записываю номер {sex:пациента|пациентки} в журнал"},
			{0, u8"/invite {arg1}"},
			{0, u8"/r Новый сотрудник {namePlayerRus[{arg1}]} принят в отделение!"}
		},
		sec = 2.0
	},
	[20] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете слышен звук печати."},
			{0, u8"/me беру бланк увольнения, заполняю {sex:его|её} для {sex:пациента|пациентки} нашей клиники {myHospEn}"},
			{0, u8"/me выписываю увольнение {namePlayerRus[{arg1}]}"},
			{0, u8"/uninvite {arg1} {arg2}"},
			{0, u8"/r {namePlayerRus[{arg1}]} был уволен из организации. Причина: {arg2}"}
		},
		sec = 2.0
	},
	[22] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/me беру бланк исключения для {sex:сотрудника|сотрудницы} из отдела"},
			{0, u8"/do Бланк подписан руководителем."},
			{0, u8"/todo Извиняюсь, я должен исключить {sex:его|её} из списка*Подпись и печать"},
			{0, u8"/me передаю уведомление об исключении {sex:сотруднику|сотруднице}"},
			{0, u8"/expel {arg1} {arg2}"}
		},
		sec = 2.0
	},
	[23] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{3, u8"Выберите тип вакцины:"},
			{2, {u8"Вакцина Pfizer", u8"Вакцина Moderna"}},
			{0, u8"{dialog1}Добро пожаловать, вы записаны на вакцинацию."},
			{0, u8"{dialog1}Стоимость вакцины составляет 600.000$. Вы согласны?"},
			{0, u8"{dialog1}Если нет, то откажитесь от процедуры и покиньте кабинет."},
			{1, u8""},
			{0, u8'{dialog1}/do На столе лежит ампула с вакциной "BioNTech".'},
			{0, u8"{dialog1}/me беру шприц, набираю вакцину и обрабатываю место укола"},
			{0, u8"{dialog1}/do Делаю укол в плечо."},
			{0, u8"{dialog1}/me ввожу вакцину и жду несколько секунд"},
			{0, u8"{dialog1}/do Реакция на вакцину отсутствует."},
			{0, u8"{dialog1}/me закрываю пробирку и убираю её в контейнер"},
			{0, u8"{dialog1}/me заполняю карту вакцинации и передаю пациенту"},
			{0, u8"{dialog1}/vaccine {arg1}"},
			{0, u8"{dialog1}/n Если возникнут побочные эффекты, сразу обратитесь к врачу."},
			{0, u8'{dialog2}/do На столе лежит ампула с вакциной "BioNTech".'},
			{0, u8"{dialog2}/me беру шприц, набираю вакцину и обрабатываю место укола"},
			{0, u8"{dialog2}/do Делаю укол в плечо."},
			{0, u8"{dialog2}/me ввожу вакцину и жду несколько секунд"},
			{0, u8"{dialog2}/do Реакция на вакцину отсутствует."},
			{0, u8"{dialog2}/me закрываю пробирку и убираю её в контейнер"},
			{0, u8"{dialog2}/me заполняю карту вакцинации и передаю пациенту"},
			{0, u8"{dialog2}/vaccine {arg1}"}
		},
		sec = 2.0
	},
	[25] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Закрываю отделение."}
		},
		sec = 2.0
	},
	[26] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Здраствуйте, меня зовут {myRusNick}, чем я могу помочь?"}
		},
		sec = 2.0
	},
	[27] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = true,
		typeAct = {
			{0, u8"Здравствуйте, я ваш лечащий врач."},
			{0, u8"Стоимость курса антибиотиков составит {priceant}$. Вы согласны?"},
			{0, u8"Если нет, то мы не сможем начать лечение."},
			{3, u8"Пожалуйста, подождите, я готовлю рецепт."},
			{1, u8""},
			{0, u8"/me выписываю рецепт на антибиотики, чтобы пациент мог пройти курс"},
			{0, u8"/do Рецепт подписан и передан пациенту."},
			{0, u8"/todo Лечу пациента антибиотиками!*Антибиотик в упаковке"},
			{3, u8"Рекомендую приобрести антибиотики в ближайшей аптеке."},
			{0, u8"/antibiotik {arg1} "}
		},
		sec = 2.0
	},
	[28] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Здравствуйте, вы хотите оформить медицинскую страховку?"},
			{0, u8"Отлично, сейчас я оформлю вашу мед. карту."},
			{0, u8"/b /showmc {myID}"},
			{1, u8""},
			{0, u8"/todo Оформляю страховку!*Заполняю бланк и ставлю печать."},
			{0, u8"Стоимость страховки зависит от выбранного пакета:"},
			{0, u8"На 1 месяц - 4 млн.$. На 2 месяца - 8 млн.$. На 3 месяца - 1.2 млн.$"},
			{0, u8"Какой пакет вы выбираете?"},
			{1, u8""},
			{0, u8"Хорошо, я оформлю страховку."},
			{0, u8"/me заполняю заявление на страховку для пациента"},
			{0, u8"/me проверяю данные, чтобы оформить полис"},
			{0, u8"/me вношу данные в базу и ставлю печать на полис"},
			{0, u8"/me выдаю полис пациенту и объясняю условия"},
			{0, u8"/do Полис готов, пациент получает копию."},
			{0, u8"/me подписываю документы и передаю их пациенту"},
			{0, u8"/do Процесс оформления завершён."},
			{0, u8"Поздравляю, теперь вы застрахованы. Берегите себя!"},
			{0, u8"/givemedinsurance {arg1}"}
		},
		sec = 2.0
	},
	[29] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Вы жаловались на боли в области сердца?"},
			{0, u8"/me прослушиваю сердце и лёгкие пациента, затем измеряю давление"},
			{0, u8"/do Врач записывает результаты осмотра."},
			{0, u8"/todo Пациент здоров!*Назначаю лечение и выписываю рецепт."},
			{0, u8"/me назначаю курс лечения и даю рекомендации пациенту"},
			{0, u8"/me объясняю пациенту, как принимать лекарства"},
			{0, u8"/do Пациент задаёт уточняющие вопросы."},
			{0, u8"/me записываю все назначения в карту"},
			{0, u8"/me даю направление на дополнительные обследования"},
			{0, u8"/me выписываю рецепт на нужные препараты"},
			{0, u8"/me объясняю пациенту режим приёма лекарств"},
			{0, u8"/do Пациент получил все необходимые рекомендации."},
			{0, u8"/cure {arg1}"}
		},
		sec = 2.0
	},
	[34] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{2, {u8"Показать паспорт", u8"Показать мед. карту", u8"Показать лицензию"}},
			{0, u8"{dialog1}/do Пациент предъявляет документ для проверки."},
			{0, u8"{dialog1}/me смотрю на документ, сверяю данные и записываю в журнал"},
			{0, u8"{dialog1}/showpass {arg1}"},
			{0, u8"{dialog2}/do Медкарта открыта на нужной странице."},
			{0, u8"{dialog2}/me изучаю записи, ставлю отметку и передаю документ обратно"},
			{0, u8"{dialog2}/showmc {arg1}"},
			{0, u8"{dialog3}/do Лицензия предъявлена."},
			{0, u8"{dialog3}/me проверяю срок действия лицензии и записываю номер"},
			{0, u8"{dialog3}/showlic {arg1}"}
		},
		sec = 2.0
	},
	[35] = {
		argfunc = true,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{2, {u8"Включить камеру", u8"Выключить камеру"}},
			{0, u8"{dialog1}/do Камера активирована в кабинете."},
			{0, u8'{dialog1}/me включаю камеру видеонаблюдения, чтобы записывать происходящее в режиме "онлайн"'},
			{0, u8"{dialog1}/me проверяю угол обзора и настраиваю фокусировку"},
			{0, u8"{dialog1}/do Запись ведётся, все действия фиксируются."},
			{0, u8"{dialog2}/do Камера отключена."},
			{0, u8"{dialog2}/me выключаю камеру, завершая запись"},
			{0, u8"{dialog2}/do Система наблюдения переведена в режим ожидания."}
		},
		sec = 2.0
	}
}
local acting_defoult = {
	[5] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do Осматриваю тело пациента на наличие повреждений."},
			{0, u8"/me доста{sex:|ю} аптечку и начина{sex:|ю} оказывать первую помощь пациен{sex:|ту}."},
			{0, u8"/me начинаю лечение на месте, чтобы стабилизироват{sex:|ь} состояние пациента"},
			{0, u8"/heal {arg1} {pricelec}"},
			{0, u8"/todo Лечу, выписываю рецепт, надеюсь на лучшее!*Ввожу лекарство"}
		},
		sec = 2.0
	},
	[7] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = true,
		var = {u8"0", u8"0", u8"0", u8"0", u8"0", u8"0", u8"0"},
		chatopen = false,
		typeAct = {
			{0, u8"Как вы себя чувствуете после полученных травм?"},
			{0, u8"Мне необходимо сверить ваши данные с картой, чтобы убедиться."},
			{0, u8'/b Ты можешь показать /showpass {myID}'},
			{1, u8""},
			{0, u8"/me бер{sex:|у} ручку и заполня{sex:|ю} бланк первичного осмотр{sex:|а}"},
			{2, {u8"Обычная мед. карта", u8"Расширенная мед. карта"}},
			{0, u8"{dialog1}Выберите тип мед. карты для дальнейшей работы."},
			{0, u8"{dialog1}7 дней: {med7}$. 14 дней: {med14}$"},
			{0, u8"{dialog1}30 дней: {med30}$. 60 дней: {med60}$"},
			{4, 0, u8"{med7}"},
			{4, 1, u8"{med14}"},
			{4, 2, u8"{med30}"},
			{4, 3, u8"{med60}"},
			{0, u8"{dialog2}Выберите тип расширенной мед. карты для дальнейшей работы."},
			{0, u8"{dialog2}7 дней: {medup7}$. 14 дней: {medup14}$"},
			{0, u8"{dialog2}30 дней: {medup30}$. 60 дней: {medup60}$"},
			{4, 0, u8"{medup7}"},
			{4, 1, u8"{medup14}"},
			{4, 2, u8"{medup30}"},
			{4, 3, u8"{medup60}"},
			{0, u8"/n Обращаю внимание на общее состояние пациента, чтобы выявить проблемы."},
			{0, u8"У вас есть какие-либо хронические заболевания?"},
			{2, {u8"7 дней", u8"14 дней", u8"30 дней", u8"60 дней"}},
			{0, u8"{dialog1}"},
			{4, 4, u8"{var1}"},
			{4, 5, u8"0"},
			{0, u8"{dialog2}"},
			{4, 4, u8"{var2}"},
			{4, 5, u8"1"},
			{0, u8"{dialog3}"},
			{4, 4, u8"{var3}"},
			{4, 5, u8"2"},
			{0, u8"{dialog4}"},
			{4, 4, u8"{var4}"},
			{4, 5, u8"3"},
			{0, u8"Хорошо, теперь я заполню карту, подождите немного."},
			{0, u8"Вы не против, если я задам вам несколько вопросов?"},
			{1, u8""},
			{0, u8"Какие-либо ещё симптомы?"},
			{2, {u8"Головная боль", u8"Тошнота и рвота", u8"Повышенная температура", u8"Не беспокоит"}},
			{0, u8"{dialog1}"},
			{4, 6, u8"3"},
			{0, u8"{dialog2}"},
			{4, 6, u8"2"},
			{0, u8"{dialog3}"},
			{4, 6, u8"1"},
			{0, u8"{dialog4}"},
			{4, 6, u8"0"},
			{0, u8"/me вношу данные в мед. карту и завершаю осмотр, выдаю пациенту справку"},
			{0, u8"/do Врач передаёт карту на подпись."},
			{0, u8"/me беру карту в руки, чтобы заполнить оставшиеся поля и поставить печать"},
			{0, u8"/do Процедура успешно завершена, карта готова."},
			{0, u8"/me вношу заключительные данные в электронную базу"},
			{0, u8"/medcard {arg1} {var7} {var6} {var5}"}
		},
		sec = 2.0
	},
	[8] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Вам необходимо пройти обследование у нарколога."},
			{0, u8"Стоимость процедуры составляет {pricenarko}$"},
			{0, u8'Пожалуйста, заполните анкету, указав "Наркотики". После этого вы сможете пройти тестирование.'},
			{0, u8"Вы согласны? Если да, то подпишите договор и оплатите."},
			{1, u8""},
			{0, u8"/do На столе лежат несколько бланков с анализами."},
			{0, u8"/me беру в руки шприц для забора крови, чтобы провери{sex:|ть} пациента"},
			{0, u8"/todo Провожу экспресс-тест на наркотики*Ввожу препарат. Беру образец мочи"},
			{0, u8"/me бер{sex:|у} пробирку, чтобы взят{sex:|ь} кровь на анализ"},
			{0, u8"/me записыва{sex:|ю} результаты, визуально оценива{sex:|ю} состояние"},
			{0, u8"/do Результаты анализов готовы к интерпретации."},
			{0, u8"/me бер{sex:|у} препарат и ввож{sex:|у} пациенту антидот"},
			{0, u8"/healbad {arg1}"},
			{0, u8"/todo Фух, я спас пациента от передозировки!*Ввожу антидот и ставлю капельницу"}
		},
		sec = 2.0
	},
	[9] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = true,
		var = {u8"1"},
		chatopen = false,
		typeAct = {
			{0, u8"Выписываю вам рецепт на основе ваших жалоб."},
			{0, u8"/n В течение 5 дней соблюдайте постельный режим."},
			{0, u8"Стоимость рецепта составляет {pricerecept}$"},
			{0, u8"Вы согласны? Если да, то оплатите на ресепшене?"},
			{3, u8"Пожалуйста, подождите, я подготовлю бланк рецепта."},
			{2, {u8"1 таблетка", u8"2 таблетки", u8"3 таблетки", u8"4 таблетки", u8"5 уколов"}},
			{0, u8"{dialog1}"},
			{4, 0, u8"1"},
			{0, u8"{dialog2}"},
			{4, 0, u8"2"},
			{0, u8"{dialog3}"},
			{4, 0, u8"3"},
			{0, u8"{dialog4}"},
			{4, 0, u8"4"},
			{0, u8"{dialog5}"},
			{4, 0, u8"5"},
			{0, u8"/do На столе лежит готовый бланк с подписью врача."},
			{0, u8"/me беру бланк и заполняю необходимые поля, затем передаю пациенту"},
			{0, u8"/do Бланк рецепта имеет все необходимые печати."},
			{0, u8"/todo Рецепт готов, передаю пациенту!*Бланк с рецептом и рекомендациями"},
			{0, u8"/recept {arg1} {var1}"}
		},
		sec = 2.0
	},
	[10] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Здравствуйте, меня зовут доктор Смит. Я ваш лечащий врач."},
			{0, u8"Расскажите, что именно вас беспокоит."},
			{1, u8""},
			{0, u8"/me смотрю на пациента и слушаю его жалобы"},
			{0, u8"/do Осмотр начинается с измерения давления и пульса."},
			{0, u8"Итак, давайте я задам вам несколько вопросов о вашем состоянии."},
			{0, u8"Вы когда-нибудь ранее проходили подобное обследование?"},
			{1, u8""},
			{0, u8"Что именно вас беспокоит?"},
			{1, u8""},
			{0, u8"Принимали ли вы какие-либо лекарства в последнее время?"},
			{1, u8""},
			{0, u8"/me записываю ответы в медицинскую карту"},
			{0, u8"Хорошо, понял вас."},
			{0, u8"/b /me слушаю пациента"},
			{1, u8""},
			{0, u8"/do Осмотр завершён."},
			{0, u8"/me даю пациенту направление на анализы"},
			{0, u8"/me назначаю лечение и выписываю рецепт"},
			{0, u8"Приходите через неделю на повторный приём."},
			{0, u8"/me записываю дату следующего визита в карту"},
			{0, u8"/do Пациент получает все необходимые инструкции."},
			{0, u8"/me выписываю рекомендации по режиму питания"},
			{0, u8"Извините, но я должен вас предупредить, что ваше состояние требует внимания."},
			{1, u8""},
			{0, u8"До свидания."},
			{0, u8"/me закрываю карту и передаю пациенту"},
			{0, u8"/me записываю свой номер в карту пациента"},
			{0, u8"Спасибо, приходите, если что-то изменится."}
		},
		sec = 2.0
	},
	[13] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Вам необходимо сделать татуировку для маскировки шрама."},
			{0, u8"Подготовьте место для процедуры, пожалуйста."},
			{1, u8""},
			{0, u8"/me беру тату-машинку и готовлю эскиз"},
			{0, u8"/do На коже пациента видно место для нанесения рисунка."},
			{0, u8"/me наношу контур и начинаю заполнять его краской"},
			{0, u8"Стоимость этой татуировки составит {pricetatu}$. Вы согласны?"},
			{0, u8"/n Обратите внимание на стерильность инструментов."},
			{0, u8"/b Дополнительную информацию можно узнать через /showtatu"},
			{1, u8""},
			{0, u8"Хорошо, я начинаю, постарайтесь не двигаться, чтобы я мог выполнить работу."},
			{0, u8"/do В кабинете слышен гул тату-машинки."},
			{0, u8"/do Мастер делает перерыв, чтобы пациент мог отдохнуть."},
			{0, u8"/me заканчиваю последние штрихи и обрабатываю кожу"},
			{0, u8"/me протираю тату, заклеиваю плёнкой для заживления"},
			{0, u8"/unstuff {arg1} {pricetatu}"}
		},
		sec = 2.0
	},
	[14] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете слышен звук печатающей машинки."},
			{0, u8"/me беру лист бумаги, чтобы выписывать предупреждение пациенту нашей клиники {myHospEn}"},
			{0, u8"/me выписываю официальное предупреждение {namePlayerRus[{arg1}]}"},
			{0, u8"/fwarn {arg1} {arg2}"},
			{0, u8"/r {namePlayerRus[{arg1}]} получил дисциплинарное взыскание! Причина: {arg2}"}
		},
		sec = 2.0
	},
	[15] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете слышен звук печатающей машинки."},
			{0, u8"/me беру лист бумаги, чтобы отменить предупреждение пациенту нашей клиники {myHospEn}"},
			{0, u8"/me выписываю уведомление об отмене {namePlayerRus[{arg1}]}"},
			{0, u8"/unfwarn {arg1}"},
			{0, u8"/r Предупреждение {namePlayerRus[{arg1}]} было снято!"}
		},
		sec = 2.0
	},
	[16] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {0, u8"время мута в минутах"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do Мутации запрещены на территории клиники."},
			{0, u8"/me выписываю предписание, чтобы ограничить пациента в правах"},
			{0, u8"/me вношу запись в журнал мутаций для {namePlayerRus[{arg1}]}"},
			{0, u8"/fmute {arg1} {arg2} {arg3}"},
			{0, u8"/r {namePlayerRus[{arg1}]} получил мут на время {arg3}. Причина: {arg2}"},
			{0, u8"/me снимаю мутацию по истечении срока"}
		},
		sec = 2.0
	},
	[17] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do Мутации запрещены на территории клиники."},
			{0, u8"/me выписываю разрешение на снятие мута для {namePlayerRus[{arg1}]}"},
			{0, u8"/me аннулирую запись о мутации {namePlayerRus[{arg1}]}"},
			{0, u8"/funmute {arg1}"},
			{0, u8"/r {namePlayerRus[{arg1}]} больше не мутирован!"},
			{0, u8"/me удаляю запись из журнала"}
		},
		sec = 2.0
	},
	[18] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {0, u8"номер ранга"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете раздаётся стук печати и шелест бумаг."},
			{0, u8"/me достаю бланк повышения, заполняю его и подписываю"},
			{0, u8"/me вручаю приказ о повышении, поздравляю коллегу"},
			{0, u8"/me записываю новый ранг в личное дело"},
			{0, u8"/giverank {arg1} {arg2}"},
			{0, u8"/r Поздравляем {namePlayerRus[{arg1}]} с повышением! Так держать!"}
		},
		sec = 2.0
	},
	[19] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете тихо, слышно только дыхание."},
			{0, u8"/me приглашаю пациента зайти в кабинет"},
			{0, u8"/me записываю номер пациента в журнал"},
			{0, u8"/invite {arg1}"},
			{0, u8"/r Новый сотрудник {namePlayerRus[{arg1}]} принят в отделение!"}
		},
		sec = 2.0
	},
	[20] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/do В кабинете слышен звук печати."},
			{0, u8"/me беру бланк увольнения, заполняю его для пациента нашей клиники {myHospEn}"},
			{0, u8"/me выписываю увольнение {namePlayerRus[{arg1}]}"},
			{0, u8"/uninvite {arg1} {arg2}"},
			{0, u8"/r {namePlayerRus[{arg1}]} был уволен из организации. Причина: {arg2}"}
		},
		sec = 2.0
	},
	[22] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}, {1, u8"причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"/me беру бланк исключения для сотрудника из отдела"},
			{0, u8"/do Бланк подписан руководителем."},
			{0, u8"/todo Извиняюсь, я должен исключить его из списка*Подпись и печать"},
			{0, u8"/me передаю уведомление об исключении сотруднику"},
			{0, u8"/expel {arg1} {arg2}"}
		},
		sec = 2.0
	},
	[23] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{3, u8"Выберите тип вакцины:"},
			{2, {u8"Вакцина Pfizer", u8"Вакцина Moderna"}},
			{0, u8"{dialog1}Добро пожаловать, вы записаны на вакцинацию."},
			{0, u8"{dialog1}Стоимость вакцины составляет 600.000$. Вы согласны?"},
			{0, u8"{dialog1}Если нет, то откажитесь от процедуры и покиньте кабинет."},
			{1, u8""},
			{0, u8'{dialog1}/do На столе лежит ампула с вакциной "BioNTech".'},
			{0, u8"{dialog1}/me беру шприц, набираю вакцину и обрабатываю место укола"},
			{0, u8"{dialog1}/do Делаю укол в плечо."},
			{0, u8"{dialog1}/me ввожу вакцину и жду несколько секунд"},
			{0, u8"{dialog1}/do Реакция на вакцину отсутствует."},
			{0, u8"{dialog1}/me закрываю пробирку и убираю её в контейнер"},
			{0, u8"{dialog1}/me заполняю карту вакцинации и передаю пациенту"},
			{0, u8"{dialog1}/vaccine {arg1}"},
			{0, u8"{dialog1}/n Если возникнут побочные эффекты, сразу обратитесь к врачу."},
			{0, u8'{dialog2}/do На столе лежит ампула с вакциной "BioNTech".'},
			{0, u8"{dialog2}/me беру шприц, набираю вакцину и обрабатываю место укола"},
			{0, u8"{dialog2}/do Делаю укол в плечо."},
			{0, u8"{dialog2}/me ввожу вакцину и жду несколько секунд"},
			{0, u8"{dialog2}/do Реакция на вакцину отсутствует."},
			{0, u8"{dialog2}/me закрываю пробирку и убираю её в контейнер"},
			{0, u8"{dialog2}/me заполняю карту вакцинации и передаю пациенту"},
			{0, u8"{dialog2}/vaccine {arg1}"}
		},
		sec = 2.0
	},
	[25] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Закрываю отделение."}
		},
		sec = 2.0
	},
	[26] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Здраствуйте, меня зовут {myRusNick}, чем я могу помочь?"}
		},
		sec = 2.0
	},
	[27] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = true,
		typeAct = {
			{0, u8"Здравствуйте, я ваш лечащий врач."},
			{0, u8"Стоимость курса антибиотиков составит {priceant}$. Вы согласны?"},
			{0, u8"Если нет, то мы не сможем начать лечение."},
			{3, u8"Пожалуйста, подождите, я готовлю рецепт."},
			{1, u8""},
			{0, u8"/me выписываю рецепт на антибиотики, чтобы пациент мог пройти курс"},
			{0, u8"/do Рецепт подписан и передан пациенту."},
			{0, u8"/todo Лечу пациента антибиотиками!*Антибиотик в упаковке"},
			{3, u8"Рекомендую приобрести антибиотики в ближайшей аптеке."},
			{0, u8"/antibiotik {arg1} "}
		},
		sec = 2.0
	},
	[28] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Здравствуйте, вы хотите оформить медицинскую страховку?"},
			{0, u8"Отлично, сейчас я оформлю вашу мед. карту."},
			{0, u8"/b /showmc {myID}"},
			{1, u8""},
			{0, u8"/todo Оформляю страховку!*Заполняю бланк и ставлю печать."},
			{0, u8"Стоимость страховки зависит от выбранного пакета:"},
			{0, u8"На 1 месяц - 4 млн.$. На 2 месяца - 8 млн.$. На 3 месяца - 1.2 млн.$"},
			{0, u8"Какой пакет вы выбираете?"},
			{1, u8""},
			{0, u8"Хорошо, я оформлю страховку."},
			{0, u8"/me заполняю заявление на страховку для пациента"},
			{0, u8"/me проверяю данные, чтобы оформить полис"},
			{0, u8"/me вношу данные в базу и ставлю печать на полис"},
			{0, u8"/me выдаю полис пациенту и объясняю условия"},
			{0, u8"/do Полис готов, пациент получает копию."},
			{0, u8"/me подписываю документы и передаю их пациенту"},
			{0, u8"/do Процесс оформления завершён."},
			{0, u8"Поздравляю, теперь вы застрахованы. Берегите себя!"},
			{0, u8"/givemedinsurance {arg1}"}
		},
		sec = 2.0
	},
	[29] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{0, u8"Вы жаловались на боли в области сердца?"},
			{0, u8"/me прослушиваю сердце и лёгкие пациента, затем измеряю давление"},
			{0, u8"/do Врач записывает результаты осмотра."},
			{0, u8"/todo Пациент здоров!*Назначаю лечение и выписываю рецепт."},
			{0, u8"/me назначаю курс лечения и даю рекомендации пациенту"},
			{0, u8"/me объясняю пациенту, как принимать лекарства"},
			{0, u8"/do Пациент задаёт уточняющие вопросы."},
			{0, u8"/me записываю все назначения в карту"},
			{0, u8"/me даю направление на дополнительные обследования"},
			{0, u8"/me выписываю рецепт на нужные препараты"},
			{0, u8"/me объясняю пациенту режим приёма лекарств"},
			{0, u8"/do Пациент получил все необходимые рекомендации."},
			{0, u8"/cure {arg1}"}
		},
		sec = 2.0
	},
	[34] = {
		argfunc = true,
		arg = {{0, u8"id пациента"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{2, {u8"Показать паспорт", u8"Показать мед. карту", u8"Показать лицензию"}},
			{0, u8"{dialog1}/do Пациент предъявляет документ для проверки."},
			{0, u8"{dialog1}/me смотрю на документ, сверяю данные и записываю в журнал"},
			{0, u8"{dialog1}/showpass {arg1}"},
			{0, u8"{dialog2}/do Медкарта открыта на нужной странице."},
			{0, u8"{dialog2}/me изучаю записи, ставлю отметку и передаю документ обратно"},
			{0, u8"{dialog2}/showmc {arg1}"},
			{0, u8"{dialog3}/do Лицензия предъявлена."},
			{0, u8"{dialog3}/me проверяю срок действия лицензии и записываю номер"},
			{0, u8"{dialog3}/showlic {arg1}"}
		},
		sec = 2.0
	},
	[35] = {
		argfunc = true,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {
			{2, {u8"Включить камеру", u8"Выключить камеру"}},
			{0, u8"{dialog1}/do Камера активирована в кабинете."},
			{0, u8'{dialog1}/me включаю камеру видеонаблюдения, чтобы записывать происходящее в режиме "онлайн"'},
			{0, u8"{dialog1}/me проверяю угол обзора и настраиваю фокусировку"},
			{0, u8"{dialog1}/do Запись ведётся, все действия фиксируются."},
			{0, u8"{dialog2}/do Камера отключена."},
			{0, u8"{dialog2}/me выключаю камеру, завершая запись"},
			{0, u8"{dialog2}/do Система наблюдения переведена в режим ожидания."}
		},
		sec = 2.0
	}
}

local optionsPKM = { u8"Лечение", u8"Выдать мед.карту", u8"Вакцинация", u8"Выдать рецепт", u8"Лечение наркотиков", u8"Выдать антибиотики", u8"Осмотр на наркотики", u8"Оформить страховку", u8"Лечение от болезни", u8"Разговор с пациентом", u8"Выдать справку", u8"Показать документы", u8"Удалить тату"
}
local setting2 = {
	funcPKM = {
		func = false,
		slider = {0, 1, 2, 3, 4, 6}
	},
	color_int = 0xFFED2626
}
local chg_funcPKM = {
	func = imgui.ImBool(false),
	slider = {imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0)}
}
for i, v in ipairs(chg_funcPKM.slider) do
	chg_funcPKM.slider[i].v = setting2.funcPKM.slider[i]
end
inventoryOpen = false
setDep = {"","",""}
cmdBind = {
	[1] = {
		cmd = "mh",
		key = {},
		desc = "Открыть главное меню.",
		rank = 1,
		rb = false
	},
	[2] = {
		cmd = "r",
		key = {},
		desc = "Ответить в рацию с тегом (если он установлен).",
		rank = 1,
		rb = false
	},
	[3] = {
		cmd = "rb",
		key = {},
		desc = "Ответить в рацию без тега.",
		rank = 1,
		rb = false
	},
	[4] = {
		cmd = "mb",
		key = {},
		desc = "Выполнить команду /members",
		rank = 1,
		rb = false
	},
	[5] = {
		cmd = "hl",
		key = {},
		desc = "Лечение по голосовому обращению.",
		rank = 2,
		rb = false
	},
	[6] = {
		cmd = "post",
		key = {},
		desc = "Пост о дежурстве. Доступен только в машине.",
		rank = 2,
		rb = false
	},
	[7] = {
		cmd = "mc",
		key = {},
		desc = "Оформление медицинской карты.",
		rank = 2,
		rb = false
	},
	[8] = {
		cmd = "narko",
		key = {},
		desc = "Лечение от наркозависимости.",
		rank = 4,
		rb = false
	},
	[9] = {
		cmd = "recep",
		key = {},
		desc = "Выдача рецепта.",
		rank = 4,
		rb = false
	},
	[10] = {
		cmd = "osm",
		key = {},
		desc = "Проведение медицинского осмотра.",
		rank = 5,
		rb = false
	},
	[11] = {
		cmd = "dep",
		key = {},
		desc = "Меню департамента.",
		rank = 5,
		rb = false
	},
	[12] = {
		cmd = "sob",
		key = {},
		desc = "Меню собеседования с пациентом.",
		rank = 5,
		rb = false
	},
	[13] = {
		cmd = "tatu",
		key = {},
		desc = "Удаление татуировки.",
		rank = 7,
		rb = false
	},
	[14] = {
		cmd = "vig",
		key = {},
		desc = "Выдача дисциплинарного взыскания.",
		rank = 8,
		rb = false
	},
	[15] = {
		cmd = "unvig",
		key = {},
		desc = "Снятие дисциплинарного взыскания.",
		rank = 8,
		rb = false
	},
	[16] = {
		cmd = "muteorg",
		key = {},
		desc = "Мут в организации.",
		rank = 8,
		rb = false
	},
	[17] = {
		cmd = "unmuteorg",
		key = {},
		desc = "Снятие мута в организации.",
		rank = 8,
		rb = false
	},
	[18] = {
		cmd = "gr",
		key = {},
		desc = "Повышение ранга (для сотрудников) в организации.",
		rank = 9,
		rb = false
	},
	[19] = {
		cmd = "inv",
		key = {},
		desc = "Приём в организацию (инвайт).",
		rank = 9,
		rb = false
	},
	[20] = {
		cmd = "unv",
		key = {},
		desc = "Увольнение из организации.",
		rank = 9,
		rb = false
	},
	[21] = {
		cmd = "time",
		key = {},
		desc = "Отправка времени с погодой.",
		rank = 1,
		rb = false
	},
	[22] = {
		cmd = "exp",
		key = {},
		desc = "Исключение из отдела.",
		rank = 1,
		rb = false
	},
	[23] = {
		cmd = "vac",
		key = {},
		desc = "Вакцинация пациента.",
		rank = 3,
		rb = false
	},
	[24] = {
		cmd = "info",
		key = {},
		desc = "Информация о доступных командах и их назначении.",
		rank = 1,
		rb = false
	},
	[25] = {
		cmd = "za",
		key = {},
		desc = "Закрытие отделения (фраза \"Закрываю отделение.\").",
		rank = 1,
		rb = false
	},
	[26] = {
		cmd = "zd",
		key = {},
		desc = "Приветствие пациента.",
		rank = 1,
		rb = false
	},
	[27] = {
		cmd = "ant",
		key = {},
		desc = "Выдача антибиотиков.",
		rank = 4,
		rb = false
	},
	[28] = {
		cmd = "strah",
		key = {},
		desc = "Оформление медицинской страховки.",
		rank = 3,
		rb = false
	},
	[29] = {
		cmd = "cur",
		key = {},
		desc = "Лечение болезни (курс лечения).",
		rank = 2,
		rb = false
	},
	[30] = {
		cmd = "hall",
		key = {2,50},
		desc = "Лечение всех пациентов в радиусе 2 метров.",
		rank = 1.5,
		rb = false
	},
	[31] = {
		cmd = "hilka",
		key = {2,49},
		desc = "Лечение ближайшего пациента (по радиусу).",
		rank = 1.5,
		rb = false
	},
	[32] = {
		cmd = "shpora",
		key = {},
		desc = "Открыть шпаргалку для медицинских действий.",
		rank = 1,
		rb = false
	},
	[33] = {
		cmd = "hme",
		key = {},
		desc = "Экстренное лечение себя.",
		rank = 1,
		rb = false
	},
	[34] = {
		cmd = "show",
		key = {},
		desc = "Показать документы (паспорт, медкарту, лицензию).",
		rank = 1,
		rb = false
	},
	[35] = {
		cmd = "cam",
		key = {},
		desc = "Включить/выключить камеру наблюдения.",
		rank = 1,
		rb = false
	}
}

function isCursorAvailable()
	return (not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen())
end

function renderFontDrawClickableText(active, font, text, posX, posY, color, color_hovered, align, b_symbol)
	local cursorX, cursorY = getCursorPos()
	local lenght = renderGetFontDrawTextLength(font, text)
	local height = renderGetFontDrawHeight(font)
	local symb_len = renderGetFontDrawTextLength(font, '>')
	local hovered = false
	local result = false
    b_symbol = b_symbol == nil and false or b_symbol
    align = align or 1

    if align == 2 then
    	posX = posX - (lenght / 2)
    elseif align == 3 then
    	posX = posX - lenght
	end

    if active and cursorX > posX and cursorY > posY and cursorX < posX + lenght and cursorY < posY + height then
        hovered = true
        if isKeyJustPressed(0x01) then
        	result = true 
        end
    end

    local anim = math.floor(math.sin(os.clock() * 10) * 3 + 5)

 	if hovered and b_symbol and (align == 2 or align == 1) then
    	renderFontDrawText(font, '>', posX - symb_len - anim, posY, 0x90FFFFFF)
    end 

    renderFontDrawText(font, text, posX, posY, hovered and color_hovered or color)

    if hovered and b_symbol and (align == 2 or align == 3) then
    	renderFontDrawText(font, '<', posX + lenght + anim, posY, 0x90FFFFFF)
    end 

    return result
end

local convert_color = function(argb)
	local col = imgui.ColorConvertU32ToFloat4(argb)
	return imgui.ImFloat4(col.z, col.y, col.x, col.w)
end

function explode_U32(u32)
	local a = bit.band(bit.rshift(u32, 24), 0xFF)
	local r = bit.band(bit.rshift(u32, 16), 0xFF)
	local g = bit.band(bit.rshift(u32, 8), 0xFF)
	local b = bit.band(u32, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8))
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function changeColorAlpha(argb, alpha)
	local _, r, g, b = explode_U32(argb)
	return join_argb(alpha, r, g, b)
end

function ARGBtoStringRGB(abgr)
	local a, r, g, b = explode_U32(abgr)
	local argb = join_argb(a, r, g, b)
	local color = ('%x'):format(bit.band(argb, 0xFFFFFF))
	return ('{%s%s}'):format(('0'):rep(6 - #color), color)
end

function imgui.ColorConvertFloat4ToARGB(float4)
	local abgr = imgui.ColorConvertFloat4ToU32(float4)
	local a, b, g, r = explode_U32(abgr)
	return join_argb(a, r, g, b)
end

function changePosition()
	if C_membScr.func.v then
		lua_thread.create(function()
			local backup = {
				['x'] = C_membScr.pos.x.v,
                ['y'] = C_membScr.pos.y.v
			}
			local ChangePos = true
			sampSetCursorMode(4)
			mainWin.v = false
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите {FF6060}ЛКМ{FFFFFF}, чтобы зафиксировать или {FF6060}ESC{FFFFFF} для отмены.", 0xFF8FA2)
            if not sampIsChatInputActive() then
                while not sampIsChatInputActive() and ChangePos do
                    wait(0)
                    local cX, cY = getCursorPos()
                    C_membScr.pos.x.v = cX
                    C_membScr.pos.y.v = cY
                    if isKeyDown(0x01) then
                    	while isKeyDown(0x01) do wait(0) end
                        ChangePos = false
						settingMassiveMembers()
                        sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Позиция сохранена.", 0xFF8FA2)
                    elseif isKeyJustPressed(VK_ESCAPE) then
                        ChangePos = false
						C_membScr.pos.x.v = backup['x']
						C_membScr.pos.y.v = backup['y']
                        sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Вы отменили изменение позиции.", 0xFF8FA2)
                    end
                end
            end
            sampSetCursorMode(0)
            mainWin.v = true
            ChangePos = false
		end)
	end
end

local fa_font = nil
local fa_font2 = nil
local fa_font3 = nil

local fontsize = nil
local fa_font_mus = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local the_path_to_the_file_font = 'moonloader/lib/fontawesome-webfont.ttf'
if not doesFileExist(getWorkingDirectory()..'/lib/fontawesome-webfont.ttf') then
	the_path_to_the_file_font = 'moonloader/resource/fonts/fontawesome-webfont.ttf'
end
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 14.0, font_config, fa_glyph_ranges)
	end
	if fa_font2 == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = false
		fa_font2 = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 20.0, font_config, fa_glyph_ranges)
	end
	if fa_font3 == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = false
		fa_font3 = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 18.0, font_config, fa_glyph_ranges)
	end
	if fa_font_mus == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = false
		fa_font_mus = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 30.0, font_config, fa_glyph_ranges)
	end
	if fontsize == nil then
		fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end
end
notes = {}
function main()	
	repeat wait(300) until isSampAvailable()
	local base = getModuleHandle("samp.dll")
	local sampVer = mem.tohex( base + 0xBABE, 10, true )
	if sampVer == "E86D9A0A0083C41C85C0" then
		sampIsLocalPlayerSpawned = function()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
	end
	if script.this.filename:find("%.luac") then
		os.rename(getWorkingDirectory().."\\MedicalHelper.luac", getWorkingDirectory().."\\MedicalHelper.lua") 
	end
	thread = lua_thread.create(function() return end)
	sectator = lua_thread.create(function() return end)
	sound_reminder = lua_thread.create(function() return end)
	lua_thread.create(function()
   		repeat wait(100) until sampIsLocalPlayerSpawned()
    	--funCMD.updateCheck()
	end)

if not doesDirectoryExist(dirml.."/MedicalHelper/files/") then
	print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создаю папку для файлов")
	createDirectory(dirml.."/MedicalHelper/files/")
end
if not doesDirectoryExist(dirml.."/MedicalHelper/Binder/") then
	print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создаю папку для биндеров.")
	createDirectory(dirml.."/MedicalHelper/Binder/")
end
if not doesDirectoryExist(dirml.."/MedicalHelper/шпаргалки/") then
	print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создаю папку для шпор")
	createDirectory(dirml.."/MedicalHelper/шпаргалки/")
end
if not doesDirectoryExist(dirml.."/MedicalHelper/госновости/") then
	print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создаю папку для гос. новостей")
	createDirectory(dirml.."/MedicalHelper/госновости/")
end
if doesDirectoryExist(dirml.."/MedicalHelper/госновости/") then
	getGovFile()
end
	local function check_table(arg, table, mode)
		if mode == 1 then
			for k, v in pairs(table) do
				if k == arg then
					return true
				end
			end
		else
			for k, v in pairs(table) do
				if v == arg then
					return true
				end
			end
		end
		return false
	end
	if doesFileExist(dirml.."/MedicalHelper/шпаргалки.med") then
		os.remove(dirml.."/MedicalHelper/шпаргалки.med")
	end
	if doesFileExist(dirml.."/MedicalHelper/госновости.med") then
		print("{82E28C}...")
		local f = io.open(dirml.."/MedicalHelper/госновости.med")
		local setf = f:read("*a")
		f:close()
		local res, sets = pcall(decodeJson, setf)
		if res and type(sets) == "table" then 
			acting = sets
		else
			os.remove(dirml.."/MedicalHelper/госновости.med")
			print("{F54A4A}..")
			print("{82E28C}...")
			local f = io.open(dirml.."/MedicalHelper/госновости.med", "w")
			f:write(encodeJson(acting))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Отсутствует файл. {82E28C}Создаю файл...")
		if not doesFileExist(dirml.."/MedicalHelper/госновости.med") then
			local f = io.open(dirml.."/MedicalHelper/госновости.med", "w")
			f:write(encodeJson(acting))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/шпаргалки.med") then
		print("{82E28C}...")
		local f = io.open(dirml.."/MedicalHelper/шпаргалки.med")
		local setf = f:read("*a")
		f:close()
		local res, sets = pcall(decodeJson, setf)
		if res and type(sets) == "table" then 
			save_tracks = sets
			if save_tracks.link[1] ~= nil then
				for i = 1, #save_tracks.link do
					if save_tracks.link[i]:find('ru.hitmotop.com') then
						save_tracks.link[i] = save_tracks.link[i]:gsub('ru%.hitmotop%.com', 'ru%.apporange%.space')
						save_tracks.image[i] = save_tracks.image[i]:gsub('ru%.hitmotop%.com', 'ru%.apporange%.space')
					end
					if save_tracks.link[i]:find('rur.hitmotop.com') then
						save_tracks.link[i] = save_tracks.link[i]:gsub('rur%.hitmotop%.com', 'ru%.apporange%.space')
						save_tracks.image[i] = save_tracks.image[i]:gsub('rur%.hitmotop%.com', 'ru%.apporange%.space')
					end
				end
			end
			local f = io.open(dirml.."/MedicalHelper/шпаргалки.med", "w")
			f:write(encodeJson(save_tracks))
			f:flush()
			f:close()
		else
			os.remove(dirml.."/MedicalHelper/шпаргалки.med")
			print("{F54A4A}Ошибка. Файл поврежден. {82E28C}Создаю новый файл...")
			local f = io.open(dirml.."/MedicalHelper/шпаргалки.med", "w")
			f:write(encodeJson(save_tracks))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Отсутствует файл. {82E28C}Создаю файл...")
		print("{82E28C}...")
		if not doesFileExist(dirml.."/MedicalHelper/шпаргалки.med") then
			local f = io.open(dirml.."/MedicalHelper/шпаргалки.med", "w")
			f:write(encodeJson(save_tracks))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/depsetting.med") then
		local f = io.open(dirml.."/MedicalHelper/depsetting.med")
		local setf = f:read("*a")
		f:close()
		local res, setdept = pcall(decodeJson, setf)
		if res and type(setdept) == "table" then 
			setdepteg.tegtext_one = setdept.tegtext_one
			setdepteg.tegtext_two = setdept.tegtext_two
			setdepteg.tegtext_three = setdept.tegtext_three
			setdepteg.tegpref_one = setdept.tegpref_one
			setdepteg.tegpref_two = setdept.tegpref_two
			setdepteg.prefix = setdept.prefix
		else
			os.remove(dirml.."/MedicalHelper/depsetting.med")
			print("{F54A4A}Ошибка. Файл поврежден. {82E28C}Создаю новый файл...")
			local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
			f:write(encodeJson(setdepteg))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Отсутствует файл. {82E28C}Создаю файл...")
		print("{82E28C}...")
		if not doesFileExist(dirml.."/MedicalHelper/depsetting.med") then
			local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
			f:write(encodeJson(setdepteg))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/MainSetting_2.med") then
	print("{82E28C}Загрузка настроек версии 2...")
	local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med")
	local setf = f:read("*a")
	f:close()
	local res, set2 = pcall(decodeJson, setf)
	if res and type(set2) == "table" then 
		setting2 = set2
		chg_funcPKM.func.v = set2.funcPKM.func
		for i = 1, #set2.funcPKM.slider do
			chg_funcPKM.slider[i] = imgui.ImInt(0)
			chg_funcPKM.slider[i].v = set2.funcPKM.slider[i]
		end
	else
		os.remove(dirml.."/MedicalHelper/MainSetting_2.med")
		print("{F54A4A}Ошибка. Файл настроек версии 2 поврежден.")
		print("{82E28C}Восстанавливаю файл настроек версии 2...")
		local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med", "w")
		f:write(encodeJson(setting2))
		f:flush()
		f:close()
	end
else
	print("{F54A4A}Ошибка. Файл настроек версии 2 не найден.")
	print("{82E28C}Создаю файл настроек версии 2...")
	if not doesFileExist(dirml.."/MedicalHelper/MainSetting_2.med") then
		local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med", "w")
		f:write(encodeJson(setting2))
		f:flush()
		f:close()
	end
end
col_interface = convert_color(setting2.color_int)
if doesFileExist(dirml.."/MedicalHelper/MainMembers.med") then
	print("{82E28C}Загрузка настроек участников...")
	local f = io.open(dirml.."/MedicalHelper/MainMembers.med")
	local setm = f:read("*a")
	f:close()
	local res, setmemb = pcall(decodeJson, setm)
	if res and type(setmemb) == "table" then 
		membScr = setmemb
	else
		os.remove(dirml.."/MedicalHelper/MainMembers.med")
		print("{F54A4A}Ошибка. Файл настроек участников поврежден.")
		print("{82E28C}Восстанавливаю файл настроек участников...")
		local f = io.open(dirml.."/MedicalHelper/MainMembers.med", "w")
		f:write(encodeJson(membScr))
		f:flush()
		f:close()
	end
else
	print("{F54A4A}Ошибка. Файл настроек участников не найден.")
	print("{82E28C}Создаю файл настроек участников...")
	if not doesFileExist(dirml.."/MedicalHelper/MainMembers.med") then
		local f = io.open(dirml.."/MedicalHelper/MainMembers.med", "w")
		f:write(encodeJson(membScr))
		f:flush()
		f:close()
	end
end
	C_membScr = {
		func = imgui.ImBool(membScr.func),
		pos = {x = imgui.ImInt(membScr.pos.x), y = imgui.ImInt(membScr.pos.y)},
		forma = imgui.ImBool(membScr.forma),
		numrank = imgui.ImBool(membScr.numrank),
		id = imgui.ImBool(membScr.id),
		afk = imgui.ImBool(membScr.afk),
		dialog = imgui.ImBool(membScr.dialog),
		vergor = imgui.ImBool(membScr.vergor),
		font = {
			size = imgui.ImFloat(membScr.font.size),
			flag = imgui.ImFloat(membScr.font.flag),
			distance = imgui.ImFloat(membScr.font.distance),
			visible = imgui.ImFloat(membScr.font.visible)
		},
		color = {
			col_title 	= membScr.color.col_title,
			col_default = membScr.color.col_default,
			col_no_work = membScr.color.col_no_work
		}
	}
	fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
	col = {
		title = convert_color(membScr.color.col_title),
		default = convert_color(membScr.color.col_default),
		no_work = convert_color(membScr.color.col_no_work)
	}
	profit_money = {
		payday = {0, 0, 0, 0, 0, 0, 0},
		lec = {0, 0, 0, 0, 0, 0, 0},
		medcard = {0, 0, 0, 0, 0, 0, 0},
		narko = {0, 0, 0, 0, 0, 0, 0},
		vac = {0, 0, 0, 0, 0, 0, 0},
		ant = {0, 0, 0, 0, 0, 0, 0},
		rec = {0, 0, 0, 0, 0, 0, 0},
		medcam = {0, 0, 0, 0, 0, 0, 0},
		cure = {0, 0, 0, 0, 0, 0, 0},
		strah = {0, 0, 0, 0, 0, 0, 0},
		tatu = {0, 0, 0, 0, 0, 0, 0},
		premium = {0, 0, 0, 0, 0, 0, 0},
		other = {0, 0, 0, 0, 0, 0, 0},
		total_week = 0,
		total_all = 0,
		date_num = {0, 0},
		date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
		date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
		date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""}
	}
	if doesFileExist(dirml.."/MedicalHelper/profit.med") then
		print("{82E28C}Загрузка данных о прибыли...")
		local f = io.open(dirml.."/MedicalHelper/profit.med")
		local setp = f:read("*a")
		f:close()
		local res, setprofit = pcall(decodeJson, setp)
		if res and type(setprofit) == "table" then 
			profit_money = setprofit 
			profit_money.date_today[1] = os.date("%d") + 0
			profit_money.date_today[2] = os.date("%m") + 0
			profit_money.date_today[3] = os.date("%Y") + 0
			if profit_money.date_today[1] ~= profit_money.date_last[1] or profit_money.date_today[2] ~= profit_money.date_last[2] or profit_money.date_today[3] ~= profit_money.date_last[3] then
				profit_money.date_num[1] = profit_money.date_num[1] + 1
			end
			if profit_money.date_num[1] > profit_money.date_num[2] then
				profit_money.date_last[1] = os.date("%d") + 0
				profit_money.date_last[2] = os.date("%m") + 0
				profit_money.date_last[3] = os.date("%Y") + 0
				profit_money.date_num[2] = profit_money.date_num[1]
				profit_money.date_week[1], profit_money.date_week[2], profit_money.date_week[3], profit_money.date_week[4], profit_money.date_week[5], profit_money.date_week[6], profit_money.date_week[7] = os.date("%d.%m.%Y"), setprofit.date_week[1], setprofit.date_week[2], setprofit.date_week[3], setprofit.date_week[4], setprofit.date_week[5], setprofit.date_week[6]
				profit_money.payday[1], profit_money.payday[2], profit_money.payday[3], profit_money.payday[4], profit_money.payday[5], profit_money.payday[6], profit_money.payday[7] = 		 			  0, setprofit.payday[1], setprofit.payday[2], setprofit.payday[3], setprofit.payday[4], setprofit.payday[5], setprofit.payday[6]
				profit_money.lec[1], profit_money.lec[2], profit_money.lec[3], profit_money.lec[4], profit_money.lec[5], profit_money.lec[6], profit_money.lec[7] = 										  0, setprofit.lec[1], setprofit.lec[2], setprofit.lec[3], setprofit.lec[4], setprofit.lec[5], setprofit.lec[6]
				profit_money.medcard[1], profit_money.medcard[2], profit_money.medcard[3], profit_money.medcard[4], profit_money.medcard[5], profit_money.medcard[6], profit_money.medcard[7] = 			  0, setprofit.medcard[1], setprofit.medcard[2], setprofit.medcard[3], setprofit.medcard[4], setprofit.medcard[5], setprofit.medcard[6]
				profit_money.narko[1], profit_money.narko[2], profit_money.narko[3], profit_money.narko[4], profit_money.narko[5], profit_money.narko[6], profit_money.narko[7] = 				 			  0, setprofit.narko[1], setprofit.narko[2], setprofit.narko[3], setprofit.narko[4], setprofit.narko[5], setprofit.narko[6]
				profit_money.vac[1], profit_money.vac[2], profit_money.vac[3], profit_money.vac[4], profit_money.vac[5], profit_money.vac[6], profit_money.vac[7] = 										  0, setprofit.vac[1], setprofit.vac[2], setprofit.vac[3], setprofit.vac[4], setprofit.vac[5], setprofit.vac[6]
				profit_money.ant[1], profit_money.ant[2], profit_money.ant[3], profit_money.ant[4], profit_money.ant[5], profit_money.ant[6], profit_money.ant[7] = 										  0, setprofit.ant[1], setprofit.ant[2], setprofit.ant[3], setprofit.ant[4], setprofit.ant[5], setprofit.ant[6]
				profit_money.rec[1], profit_money.rec[2], profit_money.rec[3], profit_money.rec[4], profit_money.rec[5], profit_money.rec[6], profit_money.rec[7] = 										  0, setprofit.rec[1], setprofit.rec[2], setprofit.rec[3], setprofit.rec[4], setprofit.rec[5], setprofit.rec[6]
				profit_money.medcam[1], profit_money.medcam[2], profit_money.medcam[3], profit_money.medcam[4], profit_money.medcam[5], profit_money.medcam[6], profit_money.medcam[7] = 		 			  0, setprofit.medcam[1], setprofit.medcam[2], setprofit.medcam[3], setprofit.medcam[4], setprofit.medcam[5], setprofit.medcam[6]
				profit_money.cure[1], profit_money.cure[2], profit_money.cure[3], profit_money.cure[4], profit_money.cure[5], profit_money.cure[6], profit_money.cure[7] = 								   	  0, setprofit.cure[1], setprofit.cure[2], setprofit.cure[3], setprofit.cure[4], setprofit.cure[5], setprofit.cure[6]
				profit_money.strah[1], profit_money.strah[2], profit_money.strah[3], profit_money.strah[4], profit_money.strah[5], profit_money.strah[6], profit_money.strah[7] = 							  0, setprofit.strah[1], setprofit.strah[2], setprofit.strah[3], setprofit.strah[4], setprofit.strah[5], setprofit.strah[6]
				profit_money.tatu[1], profit_money.tatu[2], profit_money.tatu[3], profit_money.tatu[4], profit_money.tatu[5], profit_money.tatu[6], profit_money.tatu[7] = 								  	  0, setprofit.tatu[1], setprofit.tatu[2], setprofit.tatu[3], setprofit.tatu[4], setprofit.tatu[5], setprofit.tatu[6]
				profit_money.premium[1], profit_money.premium[2], profit_money.premium[3], profit_money.premium[4], profit_money.premium[5], profit_money.premium[6], profit_money.premium[7] =			  	  0, setprofit.premium[1], setprofit.premium[2], setprofit.premium[3], setprofit.premium[4], setprofit.premium[5], setprofit.premium[6]
				profit_money.other[1], profit_money.other[2], profit_money.other[3], profit_money.other[4], profit_money.other[5], profit_money.other[6], profit_money.other[7] = 				 			  0, setprofit.other[1], setprofit.other[2], setprofit.other[3], setprofit.other[4], setprofit.other[5], setprofit.other[6]
			end
				profit_money.total_week = profit_money.payday[1] + profit_money.payday[2] + profit_money.payday[3] + profit_money.payday[4] + profit_money.payday[5] + profit_money.payday[6] + profit_money.payday[7] +
				profit_money.lec[1] + profit_money.lec[2] + profit_money.lec[3] + profit_money.lec[4] + profit_money.lec[5] + profit_money.lec[6] + profit_money.lec[7] +
				profit_money.medcard[1] + profit_money.medcard[2] + profit_money.medcard[3] + profit_money.medcard[4] + profit_money.medcard[5] + profit_money.medcard[6] + profit_money.medcard[7] +
				profit_money.narko[1] + profit_money.narko[2] + profit_money.narko[3] + profit_money.narko[4] + profit_money.narko[5] + profit_money.narko[6] + profit_money.narko[7] +
				profit_money.vac[1] + profit_money.vac[2] + profit_money.vac[3] + profit_money.vac[4] + profit_money.vac[5] + profit_money.vac[6] + profit_money.vac[7] +
				profit_money.ant[1] + profit_money.ant[2] + profit_money.ant[3] + profit_money.ant[4] + profit_money.ant[5] + profit_money.ant[6] + profit_money.ant[7] +
				profit_money.rec[1] + profit_money.rec[2] + profit_money.rec[3] + profit_money.rec[4] + profit_money.rec[5] + profit_money.rec[6] + profit_money.rec[7] +
				profit_money.medcam[1] + profit_money.medcam[2] + profit_money.medcam[3] + profit_money.medcam[4] + profit_money.medcam[5] + profit_money.medcam[6] + profit_money.medcam[7] +
				profit_money.cure[1] + profit_money.cure[2] + profit_money.cure[3] + profit_money.cure[4] + profit_money.cure[5] + profit_money.cure[6] + profit_money.cure[7] +
				profit_money.strah[1] + profit_money.strah[2] + profit_money.strah[3] + profit_money.strah[4] + profit_money.strah[5] + profit_money.strah[6] + profit_money.strah[7] +
				profit_money.tatu[1] + profit_money.tatu[2] + profit_money.tatu[3] + profit_money.tatu[4] + profit_money.tatu[5] + profit_money.tatu[6] + profit_money.tatu[7] +
				profit_money.premium[1] + profit_money.premium[2] + profit_money.premium[3] + profit_money.premium[4] + profit_money.premium[5] + profit_money.premium[6] + profit_money.premium[7] +
				profit_money.other[1] + profit_money.other[2] + profit_money.other[3] + profit_money.other[4] + profit_money.other[5] + profit_money.other[6] + profit_money.other[7]
				local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
				f:write(encodeJson(profit_money))
				f:flush()
				f:close()
		else
			os.remove(dirml.."/MedicalHelper/profit.med")
			print("{F54A4A}Ошибка. Файл данных о прибыли поврежден.")
			print("{82E28C}Восстанавливаю файл данных о прибыли...")
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл данных о прибыли .")
		print("{82E28C}...")
		if not doesFileExist(dirml.."/MedicalHelper/profit.med") then
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/onlinestat.med") then
		print("{82E28C}Загрузка данных о онлайн статусе...")
		local f = io.open(dirml.."/MedicalHelper/onlinestat.med")
		local seton = f:read("*a")
		f:close()
		local res, setonline = pcall(decodeJson, seton)
		if res and type(setonline) == "table" then 
			online_stat = setonline 
			online_stat.date_today[1] = os.date("%d") + 0
			online_stat.date_today[2] = os.date("%m") + 0
			online_stat.date_today[3] = os.date("%Y") + 0
			if online_stat.date_today[1] ~= online_stat.date_last[1] or online_stat.date_today[2] ~= online_stat.date_last[2] or online_stat.date_today[3] ~= online_stat.date_last[3] then
				online_stat.date_num[1] = online_stat.date_num[1] + 1
			end
			if online_stat.date_num[1] > online_stat.date_num[2] then
				online_stat.date_last[1] = os.date("%d") + 0
				online_stat.date_last[2] = os.date("%m") + 0
				online_stat.date_last[3] = os.date("%Y") + 0
				online_stat.date_num[2] = online_stat.date_num[1]
				online_stat.date_week[1], online_stat.date_week[2], online_stat.date_week[3], online_stat.date_week[4], online_stat.date_week[5], online_stat.date_week[6], online_stat.date_week[7] = os.date("%d.%m.%Y"), setonline.date_week[1], setonline.date_week[2], setonline.date_week[3], setonline.date_week[4], setonline.date_week[5], setonline.date_week[6]
				online_stat.clean[1], online_stat.clean[2], online_stat.clean[3], online_stat.clean[4], online_stat.clean[5], online_stat.clean[6], online_stat.clean[7] = 		 			  0, setonline.clean[1], setonline.clean[2], setonline.clean[3], setonline.clean[4], setonline.clean[5], setonline.clean[6]
				online_stat.afk[1], online_stat.afk[2], online_stat.afk[3], online_stat.afk[4], online_stat.afk[5], online_stat.afk[6], online_stat.afk[7] = 										  0, setonline.afk[1], setonline.afk[2], setonline.afk[3], setonline.afk[4], setonline.afk[5], setonline.afk[6]
				online_stat.all[1], online_stat.all[2], online_stat.all[3], online_stat.all[4], online_stat.all[5], online_stat.all[6], online_stat.all[7] = 										  0, setonline.all[1], setonline.all[2], setonline.all[3], setonline.all[4], setonline.all[5], setonline.all[6]
			end
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
		else
			os.remove(dirml.."/MedicalHelper/onlinestat.med")
			print("{F54A4A}Ошибка. Файл данных о онлайн статусе поврежден.")
			print("{82E28C}Восстанавливаю файл данных о онлайн статусе...")
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл данных о онлайн статусе не найден.")
		print("{82E28C}Создаю новый файл данных о онлайн статусе...")
		if not doesFileExist(dirml.."/MedicalHelper/onlinestat.med") then
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
		end
	end
	
	if doesFileExist(dirml.."/MedicalHelper/reminders.med") then
		print("{82E28C}Загрузка данных о напоминаниях...")
		local f = io.open(dirml.."/MedicalHelper/reminders.med")
		local seton = f:read("*a")
		f:close()
		local res, setreminer = pcall(decodeJson, seton)
		if res and type(setreminer) == "table" then 
			reminder = setreminer
		else
			os.remove(dirml.."/MedicalHelper/reminders.med")
			print("{F54A4A}Ошибка. Файл данных о напоминаниях поврежден.")
			print("{82E28C}Восстанавливаю файл данных о напоминаниях...")
			local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
			f:write(encodeJson(reminder))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл данных о напоминаниях не найден.")
		print("{82E28C}Создаю новый файл данных о напоминаниях...")
		if not doesFileExist(dirml.."/MedicalHelper/reminders.med") then
			local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
			f:write(encodeJson(reminder))
			f:flush()
			f:close()
		end
	end
	
	local function settingMassiveStart()
		setting.nick = u8:decode(buf_nick.v)
		setting.teg = u8:decode(buf_teg.v)
		setting.org = num_org.v
		setting.sex = num_sex.v
		setting.rank = num_rank.v
		setting.time = cb_time.v
		setting.timeTx = u8:decode(buf_time.v)
		setting.timeDo = cb_timeDo.v
		setting.rac = cb_rac.v
		setting.racTx = u8:decode(buf_rac.v)
		setting.lec = buf_lec.v
		setting.rec = buf_rec.v
		setting.narko = buf_narko.v
		setting.tatu = buf_tatu.v
		setting.ant = buf_ant.v
		setting.chat1 = cb_chat1.v
		setting.chat2 = cb_chat2.v
		setting.chat3 = cb_chat3.v
		setting.chathud = cb_hud.v
		setting.arp = arep
		setting.setver = setver
		setting.htime = cb_hudTime.v
		setting.hping = hudPing
		setting.orgl = {}
		setting.rankl = {}
		setting.theme = num_theme.v
	end
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = sampGetPlayerNickname(myid)
	mynickname = trst(myNick)
	if doesFileExist(dirml.."/MedicalHelper/MainSetting.med") then
		print("{82E28C}Загрузка данных о главных настройках...")
		local f = io.open(dirml.."/MedicalHelper/MainSetting.med")
		local setf = f:read("*a")
		f:close()
		local res, set = pcall(decodeJson, setf)
		if res and type(set) == "table" then 
			buf_nick.v = u8(set.nick)
			buf_teg.v = u8(set.teg)
			num_org.v = set.org
			num_sex.v = set.sex
			num_rank.v = set.rank
			cb_time.v = set.time
			buf_time.v = u8(set.timeTx)
			cb_timeDo.v = set.timeDo
			cb_rac.v = set.rac
			buf_rac.v = u8(set.racTx)
			buf_lec.v = u8(set.lec)
			buf_rec.v = u8(set.rec)
			buf_narko.v = u8(set.narko)
			buf_tatu.v = u8(set.tatu)
			buf_ant.v = u8(set.ant)
			cb_chat1.v = set.chat1
			cb_chat2.v = set.chat2
			cb_chat3.v = set.chat3
			cb_hud.v = set.chathud
			arep = set.arp
			setver = set.setver
			hudPing = set.hping
			cb_hudTime.v = set.htime
			if check_table('theme', set, 1) then
				num_theme.v = set.theme
				num_themeTest = set.theme
			else
				settingMassiveStart()
				local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
				f:write(encodeJson(setting))
				f:flush()
				f:close()
			end
			if check_table('mede', set, 1) then
				for i = 1, 4 do
					buf_mede[i].v = u8(set.mede[i])
					buf_upmede[i].v = u8(set.upmede[i])
				end
				accept_spawn.v = set.spawn
				accept_autolec.v = set.autolec
				prikol.v = set.prikol
			else
				settingMassiveStart()
				for i = 1, 4 do
					setting.mede[i] = buf_mede[i].v
					setting.upmede[i] = buf_upmede[i].v
				end
				setting.spawn = accept_spawn.v
				setting.autolec = accept_autolec.v
				setting.prikol = prikol.v
				local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
				f:write(encodeJson(setting))
				f:flush()
				f:close()
			end
			if set.orgl then
				for i,v in ipairs(set.orgl) do
					chgName.org[tonumber(i)] = u8(v)
				end
			end
			if set.rankl then
				for i,v in ipairs(set.rankl) do
					chgName.rank[tonumber(i)] = u8(v)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/MainSetting.med")
			print("{F54A4A}Ошибка. Файл данных о главных настройках поврежден.")
			print("{82E28C}Восстанавливаю файл данных о главных настройках...")
			buf_nick.v = u8(mynickname)
			buf_lec.v = "10000"
			buf_mede[1].v = "20000"
			buf_mede[2].v = "40000"
			buf_mede[3].v = "60000"
			buf_mede[4].v = "80000"
			buf_upmede[1].v = "40000"
			buf_upmede[2].v = "60000"
			buf_upmede[3].v = "80000"
			buf_upmede[4].v = "100000"
			buf_narko.v = "100000"
			buf_tatu.v = "50000"
			buf_rec.v = "30000"
			buf_ant.v = "25000"
			num_theme.v = 0
			buf_time.v = u8"/me посмотрел на часы и пробормотал \"Made in China\""
			buf_rac.v = u8"/me поднял руки вверх, что-то шепчет и улыбается"
		end
	else
		print("{F54A4A}Ошибка. Файл данных о главных настройках не найден.")
		print("{82E28C}Создаю новый файл данных о главных настройках...")
		buf_nick.v = u8(mynickname)
		buf_lec.v = "10000"
		buf_mede[1].v = "20000"
		buf_mede[2].v = "40000"
		buf_mede[3].v = "60000"
		buf_mede[4].v = "80000"
		buf_upmede[1].v = "40000"
		buf_upmede[2].v = "60000"
		buf_upmede[3].v = "80000"
		buf_upmede[4].v = "100000"
		buf_narko.v = "100000"
		buf_tatu.v = "50000"
		buf_rec.v = "30000"
		buf_ant.v = "25000"
		num_theme.v = 0
		buf_time.v = u8"/me посмотрел на часы и пробормотал \"Много времени...\""
		buf_rac.v = u8"/me поднял руки вверх, что-то шепчет и улыбается"	
	end
	print("{82E28C}Загрузка данных о командах...")
	if doesFileExist(dirml.."/MedicalHelper/cmdSetting.med") then
		local f = io.open(dirml.."/MedicalHelper/cmdSetting.med")
		local res, keys = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(keys) == "table" then
			for i, v in ipairs(keys) do
				cmdBind[i].cmd = v.cmd
				if #v.key > 0 then
					rkeys.registerHotKey(v.key, true, onHotKeyCMD)
					cmdBind[i].key = v.key
					table.insert(keysList, v.key)
				end
			end
		else
			print("{82E28C}Ошибка. Файл данных о командах поврежден.")
			os.remove(dirml.."/MedicalHelper/cmdSetting.med")
		end
	end
	print("{82E28C}Загрузка данных о привязках...")
	if doesFileExist(dirml.."/MedicalHelper/bindSetting.med") then
		local f = io.open(dirml.."/MedicalHelper/bindSetting.med")
		local res, list = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(list) == "table" then
			binder.list = list
			for i, v in ipairs(binder.list) do
				if #v.key > 0 then
					binder.list[i].key = v.key
					rkeys.registerHotKey(v.key, true, onHotKeyBIND)
					table.insert(keysList, v.key)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/bindSetting.med")
			print("{F54A4A}Ошибка. Файл данных о привязках поврежден.")
			print("{82E28C}Восстанавливаю файл данных о привязках...")
		end
	else 
		print("{82E28C}Загрузка данных о привязках...")
	end
	lockPlayerControl(false)
	sampfuncsRegisterConsoleCommand("arep", function(bool) 
		if tonumber(bool) == 1 then 
			arep = true 
		else 
			arep = false 
		end 
	end)
	function styleWin()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		local ImVec4Choice = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], col_interface.v[4])
		style.WindowRounding = 15.0
		style.ChildWindowRounding = 10.0
		style.FrameRounding = 8.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ScrollbarSize = 15.0
		style.FramePadding = imgui.ImVec2(5, 3)
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarRounding = 0
		style.GrabMinSize = 18.0
		style.GrabRounding = 4.0
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		
		colors[clr.FrameBg] 			   = ImVec4(0.35, 0.35, 0.35, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.55, 0.55, 0.55, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.30, 0.30, 0.30, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 0.50)
		colors[clr.TitleBgActive]          = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.90)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.50)
		colors[clr.CheckMark]              = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.90) --!!
		colors[clr.SliderGrab]             = ImVec4Choice
		colors[clr.SliderGrabActive]       = ImVec4Choice
		colors[clr.Button]                 = imgui.ImVec4(1.00, 1.00, 1.00, 0.23)
		colors[clr.ButtonHovered]          = imgui.ImVec4(1.00, 1.00, 1.00, 0.31)
		colors[clr.ButtonActive]           = imgui.ImVec4(1.00, 1.00, 1.00, 0.12)
		colors[clr.Header]                 = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.65)
		colors[clr.HeaderHovered]          = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.80)
		colors[clr.HeaderActive]           = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.90)
		colors[clr.Separator]              = imgui.ImVec4(0.37, 0.37, 0.37, 0.60)
		colors[clr.SeparatorHovered]       = imgui.ImVec4(0.37, 0.37, 0.37, 0.60)
		colors[clr.SeparatorActive]        = imgui.ImVec4(0.37, 0.37, 0.37, 0.60)
		colors[clr.ResizeGrip]             = ImVec4Choice
		colors[clr.ResizeGripHovered]      = ImVec4Choice
		colors[clr.ResizeGripActive]       = ImVec4Choice
		colors[clr.TextSelectedBg]         = ImVec4Choice
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]                 = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.50)
		colors[clr.BorderShadow]           = ImVec4(0.26, 0.59, 0.98, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	
		colBut = colors[clr.Button]
		colButActive = colors[clr.ButtonActive]
		colButActiveMenu = imgui.ImColor(col_interface.v[1]*255, col_interface.v[2]*255, col_interface.v[3]*255, 204):GetVec4()
		ButtonNoAct = imgui.ImColor(20, 20, 20, 220):GetVec4()
		colors[clr.Border] = colBut
	end
	styleWin()
	sampRegCMDLoadScript()
	repeat wait(100) until sampIsLocalPlayerSpawned()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = getPlayerNickName(myid) 
	sampAddChatMessage(string.format("{FF8FA2}[Medical Helper]{FFFFFF} %s, ты запустил этот скрипт, напиши в чат {a8a8a8}/"..cmdBind[1].cmd, getPlayerNickName(myid):gsub("_"," ")), 0xFF8FA2)
	wait(200)
	if buf_nick.v == "" then  
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Внимание, у вас не заполнено имя пользователя.", 0xFF8FA2)
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Зайдите в главное меню в раздел \"Настройки\" и укажите необходимые данные.", 0xFF8FA2)
	end
	lua_thread.create(time)
	lua_thread.create(saveCounOnl)
	lua_thread.create(membfunc)
	while true do wait(0)
		if sampIsDialogActive() then
    		lastDialogWasActive = os.clock()
    	end
		resTarg, pedTar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if resTarg then
			targID = nil
			_, targID = sampGetPlayerIdByCharHandle(pedTar)
			if setting2.funcPKM.func then
			renderFontDrawText(fontPD, "[{F25D33}Num 2{FFFFFF}] - вызвать меню с ID "..targID, sx-350, sy-30, 0xFFFFFFFF)
				if isKeyJustPressed(VK_R) then
					if #optionsPKM > 13 then
						for m = 14, #optionsPKM do
							table.remove(optionsPKM, 14)
						end
						for m = 1, #binder.list do
							optionsPKM[m + 13] = u8(binder.list[m].name)
						end
					else
						for m = 1, #binder.list do
							optionsPKM[m + 13] = u8(binder.list[m].name)
						end
					end
					choiceWin.v = true
					imgui.ShowCursor = true
					_, targetID = sampGetPlayerIdByCharHandle(pedTar)
				end
			end
			renderFontDrawText(fontPD, "[{F25D33}R{FFFFFF}] - выбрать действие с ID "..targID, sx-350, sy-60, 0xFFFFFFFF)
		end
	if status_track_pl ~= "STOP" and player_HUD.v then
		musicHUD.v = true
	else
		musicHUD.v = false
	end
	if not isGamePaused() and status_track_pl ~= 'STOP' then
		stalecatin()
	elseif isGamePaused() and status_track_pl == 'PLAY' then
		if get_status_potok_song() == 1 then
			bass.BASS_ChannelPause(stream_music)
		end
	end
	if vaccine_two then
		if vactimer[1] >= 0 and vactimer[2] >= 0 then
			if not isGamePaused() then
				local timervac = {string.len(tostring(vactimer[1])), string.len(tostring(vactimer[2]))}
				if timervac[1] == 1 then
					minutevac = "0"..vactimer[1]
				else
					minutevac = vactimer[1]
				end
				if timervac[2] == 1 then
					hourvac = "0"..vactimer[2]
				else
					hourvac = vactimer[2]
				end
				renderFontDrawText(fontPD, "{FFFFFF}Осталось времени:\n           {11B835}"..hourvac.."{FFFFFF}:{11B835}"..minutevac, sx-200, sy-60, 0xFFFFFFFF)
				renderFontDrawText(fontPD, "Отмена вакцинации: [{F25D33}Delete{FFFFFF}] - прервать", 20, sy-30, 0xFFFFFFFF)
			end
		else
			if not isGamePaused() then
				renderFontDrawText(fontPD, "  [{11B835}Num 1{FFFFFF}] - вызвать меню.\n [{F25D33}Delete{FFFFFF}] - отменить.", sx-300, sy-60, 0xFFFFFFFF)
			end
			if isKeyJustPressed(VK_1) then
				vaccine_two = false
				funCMD.vac(vaccine_id)
			end
		end
		if isKeyJustPressed(VK_DELETE) then
			vaccine_two = false
		end
	end
	if thread:status() ~= "dead" and not isGamePaused() then
		renderFontDrawText(fontPD, "Прерывание: [{F25D33}Page Down{FFFFFF}] - отменить", 20, sy-30, 0xFFFFFFFF)
		if isKeyJustPressed(VK_NEXT) and not sampIsChatInputActive() and not sampIsDialogActive() then
			thread:terminate()
			statusvac = false
		end
	end
	if sampIsDialogActive() then
		if arep then
			local idD = sampGetCurrentDialogId()
			if idD == 1333 then
				HideDialog()
			lockPlayerControl(false)
			end
		end
	end
	if cb_hud.v then showInputHelp() end
	if cb_hudTime.v and not isPauseMenuActive() then hudTimeF() end
	imgui.Process = mainWin.v or iconwin.v or sobWin.v or depWin.v or updWin.v or spurBig.v or choiceWin.v or musicHUD.v or ReminderWin.v
	if C_membScr.func.v and isCursorAvailable() and isKeyJustPressed(0xA5) then
    	script_cursor = not script_cursor
    	showCursor(script_cursor, false)
    end
	------------------------------------------------------------RNDER
	if C_membScr.func.v and not isGamePaused() and ((C_membScr.dialog.v and not sampIsDialogActive() and not sampIsCursorActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive()) or not C_membScr.dialog.v) then
	    	rendering_func()
		end
	------------------------------------------------------------RNDER
	end
end

function rendering_func()
	local X, Y = C_membScr.pos.x.v, C_membScr.pos.y.v
	local title = string.format('%s | Онлайн: %s%s', org.name, org.online, (C_membScr.afk.v and (' (%s в АФК)'):format(org.afk) or ''))
	local col_title = changeColorAlpha(C_membScr.color.col_title, C_membScr.font.visible.v)
	if C_membScr.vergor.v then
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - C_membScr.font.distance.v - 5, col_title, col_title, 4, false) then
			sampSendChat('/members')
		end
	else
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - C_membScr.font.distance.v - 5, col_title, col_title, 3, false) then
			sampSendChat('/members')
		end
	end
	if org.name == 'Вы не состоите в организации' then
		if C_membScr.vergor.v then
		renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
		renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF, 3, false)
		end
	elseif #members > 0 then
		for i, member in ipairs(members) do
			if i <= tonumber(org.online) then
				local color = changeColorAlpha(C_membScr.forma.v and (member.uniform and C_membScr.color.col_default or C_membScr.color.col_no_work) or C_membScr.color.col_default, C_membScr.font.visible.v)
				local rank = C_membScr.numrank.v and string.format('[%s]', member.rank.count) or nil
				local nick = member.nick .. (C_membScr.id.v and string.format('(%s)', member.id) or '')
				local afk = C_membScr.afk.v and string.format(' (AFK: %s)', member.afk) or ''
				local out_string
				if C_membScr.vergor.v then
					out_string = ('%s%s%s'):format(rank and rank .. ' ' or '', nick, afk)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color,  4, true) --C_membScr.vergor.v
				else
					out_string = ('%s%s%s'):format(rank and rank .. ' ' or '', nick, afk)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color,  3, true)
				end
				Y = Y + C_membScr.font.distance.v
			end
		end
	else
		if C_membScr.vergor.v then
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
		end
	end
end

function back_track()
	if menu_play_track[1] then
		if selectis > 1 and tracks.link[selectis] == url_track_pack then
			selectis = selectis - 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(tracks.link[selectis], false)
			download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif selectis == 1 or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis > 1 and save_tracks.link[selectis - 1] ~= nil then
			selectis = selectis - 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(save_tracks.link[selectis], false)
			download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif selectis == 1 or save_tracks.link[selectis - 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function next_track()
	if menu_play_track[1] then
		if selectis ~= 0 and selectis < #tracks.link and tracks.link[selectis] == url_track_pack then
			selectis = selectis + 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(tracks.link[selectis], false)
			download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif (selectis ~= 0 and selectis == #tracks.link) or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis ~= 0 and selectis < #save_tracks.link and save_tracks.link[selectis + 1] ~= nil then
			selectis = selectis + 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(save_tracks.link[selectis], false)
			download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif (selectis ~= 0 and selectis == #save_tracks.link) or save_tracks.link[selectis + 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function stalecatin()
	if get_status_potok_song() == 3 and status_track_pl == 'PLAY' then
		action_song('PLAY')
	elseif get_status_potok_song() == 0 and status_track_pl == 'PLAY' then
		if repeatmusic.v then
			play_song(url_track_pack, false)
		else
			next_track()
		end
	end
end

function Window_Reminder(param)
	if ReminderWin.v then ReminderWin.v = false end
	remin_text = param.text
	ReminderWin.v = true
	if param.sound then
		sound_reminder = lua_thread.create(function()
			local stap = 0
			while true do
				repeat wait(200) 
					addOneOffSound(0, 0, 0, 1057)
					stap = stap + 1
				until stap > 15
				wait(5000)
				stap = 0
			end
		end)
	end
end

local swx, shy = getScreenResolution()
local posWinStarted = {x = 1, y = 1}
local posWinClosed

local animka_main = {MoveAnim = false, paramOff = false, posX = 0, posY = 0}
local animka_dep = {MoveAnim = false, paramOff = false, posX = 0, posY = 0}
local animka_sob = {MoveAnim = false, paramOff = false, posX = 0, posY = 0}
local animka_upd = {MoveAnim = false, paramOff = false, posX = 0, posY = 0}
local animka_big = {MoveAnim = false, paramOff = false, posX = 0, posY = 0}

function styleAnimationOpen(idWin)
	local fps = mem.getfloat(0xB7CB50, true)
	local pert = 15
	if fps < 60 and fps >= 50 then
		pert = 20
	elseif fps < 50 and fps >= 40 then
		pert = 40
	elseif fps < 40 and fps >= 30 then
		pert = 70
	elseif fps < 30 then
		pert = 120
	end
	if idWin == 1 then
		animka_main.posY = shy / 2
		animka_main.posX = swx * 2
		
		lua_thread.create(function()
			animka_main.MoveAnim = true
			repeat wait(0)
				animka_main.posX = (animka_main.posX/1.04) - pert
				pert = pert
			until animka_main.posX < swx/2
			animka_main.MoveAnim = false
		end)
	end
	if idWin == 2 then
		animka_dep.posY = shy / 2
		animka_dep.posX = swx * 2
		lua_thread.create(function()
			animka_dep.MoveAnim = true
			repeat wait(0)
				animka_dep.posX = (animka_dep.posX/1.04) - pert
				pert = pert
			until animka_dep.posX < swx/2
			animka_dep.MoveAnim = false
		end)
	end
	if idWin == 3 then --> sobWin
		animka_sob.posY = shy / 2
		animka_sob.posX = swx * 2
		lua_thread.create(function()
			animka_sob.MoveAnim = true
			repeat wait(0)
				animka_sob.posX = (animka_sob.posX/1.04) - pert
				pert = pert
			until animka_sob.posX < swx/2
			animka_sob.MoveAnim = false
		end)
	end
	if idWin == 4 then
		animka_upd.posY = shy / 2
		animka_upd.posX = swx * 2
		lua_thread.create(function()
			animka_upd.MoveAnim = true
			repeat wait(0)
				animka_upd.posX = (animka_upd.posX/1.04) - pert
				pert = pert
			until animka_upd.posX < swx/2
			animka_upd.MoveAnim = false
		end)
	end
	if idWin == 5 then
		animka_big.posY = shy / 2
		animka_big.posX = swx * 2
		lua_thread.create(function()
			animka_big.MoveAnim = true
			repeat wait(0)
				animka_big.posX = (animka_big.posX/1.04) - pert
				pert = pert
			until animka_big.posX < swx/2
			animka_big.MoveAnim = false
		end)
	end
	imgui.ShowCursor = true
end

function styleAnimationClose(idWin, xWin, yWin)
	local fps = mem.getfloat(0xB7CB50, true)
	local pert = 18
	if fps < 60 and fps >= 50 then
		pert = 20
	elseif fps < 50 and fps >= 40 then
		pert = 40
	elseif fps < 40 and fps >= 30 then
		pert = 70
	elseif fps < 30 then
		pert = 120
	end
	if idWin == 1 then
		if not depWin.v and not iconwin.v and not sobWin.v and not updWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_main.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_main.posX = xWin/2
		else
			animka_main.posX = xWin/2
		end
		lua_thread.create(function()
			animka_main.MoveAnim = true
			repeat wait(0)
				animka_main.posX = (animka_main.posX*1.04) + pert
				pert = pert
			until animka_main.posX > swx + xWin
			mainWin.v = false
			animka_main.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 2 then
		if not mainWin.v and not iconwin.v and not sobWin.v and not updWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_dep.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_dep.posX = posWinClosed.x + (xWin/2)
		else
			animka_main.posX = xWin/2
		end
		lua_thread.create(function()
			animka_dep.MoveAnim = true
			repeat wait(0)
				animka_dep.posX = (animka_dep.posX*1.04) + pert
				pert = pert
			until animka_dep.posX > swx + xWin
			depWin.v = false
			animka_dep.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 3 then
		if not mainWin.v and not iconwin.v and not depWin.v and not updWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_sob.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_sob.posX = posWinClosed.x + (xWin/2)
		else
		    animka_main.posX = xWin/2
		end
		lua_thread.create(function()
			animka_sob.MoveAnim = true
			repeat wait(0)
				animka_sob.posX = (animka_sob.posX*1.04) + pert
				pert = pert
			until animka_sob.posX > swx + xWin
			sobWin.v = false
			animka_sob.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 4 then
		if not mainWin.v and not iconwin.v and not depWin.v and not sobWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_upd.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_upd.posX = posWinClosed.x + (xWin/2)
		else
		    animka_main.posX = xWin/2
		end
		lua_thread.create(function()
			animka_upd.MoveAnim = true
			repeat wait(0)
				animka_upd.posX = (animka_upd.posX*1.04) + pert
				pert = pert
			until animka_upd.posX > swx + xWin
			updWin.v = false
			animka_upd.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 5 then
		if not mainWin.v and not iconwin.v and not depWin.v and not sobWin.v and not updWin.v then
			imgui.ShowCursor = false
		end
		animka_big.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_big.posX = posWinClosed.x + (xWin/2)
		else
		    animka_main.posX = xWin/2
		end
		lua_thread.create(function()
			animka_big.MoveAnim = true
			repeat wait(0)
				animka_big.posX = (animka_big.posX*1.04) + pert
				pert = pert
			until animka_big.posX > swx + xWin
			spurBig.v = false
			animka_big.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
end

function sampRegCMDLoadScript()
	sampRegisterChatCommand(cmdBind[1].cmd, function()
		if not mainWin.v then
			styleAnimationOpen(1)
			mainWin.v = true
		else
			animka_main.paramOff = true
		end
	end)
	sampRegisterChatCommand(cmdBind[4].cmd, funCMD.memb)
	sampRegisterChatCommand(cmdBind[5].cmd, funCMD.lec)
	sampRegisterChatCommand(cmdBind[6].cmd, funCMD.post)
	sampRegisterChatCommand(cmdBind[7].cmd, funCMD.med)
	sampRegisterChatCommand(cmdBind[8].cmd, funCMD.narko)
	sampRegisterChatCommand(cmdBind[9].cmd, funCMD.recep)
	sampRegisterChatCommand(cmdBind[10].cmd, funCMD.osm)
	sampRegisterChatCommand(cmdBind[11].cmd, funCMD.dep)
	sampRegisterChatCommand(cmdBind[12].cmd, funCMD.sob)
	sampRegisterChatCommand(cmdBind[13].cmd, funCMD.tatu)
	sampRegisterChatCommand(cmdBind[14].cmd, funCMD.warn)
	sampRegisterChatCommand(cmdBind[15].cmd, funCMD.uwarn)
	sampRegisterChatCommand(cmdBind[16].cmd, funCMD.mute)
	sampRegisterChatCommand(cmdBind[17].cmd, funCMD.umute)
	sampRegisterChatCommand(cmdBind[18].cmd, funCMD.rank)
	sampRegisterChatCommand(cmdBind[19].cmd, funCMD.inv)
	sampRegisterChatCommand(cmdBind[20].cmd, funCMD.unv)
	sampRegisterChatCommand(cmdBind[22].cmd, funCMD.expel)
	sampRegisterChatCommand(cmdBind[23].cmd, funCMD.vac)
	sampRegisterChatCommand(cmdBind[24].cmd, funCMD.info)
	sampRegisterChatCommand(cmdBind[25].cmd, funCMD.za)
	sampRegisterChatCommand(cmdBind[26].cmd, funCMD.zd)
	sampRegisterChatCommand(cmdBind[27].cmd, funCMD.ant)
	sampRegisterChatCommand(cmdBind[28].cmd, funCMD.strah)
	sampRegisterChatCommand(cmdBind[29].cmd, funCMD.cur)
	sampRegisterChatCommand(cmdBind[32].cmd, funCMD.shpora)
	sampRegisterChatCommand(cmdBind[33].cmd, funCMD.hme)
	sampRegisterChatCommand(cmdBind[34].cmd, funCMD.show)
	sampRegisterChatCommand(cmdBind[35].cmd, funCMD.cam)
	sampRegisterChatCommand("hall", funCMD.hall)
	sampRegisterChatCommand("hilka", funCMD.hilka)
	sampRegisterChatCommand("reload", function() scr:reload() end)
	sampRegisterChatCommand("updatemh", 
	function() 
		if not updWin.v then
			styleAnimationOpen(4)
			updWin.v = true
		else
			animka_upd.paramOff = true
		end
	end)
	sampRegisterChatCommand("ts", funCMD.time)
	sampRegisterChatCommand("mh-delete", funCMD.del)
	for i,v in ipairs(binder.list) do
		sampRegisterChatCommand(binder.list[i].cmd, function() binderCmdStart() end)
	end
end

function sampRegCMD()
	if cmdBind[selected_cmd].cmd ==	cmdBind[1].cmd then sampRegisterChatCommand(cmdBind[1].cmd, 
		function()
			if not mainWin.v then
				styleAnimationOpen(1)
				mainWin.v = true
			else
				animka_main.paramOff = true
			end
		end) 
	end
	if cmdBind[selected_cmd].cmd ==	cmdBind[4].cmd then	sampRegisterChatCommand(cmdBind[4].cmd, funCMD.memb) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[5].cmd then	sampRegisterChatCommand(cmdBind[5].cmd, funCMD.lec) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[6].cmd then	sampRegisterChatCommand(cmdBind[6].cmd, funCMD.post) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[7].cmd then	sampRegisterChatCommand(cmdBind[7].cmd, funCMD.med) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[8].cmd then	sampRegisterChatCommand(cmdBind[8].cmd, funCMD.narko) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[9].cmd then	sampRegisterChatCommand(cmdBind[9].cmd, funCMD.recep) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[10].cmd then sampRegisterChatCommand(cmdBind[10].cmd, funCMD.osm) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[11].cmd then sampRegisterChatCommand(cmdBind[11].cmd, funCMD.dep) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[12].cmd then sampRegisterChatCommand(cmdBind[12].cmd, funCMD.sob) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[13].cmd then sampRegisterChatCommand(cmdBind[13].cmd, funCMD.tatu) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[14].cmd then sampRegisterChatCommand(cmdBind[14].cmd, funCMD.warn) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[15].cmd then sampRegisterChatCommand(cmdBind[15].cmd, funCMD.uwarn) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[16].cmd then sampRegisterChatCommand(cmdBind[16].cmd, funCMD.mute) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[17].cmd then sampRegisterChatCommand(cmdBind[17].cmd, funCMD.umute) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[18].cmd then sampRegisterChatCommand(cmdBind[18].cmd, funCMD.rank) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[19].cmd then sampRegisterChatCommand(cmdBind[19].cmd, funCMD.inv) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[20].cmd then sampRegisterChatCommand(cmdBind[20].cmd, funCMD.unv) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[22].cmd then sampRegisterChatCommand(cmdBind[22].cmd, funCMD.expel) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[23].cmd then sampRegisterChatCommand(cmdBind[23].cmd, funCMD.vac) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[24].cmd then sampRegisterChatCommand(cmdBind[24].cmd, funCMD.info) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[25].cmd then sampRegisterChatCommand(cmdBind[25].cmd, funCMD.za) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[26].cmd then sampRegisterChatCommand(cmdBind[26].cmd, funCMD.zd) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[27].cmd then sampRegisterChatCommand(cmdBind[27].cmd, funCMD.ant) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[28].cmd then sampRegisterChatCommand(cmdBind[28].cmd, funCMD.strah) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[29].cmd then sampRegisterChatCommand(cmdBind[29].cmd, funCMD.cur) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[32].cmd then sampRegisterChatCommand(cmdBind[32].cmd, funCMD.shpora) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[33].cmd then sampRegisterChatCommand(cmdBind[33].cmd, funCMD.hme) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[34].cmd then sampRegisterChatCommand(cmdBind[34].cmd, funCMD.show) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[35].cmd then sampRegisterChatCommand(cmdBind[35].cmd, funCMD.cam) end
	for i,v in ipairs(binder.list) do
		sampRegisterChatCommand(binder.list[i].cmd, function() binderCmdStart() end)
	end
end

function HideDialog(bool)
	lua_thread.create(function()
		repeat wait(0) until sampIsDialogActive()
		while sampIsDialogActive() do
			mem.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
			sampToggleCursor(bool)
		end
	end)
end
imgui.GetIO().FontGlobalScale = 1.1

function getNearestID()
    local chars = getAllChars()
    local mx, my, mz = getCharCoordinates(PLAYER_PED)
    local nearId, dist = nil, 10000
    for i,v in ipairs(chars) do
        if doesCharExist(v) and v ~= PLAYER_PED then
            local vx, vy, vz = getCharCoordinates(v)
            local cDist = getDistanceBetweenCoords3d(mx, my, mz, vx, vy, vz)
            local r, id = sampGetPlayerIdByCharHandle(v)
            if r and cDist < dist then
                dist = cDist
                nearId = id
            end
        end
    end
    return nearId
end

function ButtonSwitch(namebut, bool)
    local rBool = false
    if LastActiveTime == nil then
        LastActiveTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end
    local function ImSaturate(f)
        return f < 0.06 and 0.06 or (f > 1.0 and 1.0 or f)
    end
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local height = imgui.GetTextLineHeightWithSpacing() * 1.15
    local width = height * 1.35
    local radius = height * 0.30
    local ANIM_SPEED = 0.09
    local butPos = imgui.GetCursorPos()
    if imgui.InvisibleButton(namebut, imgui.ImVec2(width, height)) then
        bool.v = not bool.v
        rBool = true
        LastActiveTime[tostring(namebut)] = os.clock()
        LastActive[tostring(namebut)] = true
    end
    imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 3, butPos.y + 3.8))
    imgui.Text( namebut:gsub('##.+', ''))
    local t = bool.v and 1.0 or 0.06
    if LastActive[tostring(namebut)] then
        local time = os.clock() - LastActiveTime[tostring(namebut)]
        if time <= ANIM_SPEED then
            local t_anim = ImSaturate(time / ANIM_SPEED)
            t = bool.v and t_anim or 1.0 - t_anim
        else
            LastActive[tostring(namebut)] = false
        end
    end
    local col_static = 0xFFFFFFFF
    local col = bool.v and imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.18, 0.82, 0.35, 0.80)) or 0xFF606060
    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col, 7.0)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.3), p.y+4.6 + radius), radius - 0.75, col_static)

    return rBool
end

dragtest = imgui.ImFloat(12.0)
function CastomDragFloat(DragText, DragParam, DragMIN, DragMAX, DragWidth, posx, poxy)
	local function convert(param)
		param = tonumber(param)*100
		return round(param, 1)
	end
	local DragWidthEnd = (DragWidth-15) / DragMAX
	imgui.SetCursorPos(imgui.ImVec2(posx+5, poxy+9))
	local p = imgui.GetCursorScreenPos()
	local DragPos = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(posx, poxy))
	imgui.PushItemWidth(DragWidth)
	imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
	local thisisDrag = imgui.SliderFloat(u8"##"..DragText, DragParam, DragMIN, DragMAX, u8"")
	imgui.PopStyleColor(3)
	
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + DragWidth-15, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (DragParam.v*DragWidthEnd), p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.11, 0.60, 0.88 ,1.00)), 10, 15)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + (DragParam.v*DragWidthEnd), p.y + 2), 9, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)))
	imgui.SameLine()
	if DragText:find("##") then
	else
		imgui.Text(DragText)
	end
	
	return 	thisisDrag
end

local ptY = 235
local visible = 0
function mainSet()
	local function text_save()
		if sectator:status() ~= "dead" then
			sectator:terminate()
		end
		visible = 255
		sectator = lua_thread.create(function()
			wait(2000)
			repeat wait(0)
				visible = visible - 6
			until visible <= 0
		end)
	end
	local function TheBackground(IsItem, posX, posY, sizeX, sizeY, rounding, flag)
		imgui.SetCursorPos(imgui.ImVec2(posX, posY))
		local p = imgui.GetCursorScreenPos()
		if IsItem == 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + sizeY), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), rounding, flag)
		elseif IsItem == 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + 1), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(547, ptY))
	imgui.TextColored(imgui.ImColor(255, 255, 255, visible):GetVec4(), u8"Настройки сохранены")
	if sel_menu_set == 1 then
		ptY = 230
		TheBackground(1, 410, 48, 426, 176, 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(425, 60))
		imgui.PushItemWidth(295);
		if imgui.InputText(u8" Ваш ник ", buf_nick, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[а-яА-Я%s]+")) then settingMassiveSave() text_save() end
		if not imgui.IsItemActive() and buf_nick.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(432)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите ваш ник в игре");
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 92))
		imgui.PushItemWidth(295);
		if imgui.InputText(u8" Тег ", buf_teg) then settingMassiveSave() text_save() end
		if not imgui.IsItemActive() and buf_teg.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(432)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите ваш тег в игре");
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 124))
		imgui.PushItemWidth(295);
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(60, 60, 60, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Combo(u8" Пол ", num_sex, list_sex) then settingMassiveSave() text_save() end
		imgui.PopStyleColor(3)
		imgui.PopItemWidth()
		imgui.PushItemWidth(283);
		imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		imgui.SetCursorPos(imgui.ImVec2(702, 156))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(51, 51, 51, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Button(fa.ICON_COG.."##1", imgui.ImVec2(21,21)) then
			chgName.inp.v = chgName.org[num_org.v+1]
			imgui.OpenPopup(u8"MH | Изменение названия организации")
		end
		imgui.PopStyleColor(3)
		imgui.PopStyleVar(1)
		imgui.SetCursorPos(imgui.ImVec2(425, 156))
		imgui.PushItemWidth(275);
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(60, 60, 60, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Combo(u8"Организация ", num_org, chgName.org) then settingMassiveSave() text_save() end
		imgui.PopStyleColor(3)
		imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		imgui.SetCursorPos(imgui.ImVec2(702, 188))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(51, 51, 51, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Button(fa.ICON_COG.."##2", imgui.ImVec2(21,21)) then
			chgName.inp.v = chgName.rank[num_rank.v+1]
			imgui.OpenPopup(u8"MH | Изменение названия ранга")
		end
		imgui.PopStyleColor(3)
		imgui.PopStyleVar(1)
		imgui.SetCursorPos(imgui.ImVec2(425, 188))
		imgui.PushItemWidth(275);
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(60, 60, 60, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Combo(u8"      Ранг ", num_rank, chgName.rank) then settingMassiveSave() text_save() end
		imgui.PopStyleColor(3)
		if imgui.BeginPopupModal(u8"MH | Изменение названия организации", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"Введите новое название для вашей организации")
			imgui.PushItemWidth(395)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
			imgui.PopItemWidth()
			if imgui.Button(u8"Применить", imgui.ImVec2(126,23)) then
				local exist = false
				for i,v in ipairs(chgName.org) do
					if v == chgName.inp.v and i ~= num_org.v+1 then
						exist = true
					end
				end
				if not exist then
					chgName.org[num_org.v+1] = chgName.inp.v
					settingMassiveSave() text_save()
					imgui.CloseCurrentPopup()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
				chgName.org[num_org.v+1] = list_org[num_org.v+1]
				needSave = true
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть", imgui.ImVec2(126,23)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopupModal(u8"MH | Изменение названия ранга", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"Введите новое название для вашего ранга")
			imgui.PushItemWidth(200)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[.%s%a%-]+"))
			imgui.PopItemWidth()
			if imgui.Button(u8"Применить", imgui.ImVec2(126,23)) then
				local exist = false
				for i,v in ipairs(chgName.rank) do
					if v == chgName.inp.v and i ~= num_rank.v+1 then
						exist = true
					end
				end
				if not exist then
					chgName.rank[num_rank.v+1] = chgName.inp.v
					settingMassiveSave() text_save()
					imgui.CloseCurrentPopup()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
				chgName.rank[num_rank.v+1] = list_rank[num_rank.v+1]
				needSave = true
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть", imgui.ImVec2(126,23)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end
	if sel_menu_set == 2 then
		ptY = 303
		TheBackground(1, 410, 48, 426, 245, 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8" Отключить рекламу в чате", cb_chat1) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 92))
		if ButtonSwitch(u8" Отключать спам сообщений", cb_chat2) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 125))
		if ButtonSwitch(u8" Отключать системные сообщения", cb_chat3) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 158))
		if ButtonSwitch(u8" ChatHUD", cb_hud) then settingMassiveSave() text_save() end;
		imgui.SetCursorPos(imgui.ImVec2(425, 191))
		if ButtonSwitch(u8" TimeHUD", cb_hudTime) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 224))
		if ButtonSwitch(u8" Авто /time ", cb_time) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Включает автовыполнение команды /time")
		end
		imgui.SameLine()
		imgui.PushItemWidth(250);
		if imgui.InputText(u8"##Поле для /time", buf_time) then settingMassiveSave() text_save()end
		if not imgui.IsItemActive() and buf_time.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(582)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите текст");
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 257))
		if ButtonSwitch(u8" Авто /r ", cb_rac) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Включает автовыполнение команды /r")
		end
		imgui.SameLine()
		imgui.SetCursorPosX(575)
		imgui.PushItemWidth(250);
		if imgui.InputText(u8"##Поле для /r", buf_rac) then settingMassiveSave() text_save() end
		if not imgui.IsItemActive() and buf_rac.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(582)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите текст");
		end
	end
if sel_menu_set == 3 then
 	ptY = 442
   	TheBackground(1, 410, 48, 426, 390, 10, 15)
    TheBackground(2, 410, 159, 426, 2, 0, 0)
    imgui.SetCursorPos(imgui.ImVec2(425, 59))
    imgui.PushItemWidth(80)
    if imgui.InputText(u8" Лечение", buf_lec, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SameLine()
    imgui.SetCursorPosX(610)
    if imgui.InputText(u8" Антибиотик", buf_ant, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 92))
    if imgui.InputText(u8" Рецепт", buf_rec, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SameLine()
    imgui.SetCursorPosX(610)
    if imgui.InputText(u8" Наркотики", buf_narko, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 125))
    if imgui.InputText(u8" Татуировка", buf_tatu, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.PopItemWidth()
    imgui.PushItemWidth(80)
    imgui.SetCursorPos(imgui.ImVec2(425, 173))
    if imgui.InputText(u8" Мед. карта цена за 7 дней", buf_mede[1], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 206))
    if imgui.InputText(u8" Мед. карта цена за 14 дней", buf_mede[2], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 239))
    if imgui.InputText(u8" Мед. карта цена за 30 дней", buf_mede[3], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 272))
    if imgui.InputText(u8" Мед. карта цена за 60 дней", buf_mede[4], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 305))
    if imgui.InputText(u8" Мед. карта (улучш.) цена за 7 дней", buf_upmede[1], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 338))
    if imgui.InputText(u8" Мед. карта (улучш.) цена за 14 дней", buf_upmede[2], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 371))
    if imgui.InputText(u8" Мед. карта (улучш.) цена за 30 дней", buf_upmede[3], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.SetCursorPos(imgui.ImVec2(425, 404))
    if imgui.InputText(u8" Мед. карта (улучш.) цена за 60 дней", buf_upmede[4], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
    imgui.PopItemWidth()
end
	if sel_menu_set == 4 then
		if C_membScr.func.v then
			ptY = 443
			TheBackground(1, 410, 48, 426, 393, 10, 15)
			TheBackground(2, 410, 93, 426, 2, 0, 0)
			TheBackground(2, 410, 205, 426, 2, 0, 0)
			TheBackground(2, 410, 348, 426, 2, 0, 0)
			TheBackground(2, 410, 395, 426, 2, 0, 0)
		else
			ptY = 100
			TheBackground(1, 410, 48, 426, 44, 10, 15)
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8"Отображать список участников на экране", C_membScr.func) then settingMassiveMembers() text_save() end
		if C_membScr.func.v then
			imgui.SetCursorPos(imgui.ImVec2(425, 106))
			if ButtonSwitch(u8" Показывать при диалоге", C_membScr.dialog) then settingMassiveMembers() text_save() end
			imgui.SameLine()
			imgui.SetCursorPos(imgui.ImVec2(625, 106))
			if ButtonSwitch(u8" Правостороннее меню", C_membScr.vergor) then settingMassiveMembers() text_save() end
			imgui.SetCursorPos(imgui.ImVec2(425, 139))
			if ButtonSwitch(u8" Отображать форму", C_membScr.forma) then settingMassiveMembers() text_save() end
			imgui.SameLine()
			imgui.SetCursorPos(imgui.ImVec2(625, 139))
			if ButtonSwitch(u8" Отображать ранг", C_membScr.numrank) then settingMassiveMembers() text_save() end
			imgui.SetCursorPos(imgui.ImVec2(425, 172))
			if ButtonSwitch(u8" Отображать id", C_membScr.id) then settingMassiveMembers() text_save() end
			imgui.SameLine()
			imgui.SetCursorPos(imgui.ImVec2(625, 172))
			if ButtonSwitch(u8" Отображать афк", C_membScr.afk) then settingMassiveMembers() text_save() end
			if CastomDragFloat(u8"Размер шрифта", C_membScr.font.size, 1, 25, 205, 425, 216) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			if CastomDragFloat(u8"Жирность шрифта", C_membScr.font.flag, 1, 25, 205, 425, 249) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			if CastomDragFloat(u8"Расстояние между строками", C_membScr.font.distance, 1, 30, 205, 425, 282) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			if CastomDragFloat(u8"Прозрачность текста", C_membScr.font.visible, 1, 255, 205, 425, 315) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			imgui.SetCursorPos(imgui.ImVec2(425, 359))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(85, 85, 85, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(105, 105, 105, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(60, 60, 60, 255):GetVec4())
			if imgui.Button(u8"Переместить", imgui.ImVec2(397, 26)) then changePosition() end
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(425, 408))
			if imgui.ColorEdit4('##TitleColor', col.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col.title.v[1], col.title.v[2], col.title.v[3], col.title.v[4])
				local argb = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_title = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_default = membScr.color.col_default
				C_membScr.color.col_no_work = membScr.color.col_no_work
				settingMassiveMembers()
				text_save()
			end
			imgui.SameLine()
			imgui.Text(u8'Заголовок')
			imgui.SetCursorPos(imgui.ImVec2(575, 408))
			if imgui.ColorEdit4('##DefaultColor', col.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col.default.v[1], col.default.v[2], col.default.v[3], col.default.v[4]) 
				C_membScr.color.col_default = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_no_work = membScr.color.col_no_work
				C_membScr.color.col_title = membScr.color.col_title
				settingMassiveMembers()
				text_save()
			end
			imgui.SameLine()
			imgui.Text(u8'В форме')
			imgui.SetCursorPos(imgui.ImVec2(717, 408))
			if imgui.ColorEdit4('##NoWorkColor', col.no_work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col.no_work.v[1], col.no_work.v[2], col.no_work.v[3], col.no_work.v[4])
				C_membScr.color.col_no_work = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_default = membScr.color.col_default
				C_membScr.color.col_title = membScr.color.col_title
				settingMassiveMembers()
				text_save()
			end
			imgui.SameLine()
			imgui.Text(u8'Без формы')
		end	
	end
	if sel_menu_set == 5 then
		ptY = 170
		TheBackground(1, 410, 48, 426, 112, 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8" Автоматический спавн в машине", accept_spawn) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Включает автоматическое появление в машине при респавне, если\nмашина была сохранена, но можно отключить эту функцию.")
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 92))
		if ButtonSwitch(u8" Автолечение по голосу", accept_autolec) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Если кто-то говорит в рацию о боли, то автоматически\nначинается лечение, но можно отключить эту опцию.")
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 127))
		if ButtonSwitch(u8" Прикольная фича для команды /d", prikol) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Включает забавные звуковые эффекты при использовании департаментского\nчата, но можно отключить эту опцию.")
		end
	end
	if sel_menu_set == 6 then --findnap
		local function	timenull(param)
			param = round(param, 1)
			if param <= 9 then
				return tostring("0"..param)
			else
				return tostring(param)
			end
		end
		ptY = 102
		imgui.SetCursorPos(imgui.ImVec2(410, 48))
		imgui.BeginChild("Reminers", imgui.ImVec2(426, 395), false, imgui.WindowFlags.NoScrollbar)
		if #reminder == 0 then
			TheBackground(1, 0, 0, 426, 32, 10, 15)
			TheBackground(1, 0, 50, 426, 50, 10, 15)
		else
			TheBackground(1, 0, 0, 426, 80 * (#reminder), 10, 15)
			TheBackground(1, 0, 13 + (80 * (#reminder)), 426, 50, 10, 15)
		end
		
		
		if #reminder == 0 then
			imgui.SetCursorPos(imgui.ImVec2(129, 7))
			imgui.Text(u8"Напоминаний нет")
		else
			for pren = 1, #reminder do
				imgui.SetCursorPos(imgui.ImVec2(0, (80 * (pren - 1))))
				if imgui.InvisibleButton("##RemoveReminder"..pren, imgui.ImVec2(426, 80)) then local removereminder = pren; imgui.OpenPopup(u8"Создать напоминание") end
				if imgui.IsItemHovered() and not imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(0, (80 * (pren - 1))))
					local p = imgui.GetCursorScreenPos()
					if pren ~= 1 and pren ~= #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)))
					elseif pren == 1 and #reminder ~= 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)), 10, 3)
					elseif pren == 1 and #reminder == 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)), 10, 15)
					elseif pren == #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)), 10, 12)
					end
				elseif imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(0, (80 * (pren - 1))))
					local p = imgui.GetCursorScreenPos()
					if pren ~= 1 and pren ~= #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)))
					elseif pren == 1 and #reminder ~= 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)), 10, 3)
					elseif pren == 1 and #reminder == 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)), 10, 15)
					elseif pren == #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)), 10, 12)
					end
				end
			end
			for qun = 1, #reminder do
				TheBackground(2, 20, 30 + (80 * (qun - 1)), 386, 1, 0, 0)
				imgui.SetCursorPos(imgui.ImVec2(20, 7 + (80 * (qun - 1))))
				imgui.Text(reminder[qun].timer.day.." "..u8(month[reminder[qun].timer.mon])..u8", "..timenull(reminder[qun].timer.hour)..u8":"..timenull(reminder[qun].timer.min))
				if not reminder[qun].repeats[1] and not reminder[qun].repeats[2] and not reminder[qun].repeats[3] and not reminder[qun].repeats[4] and not reminder[qun].repeats[5] and not reminder[qun].repeats[6] and not reminder[qun].repeats[7] then
					imgui.SetCursorPos(imgui.ImVec2(302, 7 + (80 * (qun - 1))))
					imgui.Text(u8"Без повтора")
				elseif reminder[qun].repeats[1] and reminder[qun].repeats[2] and reminder[qun].repeats[3] and reminder[qun].repeats[4] and reminder[qun].repeats[5] and reminder[qun].repeats[6] and reminder[qun].repeats[7] then
					imgui.SetCursorPos(imgui.ImVec2(266, 7 + (80 * (qun - 1))))
					imgui.Text(u8"Повтор: каждый день")
				else
					textesweek = ""
					local weekcut = {u8" Пн", u8" Вт", u8" Ср", u8" Чт", u8" Пт", u8" Сб", u8" Вс"}
					for j = 1, 7 do
						if reminder[qun].repeats[j] then
							textesweek = textesweek..weekcut[j]
						end
					end
					local calc = imgui.CalcTextSize(textesweek)
					imgui.SetCursorPos(imgui.ImVec2(353 -  calc.x, 7 + (80 * (qun - 1))))
					imgui.Text(u8"Повтор:"..textesweek)			
				end
				imgui.SetCursorPos(imgui.ImVec2(21, 40+  (80 * (qun - 1))))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + 17), imgui.GetColorU32(imgui.ImVec4(1.00, 0.58, 0.02 ,1.00)), 10, 15)
				imgui.SetCursorPos(imgui.ImVec2(30, 40+  (80 * (qun - 1))))
				if reminder[qun].text ~= "" then
					imgui.Text(reminder[qun].text)
				else
					imgui.Text(u8"Без текста")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 90))
		end
		if #reminder == 0 then
			imgui.SetCursorPos(imgui.ImVec2(20, 60))
		else
			imgui.SetCursorPos(imgui.ImVec2(20, 23 + (80 * (#reminder))))
		end
		local function get_days_in_months(year)
			local is_leap = year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
			local days_in_month = {31, is_leap and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
			return days_in_month
		end
		if imgui.Button(u8"Создать напоминание", imgui.ImVec2(386, 30)) then
			reminder_buf = {
				timer = {year = imgui.ImInt(0), mon = imgui.ImInt(0), day = imgui.ImInt(0), hour = imgui.ImFloat(1.0), min = imgui.ImFloat(1.0)},
				text = imgui.ImBuffer(100),
				repeats = {imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false)},
				sound = imgui.ImBool(true)
			}
			reminder_buf.timer.year.v = tonumber(os.date("%Y"))
			reminder_buf.timer.mon.v = tonumber(os.date("%m"))
			reminder_buf.timer.day.v = tonumber(os.date("%d")) 
			reminder_buf.timer.hour.v = tonumber(os.date("%H"))
			if tonumber(os.date("%M")) <= 55 then
				reminder_buf.timer.min.v = tonumber(os.date("%M")) + 2
			else
				reminder_buf.timer.min.v = 0
				if tonumber(os.date("%H")) ~= 23 then
					reminder_buf.timer.hour.v = tonumber(os.date("%H")) + 1
				else
					reminder_buf.timer.hour.v = 0
				end
			end
			reminder_buf.text.v = u8""
			date_rem = {
				month = {u8"Январь", u8"Февраль", u8"Март", u8"Апрель", u8"Май", u8"Июнь", u8"Июль", u8"Август", u8"Сентябрь", u8"Октябрь", u8"Ноябрь", u8"Декабрь"},
				day = get_days_in_months(reminder_buf.timer.year.v)
			}
			weekday = tonumber(os.date("%w"))
			imgui.OpenPopup(u8"Создать напоминание") 
		end
		
		if imgui.BeginPopupModal(u8"Создать напоминание", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
		imgui.SetCursorPosX(77)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Создать напоминание")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(303)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" #askd", imgui.ImVec2(24, 24)) or animka_sob.paramOff then 
				imgui.CloseCurrentPopup()
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(308)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(308)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginChild("ChildHZG", imgui.ImVec2(313, 35), false, imgui.WindowFlags.NoScrollbar)
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Text(u8" Вы уверены, что хотите удалить напоминание?")
			imgui.EndChild()
			if imgui.Button(u8"Удалить##nal", imgui.ImVec2(156, 24)) then
				imgui.CloseCurrentPopup() 
				table.remove(reminder, removereminder) 
				local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
				f:write(encodeJson(reminder))
				f:flush()
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Отмена##nal", imgui.ImVec2(156, 24)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
			
		if imgui.BeginPopupModal(u8"Создать напоминание", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
		local function get_first_day_of_month(year, month)
			local first_day = os.date("*t", os.time{year=year, month=month, day=1})
			if first_day.wday == 1 then 
				first_day.wday = 6 
			else 
				first_day.wday = first_day.wday - 2
			end
			return first_day.wday
		end
		imgui.SetCursorPosX(195)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Создать напоминание")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(485)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" #as", imgui.ImVec2(24, 24)) or animka_sob.paramOff then 
				imgui.CloseCurrentPopup()
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(490)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(490)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginChild("ChildHZ", imgui.ImVec2(500, 555), false, imgui.WindowFlags.NoScrollbar)
			imgui.PushItemWidth(480)
			imgui.SetCursorPosX(10)
			if imgui.InputText(u8"##Поле напоминания ", reminder_buf.text) then end
			imgui.PopItemWidth()
			if not imgui.IsItemActive() and reminder_buf.text.v == "" then
				imgui.SameLine()
				imgui.SetCursorPosX(20)
				imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите текст напоминания");
			end
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			
			imgui.SetCursorPos(imgui.ImVec2(10, 45))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 275), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(25, 80))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 1), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)))
			imgui.SetCursorPos(imgui.ImVec2(10, 335))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 60), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(10, 410))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 90), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(25, 440))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 1), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)))		
		imgui.SetCursorPos(imgui.ImVec2(10, 515))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 30), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			
			imgui.SetCursorPos(imgui.ImVec2(25, 55))
			imgui.Text(date_rem.month[reminder_buf.timer.mon.v].." "..reminder_buf.timer.year.v..u8" г.")
			imgui.SetCursorPos(imgui.ImVec2(440, 55))
			if imgui.InvisibleButton("##ButDateStampDown", imgui.ImVec2(18, 18)) then
				date_rem.day = get_days_in_months(reminder_buf.timer.year.v)
				if reminder_buf.timer.mon.v ~= 1 then
					reminder_buf.timer.mon.v = reminder_buf.timer.mon.v - 1
				else
					reminder_buf.timer.year.v = reminder_buf.timer.year.v - 1
					reminder_buf.timer.mon.v = 12
				end
				for m = 1, date_rem.day[reminder_buf.timer.mon.v] do
					if weekday == 1 then
						weekday = 0
					elseif weekday == 0 then
						weekday = 6
					elseif weekday == 6 then
						weekday = 5
					elseif weekday == 5 then
						weekday = 4
					elseif weekday == 4 then
						weekday = 3
					elseif weekday == 3 then
						weekday = 2
					elseif weekday == 2 then
						weekday = 1
					end
				end
				reminder_buf.timer.day.v = date_rem.day[reminder_buf.timer.mon.v]
			end
			imgui.SetCursorPos(imgui.ImVec2(442, 57))
			if imgui.IsItemHovered() then
				imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_LEFT)
			else
				imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_LEFT)
			end
			imgui.SetCursorPos(imgui.ImVec2(460, 55))
			if imgui.InvisibleButton("##ButDateStampUp", imgui.ImVec2(18, 18)) then 
				date_rem.day = get_days_in_months(reminder_buf.timer.year.v)
				for m = 1, date_rem.day[reminder_buf.timer.mon.v] do
					if weekday <= 5 then
						weekday = weekday + 1
					elseif weekday == 6 then
						weekday = 0
					end
				end
				if reminder_buf.timer.mon.v ~= 12 then
					reminder_buf.timer.mon.v = reminder_buf.timer.mon.v + 1
				else
					reminder_buf.timer.year.v = reminder_buf.timer.year.v + 1
					reminder_buf.timer.mon.v = 1
				end
				reminder_buf.timer.day.v = 1
			end
			imgui.SetCursorPos(imgui.ImVec2(465, 57))
			if imgui.IsItemHovered() then
				imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_RIGHT)
			else
				imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_RIGHT)
			end
			imgui.SetCursorPos(imgui.ImVec2(35, 92))
			imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.40), u8"Пн             Вт             Ср             Чт             Пт             Сб             Вс")
			local dt_weekday = get_first_day_of_month(reminder_buf.timer.year.v, reminder_buf.timer.mon.v)
			local dt_string = 1
			for k = 1, date_rem.day[reminder_buf.timer.mon.v] do
				local numdt = tostring(k)
				if dt_weekday <= 6 then
					imgui.SetCursorPos(imgui.ImVec2(30 + (dt_weekday * 69), 91 + (dt_string * 33)))
					if imgui.InvisibleButton("##thisdtbut"..k, imgui.ImVec2(26, 26)) then reminder_buf.timer.day.v = k end
					if imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.25)), 60)
					end
					if k == reminder_buf.timer.day.v then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
					end
					if k >= 10 then
						imgui.SetCursorPos(imgui.ImVec2(35 + (dt_weekday * 69), 95 + (dt_string * 33)))
					else
						imgui.SetCursorPos(imgui.ImVec2(39 + (dt_weekday * 69), 95 + (dt_string * 33)))
					end
					imgui.Text(numdt)
					dt_weekday = dt_weekday + 1
				elseif dt_weekday == 7 then
					dt_weekday = 0
					dt_string = dt_string + 1
					imgui.SetCursorPos(imgui.ImVec2(30 + (dt_weekday * 69), 91 + (dt_string * 33)))
					if imgui.InvisibleButton("##thisdtbut"..k, imgui.ImVec2(26, 26)) then reminder_buf.timer.day.v = k end
					if imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.25)), 60)
					end
					if k == reminder_buf.timer.day.v then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
					end
					if k >= 10 then
						imgui.SetCursorPos(imgui.ImVec2(35 + (dt_weekday * 69), 95 + (dt_string * 33)))
					else
						imgui.SetCursorPos(imgui.ImVec2(39 + (dt_weekday * 69), 95 + (dt_string * 33)))
					end
					imgui.Text(numdt)
					dt_weekday = 1
				end
			end
			
			if CastomDragFloat(u8"##ВыборЧаса", reminder_buf.timer.hour, 0, 22, 220, 25, 365) then end
			if CastomDragFloat(u8"##ВыборМинуты", reminder_buf.timer.min, 0, 58, 220, 260, 365) then end
			imgui.SetCursorPos(imgui.ImVec2(120, 342))
			imgui.Text(timenull(reminder_buf.timer.hour.v)..u8" ч.")
			imgui.SetCursorPos(imgui.ImVec2(343, 345))
			imgui.Text(timenull(reminder_buf.timer.min.v)..u8" мин.")
			imgui.SetCursorPos(imgui.ImVec2(212, 417))
			imgui.Text(u8"Повторение")
			imgui.SetCursorPos(imgui.ImVec2(32, 469))
			ButtonSwitch(u8"##Пн", reminder_buf.repeats[1])
			imgui.SetCursorPos(imgui.ImVec2(100, 469))
			ButtonSwitch(u8"##Вт", reminder_buf.repeats[2])
			imgui.SetCursorPos(imgui.ImVec2(168, 469))
			ButtonSwitch(u8"##Ср", reminder_buf.repeats[3])
			imgui.SetCursorPos(imgui.ImVec2(236, 469))
			ButtonSwitch(u8"##Чт", reminder_buf.repeats[4])
			imgui.SetCursorPos(imgui.ImVec2(304, 469))
			ButtonSwitch(u8"##Пт", reminder_buf.repeats[5])
			imgui.SetCursorPos(imgui.ImVec2(372, 469))
			ButtonSwitch(u8"##Сб", reminder_buf.repeats[6])
			imgui.SetCursorPos(imgui.ImVec2(440, 469))
			ButtonSwitch(u8"##Вс", reminder_buf.repeats[7])
			imgui.SetCursorPos(imgui.ImVec2(38, 449))
			imgui.Text(u8"Пн             Вт")
			imgui.SetCursorPos(imgui.ImVec2(175, 449))
			imgui.Text(u8"Ср             Чт             Пт             Сб             Вс")
			
			imgui.SetCursorPos(imgui.ImVec2(25, 522))
			imgui.TextColoredRGB("Напоминание {ffc800}"..reminder_buf.timer.day.v.." "..(month[reminder_buf.timer.mon.v]).." "..reminder_buf.timer.year.v.." г. {FFFFFF}в {ffc800}"..timenull(reminder_buf.timer.hour.v)..":"..timenull(reminder_buf.timer.min.v))
			imgui.SetCursorPos(imgui.ImVec2(330, 519))
			ButtonSwitch(u8" Звук напоминания", reminder_buf.sound)
			imgui.EndChild()
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.SetCursorPosX(20)
			if imgui.Button(u8"Сохранить напоминание##12", imgui.ImVec2(236, 25)) then
				reminder[#reminder + 1] = {
					timer = {year = reminder_buf.timer.year.v, mon = reminder_buf.timer.mon.v, day = reminder_buf.timer.day.v, hour = round(reminder_buf.timer.hour.v, 1), min = round(reminder_buf.timer.min.v, 1)},
					text = reminder_buf.text.v,
					repeats = {reminder_buf.repeats[1].v, reminder_buf.repeats[2].v, reminder_buf.repeats[3].v, reminder_buf.repeats[4].v, reminder_buf.repeats[5].v, reminder_buf.repeats[6].v, reminder_buf.repeats[7].v},
					sound = reminder_buf.sound.v
				}
				imgui.CloseCurrentPopup()
				reminder_buf = {}
				local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
				f:write(encodeJson(reminder))
				f:flush()
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть", imgui.ImVec2(236, 25)) then imgui.CloseCurrentPopup() reminder_buf = {} end
			imgui.Dummy(imgui.ImVec2(0, 1))
		imgui.EndPopup()
		end
		imgui.EndChild()
	end
	if sel_menu_set == 7 then
		ptY = 199
		TheBackground(1, 410, 48, 426, 141, 10, 15)
		TheBackground(2, 410, 86, 426, 2, 0, 0)
		TheBackground(2, 410, 138, 426, 2, 0, 0)
		imgui.SetCursorPos(imgui.ImVec2(532, 59))
		imgui.TextColoredRGB("Версия скрипта - {FFB700}".. scr.version)
		imgui.SetCursorPos(imgui.ImVec2(425, 100))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(85, 85, 85, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(105, 105, 105, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(60, 60, 60, 255):GetVec4())
		if imgui.Button(u8"Проверить обновление", imgui.ImVec2(397, 26)) then 
    		animka_main.paramOff = true 
		end
		imgui.PopStyleColor(3)
	
		if update_available then
			imgui.SetCursorPos(imgui.ImVec2(425, 151))
			imgui.TextColoredRGB("Доступна новая версия: {FFB700}" .. newversion)
			imgui.SetCursorPos(imgui.ImVec2(425, 175))
			imgui.TextWrapped(updinfo or "Список изменений не загружен.")
			imgui.SetCursorPos(imgui.ImVec2(425, 300))
				if imgui.Button(u8"Обновить", imgui.ImVec2(397, 26)) then
					funCMD.doUpdate()
				end
			else
			imgui.SetCursorPos(imgui.ImVec2(425, 151))
			imgui.TextColoredRGB("У вас актуальная версия.")
		end
	end
	if sel_menu_set == 8 then
		for m = 1, #binder.list do
			optionsPKM[m + 13] = u8(binder.list[m].name)
		end
		if chg_funcPKM.func.v then
			ptY = 160 + (#chg_funcPKM.slider * 30)
			TheBackground(1, 410, 48, 426, 102 + (#chg_funcPKM.slider * 30), 10, 15)
			TheBackground(2, 410, 93, 426, 2, 0, 0)
		else
			ptY = 102
			TheBackground(1, 410, 48, 426, 44, 10, 15)
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8" Контекстное меню по нажатию R на игроке", chg_funcPKM.func) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Включает контекстное меню при наведении на игрока и нажатии клавиши R.\nПосле выбора действия будет выполнена соответствующая команда.")
		end
		
		if chg_funcPKM.func.v then
			for k = 1, #chg_funcPKM.slider do
				if chg_funcPKM.slider[k] ~= nil then
					imgui.PushItemWidth(363);
					imgui.SetCursorPos(imgui.ImVec2(425, 79 + (k * 30)))
					if imgui.Combo(u8" ##sliderPKM"..k, chg_funcPKM.slider[k], optionsPKM) then settingMassiveSave() text_save() end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 60):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 30):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 80):GetVec4())
					if imgui.Button(fa.ICON_TRASH.."##DELFF"..k, imgui.ImVec2(26, 23)) then
						table.remove(chg_funcPKM.slider, k)
						table.remove(setting2.funcPKM.slider, k)
						settingMassiveSave()
						text_save()
					end
					imgui.PopStyleColor(3)
				end
			end
			if #chg_funcPKM.slider < 9 then
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 60):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 30):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 80):GetVec4())
				imgui.SetCursorPos(imgui.ImVec2(593, 113 + (#chg_funcPKM.slider * 30)))
				imgui.TextColoredRGB('{FFFFFF}Добавить')
			else
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 10):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 10):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 10):GetVec4())
				imgui.SetCursorPos(imgui.ImVec2(593, 113 + (#chg_funcPKM.slider * 30)))
				imgui.TextColoredRGB('{858585}Добавить')
			end
			imgui.SetCursorPos(imgui.ImVec2(425, 110 + (#chg_funcPKM.slider * 30)))
			if imgui.Button(u8"##Добавить", imgui.ImVec2(397, 25)) then
				if #chg_funcPKM.slider < 9 then
					chg_funcPKM.slider[#chg_funcPKM.slider + 1] = imgui.ImInt(0)
					settingMassiveSave()
					text_save()
				end
			end
			imgui.PopStyleColor(3)
		end
	end
end

function mainGameSimplification()
	imgui.SetCursorPosX(25)
	imgui.BeginGroup()
	imgui.PushItemWidth(150);
	imgui.Dummy(imgui.ImVec2(0, 2))
	if ButtonSwitch(u8"Автоматический спавн в машине", accept_spawn) then needSave = true end
	imgui.SameLine()
	ShowHelpMarker(u8"Включает автоматическое появление в машине при респавне, если\nмашина была сохранена, но можно отключить эту функцию.")
	imgui.Dummy(imgui.ImVec2(0, 2))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 2))
	if ButtonSwitch(u8"Автолечение по голосу", accept_autolec) then needSave = true end
	imgui.SameLine()
	ShowHelpMarker(u8"Если кто-то говорит в рацию о боли, то автоматически\nначинается лечение, но можно отключить эту опцию.")
	imgui.PopItemWidth()
	imgui.EndGroup()
end

function point_sum(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function imgui.ButtonArrow()
	imgui.SetCursorPosX(134)
	if select_menu[1] then
		imgui.SetCursorPosY(5)
	elseif select_menu[2] then
		imgui.SetCursorPosY(52)
	elseif select_menu[3] then
		imgui.SetCursorPosY(99)
	elseif select_menu[4] then
		imgui.SetCursorPosY(146)
	elseif select_menu[5] then
		imgui.SetCursorPosY(193)
	elseif select_menu[7] then
		imgui.SetCursorPosY(240)
	elseif select_menu[10] then
		imgui.SetCursorPosY(287)
	elseif select_menu[6] then
		imgui.SetCursorPosY(334)
	elseif select_menu[9] then
		imgui.SetCursorPosY(381)
	end
    local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddTriangleFilled(imgui.ImVec2(p.x + 15, p.y + 35), imgui.ImVec2(p.x - 16, p.y + 35),imgui.ImVec2(p.x + 15, p.y + 5), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
end
function imgui.ButtonArrowLine()
	imgui.SetCursorPosX(134)
	if select_menu[1] then
		imgui.SetCursorPosY(-5)
	elseif select_menu[2] then
		imgui.SetCursorPosY(42)
	elseif select_menu[3] then
		imgui.SetCursorPosY(89)
	elseif select_menu[4] then
		imgui.SetCursorPosY(136)
	elseif select_menu[5] then
		imgui.SetCursorPosY(183)
	elseif select_menu[7] then
		imgui.SetCursorPosY(230)
	elseif select_menu[10] then
		imgui.SetCursorPosY(277)
	elseif select_menu[6] then
		imgui.SetCursorPosY(324)
	elseif select_menu[9] then
		imgui.SetCursorPosY(371)
	end
    local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddTriangleFilled(imgui.ImVec2(p.x + 15, p.y + 35), imgui.ImVec2(p.x - 16, p.y + 5),imgui.ImVec2(p.x + 15, p.y + 5), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
end

function imgui.GetCursorPosNil()
end

function mainWind()
	if not animka_main.MoveAnim then
		seelM = imgui.Cond.FirstUseEver
	else
		seelM = imgui.Cond.Always
	end
	sw, sh = getScreenResolution()
	imgui.SetNextWindowSize(imgui.ImVec2(854, 465), seelM)
	imgui.SetNextWindowPos(imgui.ImVec2(animka_main.posX, animka_main.posY), seelM, imgui.ImVec2(0.5, 0.5))
	imgui.Begin(fa.ICON_HEARTBEAT .. " Medical Helper by Kane "..scr.version.. u8" Меню", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse);
	imgui.SetCursorPosX(374)
	imgui.PushFont(fontsize)
	imgui.SetCursorPosY(6)
	imgui.TextColored(imgui.ImVec4(1.00, 0.56, 0.64 ,1.00), " Medical Helper")
	imgui.PopFont()
	imgui.SameLine()
	imgui.SetCursorPosX(825)
	imgui.SetCursorPosY(6)
	if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_main.paramOff then 
		posWinClosed = imgui.GetWindowPos()
		styleAnimationClose(1, 854, 465)
		animka_main.paramOff = false
	end
	if imgui.IsItemHovered() then
		imgui.SameLine()
		imgui.SetCursorPosX(830)
		imgui.SetCursorPosY(3)
		imgui.PushFont(fa_font2)
		imgui.TextColored(imgui.ImVec4(1.00, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.SameLine()
		imgui.SetCursorPosX(830)
		imgui.SetCursorPosY(3)
		imgui.PushFont(fa_font2)
		imgui.Text(fa.ICON_TIMES)
		imgui.PopFont()
	end
	imgui.Separator()
	
	imgui.SetCursorPos(imgui.ImVec2(-10, getposcur + 37))
	p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 153, p.y + 40), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
	if poshovbuttr[1] or poshovbuttr[2] or poshovbuttr[3] or poshovbuttr[4] or poshovbuttr[5] or poshovbuttr[6] or poshovbuttr[7] or poshovbuttr[9] or poshovbuttr[10] then
		visbut = 0.05
	else
		visbut = 0.00
	end
	imgui.SetCursorPos(imgui.ImVec2(-10, poshovbut + 37))
	p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 153, p.y + 40), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,visbut)), 10, 15)
	imgui.GetCursorStartPos()
	
	imgui.SetCursorPos(imgui.ImVec2(13, 40))
	imgui.BeginChild("Mine menu", imgui.ImVec2(137, 0), false)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(20, 20, 20, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(20, 20, 20, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(20, 20, 20, 0):GetVec4())
	if imgui.Button(u8"##Основное", imgui.ImVec2(128, 39)) then select_menu = {true, false, false, false, false, false, false, false, false, false}; end
	if imgui.IsItemHovered() then
		poshovbuttr[1] = true
		poshovbut = 2
	else poshovbuttr[1] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Настройки", imgui.ImVec2(128, 39)) then select_menu = {false, true, false, false, false, false, false, false, false, false} end	
	if imgui.IsItemHovered() then
		poshovbuttr[2] = true
		poshovbut = 49
	else poshovbuttr[2] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Основное", imgui.ImVec2(128, 39)) then select_menu = {false, false, true, false , false, false, false, false, false, false} end	
	if imgui.IsItemHovered() then
		poshovbuttr[3] = true
		poshovbut = 96
	else poshovbuttr[3] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Настройки", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, true, false, false, false, false, false, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[4] = true
		poshovbut = 143
	else poshovbuttr[4] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Команды", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, true, false, false, false, false, false}; 
		getSpurFile() 
		spur.name.v = ""
		spur.text.v = ""
		spur.edit = false
		spurBig.v = false
		spur.select_spur = -1
	end
	if imgui.IsItemHovered() then
		poshovbuttr[5] = true
		poshovbut = 190
	else poshovbuttr[5] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Биндер", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, false, true, false, false, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[7] = true
		poshovbut = 237
	else poshovbuttr[7] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Музыка", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, false, false, false, false, true} 
    imgRECORD = {
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/DANCE.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/MEGAMIX.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/PARTY.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/PHONK.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/GOPFM.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/RUKIVVERH.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/DUPSTEP.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/BIGHITS.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/ORGANIC.png"),
        imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/картинки/RUSSIANHITS.png")
    }
    imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
	end
	if imgui.IsItemHovered() then
		poshovbuttr[10] = true
		poshovbut = 284
	else poshovbuttr[10] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Помощь", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, true, false, false, false, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[6] = true
		poshovbut = 331
	else poshovbuttr[6] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##О скрипте",imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, false, false, false, true, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[9] = true
		poshovbut = 378
	else poshovbuttr[9] = false
	end
	imgui.PopStyleColor(3)
	imgui.SetCursorPos(imgui.ImVec2(13, 11))
	if select_menu[1] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_USERS.. u8"   Основное")
		getposcur = 2
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_USERS.. u8"   Основное")
	end
	imgui.SetCursorPos(imgui.ImVec2(13, 58))
	if select_menu[2] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_TOGGLE_ON.. u8"   Настройки")
		getposcur = 49
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_TOGGLE_ON.. u8"   Настройки")
	end

	imgui.SetCursorPos(imgui.ImVec2(15, 105))
	if select_menu[3] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_TERMINAL.. u8"   Команды")
		getposcur = 96
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_TERMINAL.. u8"   Команды")
	end

	imgui.SetCursorPos(imgui.ImVec2(14, 152))
	if select_menu[4] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_DESKTOP.. u8"   Биндер")
		getposcur = 143
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_DESKTOP.. u8"   Биндер")
	end

	imgui.SetCursorPos(imgui.ImVec2(14, 200))
	if select_menu[5] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_BOOK.. u8"   Шпоры")
		getposcur = 190
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_BOOK.. u8"   Шпоры")
	end

	imgui.SetCursorPos(imgui.ImVec2(14, 246))
	if select_menu[7] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_AREA_CHART.. u8"   Статистика")
		getposcur = 237
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_AREA_CHART.. u8"   Статистика")
	end

	imgui.SetCursorPos(imgui.ImVec2(14, 293))
	if select_menu[10] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_MUSIC.. u8"   Музыка")
		getposcur = 284
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_MUSIC.. u8"   Музыка")
	end

	imgui.SetCursorPos(imgui.ImVec2(16, 340))
	if select_menu[6] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_QUESTION.. u8"   Помощь")
		getposcur = 331
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_QUESTION.. u8"   Помощь")
	end

	imgui.SetCursorPos(imgui.ImVec2(13, 387))
	if select_menu[9] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_CODE.. u8"   О скрипте")
		getposcur = 378
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_CODE.. u8"   О скрипте")
	end
	
	imgui.GetCursorStartPos()
	imgui.EndChild();	
	if select_menu[1] then
		colorInfo = imgui.ImColor(240, 170, 40, 255):GetVec4()
		imgui.SameLine()
		imgui.BeginGroup()
		imgui.BeginGroup()
		imgui.SetCursorPosY(153)
		imgui.Separator()
		imgui.SameLine();
		imgui.SetCursorPosX(168)
		imgui.SetCursorPosY(255)
		p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 75), imgui.GetColorU32(imgui.ImVec4(1.00, 0.56, 0.64 ,0.90)), 10, 15)
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x+63, p.y-30), 52, imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]), 60)
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x+63, p.y-40), 50, imgui.GetColorU32(imgui.ImVec4(1.00, 0.56, 0.64 ,0.90)), 60)
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(168)
		imgui.Text(fa.ICON_ADDRESS_CARD .. u8"  Ваш ник: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.name())
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(216)
		imgui.Text(fa.ICON_HOSPITAL_O .. u8"  Организация: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.org());
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(263)
		imgui.Text(fa.ICON_USER .. u8"  Ранг: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.rank());
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(311)
		imgui.Text(fa.ICON_TRANSGENDER .. u8"  Пол: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.sex())
		imgui.Dummy(imgui.ImVec2(0, 8))
		imgui.Separator()	
		imgui.EndGroup()
		imgui.EndGroup()
	end
	if select_menu[2] then
		imgui.SameLine()
		imgui.BeginGroup()
		function Separatordraw(xsep, ysep, pxs)
			imgui.SetCursorPos(imgui.ImVec2(xsep, ysep))
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + pxs, p.y + 1), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
		end
		function IconsBackground(xicon, yicon, imvec)
			imgui.SetCursorPos(imgui.ImVec2(xicon, yicon))
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec), 5, 15)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(158, 49))
		if imgui.InvisibleButton(u8"##Настройки профиля", imgui.ImVec2(234, 37)) then sel_menu_set = 1 end
		imgui.SetCursorPos(imgui.ImVec2(156, 47))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 3)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 3)
		elseif sel_menu_set ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 3)
		elseif sel_menu_set == 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 3)
			mainSet()
		end
		IconsBackground(168, 54, imgui.ImVec4(0.50, 0.50, 0.50 ,1.00))
		imgui.SameLine()
		if sel_menu_set == 1 then
			imgui.SetCursorPos(imgui.ImVec2(172, 55))
		else
			imgui.SetCursorPos(imgui.ImVec2(172, 58))
		end
		imgui.Text(fa.ICON_COGS)
		imgui.SetCursorPos(imgui.ImVec2(200, 58))
		imgui.Text(u8" Настройки профиля")
		imgui.SetCursorPos(imgui.ImVec2(375, 60))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		imgui.SetCursorPos(imgui.ImVec2(158, 86))
		if imgui.InvisibleButton(u8"##Настройки игры", imgui.ImVec2(234, 37)) then sel_menu_set = 2 end
		imgui.SetCursorPos(imgui.ImVec2(156, 85))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		IconsBackground(168, 92, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00))
		if sel_menu_set == 1 or imgui.IsItemHovered() then
			Separatordraw(204, 84, 189)
		else
			Separatordraw(204, 85, 189)
		end
		imgui.SameLine()
		if sel_menu_set == 2 then
			imgui.SetCursorPos(imgui.ImVec2(173, 93))
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 96))
		end
		imgui.Text(fa.ICON_BARS)
		imgui.SetCursorPos(imgui.ImVec2(200, 96))
		imgui.Text(u8" Настройки игры")
		imgui.SetCursorPos(imgui.ImVec2(375, 98))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		imgui.SetCursorPos(imgui.ImVec2(158, 124))
		if imgui.InvisibleButton(u8"##Настройки персонажа", imgui.ImVec2(234, 37)) then sel_menu_set = 3 end
		imgui.SetCursorPos(imgui.ImVec2(156, 123))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 130, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00))
		if sel_menu_set == 2 or imgui.IsItemHovered() then
			Separatordraw(204, 122, 189)
		else
			Separatordraw(204, 123, 189)
		end
		if sel_menu_set == 3 then
			imgui.SetCursorPos(imgui.ImVec2(176, 132))
		else
			imgui.SetCursorPos(imgui.ImVec2(176, 135))
		end
		imgui.Text(fa.ICON_USD)
		imgui.SetCursorPos(imgui.ImVec2(200, 135))
		imgui.Text(u8" Настройки персонажа")
		imgui.SetCursorPos(imgui.ImVec2(375, 137))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 162))
		if imgui.InvisibleButton(u8"##Настройки", imgui.ImVec2(234, 37)) then sel_menu_set = 7 end
		imgui.SetCursorPos(imgui.ImVec2(156, 161))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 12)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 12)
		elseif sel_menu_set ~= 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 12)
		elseif sel_menu_set == 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 12)
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 168, imgui.ImVec4(0.50, 0.50, 0.50 ,1.00))
		if sel_menu_set == 3 or imgui.IsItemHovered() then
			Separatordraw(204, 160, 189)
		else
			Separatordraw(204, 161, 189)
		end
		if sel_menu_set == 7 then
			imgui.SetCursorPos(imgui.ImVec2(173, 169))
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 172))
		end
		imgui.Text(fa.ICON_DOWNLOAD)
		imgui.SetCursorPos(imgui.ImVec2(200, 172))
		imgui.Text(u8" Настройки")
		imgui.SetCursorPos(imgui.ImVec2(375, 174))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 220))
		if imgui.InvisibleButton(u8"##Настройки", imgui.ImVec2(234, 37)) then sel_menu_set = 5 end
		imgui.SetCursorPos(imgui.ImVec2(156, 219))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 3)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 3)
		elseif sel_menu_set ~= 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 3)
		elseif sel_menu_set == 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 3)
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 226, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00))
		if sel_menu_set == 5 then
			imgui.SetCursorPos(imgui.ImVec2(175, 231))
		else
			imgui.SetCursorPos(imgui.ImVec2(175, 231))
		end
		imgui.Text(fa.ICON_FACEBOOK)
		imgui.SetCursorPos(imgui.ImVec2(200, 230))
		imgui.Text(u8" Настройки")
		imgui.SetCursorPos(imgui.ImVec2(375, 232))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 258))
		if imgui.InvisibleButton(u8"##Настройки уведомлений", imgui.ImVec2(234, 37)) then sel_menu_set = 6 end
		imgui.SetCursorPos(imgui.ImVec2(156, 257))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 264, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00))
		if sel_menu_set == 5 or imgui.IsItemHovered() then
			Separatordraw(204, 256, 189)
		else
			Separatordraw(204, 257, 189)
		end
		if sel_menu_set == 6 then
			imgui.SetCursorPos(imgui.ImVec2(173, 268))
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 268))
		end
		imgui.Text(fa.ICON_BELL)
		imgui.SetCursorPos(imgui.ImVec2(200, 268))
		imgui.Text(u8" Настройки уведомлений")
		imgui.SetCursorPos(imgui.ImVec2(375, 270))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 296))
		if imgui.InvisibleButton(u8"##Настройки профиля", imgui.ImVec2(234, 37)) then sel_menu_set = 4 end
		imgui.SetCursorPos(imgui.ImVec2(156, 295))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 302, imgui.ImVec4(0.0, 0.47, 0.99 ,1.00))
		if sel_menu_set == 6 or imgui.IsItemHovered() then
			Separatordraw(204, 294, 189)
		else
			Separatordraw(204, 295, 189)
		end
		if sel_menu_set == 4 then
			if C_membScr.func.v then
				imgui.SetCursorPos(imgui.ImVec2(173, 303))
			else
				imgui.SetCursorPos(imgui.ImVec2(173, 306))
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 306))
		end
		imgui.Text(fa.ICON_USER_CIRCLE_O)
		imgui.SetCursorPos(imgui.ImVec2(200, 306))
		imgui.Text(u8" Настройки профиля")
		imgui.SetCursorPos(imgui.ImVec2(375, 308))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		imgui.SetCursorPos(imgui.ImVec2(158, 334))
		if imgui.InvisibleButton(u8"##Настройки игры", imgui.ImVec2(234, 37)) then
			if #optionsPKM > 13 then
				for m = 14, #optionsPKM do
					table.remove(optionsPKM, 14)
				end
			end
			sel_menu_set = 8 
		end
		imgui.SetCursorPos(imgui.ImVec2(156, 333))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 12)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 12)
		elseif sel_menu_set ~= 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 12)
		elseif sel_menu_set == 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 12)
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 340, imgui.ImVec4(1.0, 0.14, 0.33 ,1.00))
		if sel_menu_set == 4 or imgui.IsItemHovered() then
			Separatordraw(204, 332, 189)
		else
			Separatordraw(204, 333, 189)
		end
		if sel_menu_set == 8 then
			if chg_funcPKM.func.v then
				imgui.SetCursorPos(imgui.ImVec2(173, 342))
			else
				imgui.SetCursorPos(imgui.ImVec2(173, 345))
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 345))
		end
		imgui.Text(fa.ICON_LINK)
		imgui.SetCursorPos(imgui.ImVec2(200, 344))
		imgui.Text(u8" Настройки игры")
		imgui.SetCursorPos(imgui.ImVec2(375, 346))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		imgui.EndGroup()
	end
	if select_menu[3] then
		imgui.SameLine()
		imgui.BeginGroup()
		imgui.BeginChild("cmd list", imgui.ImVec2(0, 360), false)
	end
		
	for i = 1, #cmdBind do
   		local is_selected = (i == selected_cmd)
    	local has_access = (cmdBind[i].rank <= num_rank.v+1)
    	local is_special = (cmdBind[i].rank == 1.5)
    	if is_selected and has_access and not is_special then
    	    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255,255,255,26):GetVec4())
        	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255,255,255,33):GetVec4())
        	imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255,255,255,28):GetVec4())
    	elseif not is_selected and has_access and not is_special then
        	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255,255,255,7):GetVec4())
        	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255,255,255,15):GetVec4())
        	imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255,255,255,8):GetVec4())
    	elseif is_special and is_selected then
        	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255,255,255,13):GetVec4())
        	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255,255,255,20):GetVec4())
        	imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255,255,255,15):GetVec4())
    	else
    	    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255,255,255,5):GetVec4())
        	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255,255,255,12):GetVec4())
        	imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255,255,255,6):GetVec4())
    	end
	end
    if imgui.Button(u8"##cmdB"..i, imgui.ImVec2(665, 30)) then
        selected_cmd = i
    end
    imgui.PopStyleColor(3)
		for i = 1, #cmdBind do
			imgui.SetCursorPos(imgui.ImVec2(18, -28 + (i*34)))
			if i ~= selected_cmd and cmdBind[i].rank <= num_rank.v+1 and cmdBind[i].rank ~= 1.5 then
				imgui.TextColoredRGB("/"..cmdBind[i].cmd.."  {858585}-  "..cmdBind[i].desc)
			else
				imgui.TextColoredRGB("{4d4d4d}/"..cmdBind[i].cmd.."  -  "..cmdBind[i].desc)
			end
		end
		
		imgui.EndChild()
		if cmdBind[selected_cmd].rank <= num_rank.v+1 and cmdBind[selected_cmd].rank ~= 1.5 then
			imgui.SetCursorPos(imgui.ImVec2(630, 423))
			if #cmdBind[selected_cmd].key == 0 then
			imgui.TextColoredRGB("{FFFFFF}Горячая клавиша:  {e84a4a}Не установлена")
			else
				imgui.TextColoredRGB("{FFFFFF}Горячая клавиша:  {3cc74e}"..table.concat(rkeys.getKeysName(cmdBind[selected_cmd].key), " + "))
			end
			if selected_cmd == 5 or selected_cmd == 7 or selected_cmd == 8 or selected_cmd == 9 or selected_cmd == 10 or selected_cmd == 13
			or selected_cmd == 14 or selected_cmd == 15 or selected_cmd == 16 or selected_cmd == 17 or selected_cmd == 18
			or selected_cmd == 19 or selected_cmd == 20 or selected_cmd == 22 or selected_cmd == 23 or selected_cmd == 25 or selected_cmd == 26 
			or selected_cmd == 27 or selected_cmd == 28 or selected_cmd == 29 or selected_cmd == 34 or selected_cmd == 35 then
				imgui.SetCursorPos(imgui.ImVec2(155, 404))
				if imgui.Button(u8"Редактировать действие", imgui.ImVec2(230, 25)) then
					acting_buf = {argfunc = imgui.ImBool(false), arg = {}, varfunc = imgui.ImBool(false), var = {},  
					chatopen = imgui.ImBool(false),	typeAct = {}, sec = imgui.ImFloat(1.0)}
					acting_buf.argfunc.v = acting[selected_cmd].argfunc
					acting_buf.varfunc.v = acting[selected_cmd].varfunc
					acting_buf.sec.v = acting[selected_cmd].sec
					acting_buf.chatopen.v = acting[selected_cmd].chatopen
					variab = {}
					for k = 1, #acting[selected_cmd].typeAct do
						if acting[selected_cmd].typeAct[k][1] ~= 2 and acting[selected_cmd].typeAct[k][1] ~= 4 then
							acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImBuffer(acting[selected_cmd].typeAct[k][2], 1024)}
							acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
						elseif acting[selected_cmd].typeAct[k][1] == 2 then
							acting_buf.typeAct[k] = {imgui.ImInt(0), {}}
							acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
							for m = 1, #acting[selected_cmd].typeAct[k][2] do
								acting_buf.typeAct[k][2][m] = imgui.ImBuffer(1024)
								acting_buf.typeAct[k][2][m].v = acting[selected_cmd].typeAct[k][2][m]
							end
						elseif acting[selected_cmd].typeAct[k][1] == 4 then
							acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImInt(0), imgui.ImBuffer(128)}
							acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
							acting_buf.typeAct[k][2].v = acting[selected_cmd].typeAct[k][2]
							acting_buf.typeAct[k][3].v = acting[selected_cmd].typeAct[k][3]
						end
					end
					for k = 1, #acting[selected_cmd].arg do
						acting_buf.arg[k] = {imgui.ImInt(0), imgui.ImBuffer(128)}
						acting_buf.arg[k][1].v = acting[selected_cmd].arg[k][1]
						acting_buf.arg[k][2].v = acting[selected_cmd].arg[k][2]
					end
					for k = 1, #acting[selected_cmd].var do
						acting_buf.var[k] = imgui.ImBuffer(128)
						acting_buf.var[k].v = acting[selected_cmd].var[k]
						variab[k] = "{var"..k.."}"
					end
					actingOutWind.v = true
				end
			else
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.SetCursorPos(imgui.ImVec2(155, 404))
				imgui.Button(u8"##Редактировать действие", imgui.ImVec2(230, 25))
				imgui.SetCursorPos(imgui.ImVec2(187, 408))
				imgui.TextColoredRGB("{6e6e6e}Редактировать действие")
				imgui.PopStyleColor(3)
			end
		imgui.SetCursorPos(imgui.ImVec2(390, 404))
		if imgui.Button(u8"Назначить клавишу", imgui.ImVec2(230, 25)) then 
			imgui.OpenPopup(u8"MH | Назначить клавишу для команды");
			lockPlayerControl(true)
			editKey = true
		end
		if cmdBind[selected_cmd].cmd ~= "r" and cmdBind[selected_cmd].cmd ~= "rb" and cmdBind[selected_cmd].cmd ~= "time" then
			imgui.SetCursorPos(imgui.ImVec2(155, 433))
				if imgui.Button(u8"Изменить команду", imgui.ImVec2(230, 25)) then 
				chgName.inp.v = cmdBind[selected_cmd].cmd
				unregcmd = chgName.inp.v
				imgui.OpenPopup(u8"MH | Изменение команды")
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.Button(u8"##Изменить команду", imgui.ImVec2(230, 25))
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(210, 437))
			imgui.TextColoredRGB("{6e6e6e}Изменить команду")
		end
		imgui.SetCursorPos(imgui.ImVec2(390, 433))
		if imgui.Button(u8"Сбросить привязку", imgui.ImVec2(230, 25)) then 
			rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
			unRegisterHotKey(cmdBind[selected_cmd].key)
			cmdBind[selected_cmd].key = {}
			f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
			f:write(encodeJson(cmdBind))
			f:flush()
			f:close()
		end	
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.Button(u8"##Редактировать действие", imgui.ImVec2(230, 25))
			imgui.SameLine()
			imgui.Button(u8"##Назначить клавишу", imgui.ImVec2(230, 25))
			imgui.Button(u8"##Изменить команду", imgui.ImVec2(230, 25))
			imgui.SameLine()
			imgui.Button(u8"##Сбросить привязку", imgui.ImVec2(230, 25))
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(187, 408))
			imgui.TextColoredRGB("{6e6e6e}Редактировать действие                      Назначить клавишу")
			imgui.SetCursorPos(imgui.ImVec2(210, 437))
			imgui.TextColoredRGB("{6e6e6e}Изменить команду                           Сбросить привязку")
			if cmdBind[selected_cmd].rank ~= 1.5 then
				imgui.SetCursorPos(imgui.ImVec2(630, 414))
				imgui.Text(u8"Уровень доступа к команде\nТребуется ранг "..cmdBind[selected_cmd].rank..u8".")
			elseif cmdBind[selected_cmd].cmd == "hall" then
				imgui.SetCursorPos(imgui.ImVec2(630, 414))
				imgui.Text(u8"Уровень доступа к команде\nТребуется ранг или +2")
			elseif cmdBind[selected_cmd].cmd == "hilka" then
				imgui.SetCursorPos(imgui.ImVec2(630, 414))
				imgui.Text(u8"Уровень доступа к команде\nТребуется ранг или +1")
			end
		end	
		imgui.EndGroup()
	if select_menu[5] then
		imgui.SameLine()
		imgui.BeginChild("shpora but", imgui.ImVec2(0, 0), false)
		imgui.SetCursorPos(imgui.ImVec2(positbut3, 2))
		imgui.BeginChild("shpora list", imgui.ImVec2(0, 355), false)
		
		if #spur.list ~= 0 then
			if spur.select_spur == -1 then
				spur.select_spur = 1
			end
			for i = 1, #spur.list do
				if i ~= spur.select_spur then
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 7):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 15):GetVec4())
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 8):GetVec4())
				else
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 24):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 40):GetVec4())
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 26):GetVec4())
				end
				if imgui.Button(u8"##spurBut"..i, imgui.ImVec2(665, 30)) then
					spur.select_spur = i
					spur.text.v = ""
					spur.name.v = ""
					spur.edit = false
					spurBig.v = false
				end
				imgui.PopStyleColor(3)
			end
			for i = 1, #spur.list do
				imgui.SetCursorPos(imgui.ImVec2(18, -28 + (i*34)))
				imgui.Text(i..".  "..u8(spur.list[i]))
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(145, 175))
			imgui.TextColoredRGB('Шпор нет, создай новую или выбери существующую.')
		end
		
		
		imgui.EndChild()
		if #spur.list ~= 0 then
			imgui.SetCursorPos(imgui.ImVec2(positbut3, 360))
			if imgui.Button(u8"Открыть шпору##shpora", imgui.ImVec2(226, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Редактировать шпору##shpora", imgui.ImVec2(226, 25)) then
				activebutanim3[1] = true
				spur.edit = true
				f = io.open(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
				spur.name.v = u8(spur.list[spur.select_spur])
			end
			imgui.SameLine()
				if imgui.Button(u8"Удалить шпору##shpora", imgui.ImVec2(226, 25)) then 
					if doesFileExist(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt") then
						os.remove(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt")
				end
				table.remove(spur.list, spur.select_spur)
				if #spur.list >= 2 then
					if spur.select_spur ~= 1 then
						spur.select_spur = spur.select_spur -1
					else
						spur.select_spur = -1
					end
				else
					spur.select_spur = -1
				end
			end
			
		end
		imgui.SetCursorPos(imgui.ImVec2(positbut3, 390))
		if imgui.Button(u8"Создать новую шпору##shpora", imgui.ImVec2(688, 25)) then 
			if #spur.list ~= 20 then
				for i = 1, 20 do
					if not table.concat(spur.list, "|"):find("шпора '"..i.."'") then
						table.insert(spur.list, "шпора '"..i.."'")
						spur.edit = true
						spur.select_spur = #spur.list
						spur.name.v = ""
						spur.text.v = ""
						spurBig.v = false
						f = io.open(dirml.."/MedicalHelper/шпаргалки/шпора '"..i.."'.txt", "w")
						f:write("")
						f:flush()
						f:close()
						break
					end
				end
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(positbut3 + 699, 2))
		imgui.BeginChild("ShporaEdit", imgui.ImVec2(691, 415), false)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 3):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 5):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 8):GetVec4())
		if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 410)) then
			activebutanim3[2] = true
		end
		imgui.PopStyleColor(3)
		
		if spur.edit and not spurBig.v then
			imgui.SetCursorPos(imgui.ImVec2(300, 0))
			imgui.Text(u8"Редактор шпоры")
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			imgui.SetCursorPosX(50)
			imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(640, 300))
			imgui.PopStyleColor(1)
			imgui.PushItemWidth(400)
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Закрыть редактор шпоры/отменить", imgui.ImVec2(640, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
			imgui.Spacing()
			imgui.SetCursorPosX(50)
			imgui.PushItemWidth(526)
			imgui.InputText(u8"Название шпоры", spur.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-яА-Я%+%%#%(%)%s]"))
			imgui.Spacing()
			imgui.PopItemWidth()
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Удалить", imgui.ImVec2(317, 25)) then
				activebutanim3[2] = true
				if doesFileExist(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt") then
					os.remove(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt")
				end
				table.remove(spur.list, spur.select_spur) 
				spur.edit = false
				spur.name.v = ""
				spur.text.v = ""
				if #spur.list >= 2 then
					if spur.select_spur ~= 1 then
						spur.select_spur = spur.select_spur -1
					else
						spur.select_spur = -1
					end
				else
					spur.select_spur = -1
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Сохранить", imgui.ImVec2(317, 25)) then
				activebutanim3[2] = true
				name = ""
				bool = false
				if spur.name.v ~= "" then 
					name = u8:decode(spur.name.v)
					if doesFileExist(dirml.."/MedicalHelper/шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
						bool = true
						imgui.OpenPopup(u8"Ошибка")
					else
						os.remove(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt")
						spur.list[spur.select_spur] = u8:decode(spur.name.v)
					end
				else
					name = spur.list[spur.select_spur]
				end
				if not bool then
					f = io.open(dirml.."/MedicalHelper/шпаргалки/"..name..".txt", "w")
					f:write(u8:decode(spur.text.v))
					f:flush()
					f:close()
					spur.text.v = ""
					spur.name.v = ""
				end
			end
		elseif spurBig.v then
			imgui.SetCursorPos(imgui.ImVec2(270, 200))
			imgui.TextColoredRGB("Закрыть редактор шпоры")
		end
		imgui.EndChild()
		imgui.EndChild()
		if activebutanim3[1] then 
			if positbut3 > -699 then
				positbut3 = positbut3 - 23
			else
				activebutanim3[1] = false
				positbut3 = - 699
			end
		end
		
		if activebutanim3[2] then 
			if positbut3 < 0 then
				positbut3 = positbut3 + 27
			else
				activebutanim3[2] = false
				positbut3 = 0
			end
		end
	end
	if select_menu[4] then
		imgui.SameLine()
		imgui.BeginChild("bind but", imgui.ImVec2(0, 0), false)
		imgui.SetCursorPos(imgui.ImVec2(positbut2, 2))
		imgui.BeginChild("bind list", imgui.ImVec2(0, 385), false)
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 7):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 15):GetVec4())
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 8):GetVec4())
		if #binder.list ~= 0 then
			for i = 1, #binder.list do
				if imgui.Button(u8"##BindBut"..i, imgui.ImVec2(665, 30)) then
					activebutanim2[1] = true
					binder.select_bind = i
					binder.name.v = u8(binder.list[binder.select_bind].name)
					binder.sleep.v = binder.list[binder.select_bind].sleep
					binder.cmd.v = u8(binder.list[binder.select_bind].cmd)
					binder.key = binder.list[binder.select_bind].key
					if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
						f = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "r")
						binder.text.v = u8(f:read("*a"))
						f:flush()
						f:close()
					end
					binder.edit = true
				end
			end
			for i = 1, #binder.list do
				imgui.SetCursorPos(imgui.ImVec2(18, -28 + (i*34)))
				imgui.Text(i..".  "..u8(binder.list[i].name))
				imgui.SetCursorPos(imgui.ImVec2(640, -26 + (i*34)))
				imgui.TextColored(imgui.ImColor(255, 255, 255, 100):GetVec4(), fa.ICON_CHEVRON_RIGHT)
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(145, 175))
			imgui.TextColoredRGB('Биндеров нет, создай новый или выбери существующий.')
		end
		imgui.PopStyleColor(3)
		imgui.EndChild()
		imgui.SetCursorPosX(positbut2)
		if imgui.Button(u8"Создать новый##биндер", imgui.ImVec2(689, 25)) then
			if #binder.list < 100 then
				for i = 1, 100 do
					bool = false
					for ix,v in ipairs(binder.list) do
						if v.name == "Noname bind '"..i.."'" then bool = true end
					end
					if not bool then
						binder.list[#binder.list+1] = {name = "Новый биндер ("..i..")", key = {}, sleep = 0.5, cmd = ""}
						binder.edit = true
						binder.select_bind = #binder.list
						binder.name.v = ""
						binder.cmd.v = ""
						binder.sleep.v = 0.5
						binder.text.v = ""
						binder.key = {}
						break 
					end
				end
			end
		end
		
		imgui.SetCursorPos(imgui.ImVec2(positbut2 + 699, 2))
		imgui.BeginChild("BindEdit", imgui.ImVec2(691, 415), false)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 3):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 5):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 8):GetVec4())
		if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 410)) then
			activebutanim2[2] = true
		end
		imgui.PopStyleColor(3)
		if binder.edit then
			imgui.SameLine()
			imgui.SetCursorPosX(300)
			imgui.Text(u8"Редактор бинда")
			imgui.SetCursorPos(imgui.ImVec2(50, 30))
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			imgui.InputTextMultiline("##bind", binder.text, imgui.ImVec2(635, 245))
			imgui.PopStyleColor(1)
			imgui.PushItemWidth(300)
			imgui.SetCursorPosX(50)
			imgui.InputText(u8"Название бинда", binder.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-яА-Я%+%%#%(%)%s]"))
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Изменить горячую клавишу", imgui.ImVec2(300, 25)) then 
				imgui.OpenPopup(u8"MH | Изменить горячую клавишу")
				editKey = true
			end
			if imgui.BeginPopupModal(u8"MH | Назначить клавишу для привязки", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then		
			imgui.Text(u8"Нажмите на клавишу для привязки или для отмены нажмите ESC."); imgui.Separator()
			imgui.Text(u8"Допустимые клавиши:")
			imgui.Bullet()	imgui.TextDisabled(u8"Модификаторы - Alt, Ctrl, Shift")
			imgui.Bullet()	imgui.TextDisabled(u8"Буквенные клавиши")
			imgui.Bullet()	imgui.TextDisabled(u8"Функциональные клавиши F1-F12")
			imgui.Bullet()	imgui.TextDisabled(u8"Клавиши стрелок")
			imgui.Bullet()	imgui.TextDisabled(u8"Цифры Numpad")
			ButtonSwitch(u8"Использовать мышь с прокруткой в диалогах", cb_RBUT)
			imgui.Separator()
			if imgui.TreeNode(u8"Для дополнительных 5-кнопочных мышей") then
				ButtonSwitch(u8"X Button 1", cb_x1)
				ButtonSwitch(u8"X Button 2", cb_x2)
				imgui.Separator()
				imgui.TreePop();
			end
			imgui.Text(u8"Нажмите клавишу(и): ");
				imgui.SameLine();
				if imgui.IsMouseClicked(0) then
					lua_thread.create(function()
						wait(500)			
						setVirtualKeyDown(3, true)
						wait(0)
						setVirtualKeyDown(3, false)
					end)
				end
				if #(rkeys.getCurrentHotKey()) ~= 0 and not rkeys.isBlockedHotKey(rkeys.getCurrentHotKey()) then	
					if not rkeys.isKeyModified((rkeys.getCurrentHotKey())[#(rkeys.getCurrentHotKey())]) then
						currentKey[1] = table.concat(rkeys.getKeysName(rkeys.getCurrentHotKey()), " + ")
						currentKey[2] = rkeys.getCurrentHotKey()
					end
				end
				imgui.TextColored(imgui.ImColor(255, 205, 0, 200):GetVec4(), currentKey[1])
				if isHotKeyDefined then
				imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данный ключ уже используется!")
				end
				if isHotKeyExists then
					imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данная комбинация уже используется!")
				end
				if imgui.Button(u8"Применить", imgui.ImVec2(150, 0)) then
					if select_menu[4] then
						if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
						if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
						if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
						if rkeys.isHotKeyExist(currentKey[2]) then 
							isHotKeyExists = true
						else	
							rkeys.unRegisterHotKey(binder.list[binder.select_bind].key)
							unRegisterHotKey(binder.list[binder.select_bind].key)
							binder.key = currentKey[2]
							lockPlayerControl(false)
							cb_RBUT.v = false
							cb_x1.v, cb_x2.v = false, false
							isHotKeyExists = false
							imgui.CloseCurrentPopup();
							editKey = false
						end
					end
				end
				imgui.SameLine();
				if imgui.Button(u8"Закрыть", imgui.ImVec2(150, 0)) then 
					imgui.CloseCurrentPopup(); 
					currentKey = {"",{}}
					cb_RBUT.v = false
					cb_x1.v, cb_x2.v = false, false
					lockPlayerControl(false)
					isHotKeyExists = false
					editKey = false
				end 
				imgui.SameLine()
				if imgui.Button(u8"Сбросить", imgui.ImVec2(150, 0)) then
					currentKey = {"",{}}
					cb_x1.v, cb_x2.v = false, false
					cb_RBUT.v = false
					isHotKeyExists = false
				end
				imgui.EndPopup()
			end
			imgui.SetCursorPosX(50)
			if #binder.list[binder.select_bind].key == 0 and #binder.key == 0 then
				imgui.SameLine()
				imgui.TextColoredRGB("Горячая клавиша: {F02626}Не установлена")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("Горячая клавиша: {1AEB1D}"..table.concat(rkeys.getKeysName(binder.key), " + "))
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Изменить команду", imgui.ImVec2(300, 25)) then 
				chgName.inp.v = binder.cmd.v
				unregcmd = chgName.inp.v
				imgui.OpenPopup(u8"MH | Изменить команду")
				editKey = true
			end
			if imgui.BeginPopupModal(u8"MH | Изменить команду", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.SetCursorPosX(70)
			imgui.Text(u8"Изменить команду бинда."); imgui.Separator()
			imgui.Text(u8"Допустимые символы:")
			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Латинские буквы.")

			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Если вы не укажете свою команду - бот будет работать некорректно.")
			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Можно использовать буквы и цифры. Русские буквы нельзя.")
			if select_menu[4] then
				imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Если вы используете команды {e3071d}/findihouse{00ff8c} и {e3071d}/findibiz {00ff8c}удачи в поиске!")
			end
			imgui.Text(u8"/");
			imgui.SameLine();
			imgui.PushItemWidth(520)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%a]+"))
			if isHotKeyDefined then
				imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данный ключ уже используется!")
			end
			if russkieBukviNahyi then
				imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF}!")
			end
			if dlinaStroki then
				imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} - 15!")
			end		
			if select_menu[4] then
				if imgui.Button(u8"Применить", imgui.ImVec2(174, 0)) then
					exits = false
					if chgName.inp.v:find("%A") then
						russkieBukviNahyi = true
						isHotKeyDefined = false
						dlinaStroki = false
						exits = true
					elseif chgName.inp.v:len() > 15 then
						dlinaStroki = true
						russkieBukviNahyi = false
						isHotKeyDefined = false
						exits = true
					end
					for i,v in ipairs(cmdBind) do
						if v.cmd == chgName.inp.v then
							exits = true
							isHotKeyDefined = true
							russkieBukviNahyi = false
							dlinaStroki = false
						end
					end
					for i,v in ipairs(binder.list) do
						if binder.list[i].cmd == chgName.inp.v and chgName.inp.v ~= binder.cmd.v and chgName.inp.v ~= "" then
							exits = true
							isHotKeyDefined = true
							russkieBukviNahyi = false
							dlinaStroki = false
						end
					end
					if not exits then
						if binder.cmd.v == chgName.inp.v then
							unregcmd = ""
							isHotKeyDefined = false
							russkieBukviNahyi = false
							dlinaStroki = false
							imgui.CloseCurrentPopup();
						else
							isHotKeyDefined = false
							russkieBukviNahyi = false
							dlinaStroki = false
							binder.cmd.v = chgName.inp.v
							imgui.CloseCurrentPopup();
							editKey = false
						end
					end
				end
			end				
			imgui.SameLine();
			if imgui.Button(u8"Закрыть", imgui.ImVec2(174, 0)) then 
				imgui.CloseCurrentPopup(); 
				currentKey = {"",{}}
				cb_RBUT.v = false
				cb_x1.v, cb_x2.v = false, false
				lockPlayerControl(false)
				isHotKeyDefined = false
				russkieBukviNahyi = false
				dlinaStroki = false
				editKey = false
				unregcmd = ""
			end 
			imgui.SameLine()
			if select_menu[4] then
				if imgui.Button(u8"Сбросить", imgui.ImVec2(174, 0)) then
					chgName.inp.v = ""
					isHotKeyDefined = false
					russkieBukviNahyi = false
					dlinaStroki = false
				end
			end
			imgui.EndPopup()
		end
			imgui.SetCursorPosX(50)
			if binder.cmd.v == "" then
				imgui.SameLine()
				imgui.TextColoredRGB("Команда бинда: {F02626}Не установлена")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("Команда бинда: {1AEB1D}/"..binder.cmd.v)
			end
			imgui.PushItemWidth(250)
			imgui.SetCursorPosX(50)
			imgui.DragFloat("##sleep", binder.sleep, 0.1, 0.5, 10.0, u8"Задержка = %.1f сек.")
			imgui.SameLine()
			if imgui.Button("-", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 0.5 then binder.sleep.v = binder.sleep.v - 0.1 end
			imgui.SameLine()
			if imgui.Button("+", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 10 then binder.sleep.v = binder.sleep.v + 0.1 end
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.Text(u8"Задержка между действиями")
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Удалить", imgui.ImVec2(152, 25)) then
				activebutanim2[2] = true
				sampUnregisterChatCommand(binder.cmd.v)
				binder.text.v = ""
				binder.sleep.v = 0.5
				binder.name.v = ""
				binder.cmd.v = ""
				binder.edit = false 
				rkeys.unRegisterHotKey(binder.key)
				unRegisterHotKey(binder.key)
				binder.key = {}
				if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
					os.remove(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt")
				end
				table.remove(binder.list, binder.select_bind) 
				f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
				f:write(encodeJson(binder.list))
				f:flush()
				f:close()
				binder.select_bind = -1 
			end
			imgui.SameLine()
			if imgui.Button(u8"Изменить", imgui.ImVec2(152, 25)) then
				bool = false
				if binder.name.v ~= "" then
					for i,v in ipairs(binder.list) do
						if v.name == u8:decode(binder.name.v) and i ~= binder.select_bind then bool = true end
					end		
					if not bool then
						binder.list[binder.select_bind].name = u8:decode(binder.name.v)
					else
						imgui.OpenPopup(u8"Ошибка")
					end
				end
				if not bool then
					rkeys.registerHotKey(binder.key, true, onHotKeyBIND)
					binder.list[binder.select_bind].key = binder.key
					binder.list[binder.select_bind].cmd = binder.cmd.v
					sec = string.format("%.1f", binder.sleep.v)
					binder.list[binder.select_bind].sleep = sec
					text = u8:decode(binder.text.v)
					cmd = u8:decode(binder.cmd.v)
					saveJS = encodeJson(binder.list) 
					sampRegCMD()
					sampUnregisterChatCommand(unregcmd)
					f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
					ftx = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "w")
					f:write(saveJS)
					ftx:write(text)
					f:flush()
					ftx:flush()
					f:close()
					ftx:close()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Параметры", imgui.ImVec2(152, 25)) then paramWin.v = not paramWin.v end
			imgui.SameLine()
			if imgui.Button(u8"Профиль", imgui.ImVec2(165, 25)) then 
				profbWin.v = not profbWin.v
			end	
		end
		imgui.EndChild()
		imgui.EndChild()
		if activebutanim2[1] then 
			if positbut2 > -699 then
				positbut2 = positbut2 - 23
			else
				activebutanim2[1] = false
				positbut2 = - 699
			end
		end
		
		if activebutanim2[2] then 
			if positbut2 < 0 then
				positbut2 = positbut2 + 27
			else
				activebutanim2[2] = false
				positbut2 = 0
			end
		end
	end
	if select_menu[6] then
		imgui.SameLine()
		text_question = { u8"Как мне быть новичком? Что мне делать?", u8"У меня нет опыта в ролевой игре. Что мне делать?", u8"В чем смысл этой игры?", u8"Как мне начать играть на сервере Arizona?", u8"Что значит ролевая игра?", u8"Как мне стать врачом?", u8"Что нужно делать и как не нарушать?", u8"Где можно посмотреть правила?", u8"Я не могу понять что-то в игре. Что делать?", u8"Я хочу узнать как создать свою семью?", u8"Как мне найти работу в городе? Что для этого нужно?", u8"Как мне заработать деньги в игре?", u8"У меня нет напарника для игры. Что делать?", u8"Как в этой игре быстро заработать деньги?", u8"Как мне разобраться в законах? Что нужно знать о них?", u8"Что делать если я попал в больницу?", u8"Как мне создать свой бизнес?", u8"Какие команды нужно знать для игры?", u8"Я слышал о некоторых командах. Что они значат?", u8"Что делать если меня арестовали и что делать?", u8"Что такое серьезная Role Play игра?"}
			icon_question = {fa.ICON_CUBE, fa.ICON_USER_SECRET, fa.ICON_BUG, fa.ICON_PENCIL, fa.ICON_ASTERISK,
			fa.ICON_PENCIL_SQUARE_O, fa.ICON_KEYBOARD_O, fa.ICON_SCISSORS, fa.ICON_FACEBOOK, fa.ICON_GAMEPAD,
			fa.ICON_LINE_CHART, fa.ICON_MUSIC, fa.ICON_WRENCH, fa.ICON_USD,
			fa.ICON_SIMPLYBUILT, fa.ICON_CUBES, fa.ICON_ARROW_UP, fa.ICON_FOLDER_OPEN, fa.ICON_CHECK_SQUARE,
			fa.ICON_EXCLAMATION_CIRCLE, fa.ICON_CHECK}
			imgui.SetCursorPos(imgui.ImVec2(positbut, 2))
			imgui.BeginChild("help2 but", imgui.ImVec2(691, 415), false)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 9):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 8):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 16):GetVec4())
			for i = 1, 21 do
				if imgui.Button(u8"##Quest"..i, imgui.ImVec2(665, 45)) then
					activebutanim[1] = true
					activebutanim[3] = i
				end
			end
			for i = 1, 21 do
				imgui.SetCursorPos(imgui.ImVec2(635, -33 + (i*49)))
				imgui.TextColored(imgui.ImColor(255, 255, 255, 120):GetVec4(), fa.ICON_CHEVRON_RIGHT)
				imgui.SetCursorPos(imgui.ImVec2(50, -35 + (i*49)))
				imgui.Text(text_question[i])
				imgui.SetCursorPos(imgui.ImVec2(18, -35 + (i*49)))
				imgui.Text(icon_question[i])
			end
			imgui.PopStyleColor(3)
			imgui.EndChild()
			
			imgui.SetCursorPos(imgui.ImVec2(positbut + 699, 2))
			imgui.BeginChild("help22 but", imgui.ImVec2(691, 415), false)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 3):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 5):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 8):GetVec4())
			if activebutanim[3] ~= 5 then
				if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 413)) then
					activebutanim[2] = true
				end
			else
				if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 1480)) then
					activebutanim[2] = true
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(50)
			if activebutanim[3] == 1 then
				imgui.TextWrapped(u8'    Medical Helper — это скрипт, который помогает игрокам медицинской организации на сервере Arizona Role Play. Скрипт максимально упрощает рутинные действия врачей. В нём есть множество функций, которые позволяют быстро выполнять различные медицинские процедуры, экономя время и делая игровой процесс более комфортным.\n\nИзначально разработчиком был Hatiko (до версии 3.0.0). В последующих версиях проект перешёл к разработчику Kane, который продолжает улучшать и поддерживать его.')
			elseif activebutanim[3] == 2 then
				imgui.TextWrapped(u8'    Если скрипт работает некорректно или вылетает с ошибками, для начала проверьте наличие всех необходимых библиотек. В большинстве случаев проблема решается просмотром лога moonloader.log, который находится в папке moonloader, где и хранятся ошибки. Проанализируйте логи, найдите там красные строки, указывающие на конкретные ошибки, файлы и строки. После этого вы сможете найти решение в интернете или на форумах.')
			elseif activebutanim[3] == 3 then
				imgui.TextWrapped(u8'    Если у вас возникли проблемы с запуском скрипта, рекомендуем обратиться к разработчику Kane, указав все детали ошибки. Возможно, вам предложат прислать логи из папки "My Documents". Имейте в виду, что на форуме и в группах могут быть темы, где уже обсуждались аналогичные проблемы. Если ответа нет, возможно, стоит проверить версию установленных библиотек или переустановить их. В таком случае рекомендуется использовать актуальные версии библиотек с официальных источников, таких как GitHub, GTAForums, BlastHack, Moonloader, SAMP и другие. Также стоит убедиться, что у вас установлена последняя версия Moonloader и правильные настройки в файлах конфигурации.\n\nКроме того, если ничего не помогает, попробуйте связаться с разработчиком Kane. Возможно, он даст инструкцию по установке или подскажет, как правильно настроить скрипт. Если вы уже пробовали различные способы и ничего не вышло, возможно, проблема в самом коде и потребуется его доработка.')
			elseif activebutanim[3] == 4 then
				imgui.TextWrapped(u8'   Для выполнения любых действий используйте команды из раздела "Команды", где можно изменить текст каждого действия. Действия автоматически выполняются с задержкой в секундах. Чтобы изменить действие, нажмите кнопку "Редактировать действие" и отредактируйте список команд. Если вы хотите добавить новое действие для команды, просто скопируйте существующее и измените его под свои нужды. Если после редактирования что-то пошло не так, всегда можно вернуть стандартные настройки кнопкой "Сброс".')
			elseif activebutanim[3] == 5 then
				imgui.TextWrapped(u8'Рассмотрим пример создания сложного действия:\n\nДля начала, если вы хотите создать действие для лечения или диагностики, лучше начать с шаблона "Редактирование действия". Там вы увидите список команд, которые можно изменять и дополнять. Как же редактировать действия? Сначала откройте раздел команд, найдите нужную команду, нажмите\n/medcard [id] [срок] [симптом] [лечение] — это пример команды для медкарты. Команда /heal [id] [цена] лечит игрока. Посмотрите, как формируются команды в примерах. Затем вы можете изменить текст каждой команды, добавив свои варианты. Если у вас есть вопросы по настройке, вы можете обратиться к документации или спросить на форуме.\n\nКратко о том, как это работает: вы пишете команду, например: /heal {arg1} {priceheal}, и при выполнении скрипт подставит нужные значения. Например, если вы нацелились на игрока с ID "24", а цена лечения указана "5000", то выполнится: /heal 24 5000\n{priceheal} — это переменная, которая берётся из настроек цен.\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 350))
				imgui.TextWrapped(u8'Всё просто. Не так ли? Перейдём к другому примеру: вы можете использовать переменные для подстановки имён, сумм и т.д. Например, переменные: {myID}, {myNick}, {myHP}. Разумеется, что переменные можно использовать в любых сообщениях. Также есть специальные функции, например "диалоговые окна" и "подстановка пола". Если вы не понимаете назначение переменных, то рекомендуем изучить документацию.\n\nТакже вы можете использовать блоки "диалоговое окно" для отображения выбора. Они очень удобны в работе. Всё просто: создаёте шаблон, указываете варианты и действия.\n\nЕсли вы хотите создать диалоговое окно, это делается так: создаёте блок {dialog}...{dialogEnd}, внутри которого перечисляете варианты, каждый с пометкой [1]=, [2]= и т.д. После выбора варианта выполняется соответствующая команда. Для отмены используйте кнопку "Отмена".\n\nТакже, если вы хотите использовать переменные внутри диалогов, например {var1}, вы можете их задать заранее.\n\nТеперь рассмотрим подробнее, как работают команды и диалоги.\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 630))
				imgui.TextWrapped(u8'\n\n1. Отправить в чат\n2. Нажать клавишу Enter\n3. Подменить диалог\n4. Отправить в рацию\n5. Выполнить команду\n\nПримеры для каждого пункта:\n\n1. Функция "Отправить в чат" отправляет указанный текст в чат, как обычное сообщение. Вместо текста можно использовать переменные, например "Здравствуйте, как ваше самочувствие?" или "/me осматривает пациента на предмет травм". Если вы хотите использовать форматирование с цветами, используйте {var1} с подстановкой значения, например "Стоимость лечения составит {var1}$" где {var1} берётся из настроек цены. Если установить цену "25000", то получится "Стоимость лечения составит 25000$". Всё просто.\n\n2. Функция "Нажать клавишу Enter" эмулирует нажатие. Это может понадобиться для продолжения диалога или закрытия окна.\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 970))
				imgui.TextWrapped(u8'3. Функция "Подменить диалог" автоматически отвечает на диалоговое окно, чтобы вы не ждали ответа игрока. При этом можно выбрать нужный пункт меню. Для этого используется переменная "Переменная диалога", затем, в зависимости от выбора, подставляется значение. Обратите внимание на синтаксис: {dialog1} и {dialog2} и т.д. Если вы хотите использовать несколько диалогов, просто создайте несколько блоков {dialog1}, {dialog2} и т.д. Если вам нужно, чтобы после выбора первого диалога открывался второй, просто вставьте в первом блоке команду, которая откроет второй диалог. Также можно использовать вложенные диалоги, но это сложнее.\n\nЕсли вы не понимаете, как работают диалоги, просто посмотрите примеры в разделе "Команды" и попробуйте воспроизвести их. После того, как разберётесь, вы сможете создавать свои сценарии.\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 1300))
				imgui.TextWrapped(u8'4. Функция "Отправить в рацию" отправляет сообщение в рацию без добавления лишнего текста. Если нужно, можно добавить переменные.\n\n5. Функция "Выполнить команду" выполняет любую игровую команду, которую вы укажете. Это может быть полезно для автоматизации рутинных действий.\n\nПомимо этого есть ещё одна опция "Игнорировать действия при диалоге". Она позволяет не отправлять команды, пока открыто диалоговое окно, чтобы избежать ошибок. Рекомендуется включать её, если вы часто используете диалоги.')
			elseif activebutanim[3] == 6 then
				imgui.TextWrapped(u8'    Эта опция отвечает за автоматическое открытие шпаргалки при запуске скрипта, чтобы вы могли быстро ознакомиться с основными командами и функциями.')
			elseif activebutanim[3] == 7 then
				imgui.TextWrapped(u8'    Биндер - это инструмент, который позволяет создавать свои собственные макросы, которые можно привязать к клавишам или командам, чтобы ускорить выполнение повседневных задач.\n\nВот несколько примеров использования. Сначала нужно создать новый биндер и задать ему имя. После этого можно добавлять команды, которые будут выполняться последовательно. Если вы хотите, чтобы биндер запускался по нажатию клавиши, назначьте ему горячую клавишу.\n\nТакже есть возможность использовать биндер для автоматического ответа на сообщения, например, для отправки стандартных фраз.\n\nДля редактирования биндера откройте его, нажмите "Редактировать" и измените содержимое. Не забудьте сохранить изменения.\n\nЕсли вы хотите создать сложный макрос с условиями, используйте переменные и диалоги.\n\nТаким образом, биндер — это мощный инструмент для автоматизации.')
			elseif activebutanim[3] == 8 then
				imgui.TextWrapped(u8'    Если вы столкнулись с проблемами при работе с биндерами, проверьте, что все файлы находятся в нужной папке и что они не повреждены. Возможно, стоит пересоздать биндер заново, если он не работает.')
			elseif activebutanim[3] == 9 then
				imgui.TextWrapped(u8'    Если кто-то не отвечает на ваши действия, вы можете написать ему в личные сообщения и предложить помощь. Если проблема серьёзная, сообщите администрации сервера, чтобы они приняли меры. В крайнем случае, можно обратиться в поддержку на форуме.')
			elseif activebutanim[3] == 10 then
				imgui.TextWrapped(u8'    Да, если возникают трудности с биндерами, вы всегда можете воспользоваться готовыми примерами, которые есть в разделе /binder. Попробуйте скопировать их и адаптировать под свои нужды.')
			elseif activebutanim[3] == 11 then
				imgui.TextWrapped(u8'    В этом разделе вы можете настроить внешний вид интерфейса: изменить цвета, размеры шрифтов и расположение элементов. Все изменения сохраняются автоматически.')
			elseif activebutanim[3] == 12 then
				imgui.TextWrapped(u8'    Музыка — это отличная возможность. В разделе "Музыка и радио" вы можете слушать онлайн-радио или загружать свои треки, если они есть. Если трек не воспроизводится, возможно, он недоступен, и вы можете попробовать другой источник. В разделе "Сохранённые" можно управлять своим плейлистом.\n\nЕсли вы хотите поделиться плейлистом с друзьями, просто сохраните его в файл и отправьте.')
			elseif activebutanim[3] == 13 then
				imgui.TextWrapped(u8'    Если в биндере возникла ошибка при сохранении, проверьте, что у вас есть права на запись в папку Moonloader. Также проблема может быть из-за занятости файла другим процессом. Если ничего не помогает - перезагрузите скрипт. Для этого используйте команду "Обновить".')
			elseif activebutanim[3] == 14 then
				imgui.TextWrapped(u8'    Ну, если ответ на ваш вопрос не найден, вы можете задать его на форуме. В зависимости от сложности, вам помогут либо другие игроки, либо разработчики. В любом случае, вы всегда можете обратиться в личные сообщения к администрации или разработчикам.')
			elseif activebutanim[3] == 15 then
				imgui.TextWrapped(u8'    Здесь можно изменить настройки языка интерфейса, если вы не хотите использовать русский. Если что-то непонятно в настройках, попробуйте переключить язык на английский и обратно. Иногда это помогает понять назначение параметров.')
			elseif activebutanim[3] == 16 then
				imgui.TextWrapped(u8'    В случае, если скрипт вызывает лаги или фризы, можно отключить некоторые функции, например, анимации. В настройках есть пункт "Отключить анимации", который может помочь. Также можно уменьшить частоту обновления некоторых элементов.')
			elseif activebutanim[3] == 17 then
				imgui.TextWrapped(u8'    Если у вас возникли проблемы с отображением интерфейса на 4K мониторе, можно изменить масштаб шрифта. Для этого есть ползунок "Масштаб интерфейса" в разделе "Настройки". Также можно изменить расположение окон, если они выходят за пределы экрана. Для этого используйте кнопку "Переместить" в настройках профиля. Если вы не можете добраться до кнопки, попробуйте изменить разрешение экрана или настройки DPI.')
			elseif activebutanim[3] == 18 then
				imgui.TextWrapped(u8'    Если вы столкнулись с проблемами при игре в 1-4 часа ночи, вы можете использовать команду для отображения времени. Также есть возможность включить автоматическое приветствие и другие функции. Если вы администратор, у вас есть доступ к дополнительным командам.\n\nЕсли проблемы, обратитесь в поддержку, они помогут вам с настройкой и ответят на вопросы.\n\nЕсли вы не уверены в настройках, лучше оставить значения по умолчанию.')
			elseif activebutanim[3] == 19 then
				imgui.TextWrapped(u8'    Если вы администратор 1-4 уровня, вы можете управлять составом организации, выдавать ранги и т.д. Если вы 5-8 уровня, вам доступны расширенные функции, такие как управление финансами и настройка организационных команд. Подробности читайте в документации.')
			elseif activebutanim[3] == 20 then
				imgui.TextWrapped(u8'    Собеседование (СОБ) — это процесс проверки игрока для приёма в организацию. Он включает в себя вопросы о знании правил, опыте и т.д.\n\nНапример, вы беседуете с игроком и спрашиваете, знает ли он правила и как они применяются. Если кандидат отвечает правильно, вы его принимаете. Собеседование проводится в формате Role Play, поэтому важно соблюдать атмосферу.\n\nСобеседование проводится в диалоговом режиме, поэтому вы можете использовать заготовленные шаблоны. Также вы можете использовать переменные для подстановки имён и другой информации.\n\nВо время СОБ вы можете задавать вопросы, проверять документы и принимать решение.\n\nПодробнее читайте в разделе "Собеседование".')
			elseif activebutanim[3] == 21 then
				imgui.TextWrapped(u8'    Основы правильного Role Play в игре, которые помогут вам избежать нарушений:\n\n1. Соблюдайте игровой реализм. Все действия должны быть обоснованы в рамках игрового мира, даже если это связано с магией. Это делает игровой процесс более увлекательным.\n2. Относитесь к другим игрокам с уважением. Role Play — это совместное творчество, которое требует взаимодействия между игроками. Если вы злитесь, не стоит выплёскивать эмоции на других, лучше обсудить ситуацию.\n3. Изучайте правила и не нарушайте их. Нарушение правил (MG) может испортить игру и вызвать конфликты. Старайтесь избегать ситуаций, которые могут привести к нарушению.\n\nПримеры правильного Role Play для врача:\n\n1. Отвечайте на вызовы и оказывайте помощь. Это одна из главных задач врача. Вы должны уметь принимать решения в сложных ситуациях.\n2. Соблюдайте субординацию и иерархию. Врачи имеют разные звания, и важно уважать старших по званию.\n3. Следуйте этике, которая принята в организации. Это поможет избежать конфликтов и создаст дружелюбную атмосферу.\n\nПомните, что Role Play — это творческий и увлекательный процесс. Соблюдайте правила и получайте удовольствие от игры.')
			end
			imgui.PopStyleColor(3)
			imgui.EndChild()
			
			if activebutanim[1] then 
				if positbut > -699 then
					positbut = positbut - 23
				else
					activebutanim[1] = false
					positbut = - 699
				end
			end
			
			if activebutanim[2] then 
				if positbut < 0 then
					positbut = positbut + 27
				else
					activebutanim[2] = false
					positbut = 0
				end
			end
		imgui.EndChild()
	end
	if select_menu[10] and not bassNOT then
		record = {'http://radio-srv1.11one.ru/record192k.mp3', 'http://radiorecord.hostingradio.ru/mix96.aacp', 'http://radiorecord.hostingradio.ru/party96.aacp', 'http://radiorecord.hostingradio.ru/phonk96.aacp', 'http://radiorecord.hostingradio.ru/gop96.aacp', 'http://radiorecord.hostingradio.ru/rv96.aacp', 'http://radiorecord.hostingradio.ru/dub96.aacp', 'http://radiorecord.hostingradio.ru/bighits96.aacp', 'http://radiorecord.hostingradio.ru/organic96.aacp', 'http://radiorecord.hostingradio.ru/russianhits96.aacp', 'http://radiorecord.hostingradio.ru/gold96.aacp'}
		action = require('moonloader').audiostream_state
		imgui.SameLine()
		if imgui.InvisibleButton(u8"##Поиск в интернете", imgui.ImVec2(227, 30)) then select_menu_music = 1 end
		imgui.SetCursorPos(imgui.ImVec2(156, 40))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and select_menu_music ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 9)
		elseif imgui.IsItemHovered() and select_menu_music ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 9)
		elseif select_menu_music ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 9)
		elseif select_menu_music == 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(colButActiveMenu), 10, 9)
		end
		imgui.SameLine()
		if imgui.InvisibleButton(u8"##Сохранённые", imgui.ImVec2(227, 30)) then select_menu_music = 2 end
		imgui.SetCursorPos(imgui.ImVec2(384, 40))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and select_menu_music ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and select_menu_music ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif select_menu_music ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif select_menu_music == 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(colButActiveMenu))
		end
		imgui.SameLine()
		if imgui.InvisibleButton(u8"Радио Record", imgui.ImVec2(227, 30)) then select_menu_music = 3 end
		imgui.SetCursorPos(imgui.ImVec2(612, 40))
		p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and select_menu_music ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 6)
		elseif imgui.IsItemHovered() and select_menu_music ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 6)
		elseif select_menu_music ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 6)
		elseif select_menu_music == 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(colButActiveMenu), 10, 6)
		end
		imgui.SetCursorPos(imgui.ImVec2(209, 47))
		imgui.Text(u8"Поиск в интернете")
		imgui.SetCursorPos(imgui.ImVec2(463, 47))
		imgui.Text(u8"Сохранённые")
		imgui.SetCursorPos(imgui.ImVec2(682, 47))
		imgui.Text(u8"Радио Record")
		imgui.SetCursorPos(imgui.ImVec2(153, 78))
		imgui.BeginChild("separator", imgui.ImVec2(0, 2), false)
		imgui.Separator()
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(150, 79))
		if select_menu_music == 1 and not effilNOT then
			
			imgui.SetCursorPos(imgui.ImVec2(150, 80))
			imgui.BeginChild("musical", imgui.ImVec2(0, 320), false)
			imgui.SetCursorPos(imgui.ImVec2(7, 8))
			if #tracks.link > 10 then
				imgui.PushItemWidth(609)
			else
				imgui.PushItemWidth(618)
			end
			if imgui.InputText(u8"##Поиск музыки", buf_find_music, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%w+%s+]+")) then end
			if not imgui.IsItemActive() and buf_find_music.v == "" then
				imgui.SameLine()
				imgui.SetCursorPos(imgui.ImVec2(15, 7))
				imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите название песни");
			end
			imgui.SameLine()
			if #tracks.link > 10 then
				imgui.SetCursorPos(imgui.ImVec2(620, 8))
			else
				imgui.SetCursorPos(imgui.ImVec2(629, 8))
			end
			if imgui.Button(u8"Искать", imgui.ImVec2(60, 21)) then
				if buf_find_music.v ~= "" then
					tracks = {
						link = {},
						artist = {},
						name = {},
						time = {},
						image = {}
					}
					selectis = 0
					find_track_link(buf_find_music.v)
				end
			end
			imgui.SetCursorPosY(40)
			if #tracks.link > 0 and tracks.link[1] ~= "error404" then
				for i = 1, #tracks.link do
					im = i
					checktrack = 1
					for hy = 1, #save_tracks.link do
						if save_tracks.link[hy] == tracks.link[im] then
							checktrack = 2
							tracknim = hy
							break
						end
					end
					imgui.SetCursorPosY(13 + (im * 35))
					if imgui.InvisibleButton(fa.ICON_PLUS..i,imgui.ImVec2(25, 25)) then
						if checktrack == 1 then
							table.insert(save_tracks.link, 1, tracks.link[i])
							table.insert(save_tracks.artist, 1, tracks.artist[i])
							table.insert(save_tracks.name, 1, tracks.name[i])
							table.insert(save_tracks.time, 1, tracks.time[i])
							table.insert(save_tracks.image, 1, tracks.image[i])
							f = io.open(dirml.."/MedicalHelper/шпаргалки.med", "w")
							f:write(encodeJson(save_tracks))
							f:flush()
							f:close()
							if selectis ~= 0 and status_track_pl ~= "STOP" and menu_play_track[2] then
								selectis = selectis + 1
								statusimage = statusimage + 1
							end
						end
						if checktrack == 2 then
							 checktracknext = save_tracks.link[tracknim]
							table.remove(save_tracks.link, tracknim)
							table.remove(save_tracks.artist, tracknim)
							table.remove(save_tracks.name, tracknim)
							table.remove(save_tracks.time, tracknim)
							table.remove(save_tracks.image, tracknim)
							f = io.open(dirml.."/MedicalHelper/шпаргалки.med", "w")
							f:write(encodeJson(save_tracks))
							f:flush()
							f:close()
							if selectis ~= 0 and menu_play_track[2] then
								if tracknim <= selectis and selectis ~= 1 and tracknim ~= selectis and #save_tracks.link ~= 0 then
									selectis = selectis - 1
									statusimage = selectis
								elseif tracknim == #save_tracks.link+1 and selectis == tracknim and #save_tracks.link ~= 0 then
									selectis = selectis - 1
									imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
									play_song(save_tracks.link[selectis], false)
								elseif tracknim == selectis and tracknim ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
									imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
									play_song(save_tracks.link[selectis], false)
								end
								if #save_tracks.link == 0 then
									action_song('STOP')
								end
							end
						end
					end
					if imgui.IsItemHovered() then
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						if checktrack == 1 then
							imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_PLUS.." ")
						else
							imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS.." ")
						end
					else
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						if checktrack == 1 then
							imgui.Text(fa.ICON_PLUS.." ")
						else
							imgui.Text(fa.ICON_CHECK.." ")
						end
					end
					imgui.GetCursorStartPos()
					imgui.SameLine()
					imgui.SetCursorPosX(31)
					if selectis == i and menu_play_track[1] then
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 42):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 52):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 37):GetVec4())
					else
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 25):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 35):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 15):GetVec4())
					end
					imgui.SetCursorPosY(5 + (im * 35))
					if imgui.Button(u8"##MusicFindTrack"..i, imgui.ImVec2(645, 30)) then
						menuu = {}
						menuu = menu_play_track
						tracknames = tracks.artist[i].." - "..tracks.name[i]
						tracknames_art = tracks.artist[i]
						tracknames_nm = tracks.name[i]
						menu_play_track = {true, false, false}
						if (selectis ~= i and menuu[1]) or not menuu[1] then
							imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
							selectis = i
							play_song(tracks.link[im], false)
							status_track_pl = "PLAY"
						elseif status_track_pl == "PAUSE" and menuu[1] then
							status_track_pl = "PLAY"
							action_song("PLAY")
						elseif status_track_pl == "PLAY" and menuu[1] then
							status_track_pl = "PAUSE"
							action_song("PAUSE")
						end
					end
					imgui.PopStyleColor(3)
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(9 + (im * 35))
					if i ~= selectis or (status_track_pl == "PAUSE" and menu_play_track[1]) then
						imgui.Text(fa.ICON_PLAY)
					elseif status_track_pl == "PLAY" and menu_play_track[1] then
						imgui.Text(fa.ICON_PAUSE)
					elseif status_track_pl == "PLAY" and menu_play_track[1] then
						imgui.Text(fa.ICON_PLAY)
					elseif not menu_play_track[1] then
						imgui.Text(fa.ICON_PLAY)
					end
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(8 + (im * 35))
					textsize = "     {FFFFFF}"..tracks.artist[i].."{BDBDBD}  �  {BDBDBD}"..tracks.name[i]
					if #textsize > 107 then
						textsize = string.sub(textsize, 1, 107) .. ".."
					end
					imgui.TextColoredRGB(textsize)
					imgui.SameLine()
					imgui.SetCursorPosX(630)
					imgui.SetCursorPosY(8 + (im * 35))
					imgui.TextColoredRGB("{FFFFFF}"..tracks.time[i])
				end
			elseif tracks.link[1] == "error404" then
				selectis = 0
				imgui.SetCursorPosX(15)
				imgui.Text(u8"Не найдено ни одного трека. Возможные причины:\n\n1. В запросе допущена ошибка.\n2. Провайдер ограничивает доступ к сайту.\n3. Сайт временно недоступен или изменил адрес.")
			else
				imgui.SetCursorPosX(15)
				imgui.Text(u8"Произошла ошибка при поиске треков. Пожалуйста, попробуйте позже.")
			end
			imgui.EndChild()
		elseif select_menu_music == 1 and effilNOT then
			imgui.SetCursorPosX(155)
			imgui.SetCursorPosY(90)
			imgui.Text(u8"Модуль effil не установлен. Пожалуйста, установите его для использования этой функции.\n\nДля установки модуля effil, загрузите его из репозитория и поместите в папку \"lib\".")
		end
		if select_menu_music == 2 then
			imgui.SetCursorPos(imgui.ImVec2(150, 90))
			imgui.BeginChild("musicsave", imgui.ImVec2(0, 310), false)
			imgui.SetCursorPos(imgui.ImVec2(7, 8))
			if #save_tracks.link > 0 then
				for i = 1, #save_tracks.link do
					im = i
					imgui.SetCursorPosY(13 + ((im-1) * 35))
					if imgui.InvisibleButton(fa.ICON_PLUS..i.."n",imgui.ImVec2(25, 25)) then
						table.remove(save_tracks.link, i)
						table.remove(save_tracks.artist, i)
						table.remove(save_tracks.name, i)
						table.remove(save_tracks.time, i)
						table.remove(save_tracks.image, i)
						f = io.open(dirml.."/MedicalHelper/шпаргалки.med", "w")
						f:write(encodeJson(save_tracks))
						f:flush()
						f:close()
						if selectis ~= 0 and menu_play_track[2] then
							if i <= selectis and selectis ~= 1 and i ~= selectis and #save_tracks.link ~= 0 then
								selectis = selectis - 1
								statusimage = selectis
							elseif i == #save_tracks.link+1 and selectis == i and #save_tracks.link ~= 0 then
								selectis = selectis - 1
								imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
								play_song(save_tracks.link[selectis], false)
							elseif i == selectis and i ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
								imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
								play_song(save_tracks.link[selectis], false)
							end
							if #save_tracks.link == 0 then
								action_song('STOP')
								selectis = 0
							end
							break
						end
						if selectis == 0 then
							break
						end
					end
					
					if imgui.IsItemHovered() then
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS.." ")
					else
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						imgui.Text(fa.ICON_MINUS.." ")
					end
					imgui.GetCursorStartPos()
					imgui.SameLine()
					imgui.SetCursorPosX(31)
					if selectis == i and menu_play_track[2] then
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 42):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 52):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 37):GetVec4())
					else
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 25):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 35):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 15):GetVec4())
					end
					imgui.SetCursorPosY(5 + ((im-1) * 35))
					if imgui.Button(u8"##MusicSaveTrack"..i, imgui.ImVec2(645, 30)) then
						menuu = {}
						menuu = menu_play_track
						tracknames = save_tracks.artist[i].." - "..save_tracks.name[i]
						tracknames_art = save_tracks.artist[i]
						tracknames_nm = save_tracks.name[i]
						menu_play_track = {false, true, false}
						if (selectis ~= i and menuu[2]) or not menuu[2] then
							imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
							selectis = i
							play_song(save_tracks.link[im], false)
							status_track_pl = "PLAY"
						elseif status_track_pl == "PAUSE" and menuu[2] then
							status_track_pl = "PLAY"
							action_song("PLAY")
						elseif status_track_pl == "PLAY" and menuu[2] then
							status_track_pl = "PAUSE"
							action_song("PAUSE")
						end
					end
					imgui.PopStyleColor(3)
			
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(9 + ((im-1) * 35))
					if i ~= selectis or (status_track_pl == "PAUSE" and menu_play_track[2]) then
						imgui.Text(fa.ICON_PLAY)
					elseif status_track_pl == "PLAY" and menu_play_track[2] then
						imgui.Text(fa.ICON_PAUSE)
					elseif status_track_pl == "PLAY" and menu_play_track[2] then
						imgui.Text(fa.ICON_PLAY)
					elseif not menu_play_track[2] then
						imgui.Text(fa.ICON_PLAY)
					end
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(8 + ((im-1) * 35))
					textsize = "     {FFFFFF}"..save_tracks.artist[i].."{BDBDBD}  -  {BDBDBD}"..save_tracks.name[i]
					if #textsize > 107 then
						textsize = string.sub(textsize, 1, 107) .. ".."
					end
					imgui.TextColoredRGB(textsize)
					imgui.SameLine()
					imgui.SetCursorPosX(630)
					imgui.SetCursorPosY(8 + ((im-1) * 35))
					imgui.TextColoredRGB("{FFFFFF}"..save_tracks.time[i])
				end
			elseif #save_tracks.link == 0 then
				imgui.SetCursorPosX(15)
				imgui.Text(u8"Не найдено ни одного сохраненного трека. Пожалуйста, добавьте треки в раздел \"Сохраненные\".")
			end
			imgui.EndChild()
		end
		if select_menu_music == 3 then -- 125 138   pos -> 15 13
			function background_record_card(posX_R, posY_R, i_R)
				imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
				if imgui.InvisibleButton(u8"##Record RADIO"..i_R, imgui.ImVec2(125, 145)) then
					selectis = 0
					menu_play_track = {false, false, true}
					if select_music ~= i_R then
						select_music = i_R
						play_song(record[i_R])
					elseif status_track_pl == 'PLAY' then
						action_song('PAUSE')
					elseif status_track_pl == 'PAUSE' then
						action_song('PLAY')
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
				p = imgui.GetCursorScreenPos()
				if select_music ~= i_R then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				elseif select_music == i_R then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.99, 0.35, 0.12 ,0.90)), 10, 15)
				end
				if imgui.IsItemActive() then	
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 15)
				elseif imgui.IsItemHovered() and select_music ~= i_R then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.20, 0.20, 0.20 ,1.00)), 10, 15)
				end
				imgui.SetCursorPos(imgui.ImVec2(posX_R + 16, posY_R + 2))
				imgui.Image(imgRECORD[i_R], imgui.ImVec2(94, 94))
				calc = imgui.CalcTextSize(u8(record_text_name[i_R]))
				imgui.SetCursorPos(imgui.ImVec2(posX_R + (63 - calc.x / 2 ), posY_R + 109))
				imgui.Text(u8(record_text_name[i_R]))
			end
			imgui.BeginChild("musicrecord", imgui.ImVec2(0, 320), false)
			--> Record Dance
			background_record_card(15, 13, 1)
			background_record_card(151, 13, 2)
			background_record_card(287, 13, 3)
			background_record_card(423, 13, 4)
			background_record_card(559, 13, 5)
			
			background_record_card(15, 166, 6)
			background_record_card(151, 166, 7)
			background_record_card(287, 166, 8)
			background_record_card(423, 166, 9)
			background_record_card(559, 166, 10)
			
			imgui.EndChild()
		end
		imgui.SetCursorPos(imgui.ImVec2(159, 400))
		p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 685, p.y + 55), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
		imgui.GetCursorStartPos()
		function convert(param)
			param = tonumber(param)*100
			return round(param, 1)
		end
		imgui.PushFont(fa_font_mus)
		if status_track_pl == "PAUSE" then
			imgui.SetCursorPos(imgui.ImVec2(199, 412))
			if imgui.InvisibleButton(u8"##PLAYMUSIC", imgui.ImVec2(30, 30)) then 
				if get_status_potok_song() ~= 0 then
					action_song("PLAY")
					status_track_pl = "PLAY"
				end
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_PLAY_CIRCLE_O)
			else
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PLAY_CIRCLE_O)
			end
		elseif status_track_pl == "PLAY" then
			imgui.SetCursorPos(imgui.ImVec2(199, 412))
			if imgui.InvisibleButton(u8"##STOPMUSIC", imgui.ImVec2(30, 30)) then
				action_song("PAUSE")
				status_track_pl = "PAUSE"
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_PAUSE_CIRCLE_O)
			else
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PAUSE_CIRCLE_O)
			end
		elseif status_track_pl == "STOP" then 
			imgui.SetCursorPos(imgui.ImVec2(200, 410))
			imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.50), fa.ICON_PLAY_CIRCLE_O)
		end
		imgui.PopFont()
		imgui.PushFont(fa_font)
		if status_track_pl ~= "STOP" and select_music == 0 then 
			imgui.SetCursorPos(imgui.ImVec2(174, 418))
			if imgui.InvisibleButton(u8"##BACKMUSIC", imgui.ImVec2(19, 18)) then
				back_track()
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(175, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_BACKWARD)
			else
				imgui.SetCursorPos(imgui.ImVec2(175, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_BACKWARD)
			end
			imgui.SetCursorPos(imgui.ImVec2(235, 418))
			if imgui.InvisibleButton(u8"##NEXTMUSIC", imgui.ImVec2(19, 18)) then
				next_track()
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(239, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_FORWARD)
			else
				imgui.SetCursorPos(imgui.ImVec2(239, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_FORWARD)
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(175, 420))
			imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.50), fa.ICON_BACKWARD)
			imgui.SetCursorPos(imgui.ImVec2(239, 420))
			imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.50), fa.ICON_FORWARD)
		end
		imgui.PopFont()
		if status_track_pl ~= "STOP" then
			if selectis ~= 0 and menu_play_track[1] then
				textsizel = "{FFFFFF}"..tracks.name[selectis]
				textsizela = "{BDBDBD}"..tracks.artist[selectis]
				if #textsizel > 57 then
					textsizel = string.sub(textsizel, 1, 57) .. "..."
				end
				if #textsizela > 57 then
					textsizela = string.sub(textsizela, 1, 57) .. "..."
				end
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB(textsizel)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB(textsizela)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				if statusimage == selectis then
					imgui.Image(imgLabel, imgui.ImVec2(46, 46))
				else
					imgui.Image(imgNoLabel, imgui.ImVec2(46, 46))
				end
			elseif selectis ~= 0 and menu_play_track[2] then
				textsizel = "{FFFFFF}"..save_tracks.name[selectis]
				textsizela = "{BDBDBD}"..save_tracks.artist[selectis]
				if #textsizel > 57 then
					textsizel = string.sub(textsizel, 1, 57) .. "..."
				end
				if #textsizela > 57 then
					textsizela = string.sub(textsizela, 1, 57) .. "..."
				end
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB(textsizel)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB(textsizela)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				if statusimage == selectis then
					imgui.Image(imgLabel, imgui.ImVec2(46, 46))
				else
					imgui.Image(imgNoLabel, imgui.ImVec2(46, 46))
				end
			elseif select_music ~= 0 then
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB("{FFFFFF}"..record_text_name[select_music])
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB("{BDBDBD}Record")
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				imgui.Image(imgRECORD[select_music], imgui.ImVec2(46, 46))
			elseif selectis == 0 and select_music == 0 and status_track_pl ~= 'STOP' then
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				imgui.Image(imgLabel, imgui.ImVec2(46, 46))
			end
			if selectis == 0 and select_music == 0 then
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				imgui.Image(imgLabel, imgui.ImVec2(46, 46))
			end
		elseif selectis == 0 and not menu_play_track[3] then
			imgui.SetCursorPos(imgui.ImVec2(325, 403))
			imgui.TextColoredRGB("{FFFFFF}".."Ничего не играет")
			imgui.SetCursorPos(imgui.ImVec2(325, 420))
			imgui.TextColoredRGB("{BDBDBD}".."")
			imgui.SetCursorPos(imgui.ImVec2(267, 405))
			imgui.Image(imgNoLabel, imgui.ImVec2(46, 46))
		end
		imgui.SetCursorPos(imgui.ImVec2(325, 442))
		p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + Y_rewind), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(325, 442))
		p = imgui.GetCursorScreenPos()
		if get_status_potok_song() ~= 0 then --findmh
			function thetime()
				if timetr[1] < 10 then
					trt = "0"..timetr[1]
				else
					trt = timetr[1]
				end
				if timetr[2] < 10 then
					trt2 = "0"..timetr[2]
				else
					trt2 = timetr[2]
				end
				return trt2..":"..trt
			end
			if select_music == 0 then
				sizeXline = (timetr[2]*60+timetr[1])*timetri
				if sizeXline > 400 then
					sizeXline = 400
				end
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeXline, p.y + Y_rewind), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 9)
				imgui.SetCursorPos(imgui.ImVec2(690, 421))
				imgui.TextColoredRGB("{FFFFFF}"..thetime())
				imgui.SetCursorPos(imgui.ImVec2(325, 442))
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + Y_rewind), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 15)
			end 
		end
		imgui.PushFont(fa_font)
		
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(255, 255, 255, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(255, 255, 255, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(255, 255, 255, 0):GetVec4())
		imgui.SetCursorPos(imgui.ImVec2(315, 434))
		imgui.PushItemWidth(419)
		if imgui.SliderFloat(u8"##Перемотка трека", sectime_track, 0, track_time_hc - 2, u8"") then
			rewind_song(sectime_track.v)
		end
		if imgui.IsItemHovered() then
			if Y_rewind < 9 then
				Y_rewind = Y_rewind + 0.5
			end
		else
			if Y_rewind > 5 then
				Y_rewind = Y_rewind - 0.5
			end
		end
		
		imgui.PopStyleColor(3)
		
		imgui.SetCursorPos(imgui.ImVec2(761, 410))
		if imgui.InvisibleButton(u8"##REPEATMUSIC", imgui.ImVec2(19, 18)) then
			repeatmusic.v = not repeatmusic.v
		end
		if imgui.IsItemHovered() then
			imgui.SetCursorPos(imgui.ImVec2(764, 412))
			imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_REPEAT)
		else
			imgui.SetCursorPos(imgui.ImVec2(764, 412))
			if repeatmusic.v then
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,1.00), fa.ICON_REPEAT)
			else
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.45), fa.ICON_REPEAT)
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(787, 410))
		if imgui.InvisibleButton(u8"##DONWSCREENPLAYER", imgui.ImVec2(19, 18)) then
			player_HUD.v = not player_HUD.v
		end
		if imgui.IsItemHovered() then
			imgui.SetCursorPos(imgui.ImVec2(789, 412))
			imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_WINDOW_MAXIMIZE)
		else
			imgui.SetCursorPos(imgui.ImVec2(789, 412))
			if player_HUD.v then
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,1.00), fa.ICON_WINDOW_MAXIMIZE)
			else
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.45), fa.ICON_WINDOW_MAXIMIZE)
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(813, 411))
		if imgui.InvisibleButton(u8"##ENDSTOPMUSIC", imgui.ImVec2(19, 18)) then
			if status_track_pl ~= "STOP" and get_status_potok_song() ~= 0 then
				action_song("STOP")
				status_track_pl = "STOP"
			end
		end
		if imgui.IsItemHovered() then
			if status_track_pl ~= "STOP" then
				imgui.SetCursorPos(imgui.ImVec2(816, 412))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_STOP)
			else
				imgui.SetCursorPos(imgui.ImVec2(816, 412))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.40), fa.ICON_STOP)
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(816, 412))
			if status_track_pl == "STOP" then
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.40), fa.ICON_STOP)
			else
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,1.00), fa.ICON_STOP)
			end	
		end
		imgui.PopFont()
		imgui.SetCursorPos(imgui.ImVec2(740, 437))
		if volume_music.v >= 0.7 then
			imgui.Text(fa.ICON_VOLUME_UP)
		elseif volume_music.v >= 0.2 and volume_music.v < 0.7 then
			imgui.Text(fa.ICON_VOLUME_DOWN)
		elseif volume_music.v < 0.2 then
			imgui.Text(fa.ICON_VOLUME_OFF)
		end
		imgui.SetCursorPos(imgui.ImVec2(760, 432))
		imgui.PushItemWidth(80)
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
		if imgui.SliderFloat(u8"##Громкость", volume_music, 0, 2, u8"") then 
			if status_track_pl ~= "STOP" then
				volume_song(volume_music.v)
			end
		end
		imgui.PopStyleColor(3)
		imgui.PopItemWidth()
		imgui.SetCursorPos(imgui.ImVec2(760, 442))
		p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 75, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(760, 442))
		p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (convert(volume_music.v)/2.66), p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 10, 15)
	elseif bassNOT and select_menu[10] then
		imgui.SetCursorPosX(155)
		imgui.SetCursorPosY(210)
		imgui.Text(u8"Необходимая библиотека отсутствует. Установите библиотеку \"bass.lua\" \n\nСкачайте файл и поместите в папку lib для дальнейшей работы скрипта.")
	end
	if select_menu[9] then
		function TheBackground(IsItem, posX, posY, sizeX, sizeY, rounding, flag)
			imgui.SetCursorPos(imgui.ImVec2(posX, posY))
			p = imgui.GetCursorScreenPos()
			if IsItem == 1 then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + sizeY), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), rounding, flag)
			elseif IsItem == 2 then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + 2), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			end
		end
		TheBackground(1, 390, 40, 222, 50, 10, 15)
		TheBackground(1, 165, 77, 675, 166, 10, 15)
		TheBackground(1, 165, 253, 675, 140, 10, 15)
		TheBackground(1, 165, 403, 675, 47, 10, 15)
		TheBackground(2, 165, 113, 675, 2, 0, 0)
		TheBackground(2, 165, 187, 675, 2, 0, 0)
		imgui.SetCursorPos(imgui.ImVec2(429, 50))
		imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), "Medical Helper by Kane")
		imgui.SetCursorPos(imgui.ImVec2(176, 86))
		imgui.Text(u8"Этот скрипт создан для сервера Arizona Role Play и упрощает работу медицинского персонала.")
		imgui.SetCursorPos(imgui.ImVec2(176, 121))
		imgui.TextColoredRGB("Автор скрипта - {FFB700}Kane")
		imgui.SetCursorPos(imgui.ImVec2(176, 142))
		imgui.TextColoredRGB("Текущая версия - {FFB700}".. scr.version .. " год")
		imgui.SetCursorPos(imgui.ImVec2(176, 163))
		imgui.TextColoredRGB("Благодарности {32CD32}blast.hk{FFFFFF}, основателю {32CD32}Hatiko{FFFFFF} и тестеру {32CD32}Ilya Kustov{FFFFFF}.")
		imgui.SetCursorPos(imgui.ImVec2(176, 194))
		imgui.TextColoredRGB("Надеюсь, скрипт поможет вам на прекрасном проекте {32CD32}Arizona RP{FFFFFF}!")
		imgui.SetCursorPos(imgui.ImVec2(176, 215))
		imgui.TextColoredRGB("Если у вас возникли проблемы?")
		imgui.SameLine()
		imgui.TextColoredRGB("Напишите {74BAF4}разработчику скрипта.")
		if imgui.IsItemHovered() then imgui.SetTooltip(u8"Нажмите, чтобы скопировать, или ПКМ, чтобы открыть в браузере") end
		if imgui.IsItemClicked(0) then setClipboardText("https://vk.com/marseloy") end
		if imgui.IsItemClicked(1) then shell32.ShellExecuteA(nil, 'open', 'https://vk.com/marseloy', nil, nil, 1) end
		imgui.SetCursorPos(imgui.ImVec2(176, 262))
		imgui.TextColoredRGB("    Изначально {FF8FA2}Medical Helper{FFFFFF} создавался на основе старого скрипта {32CD32}Hatiko{FFFFFF}, но со временем")
		imgui.SetCursorPos(imgui.ImVec2(176, 283))
		imgui.TextColoredRGB("он претерпел значительные изменения, поэтому его можно считать самостоятельным.")
		imgui.SetCursorPos(imgui.ImVec2(176, 304))
		imgui.TextColoredRGB("Да, именно, оригинальный {32CD32}Hatiko{FFFFFF} больше не поддерживается и устарел.")
		imgui.SetCursorPos(imgui.ImVec2(176, 325))
		imgui.TextColoredRGB("Новый скрипт написан с учётом всех современных требований, использует")
		imgui.SetCursorPos(imgui.ImVec2(176, 346))
		imgui.TextColoredRGB("современные технологии, которые обеспечивают быструю работу и удобство")
		imgui.SetCursorPos(imgui.ImVec2(176, 367))
		imgui.TextColoredRGB("пользователя при выполнении любых медицинских процедур.")
		imgui.SetCursorPos(imgui.ImVec2(176, 413))
		if imgui.Button(u8"Выгрузить", imgui.ImVec2(215, 26)) then showCursor(false); scr:unload() end
		imgui.SameLine()
		if imgui.Button(u8"Перезагрузить", imgui.ImVec2(214, 26)) then showCursor(false); scr:reload() end
		imgui.SameLine()
		if imgui.Button(u8"Удалить скрипт", imgui.ImVec2(214, 26)) then 
			addOneOffSound(0, 0, 0, 1058)
			sampAddChatMessage("", 0xFF8FA2); sampAddChatMessage("", 0xFF8FA2); sampAddChatMessage("", 0xFF8FA2)
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Готово! Для полного удаления введите команду {77DF63}/mh-delete.", 0xFF8FA2)
			mainWin.v = false
		end
	if select_menu[7] then
		profitmoney()
	end

	imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
	if imgui.BeginPopupModal(u8"MH | Назначить клавишу для команды", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then		
		imgui.Text(u8"Нажмите на клавишу для привязки или для отмены нажмите ESC."); imgui.Separator()
		imgui.Text(u8"Допустимые клавиши:")
		imgui.Bullet()	imgui.TextDisabled(u8"Модификаторы - Alt, Ctrl, Shift")
		imgui.Bullet()	imgui.TextDisabled(u8"Буквенные клавиши")
		imgui.Bullet()	imgui.TextDisabled(u8"Функциональные клавиши F1-F12")
		imgui.Bullet()	imgui.TextDisabled(u8"Клавиши стрелок")
		imgui.Bullet()	imgui.TextDisabled(u8"Цифры Numpad")
		ButtonSwitch(u8"Использовать мышь с прокруткой в диалогах", cb_RBUT)
		imgui.Separator()
		if imgui.TreeNode(u8"Для дополнительных 5-кнопочных мышей") then
			ButtonSwitch(u8"X Button 1", cb_x1)
			ButtonSwitch(u8"X Button 2", cb_x2)
			imgui.Separator()
			imgui.TreePop();
		end
		imgui.Text(u8"Нажмите клавишу(и): ");
		imgui.SameLine();
		if imgui.IsMouseClicked(0) then
			lua_thread.create(function()
				wait(500)			
				setVirtualKeyDown(3, true)
				wait(0)
				setVirtualKeyDown(3, false)
			end)
		end
		if #(rkeys.getCurrentHotKey()) ~= 0 and not rkeys.isBlockedHotKey(rkeys.getCurrentHotKey()) then	
			if not rkeys.isKeyModified((rkeys.getCurrentHotKey())[#(rkeys.getCurrentHotKey())]) then
				currentKey[1] = table.concat(rkeys.getKeysName(rkeys.getCurrentHotKey()), " + ")
				currentKey[2] = rkeys.getCurrentHotKey()
			end
		end
		imgui.TextColored(imgui.ImColor(255, 205, 0, 200):GetVec4(), currentKey[1])
		if isHotKeyDefined then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данный ключ уже используется!")
		end
		if isHotKeyExists then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данная комбинация уже занята другой клавишей/командой!")
		end
		if imgui.Button(u8"Применить", imgui.ImVec2(150, 0)) then
			if select_menu[3] then
				if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
				if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
				if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
				if rkeys.isHotKeyExist(currentKey[2]) then 
					isHotKeyExists = true
				else
					rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
					unRegisterHotKey(cmdBind[selected_cmd].key)
					cmdBind[selected_cmd].key = currentKey[2]
					rkeys.registerHotKey(currentKey[2], true, onHotKeyCMD)
					table.insert(keysList, currentKey[2])
					currentKey = {"",{}}
					lockPlayerControl(false)
					cb_RBUT.v = false
					cb_x1.v, cb_x2.v = false, false
					isHotKeyExists = false
					imgui.CloseCurrentPopup();
					f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
					f:write(encodeJson(cmdBind))
					f:flush()
					f:close()
					editKey = false
				end	
			elseif select_menu[4] then
				if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
				if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
				if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
				if rkeys.isHotKeyExist(currentKey[2]) then 
					isHotKeyExists = true
				else	
					rkeys.unRegisterHotKey(binder.list[binder.select_bind].key)
					unRegisterHotKey(binder.list[binder.select_bind].key)
					binder.key = currentKey[2]
					lockPlayerControl(false)
					cb_RBUT.v = false
					cb_x1.v, cb_x2.v = false, false
					isHotKeyExists = false
					imgui.CloseCurrentPopup();
					editKey = false
				end
			end
		end
		imgui.SameLine();
		if imgui.Button(u8"Отменить", imgui.ImVec2(150, 0)) then 
			imgui.CloseCurrentPopup(); 
			currentKey = {"",{}}
			cb_RBUT.v = false
			cb_x1.v, cb_x2.v = false, false
			lockPlayerControl(false)
			isHotKeyExists = false
			editKey = false
		end 
		imgui.SameLine()
		if imgui.Button(u8"Очистить", imgui.ImVec2(150, 0)) then
			currentKey = {"",{}}
			cb_x1.v, cb_x2.v = false, false
			cb_RBUT.v = false
			isHotKeyExists = false
		end
		imgui.EndPopup()
	end

		if imgui.BeginPopupModal(u8"MH | Изменение команды", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.SetCursorPosX(70)
		imgui.Text(u8"Введите новую команду для этого бинда, затем нажмите применить."); imgui.Separator()
		imgui.Text(u8"Рекомендации:")
		imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Используйте только латинские буквы.")
		imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Если вы не укажете свою команду - бот будет работать некорректно.")
		imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Можно использовать буквы и цифры. Русские буквы нельзя.")
		if select_menu[4] then
			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Если вы используете команды {e3071d}/findihouse{00ff8c} и {e3071d}/findibiz {00ff8c}удачи в поиске!")
		end
		imgui.Text(u8"/");
		imgui.SameLine();
		imgui.PushItemWidth(520)
		imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%a]+"))
		if isHotKeyDefined then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данная команда уже используется!")
		end
		if russkieBukviNahyi then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Нельзя использовать русские буквы!")
		end
		if dlinaStroki then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Максимальная длина команды - 15 символов!")
		end
		if select_menu[3] then
			if imgui.Button(u8"Применить", imgui.ImVec2(174, 0)) then
				exits = false
				if chgName.inp.v:find("%A") then
					russkieBukviNahyi = true
					isHotKeyDefined = false
					dlinaStroki = false
					exits = true
				elseif chgName.inp.v:len() > 15 then
					dlinaStroki = true
					russkieBukviNahyi = false
					isHotKeyDefined = false
					exits = true
				end
				for i,v in ipairs(binder.list) do
					if binder.list[i].cmd == chgName.inp.v then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
					if chgName.inp.v == binder.cmd.v then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				for i,v in ipairs(cmdBind) do
					if v.cmd == chgName.inp.v and chgName.inp.v ~= cmdBind[selected_cmd].cmd then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				if not exits then
					if cmdBind[selected_cmd].cmd == chgName.inp.v then
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						imgui.CloseCurrentPopup();
					else
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						cmdBind[selected_cmd].cmd = chgName.inp.v
						imgui.CloseCurrentPopup();
						f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
						f:write(encodeJson(cmdBind))
						f:flush()
						f:close()
						sampRegCMD()
						sampUnregisterChatCommand(unregcmd)
						editKey = false
					end
				end
			end
		end			
		if select_menu[4] then
			if imgui.Button(u8"Применить", imgui.ImVec2(174, 0)) then
				exits = false
				if chgName.inp.v:find("%A") then
					russkieBukviNahyi = true
					isHotKeyDefined = false
					dlinaStroki = false
					exits = true
				elseif chgName.inp.v:len() > 15 then
					dlinaStroki = true
					russkieBukviNahyi = false
					isHotKeyDefined = false
					exits = true
				end
				for i,v in ipairs(cmdBind) do
					if v.cmd == chgName.inp.v then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				for i,v in ipairs(binder.list) do
					if binder.list[i].cmd == chgName.inp.v and chgName.inp.v ~= binder.cmd.v and chgName.inp.v ~= "" then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				if not exits then
					if binder.cmd.v == chgName.inp.v then
						unregcmd = ""
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						imgui.CloseCurrentPopup();
					else
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						binder.cmd.v = chgName.inp.v
						imgui.CloseCurrentPopup();
						editKey = false
					end
				end
			end
		end				
		imgui.SameLine();
		if imgui.Button(u8"Отменить", imgui.ImVec2(174, 0)) then 
			imgui.CloseCurrentPopup(); 
			currentKey = {"",{}}
			cb_RBUT.v = false
			cb_x1.v, cb_x2.v = false, false
			lockPlayerControl(false)
			isHotKeyDefined = false
			russkieBukviNahyi = false
			dlinaStroki = false
			editKey = false
			unregcmd = ""
		end 
		imgui.SameLine()
		if select_menu[3] then
			if imgui.Button(u8"Восстановить исходную", imgui.ImVec2(174, 0)) then
				chgName.inp.v = list_cmd[selected_cmd]
				isHotKeyDefined = false
				russkieBukviNahyi = false
				dlinaStroki = false
			end
		end
		if select_menu[4] then
			if imgui.Button(u8"Очистить", imgui.ImVec2(174, 0)) then
				chgName.inp.v = ""
				isHotKeyDefined = false
				russkieBukviNahyi = false
				dlinaStroki = false
			end
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopupModal(u8"Ошибка", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
    imgui.Text(u8"Такое имя уже существует")
		imgui.SetCursorPosX(60)
		if imgui.Button(u8"ОК", imgui.ImVec2(120, 20)) then imgui.CloseCurrentPopup() end
		imgui.EndPopup()
	end	
	imgui.PopStyleColor(1)
	imgui.End()
end

function imgui.OnDrawFrame()
	if mainWin.v then
		mainWind()
	end
	if choiceWin.v then
		choiceWind()
	end
	if ReminderWin.v then
		sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(300, 130), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Напоминание", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse);
		imgui.SetCursorPosX(105)
		imgui.PushFont(fontsize)
		imgui.SetCursorPosY(6)
		imgui.Text(u8" Напоминание")
		imgui.PopFont()
		imgui.SameLine()
		imgui.SetCursorPosX(270)
		imgui.SetCursorPosY(6)
		if imgui.InvisibleButton(u8"closef", imgui.ImVec2(24, 24)) then
			if sound_reminder:status() ~= "dead" then
				sound_reminder:terminate()
			end
			ReminderWin.v = false
		end
		if imgui.IsItemHovered() then
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.SetCursorPosY(3)
			imgui.PushFont(fa_font2)
			imgui.TextColored(imgui.ImVec4(1.00, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
			imgui.PopFont()
		else
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.SetCursorPosY(3)
			imgui.PushFont(fa_font2)
			imgui.Text(fa.ICON_TIMES)
			imgui.PopFont()
		end
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 1))
		imgui.PushFont(fontsize)
		imgui.TextWrapped(remin_text)
		imgui.PopFont()
		imgui.Dummy(imgui.ImVec2(0, 2))
		if imgui.Button(u8"Закрыть", imgui.ImVec2(286, 30)) then
			if sound_reminder:status() ~= "dead" then
				sound_reminder:terminate()
			end
			ReminderWin.v = false
		end
		imgui.Dummy(imgui.ImVec2(0, 2))
		imgui.End()
	end
	if player_HUD.v then
		if musicHUD.v then
			if not mainWin.v and not iconwin.v and not sobWin.v and not depWin.v and not updWin.v and not spurBig.v and not choiceWin.v and not ReminderWin.v then
				imgui.ShowCursor = false
			end
			if status_track_pl == "STOP" then
				musicHUD.v = false
			end
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 1.06), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
			if not menu_play_track[3] then
				imgui.SetNextWindowSize(imgui.ImVec2(346, 70))
			else
				imgui.SetNextWindowSize(imgui.ImVec2(308, 70))
			end
			imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.11, 0.15, 0.17, 0.85))
			imgui.Begin(u8"Музыкальный плеер", musicHUD, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
			if status_track_pl ~= "STOP" then
				if selectis ~= 0 and menu_play_track[1] then
					textsizel = "{FFFFFF}"..tracks.name[selectis]
					textsizela = "{BDBDBD}"..tracks.artist[selectis]
					if #textsizel > 27 then
						textsizel = string.sub(textsizel, 1, 27) .. "..."
					end
					if #textsizela > 27 then
						textsizela = string.sub(textsizela, 1, 27) .. "..."
					end
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB(textsizel)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB(textsizela)
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					if statusimage == selectis then
						imgui.Image(imgLabel, imgui.ImVec2(60, 60))
					else
						imgui.Image(imgNoLabel, imgui.ImVec2(60, 60))
					end
				elseif selectis ~= 0  and menu_play_track[2] then
					textsizel = "{FFFFFF}"..save_tracks.name[selectis]
					textsizela = "{BDBDBD}"..save_tracks.artist[selectis]
					if #textsizel > 27 then
						textsizel = string.sub(textsizel, 1, 27) .. "..."
					end
					if #textsizela > 27 then
						textsizela = string.sub(textsizela, 1, 27) .. "..."
					end
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB(textsizel)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB(textsizela)
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					if statusimage == selectis then
						imgui.Image(imgLabel, imgui.ImVec2(60, 60))
					else
						imgui.Image(imgNoLabel, imgui.ImVec2(60, 60))
					end
				elseif select_music ~= 0 then
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB("{FFFFFF}"..record_text_name[select_music])
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB("{BDBDBD}Record")
					imgui.SetCursorPos(imgui.ImVec2(14, 5))
					imgui.Image(imgRECORD[select_music], imgui.ImVec2(60, 60))
				elseif selectis == 0 and select_music == 0 and status_track_pl ~= 'STOP' then
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
					imgui.SetCursorPos(imgui.ImVec2(14, 5))
					imgui.Image(imgLabel, imgui.ImVec2(60, 60))
				end
				if selectis == 0 and select_music == 0 then
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					imgui.Image(imgLabel, imgui.ImVec2(60, 60))
				end
			elseif selectis == 0 and select_music == 0 then
				imgui.SetCursorPos(imgui.ImVec2(88, 9))
				imgui.TextColoredRGB("{FFFFFF}".."Ничего не играет")
				imgui.SetCursorPos(imgui.ImVec2(88, 27))
				imgui.TextColoredRGB("{BDBDBD}".."")
				imgui.SetCursorPos(imgui.ImVec2(17, 5))
				imgui.Image(imgNoLabel, imgui.ImVec2(60, 60))
			end
			imgui.SetCursorPos(imgui.ImVec2(88, 55))
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 200, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(88, 55))
			p = imgui.GetCursorScreenPos()
			if get_status_potok_song() ~= 0 then
				function thetime()
					if timetr[1] < 10 then
						trt = "0"..timetr[1]
					else
						trt = timetr[1]
					end
					if timetr[2] < 10 then
						trt2 = "0"..timetr[2]
					else
						trt2 = timetr[2]
					end
					return trt2..":"..trt
				end
				if select_music == 0 then
					sizeXline = (timetr[2]*60+timetr[1])*(timetri/2)
					if sizeXline > 200 then
						sizeXline = 200
					end
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeXline, p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 15)
					imgui.SetCursorPos(imgui.ImVec2(296, 48))
					imgui.TextColoredRGB("{FFFFFF}"..thetime())
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 200, p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 15)
				end
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 100, 15)
			end
			imgui.PushFont(fa_font_mus)
			if status_track_pl == "PAUSE" or status_track_pl == "STOP" then
				if select_music == 0 then
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 60), imgui.GetColorU32(imgui.ImVec4(0.00, 0.00, 0.00 ,0.50)))
					imgui.SetCursorPos(imgui.ImVec2(33, 17))
					imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PAUSE_CIRCLE_O)
				else
					imgui.SetCursorPos(imgui.ImVec2(30, 18))
					imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PAUSE_CIRCLE_O)
				end
			end
			imgui.PopFont()
			if anim_hud_tr[1] <= 1 then
				active_anim_hud[1] = true
			elseif anim_hud_tr[1] >= 11 then
				active_anim_hud[1] = false
			end
			if anim_hud_tr[2] <= 1 then
				active_anim_hud[2] = true
			elseif anim_hud_tr[2] >= 11 then
				active_anim_hud[2] = false
			end
			if anim_hud_tr[3] <= 1 then
				active_anim_hud[3] = true
			elseif anim_hud_tr[3] >= 11 then
				active_anim_hud[3] = false
			end
			if status_track_pl == 'PLAY' then
				if active_anim_hud[1] then
					anim_hud_tr[1] = anim_hud_tr[1] + 0.1
				else
					anim_hud_tr[1] = anim_hud_tr[1] - 0.1
				end
				if active_anim_hud[2] then
					anim_hud_tr[2] = anim_hud_tr[2] + 0.25
				else
					anim_hud_tr[2] = anim_hud_tr[2] - 0.25
				end
				if active_anim_hud[3] then
					anim_hud_tr[3] = anim_hud_tr[3] + 0.17
				else
					anim_hud_tr[3] = anim_hud_tr[3] - 0.17
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(272, 48))
			p = imgui.GetCursorScreenPos()
	--[[]]	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + -anim_hud_tr[1]), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.90)))
			
			imgui.SetCursorPos(imgui.ImVec2(277, 48))
			p = imgui.GetCursorScreenPos()
	--[[]]	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + -anim_hud_tr[2]), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.90)))
			
			imgui.SetCursorPos(imgui.ImVec2(282, 48))
			p = imgui.GetCursorScreenPos()
	--[[]]	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + -anim_hud_tr[3]), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.90)))
			imgui.End()
			imgui.PopStyleColor()
		end
    end
	if iconwin.v then
		sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", iconwin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			for i,v in pairs(fa) do
				if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then setClipboardText(i) end
			end
			
		imgui.End()
	
	end
end

if actingOutWind.v then 
	function ButtonMinPl(iv, effect, parvararg)
		if parvararg == "arg" then
			if effect == "remove" then
				imgui.SetCursorPos(imgui.ImVec2(15, 35 + (iv*30)))
				if imgui.InvisibleButton(iv.. u8"##CreateFunct", imgui.ImVec2(15, 8)) then
					table.remove(acting_buf.arg, iv)
				end
				imgui.SetCursorPos(imgui.ImVec2(17, 32 + (iv*30)))
				if imgui.IsItemHovered() then
					imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS)
				else
					imgui.Text(fa.ICON_MINUS)
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.arg + 1)*30)))
				if #acting_buf.arg <= 4 then
					if imgui.InvisibleButton(u8"##CreateFunctAdd", imgui.ImVec2(100, 30)) then
						table.insert(acting_buf.arg, (#acting_buf.arg + 1), {imgui.ImInt(0), imgui.ImBuffer(u8"Аргумент "..#acting_buf.arg, 128)})
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.arg+1)*30)))
					p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() and not imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 10, 15)
					elseif imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 10, 15)
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.arg+1)*30)))
					p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 38 + ((#acting_buf.arg+1)*30)))
				if #acting_buf.arg <= 4 then
					imgui.Text(u8"Аргумент")
				else
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), u8"Аргумент")
				end
			end
		else
			if effect == "remove" then
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(557, 35 + (iv*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(15, 35 + (iv*30)))
				end
				if imgui.InvisibleButton(iv.. u8"##CreateFunct2", imgui.ImVec2(15, 8)) then
					table.remove(acting_buf.var, iv)
					variab = {}
					for j = 1, #acting_buf.var do
						variab[j] = "{var"..j.."}"
					end
					for j = 1, #acting_buf.typeAct do
						if acting_buf.typeAct[j][1].v == 4 and acting_buf.typeAct[j][2].v == #acting_buf.var then
							acting_buf.typeAct[j][2].v = acting_buf.typeAct[j][2].v - 1
						end
					end
				end
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(559, 32 + (iv*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + (iv*30)))
				end
				if imgui.IsItemHovered() then
					imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS)
				else
					imgui.Text(fa.ICON_MINUS)
				end
			else
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(559, 32 + ((#acting_buf.var + 1)*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.var + 1)*30)))
				end
				if #acting_buf.var <= 19 then
					if imgui.InvisibleButton(u8"##CreateFunctAdd2", imgui.ImVec2(100, 30)) then
						table.insert(acting_buf.var, (#acting_buf.var + 1), imgui.ImBuffer(u8"", 128))
						for j = 1, #acting_buf.var do
							variab[j] = "{var"..j.."}"
						end
					end
					if acting_buf.argfunc.v then 
						imgui.SetCursorPos(imgui.ImVec2(559, 32 + ((#acting_buf.var+1)*30)))
					else
						imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.var+1)*30)))
					end
					p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() and not imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 10, 15)
					elseif imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 10, 15)
					end
				else
					if acting_buf.argfunc.v then  
						imgui.SetCursorPos(imgui.ImVec2(559, 32 + ((#acting_buf.var+1)*30)))
					else
						imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.var+1)*30)))
					end
					p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
				end
				if acting_buf.argfunc.v then  
					imgui.SetCursorPos(imgui.ImVec2(577, 38 + ((#acting_buf.var+1)*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(35, 38 + ((#acting_buf.var+1)*30)))
				end
				if #acting_buf.var <= 19 then
					imgui.Text(u8"Переменная")
				else
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), u8"Переменная")
				end
			end
		end
	end
	function ButtomPosition(parx, pary)
		if acting_buf.argfunc.v and acting_buf.varfunc.v then
			if #acting_buf.arg >= #acting_buf.var then
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
			elseif #acting_buf.var >= #acting_buf.arg then
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
			end
			elseif acting_buf.argfunc.v then
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
			elseif acting_buf.varfunc.v then 
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
			else
				imgui.SetCursorPos(imgui.ImVec2(parx, pary - 75 + ((#acting_buf.typeAct + 1) * 40)))
		end
	end
	function ButtonRemAdd()
		if #acting_buf.typeAct <= 99 then
			ButtomPosition(15, 175)
			if imgui.InvisibleButton(u8"##NewTypeAdd", imgui.ImVec2(100, 30)) then
				table.insert(acting_buf.typeAct, (#acting_buf.typeAct + 1), {imgui.ImInt(0), imgui.ImBuffer(u8"", 1024)})
			end
			ButtomPosition(15, 175)
			p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() and not imgui.IsItemActive() then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 10, 15)
			elseif imgui.IsItemActive() then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 10, 15)
			end
		else
			ButtomPosition(15, 175)
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
		end
		
		if #acting_buf.typeAct <= 99 then
			ButtomPosition(31, 180)
			imgui.Text(u8"Напоминание")
		else
			ButtomPosition(31, 180)
			imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), u8"Напоминание")
		end
	end
	function waitvar()
		param = round(acting_buf.sec.v, 0.1)
		return tostring(param)
	end
	sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1100, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(u8"MH | Медицинская помощь", actingOutWind, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar);
		imgui.SetCursorPosX(430)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"MH | Медицинская помощь")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(1070)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_sob.paramOff then 
				actingOutWind.v = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(1075)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(1075)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginChild("RedactorActingOut", imgui.ImVec2(1085, 496), false, imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(5, 5))
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
			imgui.SetWindowFontScale(1.1)
			imgui.SetCursorPos(imgui.ImVec2(300, 7))
			if ButtonSwitch(u8" Использовать аргументы", acting_buf.argfunc) then end
			imgui.SetCursorPos(imgui.ImVec2(540, 7))
			if ButtonSwitch(u8" Использовать переменные", acting_buf.varfunc) then end
			if acting_buf.argfunc.v then
				imgui.SetCursorPos(imgui.ImVec2(5, 45))
				p = imgui.GetCursorScreenPos()
				if acting_buf.varfunc.v then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 532, p.y + 63 + (#acting_buf.arg*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 63 + (#acting_buf.arg*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				end
				for i = 1, #acting_buf.arg do
					ButtonMinPl(i, "remove", "arg")
					imgui.SetCursorPos(imgui.ImVec2(37, 30 + (i*30)))
					imgui.Text(i.. u8" Арг. ")
					imgui.SameLine()
					imgui.PushItemWidth(180)
					if acting_buf.arg[i] ~= nil then
						if imgui.Combo(u8"##TypeVariable"..i, acting_buf.arg[i][1], arg_options) then end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.TextColoredRGB(u8"  Значение аргумента для {E6BA39}{arg"..i.."}")
				end
				ButtonMinPl(i, "create", "arg")
			end
			if acting_buf.varfunc.v then
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(547, 45))
				else
					imgui.SetCursorPos(imgui.ImVec2(5, 45))
				end
				p = imgui.GetCursorScreenPos()
				if acting_buf.argfunc.v then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 532, p.y + 63 + (#acting_buf.var*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 63 + (#acting_buf.var*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				end
				for i = 1, #acting_buf.var do
					ButtonMinPl(i, "remove", "var")
					if not acting_buf.argfunc.v then
						imgui.SetCursorPos(imgui.ImVec2(37, 30 + (i*30)))
					else
						imgui.SetCursorPos(imgui.ImVec2(579, 30 + (i*30)))
					end
					imgui.Text(i.. u8" Перем. ")
					imgui.SameLine()
					imgui.PushItemWidth(140)
					if acting_buf.var[i] ~= nil then
						if imgui.InputText(u8"##TextVariable"..i, acting_buf.var[i], type_options) then end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.TextColoredRGB(u8" Значение переменной для {E6BA39}{var"..i.."}")
				end
				ButtonMinPl(i, "create", "var")
			end
			function GetPosField()
				parametrY = 0
				if acting_buf.argfunc.v and acting_buf.varfunc.v then
					if #acting_buf.arg >= #acting_buf.var then
						parametrY = 74 + (#acting_buf.arg * 30)
					elseif #acting_buf.var >= #acting_buf.arg then
						parametrY = 74 + (#acting_buf.var * 30)
					end
				elseif acting_buf.argfunc.v then
					parametrY = 74 + (#acting_buf.arg * 30)
				elseif acting_buf.varfunc.v then 
					parametrY = 74 + (#acting_buf.var * 30)
				else
					parametrY = 0
				end
				return parametrY
			end
			function find_last_index(array, element)
				index = 0
				for i = 1, #array do
					if array[i][1].v == element then
						index = i
					end
				end
				return index
			end
			imgui.SetCursorPos(imgui.ImVec2(5, 44 + GetPosField()))
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(16, 78 + GetPosField()))
			imgui.PushItemWidth(150)
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
			if imgui.SliderFloat(u8"##Задержка выполнения", acting_buf.sec, 1, 10, u8"") then
			end
			imgui.PopStyleColor(3)
			imgui.PopItemWidth()
			imgui.SetCursorPos(imgui.ImVec2(68, 55 + GetPosField()))
			imgui.Text(waitvar()..u8" сек.")
			imgui.SetCursorPos(imgui.ImVec2(16, 86 + GetPosField()))
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 140, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (acting_buf.sec.v*14), p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.11, 0.60, 0.88 ,1.00)), 10, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + (acting_buf.sec.v*14), p.y + 2), 9, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)))
			imgui.SetCursorPos(imgui.ImVec2(166, 79 + GetPosField()))
			imgui.TextColoredRGB(u8" Задержка выполнения")
			if acting_buf.sec.v < 1.8 then
				imgui.SameLine()
				imgui.TextColored(imgui.ImVec4(0.86, 0.18, 0.18, 1.00), u8"   Внимание! Из-за малой задержки могут появиться сообщения \"Не туда!\"")
			end
			imgui.SetCursorPos(imgui.ImVec2(5, 123 + GetPosField()))
			p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 60 + (#acting_buf.typeAct * 40)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
			
			for c = 1, #acting_buf.typeAct do
				pd = c
				if acting_buf.argfunc.v and acting_buf.varfunc.v then
					if #acting_buf.arg >= #acting_buf.var and acting_buf.argfunc.v then
						imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.arg * 30)))
						parsic = 175 + (pd * 40) + (#acting_buf.arg * 30)
					elseif #acting_buf.var >= #acting_buf.arg and acting_buf.varfunc.v then
						imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.var * 30)))
						parsic = 175 + (pd * 40) + (#acting_buf.var * 30)
					end
				elseif acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.arg * 30)))
					parsic = 175 + (pd * 40) + (#acting_buf.arg * 30)
				elseif acting_buf.varfunc.v then 
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.var * 30)))
					parsic = 175 + (pd * 40) + (#acting_buf.var * 30)
				else
					imgui.SetCursorPos(imgui.ImVec2(15, 100 + (pd * 40)))
					parsic = 100 + (pd * 40)
				end
				imgui.Text(pd.. u8".  ")
				imgui.SameLine()
				local trush = fa.ICON_TRASH
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(70, 70, 70, 0):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(70, 70, 70, 0):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(70, 70, 70, 0):GetVec4())
				if imgui.Button(trush..u8"##"..pd, imgui.ImVec2(21, 21)) then 
					table.remove(acting_buf.typeAct, pd)
				end
				imgui.PopStyleColor(3)
				imgui.SameLine()
				imgui.PushItemWidth(220)
				if acting_buf.typeAct[c] ~= nil then
					if imgui.Combo(u8"##ComboType"..pd, acting_buf.typeAct[c][1], type_options) then
						if acting_buf.typeAct[c][1].v ~= 2 and acting_buf.typeAct[c][1].v ~= 4 then
							acting_buf.typeAct[c][2] = imgui.ImBuffer(u8"", 1024)
						elseif acting_buf.typeAct[c][1].v == 2 then
							acting_buf.typeAct[c][2] = {imgui.ImBuffer(u8"Вариант 1", 128)}
						elseif acting_buf.typeAct[c][1].v == 4 then
							acting_buf.typeAct[c][2] = imgui.ImInt(0)
							acting_buf.typeAct[c][3] = imgui.ImBuffer(128)
						end
					end
					imgui.PopItemWidth()
					if acting_buf.typeAct[c][1].v == 0 then
						imgui.SameLine()
						imgui.Text(u8"  Текст действия")
						imgui.SameLine()
						imgui.PushItemWidth(630)
						if imgui.InputText(u8"##Text"..pd, acting_buf.typeAct[c][2]) then end
						imgui.PopItemWidth()
						if find_last_index(acting_buf.typeAct, 0) == c then
							if acting_buf.argfunc.v and acting_buf.varfunc.v then
								if #acting_buf.arg >= #acting_buf.var and acting_buf.argfunc.v then
									imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
								elseif #acting_buf.var >= #acting_buf.arg and acting_buf.varfunc.v then
									imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
								end
							elseif acting_buf.argfunc.v then
								imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
							elseif acting_buf.varfunc.v then 
								imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
							else
								imgui.SetCursorPos(imgui.ImVec2(130, 103 + ((#acting_buf.typeAct + 1) * 40)))
							end
							if ButtonSwitch(u8" Открыть чат", acting_buf.chatopen) then end
						end
					end
					if acting_buf.typeAct[c][1].v == 1 and acting_buf.typeAct[c] ~= nil then
						imgui.SameLine()
						imgui.Text(u8"  Ожидание нажатия клавиши Enter.")
					end
					if acting_buf.typeAct[c][1].v == 2 and acting_buf.typeAct[c] ~= nil then
						imgui.SetCursorPos(imgui.ImVec2(302, parsic - 1))
						if imgui.InvisibleButton(u8"##EditDialogAct"..pd, imgui.ImVec2(367, 25)) then 
							imgui.OpenPopup(u8"Редактирование диалога")
							popumodDialog = pd
						end
						imgui.SetCursorPos(imgui.ImVec2(302, parsic - 1))
						local p = imgui.GetCursorScreenPos()
						if imgui.IsItemHovered() and not imgui.IsItemActive() then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 367, p.y + 25), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 8, 15)
						elseif imgui.IsItemActive() then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 367, p.y + 25), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 367, p.y + 25), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 8, 15)
						end
						imgui.SetCursorPos(imgui.ImVec2(314, 2 + parsic))
						imgui.Text(u8"Редактирование вариантов диалога     (кол-во вариантов: ".. #acting_buf.typeAct[c][2].. ")")
					end
					if acting_buf.typeAct[c][1].v == 3 and acting_buf.typeAct[c] ~= nil then
						imgui.SameLine()
						imgui.Text(u8"  Текст действия ")
						imgui.SameLine()
						imgui.PushItemWidth(630)
						if imgui.InputText(u8"##Text"..pd, acting_buf.typeAct[c][2]) then end
						imgui.PopItemWidth()
					end
					if acting_buf.typeAct[c][1].v == 4 and acting_buf.typeAct[c] ~= nil then
						imgui.SameLine()
						if acting_buf.varfunc.v and #acting_buf.var ~= 0 then
							imgui.Text(u8"  Переменная ")
							imgui.SameLine()
							imgui.PushItemWidth(90)
							if imgui.Combo(u8"##VarEdit"..pd, acting_buf.typeAct[c][2], variab) then end
							imgui.SameLine()
							imgui.Text(u8"  Название переменной ")
							imgui.SameLine()
							imgui.PushItemWidth(180)
							if imgui.InputText(u8"##variabname"..pd, acting_buf.typeAct[c][3]) then end
						else
							imgui.Text(u8" Переменные не заданы или их не существует.")
						end
					end
				end
			end
			if acting_buf.argfunc.v and acting_buf.varfunc.v then
				if #acting_buf.arg >= #acting_buf.var and acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
				elseif #acting_buf.var >= #acting_buf.arg and acting_buf.varfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
				end
			elseif acting_buf.argfunc.v then
				imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
			elseif acting_buf.varfunc.v then 
				imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
			else
				imgui.SetCursorPos(imgui.ImVec2(15, 100 + ((#acting_buf.typeAct + 1) * 40)))
			end
			ButtonRemAdd()
			imgui.Dummy(imgui.ImVec2(0, 20)) 
			if imgui.BeginPopupModal(u8"Редактирование диалога", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPosX(140)
				imgui.PushFont(fontsize)
				imgui.SetCursorPosY(6)
				imgui.Text(u8"Редактирование диалога")
				imgui.SameLine()
				ShowHelpMarker(u8"Вы можете использовать эту функцию, чтобы создавать свои шаблоны действий,\nкоторые будут выполняться автоматически.\n\nЕсли вы используете чужие настройки и не знаете их назначения,\nпопробуйте воспользоваться поиском или спросить у автора.\n\nДля того чтобы увидеть результат работы вашего шаблона,\nвы можете открыть окно с диалогами и нажать кнопку \"Отправить сообщение в чат\".\n\nЕсли команда \"Отправить сообщение в чат\" не работает у вас,\nкак надо, попробуйте проверить настройки.\n\nТакже вы всегда можете задать вопрос разработчику скрипта,\nнаписав ему личное сообщение.")
				imgui.PopFont()
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 1))
				for i = 1, #acting_buf.typeAct[popumodDialog][2] do
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(70, 70, 70, 0):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(70, 70, 70, 0):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(70, 70, 70, 0):GetVec4())
					if imgui.Button(fa.ICON_TRASH..u8"##12"..i, imgui.ImVec2(21, 21)) then 
						table.remove(acting_buf.typeAct[popumodDialog][2], i)
					end
					imgui.PopStyleColor(3)
					if acting_buf.typeAct[popumodDialog][2][i] ~= nil then
						imgui.SameLine()
						imgui.Text(u8" Вариант "..i.." ")
						imgui.SameLine()
						imgui.PushItemWidth(150)
						if imgui.InputText(u8"##TextDialogTest"..i, acting_buf.typeAct[popumodDialog][2][i]) then end
						imgui.PopItemWidth()
						imgui.SameLine()
						imgui.TextColoredRGB(" Вариант " .. i .. " - {E6BA39}{Dialog"..i.."}{FFFFFF} ")
					end
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.Button(u8"Добавить вариант", imgui.ImVec2(140, 25)) then 
					if #acting_buf.typeAct[popumodDialog][2] < 8 then
						table.insert(acting_buf.typeAct[popumodDialog][2], (#acting_buf.typeAct[popumodDialog][2] + 1), imgui.ImBuffer(u8"Вариант "..#acting_buf.typeAct[popumodDialog][2] + 1, 128))
					end
				end
				if #acting_buf.typeAct[popumodDialog][2] >= 8 then
    imgui.SameLine()
    imgui.TextColoredRGB("  {d42629}Достигнут лимит!")
	end
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Text(u8'Вот как будут выглядеть варианты:')
			imgui.TextColoredRGB('{1dcc25}Вы можете использовать цифры для выбора:')
			for i = 1, #acting_buf.typeAct[popumodDialog][2] do
				imgui.TextColoredRGB('{cca61d}[Номер '..i.."]{FFFFFF} - "..u8:decode(acting_buf.typeAct[popumodDialog][2][i].v))
				if i > 1 then
					imgui.Text("...")
					break
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			if imgui.Button(u8"Закрыть", imgui.ImVec2(440, 25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
			end
			imgui.EndChild()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(102, 102, 102, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(77, 77, 77, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(115, 115, 115, 255):GetVec4())
			if imgui.Button(u8"Сохранить", imgui.ImVec2(357, 25)) then
				acting[selected_cmd] = {argfunc = false, arg = {}, varfunc = false, var = {}, chatopen = false, typeAct = {}, sec = 2.0}
				acting[selected_cmd].argfunc = acting_buf.argfunc.v
				acting[selected_cmd].varfunc = acting_buf.varfunc.v
				acting[selected_cmd].sec = acting_buf.sec.v
				acting[selected_cmd].chatopen = acting_buf.chatopen.v
				for k = 1, #acting_buf.typeAct do
					if acting_buf.typeAct[k][1].v ~= 2 and acting_buf.typeAct[k][1].v ~= 4 then
						acting[selected_cmd].typeAct[k] = {acting_buf.typeAct[k][1].v, acting_buf.typeAct[k][2].v}
					elseif acting_buf.typeAct[k][1].v == 2 then
						acting[selected_cmd].typeAct[k] = {acting_buf.typeAct[k][1].v, {}}
						for m = 1, #acting_buf.typeAct[k][2] do
							local mems = m
							table.insert(acting[selected_cmd].typeAct[k][2], mems, acting_buf.typeAct[k][2][m].v)
						end
					elseif acting_buf.typeAct[k][1].v == 4 then
						acting[selected_cmd].typeAct[k] = {acting_buf.typeAct[k][1].v, acting_buf.typeAct[k][2].v, acting_buf.typeAct[k][3].v}
					end
				end
				for k = 1, #acting_buf.arg do
					acting[selected_cmd].arg[k] = {acting_buf.arg[k][1].v, acting_buf.arg[k][2].v}
				end
				for k = 1, #acting_buf.var do
					acting[selected_cmd].var[k] = acting_buf.var[k].v
				end
				local f = io.open(dirml.."/MedicalHelper/госновости.med", "w")
				f:write(encodeJson(acting))
				f:flush()
				f:close()
				actingOutWind.v = false
			end
			imgui.SameLine()
			if imgui.Button(u8"Сброс по умолчанию##svag", imgui.ImVec2(357, 25)) then 
				acting[selected_cmd] = acting_defoult[selected_cmd]
				acting_buf = {argfunc = imgui.ImBool(false), arg = {}, varfunc = imgui.ImBool(false), var = {},  
					chatopen = imgui.ImBool(false),	typeAct = {}, sec = imgui.ImFloat(1.0)}
					
					acting_buf.argfunc.v = acting[selected_cmd].argfunc
					acting_buf.varfunc.v = acting[selected_cmd].varfunc
					acting_buf.sec.v = acting[selected_cmd].sec
					acting_buf.chatopen.v = acting[selected_cmd].chatopen
					variab = {}
				for k = 1, #acting[selected_cmd].typeAct do
					if acting[selected_cmd].typeAct[k][1] ~= 2 and acting[selected_cmd].typeAct[k][1] ~= 4 then
						acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImBuffer(acting[selected_cmd].typeAct[k][2], 1024)}
						acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
					elseif acting[selected_cmd].typeAct[k][1] == 2 then
						acting_buf.typeAct[k] = {imgui.ImInt(0), {}}
						acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
						for m = 1, #acting[selected_cmd].typeAct[k][2] do
							acting_buf.typeAct[k][2][m] = imgui.ImBuffer(1024)
							acting_buf.typeAct[k][2][m].v = acting[selected_cmd].typeAct[k][2][m]
						end
					elseif acting[selected_cmd].typeAct[k][1] == 4 then
						acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImInt(0), imgui.ImBuffer(128)}
						acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
						acting_buf.typeAct[k][2].v = acting[selected_cmd].typeAct[k][2]
						acting_buf.typeAct[k][3].v = acting[selected_cmd].typeAct[k][3]
					end
				end
				for k = 1, #acting[selected_cmd].arg do
					acting_buf.arg[k] = {imgui.ImInt(0), imgui.ImBuffer(128)}
					acting_buf.arg[k][1].v = acting[selected_cmd].arg[k][1]
					acting_buf.arg[k][2].v = acting[selected_cmd].arg[k][2]
				end
				for k = 1, #acting[selected_cmd].var do
					acting_buf.var[k] = imgui.ImBuffer(128)
					acting_buf.var[k].v = acting[selected_cmd].var[k]
					variab[k] = "{var"..k.."}"
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть без сохранения##svag", imgui.ImVec2(357, 25)) then 
				actingOutWind.v = false
			end
			imgui.PopStyleColor(3)
	imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.End()
	end
		
	if paramWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(820, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(u8"Чит-подсказка для биндера", paramWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(50)
		imgui.TextColoredRGB("[center]{FFFF41}Здесь список всех переменных, которые можно использовать.", imgui.GetMaxWidthByText("Здесь список всех переменных, которые можно использовать."))
		imgui.Dummy(imgui.ImVec2(0, 15))
		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myID}")
		imgui.SameLine()
		if imgui.IsItemHovered(0) then setClipboardText("{myID}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш ID - {ACFF36}"..tostring(myid))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myNick}");  end
		imgui.TextColoredRGB("{C1C1C1} - Ваш игровой ник (без подч.) - {ACFF36}"..tostring(myNick:gsub("_"," ")))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRusNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRusNick}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш ник, который вы указали в настройках - {ACFF36}"..tostring(u8:decode(buf_nick.v)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHP}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHP}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваше здоровье - {ACFF36}"..tostring(getCharHealth(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myArmo}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myArmo}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш уровень брони - {ACFF36}"..tostring(getCharArmour(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHosp}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHosp}") end
		imgui.TextColoredRGB("{C1C1C1} - Название вашей клиники - {ACFF36}"..tostring(u8:decode(chgName.org[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHospEn}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHospEn}") end
		imgui.TextColoredRGB("{C1C1C1} - То же название клиники на англ. - {ACFF36}"..tostring(u8:decode(list_org_en[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myTag}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myTag}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш тег - {ACFF36}"..tostring(u8:decode(buf_teg.v)))
		
		imgui.Spacing()		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRank}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRank}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш ранг - {ACFF36}"..tostring(u8:decode(chgName.rank[num_rank.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{time}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{time}") end
		imgui.TextColoredRGB("{C1C1C1} - Время в формате час:минута:секунда - {ACFF36}"..tostring(os.date("%X")))
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{day}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{day}") end
		imgui.TextColoredRGB("{C1C1C1} - Текущий день - {ACFF36}"..tostring(os.date("%d")))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{week}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{week}") end
		imgui.TextColoredRGB("{C1C1C1} - День недели - {ACFF36}"..tostring(week[tonumber(os.date("%w"))+1]))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{month}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{month}") end
		imgui.TextColoredRGB("{C1C1C1} - Название месяца - {ACFF36}"..tostring(month[tonumber(os.date("%m"))]))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{getNickByTarget}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByTarget}") end
		imgui.TextColoredRGB("{C1C1C1} - Получить ник игрока, на которого вы смотрите, для команд.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{target}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{target}") end
		imgui.TextColoredRGB("{C1C1C1} - ID игрока, на которого вы смотрите (ваш прицел) - {ACFF36}"..tostring(targID))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{pause}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{pause}") end
		imgui.TextColoredRGB("{C1C1C1} - Ставит паузу до нажатия Enter в игре. {EC3F3F}Не рекомендуется использовать в циклах.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sleep:задержка}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sleep:1000}") end
		imgui.TextColoredRGB("{C1C1C1} - Задержка выполнения в миллисекундах. \n\tПример: {sleep:2500}, то есть 2500 миллисекунд (1 сек = 1000 мс)")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sex:текст1|текст2}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sex:text1|text2}") end
		imgui.TextColoredRGB("{C1C1C1} - Подставляет текст в зависимости от пола игрока.  \n\tПример: {sex:доктор|доктор}, получится 'доктор' независимо от пола (здесь пример не очень, но суть понятна)")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{getNickByID:ID игрока}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByID:}") end
		imgui.TextColoredRGB("{C1C1C1} - Получить ник игрока по его ID. \n\tПример: {getNickByID:25}, получим ник игрока с ID 25.")
		
		imgui.End()
	end
	
	if spurBig.v then
		if not animka_big.MoveAnim then
			seelB = imgui.Cond.FirstUseEver
		else
			seelB = imgui.Cond.Always
		end
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1098, 728), seelB)
		imgui.SetNextWindowPos(imgui.ImVec2(animka_big.posX, animka_big.posY), seelB, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Просмотр шпоры", spurBig, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		imgui.SameLine()
			imgui.SetCursorPosY(4)
			imgui.PushItemWidth(170)
			imgui.InputText("##chatgta", searchtext)
			imgui.SameLine()
			if imgui.Button(u8"Найти", imgui.ImVec2(100, 23)) then
			plerel = true
				if searchtext.v ~= "" then
					local findStr = 0
					for line in io.lines(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt") do
						findStr = findStr + 1
						if textEndShpora[findStr]:find("{F2FF00}") then
						textEndShpora[findStr] = textEndShpora[findStr]:gsub("{F2FF00}", "")
						end
						if textEndShpora[findStr]:find("{FFFFFF}") then
						textEndShpora[findStr] = textEndShpora[findStr]:gsub("{FFFFFF}", "")
						end
						for textes in line:gmatch(u8:decode(searchtext.v)) do
							perta = "{F2FF00}"..u8:decode(searchtext.v).."{FFFFFF}"
							if textEndShpora[findStr]:find(textes) then
								textEndShpora[findStr] = textEndShpora[findStr]:gsub(textes, perta)
								if textEndShpora[findStr]:find("{F2FF00}{F2FF00}"..textes.."{FFFFFF}{FFFFFF}") then
									textEndShpora[findStr] = textEndShpora[findStr]:gsub("{F2FF00}{F2FF00}"..textes.."{FFFFFF}{FFFFFF}", "{F2FF00}"..textes.."{FFFFFF}")
								end
							end
						end
					end	
				else
					for i, v in ipairs(textEndShpora) do
						if textEndShpora[i]:find("F2FF00") then
						textEndShpora[i] = textEndShpora[i]:gsub("{F2FF00}", "")
						end
						if textEndShpora[i]:find("FFFFFF") then
						textEndShpora[i] = textEndShpora[i]:gsub("{FFFFFF}", "")
						end
					end
				end
					if doesFileExist(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt") then
							os.remove(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt")
							for i, v in ipairs(textEndShpora) do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						else
							for i, v in ipairs(textEndShpora) do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						end
				plerel = false
			end
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(500)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(5)
			imgui.Text(u8"Редактор шпоры")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(1068)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_big.paramOff then 
				posWinClosed = imgui.GetWindowPos()
				styleAnimationClose(5, 1098, 728)
				animka_big.paramOff = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(1073)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(1073)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
		if spur.edit then
				imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(1081, 622))
				if imgui.Button(u8"Сохранить", imgui.ImVec2(357, 25)) then
					local name = ""
					local bool = false
					if spur.name.v ~= "" then 
							name = u8:decode(spur.name.v)
							if doesFileExist(dirml.."/MedicalHelper/шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
								bool = true
								imgui.OpenPopup(u8"Ошибка")
							else
								os.remove(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt")
								spur.list[spur.select_spur] = u8:decode(spur.name.v)
							end
					else
						name = spur.list[spur.select_spur]
					end
					if not bool then
						local f = io.open(dirml.."/MedicalHelper/шпаргалки/"..name..".txt", "w")
						f:write(u8:decode(spur.text.v))
						f:flush()
						f:close()
						spur.text.v = ""
						spur.name.v = ""
						spur.edit = false
						examination = true
						textEndShpora = {}
					end
				end
				imgui.SameLine()
				if imgui.Button(u8"Удалить", imgui.ImVec2(357, 25)) then
					spur.text.v = ""
					table.remove(spur.list, spur.select_spur) 
					spur.select_spur = -1
					if doesFileExist(dirml.."/MedicalHelper/шпаргалки/"..u8:decode(spur.select_spur)..".txt") then
						os.remove(dirml.."/MedicalHelper/шпаргалки/"..u8:decode(spur.select_spur)..".txt")
					end
					spur.name.v = ""
					spurBig.v = false
					spur.edit = false
					examination = true
					textEndShpora = {}
				end
				imgui.SameLine()
				if imgui.Button(u8"Просмотр", imgui.ImVec2(357, 25)) then spur.edit = false examination = true textEndShpora = {} end
				if imgui.Button(u8"Закрыть", imgui.ImVec2(1081, 25)) then
					if not spurBig.v then
						styleAnimationOpen(5)
						spurBig.v = true
						examination = true
						textEndShpora = {}
					else
						animka_big.paramOff = true
					end
				end
		else
			imgui.BeginChild("spur spec", imgui.ImVec2(1070, 650), true)
				if examination then
					if doesFileExist(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt") then
						local numSh = 0
						for line in io.lines(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt") do
							numSh = numSh + 1
							if line == "" then
								line = " "
							end
							textEndShpora[numSh] = wraper(line, 140)
						end
					end
					if doesFileExist(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt") then
							os.remove(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt")
							for i = 1, #textEndShpora do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						else
							for i = 1, #textEndShpora do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						end
					examination = false
				end
				if not plerel and not examination then
					if doesFileExist(dirml.."/MedicalHelper/editShporaFindSLL.txt") then
						for line in io.lines(dirml.."/MedicalHelper/editShporaFindSLL.txt") do
							imgui.TextColoredRGB(line)
						end
					end
				end
			imgui.EndChild()
			if imgui.Button(u8"Открыть редактирование", imgui.ImVec2(537, 25)) then 
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть", imgui.ImVec2(537, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
		end
		imgui.End()
	end

	if depWin.v then
		inDepWin()
	end

		if updWin.v then
    	if not animka_upd.MoveAnim then seelU = imgui.Cond.FirstUseEver else seelU = imgui.Cond.Always end
    	local sw, sh = getScreenResolution()
    	imgui.SetNextWindowSize(imgui.ImVec2(700, 420), seelU)
    	imgui.SetNextWindowPos(imgui.ImVec2(animka_upd.posX, animka_upd.posY), seelU, imgui.ImVec2(0.5, 0.5))
    	imgui.Begin(fa.ICON_DOWNLOAD .. u8"  Проверка обновлений.", updWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    	-- ... заголовок и кнопка закрытия ...
    	if update_available then
     	   imgui.SetCursorPosX(120)
     	   imgui.TextColored(imgui.ImColor(255, 200, 0, 225):GetVec4(), fa.ICON_EXCLAMATION_TRIANGLE); imgui.SameLine()
     	   imgui.TextColoredRGB("Доступна новая версия: {72F566}"..newversion)
     	   imgui.SetCursorPosX(282)
     	   imgui.TextColoredRGB("{F8A436}Список изменений:")
      	  imgui.Spacing()
      	  imgui.BeginChild("update log", imgui.ImVec2(0, 230), true)
      	  if updinfo then
      	      for line in updinfo:gmatch("[^\n]+") do
       	         imgui.TextColoredRGB(line)
       	    end
      	  	else
       	    	imgui.Text("Информация не загружена.")
        	end
        	imgui.EndChild()
        	imgui.SetCursorPosX(192)
        	if imgui.Button(fa.ICON_DOWNLOAD .. u8"  Обновить", imgui.ImVec2(270, 30)) then
        	    funCMD.doUpdate()
        	end
    	else
        	imgui.SetCursorPosX(120)
        	imgui.TextColored(imgui.ImColor(0, 255, 0, 225):GetVec4(), fa.ICON_CHECK); imgui.SameLine()
        	imgui.TextColoredRGB("У вас последняя версия ({72F566}"..scr.version..")")
    	end
    	imgui.End()
	end
		if profbWin.v then
		profbWind()
	end
end
function funcTargetDo(idTarget) --geter
	if idTarget == 0 then
		funCMD.lec(tostring(targetID))
	elseif idTarget == 1 then
		funCMD.med(tostring(targetID))
	elseif idTarget == 2 then
		funCMD.vac(tostring(targetID))
	elseif idTarget == 3 then
		funCMD.narko(tostring(targetID))
	elseif idTarget == 4 then
		funCMD.ant(tostring(targetID))
	elseif idTarget == 5 then
		funCMD.recep(tostring(targetID))
	elseif idTarget == 6 then
		funCMD.expel(tostring(targetID).." причина")
	elseif idTarget == 8 then
		sampSetChatInputEnabled(true)
		sampSetChatInputText("/"..cmdBind[18].cmd.." "..targetID.." ")
	elseif idTarget == 9 then
		funCMD.inv(tostring(targetID))
	elseif idTarget == 10 then
		funCMD.cure(tostring(targetID))
	elseif idTarget == 11 then
		funCMD.show(tostring(targetID))
	elseif idTarget == 12 then
		sampSendChat('/trade '..(tostring(targetID)))
	elseif idTarget >= 13 then
		thread = lua_thread.create(function()		
			local dir = dirml.."/MedicalHelper/Binder/bind-"..binder.list[idTarget - 12].name..".txt"	
			local tb = {}
			tb = strBinderTable(dir)
			tb.sleep = binder.list[idTarget - 12].sleep
			playBind(tb)
			return
		end)
	end
end
function choiceWind()
	if sampIsPlayerConnected(targetID) then
		local sw, sh = getScreenResolution()
		local sizewinda = 0
		for i = 1, #setting2.funcPKM.slider do
			if optionsPKM[setting2.funcPKM.slider[i] + 1] ~= nil then
				sizewinda = sizewinda + 34
			end
		end
		imgui.SetNextWindowSize(imgui.ImVec2(250, 100 + sizewinda), imgui.Cond.Always)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Choicewindows", choiceWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove);
		imgui.PushFont(fontsize)
		imgui.SetCursorPosY(6)
		local calc = imgui.CalcTextSize(u8(getPlayerNickName(targetID)).." ["..targetID.."]")
		imgui.SetCursorPosX(125 - calc.x / 2 )
		imgui.TextColoredRGB("{5BF165}"..u8(getPlayerNickName(targetID)).." ["..targetID.."]")
		imgui.PopFont()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 2))
		local function stopKeyPressed()
			lua_thread.create(function()
				setVirtualKeyDown(VK_RBUTTON, true) 
				wait(1)
				setVirtualKeyDown(VK_RBUTTON, false)
			end)
		end
		for i = 1, #setting2.funcPKM.slider do
			if optionsPKM[setting2.funcPKM.slider[i] + 1] ~= nil then
				imgui.Spacing()
				imgui.SetCursorPosX(-20)
				if imgui.Button("    "..optionsPKM[setting2.funcPKM.slider[i] + 1].."##sl"..i, imgui.ImVec2(276, 27)) then
					stopKeyPressed()
					funcTargetDo(setting2.funcPKM.slider[i])
					choiceWin.v = false
				end
			end
		end
		imgui.Dummy(imgui.ImVec2(0, 2))
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 2))
		if imgui.Button(u8"Закрыть", imgui.ImVec2(233,27)) then choiceWin.v = false stopKeyPressed() end
		imgui.End()
		else
		choiceWin.v = false
	end
end
function profbWind()
local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(710, 450), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Помощь по шпаргалкам", profbWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			local vt1 = [[Основные принципы использования скрипта для автоматизации медицинских действий. Здесь представлены основные функции скрипта для упрощения работы.
			{FFCD00}1. Переменные цены{FFFFFF}
				Для создания переменной используется символ {ACFF36}#{FFFFFF}, затем имя переменной.
			Значение переменной можно задать через число или текст, чтобы потом использовать.
				Для задания значения используется знак {ACFF36}={FFFFFF} и после него пишется значение, которое
			присваивается этой переменной. После этого её можно использовать.
					Пример: {ACFF36}#price=10.000$.{FFFFFF}
				Теперь, используя переменную {ACFF36}#price{FFFFFF}, можно вставить её в любое сообщение, и она
			подставит значение из заданной цены на лечение, которое вы 
			установили ранее.
			
			{FFCD00}2. Комментарии в скрипте{FFFFFF}
				В редакторе комментарии можно использовать двумя способами: для описания действий
			или для отключения частей скрипта. Обычно используется двойной слэш //,
			чтобы закомментировать часть кода.
				Пример: {ACFF36}Здравствуйте, я ваш лечащий врач // приветствие{FFFFFF}
			Использование {ACFF36}// приветствие{FFFFFF} не будет отправлено в чат и останется только в коде.
			
			{FFCD00}3. Создание диалога{FFFFFF}
				В редакторе диалогов можно создавать интерактивные окна, в которых игрок сможет
			выбирать варианты ответов для дальнейших действий.
			Синтаксис диалога:
			{ACFF36}{dialog}{FFFFFF} 		- начало блока диалога
			{ACFF36}[name]=Название{FFFFFF}- имя диалога. Знак равенства обязателен. Имя не должно быть пустым
			{ACFF36}[1]=Вариант{FFFFFF}		- номер варианта для выбора, например 1 - это
			первая опция. Можно использовать и другие клавиши, например, [X], [B],
			[NUMPAD1], [NUMPAD2] и т.д. После выбора варианта будет выполнена команда. Также можно
			использовать переменные, которые будут подставлены в действия. 
			Кроме того, после каждого варианта можно указать действия.
			{ACFF36}Список действий...
			{ACFF36}[2]=Вариант{FFFFFF}	
			{ACFF36}Список действий...
			{ACFF36}{dialogEnd}{FFFFFF}		- конец блока диалога
		]]
		local vt2 = [[
									{E45050}Ограничения:
		1. Количество вариантов в диалоге не ограничено, но 
		рекомендуется не более 10 для удобства;
		2. Можно использовать только латинские буквы и цифры, 
		а также специальные символы;
		3. Нельзя использовать для названий зарезервированные слова 
		(диалог, конец, имя и т.п.)
		]]
		local vt3 = [[
		{FFCD00}4. Использование переменных{FFFFFF}
		Здесь список всех переменных, которые можно использовать в сообщениях или в командах.
		Их использование упрощает написание скриптов, делая их гибкими.
		Примеры таких переменных:
			1. Стандартные - те, которые уже есть по умолчанию, например, 
		используются в любых сообщениях, например, {ACFF36}{myID}{FFFFFF} - выводит ваш ID.
			2. Чит-команды - специальные переменные, которые выполняют дополнительные функции.
		Список переменных:
			{ACFF36}{sleep:[задержка]}{FFFFFF} - задержка выполнения в миллисекундах. 
		Указывается числом в миллисекундах. Пример: {ACFF36}{sleep:2000}{FFFFFF} - задержка в 2 секунды
		1 секунда = 1000 миллисекунд

			{ACFF36}{sex:текст1|текст2}{FFFFFF} - подставляет текст в зависимости от пола игрока.
		Особенно полезно, если вы обращаетесь к игроку с уважением.
		Где {6AD7F0}текст1{FFFFFF} - для мужского пола, {6AD7F0}текст2{FFFFFF} - для женского. Рекомендуется использовать всегда.
			Пример: {ACFF36}Я {sex:доктор|доктор} поликлиники.

			{ACFF36}{getNickByID:ID игрока}{FFFFFF} - получить ник игрока по его ID.
		Пример: у игрока ник {6AD7F0}Nick_Name{FFFFFF} и id - 25.
		{ACFF36}{getNickByID:25}{FFFFFF} выдаст - {6AD7F0}Nick Name.
		]]
			imgui.TextColoredRGB(vt1)

			imgui.BeginGroup()
				imgui.TextDisabled(u8"					Пример")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##dialogPar", helpd.exp, imgui.ImVec2(220, 180), 16384)
				imgui.PopStyleColor(1)
				imgui.TextDisabled(u8"Для копирования используйте\nCtrl + C. Вставка - Ctrl + V")
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginGroup()
				imgui.TextColoredRGB(vt2)
				if imgui.Button(u8"Список ключей", imgui.ImVec2(150,25)) then
					imgui.OpenPopup("helpdkey")
				end
			imgui.EndGroup()
			imgui.TextColoredRGB(vt3)
			------
			if imgui.BeginPopup("helpdkey") then
				imgui.BeginChild("helpdkey", imgui.ImVec2(290,320))
					imgui.TextColoredRGB("{FFCD00}Ключи, которые можно использовать")
					imgui.BeginGroup()
						for _,v in ipairs(helpd.key) do
							if imgui.Selectable(u8("["..v.k.."] 	-	"..v.n)) then
								setClipboardText(v.k)
							end
						end
					imgui.EndGroup()
				imgui.EndChild()
			imgui.EndPopup()
			end
		imgui.End()
end
function testwin()
local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			for i,v in pairs(fa) do
				if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then setClipboardText(i) end
			end
			
		imgui.End()
end

function inDepWin()
	if not animka_dep.MoveAnim then
		seelD = imgui.Cond.FirstUseEver
	else
		seelD = imgui.Cond.Always
	end
	local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(950, 445), seelD)
		imgui.SetNextWindowPos(imgui.ImVec2(animka_dep.posX, animka_dep.posY), seelD, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_SIGNAL .. u8" Меню департамента.", depWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
			imgui.SetCursorPosX(420)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Меню департамента.")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(920)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_dep.paramOff then 
				posWinClosed = imgui.GetWindowPos()
				styleAnimationClose(2, 950, 445)
				animka_dep.paramOff = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(925)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(925)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginGroup()
			imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
			if imgui.Button(fa.ICON_COG..u8" Настройки департамента", imgui.ImVec2(230, 25)) then
				imgui.OpenPopup(u8"MH | Настройки департамента");
				chgDepSetD[1].v = setdepteg.tegtext_one
				chgDepSetD[2].v = setdepteg.tegtext_two
				chgDepSetD[3].v = setdepteg.tegtext_three
				num_dep.v = setdepteg.tegpref_one
				num_dep2.v = setdepteg.tegpref_two
				prefixDefolt = setdepteg.prefix
			end
			imgui.PopStyleColor(1)
			if imgui.BeginPopupModal(u8"MH | Настройки департамента", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
				imgui.SetCursorPosX(186)
				imgui.Text(u8"Настройки департамента")
				imgui.Separator();
				imgui.SetCursorPosY(60)
				imgui.Text(u8"/d "); imgui.SameLine();
				imgui.SetCursorPosY(58)
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext1", chgDepSetD[1]);
				imgui.SameLine();
				imgui.SetCursorPosX(35)
					if chgDepSetD[1].v == "" or chgDepSetD[1].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Тег");
					end
				imgui.SameLine();
				imgui.SetCursorPosX(99);
				imgui.PushItemWidth(193);
					if imgui.Combo(u8"##pref1", num_dep, list_dep_pref_one) then end
				imgui.SameLine();
				imgui.SetCursorPosX(297);
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext2", chgDepSetD[2]);
				imgui.SameLine();
				imgui.SetCursorPosX(303);
					if chgDepSetD[2].v == "" or chgDepSetD[2].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Тег");
					end
				imgui.SameLine();
				imgui.SetCursorPosX(367);
				imgui.PushItemWidth(193);
					if imgui.Combo(u8"##pref2", num_dep2, list_dep_pref_two) then end
				imgui.SameLine();
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext3", chgDepSetD[3]);
				imgui.SameLine();
				imgui.SetCursorPosX(570);
					if chgDepSetD[3].v == "" or chgDepSetD[3].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Тег");
					else
						imgui.Dummy(imgui.ImVec2(0, 1))
					end
				imgui.Dummy(imgui.ImVec2(0, 1))
				imgui.Separator();
				imgui.Text(u8"Вот как будет выглядеть тег:");
				imgui.SameLine();
				imgui.TextColoredRGB(u8"{ffe14d}/d ".. u8:decode(DepTxtEndSetting(prefix_end[2])) .. "В чат...");
				imgui.Separator();
				imgui.Dummy(imgui.ImVec2(0, 6))
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Проверьте свой тег, чтобы не отправлять пустые сообщения.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Тег не должен содержать пробелов, используйте только буквы и цифры")
				imgui.SetCursorPosX(53);
				imgui.TextColoredRGB("{00ff8c}Проверяйте на наличие лишних символов, особенно в начале строки.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Важно помнить! Не используйте тег в диалогах или личных сообщениях.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Проверьте правильность написания префикса департамента. (Важно знать)")
				imgui.Dummy(imgui.ImVec2(0, 6))
				imgui.Separator();
						if imgui.Button(u8"Редактировать префикс (тег) департамента", imgui.ImVec2(622, 0)) then 
						imgui.OpenPopup(u8"MH | Редактирование префикса (тега)")
						chgDepSetPref.v = prefixDefolt[num_pref.v + 1]
						end 
						imgui.Separator();
						imgui.Dummy(imgui.ImVec2(0, 6))
						if imgui.Button(u8"Применить", imgui.ImVec2(308, 0)) then 
							setdepteg.tegtext_one = chgDepSetD[1].v
							setdepteg.tegtext_two = chgDepSetD[2].v
							setdepteg.tegtext_three = chgDepSetD[3].v
							setdepteg.tegpref_one = num_dep.v
							setdepteg.tegpref_two =  num_dep2.v
							local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
							f:write(encodeJson(setdepteg))
							f:flush()
							f:close()
							sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
							imgui.CloseCurrentPopup();
							lockPlayerControl(false);
						end 
						imgui.SameLine();
						if imgui.Button(u8"Закрыть", imgui.ImVec2(308, 0)) then 
							imgui.CloseCurrentPopup()
							lockPlayerControl(false)
						end
						if imgui.BeginPopupModal(u8"MH | Редактирование префикса (тега)", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
							imgui.SetCursorPosX(10)
							imgui.Text(u8"Редактирование тега для быстрого изменения префикса департамента.")
							imgui.SetCursorPosX(60)
							imgui.Text(u8"Введите новый префикс или выберите из списка, затем сохраните")
							imgui.SetCursorPosX(170)
							imgui.Text(u8"Используйте стандартные названия отделов.")
							imgui.Separator();
							imgui.Spacing();
							imgui.PushItemWidth(230);
							prefixDefolt[num_pref.v + 1] = chgDepSetPref.v
							if imgui.Combo(u8"##tegorg", num_pref, dep.sel_all) then
								chgDepSetPref.v = prefixDefolt[num_pref.v + 1]
							end --// Rgf
							imgui.SameLine();
							imgui.PushItemWidth(120);
							imgui.InputText(u8" Ваш префикс", chgDepSetPref);
							imgui.Dummy(imgui.ImVec2(0, 6));
							if imgui.Button(u8"Применить", imgui.ImVec2(275, 0)) then 
								setdepteg.prefix = prefixDefolt
								local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
								f:write(encodeJson(setdepteg))
								f:flush()
								f:close()
								sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
								imgui.CloseCurrentPopup();
								lockPlayerControl(false);
							end 
							imgui.SameLine();
							if imgui.Button(u8"Закрыть", imgui.ImVec2(275, 0)) then 
								imgui.CloseCurrentPopup();
								lockPlayerControl(false);
							end
						imgui.EndPopup()
						end
				imgui.EndPopup()
				end
			imgui.Dummy(imgui.ImVec2(0, 4)) 
				imgui.BeginChild("dep list", imgui.ImVec2(230, 158), true)
					if ButtonDep(u8(dep.list[2]), dep.bool[2]) and dep.select_dep[2] == 0 then --> ����� �����
						dep.bool = {false, true, false, false, false, false}
						dep.select_dep[1] = 2
						select_depart = 2
					end
					if ButtonDep(u8(dep.list[6]), dep.bool[6]) and dep.select_dep[2] == 0 then --> ���. ���������
						dep.bool = {false, false, false, false, false, true, false}
						dep.select_dep[1] = 6
						select_depart = 3
					end
					if ButtonDep(u8(dep.list[7]), dep.bool[7]) and dep.select_dep[2] == 0 then --> GOV
						dep.bool = {false, false, false, false, false, false, true}
						dep.select_dep[1] = 7
						getGovFile()
						select_depart = 4
					end
				imgui.EndChild()
					if dep.select_dep[1] < 5 and dep.select_dep[1] ~= 0 and dep.select_dep[2] == 0 then
						if dep.select_dep[1] == 1 then
							imgui.Dummy(imgui.ImVec2(0, 5)) 
							if imgui.Button(u8"Активировать тег", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then 
										dep.select_dep[2] = i
									end
								end
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы активировали свой тег. Используйте его в департаментском чате.\n\nДля отключения просто нажмите снова.")
						end
						if dep.select_dep[1] == 2 then
							imgui.Dummy(imgui.ImVec2(0, 3)) 
							imgui.PushItemWidth(207);
							imgui.InputText(u8"##preftext1", your_tag);
							imgui.SameLine();
							imgui.SetCursorPosX(15);
							if your_tag.v == "" or your_tag.v == nil then
								imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Ваш тег");
							end
							imgui.SameLine()
							imgui.SetCursorPosX(220);
							ShowHelpMarker(u8"Введите ваш тег, чтобы активировать его в департаментском чате.\n\nДля отключения просто нажмите снова.")
							imgui.Dummy(imgui.ImVec2(0, 3)) 
							imgui.PushItemWidth(228);
							if your_tag.v ~= "" and your_tag.v ~= nil then
								imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(156, 156, 156, 200):GetVec4())
								imgui.Combo("##orgs", num_dep3, dep.sel_all)
								imgui.PopStyleColor(1)
							else
								imgui.Combo("##orgs", num_dep3, dep.sel_all)
							end
								imgui.Dummy(imgui.ImVec2(0, 3)) 
							if imgui.Button(u8"Активировать тег", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
								sampSendChat(string.format("/d %sв чат...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Пример использования:\n\n/d ".. DepTxtEnd(prefix_end[2]) .. u8"в чат...\n\nПосле тега вы можете ввести своё сообщение.")
							if imgui.Button(u8"Активировать тег", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
								sampSendChat(string.format("/d %sв чат...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Пример использования:\n\n/d ".. DepTxtEnd(prefix_end[2]) .. u8"в чат...\n\nПосле тега вы можете ввести своё сообщение.")
							if imgui.Button(u8"Активировать тег", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы активировали свой тег. Используйте префикс \"" .. dep.sel_all[num_dep3.v+1] .. u8"\" для отправки сообщений.\n\nДля отключения просто нажмите снова.")
						end
					elseif dep.bool[5] then
						imgui.Dummy(imgui.ImVec2(0, 5))
						imgui.SetCursorPosX(60)
						imgui.Text(u8"Текущее время: "..dep.time[1]..":"..dep.time[2])
						imgui.Spacing()
						imgui.Spacing()
							imgui.SetCursorPosX(60)
							imgui.Text(u8"Часы\t\t Минуты");
							imgui.SetCursorPosX(45)
							if imgui.SmallButton("<<") and dep.time[1] > 0 then dep.time[1] = dep.time[1] - 1 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[1]))
							imgui.SameLine()
							if imgui.SmallButton(">>") and dep.time[1] < 24 then dep.time[1] = dep.time[1] + 1 end
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							if imgui.SmallButton("<<##1") and dep.time[2] > 0 then dep.time[2] = dep.time[2] - 5 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[2]))
							imgui.SameLine()
							if imgui.SmallButton(">>##1") and dep.time[2] < 55 then dep.time[2] = dep.time[2] + 5 end
						imgui.Spacing()
						imgui.Spacing()
						if imgui.Button(u8"��������", imgui.ImVec2(208, 25)) then
							lua_thread.create(function()
							local inpSob = string.format("%d,%d,%s", dep.time[1], dep.time[2], u8:decode(list_org[num_org.v+1]))
								sampSendChat(string.format("/d [%s] - [Диспетчер] Вызов на частоте 103,9", u8:decode(list_org[num_org.v+1])))
								wait(1750)
								sampSendChat(string.format("/d [%s] - [103,9] Приём сообщений для проведения собеседования.", u8:decode(list_org[num_org.v+1])))
								wait(500)
								sampSendChat("/lmenu")
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1214
								sampSetCurrentDialogListItem(2)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1336
								sampSetCurrentDialogListItem(0)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(0) until sampIsDialogActive() and sampGetCurrentDialogId() == 1335
								wait(350)
								sampSetCurrentDialogEditboxText(inpSob)
								wait(350)
								sampCloseCurrentDialogWithButton(1)
								wait(1700)
								sampSendChat(string.format("/d [%s] - [Диспетчер] Вызов на частоте 103,9.",  u8:decode(list_org[num_org.v+1]))) 
							end)
						end
					elseif  dep.bool[6] then
						imgui.Dummy(imgui.ImVec2(0, 5)) 
						if imgui.Button(u8"Отправить", imgui.ImVec2(208, 25)) then 
							sampSendChat(string.format("/d %sСмены. Начало.", u8:decode(DepTxtEnd(prefix_end[1]))))
						end
						imgui.SameLine()
						ShowHelpMarker(u8"Пример использования:\n\n/d ".. DepTxtEnd(prefix_end[1]) .. u8"Смены. Начало.")
					elseif dep.bool[7] then
						imgui.Spacing()
						imgui.PushItemWidth(225)
						if imgui.Combo("##news", dep.newsN, dep.news) then
							brp = 0
							lua_thread.create(function()
								deadgov = true
								if doesFileExist(dirml.."/MedicalHelper/госновости/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") then
    							for line in io.lines(dirml.."/MedicalHelper/госновости/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") do
										if brp < 6 then
											trtxt[brp + 1].v = u8(line)
											brp = brp + 1
										end
									end
								end
								deadgov = false
							end)
						end
						imgui.PopItemWidth()
						imgui.Dummy(imgui.ImVec2(0, 2))
							
							imgui.Text(u8"Выберите нужный файл новости для")
							imgui.Text(u8"публикации в чат.")
							imgui.SetCursorPos(imgui.ImVec2(133, 293))
							imgui.TextColoredRGB("{29EB2F}Папка")
							if imgui.IsItemHovered() then 
								imgui.SetTooltip(u8"Нажмите, чтобы открыть папку.")
							end
							if imgui.IsItemClicked(0) then
								print(shell32.ShellExecuteA(nil, 'open', dirml.."/MedicalHelper/госновости/", nil, nil, 1))
							end
						imgui.Dummy(imgui.ImVec2(0, 85))
						if imgui.Button(u8"Опубликовать", imgui.ImVec2(208, 25)) then
							lua_thread.create(function()
								if doesFileExist(dirml.."/MedicalHelper/госновости/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") then
								deadgov = true
									for line in io.lines(dirml.."/MedicalHelper/госновости/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") do
										sampSendChat(line)
										wait(1800)
									end
								end
								deadgov = false
							end)
						end
							imgui.SameLine()
							ShowHelpMarker(u8"Пример использования: \n\n".. trtxt[1].v.. "\n".. trtxt[2].v.. "\n".. trtxt[3].v .. "\n".. trtxt[4].v .. "\n".. trtxt[5].v .. "\n".. trtxt[6].v)
					elseif dep.select_dep[2] < 5 and dep.select_dep[2] ~= 0 then
						imgui.Dummy(imgui.ImVec2(0, 5)) 
						imgui.PushItemWidth(225)
						if dep.select_dep[1] == 1 then --����
							if imgui.Button(u8"Отключить", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
								sampSendChat(string.format("/d %sначало смены...", u8:decode(DepTxtEnd(prefix_end[1]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключили свой тег. Отмена. Пример использования:\n\n/d " .. DepTxtEnd(prefix_end[1]).. u8"начало смены...")
							if imgui.Button(u8"Отключить тег", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключили свой тег. Отмена.\n\nВ этом разделе ничего нет.")
						end
						if dep.select_dep[1] == 2 then --����������
							if imgui.Button(u8"Отключить", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
								sampSendChat(string.format("/d %sначало смены...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
 							ShowHelpMarker(u8"Вы отключили свой тег. Используйте префикс \"" .. dep.sel_all[num_dep3.v+1] .. u8"\". Пример использования:\n\n/d " .. DepTxtEnd(prefix_end[2]).. u8"начало смены...")
								if imgui.Button(u8"Отключить тег", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключили свой тег. Отмена.\n\nВ этом разделе ничего нет.")
						end
						imgui.PopItemWidth()

					else
						imgui.SetCursorPos(imgui.ImVec2(23, 250)) 
						imgui.Text(u8"Выберите отделение")
					end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginChild("dep log", imgui.ImVec2(0, 0), true)
				imgui.SetCursorPosX(305)
				imgui.Text(u8"История чата")
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"Нажмите ПКМ для очистки") end
				if imgui.IsItemClicked(1) then dep.dlog = {} end
					imgui.BeginChild("dep logg", imgui.ImVec2(0, 325), true)
						for i,v in ipairs(dep.dlog) do
							imgui.TextColoredRGB(v)
						end
						imgui.SetScrollY(imgui.GetScrollMaxY())
					imgui.EndChild()
				imgui.Spacing()
				imgui.Text(u8"Сообщение:");
				imgui.SameLine()
				imgui.PushItemWidth(550)
				imgui.InputText("##chat", dep.input)
				imgui.PopItemWidth()
				imgui.SameLine()
				if dep.select_dep[2] ~= 0 and not dep.bool[5] and not dep.bool[6] and not dep.bool[7] then
					if imgui.Button(u8"Отправить", imgui.ImVec2(80, 21.5)) then
						if dep.select_dep[2] < 3 and dep.select_dep[2] > 0 then
							if dep.bool[1] then
								sampSendChat(string.format("/d %s"..u8:decode(dep.input.v), u8:decode(DepTxtEnd(prefix_end[1]))))
							elseif dep.bool[2] then
								sampSendChat(string.format("/d %s"..u8:decode(dep.input.v), u8:decode(DepTxtEnd(prefix_end[num_dep3.v + 1]))))
							end
						end
						dep.input.v = ""
					end
				else
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.Button(u8"Отправить", imgui.ImVec2(80, 21.5))
					imgui.PopStyleColor(3)
				end
				if dep.select_dep[2] == 0 then
					imgui.SameLine()
					ShowHelpMarker(u8"Выберите отделение для отправки сообщения.\n\nДля этого выберите одно из доступных отделений.")
				elseif dep.bool[1] then
					imgui.SameLine()
					ShowHelpMarker(u8"Отправка сообщения в отделение:\n\n/d ".. DepTxtEnd(prefix_end[1]) .. dep.input.v)
				elseif dep.bool[2] then
					imgui.SameLine()
					ShowHelpMarker(u8"Отправка сообщения в отделение:\n\n/d ".. DepTxtEnd(prefix_end[num_dep3.v + 1]) .. dep.input.v)
				elseif dep.bool[5] or dep.bool[6] or dep.bool[7] then
					imgui.SameLine()
					ShowHelpMarker(u8"Отправка сообщения в отделение:\n\n/d ".. DepTxtEnd(prefix_end[num_dep3.v + 1]) .. dep.input.v)
				end
			
				---------------------------------------------------
			imgui.EndChild()
		imgui.End()
end

function settingMassiveSave()
	setting.nick = u8:decode(buf_nick.v)
	setting.teg = u8:decode(buf_teg.v)
	setting.org = num_org.v
	setting.sex = num_sex.v
	setting.rank = num_rank.v
	setting.time = cb_time.v
	setting.timeTx = u8:decode(buf_time.v)
	setting.timeDo = cb_timeDo.v
	setting.rac = cb_rac.v
	setting.racTx = u8:decode(buf_rac.v)
	setting.lec = buf_lec.v
	setting.rec = buf_rec.v
	setting.narko = buf_narko.v
	setting.tatu = buf_tatu.v
	setting.ant = buf_ant.v
	setting.chat1 = cb_chat1.v
	setting.chat2 = cb_chat2.v
	setting.chat3 = cb_chat3.v
	setting.chathud = cb_hud.v
	setting.arp = arep
	setting.setver = setver
	setting.htime = cb_hudTime.v
	setting.hping = hudPing
	setting.orgl = {}
	setting.rankl = {}
	setting.theme = num_theme.v
	setting.themAngle = theme_Angle.v
	theme_AngleTest = theme_Angle.v
	setting.spawn = accept_spawn.v
	setting.autolec = accept_autolec.v
	setting.prikol = prikol.v
	setting2.funcPKM.func = chg_funcPKM.func.v
	for i = 1, #chg_funcPKM.slider do
		setting2.funcPKM.slider[i] = chg_funcPKM.slider[i].v
	end
	for i,v in ipairs(chgName.org) do
		setting.orgl[i] = u8:decode(v)
	end
	for i,v in ipairs(chgName.rank) do
		setting.rankl[i] = u8:decode(v)
	end
	for i = 1, 4 do
		setting.mede[i] = buf_mede[i].v
		setting.upmede[i] = buf_upmede[i].v
	end
	local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
	f:write(encodeJson(setting))
	f:flush()
	f:close()
	local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med", "w")
	f:write(encodeJson(setting2))
	f:flush()
	f:close()
end

function settingMassiveSave2()
	for i, v in ipairs(setCmdEdit[selected_cmd].sec) do
		setCmdEdit[selected_cmd].sec[i] = chgCmd[i].v * 1000
		setCmdEdit[selected_cmd].text[i] = chgCmdSet[i].v
	end
	local f = io.open(dirml.."/MedicalHelper/госновости.med", "w")
	f:write(encodeJson(setCmdEdit))
	f:flush()
	f:close()
end

function settingMassiveMembers()
	membScr = {
		func = C_membScr.func.v,
		pos = {x = C_membScr.pos.x.v, y = C_membScr.pos.y.v},
		forma = C_membScr.forma.v,
		numrank = C_membScr.numrank.v,
		id = C_membScr.id.v,
		afk = C_membScr.afk.v,
		dialog = C_membScr.dialog.v,
		vergor = C_membScr.vergor.v,
		font = {
			size = C_membScr.font.size.v,
			flag = C_membScr.font.flag.v,
			distance = C_membScr.font.distance.v,
			visible = C_membScr.font.visible.v
		},
		color = {
				col_title 	= C_membScr.color.col_title,
				col_default =  C_membScr.color.col_default,
				col_no_work =  C_membScr.color.col_no_work
		}	
	}
	
	local f = io.open(dirml.."/MedicalHelper/MainMembers.med", "w")
	f:write(encodeJson(membScr))
	f:flush()
	f:close()
end

function profitmoney()
	
	imgui.SetCursorPosX(152)
	imgui.SetCursorPosY(41)
	if select_menu_money then
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		if imgui.Button(u8"Прибыль клиники", imgui.ImVec2(345, 24)) then select_menu_money = true end
		imgui.PopStyleColor(1)
		imgui.SetCursorPosX(499)
		imgui.SetCursorPosY(41)
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
		if imgui.Button(u8"История прибыли", imgui.ImVec2(345, 24)) then select_menu_money = false end
		imgui.PopStyleColor(1)
	else
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
		if imgui.Button(u8"Прибыль клиники", imgui.ImVec2(345, 24)) then select_menu_money = true end
		imgui.PopStyleColor(1)
		imgui.SetCursorPosX(499)
		imgui.SetCursorPosY(41)
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		if imgui.Button(u8"История прибыли", imgui.ImVec2(345, 24)) then select_menu_money = false end
		imgui.PopStyleColor(1)
	end
	imgui.SameLine()
	if profit_money.payday[id_param] ~= 0 then
		imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[id_param]).."$")
	end
	if profit_money.lec[id_param] ~= 0 then
		imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[id_param]).."$")
	end
	if profit_money.medcard[id_param] ~= 0 then
		imgui.TextColoredRGB(" Продажа мед.карт: {36cf5c}"..point_sum(profit_money.medcard[id_param]).."$")
	end
	if profit_money.narko[id_param] ~= 0 then
		imgui.TextColoredRGB(" Лечение наркозависимости: {36cf5c}"..point_sum(profit_money.narko[id_param]).."$")
	end
	if profit_money.vac[id_param] ~= 0 then
		imgui.TextColoredRGB(" Вакцинация: {36cf5c}"..point_sum(profit_money.vac[id_param]).."$")
	end
	if profit_money.ant[id_param] ~= 0 then
		imgui.TextColoredRGB(" Выдача антибиотиков: {36cf5c}"..point_sum(profit_money.ant[id_param]).."$")
	end
	if profit_money.rec[id_param] ~= 0 then
		imgui.TextColoredRGB(" Выдача рецептов: {36cf5c}"..point_sum(profit_money.rec[id_param]).."$")
	end
	if profit_money.medcam[id_param] ~= 0 then
		imgui.TextColoredRGB(" Расширенные медкарты: {36cf5c}"..point_sum(profit_money.medcam[id_param]).."$")
	end
	if profit_money.cure[id_param] ~= 0 then
		imgui.TextColoredRGB(" От болезни: {36cf5c}"..point_sum(profit_money.cure[id_param]).."$")
	end
	if profit_money.strah[id_param] ~= 0 then
		imgui.TextColoredRGB(" Оформление страховки: {36cf5c}"..point_sum(profit_money.strah[id_param]).."$")
	end
	if profit_money.tatu[id_param] ~= 0 then
		imgui.TextColoredRGB(" Удаление тату: {36cf5c}"..point_sum(profit_money.tatu[id_param]).."$")
	end
	if profit_money.premium[id_param] ~= 0 then
		imgui.TextColoredRGB(" Доход от премиума: {36cf5c}"..point_sum(profit_money.premium[id_param]).."$")
	end
		local function text_profit_2(param_id)
			imgui.Separator()
			imgui.SetCursorPosX(315)
			imgui.TextColoredRGB(profit_money.date_week[param_id])
			imgui.Separator()
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			text_profit(param_id)
			local money_all = point_sum(profit_money.payday[param_id] + profit_money.lec[param_id] + profit_money.medcard[param_id] + profit_money.narko[param_id] + profit_money.vac[param_id] + profit_money.ant[param_id] + profit_money.rec[param_id] + profit_money.medcam[param_id] + profit_money.cure[param_id] + profit_money.strah[param_id] + profit_money.tatu[param_id] + profit_money.premium[param_id])
			if money_all ~= "0" then
			imgui.TextColoredRGB(" Итого за день: {36cf5c}"..money_all.."$")
			else
			imgui.TextColoredRGB(" За этот день ничего не заработано.")
			end
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Separator()
		end
	imgui.SetCursorPosY(75)
	imgui.SetCursorPosX(152)
	imgui.BeginChild("money", imgui.ImVec2(695, 380), true)
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.SetCursorPosX(90)
	imgui.TextColoredRGB("Здесь отображается прибыль и онлайн за последние семь дней.")
	imgui.SameLine()
	ShowHelpMarker(u8"Тут, всё что вы заработали, и сколько времени вы провели в игре за последнюю неделю.\nДанные обновляются каждые 7 дней. После недели данные сбрасываются.")
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Separator()
	imgui.SetCursorPosX(315)
	imgui.TextColoredRGB(profit_money.date_week[1])
	imgui.Separator()
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	text_profit(1)
	local moneyall1 = point_sum(profit_money.payday[1] + profit_money.lec[1] + profit_money.medcard[1] + profit_money.narko[1] + profit_money.vac[1] + profit_money.ant[1] + profit_money.rec[1] + profit_money.medcam[1] + profit_money.cure[1] + profit_money.strah[1] + profit_money.tatu[1] + profit_money.premium[1])
	if moneyall1 ~= "0" then
		imgui.TextColoredRGB(" Итого за день: {36cf5c}"..moneyall1.."$")
	else
		imgui.TextColoredRGB(" За этот день ничего не заработано.")
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	for k = 2, 7 do
		if profit_money.date_week[k] ~= "" then
			text_profit_2(k)
		end
	end
	profit_money.total_week = profit_money.payday[1] + profit_money.payday[2] + profit_money.payday[3] + profit_money.payday[4] + profit_money.payday[5] + profit_money.payday[6] + profit_money.payday[7] +
	profit_money.lec[1] + profit_money.lec[2] + profit_money.lec[3] + profit_money.lec[4] + profit_money.lec[5] + profit_money.lec[6] + profit_money.lec[7] +
	profit_money.medcard[1] + profit_money.medcard[2] + profit_money.medcard[3] + profit_money.medcard[4] + profit_money.medcard[5] + profit_money.medcard[6] + profit_money.medcard[7] +
	profit_money.narko[1] + profit_money.narko[2] + profit_money.narko[3] + profit_money.narko[4] + profit_money.narko[5] + profit_money.narko[6] + profit_money.narko[7] +
	profit_money.vac[1] + profit_money.vac[2] + profit_money.vac[3] + profit_money.vac[4] + profit_money.vac[5] + profit_money.vac[6] + profit_money.vac[7] +
	profit_money.ant[1] + profit_money.ant[2] + profit_money.ant[3] + profit_money.ant[4] + profit_money.ant[5] + profit_money.ant[6] + profit_money.ant[7] +
	profit_money.rec[1] + profit_money.rec[2] + profit_money.rec[3] + profit_money.rec[4] + profit_money.rec[5] + profit_money.rec[6] + profit_money.rec[7] +
	profit_money.medcam[1] + profit_money.medcam[2] + profit_money.medcam[3] + profit_money.medcam[4] + profit_money.medcam[5] + profit_money.medcam[6] + profit_money.medcam[7] +
	profit_money.cure[1] + profit_money.cure[2] + profit_money.cure[3] + profit_money.cure[4] + profit_money.cure[5] + profit_money.cure[6] + profit_money.cure[7] +
	profit_money.strah[1] + profit_money.strah[2] + profit_money.strah[3] + profit_money.strah[4] + profit_money.strah[5] + profit_money.strah[6] + profit_money.strah[7] +
	profit_money.tatu[1] + profit_money.tatu[2] + profit_money.tatu[3] + profit_money.tatu[4] + profit_money.tatu[5] + profit_money.tatu[6] + profit_money.tatu[7] +
	profit_money.premium[1] + profit_money.premium[2] + profit_money.premium[3] + profit_money.premium[4] + profit_money.premium[5] + profit_money.premium[6] + profit_money.premium[7] +
	profit_money.other[1] + profit_money.other[2] + profit_money.other[3] + profit_money.other[4] + profit_money.other[5] + profit_money.other[6] + profit_money.other[7]
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Итого за неделю: {36cf5c}"..point_sum(profit_money.total_week).."$")
	imgui.TextColoredRGB(" Итого за все время: {36cf5c}"..point_sum(profit_money.total_all).."$")
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	if imgui.Button(u8"Сбросить данные", imgui.ImVec2(666,23)) then 
		imgui.OpenPopup(u8"MH | Сбросить данные")
	end
	if imgui.BeginPopupModal(u8"MH | Сбросить данные", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB("Вы уверены, что хотите сбросить данные?\n          Все данные будут потеряны.")
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 1))
		if imgui.Button(u8"Сбросить", imgui.ImVec2(152, 0)) then 
			profit_money = {
			payday = {0, 0, 0, 0, 0, 0, 0},
			lec = {0, 0, 0, 0, 0, 0, 0},
			medcard = {0, 0, 0, 0, 0, 0, 0},
			narko = {0, 0, 0, 0, 0, 0, 0},
			vac = {0, 0, 0, 0, 0, 0, 0},
			ant = {0, 0, 0, 0, 0, 0, 0},
			rec = {0, 0, 0, 0, 0, 0, 0},
			medcam = {0, 0, 0, 0, 0, 0, 0},
			cure = {0, 0, 0, 0, 0, 0, 0},
			strah = {0, 0, 0, 0, 0, 0, 0},
			tatu = {0, 0, 0, 0, 0, 0, 0},
			premium = {0, 0, 0, 0, 0, 0, 0},
			other = {0, 0, 0, 0, 0, 0, 0},
			total_week = 0,
			total_all = 0,
			date_num = {0, 0},
			date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
			date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
			date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""}
		}
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
		imgui.SameLine();
		if imgui.Button(u8"Отмена", imgui.ImVec2(152, 0)) then 
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
	imgui.EndPopup()
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.EndChild()
	end
	if not select_menu_money then
		local function text_online(id_param)
			imgui.Separator()
			imgui.SetCursorPosX(315)
			imgui.TextColoredRGB(online_stat.date_week[id_param])
			imgui.Separator()
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.TextColoredRGB(" Активно в день: {36cf5c}"..print_time(online_stat.clean[id_param]))
			imgui.TextColoredRGB(" АФK в день: {36cf5c}"..print_time(online_stat.afk[id_param]))
			imgui.TextColoredRGB(" Всего в день: {36cf5c}"..print_time(online_stat.all[id_param]))
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Separator()
		end
	imgui.SetCursorPosY(75)
	imgui.SetCursorPosX(152)
	imgui.BeginChild("money", imgui.ImVec2(695, 380), true)
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.SetCursorPosX(90)
	imgui.TextColoredRGB("Здесь отображается прибыль и онлайн за последние семь дней.")
	imgui.SameLine()
	ShowHelpMarker(u8"Тут, всё что вы заработали, и сколько времени вы провели в игре за последнюю неделю.\nДанные обновляются каждые 7 дней. После недели данные сбрасываются.")
	imgui.Dummy(imgui.ImVec2(0, 9))
	imgui.Separator()
	imgui.Separator()
	imgui.SetCursorPosX(315)
	imgui.TextColoredRGB(online_stat.date_week[1])
	imgui.Separator()
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Активно в день: {36cf5c}"..print_time(online_stat.clean[1]))
	imgui.TextColoredRGB(" АФK в день: {36cf5c}"..print_time(online_stat.afk[1]))
	imgui.TextColoredRGB(" Всего в день: {36cf5c}"..print_time(online_stat.all[1]))
	imgui.Spacing()
	imgui.Spacing()
	imgui.TextColoredRGB(" Активно за неделю: {36cf5c}"..print_time(session_clean.v))
	imgui.TextColoredRGB(" АФK за неделю: {36cf5c}"..print_time(session_afk.v))
	imgui.TextColoredRGB(" Всего за неделю: {36cf5c}"..print_time(session_all.v))
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	for k = 2, 7 do
		if online_stat.date_week[k] ~= "" then
			text_online(k)
		end
	end
	online_stat.total_week = online_stat.clean[1] + online_stat.clean[2] + online_stat.clean[3] + online_stat.clean[4] + online_stat.clean[5] + online_stat.clean[6] + online_stat.clean[7]
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Активно за неделю: {36cf5c}"..print_time(online_stat.total_week))
	imgui.TextColoredRGB(" АФK за неделю: {36cf5c}"..print_time(online_stat.total_all))
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	if imgui.Button(u8"Сбросить данные", imgui.ImVec2(666,23)) then 
		imgui.OpenPopup(u8"MH | Сбросить данные")
	end
	if imgui.BeginPopupModal(u8"MH | Сбросить данные", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB("Вы уверены, что хотите сбросить данные?\n          Все данные будут потеряны.")
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 1))
		if imgui.Button(u8"Сбросить", imgui.ImVec2(152, 0)) then 
			online_stat = {
				clean = {0, 0, 0, 0, 0, 0, 0},
				afk = {0, 0, 0, 0, 0, 0, 0},
				all = {0, 0, 0, 0, 0, 0, 0},
				total_week = 0,
				total_all = 0,
				date_num = {0, 0},
				date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
				date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
				date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""}
			}
			session_clean.v = 0
			session_afk.v = 0
			session_all.v = 0
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
		imgui.SameLine();
		if imgui.Button(u8"Отмена", imgui.ImVec2(152, 0)) then 
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
		imgui.EndPopup()
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.EndChild()
end

function rankFix()
	if num_rank.v == 10 then
		return u8:decode(list_rank[num_rank.v+1])
	else
		return u8:decode(list_org[num_org.v+1])
	end
end

function ButtonDep(desk, bool)
	local retBool = false
	if bool then
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
		imgui.PopStyleColor(1)
	elseif not bool and dep.select_dep[2] == 0 then
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
		retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
		imgui.PopStyleColor(1)
	elseif not bool and dep.select_dep[2] ~= 0 then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
		retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
		imgui.PopStyleColor(3)
	end
	return retBool
end

function HideDialogInTh(bool)
	repeat wait(0) until sampIsDialogActive()
	while sampIsDialogActive() do
		local memory = require 'memory'
		memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
		sampToggleCursor(bool)
	end
end

function ShowHelpMarker(stext)
	imgui.TextDisabled(u8"(?)")
	if imgui.IsItemHovered() then
	imgui.SetTooltip(stext)
	end
end

function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or mainWin.v and editKey then
		return false
	end
end

function onHotKeyCMD(id, keys)
	if thread:status() == "dead" and lectime == false and statusvac == false then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(cmdBind) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				if k == 1 then
					if not mainWin.v then
						styleAnimationOpen(1)
						mainWin.v = true
					else
						animka_main.paramOff = true
					end
				elseif k == 2 then
					sampSetChatInputEnabled(true)
					if buf_teg.v ~= "" then
						sampSetChatInputText("/r "..u8:decode(buf_teg.v)..": ")
					else
						sampSetChatInputText("/r ")
					end
				elseif k == 3 then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/rb ")
				elseif k == 4 then
					sampSendChat("/members")
				elseif k == 5 then
					if resTarg then
						funCMD.lec(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[5].cmd.." ")
					end
				elseif k == 6 then 
					funCMD.post()
				elseif k == 7 then
					if resTarg then
						funCMD.med(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[7].cmd.." ")
					end
				elseif k == 8 then
					if resTarg then
						funCMD.narko(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[8].cmd.." ")
					end
				elseif k == 9 then
					if resTarg then
						funCMD.recep(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[9].cmd.." ")
					end
				elseif k == 10 then
					funCMD.osm()
				elseif k == 11 then 
					if not depWin.v then
						styleAnimationOpen(2)
						depWin.v = true
					else
						animka_dep.paramOff = true
					end
				elseif k == 12 then
					if not sobWin.v then
						styleAnimationOpen(3)
						sobWin.v = true
					else
						animka_sob.paramOff = true
					end
				elseif k == 13 then 
					if resTarg then
						funCMD.tatu(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[13].cmd.." ")
					end
				elseif k == 14 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[14].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[14].cmd.." ")
					end
				elseif k == 15 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[15].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[15].cmd.." ")
					end
				elseif k == 16 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[16].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[16].cmd.." ")
					end
				elseif k == 17 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[17].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[17].cmd.." ")
					end
				elseif k == 18 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[18].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[18].cmd.." ")
					end
				elseif k == 19 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[19].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[19].cmd.." ")
					end
				elseif k == 20 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[20].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[20].cmd.." ")
					end
				elseif k == 21 then
					funCMD.time()
				elseif k == 22 then
					if resTarg then
						funCMD.expel(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[22].cmd.." ")
					end
				elseif k == 23 then
					if resTarg then
						funCMD.vac(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[23].cmd.." ")
					end
				elseif k == 24 then
					funCMD.info()
				elseif k == 25 then
					funCMD.za()
				elseif k == 26 then
					funCMD.zd()
				elseif k == 27 then
					if resTarg then
						funCMD.ant(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[27].cmd.." ")
					end	
				elseif k == 28 then
					if resTarg then
						funCMD.strah(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[28].cmd.." ")
					end
				elseif k == 29 then
					if resTarg then
						funCMD.cur(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[29].cmd.." ")
					end
				elseif k == 30 then
					funCMD.lec(tostring(targID))
				elseif k == 31 then
					funCMD.hilka()
				elseif k == 32 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[32].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[32].cmd.." ")
					end
				elseif k == 33 then
					funCMD.hme()
				elseif k == 34 then
					if resTarg then
						funCMD.show(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[34].cmd.." ")
					end
				elseif k == 35 then
					funCMD.cam()
				end
			end
		end
	elseif not lectime and not statusvac and not isKeyJustPressed(VK_1) then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} В данный момент выполняется действие.", 0xFF8FA2)
		wait(100)
	end
	if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() and lectime and not statusvac and thread:status() == "dead" then 
		funCMD.lec(tostring(idMesPlayer))
		wait(100)
		lectime = false;
	end
end

function strBinderTable(dir)
	local tb = {
		vars = {},
		bind = {},
		debug = {
			file = true,
			close = {}
		},
		sleep = 1000
	}
	if doesFileExist(dir) then
		local l = {{},{},{},{},{}}
		local f1 = io.open(dir)
		local t = {}
		local ln = 0
		for line in f1:lines() do
			if line:find("^//.*$") then
				line = ""
			elseif line:find("//.*$") then
				line = line:match("(.*)//")
			end
			ln = ln + 1
			if #t > 0 then
				if line:find("%[name%]=(.*)$") then
					t[#t].name = line:match("%[name%]=(.*)$")
				elseif line:find("%[[%a%d]+%]=(.*)$") then
					local k, n = line:match("%[([%d%a]+)%]=(.*)$")
					local nk = vkeys["VK_"..k:upper()]
					if nk then
						local a = {n = n, k = nk, kn = k:upper(), t = {}}
						table.insert(t[#t].var, a)
					end
				elseif line:find("{dialogEnd}") then
					if #t > 1 then
						local a = #t[#t-1].var
						table.insert(t[#t-1].var[a].t, t[#t])
						t[#t] = nil
					elseif #t == 1 then
						table.insert(tb.bind, t[1])
						t = {}
					end
					table.remove(tb.debug.close)
				elseif line:find("{dialog}") then
					local b = {}
					b.name = ""
					b.var = {}
					table.insert(tb.debug.close, ln)
					table.insert(t, b)
				elseif #line > 0 and #t[#t].var > 0 then
					local a = #t[#t].var
					table.insert(t[#t].var[a].t, line)
				end
			else
				if line:find("{dialog}") and #t == 0 then
					local b = {} 
					b.name = ""
					b.var = {}
					table.insert(t, b)
					table.insert(tb.debug.close, ln)
				end
				if #tb.debug.close == 0 and #line > 0 then 
					table.insert(tb.bind, line)
				end
			end
		end
		f1:close()
		return tb
	else
		tb.debug.file = false
		return tb
	end 
end

function playBind(tb)
	if not tb.debug.file or #tb.debug.close > 0 then
		if not tb.debug.file then
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} В данный момент выполняется действие.", 0xFF8FA2)
		elseif #tb.debug.close > 0 then
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Ошибка, в строке "..tb.debug.close[#tb.debug.close]..",  {dialogEnd}", 0xFF8FA2)
		end
		addOneOffSound(0, 0, 0, 1058)
		return false
	end
	function pairsT(t, var)
		for i, line in ipairs(t) do
			if type(line) == "table" then
				renderT(line, var)
			else
				if line:find("{pause}") then
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
					while true do
						wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "Продолжение...\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
							if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
						end
					end
				elseif line:find("{sleep:%d+}") then
					btime = tonumber(line:match("{sleep:(%d+)}"))
				elseif line:find("^%#[%d%a]+=.*$") then
					local var, val = line:match("^%#([%d%a]+)=(.*)$")
					tb.vars[var] = tags(val)			
				else
					wait(i == 1 and 0 or btime or tb.sleep*1000)
					btime = nil
					local str = line
					if var then
						for k,v in pairs(var) do
							str = str:gsub("#"..k, v)
						end
					end
					if str:find("/") then
						sampProcessChatInput(tags(str))
					else
						sampSendChat(tags(str))
					end
				end
			end
		end
	end
	function renderT(t, var)
		local render = true
		local len = renderGetFontDrawTextLength(font, t.name)
		for i,v in ipairs(t.var) do
			local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
			if len < renderGetFontDrawTextLength(font, str) then
				len = renderGetFontDrawTextLength(font, str)
			end
		end
		repeat
			wait(0)
			if not isGamePaused() then
				renderFontDrawText(font, t.name, sx-10-len, sy-#t.var*25-30, 0xFFFFFFFF)
				for i,v in ipairs(t.var) do
					local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
					renderFontDrawText(font, str, sx-10-len, sy-#t.var*25-30+(25*i), 0xFFFFFFFF)
					if isKeyJustPressed(v.k) and not sampIsChatInputActive() and not sampIsDialogActive() then
						pairsT(v.t, var)
						render = false
					end
				end
			end
		until not render						
	end					
	pairsT(tb.bind, tb.vars)
end

function onHotKeyBIND(id, keys)
	if thread:status() == "dead" then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(binder.list) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				thread = lua_thread.create(function()		
					local dir = dirml.."/MedicalHelper/Binder/bind-"..v.name..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = v.sleep
					playBind(tb)
					return
				end)
			end
		end
	end
end

function binderCmdStart()
	for i,v in ipairs(binder.list) do
	local factCommand = sampGetChatInputText()
	local factCommandRussia = string.format(".%s", translatizator(binder.list[i].cmd))
	local sverkaCommand = string.format("/%s", binder.list[i].cmd)
		if sverkaCommand == factCommand or factCommand == factCommandRussia then
		local numberMassive = i
		local nameMassive = binder.list[i].name
			for k, v in pairs(binder.list) do
				if thread:status() == "dead" then
					thread = lua_thread.create(function()
					local dir = dirml.."/MedicalHelper/Binder/bind-"..nameMassive..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = binder.list[i].sleep
					playBind(tb)
					return
					end)	
				end
			end
		end
	end
end

function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	render_text(string)
end

function imgui.GetMaxWidthByText(text)
	local max = imgui.GetWindowWidth()
	for w in text:gmatch('[^\r\n]+') do
		local size = imgui.CalcTextSize(w)
		if size.x > max then max = size.x end
	end
	return max - 15
end

function getSpurFile()
	spur.list = {}
    local search, name = findFirstFile("moonloader/MedicalHelper/шпаргалки/*.txt")
	while search do
		if not name then findClose(search) else
			table.insert(spur.list, tostring(name:gsub(".txt", "")))
			name = findNextFile(search)
			if name == nil then
				findClose(search)
				break
			end
		end
	end
end

function wraper(str, limit, indent, indent1)
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 79
  local here = 1-#indent1
  return indent1..str:gsub("(%s+)()(%S+)()",
	function(sp, st, word, fi)
		if fi-here > limit then
			here = st - #indent
		return "\n"..indent..word
		end
	end)
end

function getGovFile()
deadgov = true
	local govls = [[
	/gov [название LS] - вызвать скорую, помощь и консультацию для жителей этого города
	/gov [название LS] - в этом же формате: номер диспетчера, сообщить причину вызова, описание ситуации
	/gov [название LS] - это вызов полиции в этом городе.
	]]
	local govsf = [[
	/gov [название SF] - вызвать скорую, помощь и консультацию для жителей этого города
	/gov [название SF] - в этом же формате: номер диспетчера, сообщить причину вызова, описание ситуации
	/gov [название SF] - это вызов полиции в этом городе.
	]]
	local govlv = [[
	/gov [название LV] - вызвать скорую, помощь и консультацию для жителей этого города
	/gov [название LV] - в этом же формате: номер диспетчера, сообщить причину вызова, описание ситуации
	/gov [название LV] - это вызов полиции в этом городе.
	]]
	local govjf = [[
	/gov [название Jafferson] - вызвать скорую, помощь и консультацию для жителей этого города
	/gov [название Jafferson] - в этом же формате: номер диспетчера, сообщить причину вызова, описание ситуации
	/gov [название Jafferson] - это вызов полиции в этом городе.
	]]

	lua_thread.create(function()
		if doesDirectoryExist(dirml.."/MedicalHelper/госновости/") then
			if doesFileExist(dirml.."/MedicalHelper/госновости/Вызов скорой помощи.txt") or not doesFileExist(dirml.."/MedicalHelper/госновости/Вызов скорой помощи LS.txt") then
				os.remove(dirml.."/MedicalHelper/госновости/Вызов скорой помощи.txt")
				local f = io.open(dirml.."/MedicalHelper/госновости/Вызов скорой помощи LS.txt", "w")
				f:write(govls)
				f:flush()
				f:close()
				local f = io.open(dirml.."/MedicalHelper/госновости/Вызов скорой помощи SF.txt", "w")
				f:write(govsf)
				f:flush()
				f:close()
				local f = io.open(dirml.."/MedicalHelper/госновости/Вызов скорой помощи LV.txt", "w")
				f:write(govlv)
				f:flush()
				f:close()
				local f = io.open(dirml.."/MedicalHelper/госновости/Вызов скорой помощи Jafferson.txt", "w")
				f:write(govjf)
				f:flush()
				f:close()
			end
			dep.news = {}
			local search, name = findFirstFile("moonloader/MedicalHelper/госновости/*.txt")
			while search do
				if not name then 
					findClose(search) 
				else
					table.insert(dep.news, u8(tostring(name:gsub(".txt", ""))))
					name = findNextFile(search)
					if name == nil then
						findClose(search)
						break
					end
				end
			end
		end
		deadgov = false
	end)
	brp = 0
	lua_thread.create(function()
		if doesFileExist(dirml.."/MedicalHelper/госновости/"..u8:decode(dep.news[1])..".txt") then
			for line in io.lines(dirml.."/MedicalHelper/госновости/"..u8:decode(dep.news[1])..".txt") do
				if brp < 6 then
					trtxt[brp + 1].v = u8(line)
					brp = brp + 1
				end
			end
		end
		deadgov = false
	end)
end

function filter(mode, filderChar)
	local function locfil(data)
		if mode == 0 then 
			if string.char(data.EventChar):find(filderChar) then 
				return true
			end
		elseif mode == 1 then
			if not string.char(data.EventChar):find(filderChar) then 
				return true
			end
		end
	end 
	
	local cbFilter = imgui.ImCallback(locfil)
	return cbFilter
end

function tags(par)
		par = par:gsub("{myID}", tostring(myid))
		par = par:gsub("{myNick}", tostring(getPlayerNickName(myid):gsub("_", " ")))
		par = par:gsub("{myRusNick}", tostring(u8:decode(buf_nick.v)))
		par = par:gsub("{myHP}", tostring(getCharHealth(PLAYER_PED)))
		par = par:gsub("{myArmo}", tostring(getCharArmour(PLAYER_PED)))
		par = par:gsub("{myHosp}", tostring(u8:decode(chgName.org[num_org.v+1])))
		par = par:gsub("{myHospEn}", tostring(u8:decode(list_org_en[num_org.v+1])))
		par = par:gsub("{myTag}", tostring(u8:decode(buf_teg.v))) 
		par = par:gsub("{myRank}", tostring(u8:decode(chgName.rank[num_rank.v+1])))
		par = par:gsub("{time}", tostring(os.date("%X")))
		par = par:gsub("{day}", tostring(tonumber(os.date("%d"))))
		par = par:gsub("{week}", tostring(week[tonumber(os.date("%w"))]))
		par = par:gsub("{month}", tostring(month[tonumber(os.date("%m"))]))
		par = par:gsub("{med7}", tostring(buf_mede[1].v))
		par = par:gsub("{med14}", tostring(buf_mede[2].v))
		par = par:gsub("{med30}", tostring(buf_mede[3].v))
		par = par:gsub("{med60}", tostring(buf_mede[4].v))
		par = par:gsub("{medup7}", tostring(buf_upmede[1].v))
		par = par:gsub("{medup14}", tostring(buf_upmede[2].v))
		par = par:gsub("{medup30}", tostring(buf_upmede[3].v))
		par = par:gsub("{medup60}", tostring(buf_upmede[4].v))
		par = par:gsub("{pricenarko}", tostring(buf_narko.v))
		par = par:gsub("{pricerecept}", tostring(buf_rec.v))
		par = par:gsub("{pricetatu}", tostring(buf_tatu.v))
		par = par:gsub("{priceant}", tostring(buf_ant.v))
		par = par:gsub("{pricelec}", tostring(buf_lec.v))
		if par:find('{namePlayerRus%[(%d+)%]}') then
			local namepl_nick_id = par:match('{namePlayerRus%[(%d+)%]}')
			local nicknamepl = sampGetPlayerNickname(tonumber(namepl_nick_id))
			par = par:gsub("{namePlayerRus%[(%d+)%]}", tostring(trst(nicknamepl)))
		end
		
		if targID ~= nil then par = par:gsub("{target}", targID) end
		if par:find("{getNickByID:%d+}") then
			for v in par:gmatch("{getNickByID:%d+}") do
				local id = tonumber(v:match("{getNickByID:(%d+)}"))
				if sampIsPlayerConnected(id) then
					par = par:gsub(v, tostring(getPlayerNickName(id))):gsub("_", " ")
				else
					sampAddChatMessage("{FFFFFF}[{FF8FA2}MH:Ошибка{FFFFFF}]: Игрок {getNickByID:ID} не найден или не в сети. Проверьте ID и повторите.", 0xFF8FA2)
					par = par:gsub(v,"")
				end
			end
		end
		if par:find("{sex:[%w%sа-яА-ЯёЁ]*|[%w%sа-яА-ЯёЁ]*}") then	
			for v in par:gmatch("{sex:[%w%sа-яА-ЯёЁ]*|[%w%sа-яА-ЯёЁ]*}") do
				local m, w = v:match("{sex:([%w%sа-яА-ЯёЁ]*)|([%w%sа-яА-ЯёЁ]*)}")
				if num_sex.v == 0 then
					par = par:gsub(v, m)
				else
					par = par:gsub(v, w)
				end
			end
		end
		
		if par:find("{getNickByTarget}") then
			if targID ~= nil and targID >= 0 and targID <= 1000 and sampIsPlayerConnected(targID) then
				par = par:gsub("{getNickByTarget}", tostring(getPlayerNickName(targID):gsub("_", " ")))
			else
				sampAddChatMessage("{FFFFFF}[{FF8FA2}MH:Ошибка{FFFFFF}]: Игрок {getNickByTarget} не найден или не в сети. Проверьте ID и повторите.", 0xFF8FA2)
				par = par:gsub("{getNickByTarget}", tostring(""))
			end
		end
	return par
end

funCMD = {}
function funCMD_All(argum, numact)
	if numact == nil then
		numact = 5
	end
	if thread:status() ~= "dead" and not lectime and not statusvac then 
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} В данный момент выполняется действие.", 0xFF8FA2)
		return
	end
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		buf_nick.v = u8(trst(myNick))
	end
	local function find_last_index(array, element)
		local index = 0
		for i = 1, #array do
			if array[i][1] == element then
				index = i
			end
		end
		return index
	end
	local breakArg = false
	local dialog_run = false
	local dialogs = {0, false}
	local donedialog = 0
	local values = {
		arg = {},
		var = {}
	}
	if acting[numact].argfunc then
		for p = 1, #acting[numact].arg do
			if acting[numact].arg[p][1] ~= nil then
				if acting[numact].arg[p][1] == 0 then
					if argum:find("^(%d+).*") then
						values.arg[p] = tostring(argum:gsub("^(%d+).*", "%1"))
						argum = argum:gsub("^%S+%s*", "")
					else
						breakArg = true
					end
				elseif acting[numact].arg[p][1] == 1 then
					if argum:find("^%s*(%S+).*") then
						values.arg[p] = tostring(argum:gsub("^%s*(%S+).*", "%1"))
						argum = argum:gsub("^%S+%s*", "")
					else
						breakArg = true
					end
				end
			end
		end
	end
	if not breakArg and acting[numact].varfunc then
		for ui = 1, #acting[numact].var do
			values.var[ui] = acting[numact].var[ui]
		end
	end
	if not breakArg then
		thread = lua_thread.create(function()
			for i = 1, #acting[numact].typeAct do
				if acting[numact].typeAct[i][1] == 2 then
					dialogs[1] = #acting[numact].typeAct[i][2]
					dialogs[2] = true
					local sizetexts = 110
					local textlin = ""
					for j = 1, dialogs[1] do
						textlin = textlin.."{FFFFFF}[Num{67E56F}"..j.."{FFFFFF}] - "..acting[numact].typeAct[i][2][j].."\n"
						local part = renderGetFontDrawTextLength(font, u8:decode(acting[numact].typeAct[i][2][j]))
						if part > sizetexts then
							sizetexts = part
						end
					end
					sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Для продолжения выберите нужный вариант в диалоговом окне.", 0xFF8FA2)
					addOneOffSound(0, 0, 0, 1058)
					while true do wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "{8ABCFA}Выберите вариант:\n".. u8:decode(textlin), sx - 100 - sizetexts, sy - 33 - (dialogs[1] * 23), 0xFFFFFFFF)
						end
						if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 1 then donedialog = 1; break end
						if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 2 then donedialog = 2; break end
						if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 3 then donedialog = 3; break end
						if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 4 then donedialog = 4; break end
						if isKeyJustPressed(VK_5) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 5 then donedialog = 5; break end
						if isKeyJustPressed(VK_6) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 6 then donedialog = 6; break end
						if isKeyJustPressed(VK_7) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 7 then donedialog = 7; break end
						if isKeyJustPressed(VK_8) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 8 then donedialog = 8; break end
					end
				end
				if acting[numact].typeAct[i][1] == 0 then
					local text_message
					if acting[numact].argfunc and values.arg[1] ~= nil then
						text_message = u8:decode(acting[numact].typeAct[i][2])
						for u = 1, #values.arg do
							text_message = text_message:gsub('{arg'..u..'}', values.arg[u])
						end
						text_message = tags(text_message)
					else
						text_message = acting[numact].typeAct[i][2]
						text_message = tags(u8:decode(text_message))
					end
					if acting[numact].varfunc and values.var[1] ~= nil then
						for u = 1, #values.var do
							text_message = text_message:gsub("{var"..u.."}", values.var[u])
						end
					end
					if text_message:find("{dialog(%d)}") then
						local iddialogs = text_message:gsub("{dialog(%d+)}.*", "%1")
						iddialogs = tonumber(iddialogs)
						if iddialogs > dialogs[1] or iddialogs <= 0 or donedialog == 0 then
							dialogs = {0, false}
							dialog_run = false
							donedialog = 0
						elseif iddialogs == donedialog then
							dialog_run = true
						elseif iddialogs ~= donedialog then
							dialog_run = false
						end
					else
						dialogs = {0, false}
						dialog_run = false
						donedialog = 0
					end
					if dialog_run and dialogs[2] then
						text_message = text_message:gsub("{dialog(%d+)}", "")
						if text_message ~= "" then
							if find_last_index(acting[numact].typeAct, 0) ~= i or not acting[numact].chatopen then
								sampSendChat(text_message)
							elseif find_last_index(acting[numact].typeAct, 0) == i and acting[numact].chatopen then
								sampSetChatInputEnabled(true)
								sampSetChatInputText(text_message)
							end
							if i ~= #acting[numact].typeAct then
								wait(acting[numact].sec * 1000)
							end
						end
					elseif not dialogs[2] then
						if text_message ~= "" then
							if find_last_index(acting[numact].typeAct, 0) ~= i or not acting[numact].chatopen then
								sampSendChat(text_message)
							elseif find_last_index(acting[numact].typeAct, 0) == i and acting[numact].chatopen then
								sampSetChatInputEnabled(true)
								sampSetChatInputText(text_message)
							end
							if i ~= #acting[numact].typeAct then
								wait(acting[numact].sec * 1000)
							end
						end
					end
				end
				if acting[numact].typeAct[i][1] == 1 then
					if (dialog_run and dialogs[2]) or not dialogs[2] then 
						sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите {23E64A}Enter{FFFFFF} для продолжения, или {FF8FA2}Page Down{FFFFFF}, чтобы выбрать другой вариант.", 0xFF8FA2)
						addOneOffSound(0, 0, 0, 1058)
						local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
						while true do wait(0)
							if not isGamePaused() then
								renderFontDrawText(font, "{8ABCFA}Выберите действие:\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-40, sy-50, 0xFFFFFFFF)
							end
							if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
						end
					end
				end
				if acting[numact].typeAct[i][1] == 3 then 
					if (dialog_run and dialogs[2]) or not dialogs[2] then
						local text_chat
						if acting[numact].argfunc and values.arg[1] ~= nil then
							for u = 1, #values.arg do
								text_chat = acting[numact].typeAct[i][2]:gsub("{arg"..u.."}", values.arg[u])
								text_chat = tags(u8:decode(text_chat))
							end
						else
							text_chat = acting[numact].typeAct[i][2]
							text_chat = tags(u8:decode(text_chat))
						end
						if acting[numact].varfunc and values.var[1] ~= nil then
							for u = 1, #values.var do
								text_chat = tags(text_chat:gsub("{var"..u.."}", values.var[u]))
							end
						end
						sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} "..text_chat, 0xFF8FA2)
					end
				end
				if acting[numact].typeAct[i][1] == 4 then
					if (dialog_run and dialogs[2]) or not dialogs[2] then
						local var_on_tag = acting[numact].typeAct[i][3]
						var_on_tag = tags(u8:decode(var_on_tag))
						local numvar = acting[numact].typeAct[i][2] + 1
						if var_on_tag:find('{var(%d)}') then
							idvariab = var_on_tag:gsub("{var(%d+)}.*", "%1")
							idvariab = tonumber(idvariab)
							var_on_tag = var_on_tag:gsub("{var"..idvariab.."}", values.var[idvariab])
						end
						values.var[numvar] = var_on_tag
					end
				end
			end
		end)
	else
		local text_sampmes = ""
		if acting[numact].argfunc and acting[numact].arg[1][1] ~= nil then
			for f = 1, #acting[numact].arg do
				text_sampmes = text_sampmes.."["..acting[numact].arg[f][2].."] "
			end
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Использование: {a8a8a8}/"..cmdBind[numact].cmd.." ".. u8:decode(text_sampmes), 0xFF8FA2)
		end
	end
end

function funCMD.del()
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Вы начали удаление скрипта.", 0xFF8FA2)
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Пожалуйста, подождите...", 0xFF8FA2)
	os.remove(scr.path)
	scr:reload()
end
function funCMD.lec(argum)
	funCMD_All(argum, 5)
end
function funCMD.med(argum)
	funCMD_All(argum, 7)
end
function funCMD.narko(argum)
	funCMD_All(argum, 8)
end
function funCMD.recep(argum)
	funCMD_All(argum, 9)
end
function funCMD.osm(argum)
	funCMD_All(argum, 10)
end
function funCMD.tatu(argum)
	funCMD_All(argum, 13)
end
function funCMD.warn(argum)
	funCMD_All(argum, 14)
end
function funCMD.uwarn(argum)
	funCMD_All(argum, 15)
end
function funCMD.mute(argum)
	funCMD_All(argum, 16)
end
function funCMD.umute(argum)
	funCMD_All(argum, 17)
end
function funCMD.rank(argum)
	funCMD_All(argum, 18)
end
function funCMD.inv(argum)
	funCMD_All(argum, 19)
end
function funCMD.unv(argum)
	funCMD_All(argum, 20)
end
function funCMD.expel(argum)
	funCMD_All(argum, 22)
end
function funCMD.vac(argum)
	funCMD_All(argum, 23)
end
function funCMD.za(argum)
	funCMD_All(argum, 25)
end
function funCMD.zd(argum)
	funCMD_All(argum, 26)
end
function funCMD.ant(argum)
	funCMD_All(argum, 27)
end
function funCMD.strah(argum)
	funCMD_All(argum, 28)
end
function funCMD.cur(argum)
	funCMD_All(argum, 29)
end
function funCMD.show(argum)
	funCMD_All(argum, 34)
end
function funCMD.cam(argum)
	funCMD_All(argum, 35)
end

function funCMD.post(stat)
	if not u8:decode(buf_nick.v):find("[а-яА-ЯёЁ]+%s[а-яА-ЯёЁ]+") then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Неверное имя, введите имя и фамилию. {90E04E}/mh > Имя > Имя и фамилия", 0xFF8FA2)
		return
	end
	if not isCharInModel(PLAYER_PED, 416) then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Вы не в модели врача, пожалуйста, смените модель.", 0xFF8FA2)
		addOneOffSound(0, 0, 0, 1058)
	else
		local bool, post, coord = postGet()
		if not bool then
			sampShowDialog(2001, ">{FFB300}Посты", "                             {55BBFF}Ближайший пост\n"..table.concat(post, "\n"), "{69FF5C}Выбрать", "{FF5C5C}Закрыть", 5)
			sampSetDialogClientside(false)
		elseif bool then
			if stat:find(".+") then
				sampSendChat(string.format("/r Дежурство: %s. Прибыл на пост %s, координаты: %s", u8:decode(buf_nick.v):gsub("%X+%s", ""), post, stat))
			else
				sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Введите сообщение, например, /"..cmdBind[6].cmd.." текст.", 0xFF8FA2)
			end
		end
	end
end
function funCMD.hall()
	local maxIdInStream = sampGetMaxPlayerId(true)
	for i = 0, maxIdInStream do
	local result, handle = sampGetCharHandleBySampPlayerId(i)
		if result and doesCharExist(handle) then
			local px, py, pz = getCharCoordinates(playerPed)
			local pxp, pyp, pzp = getCharCoordinates(handle)
			local distance = getDistanceBetweenCoords2d(px, py, pxp, pyp)
			if distance <= 4 then
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/hl "..i)
			end
		end
	end
end
function funCMD.hilka()
local id = getNearestID()
	if id then
		name = getPlayerNickName(id)
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Название персонажа: {5BF165}"..name.." ["..id.."]", 0xFF8FA2)
		funCMD.lec(tostring(id))
	else
    sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Название персонажа не найдено!", 0xFF8FA2)
	end
end
function funCMD.sob()
	if not sobWin.v then
		styleAnimationOpen(3)
		sobWin.v = true
	else
		animka_sob.paramOff = true
	end
end
function funCMD.dep()
	if num_rank.v+1 < 5 then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Недостаточно прав для выполнения. Повысьте свой ранг в организации или обратитесь к руководству.", 0xFF8FA2)
		return
	end
	if not depWin.v then
		styleAnimationOpen(2)
		depWin.v = true
	else
		animka_dep.paramOff = true
	end
end
function funCMD.hme()
	thread = lua_thread.create(function()
		sampSendChat("/me достал"..chsex("","а").." из своей аптечки, чтобы вылечить себя от ран"..chsex("","").."")
		wait(1000)
		sampSendChat("/heal "..myid.." 5000")
		healme = true
	end)
end
function funCMD.memb()
	sampSendChat("/members")
end
function funCMD.time()
	lua_thread.create(function()
		sampSendChat("/time")
		wait(1500)
		setVirtualKeyDown(VK_F8, true)
		wait(20)
		setVirtualKeyDown(VK_F8, false)
	end)
end
function funCMD.info()
    sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Список команд:", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[5].cmd.." [id пациента]{FFFFFF} - Лечение пациента", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[7].cmd.." [id пациента]{FFFFFF} - Выдача мед. карты", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[9].cmd.." [id пациента]{FFFFFF} - Выдача рецепта", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[8].cmd.." [id пациента]{FFFFFF} - Лечение от наркозависимости", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[13].cmd.." [id пациента]{FFFFFF} - Удаление татуировки", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[23].cmd.." [id пациента]{FFFFFF} - Вакцинация пациента", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[27].cmd.." [id пациента]{FFFFFF} - Выдача антибиотиков", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[28].cmd.." [id пациента]{FFFFFF} - Оформление мед. страховки", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[29].cmd.." [id пациента]{FFFFFF} - Лечение болезни", 0xFF8FA2)
    sampAddChatMessage("{1fc5f2}/"..cmdBind[26].cmd.."{FFFFFF} - Приветствие пациента", 0xFF8FA2)
end
function funCMD.shpora(number)
    if number:find("(%d+)") then
        getSpurFile()
        spur.select_spur = 0 + number
        if spur.select_spur <= #spur.list and spur.select_spur > 0 then
            local f = io.open(dirml.."/MedicalHelper/шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
            spur.text.v = u8(f:read("*a"))
            f:close()
            spur.name.v = u8(spur.list[spur.select_spur])
            if not spurBig.v then
                styleAnimationOpen(5)
                spurBig.v = true
                examination = true
                textEndShpora = {}
            else
                animka_big.paramOff = true
            end
        elseif spur.select_spur <= 0 then
            sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Неверный номер шпоры. Укажите число от 1 до "..#spur.list..".", 0xFF8FA2)
        else
            sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Шпора с таким номером не найдена.", 0xFF8FA2)
        end
    else
        sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Использование: {a8a8a8}/"..cmdBind[32].cmd.." [номер шпоры в списке].", 0xFF8FA2)
    end
end

local update_downloaded = false

function funCMD.updateCheck()
    sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Поиск обновлений...", 0xFF8FA2)
    local version_url = GITHUB_RAW_URL .. VERSION_FILE
    local dir = dirml .. "/MedicalHelper/files/version.tmp"
    downloadUrlToFile(version_url, dir, function(id, status, p1, p2)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            local f = io.open(dir, "r")
            if f then
                local remote_version = f:read("*all"):gsub("%s+", "")
                f:close()
                os.remove(dir)
                if remote_version ~= current_version then
                    update_available = true
                    newversion = remote_version
                    sampAddChatMessage("{FF8FA2}[MH]{4EEB40} Доступна новая версия: " .. remote_version .. ". Напиши {22E9E3}/updatemh для информации.", 0xFF8FA2)
                    local changelog_url = GITHUB_RAW_URL .. CHANGELOG_FILE
                    downloadUrlToFile(changelog_url, dirml .. "/MedicalHelper/files/changelog.tmp", function(id2, status2)
                        if status2 == dlstatus.STATUS_ENDDOWNLOADDATA then
                            local f2 = io.open(dirml .. "/MedicalHelper/files/changelog.tmp", "r")
                            if f2 then
                                updinfo = f2:read("*all")
                                f2:close()
                                os.remove(dirml .. "/MedicalHelper/files/changelog.tmp")
                            end
                        end
                    end)
                else
                    sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} У вас последняя версия (" .. current_version .. ").", 0xFF8FA2)
                end
            else
                sampAddChatMessage("{FF8FA2}[MH]{FF0000} Не удалось проверить обновления (файл version.txt).", 0xFF8FA2)
            end
        elseif status == dlstatus.STATUSEX_ENDDOWNLOAD then
            sampAddChatMessage("{FF8FA2}[MH]{FF0000} Ошибка соединения с GitHub.", 0xFF8FA2)
        end
    end)
end

function funCMD.doUpdate()
    if not update_available then
        sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нет доступных обновлений.", 0xFF8FA2)
        return
    end
    sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Начинаю загрузку новой версии...", 0xFF8FA2)
    local dir = dirml .. "/MedicalHelper.lua"
    downloadUrlToFile(DOWNLOAD_URL, dir, function(id, status, p1, p2)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            update_downloaded = true
            sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Загрузка завершена! Перезагрузка скрипта...", 0xFF8FA2)
            lua_thread.create(function()
                wait(500)
                reloadScripts()
                showCursor(false)
            end)
        elseif status == dlstatus.STATUSEX_ENDDOWNLOAD then
            sampAddChatMessage("{FF8FA2}[MH]{FF0000} Ошибка загрузки. Проверьте ссылку.", 0xFF8FA2)
        end
    end)
end

function asyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = effil.thread(function (method, url, args)
      local requests = require 'requests'
      local result, response = pcall(requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)

   if not resolve then resolve = function() end end
   if not reject then reject = function() end end

   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end

function hook.onServerMessage(mesColor, mes)
	if mes:find("Зарплата: $(%d+)") then
		local mesPay = mes:match("Зарплата: $(.+)")
		mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + (mesPay + 0)
		profit_money.payday[1] = profit_money.payday[1] + (mesPay + 0)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end

	if mes:find("%[Медицина%] {FFFFFF}Вылечил (.+) на ") then
		local mesPay = mes:match("%[Медицина%] {FFFFFF}Вылечил (.+) на (%d+)")
		if mesPay then
			mesPay = mesPay:gsub("%D","")
			profit_money.total_all = profit_money.total_all + round(tonumber(mesPay) * 0.6, 1)
			profit_money.lec[1] = profit_money.lec[1] + round(tonumber(mesPay) * 0.6, 1)
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end

	if mes:find("%[Медицина%] {FFFFFF}Выдал карту (.+) на") then
		local mesPay = mes:match(" на (%d+)")
		if mesPay then
			local days = tonumber(mesPay)
			local price = 0
			if days == 7 then price = setting.mede[1]
			elseif days == 14 then price = setting.mede[2]
			elseif days == 30 then price = setting.mede[3]
			elseif days == 60 then price = setting.mede[4]
			end
			if price then
				profit_money.total_all = profit_money.total_all + round(price / 2, 1)
				profit_money.medcard[1] = profit_money.medcard[1] + round(price / 2, 1)
				local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
				f:write(encodeJson(profit_money))
				f:flush()
				f:close()
			end
		end
	end

	if mes:find("%[Медицина%] {FFFFFF}Вылечил игрока (.+) от наркозависимости на ") then
		local mesPay = mes:match(" на (%d+)")
		if mesPay then
			mesPay = mesPay:gsub("%D","")
			profit_money.total_all = profit_money.total_all + (tonumber(mesPay) * 0.8)
			profit_money.narko[1] = profit_money.narko[1] + (tonumber(mesPay) * 0.8)
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end

	if mes:find("%[Медицина%] {ffffff}Вы сделали укол игроку в рамках вакцинации") then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Осталось время до вакцинации 2 минуты.{00E600} Delete {FFFFFF}- отмена.", 0xFF8FA2)
		vactimer = {59, 1}
		vaccine_two = true
	end

	if mes:find("%[Медицина%] {ffffff}Вы сделали укол игроку {ffff00}(.+)%[ID: (%d+)%] {ffffff}в рамках процедуры вакцинации.") then
		vaccine_id = mes:match("ID: (%d+)%]")
	end

	if mes:find("%[Медицина%] {FFFFFF}Выдал антибиотики (.+) на сумму (.+)") then
		local mesPay = mes:match("на сумму: $(.+)")
		if mesPay then
			mesPay = mesPay:gsub("%D","")
			profit_money.total_all = profit_money.total_all + (tonumber(mesPay) + 0)
			profit_money.ant[1] = profit_money.ant[1] + (tonumber(mesPay) + 0)
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end

	if mes:find("%[Медицина%] {FFFFFF}Выдал (%d+) рецептов (.+) на ") then
		local mesPay = mes:match("$(.+)")
		if mesPay then
			mesPay = mesPay:gsub("%D","")
			profit_money.total_all = profit_money.total_all + round(tonumber(mesPay) / 2, 1)
			profit_money.rec[1] = profit_money.rec[1] + round(tonumber(mesPay) / 2, 1)
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end

	if mes:find ("Провёл 100 осмотров") then
		if mes:find(">>>{FFFFFF} "..getPlayerNickName(myid).."%[(%d+)%] Провёл 100 осмотров за месяц!") then
			profit_money.total_all = profit_money.total_all + 100000
			profit_money.medcam[1] = profit_money.medcam[1] + 100000
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end

	if mes:find("Вылечил от болезни (.+)") then
		profit_money.total_all = profit_money.total_all + 300000
		profit_money.cure[1] = profit_money.cure[1] + 300000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end

	if mes:find("%[Медицина%] Оформил страховку игроку (.+)") then
		profit_money.total_all = profit_money.total_all + 200000
		profit_money.strah[1] = profit_money.strah[1] + 200000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end

	-- Автолечение по голосу
	if ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lek") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lechi") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lekni")
	or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)bolit") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)golova") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)fast")
	or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)vylechi") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)tabl") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)khil") then
		if not ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lekts") then
			if accept_autolec.v and not sampIsChatInputActive() and not sampIsDialogActive() and thread:status() == "dead" and not deadgov then 
				local mesPlayer = mes:match("(.+)говорит:")
				if mesPlayer then
					idMesPlayer = mesPlayer:match("%[(%d+)%]")
					_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					if (idMesPlayer+1) ~= (myid+1) then
						local keysi = {49}
						rkeys.registerHotKey(keysi, true, onHotKeyCMD)
						lua_thread.create(function()
							wait(15)
							EXPORTS.sendRequest()
							wait(150)
							if myforma then
								addOneOffSound(0, 0, 0, 1058)
								sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите {00E600}1{FFFFFF} чтобы начать лечение игрока {00E600}"..mesPlayer.."{FFFFFF}. У вас есть 5 секунд.", 0xFF8FA2)
								lectime = true
								wait(5000)
								lectime = false
							end
						end)
					end
				end
			end
		end
	end

	if mes:find("%[D%](.+)"..u8:decode(setdepteg.prefix[num_org.v + 14]).."(.+)звук") and prikol.v then
		local stap = 0
		lua_thread.create(function()
			wait(300)
			sampAddChatMessage("{FF8FA2}[MH]{e3a220} Звук активирован в департаментском чате!", 0xFF8FA2)
			sampAddChatMessage("{FF8FA2}[MH]{e3a220} Звук активирован в департаментском чате!", 0xFF8FA2)
			repeat wait(200) 
				addOneOffSound(0, 0, 0, 1057)
				stap = stap + 1
			until stap > 15
		end)
	end

	if mes:find("зарплата ((%w+)_(%w+)):(.+)звук") or mes:find("зарплата (%w+)_(%w+):(.+)звук") or mes:find("soundactivemh") then
		if accept_spawn.v and not errorspawn then
			local stap = 0
			lua_thread.create(function()
				errorspawn = true
				repeat wait(200) 
					addOneOffSound(0, 0, 0, 1057)
					stap = stap + 1
				until stap > 15
				wait(62000)
				errorspawn = false
			end)
		end
	end

	if mes:find("AIberto_Kane(.+):(.+)vizov1488mh") or mes:find("Alberto_Kane(.+):(.+)vizov1488mh") then
		if mes:find("AIberto_Kane(.+){B7AFAF}") or mes:find("Alberto_Kane(.+){B7AFAF}") then
			local staps = 0
			sampShowDialog(2001, "Поздравляем", "Вы используете изменённую версию, которая была модифицирована\n                 Разработчик скрипта Medical Helper - {2b8200}Alberto_Kane", "Закрыть", "", 0)
			sampAddChatMessage("{FF8FA2}[MH]{3ad41c} Вы используете модифицированную версию, основанную на оригинальном Medical Helper - {39e3be}Alberto_Kane.", 0xFF8FA2)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					staps = staps + 1
				until staps > 10
			end)
			return false
		end
	end

	-- Фильтр спама в чате
	if cb_chat2.v then
		if mes:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") or 
		   mes:find("- Основные команды: /menu /help /gps /settings") or 
		   mes:find("Доступ к игре через лаунчер и сайт") or 
		   mes:find("- Сайт и донат: arizona-rp.com/donate") or 
		   mes:find("Информация на официальном сайте") or 
		   mes:find("(донат/привилегии)") or 
		   mes:find("В игре доступны функции") or 
		   mes:find("Вы можете узнать на форуме") or 
		   mes:find("Вы не можете использовать {FFFFFF}команды") or 
		   mes:find("Донат на сервере {FFFFFF}VIP{6495ED} даёт бонусы") or 
		   mes:find("Список доступных {FFFFFF}команд, функций, настроек") or 
		   mes:find("Внимание, сервер запущен! Как играть:") or 
		   mes:find("Не нужно нарушать правила") or 
		   mes:find("Можно играть на сервере, если у вас есть аккаунт.") or 
		   mes:find("Если у вас возникли проблемы, обратитесь к администратору или на форум.") or 
		   mes:find("{ffffff}Используйте команду /help, чтобы узнать список команд:") or 
		   mes:find("{ffffff}Команда: {FF6666}/help для получения справки в игре Vice City.") or 
		   mes:find("{ffffff}Внимание! На сервере Vice City доступна система PayDay.") or 
		   mes:find("%[Сервер%] Игрок присоединился (.+) и хочет играть, но у него нет прав") or 
		   mes:find("%[Сервер%] Игрок присоединился (.+) но у него нет доступа к серверу") then 
			return false
		end
	end

	if cb_chat3.v then
		if mes:find("News LS") or mes:find("News SF") or mes:find("News LV") then 
			return false
		end
	end

	if cb_chat1.v then
		if mes:find("Реклама:") or mes:find("Информационное сообщение") then
			return false
		end
	end

	local function stringN(str, color)
		if str:len() > 72 then
			local str1 = str:sub(1, 70)
			local str2 = str:sub(71, str:len())
			return str1.."\n".."{"..color.."}"..str2
		else 
			return str
		end
	end

	if mes:find("%[D%]") then
		if mes:find("%[D%] [%X%a]+ [%a_]+%[%d+%]:") and not mes:find("%[D%] [%X%a]+ ".. getPlayerNickName(myid).."%[%d+%]:") then
			local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:")
			if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
				local mesD = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:%p*(.+)")
				if mesD then
					table.insert(dep.dlog, "{7ECAFF}"..org.."{FFFFFF}"..mesD)
				end
			end
		end
		if mes:find("%[D%] [%X%a]+ ".. getPlayerNickName(myid).."%[%d+%]:") then
			local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:")
			if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
				local mesD = mes:match("%[D%] [%X%a]+ ".. getPlayerNickName(myid).."%[%d+%]:%p*(.+)")
				if mesD then
					table.insert(dep.dlog, "{39e81e}"..org.."{FFFFFF}"..mesD)
				end
			end
		end
	end
end

local lower, sub, char, upper = string.lower, string.sub, string.char, string.upper
local concat = table.concat

local lu_rus, ul_rus = {}, {}
for i = 192, 223 do
    local A, a = char(i), char(i + 32)
    ul_rus[A] = a
    lu_rus[a] = A
end
local E, e = char(168), char(184)
ul_rus[E] = e
lu_rus[e] = E

function string.nlower(s)
    s = lower(s)
    local len, res = #s, {}
    for i = 1, len do
        local ch = sub(s, i, i)
        res[i] = ul_rus[ch] or ch
    end
    return concat(res)
end

function string.nupper(s)
    s = upper(s)
    local len, res = #s, {}
    for i = 1, len do
        local ch = sub(s, i, i)
        res[i] = lu_rus[ch] or ch
    end
    return concat(res)
end

function time()
	local function get_weekday(year, month, day)
	   return tonumber(os.date("%w", os.time{year=year, month=month, day=day}))
	end
	local current_date = {}
	local currect_week
	local currect_sec
	while true do
		wait(1000)
		if sampGetGamestate() == 3 then 
			if not isGamePaused() then
				session_clean.v = session_clean.v + 1
				session_all.v = session_all.v + 1
			
				online_stat.clean[1] = online_stat.clean[1] + 1
				online_stat.all[1] = online_stat.all[1] + 1
				online_stat.total_all = online_stat.total_all + 1
			else
				session_all.v = session_all.v + 1
				session_afk.v = session_afk.v + 1
				
				online_stat.all[1] = online_stat.all[1] + 1
				online_stat.afk[1] = online_stat.afk[1] + 1
			end
		end
		if get_status_potok_song() == 1 and track_time_hc ~= 0 then
			local time_song = 0
			time_song = time_song_position(track_time_hc)
			time_song = round(time_song, 1)
			timetr[1] = time_song % 60
			timetr[2] = math.floor(time_song / 60)
		end
		if vaccine_two then
			if vactimer[2] >= 0 then
				if vactimer[1] < 60 and vactimer[1] > 0 then
					vactimer[1] = vactimer[1] - 1
				else
					vactimer[1] = 59
					vactimer[2] = vactimer[2] - 1
				end
			end
			if vactimer[1] == 0 and vactimer[2] == 0 then
				sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите {23E64A}1{FFFFFF} для продолжения вакцинации или {FF8FA2}Delete{FFFFFF} для отмены.", 0xFF8FA2)
			end
		end
		currect_sec = tonumber(os.date("%S"))
		if #reminder ~= 0 and currect_sec == 0 then
			current_date = {
				year = tonumber(os.date("%Y")),
				month = tonumber(os.date("%m")),
				day = tonumber(os.date("%d")),
				hour = tonumber(os.date("%H")),
				min = tonumber(os.date("%M"))
			}
			currect_week = get_weekday(current_date.year, current_date.month, current_date.day)
			for k = 1, #reminder do
				if reminder[k].timer.year == current_date.year and reminder[k].timer.mon == current_date.month and reminder[k].timer.day == current_date.day
				and reminder[k].timer.hour == current_date.hour and reminder[k].timer.min == current_date.min  then
					if not reminder[k].repeats[1] and not reminder[k].repeats[2] and not reminder[k].repeats[3] and not reminder[k].repeats[4] 
					and not reminder[k].repeats[5] and not reminder[k].repeats[6] and not reminder[k].repeats[7] then
						Window_Reminder(reminder[k])
						table.remove(reminder, k)
						local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
						f:write(encodeJson(reminder))
						f:flush()
						f:close()
						break
					else
						Window_Reminder(reminder[k])
					end
				else
					if reminder[k].repeats[currect_week] and reminder[k].timer.hour == current_date.hour and reminder[k].timer.min == current_date.min then
						Window_Reminder(reminder[k])
					end
				end
			end
		end
	end
end

function saveCounOnl()
	while true do 
		wait(60000)
		local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
		f:write(encodeJson(online_stat))
		f:flush()
		f:close()
	end
end

function isCharDriving(ped)
    if isCharInAnyCar(ped) then
        return getDriverOfCar(storeCarCharIsInNoSave(ped)) == ped
    end
    return false
end

function hook.onShowTextDraw(id, data)
	local x, y = math.floor(data.position.x), math.floor(data.position.y)
	if not isCharDriving(PLAYER_PED) and data.text == 'REPORT' then
		inventoryOpen = false
	else 
		inventoryOpen = true
	end
end

onday = false
function print_time(time)
	local timehighlight = 86400 - os.date('%H', 0) * 3600
	if tonumber(time) >= 86400 then onDay = true else onDay = false end
	return os.date((onDay and math.floor(time / 86400)..' д. ' or '')..('%H ч. %M мин.'), time + timehighlight)
end

function hook.onDisplayGameText(st, time, text)
	if text:find("~y~%d+ ~y~"..os.date("%B").."~n~~w~%d+:%d+~n~ ~g~ Played ~w~%d+ min") then
		if cb_time.v then
			lua_thread.create(function()
			wait(100)
			sampSendChat(u8:decode(buf_time.v))
			if cb_timeDo.v then
				wait(1000)
				sampSendChat("/do Время на часах - "..os.date("%H:%M:%S"))
			end
			end)
		end
	end
end

function hook.onSendCommand(cmd)
	if cmd:find("/r ") then
		if cb_rac.v then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(buf_rac.v))
			end)
		end
	end
	if cmd:find("/time") then
		if cb_time.v then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(buf_time.v))
			end)
		end
	end
end

function hook.onSendSpawn()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = getPlayerNickName(myid)
end

function hook.onSendDialogResponse(id, but, list)
	if sampGetDialogCaption() == ">{FFB300}Посты" then
		if but == 1 then
			local bool, post, coord = postGet()
			placeWaypoint(coord[list+1].x, coord[list+1].y, 20)
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Вы выбрали пост с указанными координатами.", 0xFF8FA2)
			addOneOffSound(0, 0, 0, 1058)
		elseif but == 0 then
		end
	end
end

function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}Caps{ffffff}"
	end
	return "{53E03D}caps{ffffff}"
end

function getStrByState2(keyState)
	if keyState == 0 then
		return ""
	end
	return "{F55353}Caps{ffffff}"
end

function showInputHelp()
	local chat = sampIsChatInputActive()
	if chat == true then
		local cx, cy = getCursorPos()
		local in1 = sampGetInputInfoPtr()
		local in1 = getStructElement(in1, 0x8, 4)
		local in2 = getStructElement(in1, 0x8, 4)
		local in3 = getStructElement(in1, 0xC, 4)
		local posX = in2 + 15
		local posY = in3 + 45
		local _, pID = sampGetPlayerIdByCharHandle(playerPed)
		local Nname = getPlayerNickName(pID)
		local score = sampGetPlayerScore(pID)
		local color = sampGetPlayerColor(pID)
		local ping = sampGetPlayerPing(pID)
		local capsState = ffi.C.GetKeyState(20)
		local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
		local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
		local localName = ffi.string(LocalInfo)
		local text = string.format(
			"%s | {%0.6x}%s [%d] {ffffff}| Ping: {ffeeaa}%d{FFFFFF} | Caps: %s {FFFFFF}| Language: {ffeeaa}%s{ffffff}",
			os.date("%H:%M:%S"), bit.band(color,0xffffff), Nname, pID, ping, getStrByState(capsState), string.match(localName, "([^%(]*)")
		)
		renderFontDrawText(textFont, text, posX, posY, 0xD7FFFFFF)
		if cx >= posX+280 and cx <= posX+280+80 and cy >= posY and cy <= posY+25 then
			if isKeyJustPressed(VK_RBUTTON) then hudPing = not hudPing end
		end
	end
end

function hudTimeF()
	local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
	local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
	local localName = ffi.string(LocalInfo)
	local capsState = ffi.C.GetKeyState(20)
	local function lang()
		local str = string.match(localName, "([^%(]*)")
		if str:find("Русский") then
			return "Ru"
		elseif str:find("English") then
			return "En"
		end
	end
	local text = string.format("%s | {ffeeaa}%s{ffffff} %s", os.date("%d ")..month[tonumber(os.date("%m"))]..os.date(" - %H:%M:%S"), lang(), getStrByState2(capsState))
	if thread:status() ~= "dead" then
		renderFontDrawText(fontPD, text, 20, sy-50, 0xFFFFFFFF)
	else
		renderFontDrawText(fontPD, text, 20, sy-25, 0xFFFFFFFF)
	end
end

function pingGraphic(posX, posY)
	local ping0 = posY + 150
	local time = posX - 200
	local function colorG(value)
		if value <= 70 then
			return 0xFF9EEFA9
		elseif value >= 71 and value <=89 then
			return 0xFFF8DE75
		elseif value >= 90 and value <= 99 then
			return 0xFFF88B75
		elseif value >= 100 then
			return 0xFFEB2700
		end
	end
			renderDrawBoxWithBorder(posX-200, posY, 400, 150, 0x50B5B5B5, 2, 0xF0838383)

			renderDrawLine(time, ping0-50, time+400, ping0-50, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-100, time+400, ping0-100, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-150, time+400, ping0-150, 1, 0x50FFFFFF)
			renderFontDrawText(fontPing, "Ping", posX-20,  posY-16, 0xAFFFFFFF)
			local maxPing = 0
			for i,v in ipairs(pingLog) do
				if maxPing < v then maxPing = v end
			end
	for i,v in ipairs(pingLog) do
		if maxPing <= 150 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)], time+10*i, ping0-v, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]-10, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/2, time+10*i, ping0-v/2, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/2-10, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/5, time+10*i, ping0-v/5, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/5-10, 0xAFFFFFFF)
		end
			
	end
		if maxPing <= 150 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 50, time-20,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 150, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 200, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 300, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 250, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 500, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 750, time-30,  ping0-160, 0xAFFFFFFF)
		end
end

function chsex(textMan, textWoman)
	if num_sex.v == 0 then
		return textMan
	else
		return textWoman
	end
end

function postGet(sel)
	local postname = {"Пост","Пост 2","Пост 3","Пост 4","Пост 5","Пост 6","Пост 7","Пост 8","Пост 9", "Пост 10", "Пост 11", "Пост 12"}
	local coord = {{},{},{},{},{},{},{},{},{}, {}, {}, {}}
	coord[1].x, coord[1].y = 1506.41, -1284.02
	coord[2].x, coord[2].y = 1827.11, -1896.01
	coord[3].x, coord[3].y = -88.35, 112.01
	coord[4].x, coord[4].y = -1998.56, 123.25
	coord[5].x, coord[5].y = -2027.53, -56.07
	coord[6].x, coord[6].y = -2115.08, -746.49
	coord[7].x, coord[7].y = 2612.48, 1163.39
	coord[8].x, coord[8].y = 2078.78, 1001.05
	coord[9].x, coord[9].y =  2825.00, 1294.61
	coord[10].x, coord[10].y = 2727, -2503.5
	coord[11].x, coord[11].y = -1347, 462.5
	coord[12].x, coord[12].y = 223, 1813.5

	if sel ~= nil and isCharInArea2d(PLAYER_PED, coord[sel].x-50, coord[sel].y-50, coord[sel].x+50, coord[sel].y+50,false) then
		local coords = {}   -- правильное имя
		coords.x, coords.y = coord[sel].x, coord[sel].y
		return true, postname, coords
	end

		if isCharInArea2d(PLAYER_PED, 1506.41-50, -1284.02-50, 1506.41+50, -1284.02+50,false) then
			local coord = {}
			coord.x, coord.y = 1506.41, -1284.02
			return true, postname[1], coord
		end
		if isCharInArea2d(PLAYER_PED, 1827.11-50, -1896.01-50, 1827.11+50, -1896.01+50,false) then
			local coord = {}
			coord.x, coord.y = 1827.11, -1896.01
			return true, postname[2], coord
		end
		if isCharInArea2d(PLAYER_PED, -88.35-50, 112.01-50, -88.35+50, 112.01+50,false) then
			local coord = {}
			coord.x, coord.y = -88.35, 112.01
			return true, postname[3], coord
		end
		if isCharInArea2d(PLAYER_PED, -1998.56-50, 123.25-50, -1998.56+50, 123.25+50,false) then
			local coord = {}
			coord.x, coord.y = -1998.56, 123.25
			return true, postname[4], coord
		end
		if isCharInArea2d(PLAYER_PED, -2027.53-50, -56.07-50, -2027.53+50, -56.07+50,false) then
			local coord = {}
			coord.x, coord.y = -2027.53, -56.07
			return true, postname[5], coord
		end
		if isCharInArea2d(PLAYER_PED, -2115.08-50, -746.49-50, -2115.08+50, -746.49+50,false) then
			local coord = {}
			coord.x, coord.y = -2115.08, -746.49
			return true, postname[6], coord
		end
		if isCharInArea2d(PLAYER_PED, 2612.48-50, 1163.39-50, 2612.48+50, 1163.39+50, false) then 
			local coord = {}
			coord.x, coord.y = 2612.48, 1163.39
			return true, postname[7], coord
		end
		if isCharInArea2d(PLAYER_PED, 2078.78-50, 1001.05-50, 2078.78+50, 1001.05+50,false) then
			local coord = {}
			coord.x, coord.y = 2078.78, 1001.05
			return true, postname[8], coord
		end
		if isCharInArea2d(PLAYER_PED, 2825.00-50, 1294.61-50, 2825.00+50, 1294.61+50,false) then
			local coord = {}
			coord.x, coord.y = 2825.00, 1294.61
			return true, postname[9], coord
		end
	return false, postname, coord
end

function membfunc()
	while true do wait(0)
		if sampIsLocalPlayerSpawned() and not sampIsDialogActive() then
			while (os.clock() - lastDialogWasActive) < 2.00 do wait(0) end
			if not await.members and C_membScr.func.v and thread:status() == "dead" and not sampIsDialogActive() then
				await.members = true
				dontShowMeMembers = false
				sampSendChat('/members')
			end
			wait(7500)
		end
	end
end

function getAfkCount()
	local count = 0
	for _, v in ipairs(members) do
		if v.afk and v.afk > 0 then   -- проверка на nil
			count = count + 1
		end
	end
	return count
end

function hook.onShowDialog(id, style, title, but_1, but_2, text)
    if id == 2015 and await.members then
        _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        myNick = getPlayerNickName(myid)
        local count = 0
        await.next_page.bool = false
        if title:find('{FFFFFF}(.+)%(онлайн: (%d+)%)') then
            org.name, org.online = title:match('{FFFFFF}(.+)%(онлайн: (%d+)%)')
        else
            org.name = 'Организация VC'
            org.online = title:match('%(онлайн: (%d+)%)')
        end
        for line in text:gmatch('[^\r\n]+') do
            count = count + 1
            if not line:find('игрок') and not line:find('администратор') then
                local color = string.match(line, "^{(%x+)}")
                local nick, id, rank_id, warns, afk, quests = string.match(line, '([^%d]+)%((%d+)%)\t.-%((%d+)%)\t(%d+) %((%d+).-\t(%d+)')
                local uniform = (color == 'FFFFFF')
                members[#members + 1] = { 
                    nick = tostring(nick),
                    id = id,
                    rank = {
                        count = tonumber(rank_id),
                    },
                    afk = tonumber(afk),
                    uniform = uniform
                }
            end

            if line:match('Следующая страница') then
                await.next_page.bool = true
                await.next_page.i = count - 2
            end
        end

        if await.next_page.bool then
            sampSendDialogResponse(id, 1, await.next_page.i, _)
            await.next_page.bool = false
            await.next_page.i = 0
        else
            while #members > tonumber(org.online) do 
                table.remove(members, 1) 
            end
            sampSendDialogResponse(id, 0, _, _)
            org.afk = getAfkCount()
            await.members = false
        end
        for i, member in ipairs(members) do
            if members[i].nick == myNick and members[i].uniform == true then
                myforma = true
            end
            if members[i].nick == myNick and members[i].uniform == false then
                myforma = false
            end
        end
        return false
    elseif await.members and id ~= 2015 then
        dontShowMeMembers = true
        await.members = false
        await.next_page.bool = false
        await.next_page.i = 0
        while #members > tonumber(org.online) do 
            table.remove(members, 1) 
        end
    elseif dontShowMeMembers and id == 2015 then
        dontShowMeMembers = false
        lua_thread.create(function(); wait(0)
        sampSendDialogResponse(id, 0, nil, nil)
        end)
        return false
    end
    if id == 131 and healme then
        healme = false
        sampSendDialogResponse(131, 1)
        return false
    elseif healme then
        healme = false
    end
end

function EXPORTS.sendRequest()
    if not sampIsDialogActive() then
        await.members = true
        sampSendChat("/members")
        return true
    end
    return false
end

remove = [[
{FFFFFF}Для полного удаления скрипта введите команду:

	Команда: {FBD82B}/delete accept{FFFFFF}
	
После этого скрипт будет удалён с вашего компьютера.
Для восстановления потребуется скачать файл заново.
]]
