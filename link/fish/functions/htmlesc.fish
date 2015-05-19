function htmlesc --description 'escape html stdin via php'
	php -r 'echo htmlspecialchars(file_get_contents("php://stdin"));'
end
