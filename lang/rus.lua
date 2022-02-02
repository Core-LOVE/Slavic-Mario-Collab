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
