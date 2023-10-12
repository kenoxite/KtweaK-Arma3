params ["_wep"];
getNumber(configFile >> "cfgWeapons" >> _wep >> "IMS_Melee_Param_Damage") > 0
