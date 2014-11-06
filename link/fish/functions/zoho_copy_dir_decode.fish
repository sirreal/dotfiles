function zoho_copy_dir_decode --description 'Copies all php files in a directory and decodes them'
	
	for f in {$argv[1]}/*.php
		set -l bn (basename $f)
		cp $f ./(echo $bn | sed s/\.php\$/.enc.php/)
	end

	# Remove the "require" code
	sed -i s/'eval(base64_decode("cmVxdWlyZV9vbmNlIE1hZ2U6OmdldEJhc2VEaXIoKSAuIERTIC4gJ2FwcCcgLiBEUyAuICdjb2RlJyAuIERTIC4gJ2xvY2FsJyAuIERTIC4gJ0NSTTRFY29tbWVyY2UnIC4gRFMgLiAnQ1JNQ29yZScgLiBEUyAuICdIZWxwZXInIC4gRFMgLiAnRW5jb2RlLnBocCc7"));'//g *.enc.php

	# Turn evals into echos + newline
	sed -i s/'eval('/"\necho("/g *.enc.php

	# Insert decoder function
	sed -i '2i function melonkat9a2d8ce3ffdcdf2123bddd94d79ef200($melonkat4ad6ef6a04056e205d412514711096a1, $melonkatc64a4c21de6cc1b64744c7329983244f = 16) {$melonkat5f4dcc3b5aa765d61d8327deb882cf99 = \'07931691ca5e63c136fbb143537b8e0b\';$melonkat4ad6ef6a04056e205d412514711096a1 = base64_decode($melonkat4ad6ef6a04056e205d412514711096a1);$n = strlen($melonkat4ad6ef6a04056e205d412514711096a1);$i = $melonkatc64a4c21de6cc1b64744c7329983244f;$melonkat10504904240f7c7a24587ef9209b3f55 = \'\';$melonkatf0b53b2da041fca49ef0b9839060b345 = substr($melonkat5f4dcc3b5aa765d61d8327deb882cf99 ^ substr($melonkat4ad6ef6a04056e205d412514711096a1, 0, $melonkatc64a4c21de6cc1b64744c7329983244f), 0, 512);while ($i < $n) {$melonkat14511f2f5564650d129ca7cabc333278 = substr($melonkat4ad6ef6a04056e205d412514711096a1, $i, 16);$melonkat10504904240f7c7a24587ef9209b3f55 .= $melonkat14511f2f5564650d129ca7cabc333278 ^ pack(\'H*\', sha1($melonkatf0b53b2da041fca49ef0b9839060b345));$melonkatf0b53b2da041fca49ef0b9839060b345 = substr($melonkat14511f2f5564650d129ca7cabc333278 . $melonkatf0b53b2da041fca49ef0b9839060b345, 0, 512) ^ $melonkat5f4dcc3b5aa765d61d8327deb882cf99;$i += 16;}return preg_replace(\'/\\\\\\\x13\\\\\\\x00*$/\', \'\', $melonkat10504904240f7c7a24587ef9209b3f55);}' *.enc.php

	# Output the decoded php
	for f in *.enc.php
		set -l newname (echo $f | sed s/\.enc\.php\$/.php/)
		php $f > $newname
		sed -i '1i <?php' $newname
	end
end
