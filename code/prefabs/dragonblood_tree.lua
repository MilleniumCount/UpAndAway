BindGlobal()

local assets =
{
	Asset("ANIM", "anim/cave_banana_tree.zip"),
}

local prefabs =
{
	"dragonblood_sap",
	"log",
}

local function chopped(inst)
	--
end

local function chop(inst)
	--
end

local loot = 
{
    "log",
	"log",
	"log",
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cave_banana_tree")
    inst.AnimState:SetBuild("cave_banana_tree")
	inst.AnimState:PlayAnimation("idle_loop", true)

	inst:AddComponent("inspectable")

	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(chopped)
    inst.components.workable:SetOnWorkCallback(chop)	

   	inst:AddComponent("lootdropper") 
   	inst.components.lootdropper:SetLoot(loot) 

	return inst
end

return Prefab ("common/inventory/dragonblood_tree", fn, assets, prefabs) 