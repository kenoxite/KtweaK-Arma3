// Returns whether the weapon is considered to be physically long or not
// by kenoxite

params [["_wep", ""]];
if (_wep == "") exitWith {false};
private _primWep = toLowerAnsi _wep;
private _primWepType = (_primWep call BIS_fnc_itemType) select 1;
private _primWepDes = toLowerAnsi (getText (configFile >> "CfgWeapons" >> _primWep >> "descriptionShort"));


call {
    if ("vss" in _primWep) exitWith {false};
    if ("sniper" in _primWepDes) exitWith {true};
    if (_primWepType == "SniperRifle") exitWith {true};
    if (_primWepType == "MachineGun") exitWith {true};
    if ("srifle" in _primWep) exitWith {true};
    if ("dmr" in _primWep) exitWith {true};
    if ("sr25" in _primWep) exitWith {true};
    if ("m76" in _primWep) exitWith {true};
    if ("rpk" in _primWep) exitWith {true};
    if ("mg" in _primWep && !("smg" in _primWep)) exitWith {true};
    if ("fal" in _primWep) exitWith {true};
    if ("l1a1" in _primWep) exitWith {true};
    if ("kar" in _primWep) exitWith {true};
    if ("m590" in _primWep) exitWith {true};
    if ("ak15" in _primWep) exitWith {true};
    if ("ak19" in _primWep) exitWith {true};
    if ("ak101" in _primWep) exitWith {true};
    if ("ak103" in _primWep) exitWith {true};
    if ("ak107" in _primWep) exitWith {true};
    if ("ak108" in _primWep) exitWith {true};
    if ("ak109" in _primWep) exitWith {true};
    if ("ak74" in _primWep) exitWith {true};
    if ("akm" in _primWep) exitWith {true};
    if ("aks" in _primWep) exitWith {true};
    if ("cz550" in _primWep) exitWith {true};
    if ("cz584" in _primWep) exitWith {true};
    if ("cz750" in _primWep) exitWith {true};
    if ("gewehr1" in _primWep) exitWith {true};
    if ("g36" in _primWep && !("g36c" in _primWep) && !("g36k" in _primWep)) exitWith {true};
    if ("g3a3" in _primWep) exitWith {true};
    if ("galil" in _primWep && !("sar" in _primWep)) exitWith {true};
    if ("klec" in _primWep) exitWith {true};
    if ("sgun_huntershotgun_01_f" in _primWep) exitWith {true};
    if ("l129a1" in _primWep) exitWith {true};
    if ("garand" in _primWep) exitWith {true};
    if ("m1014" in _primWep) exitWith {true};
    if ("m16" in _primWep) exitWith {true};
    if ("m27" in _primWep) exitWith {true};
    if ("m70" in _primWep) exitWith {true};
    if ("mk17" in _primWep && !("cqc" in _primWep)) exitWith {true};
    if ("m38" in _primWep) exitWith {true};
    if ("mp44" in _primWep) exitWith {true};
    if ("remington" in _primWep) exitWith {true};
    if ("romat" in _primWep) exitWith {true};
    if ("sa58" in _primWep) exitWith {true};
    if ("sks" in _primWep) exitWith {true};
    if ("m14" in _primWep) exitWith {true};
    if ("spas" in _primWep) exitWith {true};
    if ("stg58" in _primWep) exitWith {true};
    if ("saiga" in _primWep) exitWith {true};
    if ("scarh" in _primWep) exitWith {true};
    false  
};
