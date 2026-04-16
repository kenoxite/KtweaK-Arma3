// KTWK_NVG_fnc_getZoom
// Calculates current zoom level based on screen position
//
// Parameters:
//   None
// Returns:
//   Number - Current zoom factor

(
    [0.5,0.5] 
    distance 
    worldToScreen 
    positionCameraToWorld 
    [0,1.05,1]
) * (
    getResolution 
    select 
    5
)
