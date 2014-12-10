--FIXME: not MP compatible
BindGlobal()

local AlchemyRecipeBook = modrequire 'resources.alchemy_recipebook'

local assets =
{
	Asset("ANIM", "anim/cauldron.zip"),
}

local slotpos = {
	Vector3(0,64+32+8+4,0), 
	Vector3(0,32+4,0),
	Vector3(0,-(32+4),0), 
	Vector3(0,-(64+32+8+4),0)
}

local widgetbuttoninfo = {
	text = "Brew",
	position = Vector3(0, -165, 0),
	fn = function(inst)
		inst.components.brewer:StartBrewing( GetPlayer() )	
	end,
		
	validfn = function(inst)
		return inst.components.brewer:CanBrew()
	end,
}

local function itemtest(inst, item, slot)
	return (item:HasTag("alchemy"))
		or item.components.edible
        or item.prefab == "bonestew"
        or item.prefab == "cloud_jelly"
        or item.prefab == "jellycap_red"
        or item.prefab == "jellycap_blue"
        or item.prefab == "jellycap_green"
        or item.prefab == "golden_petals"	
        or item.prefab == "nightmarefuel"
        or item.prefab == "rocks"
        or item.prefab == "marble"
        or item.prefab == "poop"
        or item.prefab == "beardhair"
        or item.prefab == "dragonblood_log"
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("cauldron")
	inst.AnimState:SetBuild("cauldron")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("brewer")
	do
		local brewer = inst.components.brewer

		brewer:SetRecipeBook(AlchemyRecipeBook)
	end

	inst:AddComponent("inspectable")
		
	inst:AddComponent("container")
	inst.components.container.itemtestfn = itemtest
	inst.components.container:SetNumSlots(4)
	inst.components.container.widgetslotpos = slotpos
	inst.components.container.widgetanimbank = "ui_cookpot_1x4"
	inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
	inst.components.container.widgetpos = Vector3(200,0,0)
	inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.acceptsstacks = false

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("cauldron.tex")	

	--container.onopenfn = onopen
	--container.onclosefn = onclose

	return inst
end

return Prefab ("common/inventory/cauldron", fn, assets) 
