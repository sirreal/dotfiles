function fish_greeting --description 'Print message at startup'
	if not test -z $TMUX
		fortune -a
	end
end
