class CfgPatches
{
	class kTweaks
	{
        name = "kTweaks";
        author = "kenoxite";
        authors[] = {"kenoxite"};
        version = "0.2";
        //url = "";

        requiredVersion = 1.60; 
        requiredAddons[] = { "A3_Functions_F", "CBA_Main", "cba_settings", "Extended_Eventhandlers" };
        units[] = {};
        weapons[] = {};
	};
};

class Extended_PreInit_EventHandlers {
    class KTWK_settings {
        init = "call compile preprocessFileLineNumbers 'kTweaks\functions\XEH_preInit.sqf'";
    };
};

class CfgFunctions
{
    class KTWK
    {
        class KTWKInit
        {
            class postInit
            {
                postInit = 1;
                file = "kTweaks\functions\init.sqf";
            };
        };

        class Main
        {
            file = "kTweaks\functions\main";
            preInit = 1;

            class inBuilding {};
            class fatalWoundPrep {};
            class cloneDead {};
            class checkBodySlam {};
            class FW_checkUnits {};
            class BIR_checkUnits {};
            class playerUnit {};
        };

        class Melee
        {
            file = "kTweaks\functions\melee";
            preInit = 1;

            class inMelee {};
        };

    };
};

#include "control_defines.inc"
#include "dialogs\dialog_default.hpp"
#include "dialogs\dialog_hud.hpp"
