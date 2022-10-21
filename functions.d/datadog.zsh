dd-log() { # <query>...
    xdg-open "https://app.datadoghq.eu/logs?query=$(echo -n "$*" | urlencode)"
}

dd-trace() { # <query>...
    xdg-open "https://app.datadoghq.eu/apm/traces?query=$(echo -n "$*" | urlencode)"
}
