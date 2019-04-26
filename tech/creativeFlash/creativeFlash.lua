require "/scripts/keybinds.lua" -- Thanks Silverfeelin!

function init()
  Bind.create("specialOne", function(args)
    --Should I make it so you cannot TP into a wall?
    mcontroller.setPosition(tech.aimPosition())
    --add effects to make it look nice.
  end)
end
