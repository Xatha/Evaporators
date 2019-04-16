function init()
  self.active = false
  self.flyModifier = 2
  self.doubleTapTimer = 0
  self.lastMoves = {}

  self.energyPerSecond = config.getParameter("energyCostPerSecond")
  self.techType = config.getParameter("type")
end

function update(args)
  input(args)
  if self.active and status.overConsumeResource("energy", 0.1) then
    tech.setParentState()
    flyControls(args)
    flyAnimation(args)
    status.addEphemeralEffect("nofalldamage", math.huge)
  end

  if mcontroller.groundMovement() or mcontroller.liquidMovement() then
    status.removeEphemeralEffect("nofalldamage")
    tech.setParentState()
  end
end

function input(args)
-- hover mode initiation
  if args.moves["up"] then
    if not self.lastMoves["up"] then
      if self.doubleTapTimer <= 0 then
        self.doubleTapTimer = 0.35
      else
        if self.active then
          self.active = false
        elseif not status.resourceLocked("energy") then
          self.active = true
        end
        self.doubleTapTimer = 0
      end
    end
  end
-- fly mode initiation
  if args.moves["special1"] then
    if not self.lastMoves["special1"] then
      if self.flyModifier == 2 then
        self.flyModifier = 1
      else
        self.flyModifier = 2
      end
    end
  end
  self.lastMoves = args.moves --hold on to old buttons to determine if they're being held
end

function flyControls(args)
  --basic controls
  if flying() and
  not args.moves["left"] and
  not args.moves["right"] then
    mcontroller.setXVelocity(0) --makes sure you dont "float" when flying,
  end

  if not args.moves["right"] and flying() then
    mcontroller.setXVelocity(0)
  end

  if args.moves["left"] and flying() then --left controls
    mcontroller.controlParameters({gravityEnabled = false}) --makes the flying have more weight
    mcontroller.setXVelocity(-10 * self.flyModifier)
    mcontroller.setYVelocity(-0.5)
    status.consumeResource("energy", 0.2 * self.flyModifier)
  end

  if args.moves["right"] and flying() then --right controls
    mcontroller.controlParameters({gravityEnabled = false})
    mcontroller.setXVelocity(10 * self.flyModifier)
    mcontroller.setYVelocity(-0.5)
    status.consumeResource("energy", 0.2 * self.flyModifier)
  end

  if args.moves["jump"] then --spacebar controls
    mcontroller.controlParameters({gravityEnabled = false})
    mcontroller.setYVelocity(15 * self.flyModifier)
    status.consumeResource("energy", 0.5 * self.flyModifier)
  elseif not args.moves["jump"] then
    tech.setParentState("fall")
    if self.flyModifier == 1 then
      mcontroller.setYVelocity(-2)
    else
      mcontroller.setYVelocity(-2.5 * (self.flyModifier * 2)) -- makes it so you glide down, instead of falling fastly
    end
  end

  if flying()
     and not args.moves["jump"]
     and not args.moves["left"]
     and not args.moves["right"] then
       status.giveResource("energy", 0.1)
     end
end

function flyAnimation(args)
  if args.moves["left"] and flying() then
    tech.setParentState("fly")
    animator.burstParticleEmitter("rocketParticles1") -- Replace particle, so it bursts to the left
  end

  if args.moves["right"] and flying() then
    tech.setParentState("fly")
    animator.burstParticleEmitter("rocketParticles1") -- Replace particle, so it bursts to the right
  end

  if args.moves["jump"] and flying() then
    tech.setParentState("fall")
    animator.burstParticleEmitter("rocketParticles1") -- Replace with own particle
  end

  if not flying()
     and not args.moves["jump"]
     and not args.moves["left"]
     and not args.moves["right"] then
       tech.setParentState()
       status.giveResource("energy", 0.1)
  end
end

function flying()
  if mcontroller.groundMovement() or mcontroller.liquidMovement() then
    return false
  elseif not mcontroller.groundMovement() or mcontroller.liquidMovement() then
    return true
  end
end

function uninit()
  self.active = false
  animator.setParticleEmitterActive("rocketParticles1", false)
  tech.setParentState()
end
