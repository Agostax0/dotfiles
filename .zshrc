alias docker-start="systemctl start docker.service"
alias discord="systemctl --user enable pipewire.service pipewire-pulse.service; systemctl --user start pipewire.service pipewire-pulse.service; systemctl --user restart xdg-desktop-portal; chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer --app=https://discord.com/app &;" 
