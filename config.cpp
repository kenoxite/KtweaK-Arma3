class CfgPatches
{
	class KtweaK
	{
        name = "KtweaK";
        author = "kenoxite";
        authors[] = {"kenoxite"};
        version = "1.0.6";
        //url = "";

        requiredVersion = 1.60; 
        requiredAddons[] = { "A3_Functions_F", "CBA_Main", "cba_settings", "Extended_Eventhandlers" };
        units[] = {
        };
        weapons[] = {
        };
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

            class fatalWoundPrep {};
            class cloneDead {};
            class checkBodySlam {};
            class FW_checkUnits {};
            class BIR_checkUnits {};
            class playerUnit {};
            class disableVoice {};
            class disableVoiceCheck {};
            class isHuman {};
            class isZombie {};
        };

        class HUDhealth
        {
            file = "KtweaK\functions\HUDhealth";

            class HUD_health_InvEH {};
            class HUD_health_resetDmgTracker {};
            class HUD_health_update {};
            class HUD_health_reset {};
            class HUD_health_moveDialog {};
        };

        class GRdrone
        {
            file = "KtweaK\functions\GRdrone";

            class GRdrone_playerInUAV {};
            class GRdrone_spawnDrone {};
            class GRdrone_addAction {};
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

class CfgMagazines
{
    class CA_Magazine;
    class KTWK_GRdrone: CA_Magazine
    {
        displayName = "GR Drone Dispenser";
        scope = 2;
        scopeArsenal = 2;
        scopeCurator = 2;
        author = "kenoxite";
        picture ="\KtweaK\weapons\data\ui\drone_icon.paa";
        model="\A3\Drones_F\Air_F_Gamma\UAV_01\UAV_01_F.p3d";
        icon = "iconObject_circle"; //Leave as is
        descriptionShort = "Dispenser of GR Drones, allowing their automatic launch and control.";
        mass = 80;
    };
};
