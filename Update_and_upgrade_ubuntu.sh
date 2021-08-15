usage() {
  cat <<EOF
  Set Up Workshop Computers with Ubuntu 20, MinKNOW, Docker, Basestack
REQUIRED:
  -h  help    show this message
  -u  BOOLEAN    Run Upgrade on the system to ubuntu 20
  -k  BOOLEAN Install MinKNOW and Configure it
	-d 	BOOLEAN  Install Docker 
	-m 	BOOLEAN  Download Modules for Basestack
	-b 	BOOLEAN   Download Latest Release of Basestack (Linux Only)
EOF
}

UPGRADE="false"
MINKNOW="false"
DOCKER="false"
MODULES="false"
BASESTACK="false"



while getopts "hi:o:s:m:f" OPTION; do
  case $OPTION in
  h)
    usage
    exit 1
    ;;
  u) UPGRADE'true';;
  k) MINKNOW='true';;
  d) DOCKER='true';;
  m) MODULES='true';;
  b) BASESTACK='true';;
?)
    usage
    exit
    ;;
  esac
done





if [[ $UPGRADE = true ]]; then 
  #Update everything 
  echo "________ Updating Systems  _____________"

  sudo apt-get -y update
  sudo apt-get -y upgrade

  echo "______Upgrading.... _____"

  sudo apt-get -y full-upgrade
  sudo do-release-upgrade -d
fi

# Install Docker
if [[ $DOCKER = true ]]; then 
  echo "________ Updating prior to docker install  _____________"

  sudo apt-get -y update
  sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

  echo "________ Curling Docker keyring _____________"

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


  echo "________ Getting Docker _____________"

  # sudo apt-get remove docker docker-engine docker.io containerd runc

  sudo apt-get -y update
  sudo apt-get -y install uidmap
  echo "user:100000:65536"  | sudo tee /etc/subuid
  echo "user:100000:65536"  | sudo tee /etc/subgid
  curl -fsSL https://get.docker.com/rootless | sh
  echo "PATH=$HOME/bin:$PATH" >> $HOME/.bashrc
  echo "DOCKER_HOST=unix:///run/user/$(id -u)/docker" >> $HOME/.bashrc

  sudo apt-get install -y docker-ce-rootless-extras

fi

# sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# sudo systemctl restart docker 

# Optimizing Docker for Rootful users


# echo "________ Rootful Define _____________DEPR.____"

# sudo groupadd docker

# sudo usermod -aG docker $USER
# sudo sed -i "1s/^/$USER:$(id -u):1\n/" /etc/subuid
# sudo sed -i "1s/^/$USER:$(id -g):1\n/" /etc/subgid

# echo "{\"userns-remap\": \"$USER\"}" | sudo tee -a /etc/docker/daemon.json
# echo "________ Restarting Docker _____________"
# sudo service docker restart

# Getting Modules
if [[ $MODULES = true ]]; then 
  docker pull jhuaplbio/basestack_consensus
  docker pull jhuaplbio/basestack_mytax
  docker pull florianbw/pavian
fi

#Update Minknow
if [[ $MINKNOW = true ]]; then 
  echo "________Getting Minion-nc__________"

  wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add -

  echo "deb http://mirror.oxfordnanoportal.com/apt $(lsb_release -c | awk '{print $2}')-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list

  sudo apt-get -y update

  sudo apt-get install -y minion-nc


  echo "____Getting Basestack___-"

  cd $HOME/Desktop
  wget $(curl -s https://api.github.com/repos/jhuapl-bio/Basestack/releases/latest | grep "tag_name" | awk '{print "https://github.com/jhuapl-bio/Basestack/releases/download/" substr($2, 2, length($2)-3) "/Basestack.AppImage"}')
  sudo chmod +x Basestack.AppImage

  # Config MinKNOW 
  echo "________Configuring Minion-nc__________"
  sudo /opt/ont/minknow/bin/config_editor --filename /opt/ont/minknow/conf/sys_conf --conf system --set on_acquisition_ping_failure=ignore
  sudo service minknow restart # Resart minknow
fi




