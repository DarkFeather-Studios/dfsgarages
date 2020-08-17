fx_version 'bodacious'
game 'gta5'

client_scripts {
    '@warmenu/warmenu.lua',
    'client.lua',
    'config_cl.lua',
}

server_scripts {
    'config_sv.lua',
    'server.lua',
	'@mysql-async/lib/MySQL.lua',
}

dependency 'enc0ded-persistent-vehicles'