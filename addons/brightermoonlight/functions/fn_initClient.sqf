// Brighter Moonlight - Client initialization

if (!hasInterface) exitWith {};

// Disable bright night effects
// - SP
addMissionEventHandler ["Ended", {
    params ["_endType"];
    true call KTWK_BML_fnc_unSet_client;
}];

// - MP
0 spawn {
    waitUntil {!isNull findDisplay 46};
    findDisplay 46 displayAddEventHandler ["Unload", {
        true call KTWK_BML_fnc_unSet_client;
    }];
};
