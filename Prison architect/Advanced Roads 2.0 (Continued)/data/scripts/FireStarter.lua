
function Create()
end

function Update( timePassed )
    local x = this.Pos.x
	local y = this.Pos.y
	
    for i = -1, 1 do
        for j = -1, 1 do
            local fire = Object.Spawn("Fire", x + i, y + j)
        end
    end
	
	this.Delete()
end
