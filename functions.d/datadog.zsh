dd-log-clean() {
    echo -n '-"Datadog Tracer" -"warning envoy config" -image_name:*istio\/*'
}

dd-log() { # <query>...
    xdg-open "https://app.datadoghq.eu/logs?query=$(echo -n "$* $(dd-log-clean)" | urlencode)"
}

dd-trace() { # <query>...
    xdg-open "https://app.datadoghq.eu/apm/traces?query=$(echo -n "$*" | urlencode)"
}

