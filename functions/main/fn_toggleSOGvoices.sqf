// Toggle SOG voices
// by kenoxite and johnnyboy

if (isNil {vn_sam_masteraudioarray}) exitwith {false};
if (isNil {KTWK_vn_sam_masteraudioarray}) then { KTWK_vn_sam_masteraudioarray = +vn_sam_masteraudioarray };

// US voices
private _USvoices1 = vn_sam_masteraudioarray#1;
private _USvoices2 = vn_sam_masteraudioarray#2;
private _USvoices3 = vn_sam_masteraudioarray#3;
call {
    // Enable all
    if (KTWK_toggleVoices_opt_SOG_US == 0) exitWith {
        { vn_sam_masteraudioarray set [_x, +(KTWK_vn_sam_masteraudioarray #_x)]; } count [1,2,3];
    };
    // Disable all but screams
    if (KTWK_toggleVoices_opt_SOG_US == 1) exitWith {        
        { _USvoices1 set [_x, []]; } count [0,1,2,3]; // Disable others
        { _USvoices1 set [_x, +((KTWK_vn_sam_masteraudioarray#1) #_x)]; } count [4,5]; // Enable screams

        { _USvoices2 set [_x, []]; } count [0,1,2,3,4,5]; // Disable others
        _USvoices2 set [6, +((KTWK_vn_sam_masteraudioarray#2) #6)]; // Enable screams

        { _USvoices3 set [_x, []]; } count [0,1,2,3,4,5]; // Disable others
        _USvoices3 set [6, +((KTWK_vn_sam_masteraudioarray#3) #6)]; // Enable screams
    };
    // Disable all
    if (KTWK_toggleVoices_opt_SOG_US == 2) exitWith {
        for "_i" from 0 to (count _USvoices1 - 1) do {
            _USvoices1 set [_i, []];
        };
        for "_i" from 0 to (count _USvoices2 - 1) do {
            _USvoices2 set [_i, []];
        };
        for "_i" from 0 to (count _USvoices3 - 1) do {
            _USvoices3 set [_i, []];
        };
    };
};

// AU voices
private _AUvoices = vn_sam_masteraudioarray#4;
call {
    // Enable all
    if (KTWK_toggleVoices_opt_SOG_AU == 0) exitWith {
        vn_sam_masteraudioarray set [4, +(KTWK_vn_sam_masteraudioarray#4)];
    };
    // Disable all but screams
    if (KTWK_toggleVoices_opt_SOG_AU == 1) exitWith {
        { _AUvoices set [_x, []]; } count [0,1,2,3]; // Disable others
        { _AUvoices set [_x, +((KTWK_vn_sam_masteraudioarray#4) #_x)]; } count [4,5,6]; // Enable screams
    };
    // Disable all
    if (KTWK_toggleVoices_opt_SOG_AU == 2) exitWith {
        for "_i" from 0 to (count _AUvoices - 1) do {
            _AUvoices set [_i, []];
        };
    };
};

// NZ voices
private _NZvoices = vn_sam_masteraudioarray#5;
call {
    // Enable all
    if (KTWK_toggleVoices_opt_SOG_NZ == 0) exitWith {
        vn_sam_masteraudioarray set [5, +(KTWK_vn_sam_masteraudioarray#5)];
    };
    // Disable all but screams
    if (KTWK_toggleVoices_opt_SOG_NZ == 1) exitWith {
        { _NZvoices set [_x, []]; } count [0,1,2,3]; // Disable others
        { _NZvoices set [_x, +((KTWK_vn_sam_masteraudioarray#5) #_x)]; } count [4,5,6]; // Enable screams
    };
    // Disable all
    if (KTWK_toggleVoices_opt_SOG_NZ == 2) exitWith {
        for "_i" from 0 to (count _NZvoices - 1) do {
            _NZvoices set [_i, []];
        };
    };
};
