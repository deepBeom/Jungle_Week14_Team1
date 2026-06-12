local EnergyBullet = {
    ParticlePath = "Content/Particle/EnergyBullet.uasset",
    Lifetime = 0.35,
    SourceParameter = "BeamSource",
    TargetParameter = "BeamEnd",
}

local function is_valid_actor(actor)
    if actor == nil then
        return false
    end
    if type(actor.IsValid) == "function" then
        return actor:IsValid()
    end
    return true
end

local function get_particle(actor)
    if actor == nil or type(actor.GetParticleSystem) ~= "function" then
        return nil
    end

    return actor:GetParticleSystem()
end

local function apply_beam_parameters(particle, source, target)
    if particle == nil then
        return
    end

    if source ~= nil then
        particle:SetVectorParameter(EnergyBullet.SourceParameter, source)
    end
    if target ~= nil then
        particle:SetVectorParameter(EnergyBullet.TargetParameter, target)
    end
end

function EnergyBullet.Play(source, target)
    if source == nil or target == nil or World == nil or World.SpawnParticleSystem == nil then
        return nil
    end

    local actor = World.SpawnParticleSystem(EnergyBullet.ParticlePath, source)
    if actor == nil then
        return nil
    end

    actor:AddTag("runtime-energy-bullet")

    local particle = get_particle(actor)
    if particle ~= nil then
        apply_beam_parameters(particle, source, target)
        particle:ResetSystem()
        particle:SetEmitterSpawningEnabled(true)
        particle:Activate()
    end

    return actor
end

function EnergyBullet.PlayInto(activeList, source, target, sourceProvider, targetProvider)
    local actor = EnergyBullet.Play(source, target)
    if actor == nil then
        return nil
    end

    activeList[#activeList + 1] = {
        Actor = actor,
        Remaining = EnergyBullet.Lifetime,
        Source = source,
        Target = target,
        SourceProvider = sourceProvider,
        TargetProvider = targetProvider,
    }
    return actor
end

function EnergyBullet.TickActive(activeList, dt)
    for index = #activeList, 1, -1 do
        local entry = activeList[index]
        if not is_valid_actor(entry.Actor) then
            table.remove(activeList, index)
        else
            entry.Remaining = entry.Remaining - dt
            if entry.Remaining <= 0.0 then
                entry.Actor:Destroy()
                table.remove(activeList, index)
            else
                local source = entry.Source
                local target = entry.Target
                if type(entry.SourceProvider) == "function" then
                    source = entry.SourceProvider() or source
                end
                if type(entry.TargetProvider) == "function" then
                    target = entry.TargetProvider() or target
                end

                entry.Source = source
                entry.Target = target
                apply_beam_parameters(get_particle(entry.Actor), source, target)
            end
        end
    end
end

function EnergyBullet.DestroyActive(activeList)
    for _, entry in ipairs(activeList) do
        if is_valid_actor(entry.Actor) then
            entry.Actor:Destroy()
        end
    end

    for index = #activeList, 1, -1 do
        activeList[index] = nil
    end
end

return EnergyBullet
