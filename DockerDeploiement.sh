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
  idmax=$(docker ps -a --format '{{ .Names }}' | awk -F "-" -v user=$USER '$0 ~ user"-debian" {print $3}' | sort -r | head -1)

#Redéfinition de min et max

  min=$(($idmax + 1))

  max=$(($idmax + $nb_machine))

#Boucle création de conteneur en fonction de min et max
# Boucle de création de conteneurs entre les bornes min et max
for i in $(seq $min $max); do
	
  ## Lance le conteneur Debian avec droits réseau, montage volume, nom et image personnalisée
  docker run -tid --cap-add NET_ADMIN --cap-add SYS_ADMIN --publish-all=true -v /Users/alexandre/docker-data:/srv/html -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name $USER-debian-$i -h $USER-debian-$i ghcr.io/alexandrenvs2/scriptdockerdeploiement:v1.0 

  # Création d’un utilisateur avec un mot de passe chiffré directement dans le conteneur
  docker exec -ti $USER-debian-$i /bin/sh -c "useradd -m -p sa3tHJ3/KuYvI $USER"

  # Création du dossier .ssh dans le home de l'utilisateur pour autoriser les connexions SSH
  docker exec -ti $USER-debian-$i /bin/sh -c "mkdir -p /home/$USER/.ssh && chmod 700 /home/$USER/.ssh && chown $USER:$USER /home/$USER/.ssh"

  # Copie de ta clé publique depuis la machine hôte vers le conteneur, pour accès SSH sans mot de passe
  docker cp $HOME/.ssh/id_rsa.pub $USER-debian-$i:/home/$USER/.ssh/authorized_keys

  # Droits sur le fichier de clé SSH dans le conteneur
  docker exec -ti $USER-debian-$i /bin/sh -c "chmod 600 /home/$USER/.ssh/authorized_keys && chown $USER:$USER /home/$USER/.ssh/authorized_keys"

  # Ajout de l'utilisateur au fichier sudoers avec droits root sans mot de passe(utile dans le cas où on voudrait utiliser ansible)
  docker exec -ti $USER-debian-$i /bin/sh -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

  # Lancement manuel du service SSH (car systemd ne peut pas fonctionner complètement dans un conteneur Docker classique)
  docker exec -ti $USER-debian-$i /usr/sbin/sshd

  # Message de confirmation
  echo "Conteneur $USER-debian-$i créé"

done
	


	  

#Si option --drop
elif [ "$1" == "--drop" ];then


echo" Suppression des conteneur..."

	docker rm -f $(docker ps -a | grep $USER-debian | awk '{print $1}')
echo" Le conteneur à été supprimé avec succès "

#Si option --start
elif [ "$1" == "--start" ];then

docker start $(docker ps -a | grep $USER-debian | awk '{print$1}')


#si options --infos
elif [ "$1" == "--infos" ];then
	echo " "
        echo " Informations des conteneurs : "
	echo " "
for conteneur in $(docker ps -a | grep $USER-debian | awk '{print $1}');do

docker inspect -f ' => {{.Name}} - {{.NetworkSettings.IPAddress }}' $conteneur

done


#si option --ansible
elif [ "$1" == "--ansible" ];then
	echo "L'option choisi est --ansible"



#si option --stop
elif [ "$1" == "--stop" ];then
	echo " Arrêt des conteneurs en cours "

	docker kill $(docker ps -a | grep $USER-debian | awk '{print $1}')

	echo " Les conteneurs on été stoppé avec succès " 
# si aucune option affiche de l'aide
else

echo "

Options : 

	- --create : lancer des conteneur
	- --drop : Supprimer des conteneur créer par le script 
	- --infos : Caractéristiques des conteneurs
	- --start : Démarage des conteneur
	- --stop : Arrêt des conteneurs
	- --ansible : Deploiement ansible
	
"
fi

