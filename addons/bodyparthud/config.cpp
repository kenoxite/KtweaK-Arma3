#include "\z\ktweak\addons\bodyparthud\version.hpp"

class CfgPatches {
    class ktweak_bodyparthud {
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

#include "\z\ktweak\addons\bodyparthud\gui.hpp"

class Extended_PreInit_EventHandlers {
    class KTWK_BPH_settings {
        init = "call compile preprocessFileLineNumbers 'z\ktweak\addons\bodyparthud\functions\XEH_preInit.sqf'";
    };
};

class CfgFunctions {
    class KTWK_BPH {
        class Init {
            file = "\z\ktweak\addons\bodyparthud\functions";
            class postInit {
                postInit = 1;
            };
        };

        class Main {
            file = "\z\ktweak\addons\bodyparthud\functions\main";
            class initHUD {};
            class invEH {};
            class moveDialog {};
            class reset {};
            class resetDmgTracker {};
            class update {};
        };

        class Helpers {
            file = "\z\ktweak\addons\bodyparthud\functions\helpers";
            class isAnimal {};
            class isHuman {};
            class isZombie {};
            class inMelee {};
        };
    };
};
