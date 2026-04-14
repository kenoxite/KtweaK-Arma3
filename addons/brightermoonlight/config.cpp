#include "\z\ktweak\addons\brightermoonlight\version.hpp"

class CfgPatches {
    class ktweak_brightermoonlight {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {
            "A3_Functions_F",
            "CBA_Main",
            "cba_settings",
            "Extended_Eventhandlers"
        };
        author = "kenoxite";
        authors[] = {"kenoxite"};
        url = "";
        version = VERSION;
        versionStr = VERSION_STR;
        versionAr[] = {VERSION_AR};
    };
};

class Extended_PreInit_EventHandlers {
    class KTWK_BM_settings {
        init = "call compile preprocessFileLineNumbers '\z\ktweak\addons\brightermoonlight\functions\XEH_preInit.sqf'";
    };
};

#define BM_EDITOR "call compile preprocessFileLineNumbers '\z\ktweak\addons\brightermoonlight\functions\BM_editor.sqf'; [[], true] call KTWK_BM_fnc_unSet; [] spawn {while {is3DEN} do {call KTWK_BM_fnc_check; sleep 0.5;}; [[], true] call KTWK_BM_fnc_unSet;};"

class Cfg3DEN
{
    class EventHandlers
    {
        class BrighterMoonlight
        {
            init = BM_EDITOR;
            OnTerrainNew = BM_EDITOR;
            OnMissionPreviewEnd = BM_EDITOR;
            OnMissionNew = BM_EDITOR;
            OnMissionLoad = BM_EDITOR;
        };
    };
};

class CfgFunctions {
    class KTWK_BM {
        class Init {
            file = "\z\ktweak\addons\brightermoonlight\functions";
            class preInit {
                preInit = 1;
            };
            class postInit {
                postInit = 1;
            };
        };

        class Main {
            file = "\z\ktweak\addons\brightermoonlight\functions\main";
            class check {};
            class set {};
            class unSet {};
            class set_client {};
            class unSet_client {};
        };

        class Helpers {
            file = "\z\ktweak\addons\brightermoonlight\functions\helpers";
            class isNight {};
        };
    };
};
