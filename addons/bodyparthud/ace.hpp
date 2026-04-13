// Bodypart HUD - ACE Medical Definitions

#define ALL_BODY_PARTS ["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"]
#define ALL_SELECTIONS ["head", "body", "hand_l", "hand_r", "leg_l", "leg_r"]
#define ALL_HITPOINTS ["HitHead", "HitChest", "HitLeftArm", "HitRightArm", "HitLeftLeg", "HitRightLeg"]

#define HITPOINT_INDEX_HEAD 0
#define HITPOINT_INDEX_BODY 1
#define HITPOINT_INDEX_LARM 2
#define HITPOINT_INDEX_RARM 3
#define HITPOINT_INDEX_LLEG 4
#define HITPOINT_INDEX_RLEG 5

#define LIMPING_DAMAGE_THRESHOLD ace_medical_const_limpingDamageThreshold
#define FRACTURE_DAMAGE_THRESHOLD ace_medical_const_fractureDamageThreshold

#define VAR_OPEN_WOUNDS "ace_medical_openWounds"

#define GET_OPEN_WOUNDS(unit) (unit getVariable [VAR_OPEN_WOUNDS, createHashMap])
#define GET_DAMAGE_THRESHOLD(unit) (unit getVariable ["ace_medical_damageThreshold", [ace_medical_AIDamageThreshold, ace_medical_playerDamageThreshold] select (isPlayer unit)])
