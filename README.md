# dac

## Utilisation

On suppose les instances déjà installé avec Ubuntu, un clé ssh, le port 8080 ouvert sur tous les serveurs et le port 8081 pour le load balancer.

Il faut mettre les IPs de ses serveurs dans le fichier hosts, dans la partie ubuntuGroup. L'IP du load balancer dans la partie main.

déployer les serveurs : ansible-playbook --private-key sshkey -i hosts server.yml
déployer le load balancer : ansible-playbook --private-key sshkey -i hosts caddy.yml

Pour tester utiliser IP:8081

### Dockerfile

##### compilation Golang

J'utilise Golang car il permet de générer un binaire pour un serveur facilement.

Pour compiler on utilise différents paramètre afin de réduire la taille du binaire.
  - CGO_ENABLED=0 On désactive cgo dans la compilation car notre app.go n'utilise pas de fonction C
  - GGOOS=linux et GOARCH=amd64 On connait le système et l'architecture de nos instances, on peut donc réduire la taille en compilant uniquement pour ceux-ci.
  - -ldflags="-w -s" On retire les informations de débogage et la table des symboles.

##### image avec Busybox

J'ai choisis Busybox plutôt qu'Alpine pour la taille, la même image avec Alpine tournait autour de 13M tandis que celle ci s'approche des 4.8M et que les fonctionnalités supplémentaires d'Alpine n'était pas nécessaire sur ce projet.

Cependant Alpine pourrait être préféré malgré sa taille supérieure pour ses facilité en terme de sécurité.

On utilise le multi-stage build de docker afin de réduire le nombre de layer.

### Ansible

J'utilise Ansible car c'est un outil que l'on a déjà utilisé et qui fonctionne bien pour déployer des dockers sur plusieurs instances.

##### server.yml

Pour recréer le conteneur dans le cas où l'image change, j'ai utilisé Ansible afin de récupérer l'ID de l'image déjà présente sur l'instance, pour ensuite la comparer avec la nouvelle créé("force_source: yes" permet de build l'image même si celle-ci existe déjà). Si celle-ci a changé, l'image à changé, il faut donc recréer le conteneur et le démarrer.

A la fin on supprime les images qui ne sont pas en cours d'utilisations en utilisant docker_prune, cela permet de libérer de l'espace, cependant il faut faire attention car on supprime toutes les images non utilisées qui pourraient utile dans d'autre projet. Ici ce n'est pas un problème mais si l'on souhaite conserver d'autres images qui ne sont pas en cours d'utilisations. Il faudrait supprimer nos images en les cherchant par nom.

### load balancer

  1. Type de load balancing
      - layer 4
      - layer 7
  2. On utilise le layer 4, car on souhaite sélectionner le serveur à utiliser indépendamment des données.
  3. Stratégie de load balancing
      - Round robin
      - Weighted round robin
      - Least connections
      - Least response time

    On va utiliser le round robin car on souhaite changer de serveur à chaque fois.

##### Caddy

  J'utilise Caddy pour mon load balancer. Le load balancer n'étant présent qu'une fois, j'ai décidé de ne pas chercher d'optimisation particulière dans la taille du docker. J'utilise un volume afin de permettre l'ajout de nouveaux serveurs facilement.
