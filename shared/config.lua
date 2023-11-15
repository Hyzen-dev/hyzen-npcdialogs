Lang = {}
Config = {}

Config.Lang = 'en' -- 'fr' or 'en'
Config.Framework = 'qbcore' -- 'qbcore' or 'esx'
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- If you don't have Convar in server.cfg, add it

Config.TargetScript = 'qb-target' -- 'qb-target' or 'ox-target'
Config.ShowDialogActionType = 'notification' -- 'drawtext' or 'draw3dtext' or 'notification'
Config.DialogDisplayType = 'mugshot' -- 'mugshot' or 'text'
Config.DialogAnswerMenu = 'qb-menu' -- 'qb-menu' or 'esx-menu'
Config.ShowDialogPosition = 'right' -- 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left' | 'center' | 'right' | 'left' | 'top' | 'bottom'

Config.Npcs = {{ -- Cop
    name = 'John Doe',
    dialog = 1, -- The dialog id (index of Config.Dialogs)
    dialogDistance = 4.0, -- The distance to display the dialog action
    coords = vector3(441.21, -978.75, 30.69),
    heading = 177.22,
    model = 's_m_y_cop_01', -- https://wiki.rage.mp/index.php?title=Peds
    hasAnimation = true,
    animationDict = 'amb@world_human_clipboard@male@idle_a', -- https://alexguirre.github.io/animations-list/
    animation = 'idle_c',
    hasWeapon = false,
    weapon = '', -- https://wiki.rage.mp/index.php?title=Weapons
    hasObject = true,
    object = 'prop_fib_clipboard' -- https://gtahash.ru/?c=Equipment
}, { -- Banker
    name = 'Leo Smith',
    dialog = 2,
    dialogDistance = 4.0,
    coords = vector3(248.19, 209.79, 106.29),
    heading = 341.87,
    model = 's_m_m_fiboffice_02',
    hasAnimation = false,
    animationDict = '',
    animation = '',
    hasWeapon = false,
    weapon = '',
    hasObject = false,
    object = ''
}, { -- Fort Zancudo Military
    name = 'Charles Smith',
    dialog = 3,
    dialogDistance = 3.0,
    coords = vector3(-2307.66, 3389.09, 30.99),
    heading = 54.78,
    model = 's_m_y_marine_01',
    hasAnimation = false,
    animationDict = '',
    animation = '',
    hasWeapon = true,
    weapon = 'WEAPON_CARBINERIFLE',
    hasObject = false,
    object = ''
}}

Config.Dialogs = {
    [1] = {
        hasChoices = true, -- If you want to display choices or you want to display a simple text
        noChoiceText = '', -- If you don't want to display choices, you can display a text instead
        dialog = {
            [1] = { -- Cop -- The index is the dialog id
                text = 'Hello, how can I help you ?', -- The text will be displayed in your dialog from NPC -- max 99 characters
                choices = {{
                    text = "I'm interested in joining the LSPD", -- That text will be displayed in your answers menu
                    value = 2 -- The value is the next dialog id
                }, {
                    text = "I'd like to make a complaint",
                    value = 3
                }, {
                    text = "Nothing, thanks",
                    value = 0 -- If you want to close the dialog, you need to set the value to 0
                }}
            },
            [2] = {
                text = "If you want to join the LSPD, you can send your CV by e-mail",
                choices = {{
                    text = 'I have another question',
                    value = 1
                }, {
                    text = 'Okay, thanks. Bye!',
                    value = 0
                }}
            },
            [3] = {
                text = 'Okay, you must complete a form on our application',
                choices = {{
                    text = 'I have another question',
                    value = 1
                }, {
                    text = 'Okay, thanks. Bye!',
                    value = 0
                }}
            }
        }
    },
    [2] = { -- Banker
        hasChoices = true,
        noChoiceText = '',
        dialog = {
            [1] = {
                text = 'Hello, how can I help you ?',
                choices = {{
                    text = "I'd like to get a credit card",
                    value = 2
                }, {
                    text = "I'd like to make a deposit",
                    value = 3
                }, {
                    text = "I'd like to make a withdrawal",
                    value = 4
                }, {
                    text = "I'd like to make a transfer",
                    value = 5
                }, {
                    text = "Nothing, thanks",
                    value = 0
                }}
            },
            [2] = {
                text = "To get your credit card, you must go at the bank and trigger the button named : Claim my credit card",
                choices = {{
                    text = 'Okay, thanks. Bye!',
                    value = 0
                }}
            },
            [3] = {
                text = 'To make a deposit, you can do it at bank or at ATM with your credit card',
                choices = {{
                    text = 'Okay, thanks. Bye!',
                    value = 0
                }}
            },
            [4] = {
                text = 'To make a withdrawal, you can do it at bank or at ATM with your credit card',
                choices = {{
                    text = 'Okay, thanks. Bye!',
                    value = 0
                }}
            },
            [5] = {
                text = 'To make a transfer, you can do it at bank and you need the bank account number of the person',
                choices = {{
                    text = 'Okay, thanks. Bye!',
                    value = 0
                }}
            }
        }
    },
    [3] = {
        hasChoices = false,
        noChoiceText = 'Sir, this is as far as you can go. Please turn around !',
        dialog = {}
    }
}
