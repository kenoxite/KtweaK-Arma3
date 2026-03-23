private _player = call CBA_fnc_currentUnit;
private _veh = vehicle _player;
((assignedItems _player) findIf {
    _x in [
        // Vanilla
        "ItemGPS",
        
        "I_UavTerminal",
        "C_UavTerminal",
        "O_UavTerminal",
        "I_E_UavTerminal",
        "B_UavTerminal",

        // Central Africa 2035
        "I_CA2035_UavTerminal",

        // Central Africa 2035 - PMC
        "Item_I_CA2035PMC_UavTerminal",
        "Item_O_CA2035PMC_UavTerminal",
        "Item_B_CA2035PMC_UavTerminal"
        ]
    }) >= 0
|| ((_veh != _player) && {getNumber (configFile >> "cfgVehicles" >> typeof _veh >> "enableGPS") == 1}) 
