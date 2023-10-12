// AI will defend from predators
// by kenoxite

KTWK_allPredators = KTWK_allAnimals select {_x isKindOf "Edaly_Crocodile_Base"};
{
    if !(_x getVariable ["KTWK_predatorInit", false]) then {
        _x setVariable ["KTWK_predatorInit", true, true];
        
        // Exclude already captives, supposedly done on purpose in the editor or script to exclude this particular predator from all this
        if (captive _x) then { continue };

        // Set predator as renegade but switch to CIV side for the time being
        _x addRating -10000;
        _x setCaptive true;

        // Give rating back to killer, to not become renegade after successive kills
        _x addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            if (!isNull _instigator) then { _instigator addRating 1000 };
        }];

        // Set to aggressive if predator gets damaged by someone, so other units can join in and further attackers won't get flagged as renegades if they kill it
        _x addEventHandler ["HandleDamage", {
            params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit"];
            if (!isNull _instigator) then { _unit setCaptive false };
        }];

        // Allow AI units to defend if predator gets too close to another infantry AI or player
        _x spawn {
            params ["_pred"];
            while {alive _pred} do {
                if (KTWK_opt_AIPredDefense_enable && {captive _pred}) then {
                    private _target = ((_pred targets [true, KTWK_opt_AIPredDefense_dist]) select {typeOf _x != typeOf _pred})#0;
                    // Predator approaching and dangerous
                    if (!isNil {_target}) then {
                        _pred setCaptive false;
                    };
                };
                sleep 1;
            };
        };
    };
} foreach KTWK_allPredators;
