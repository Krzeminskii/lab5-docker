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