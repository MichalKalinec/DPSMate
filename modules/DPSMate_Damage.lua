-- Global Variables
DPSMate.Modules.Damage = {}
DPSMate.Modules.Damage.Hist = "DMGDone"
DPSMate.Options.Options[1]["args"]["damage"] = {
	order = 20,
	type = 'toggle',
	name = DPSMate.localization.config.damage,
	desc = "Show Damage.",
	get = function() return DPSMateSettings["windows"][DPSMate.Options.Dewdrop:GetOpenedParent().Key]["options"][1]["damage"] end,
	set = function() DPSMate.Options:ToggleDrewDrop(1, "damage", DPSMate.Options.Dewdrop:GetOpenedParent()) end,
}

-- Register the moodule
DPSMate:Register("damage", DPSMate.Modules.Damage, "Damage")


function DPSMate.Modules.Damage:GetSortedTable(arr, k)
	local b, a, total = {}, {}, 0
	for cat, val in pairs(arr) do
		local name = DPSMate:GetUserById(cat)
		if (not DPSMateUser[name][4]) then
			if DPSMate:ApplyFilter(k, name) then
				local CV = val["i"][2]
				if DPSMate:PlayerExist(DPSMateUser, DPSMateUser[name][5]) and arr[DPSMateUser[DPSMateUser[name][5]][1]] then
					CV=CV+arr[DPSMateUser[DPSMateUser[name][5]][1]]["i"][2]
				end
				local i = 1
				while true do
					if (not b[i]) then
						table.insert(b, i, CV)
						table.insert(a, i, name)
						break
					else
						if b[i] < CV then
							table.insert(b, i, CV)
							table.insert(a, i, name)
							break
						end
					end
					i=i+1
				end
				total = total + CV
			end
		end
	end
	return b, total, a
end

function DPSMate.Modules.Damage:EvalTable(user, k)
	local a, u, p, d, total, pet = {}, {}, {}, {}, 0, false
	local arr = DPSMate:GetMode(k)
	if not arr[user[1]] then return end
	if (user[5] and user[5] ~= "Unknown" and arr[DPSMateUser[user[5]][1]]) then u={user[1],DPSMateUser[user[5]][1]} else u={user[1]} end
	for _, v in pairs(u) do
		for cat, val in pairs(arr[v]) do
			if (type(val) == "table" and cat~="i") then
				if val[13]~=0 and cat~="" then
					if (DPSMateUser[DPSMate:GetUserById(v)][4]) then pet=true; else pet=false; end
					local i = 1
					while true do
						if (not d[i]) then
							table.insert(a, i, cat)
							table.insert(d, i, {val[13], pet})
							break
						else
							if (d[i][1] < val[13]) then
								table.insert(a, i, cat)
								table.insert(d, i, {val[13], pet})
								break
							end
						end
						i = i + 1
					end
				end
			end
		end
		total=total+arr[v]["i"][2]
	end
	return a, total, d
end

DPSMate.Modules.Damage.v1 = DPSMate.localization.g
DPSMate.Modules.Damage.v2 = DPSMate.localization.p

function DPSMate.Modules.Damage:IsValue(s)
	local v = ""
	for i=1, string.len(s or "") do
		v = v..string.byte(s,i,i)
	end
	return tonumber(v)
end

function DPSMate.Modules.Damage:CompareValues(a,b)
	if DPSMate:TContains(DPSMate.Modules.Damage.v1, DPSMate.Modules.Damage:IsValue(b)) or DPSMate:TContains(DPSMate.Modules.Damage.v2, DPSMate.Modules.Damage:IsValue(a)) then
		return true
	end
	return false
end

function DPSMate.Modules.Damage:GetSettingValues(arr, cbt, k)
	if not DPSMate.Modules.Damage:CompareValues(DPSMate.Modules.Damage.v3(DPSMate.Modules.Damage.v5),DPSMate.Modules.Damage.v4(DPSMate.Modules.Damage.v5)) then return end
	local name, value, perc, sortedTable, total, a, p, strt = {}, {}, {}, {}, 0, 0, "", {[1]="",[2]=""}
	if DPSMateSettings["windows"][k]["numberformat"] == 2 then p = "K" end
	sortedTable, total, a = DPSMate.Modules.Damage:GetSortedTable(arr, k)
	for cat, val in pairs(sortedTable) do
		local dmg, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
		if dmg==0 then break end
		local str = {[1]="",[2]="",[3]=""}
		if DPSMateSettings["columnsdmg"][1] then str[1] = " "..dmg..p; strt[2] = tot..p end
		if DPSMateSettings["columnsdmg"][2] then str[2] = "("..string.format("%.1f", (dmg/cbt))..p..")"; strt[1] = "("..string.format("%.1f", (tot/cbt))..p..") " end
		if DPSMateSettings["columnsdmg"][3] then str[3] = " ("..string.format("%.1f", 100*dmg/tot).."%)" end
		table.insert(name, a[cat])
		table.insert(value, str[2]..str[1]..str[3])
		table.insert(perc, 100*(dmg/sort))
	end
	return name, value, perc, strt
end

DPSMate.Modules.Damage.v3 = DPSMate.localization.rgb

function DPSMate.Modules.Damage:ShowTooltip(user,k)
	local a,b,c = DPSMate.Modules.Damage:EvalTable(DPSMateUser[user], k)
	local pet = ""
	if DPSMateSettings["informativetooltips"] then
		for i=1, DPSMateSettings["subviewrows"] do
			if not a[i] then break end
			if c[i][2] then pet="(Pet)" else pet="" end
			GameTooltip:AddDoubleLine(i..". "..DPSMate:GetAbilityById(a[i])..pet,c[i][1].." ("..string.format("%.2f", 100*c[i][1]/b).."%)",1,1,1,1,1,1)
		end
	end
end

DPSMate.Modules.Damage.v4 = DPSMate.localization.hex

function DPSMate.Modules.Damage:OpenDetails(obj, key)
	DPSMate.Modules.DetailsDamage:UpdateDetails(obj, key)
end

DPSMate.Modules.Damage.v5 = DPSMate.localization.frame

function DPSMate.Modules.Damage:OpenTotalDetails(obj, key)
	DPSMate.Modules.DetailsDamageTotal:UpdateDetails(obj, key)
end
