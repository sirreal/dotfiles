function allupdate --description 'System update'
	begin
		if	begin
				which apt-get > /dev/null
				and test -x (which apt-get)
			end
			sudo apt-get update -qq
			sudo apt-get upgrade -yqqu
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
			if test -w (npm config get prefix --global)/lib
				function _allupdate_CMD; npm $argv; end
			else
				function _allupdate_CMD; sudo npm $argv; end
			end
			for p in (npm -g outdated --parseable --depth=0 | cut -d: -f2)
				_allupdate_CMD -g i "$p"
			end
			functions -e _allupdate_CMD
		end
	end
end
