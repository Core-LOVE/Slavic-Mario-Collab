local littleDialogue = require('littleDialogue')

local lang = 'rus'
local name = 'Русский'

littleDialogue.translation[lang] = {}

local function translate(orig, new)
	littleDialogue.translation[lang][orig] = new
end

translate([[WARNING:
Purple water is poisonous.]], [[ВНИМАНИЕ:
Фиолетовая вода ядовита.]])

translate([[<portrait rules>Ye WORMES THOUGHT THAT I, THE GREAT ROUXLS KAARD COULDE BE CONSTRAINEST TO BUT ONE GAMEN?!]], [[<portrait rules>Вы ЧЕРВЪ ДУМАЛИ ЧТО Я, ВЕЛИКИЪ РУЛУКС КАРДЪ МОГУ БЫТЪ ЛИШЬ В ОДНОЙЪ ИГРЕ?!>]])
translate("<portrait rules 2>Waite is thate mario gamen?<page>I think<page>I think I need to checke oute Kris in Chapter Three.<page>Alls Well That Ends Well!",
"<portrait rules 2>Погодитъ, этоъ Марио игра?<page>Я думаю<page>Я думаю мнеъ надо увидитъся с Крисомъ в 3 Главе.<page>Конецъ - делу венецъ!")

translate("<speakerName ???>So... Here's the deal, Bowser.<page>You'll help me creating <wave 2>Sources</wave> around the Mushroom Kingdom.<page>They are used to extract needed resources, and I can share those resources with you afterwards.<page>A deal?", "<speakerName ???>Такс... Вот тебе предложение, Боузер.<page>Ты поможешь мне создавать <wave 2>Источники</wave> по всему Грибному Королевству.<page>Они нужны для ресурсов, а потом я могу поделиться этими ресурсами с тобой.<page>По рукам?")

translate("<speakerName ???>H-huh?!<page>Mario??!!", "<speakerName ???>Ч-что?!<page>Марио??!!")

translate("<speakerName ???>Bowser?! H-hey! Don't leave me here!", "<speakerName ???>Боузер?! Эй! Не оставляй меня тут!")

translate("<speakerName ???>Ghahaha...<page>A pawn of Mushroom Kingdom I see.<page>Once your Kingdom took everything away from me and my people, now it's time for Mushroom Kingdom to repent.<page>And you shall not stand in my way, Mario.<page>See you soon.", "<speakerName ???>Гхехаха...<page>Пешка Грибного королевства.<page>Однажды ваше королевство забрало всё от меня и моих людей, и за это ваше королевство поплатится.<page>Не смей стоять на пути, Марио.<page>Увидимся.")

translate([[To jump on the spikes, hold <playerKey down>.]], [[Чтобы прыгать на шипах, зажмите <playerKey down>.]])

translate("<portrait boogie>Hey-hey-hey!!<page>Plumber, do you want anything?<page>You probably want to get that delicious <wave 1>Source</wave>, isn't it?<page>Well, you won't get it!!<delay 14>This thingy is very important for us!!<page>You wanna fight? Well, i'll fight too!!", "<portrait boogie>Эй-эй-эй!!<page>Сантехник, вам что-нибудь нужно?<page>Вы, наверное, хотите получить этот вкусный <wave 1>Источник</wave>, не так ли?<page>Чтож, не получишь!!<delay 14> Он очень важен для нас!!<page>Ты хочешь подраться? Ну давай подерёмся!!")

translate("<portrait boogie>Uh-oh!!<page>Welp, nothing can stop you, huh?", "<portrait boogie>Ох!!<page>Ну, ничего тебя не может остановить, да?")

translate("<portrait sherif>HEY YOU! In the name of the law I demand you to stop RIGHT where you are!<page>Do you realize, that by clearing <wave 2>Sources</wave> you're making our lifes worse?<page>HA, like you'd listen anyways!<page>Let me showcase you what happens to ANYBODY who clears 'em.", "<portrait sherif>ЭЙ ТЫ! Именем закона я призываю тебя ОСТАНОВИТЬСЯ прямо сейчас!<page>Ты же понимаешь, что очищая <wave 2>Источники</wave> ты делаешь наши жизни хуже?<page>ХА, как будто тебе не пофиг!<page>Позволь показать мне ТО, что произойдёт с каждым, кто так делает.")

translate('Menu', 'Меню')
translate('Continue', 'Продолжить')
translate('Restart', 'Рестарт')
translate('Exit', 'Выйти')
	
translate('Settings', 'Настройки')
translate('Return', 'Вернуться')
translate('Change Language', 'Сменить Язык')
translate('Disable Screenshake', 'Отключить тряску камеры')
translate('Darkness', 'Темнота')
translate('Weather', 'Эффекты')
translate('Other Optimizations', 'Другие оптимизации')

translate('Choose language!', 'Выберите язык!')

LanguagesName[lang] = name