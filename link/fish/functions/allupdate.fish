function allupdate --description 'System update'
	begin
		if	begin
			which apt-get > /dev/null
			and test -x (which apt-get)
		end
			sudo apt-get update -qq
			sudo apt-get upgrade -y -qq
		end
		if	begin
				which brew > /dev/null
				and test -x (which brew)
			end
			brew update
			brew upgrade
		end
		if	begin
			which npm > /dev/null
			and test -x (which npm)
		end
			for p in (npm -g outdated --parseable --depth=0 | cut -d: -f2)
				npm -g i "$p"
			end
		end
	end
end
