local littleDialogue = require('littleDialogue')

littleDialogue.translation['rus'] = {}

local function translate(orig, new)
	littleDialogue.translation['rus'][orig] = new
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