Config = {}

Config.NPCHash = 0x5244247D 	--https://wiki.rage.mp/index.php?title=Peds
Config.NPCName = "u_m_y_baygor"



----------- Kiírások -------------
Config.NameChat = "^1[ mc_shop ] ^0" -- Üzenetek/hibaüzenetek a chaten

--Config.NoPermission = "Nincs jogosultságod a parancs használatára!"
Config.parameter = "Nincs megadva minden paraméter."
Config.openShopText = "Nyomd meg az ~g~E~w~ betüt, hogy megnyisd a boltot."
Config.notOnline = "Nincs ilyen ID-vel rendelkező játékos online."
Config.openStorageText = "Nyomd meg az ~g~E~w~ betüt, hogy megnyisd a kezelöfelületet."
Config.cantCarry = "Nem fér el nálad."
Config.SuccesBuy = "Sikeresen megvásároltad."
Config.StoreExsist = "Már létezik ilyen nevű bolt."
Config.Succes = "Sikeresen létrehoztad az a boltot."
Config.NotYours = "Ez nem a te boltod, nem tudod megnyitni a kezelöfelületet."
Config.removeError = "Nem található az item, amit elszeretnél távolítani."
Config.removeSucces = "Sikeresen eltávolítottad a terméket a boltból."
Config.OutOfStock = "Nincs raktáron."
Config.NotEnoughMoney = "Nincs elég pénzed."
Config.SuccesKereslet = "Sikeresen kivetted a bolt keresletét."
Config.nagyKerAr = "Nem adhatod olcsóbban mint a nagykerár."
Config.SuccesArValtozas = "Sikeresen megváltoztattad az árát."
Config.nincsIlyenItem = "Nincs ilyen termék."
Config.vanMarIlyen = "Van már ilyen termék a boltban."
Config.SikeresItemAdd = "Sikeresen hozzáadtál egy új terméket a bolthoz."

-- Azok számára akik ki szeretnék játszani a rendszert. :) ( Nem lehet. )
Config.InvaildItem = "Ilyen item nincs is ebbe a boltba, hogy akarod megvenni öcsi?"
Config.PriceNemJo = "Vicces, ezt nem veheted meg ennyiért.."
Config.NoShop = "Szép próbálkozás, de nincs is ilyen bolt."
Config.ismeretlen = "Hehh? Nah ezt a hibát hogy idézted elő?"

Config.Debug = true -- Ki fogja írni console-ra, hogy ki próbálkozik a fentiekkel. ( ajánlott ) 


--------------------------------------------------------------------------------------------------------
Config.MenuAlign = "right" -- right, left, top-left, top-right, bottom-left, bottom-right
--Lehetséges itemek, amiket be lehet tenni a boltba.
Config.itemsInShop = {-- lehívó név, nagyker ár, név ami megjelenik
	{"bread",10, "Kenyér"},
	{"water",20, "Víz"},
	{"cannabis",15, "Kanabisz"},
	{"fixkit", 50, "Szerelőláda"}
}

--[[

Víz,water,10,50][Kenyér,bread,5,999

$/huf váltás
jogosultság ki tud lerakni bolott

]]--
