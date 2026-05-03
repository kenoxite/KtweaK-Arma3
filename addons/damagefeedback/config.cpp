#include "\z\ktweak\addons\damagefeedback\version.hpp"

class CfgPatches {
    class ktweak_damagefeedback {
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

#include "\z\ktweak\addons\damagefeedback\gui.hpp"

class Extended_PreInit_EventHandlers {
    class KTWK_DFB_settings {
        init = "call compile preprocessFileLineNumbers 'z\ktweak\addons\damagefeedback\functions\XEH_preInit.sqf'";
    };
};

class CfgFunctions {
    class KTWK_DFB {
        class Init {
            file = "\z\ktweak\addons\damagefeedback\functions";
            class postInit {
                postInit = 1;
            };
        };

        class Main {
            file = "\z\ktweak\addons\damagefeedback\functions\main";
            class createPfh {};
            class disableSystem {};
            class drawHUD {};
            class hideHUD {};
            class initGlobals {};
            class initSystem {};
            class moveDialog {};
            class reset {};
            class resetDmgTracker {};
            class showHUD {};
            class toggleSystem {};
            class update {};
        };

        class Helpers {
            file = "\z\ktweak\addons\damagefeedback\functions\helpers";
            class getPlayer {};
            class isAnimal {};
            class isHuman {};
            class isZombie {};
            class inMelee {};
        };
    };
};
