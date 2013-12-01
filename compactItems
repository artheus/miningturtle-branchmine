for i=1,16 do
	if turtle.getItemCount(i) > 0 then
		turtle.select(i)
		for x=i+1,16 do
			print(i.." : "..x)
			if turtle.compareTo(x) then
				turtle.transferTo(x, turtle.getItemSpace(x))
				if turtle.getItemCount(i) == 0 then break end
			end
		end
	end		
end
