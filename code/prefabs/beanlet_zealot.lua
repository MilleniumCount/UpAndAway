BindGlobal()

local assets =
{
    Asset("ANIM", "anim/beanlet_zealot.zip"),  -- same name as the .scml
    Asset("SOUND", "sound/pengull.fsb"),
}

local prefabs =
{
   "greenbean",
   "beanlet_shell",
}

SetSharedLootTable( 'beanlet',
{
    {'greenbean',       1.00},
    {'greenbean',       0.90},
    {'greenbean',       0.80},
    {'greenbean',       0.70},
    {'beanlet_shell',   0.33},
})

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function OnHit(inst, attacker, damage)
    if attacker and attacker.prefab == bean_giant then
        damage = 0
    end 
    return damage   
end    

local function RetargetFn(inst)
    return FindEntity(inst, 8, function(guy)
        return inst.components.combat:CanTarget(guy)
               and not guy:HasTag("beanlet")
               and not guy:HasTag("beanmonster")
    end)
end

local function OnAttacked(inst, data)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30, {'beanlet'})
    
    local num_friends = 0
    local maxnum = 5
    for k,v in pairs(ents) do
        v:PushEvent("gohome")
        num_friends = num_friends + 1
        
        if num_friends > maxnum then
            break
        end
    end    

    if not GetPlayer().bean_hate then
        GetPlayer().bean_hate = 0
    end    

    GetPlayer().bean_hate = GetPlayer().bean_hate+1

    print(GetPlayer().bean_hate)

    if GetPlayer().bean_hate and GetPlayer().bean_hate == 5 then
        SpawnPrefab("bean_giant").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end    

    local attacker = data.attacker

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("zealot") end, MAX_TARGET_SHARES)
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
    local sound = inst.entity:AddSoundEmitter()
    --inst.Transform:SetTwoFaced()

    local brain = require "brains/beanletzealotbrain"
    inst:SetBrain(brain)

    MakeCharacterPhysics(inst, 50, .5)  

    inst.AnimState:SetBank("beanlet_zealot") -- name of the animation root
    inst.AnimState:SetBuild("beanlet_zealot")  -- name of the file
    inst.AnimState:PlayAnimation("idle", true) -- name of the animation

    inst:AddTag("animal")
    inst:AddTag("smallcreature")
    inst:AddTag("beanlet")
    inst:AddTag("zealot")

    inst:AddComponent("knownlocations")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 5
    inst:SetStateGraph("SGbeanlet")

    inst.Transform:SetScale(1.4, 1.4, 1.4)

    inst.data = {}  

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(35)
    inst.components.combat:SetAttackPeriod(TUNING.PIG_GUARD_ATTACK_PERIOD)
    inst.components.combat:SetOnHit(OnHit)

    inst:RemoveComponent("burnable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(150)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('beanlet')

    inst:AddComponent("inspectable")

    inst:ListenForEvent("attacked", OnAttacked) 
    inst.components.combat:SetRetargetFunction(2, RetargetFn)  

    --inst:DoPeriodicTask(0, function(inst) inst.AnimState:PlayAnimation("idle") end)     
    
    return inst
end

return Prefab("common/beanlet_zealot", fn, assets, prefabs) 