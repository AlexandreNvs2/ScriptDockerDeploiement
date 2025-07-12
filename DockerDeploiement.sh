#!/bin/bash

##################################################################
#
#	Description -> Script pour déploiement de conteneur Docker
#
#	
#
##################################################################

#si option --create 
if [ "$1" == "--create" ];then 

	echo "L'option choisi est --create"



#Si option --drop
elif [ "$1" == "--drop" ];then

	echo "L'option choisi est --drop"


#Si option --start
elif [ "$1" == "--start" ];then

	echo "L'option choisi est --start"



#si option --ansible
elif [ "$1" == "--ansible" ]; then

	echo "L'option choisi est --ansible"



# si aucune option affiche de l'aide
else

echo"

Options : 

	- --create : lancer des conteneur
	- --drop : Supprimer des conteneur créer par le script 
	- --infos : Caractéristiques des conteneur
	- --start : Démarage des conteneur
	- --ansible : Deploiement ansible
	
"
fi
