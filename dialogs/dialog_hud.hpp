#include "..\control_defines.inc"

class RscTitles
{
    // HUD - Body Health
    class KTWK_GUI_Dialog_HUD_bodyHealth
    {
        idd = IDD_HUD_BODYHEALTH;
        name = "HUD_bodyHealth";
        movingEnable = false;
        enableSimulation = true;
        onLoad = "uiNamespace setVariable ['KTWK_GUI_Display_HUD_bodyHealth', _this #0];";
        onUnLoad = "uiNamespace setVariable ['KTWK_GUI_Display_HUD_bodyHealth', nil]";
        duration = 9999999;
        fadeIn = 1;
        fadeOut = 1;

        class controls
        {
            class KTWK_Grp_HUD_bodyHealth: KTWK_Controls_Group {
                idc = IDC_GRP_HUD_BODYHEALTH; 

                x = SafeZoneX + (SafeZoneW - (4 * pixelGridNoUIScale * pixelW));
                y = SafeZoneY + (SafeZoneH - (9 * pixelGridNoUIScale * pixelH));
                w = 4 * pixelGridNoUIScale * pixelW;
                h = 8 * pixelGridNoUIScale * pixelH;

                class Controls {
                    // Backgrounds
                    class KTWK_Img_HUD_bodyHealth_Background1:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_BG1;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };

                    class KTWK_Img_HUD_bodyHealth_Background2:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_BG2;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };

                    // Foregrounds
                    class KTWK_Img_HUD_bodyHealth_Foreground1:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_FG1;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };

                    class KTWK_Img_HUD_bodyHealth_Foreground2:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_FG2;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };

                    // Body parts - Groups
                    class KTWK_Img_HUD_bodyHealth_Grp_Head:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_GRP_HEAD;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Grp_Torso:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_GRP_TORSO;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Grp_Arms:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_GRP_ARMS;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Grp_HeadWFace:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_GRP_HEADWFACE;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };

                    // Body parts - Individual parts
                    // Head
                    class KTWK_Img_HUD_bodyHealth_Head:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_HEAD;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Face:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_FACE;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Neck:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_NECK;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    // Torso
                    class KTWK_Img_HUD_bodyHealth_Chest:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_CHEST;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Diaphragm:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_DIAPHRAGM;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Abdomen:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_ABDOMEN;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Pelvis:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_PELVIS;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    // Arms
                    class KTWK_Img_HUD_bodyHealth_Arms:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_ARMS;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    class KTWK_Img_HUD_bodyHealth_Hands:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_HANDS;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    // Legs
                    class KTWK_Img_HUD_bodyHealth_Legs:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_LEGS;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                    // Body
                    class KTWK_Img_HUD_bodyHealth_Body:KTWK_RscPicture
                    {
                        idc = IDC_IMG_HUD_HEALTH_BODY;

                        x = 0 * pixelGridNoUIScale * pixelW;
                        y = 0 * pixelGridNoUIScale * pixelH;
                        w = 4 * pixelGridNoUIScale * pixelW;   
                        h = 8 * pixelGridNoUIScale * pixelH;
                        
                        text = "";
                    };
                };
            };
        };
    };
};