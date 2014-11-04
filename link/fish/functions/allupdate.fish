function allupdate --description 'System update'
	if test -x (which apt-get)
		and test -x (which apt-get)
		echo "apt found"
		sudo apt-get update -qq
		sudo apt-get upgrade -y -q
	end
	if test (which brew)
		and test -x (which brew)
		echo "brew found"
		brew update
		brew upgrade
	end
	if test (which npm)
		and test -x (which npm)
		echo "npm found"
		for p in (npm -g outdated --parseable --depth=0 | cut -d: -f2)
			npm -g i "$p"
		end
	end
end
