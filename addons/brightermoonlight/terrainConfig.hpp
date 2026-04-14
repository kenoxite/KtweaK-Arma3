// Brighter Moonlight - Terrain Configuration

KTWK_BM_set = false;
KTWK_BM_lastOption = KTWK_BM_opt_enabled;

// All terrain names must be lowercase!
KTWK_BM_excluded = [
    "sefrouramal",
    "dingor",
    "optre_eridanussecundus",
    "optre_phobos",
    "chernarus_winter",
    "swu_public_salman_map",
    "uzbin"
];
if ("juju_" in worldName) then {KTWK_BM_excluded pushBack toLowerANSI worldName};

KTWK_BM_altPpEffect_darker = [
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
];

KTWK_BM_noAperture = [
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
];
if ("swu_public_" in worldName) then {KTWK_BM_noAperture pushBack toLowerANSI worldName};

KTWK_BM_altAperture_narrow = [
    "rhspkl",
    "cam_lao_nam"
];

KTWK_BM_altAperture_mid = [
    "enoch",
    "edaly_map_alpha",
    "vn_khe_sanh"
];

KTWK_BM_altAperture_wide = [
    "brf_sumava",
    "tem_ihantala",
    "hellanmaa",
    "gm_weferlingen_summer",
    "bornholm"
];

KTWK_BM_altAperture_ultraWide = [];
