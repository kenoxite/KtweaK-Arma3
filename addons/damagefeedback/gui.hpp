// Bodypart HUD - GUI Definitions

// Base classes
class RscPicture;
class RscControlsGroup;

#include "\z\ktweak\addons\damagefeedback\idc.hpp"

class RscTitles
{
    class BPH_Dialog
    {
        idd = IDD_BPH_DIALOG;
        name = "BPH_Dialog";
        movingEnable = 1;
        enableSimulation = 1;
        enableDisplay = 1;
        onLoad = "uiNamespace setVariable ['BPH_Display', _this #0];";
        onUnLoad = "uiNamespace setVariable ['BPH_Display', nil];";
        duration = 9999999;
        fadeIn = 1;
        fadeOut = 1;

        class controls
        {
            class BPH_ControlsGroup: RscControlsGroup
            {
                idc = IDC_BPH_GROUP;
                x = "safeZoneX + (safeZoneW - (3.5 * pixelGridNoUIScale * pixelW))";
                y = "safeZoneY + (safeZoneH - (7.4 * pixelGridNoUIScale * pixelH))";
                w = "4 * pixelGridNoUIScale * pixelW";
                h = "8 * pixelGridNoUIScale * pixelH";

                class controls
                {
                    // Global health indicator
                    class BPH_GlobalHealth: RscPicture
                    {
                        idc = IDC_BPH_GLOBAL;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Outline
                    class BPH_Outline: RscPicture
                    {
                        idc = IDC_BPH_OUTLINE;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Head group
                    class BPH_Head: RscPicture
                    {
                        idc = IDC_BPH_HEAD;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Face
                    class BPH_Face: RscPicture
                    {
                        idc = IDC_BPH_FACE;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Neck
                    class BPH_Neck: RscPicture
                    {
                        idc = IDC_BPH_NECK;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Torso group
                    class BPH_Torso: RscPicture
                    {
                        idc = IDC_BPH_TORSO;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Chest
                    class BPH_Chest: RscPicture
                    {
                        idc = IDC_BPH_CHEST;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Diaphragm
                    class BPH_Diaphragm: RscPicture
                    {
                        idc = IDC_BPH_DIAPHRAGM;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Abdomen
                    class BPH_Abdomen: RscPicture
                    {
                        idc = IDC_BPH_ABDOMEN;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Pelvis
                    class BPH_Pelvis: RscPicture
                    {
                        idc = IDC_BPH_PELVIS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Arms group
                    class BPH_Arms: RscPicture
                    {
                        idc = IDC_BPH_ARMS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Left arm
                    class BPH_LeftArm: RscPicture
                    {
                        idc = IDC_BPH_LEFTARM;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Right arm
                    class BPH_RightArm: RscPicture
                    {
                        idc = IDC_BPH_RIGHTARM;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Hands
                    class BPH_Hands: RscPicture
                    {
                        idc = IDC_BPH_HANDS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Legs group
                    class BPH_Legs: RscPicture
                    {
                        idc = IDC_BPH_LEGS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Left leg
                    class BPH_LeftLeg: RscPicture
                    {
                        idc = IDC_BPH_LEFTLEG;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Right leg
                    class BPH_RightLeg: RscPicture
                    {
                        idc = IDC_BPH_RIGHTLEG;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Body (full)
                    class BPH_Body: RscPicture
                    {
                        idc = IDC_BPH_BODY;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };
                };
            };
        };
    };
};
