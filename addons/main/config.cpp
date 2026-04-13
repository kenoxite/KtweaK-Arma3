#include "\z\ktweak\addons\main\version.hpp"

class CfgPatches
{
	class ktweak
	{
        name = "KtweaK";
        author = "kenoxite";
        authors[] = {"kenoxite"};
        version = VERSION;
        versionStr = VERSION_STR;
        versionAr[] = {VERSION_AR};
        //url = "";

        requiredVersion = 2.14; 
        requiredAddons[] = {
            "A3_Functions_F",
            "CBA_Main",
            "cba_settings",
            "Extended_Eventhandlers"
        };
        units[] = {
            "KTWK_GRdroneItem"
        };
        weapons[] = {
            "KTWK_GRdrone"
        };
	};
};

class Extended_PreInit_EventHandlers {
    class KTWK_settings {
        init = "call compile preprocessFileLineNumbers 'z\ktweak\addons\main\functions\XEH_preInit.sqf'";
    };
};

#define BN_EDITOR "call compile preprocessFileLineNumbers 'z\ktweak\addons\main\functions\ktweak_3denBrightNights.sqf'; [[], true] call KTWK_fnc_brighterNight_unSet; [] spawn {while {is3DEN} do {call KTWK_fnc_brighterNight_check; sleep 0.5;}; [[], true] call KTWK_fnc_brighterNight_unSet;};"

class Cfg3DEN
{
    class EventHandlers
    {
        class KtweaK
        {
            init = BN_EDITOR;
            OnTerrainNew = BN_EDITOR;
            OnMissionPreviewEnd = BN_EDITOR;
            OnMissionNew = BN_EDITOR;
            OnMissionLoad = BN_EDITOR;
        };
    };
};

class CfgFunctions
{
    class KTWK
    {
        class KTWKInit
        {
            class preInit
            {
                preInit = 1;
                file = "z\ktweak\addons\main\functions\ktweak_server.sqf";
            };
            class postInit
            {
                postInit = 1;
                file = "z\ktweak\addons\main\functions\initClient.sqf";
            };
        };

        class Main
        {
            file = "z\ktweak\addons\main\functions\main";
            preInit = 1;

            class BIR_checkUnits {};
            class playerUnit {};
            class disableVoice {};
            class disableVoiceCheck {};
            class enableVoice {};
            class isHuman {};
            class isAnimal {};
            class isZombie {};
            class toggleSOGvoices {};
            class AIPredatorDefense {};
            class checkForGPS {};
            class checkForMap {};
            class GPSHideIcons {};
            class unitContainerItems {};
            class swapUnitContainer {};
            class ponchoSwap {};
            class underRoof {};
            class isDuskOrDawn {};
            class isNight {};
            class AIstopForHealing {};
            class disableAutoMapCenter {};
            class addLightToAI {};
            class NVGcheck {};
            class NVGcheckInv {};
            class holsterWeapon {};
            class inBuilding {};
            class beforeDawn {};
            class inFOV {};
            class inCombat {};
            class getTemp {};
        };

        class FatalWounds
        {
            file = "z\ktweak\addons\main\functions\FW";
            preInit = 1;

            class fatalWoundPrep {};
            class cloneDead {};
            class checkBodySlam {};
            class FW_checkUnits {};
            class fatalWound {};
        };

        class GRdrone
        {
            file = "z\ktweak\addons\main\functions\GRdrone";

            class GRdrone_playerInUAV {};
            class GRdrone_spawnDrone {};
            class GRdrone_addAction {};
            class GRdrone_action {};
        };

        class Melee
        {
            file = "z\ktweak\addons\main\functions\melee";
            preInit = 1;

            class inMelee {};
            class isMeleeWeapon {};
        };

        class SlideInSlopes
        {
            file = "z\ktweak\addons\main\functions\SiS";
            preInit = 1;

            class slideInSlopes {};
            class slideDownSlope {};
            class slideUpSlope {};
        };

        class EquipNextWeapon
        {
            file = "z\ktweak\addons\main\functions\ENW";
            preInit = 1;

            class ENW_equipNextWeapon {};
            class ENW_performWeaponSwap {};
            class ENW_displayHolster {};
            class ENW_toggleHolsterDisplay {};
            class ENW_addInvEH {};
            class ENW_invAnims {};
            class ENW_addHolsters {};
            class ENW_isWeaponLong {};
            class ENW_isWeaponShort {};

            // Legacy
            class toggleHolsterDisplay {};
        };

        class BrighterNight
        {
            file = "z\ktweak\addons\main\functions\BN";
            preInit = 1;

            class brighterNight_check {};
            class brighterNight_set {};
            class brighterNight_unSet {};
            class brighterNight_set_client {};
            class brighterNight_unSet_client {};
        };
    };
};

// -------------------------------------------
// LEGACY
class CfgMagazines
{
    class CA_Magazine;
    class KTWK_GRdrone: CA_Magazine
    {
        displayName = "Recon Drone Dispenser";
        scope = 1;
        scopeArsenal = 1;
        scopeCurator = 1;
        author = "kenoxite";
        picture ="z\ktweak\addons\main\weapons\data\ui\drone_icon.paa";
        model="\A3\Drones_F\Air_F_Gamma\UAV_01\UAV_01_F.p3d";
        icon = "iconObject_circle"; //Leave as is
        descriptionShort = "Dispenser of Recon Drones, allowing their automatic launch and control.";
        mass = 80;
    };
};

// -------------------------------------------
// NEW
class CfgVehicles
{
    class Item_Base_F;

    // GR Dispenser editor item
    class KTWK_GRdroneItem: Item_Base_F
    {
        scope = 2;
        scopeCurator = 2;
        scopeArsenal = 2;
        displayName = "Recon Drone Dispenser";
        author = "kenoxite";
        editorCategory = "EdCat_Equipment";
        editorSubcategory = "EdSubcat_InventoryItems";
        vehicleClass = "Items";
        class TransportItems
        {
            class _xx_KTWK_GRdrone
            {
                name = "KTWK_GRdrone";
                count = 1;
            };
        };
    };
};

class CfgWeapons
{
    class CBA_MiscItem;
    class CBA_MiscItem_ItemInfo;
    class KTWK_ItemCore: CBA_MiscItem {};

    // GR Dispenser inventory item
    class KTWK_GRdrone: KTWK_ItemCore
    {
        author = "kenoxite";
        scope = 2;
        scopeArsenal = 2;
        scopeCurator = 2;
        displayName = "Recon Drone Dispenser";
        descriptionShort = "Dispenser of Recon Drones, allowing their automatic launch and control.";
        picture = "z\ktweak\addons\main\weapons\data\ui\drone_icon.paa";
        model = "\A3\Drones_F\Air_F_Gamma\UAV_01\UAV_01_F.p3d";
        icon = "iconObject_circle";
        class ItemInfo: CBA_MiscItem_ItemInfo
        {
            mass = 80;
        };
    };
};

// SOUNDS
class CfgSounds
{
    sounds[] = {};

    class KTWK_noSound
    {
        name = "[FX] No sound";
        sound[] = { "z\ktweak\addons\main\sounds\silence.wss", "db", 1, 100 };
        titles[] = {};
    };

    // Effects
    class KTWK_coverInDirt {
        name = "[FX] Covering in dirt";
        sound[] = {"z\ktweak\addons\main\sounds\coverInDirt.wss", "db", 1, 100 };
        titles[] = {0, ""};
    };
    class KTWK_slidingUpSlope {
        name = "[FX] Sliding upslope";
        sound[] = {"z\ktweak\addons\main\sounds\slidingUpSlope.wss", "db", 1, 100 };
        titles[] = {0, ""};
    };
    class KTWK_slidingDownSlope {
        name = "[FX] Sliding downslope";
        sound[] = {"z\ktweak\addons\main\sounds\slidingDownSlope.wss", "db", 1, 100 };
        titles[] = {0, ""};
    };
    class KTWK_gruntMan1 {
        name = "[FX] Grunt man 1";
        sound[] = {"z\ktweak\addons\main\sounds\manGrunt1.wss", "db+20", 1, 100 };
        titles[] = {0, ""};
    };
    class KTWK_gruntMan2 {
        name = "[FX] Grunt man 2";
        sound[] = {"z\ktweak\addons\main\sounds\manGrunt2.wss", "db+20", 1, 100 };
        titles[] = {0, ""};
    };
    class KTWK_gruntMan3 {
        name = "[FX] Grunt man 3";
        sound[] = {"z\ktweak\addons\main\sounds\manGrunt3.wss", "db+20", 1, 100 };
        titles[] = {0, ""};
    };
    class KTWK_gruntMan4 {
        name = "[FX] Grunt man 4";
        sound[] = {"z\ktweak\addons\main\sounds\manGrunt4.wss", "db+20", 1, 100 };
        titles[] = {0, ""};
    };
};
