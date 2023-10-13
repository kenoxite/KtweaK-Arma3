// -----------------------------------------------
// KTWEAK - Init
// by kenoxite
// -----------------------------------------------

if (hasInterface) then {
    [] execVM "KtweaK\functions\ktweak_client.sqf";
};

if (isServer) then {
    [] execVM "KtweaK\functions\ktweak_server.sqf";
};
