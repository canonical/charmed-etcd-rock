# Charmed etcd Rock

This repository contains the packaging metadata for creating a Charmed etcd rock derived from the [Charmed etcd Snap](https://github.com/canonical/charmed-etcd-snap). For more information on rocks, visit the [rockcraft Github](https://github.com/canonical/rockcraft).

## Building the rock
The steps outlined below are based on the assumption that you are building the rock with the latest LTS of Ubuntu.  
If you are using another version of Ubuntu or another operating system, the process may be different.

### Clone Repository
```bash
git clone git@github.com:canonical/charmed-etcd-rock.git
cd charmed-etcd-rock
```
### Installing Prerequisites
```bash
sudo snap install rockcraft --edge --classic
sudo snap install docker
sudo snap install lxd
```
### Configuring Prerequisites
```bash
sudo usermod -aG docker $USER 
sudo lxd init --auto
```
*_NOTE:_* You will need to open a new shell for the group change to take effect (i.e. `su - $USER`)
### Packing and Running the rock

```
rockcraft pack
ROCK=$(echo ./charmed-etcd_*.rock)
sudo rockcraft.skopeo --insecure-policy copy oci-archive:$ROCK docker-daemon:charmed-etcd:<tag>
docker run --rm -it charmed-etcd:<tag>
```
## License:
The Charmed etcd rock is free software, distributed under the Apache Software License, version 2.0. See licenses for 
more information.
