#include "\z\ktweak\addons\nvg\version.hpp"

class CfgPatches {
    class ktweak_nvg {
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
    class KTWK_NVG_settings {
        init = "call compile preprocessFileLineNumbers '\z\ktweak\addons\nvg\functions\XEH_preInit.sqf'";
    };
};

class CfgFunctions {
    class KTWK_NVG {
        class Init {
            file = "\z\ktweak\addons\nvg\functions";
            class preInit {
                preInit = 1;
            };
            class postInit {
                postInit = 1;
            };
        };

        class Main {
            file = "\z\ktweak\addons\nvg\functions\main";
            class disableSystem {};
            class resetCache {};
            class mode {};
            class sampleLighting {};
            class calcEffects {};
            class createHandles {};
            class applyEffects {};
            class disableEffects {};
            class initSystem {};
            class createPfh {};
            class initGlobals {};
            class isExcluded {};
            class getDeviceGen {};
            class updateColorArrays {};
            class updateExclusions {};
            class updateGenArrays {};
            class toggleIRLight {};
            class createIRLight {};
            class deleteIRLight {};
            class updateOpticZoom {};
        };

        class Helpers {
            file = "\z\ktweak\addons\nvg\functions\helpers";
            class getZoom {};
            class resolveMagicWords {};
            class getColor {};
        };
    };
};
