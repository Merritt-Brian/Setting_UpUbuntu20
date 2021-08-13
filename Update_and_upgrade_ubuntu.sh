

#Update everything 
echo "________ Updating Systems  _____________"

sudo apt-get -y update
sudo apt-get -y upgrade

echo "______Upgrading.... _____"

sudo apt-get -y full-upgrade
sudo do-release-upgrade -d


# Install Docker

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


sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo systemctl restart docker 

# Optimizing Docker for Rootful users


echo "________ Rootful Define _____________"

sudo groupadd docker

sudo usermod -aG docker $USER
sudo sed -i "1s/^/$USER:$(id -u):1\n/" /etc/subuid
sudo sed -i "1s/^/$USER:$(id -g):1\n/" /etc/subgid

echo "{\"userns-remap\": \"$USER\"}" | sudo tee -a /etc/docker/daemon.json
echo "________ Restarting Docker _____________"
sudo service docker restart

# Getting Modules

docker pull jhuaplbio/basestack_consensus
docker pull jhuaplbio/basestack_mytax
docker pull florianbw/pavian


#Update Minknow

echo "________Getting Minion-nc__________"

wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add -

echo "deb http://mirror.oxfordnanoportal.com/apt $(lsb_release -c | awk '{print $2}')-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list

sudo apt-get -y update

sudo apt-get install -y minion-nc


echo "____Getting Basestack___-"

cd $HOME/Desktop
curl $(curl -s https://api.github.com/repos/jhuapl-bio/Basestack/releases/latest | grep "tag_name" | awk '{print "https://github.com/jhuapl-bio/Basestack/releases/download/" substr($2, 2, length($2)-3) "/Basestack.AppImage"}')

# Config MinKNOW 

echo "________Configuring Minion-nc__________"


sudo /opt/ont/minknow/bin/config_editor --filename /opt/ont/minknow/conf/sys_conf --conf system --set on_acquisition_ping_failure=ignore
sudo service minknow restart # Resart minknow




