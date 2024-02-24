#!/usr/bin/env zsh

completions="$(dirname "$(readlink -m "${(%):-%N}")")"

if command -v argocd >/dev/null; then
    argocd completion zsh > "${completions}/_argocd"
fi

# no real way to install automatically -> resort to manual updates
# _br
# _broot

if command -v gh >/dev/null; then
   gh completion -s zsh > "${completions}/_gh"
fi

# _hub (not used anymore)

if command -v k9s >/dev/null; then
   k9s completion zsh > "${completions}/_k9s"
fi

if command -v revcli >/dev/null; then
   revcli generate completion zsh > "${completions}/_revcli"
fi

if command -v rustup >/dev/null; then
   rustup completions zsh > "${completions}/_rustup"
fi

# _semf (not used anymore)
