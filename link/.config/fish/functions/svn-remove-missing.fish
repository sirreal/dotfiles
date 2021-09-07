function svn-remove-missing --description 'Remove missing (!) file from svn repo.'
	svn rm (svn st | grep '^!' | cut -c 9-)
end
