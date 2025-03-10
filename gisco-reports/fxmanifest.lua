fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'ItsGisca'
description 'Report system for ESX using OX_LIB'

shared_scripts {
    '@es_extended/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/nl.lua',
    'config.lua',
}

client_scripts {
    'scr/client/cl_reports.lua',
    'scr/client/cl_function_open.lua'
}

server_script {
    '@mysql-async/lib/MySQL.lua',
    'scr/server/sv_reports.lua',
    'scr/server/sv_logs.lua',
}
