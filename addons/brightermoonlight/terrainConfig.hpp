// Brighter Moonlight - Terrain Configuration

KTWK_BML_set = false;
KTWK_BML_lastOption = KTWK_BML_opt_enabled;

KTWK_BML_wasExcluded = false;
KTWK_BML_excluded = [];
call KTWK_BML_fnc_updateExclusions;
KTWK_BML_lastExcluded = KTWK_BML_opt_excludeTerrains;

KTWK_BML_altPpEffect_darker = [
    "utes",
    "chernarus",
    "chernarus_summer",
    "sara",
    "saralite",
    "sara_dbe1",
    "takistan",
    "mountains_acr",
    "lythium",
    "xcam_taunus",
    "farabad",
    "cam_lao_nam"
] apply {toLowerANSI _x};

KTWK_BML_noAperture = [
    "egl_gliese581xsouth",
    "egl_gliese581xeast",
    "egl_gliese581xnorth",
    "vn_the_bra",
    "lythium",
    "cartercity",
    "cartercity_old",
    "zargabad",
    "farabad",
    "tem_kujari"
] apply {toLowerANSI _x};
if ("swu_public_" in worldName) then {KTWK_BML_noAperture pushBack toLowerANSI worldName};

KTWK_BML_altAperture_narrow = [
    "rhspkl",
    "cam_lao_nam"
] apply {toLowerANSI _x};

KTWK_BML_altAperture_mid = [
    "enoch",
    "edaly_map_alpha",
    "vn_khe_sanh"
] apply {toLowerANSI _x};

KTWK_BML_altAperture_wide = [
    "brf_sumava",
    "tem_ihantala",
    "hellanmaa",
    "gm_weferlingen_summer",
    "bornholm"
] apply {toLowerANSI _x};

KTWK_BML_altAperture_ultraWide = [];
