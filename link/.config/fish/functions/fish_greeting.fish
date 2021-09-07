function fish_greeting --description 'Print message at startup'
	if	begin
			which fortune > /dev/null
			and not test -z $TMUX
		end
		fortune -as
	end
end
