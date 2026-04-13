// Check for stored NVG

params ["_unit"];

private _hasNVG = false;
private _cfgWeps = configFile >> "cfgWeapons";
{
    if (_x isKindOf ["NVGoggles", _cfgWeps]) then {
        _hasNVG = true;
    };
} forEach (itemsWithMagazines _unit);

_hasNVG
