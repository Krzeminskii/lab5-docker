# Sprawozdanie laboratorium 5 PAwChO 

## 1. Treść utworzonego pliku Dockerfile
Poniżej znajduje się kod wykorzystanego pliku `Dockerfile`, który realizuje wieloetapowe budowanie w oparciu o obraz `scratch` (z wstrzykniętym systemem plików Alpine) oraz `nginx`:

```dockerfile
# Etap 1
# Obraz bazowy scratch
FROM scratch AS builder

# Dodanie systemu plików Alpine do obrazu
ADD alpine-minirootfs-3.23.3-x86_64.tar.gz /

ARG VERSION=1.0.0
WORKDIR /app

# Utworzenie skryptu startowego do generowania pliku index.html z informacjami o serwerze
RUN echo "#!/bin/sh" > setup_app.sh && \
    echo "echo '<html><body style=\"font-family: Arial;\">' > /usr/share/nginx/html/index.html" >> setup_app.sh && \
    echo "echo '<h2>Informacje o serwerze (w czasie dzialania):</h2>' >> /usr/share/nginx/html/index.html" >> setup_app.sh && \
    echo "echo '<p><b>Wersja aplikacji:</b> ${VERSION}</p>' >> /usr/share/nginx/html/index.html" >> setup_app.sh && \
    echo "echo \"<p><b>Nazwa serwera (hostname):</b> \$(hostname)</p>\" >> /usr/share/nginx/html/index.html" >> setup_app.sh && \
    echo "echo \"<p><b>Adres IP:</b> \$(hostname -i)</p>\" >> /usr/share/nginx/html/index.html" >> setup_app.sh && \
    echo "echo '</body></html>' >> /usr/share/nginx/html/index.html" >> setup_app.sh && \
    chmod +x setup_app.sh

# Etap 2
# Obraz bazowy nginx wersja 1.25.4-alpine
FROM nginx:1.25.4-alpine

# Skopiowanie skryptu startowego z etapu budowania do katalogu, który będzie wykonywany przy starcie kontenera
COPY --from=builder /app/setup_app.sh /docker-entrypoint.d/99-setup-app.sh

# Skonfigurowanie sprawdzania stanu zdrowia kontenera
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1

# Otworzenie portu 80 dla ruchu HTTP
EXPOSE 80
```
## 2. Budowa obrazu 
Użyte polecenie: 
```
docker build --build-arg VERSION=1.0.0 -t zadlab5 .
```

Wynik polecenia: 
```
[+] Building 1.6s (11/11) FINISHED                                                                 docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 1.55kB                                                                             0.0s
 => [internal] load metadata for docker.io/library/nginx:1.25.4-alpine                                             1.4s
 => [auth] library/nginx:pull token for registry-1.docker.io                                                       0.0s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 2B                                                                                    0.0s
 => [internal] load build context                                                                                  0.0s
 => => transferring context: 62B                                                                                   0.0s
 => [stage-1 1/2] FROM docker.io/library/nginx:1.25.4-alpine@sha256:31bad00311cb5eeb8a6648beadcf67277a175da89989f  0.0s
 => => resolve docker.io/library/nginx:1.25.4-alpine@sha256:31bad00311cb5eeb8a6648beadcf67277a175da89989f14727420  0.0s
 => CACHED [builder 1/3] ADD alpine-minirootfs-3.23.3-x86_64.tar.gz /                                              0.0s
 => CACHED [builder 2/3] WORKDIR /app                                                                              0.0s
 => CACHED [builder 3/3] RUN echo "#!/bin/sh" > setup_app.sh &&     echo "echo '<html><body style="font-family: A  0.0s
 => CACHED [stage-1 2/2] COPY --from=builder /app/setup_app.sh /docker-entrypoint.d/99-setup-app.sh                0.0s
 => exporting to image                                                                                             0.2s
 => => exporting layers                                                                                            0.0s
 => => exporting manifest sha256:fb3fce15ef9e9140b3b9b89af04b0a768b0a7ad74582f4a315944cc98dcf8862                  0.0s
 => => exporting config sha256:4fdebb56593f7ce18dc231a9db9ddaa8c731804a8779a95ebf2d8d84f1ab588a                    0.0s
 => => exporting attestation manifest sha256:bfd4b43cc778e3474e71200779d5834e90107536ed2f3a7b10eb791c648ca751      0.0s
 => => exporting manifest list sha256:06f9eb8ffbf4023c524ac5c1bc34aa2d393d0e56cda9ea63455feb3f8862344c             0.0s
 => => naming to docker.io/library/zadlab5:latest                                                                  0.0s
 => => unpacking to docker.io/library/zadlab5:latest 
 ```
## 3. Uruchomienie serwera
Użyte polecenie:
```
docker run -d -p 8080:80 --name test-lab5 zadlab5
```
## 4. Potwierdzenie działania kontenera i aplikacji
W celu potwierdzenia, że kontener działa prawidłowo, użyto polecenia docker ps, które w kolumnie status informuje czy kontener przechodzi Healthchecki.
```
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                    PORTS                                     NAMES
a14b227b0f32   zadlab5   "/docker-entrypoint.…"   17 seconds ago   Up 16 seconds (healthy)   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   test-lab5
```
## 5. Zrzut ekranu 
Poniżej znajduje się zrzut ekranu z przeglądarki internetowej pod adresem localhost:8080, potwierdzający, że aplikacja realizuje wymaganą funkcjonalność.

<img width="505" height="239" alt="obraz" src="https://github.com/user-attachments/assets/a4420ca0-7f9e-49dc-9486-3573e2a0084e" />


 
