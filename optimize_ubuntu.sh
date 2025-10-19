#!/bin/bash
# 🚀 Script de otimização automática do Ubuntu
# Para usar em instalações novas, roda sem interação
# Mantém Snap Store funcional e aplica todas as otimizações

green="\e[32m"; yellow="\e[33m"; nc="\e[0m"

echo -e "${green}=== 🧰 Iniciando otimização automática do Ubuntu ===${nc}"

# 1. Atualizar sistema
echo -e "${yellow}→ Atualizando pacotes...${nc}"
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo apt autoclean -y

# 2. Drivers proprietários
echo -e "${yellow}→ Instalando drivers proprietários...${nc}"
sudo ubuntu-drivers autoinstall || true

# 3. Ferramentas essenciais
echo -e "${yellow}→ Instalando pacotes essenciais...${nc}"
sudo apt install -y curl wget htop net-tools tlp tlp-rdw zram-tools gparted \
gnome-tweaks gnome-shell-extensions cpufrequtils preload ufw bleachbit snapd

# 4. Ativar serviços TLP e Preload
echo -e "${yellow}→ Ativando TLP e Preload...${nc}"
sudo systemctl enable tlp && sudo systemctl start tlp
sudo systemctl enable preload && sudo systemctl start preload

# 5. TRIM automático
echo -e "${yellow}→ Ativando TRIM automático...${nc}"
sudo systemctl enable fstrim.timer && sudo systemctl start fstrim.timer

# 6. Otimizar swap e memória
echo -e "${yellow}→ Otimizando swap e zram...${nc}"
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
sudo sysctl -p

# 7. CPU em modo performance
echo -e "${yellow}→ Ajustando CPU para modo performance...${nc}"
sudo cpufreq-set -r -g performance || true

# 8. Desativar serviços lentos no boot (sem afetar Snap)
echo -e "${yellow}→ Desativando serviços lentos...${nc}"
sudo systemctl disable plymouth-quit-wait.service 2>/dev/null
sudo systemctl mask plymouth-quit-wait.service 2>/dev/null
sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null
sudo systemctl disable gpu-manager.service 2>/dev/null

# 9. Garantir Snap Store funcional
echo -e "${yellow}→ Garantindo que Snap Store esteja instalada e conectada...${nc}"
sudo snap install snap-store --classic || true
sudo snap connect snap-store:gtk-3-themes gtk-common-themes
sudo snap connect snap-store:gnome-3-38-2004 gnome-3-38-2004 || true
sudo snap refresh snap-store

# 10. Flatpak + GNOME Software (opcional automática)
echo -e "${yellow}→ Instalando Flatpak + GNOME Software (automático)...${nc}"
sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 11. Ativar firewall
echo -e "${yellow}→ Ativando firewall UFW...${nc}"
sudo ufw enable

# 12. Limpeza final
echo -e "${yellow}→ Limpando pacotes e cache...${nc}"
sudo apt autoremove --purge -y
sudo apt autoclean -y

# 13. Resultado
echo -e "${green}\n✅ Otimização concluída!${nc}"
systemd-analyze
echo -e "${green}\nTempo total de boot acima. Reiniciando automaticamente...${nc}"

# 14. Reiniciar
sudo reboot
