KTWK_BN_set = false;
KTWK_BN_lastOption = KTWK_BN_opt_enabled;

// All terrain names must be lowercase!
// Ctrl+k Ctrl+l if using Sublime Text
KTWK_BN_excluded = [
    "sefrouramal",
    "dingor",
    "optre_eridanussecundus",
    "optre_phobos",
    "chernarus_winter",
    "swu_public_salman_map"
];
if ("juju_" in worldName) then {KTWK_BN_excluded pushBack toLowerAnsi worldName};

KTWK_BN_altPpEffect_darker = [
    // "altis",
    // "stratis",
    // "malden",
    "ruha",
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

KTWK_BN_noAperture = [
    // "altis",
    // "stratis",
    // "malden",
    // "tanoa",
    // "utes",
    // "chernarus",
    // "chernarus_summer",
    // "cup_chernarus_a3",
    // "sara",
    // "saralite",
    // "sara_dbe1",
    // "bootcamp_acr",
    // "takistan",
    // "mountains_acr",
    // "abel",
    "egl_gliese581xsouth",
    "egl_gliese581xeast",
    "egl_gliese581xnorth",
    "vn_the_bra",
    // "bozoum",
    "lythium",
    "cartercity",
    "cartercity_old",
    "zargabad",
    "farabad",
    // "tem_ihantala",
    // "islapera",
    "tem_kujari",
    // "beketov",   // only necessary with livonian lighting
    "cam_lao_nam"
];
if ("swu_public_" in worldName) then {KTWK_BN_noAperture pushBack toLowerAnsi worldName};

KTWK_BN_altAperture_narrow = [
    // "vtf_korsac",
    // "vtf_lybor",
    "rhspkl"
];

KTWK_BN_altAperture_mid = [
    "enoch",
    "edaly_map_alpha"
];

KTWK_BN_altAperture_wide = [
    "brf_sumava",
    "tem_ihantala",
    "hellanmaa",
    // "vt7",
    "gm_weferlingen_summer",
    "bornholm"  // original, not revamped
];

KTWK_BN_altAperture_ultraWide = [
    // "tem_vinjesvingenc" // still too dark in summer and too bright in winter
];
