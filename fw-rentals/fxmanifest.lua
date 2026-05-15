fx_version 'cerulean'
game 'gta5'

author 'Frank Scripts'
description 'FW Rentals. This script took insperation from Prodigy RP 2.0 Rental System'
version '1.0.0'

ui_page 'web/dist/index.html'
shared_scripts {
    '@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
    '@qbx_core/modules/playerdata.lua',
}

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua'
}

server_script {
    'server/*.lua'
}

files {
	'config/client.lua',
	'config/server.lua',
    'web/dist/**/*'

}

dependencies {
	'ox_lib',
	'ox_target',
	'ox_inventory',
	'qbx_core',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'