// -----------------------------------------------
// KTWEAK - Init
// by kenoxite
// -----------------------------------------------

// Init
// [] execVM "KtweaK\functions\ktweak.sqf";

if (hasInterface) then {
    [] execVM "KtweaK\functions\ktweak_client.sqf";
};

if (isServer) then {
    [] execVM "KtweaK\functions\ktweak_server.sqf";
};
