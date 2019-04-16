function init()
  self.dashCooldown = 0.8
  self.dashCooldownTimer = 0
  self.dashTimer = 0
end

function update(args)
  if args.moves["special1"] and self.dashTimer == 0 then
    mcontroller.setPosition(tech.aimPosition())
    self.dashTimer = 0.1
  end
  self.dashTimer = math.max(0, self.dashTimer - args.dt)
end
