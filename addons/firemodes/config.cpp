#include "\z\ktweak\addons\firemodes\version.hpp"

class CfgPatches {
    class ktweak_firemodes {
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
    class KTWK_Firemodes_settings {
        init = "call compile preprocessFileLineNumbers '\z\ktweak\addons\firemodes\functions\XEH_preInit.sqf'";
    };
};

class CfgFunctions {
    class KTWK_CFM {  
        class Init {
            file = "\z\ktweak\addons\firemodes\functions";
            class postInit {
                postInit = 1;
            };
        };      
        class Main {
            file = "\z\ktweak\addons\firemodes\functions\main";
            preInit = 1;

            class validateMuzzles {};
            class cycleFiremode {};
            class getWeaponData {};
            class nextWeapon {};
            class switchToGL {};
        };
    };
};
