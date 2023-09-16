class CfgPatches
{
	class KtweaK
	{
        name = "KtweaK";
        author = "kenoxite";
        authors[] = {"kenoxite"};
        version = "1.0";
        //url = "";

        requiredVersion = 1.60; 
        requiredAddons[] = { "A3_Functions_F", "CBA_Main", "cba_settings", "Extended_Eventhandlers" };
        units[] = {};
        weapons[] = {};
	};
};

class Extended_PreInit_EventHandlers {
    class KTWK_settings {
        init = "call compile preprocessFileLineNumbers 'KtweaK\functions\XEH_preInit.sqf'";
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
                file = "KtweaK\functions\init.sqf";
            };
        };

        class Main
        {
            file = "KtweaK\functions\main";
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
            file = "KtweaK\functions\melee";
            preInit = 1;

            class inMelee {};
        };

    };
};

#include "control_defines.inc"
#include "dialogs\dialog_default.hpp"
#include "dialogs\dialog_hud.hpp"
