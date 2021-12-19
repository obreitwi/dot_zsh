
db-speed() {
    echo "$(curl https://iceportal.de/api1/rs/status 2>/dev/null | jq .speed) km/h"
}

