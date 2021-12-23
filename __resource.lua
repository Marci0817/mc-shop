resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

author "Marci"
description "Egy új, egyedi bolt rendszer. by.: Marci :)"
version "v1"

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/listener.js',
	'html/style.css',
	'html/reset.css',
	--ide jönnek a képek neked kell mindet beírnod ha hozzáadsz
	'html/img/water.png',
	'html/img/default.png',
}

client_scripts {
	"client.lua",
	"config.lua"
}
server_scripts{
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	"server.lua",
	"config.lua"
}