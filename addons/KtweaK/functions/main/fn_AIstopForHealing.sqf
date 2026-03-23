// AI stop for Healing
// by kenoxite

params ["_injured", "_healer"];
// Only apply when healer is a player or a player controlled unit and also if injured unit is local to the player
private _players = allPlayers - entities "HeadlessClient_F";
if (isPlayer _injured || {!(_healer in _players) && !(remoteControlled _healer in _players)}) exitwith {};
_this spawn {
    params ["_injured", "_healer"];
    private _damage = damage _injured;
    private _startTime = time;
    [_injured, "MOVE"] remoteExecCall ["disableAI", _injured, true];
    waitUntil {sleep 1; damage _injured != _damage || !alive _injured || !alive _healer || (time - _startTime) > 30};
    [_injured, "MOVE"] remoteExecCall ["enableAI", _injured, true];
    // Add some mission rating to the player to reward being an active healer, based on amount healed
    if (damage _injured != _damage) then {
        [_healer, (round (200 * _damage))] remoteExec ["addRating", _healer];
    };
};
