// Swaps the equipped poncho from dry to wet, and viceversa, based on weather and other conditions
// by kenoxite

#define DRYRATE 0.03

params [["_unit", objNull]];
if (isNull _unit) exitWith {false};
if (!local _unit) exitWith {false};

// Exit if paused
if (isPlayer _unit && {!(isNull (findDisplay 49))}) exitWith {false};
// Exit in arsenal
if (_unit getVariable ["KTWK_arsenalOpened", false]) exitWith {false};

private _validPonchos_backpack = [
    // MGSR
    "mgsr_poncho_wet",
    "mgsr_poncho_dry"
];

private _validPonchos_vest = [
    // MGSR
    "mgsr_poncho_dry_vest",
    "mgsr_poncho_wet_vest"
];

// If for some reason both poncho types are worn, only the vest is visible
private _ponchoBackpack = backpack _unit;
private _ponchoVest = vest _unit;
private _poncho = "";
private _ponchoType = "";
call { 
    if (_ponchoVest in _validPonchos_vest) exitWith { _ponchoType = "vest"; _poncho = _ponchoVest };  
    if (_ponchoBackpack in _validPonchos_backpack) exitWith { _ponchoType = "backpack"; _poncho = _ponchoBackpack }; 
};
if (_ponchoType == "") exitWith {false};

// Is wet when: under rain and not under roof or vehicle; swimming or diving
private _isWet = (rain > 0 && !([_unit] call KTWK_fnc_underRoof)) || (eyePos _unit)#2 < 0;
private _wetness = _unit getVariable ["KTWK_wetness", 0];
_wetness = if (_isWet) then { (_wetness + ([1, rain/2] select (rain > 0))) min 1 } else { (_wetness - DRYRATE) max 0 };
_unit setVariable ["KTWK_wetness", _wetness, true];

private _newPoncho = "";
call {
    if (_wetness > 0.5 && {"dry" in _poncho}) then {
        call {
            if (_ponchoType == "vest") exitWith { _newPoncho = "mgsr_poncho_wet_vest" };
            if (_ponchoType == "backpack") exitWith { _newPoncho = "mgsr_poncho_wet" };
        };
    };
    if (_wetness == 0 && {"wet" in _poncho}) then {
        call {
            if (_ponchoType == "vest") exitWith { _newPoncho = "mgsr_poncho_dry_vest" };
            if (_ponchoType == "backpack") exitWith { _newPoncho = "mgsr_poncho_dry" };
        };
    };
};

if (_newPoncho != "") then {
    // [_unit, _ponchoType, _newPoncho] call KTWK_fnc_swapUnitContainer;
    [_unit, _ponchoType, _newPoncho] remoteExecCall ["KTWK_fnc_swapUnitContainer", _unit];
};
