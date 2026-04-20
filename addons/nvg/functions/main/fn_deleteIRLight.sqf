// KTWK_NVG_fnc_deleteIRLight
// Deletes IR light objects associated with a player UID from the light manager array
//
// Parameters:
//   _uid - Player UID to remove lights for
// Returns:
//   Nothing

params ["_uid"];

private _toDelete = [];

// Find uid in light manager array and mark for deletion
{
    if ((_x # 0) == _uid) then {
        _toDelete pushBack _forEachIndex;
    };
} forEach KTWK_NVG_irLightManager;

// Delete the lights and remove entries from array (reverse order to preserve indices)
{
    private _entry = KTWK_NVG_irLightManager # _x;
    deleteVehicle (_entry # 1);
    KTWK_NVG_irLightManager deleteAt _x;
} forEach (call {
    private _reversed = [];
    for "_i" from (count _toDelete - 1) to 0 step -1 do {
        _reversed pushBack (_toDelete # _i);
    };
    _reversed
});
