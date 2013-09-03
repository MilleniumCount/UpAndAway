local assets =
{
	Asset("ANIM", "anim/berrybush.zip"),
}

local prefabs = 
{
    "cloud_cotton",
    "dug_marsh_bush",
}

local function ontransplantfn(inst)
	inst.components.pickable:MakeEmpty()
end

local function dig_up(inst, chopper)
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		inst.components.lootdropper:SpawnLootPrefab("cloud_cotton")
	end
	inst:Remove()
	local bush = inst.components.lootdropper:SpawnLootPrefab("dug_marsh_bush")
end

local function onpickedfn(inst, picker)
	inst.AnimState:PlayAnimation("picking") 
	inst.AnimState:PushAnimation("picked", false)
	--[[
	if picker.components.combat then
        picker.components.combat:GetAttacked(nil, TUNING.MARSHBUSH_DAMAGE)
	end
	--]]
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow") 
	inst.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("idle_dead")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBuild("berrybush")
    anim:SetBank("berrybush")
	anim:PlayAnimation("empty")
    --anim:PlayAnimation("idle", true)
    anim:SetTime(math.random()*2)

    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    
    inst.components.pickable:SetUp("cloud_cotton", TUNING.MARSHBUSH_REGROW_TIME)
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.ontransplantfn = ontransplantfn

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)
    
    inst:AddComponent("inspectable")
    
    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)

    return inst
end

return Prefab( "marsh/objects/cloud_bush", fn, assets, prefabs) 