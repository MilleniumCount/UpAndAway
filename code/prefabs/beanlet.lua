BindGlobal()

local assets =
{
	Asset("ANIM", "anim/beanlet.zip"),  -- same name as the .scml
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

local function OnIgnite(inst)
    DefaultBurnFn(inst)
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

    if GetPlayer().bean_hate and GetPlayer().bean_hate == 10 then
        SpawnPrefab("bean_giant").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end    
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
    local sound = inst.entity:AddSoundEmitter()
    inst.Transform:SetTwoFaced()

    local brain = require "brains/beanletbrain"
    inst:SetBrain(brain)

    MakeCharacterPhysics(inst, 50, .5)  

    local scale = 1
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBank("beanlet") -- name of the animation root
    inst.AnimState:SetBuild("beanlet")  -- name of the file
    inst.AnimState:PlayAnimation("idle", true) -- name of the animation

    inst:AddTag("animal")
    inst:AddTag("smallcreature")
    inst:AddTag("beanlet")

    inst:AddComponent("knownlocations")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6
    inst:SetStateGraph("SGbeanlet")

    inst.data = {}  

    inst:AddComponent("combat")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(80)

    MakeMediumBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('beanlet')

    inst:AddComponent("inspectable")

    inst:ListenForEvent("attacked", OnAttacked)

    --inst:DoPeriodicTask(0, function(inst) inst.AnimState:PlayAnimation("idle") end)        
	
    return inst
end

return Prefab("common/beanlet", fn, assets, prefabs) 