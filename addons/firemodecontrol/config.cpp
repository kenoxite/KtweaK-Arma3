#include "\z\ktweak\addons\firemodecontrol\version.hpp"

class CfgPatches {
    class ktweak_firemodecontrol {
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
        init = "call compile preprocessFileLineNumbers '\z\ktweak\addons\firemodecontrol\functions\XEH_preInit.sqf'";
    };
};

class UserActionGroups
{
	class KTWK_FiremodeControl // Unique classname of your category.
	{
		name = "KtweaK - Firemode Control"; // Display name of your category.
		isAddon = 1;
		group[] = { "KTWK_FMC_switchToAltMuzzle" }; // List of all actions inside this category.
	};
};

class CfgUserActions
{
	class KTWK_FMC_switchToAltMuzzle // This class name is used for internal representation and also for the inputAction command.
	{
		displayName = "Switch to secondary fire mode (GL, etc)";
		tooltip = "Switches to the secondary fire mode of the weapon if available, usually an underbarrel grenade launcher.";
		onActivate = "[KTWK_player] call KTWK_FMC_fnc_switchToAltMuzzle;";		// _this is always true.
		onDeactivate = "";		// _this is always false.
		onAnalog = "[KTWK_player] call KTWK_FMC_fnc_switchToAltMuzzle;";	// _this is the scalar analog value.
		analogChangeThreshold = 0.1; // Minimum change required to trigger the onAnalog EH (default: 0.01).
	};
};

class CfgDefaultKeysPresets
{
	class Arma2 // Arma2 is inherited by all other presets.
	{
		class Mappings
		{
            KTWK_FMC_switchToAltMuzzle[] = {
                0x1D130021  // Ctrl+F (CTRL=0x1D, combo flag=0x00010000, F=0x21)
            };
		};
	};
};

class CfgFunctions {
    class KTWK_FMC {  
        class Init {
            file = "\z\ktweak\addons\firemodecontrol\functions";
            class postInit {
                postInit = 1;
            };
        };      
        class Main {
            file = "\z\ktweak\addons\firemodecontrol\functions\main";
            preInit = 1;

            class validateMuzzles {};
            class cycleFiremode {};
            class getWeaponData {};
            class switchToAltMuzzle {};
        };      
        class Helpers {
            file = "\z\ktweak\addons\firemodecontrol\functions\helpers";
            preInit = 1;

            class getPlayer {};
        };
    };
};
