// overlayOverride.hpp
// Removes vanilla NVG overlays

class CfgWeapons {
    class Binocular;
    class NVGoggles: Binocular {
        modelOptics = "";
    };
    class O_NVGoggles_hex_F: NVGoggles {
        modelOptics = "";
    };
    class O_NVGoggles_urb_F: O_NVGoggles_hex_F {
        modelOptics = "";
    };
    class O_NVGoggles_ghex_F: O_NVGoggles_hex_F {
        modelOptics = "";
    };
    class NVGoggles_OPFOR: NVGoggles {
        modelOptics = "";
    };
    class NVGoggles_INDEP: NVGoggles {
        modelOptics = "";
    };
    class NVGogglesB_blk_F: NVGoggles {
        modelOptics = "";
    };
    class NVGogglesB_grn_F: NVGoggles {
        modelOptics = "";
    };
    class NVGogglesB_gry_F: NVGoggles {
        modelOptics = "";
    };
};
