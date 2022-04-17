local littleDialogue = _G.littleDialogue

local lang = 'spn'
local name = 'Español'

littleDialogue.translation[lang] = {}

local function translate(orig, new)
	littleDialogue.translation[lang][orig] = new
end

translate([[WARNING:
Purple water is poisonous.]], [[CUIDADO:
La agua morada es venenosa.]])

translate([[<portrait rules>Ye WORMES THOUGHT THAT I, THE GREAT ROUXLS KAARD COULDE BE CONSTRAINEST TO BUT ONE GAMEN?!]], [[<portrait rules>¡VOSOTROS UNOS GUSANOS INSIGNIFICANTES PENSASTEIS QUE PODRIAIS DERROTARME, EL GRAN ROUXLS KAARD PODRIA ESTAR PROHIBIDO, PERO UN JUEGO?!>]])
translate("<portrait rules 2>Waite is thate mario gamen?<page>I think<page>I think I need to checke oute Kris in Chapter Three.<page>¡¡Bien esta lo que bien acaba!!",
"<portrait rules 2>Esperra,es eto un jueego de Mairo?<page>Creo que...<page>Creo que tengo que visitar a Kris en el Capitulo 3.<page>Конецъ - делу венецъ!")

translate("<speakerName ???>So... Here's the deal, Bowser.<page>You'll help me creating <wave 2>Sources</wave> around the Mushroom Kingdom.<page>They are used to extract needed resources, and I can share those resources with you afterwards.<page>A deal?", "<speakerName ???>Así que... Este es el trato, Bowser.<page>Tu me ayudaras a crear las <wave 2>fuentes</wave> alrededor el Reino Champiñon.<page>Son usados para extraer los materiales necesarios,puedo compartir esos recursos contigo después .<page>Trato?")

translate("<speakerName ???>H-huh?!<page>Mario??!!", "<speakerName ???>¡H-huh?!<page>¡¡Mario??!!")

translate("<speakerName ???>Bowser?! H-hey! Don't leave me here!", "<speakerName ???>¡Bowser?! ¡Oye, no me dejes aqui!")

translate("<speakerName ???>Ghahaha...<page>A pawn of Mushroom Kingdom I see.<page>Once your Kingdom took everything away from me and my people, now it's time for Mushroom Kingdom to repent.<page>And you shall not stand in my way, Mario.<page>See you soon.", "<speakerName ???>Gwahahaha...<page>Un peon del Reino Champiñon.<page>Una vez tu reino me quito todo a mi y a mi gente, ahora toca al Reino Champiñon sufrir lo que nosotros sufrimos.<page>Y tu no te tendrias que meter en el medio, Mario.<page>Nos vemos pronto.")

translate([[To jump on the spikes, hold <playerKey down>.]], [[Para saltar sobre los pinchos, manten <playerKey down>.]])

translate("<portrait boogie>Hey-hey-hey!!<page>Plumber, do you want anything?<page>You probably want to get that delicious <wave 1>Source</wave>, isn't it?<page>Well, you won't get it!!<delay 14>This thingy is very important for us!!<page>You wanna fight? Well, i'll fight too!!", "<portrait boogie>Oye-oyee!!<page>Fontanero, quieres algo?<page>Bueno, supongo que quieres conseguir esa preciosa <wave 1>Fuente</wave>, verdad?<page>Pues olvidate de ella!!<delay 14> esa cosa es demasiado importante para nosotros!!<page>Espera, quieres luchar? Pues luchemos!!")

translate("<portrait boogie>Uh-oh!!<page>Welp, nothing can stop you, huh?", "<portrait boogie>¡¡uhh-oh!!<page>Bueno, supongo que nada te puede parar, huh?")

translate("<portrait sherif>HEY YOU! In the name of the law I demand you to stop RIGHT where you are!<page>Do you realize, that by clearing <wave 2>Sources</wave> you're making our lifes worse?<page>HA, like you'd listen anyways!<page>Let me showcase you what happens to ANYBODY who clears 'em.", "<portrait sherif>EH TU! En nombre de la ley te ruego que pares AHI mismo!<page>>Entiendes que al limpiar las <wave 2>Fuentes</wave> estas haciendo nuestra vida peor?<page>HA,tu lo escucharas igualmente!<page>Dejame enseñarte que pasa cuando NADIE lo despeja.")

translate('Menu', 'Menu')
translate('Continue', 'Continuar')
translate('Restart', 'Restart')
translate('Exit', 'Salir')
	
translate('Settings', 'Ajustes')
translate('Return', 'Retroceder')
translate('Change Language', 'Cambiar de Lengua')
translate('Disable Screenshake', 'Desactivar Terremotos')
translate("HUD's Opacity", 'Opacidad del HUD')
translate('HUD Offset', 'Offset del HUD')

translate('Optimizations', 'Optimizaciones')
translate('Darkness', 'Oscuridad')
translate('Weather', 'Clima')
translate('Screen Effects', 'Efectos de Pantalla')
translate('Other...', 'Otros...')

translate('Assist Mode', 'Modo Ayuda')

translate('Choose language!', '¡Elige la lengua!')

translate('World', 'Mundo')
translate('by', 'hecho por')

-- translate('Caucazeus', 'Кавказеус')
-- translate('Asgarden', 'Асгарден')
-- translate('Zahara', 'Захара')
-- translate('Anterpole', 'Антерпол')
-- translate('Blockade', 'Блокада')

translate('Old Yoshi', 'Yoshi antiguo')

LanguagesName[lang] = name