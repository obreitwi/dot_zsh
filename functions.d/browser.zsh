#!/bin/bash

browser_set_chrome_auto_profile() {
    echo "Setting default browser to chrome-auto-profile…">&2
    xdg-settings set default-web-browser chrome-auto-profile.desktop
}

browser_set_chrome() {
    echo "Setting default browser to chrome…">&2
    xdg-settings set default-web-browser google-chrome.desktop
}

browser_set_firefox() {
    echo "Setting default browser to firefox…">&2
    xdg-settings set default-web-browser firefox.desktop
}
