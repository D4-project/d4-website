jekyll build
rsync -v -rz --checksum  _site/ circl@cpab.circl.lu:/var/www/www.d4-project.org/
