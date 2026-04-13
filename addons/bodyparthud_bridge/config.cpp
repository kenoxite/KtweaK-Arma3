#include "\z\ktweak\addons\bodyparthud_bridge\version.hpp"

class CfgPatches {
    class ktweak_bodyparthud_bridge {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {
            "ktweak_main",
            "ktweak_bodyparthud"
        };
        skipWhenMissingDependencies = 1; 
        author = "kenoxite";
        authors[] = {"kenoxite"};
        url = "";
        version = VERSION;
        versionStr = VERSION_STR;
        versionAr[] = {VERSION_AR};
    };
};
