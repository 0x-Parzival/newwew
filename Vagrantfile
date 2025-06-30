Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  config.vm.hostname = "kalki-os-vm"
  config.vm.synced_folder ".", "/home/vagrant/project"
  config.vm.network "forwarded_port", guest: 5901, host: 5901, auto_correct: true # For VNC
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 2
  end
  config.vm.provision "shell", inline: <<-SHELL
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm base-devel git sudo python python-pip tk xorg-xauth xorg-xhost xorg-xeyes xorg-xclock zenity tigervnc
    # Install paru (AUR helper)
    if ! command -v paru >/dev/null 2>&1; then
      git clone https://aur.archlinux.org/paru.git
      cd paru
      makepkg -si --noconfirm
      cd ..
      rm -rf paru
    fi
    # Install Python requirements if present
    if [ -f /home/vagrant/project/requirements-all.txt ]; then
      pip install --user -r /home/vagrant/project/requirements-all.txt || true
    fi
    echo "Setup complete. To start the GUI, run:"
    echo "  vncserver :1"
    echo "  export DISPLAY=:1"
    echo "  cd /home/vagrant/project && python3 kalki-build-gui.py"
  SHELL
end 