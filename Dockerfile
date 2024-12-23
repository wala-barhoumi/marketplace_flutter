# Utiliser une image Ubuntu comme base
FROM ubuntu:22.04

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk

# Installer Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Mettre à jour Flutter pour la dernière version stable
RUN flutter channel stable && flutter upgrade

# Définir le répertoire de travail
WORKDIR /app

# Copier le projet Flutter dans le conteneur
COPY . .

# Installer les dépendances du projet
RUN flutter pub get

# Construire l'application Flutter pour le Web
RUN flutter build web

# Exposer le port 8080 pour le serveur Web
EXPOSE 8080

# Commande pour démarrer le serveur Flutter
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080"]
