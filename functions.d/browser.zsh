#!/bin/bash

browser_set_firefox() {
    echo "Setting default browser to firefox…">&2
    xdg-settings set default-web-browser firefox.desktop
}

browser_set_chrome() {
    echo "Setting default browser to chrome…">&2
    xdg-settings set default-web-browser google-chrome.desktop
}
