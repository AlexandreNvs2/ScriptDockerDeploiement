#!/bin/bash

##################################################################
#
#	Description -> Script pour déploiement de conteneur Docker
#
#	
#
##################################################################

#Si option --create 
if [ "$1" == "--create" ];then 

#Définition grâce à $2 le  nombre de conteneur voulu
	nb_machine=1
	 [ "$2" != "" ] && nb_machine=$2

#Set de min et max
  min=1
  max=0



#Récupération de l'id max
  idmax=$(docker ps -a --format '{{ .Names }}' | awk -F "-" -v user=$USER '$0 ~ user"-alpine" {print $3}' | sort -r | head -1)

#Redéfinition de min et max

  min=$(($idmax + 1))

  max=$(($idmax + $nb_machine))

#Boucle création de conteneur en fonction de min et max
	for i in $(seq $min $max);do
	  docker run -tid --name $USER-alpine-$i alpine:latest
	echo "Conteneur $USER-alpine-$i créé"
      done

#Si option --drop
elif [ "$1" == "--drop" ];then


echo" Suppression des conteneur..."

	docker rm -f $(docker ps -a | grep $USER-alpine | awk '{print $1}')
echo" Le conteneur à été supprimé avec succès "

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
