// Damage Feedback - GUI Definitions

// Base classes
class RscPicture;
class RscControlsGroup;

#include "\z\ktweak\addons\damagefeedback\idc.hpp"

class RscTitles
{
    class DFB_Dialog
    {
        idd = IDD_DFB_DIALOG;
        name = "DFB_Dialog";
        movingEnable = 1;
        enableSimulation = 1;
        enableDisplay = 1;
        onLoad = "uiNamespace setVariable ['DFB_Display', _this #0];";
        onUnLoad = "";
        duration = 9999999;
        fadeIn = 1;
        fadeOut = 1;

        class controls
        {
            class DFB_ControlsGroup: RscControlsGroup
            {
                idc = IDC_DFB_GROUP;
                x = "safeZoneX + (safeZoneW - (3.5 * pixelGridNoUIScale * pixelW))";
                y = "safeZoneY + (safeZoneH - (7.4 * pixelGridNoUIScale * pixelH))";
                w = "4 * pixelGridNoUIScale * pixelW";
                h = "8 * pixelGridNoUIScale * pixelH";

                class controls
                {
                    // Global health indicator
                    class DFB_GlobalHealth: RscPicture
                    {
                        idc = IDC_DFB_GLOBAL;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Outline
                    class DFB_Outline: RscPicture
                    {
                        idc = IDC_DFB_OUTLINE;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Head group
                    class DFB_Head: RscPicture
                    {
                        idc = IDC_DFB_HEAD;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Face
                    class DFB_Face: RscPicture
                    {
                        idc = IDC_DFB_FACE;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Neck
                    class DFB_Neck: RscPicture
                    {
                        idc = IDC_DFB_NECK;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Torso group
                    class DFB_Torso: RscPicture
                    {
                        idc = IDC_DFB_TORSO;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Chest
                    class DFB_Chest: RscPicture
                    {
                        idc = IDC_DFB_CHEST;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Diaphragm
                    class DFB_Diaphragm: RscPicture
                    {
                        idc = IDC_DFB_DIAPHRAGM;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Abdomen
                    class DFB_Abdomen: RscPicture
                    {
                        idc = IDC_DFB_ABDOMEN;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Pelvis
                    class DFB_Pelvis: RscPicture
                    {
                        idc = IDC_DFB_PELVIS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Arms group
                    class DFB_Arms: RscPicture
                    {
                        idc = IDC_DFB_ARMS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Left arm
                    class DFB_LeftArm: RscPicture
                    {
                        idc = IDC_DFB_LEFTARM;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Right arm
                    class DFB_RightArm: RscPicture
                    {
                        idc = IDC_DFB_RIGHTARM;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Hands
                    class DFB_Hands: RscPicture
                    {
                        idc = IDC_DFB_HANDS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Legs group
                    class DFB_Legs: RscPicture
                    {
                        idc = IDC_DFB_LEGS;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Left leg
                    class DFB_LeftLeg: RscPicture
                    {
                        idc = IDC_DFB_LEFTLEG;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Right leg
                    class DFB_RightLeg: RscPicture
                    {
                        idc = IDC_DFB_RIGHTLEG;
                        x = 0;
                        y = 0;
                        w = "4 * pixelGridNoUIScale * pixelW";
                        h = "8 * pixelGridNoUIScale * pixelH";
                        text = "";
                    };

                    // Body (full)
                    class DFB_Body: RscPicture
                    {
                        idc = IDC_DFB_BODY;
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
