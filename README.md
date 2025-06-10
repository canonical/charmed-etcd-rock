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
version=$(yq .version rockcraft.yaml)
rockcraft pack
ROCK=$(echo ./charmed-etcd_*.rock)
sudo rockcraft.skopeo --insecure-policy copy oci-archive:$ROCK docker-daemon:charmed-etcd:${version}
docker run --rm -it charmed-etcd:${version}
```
### Forming a cluster
```
# deploy discovery node
discovery_node=$(docker run -d \
  --name discovery-node \
  -e ETCD_NAME=discovery-node \
  -e ETCD_INITIAL_ADVERTISE_PEER_URLS=http://localhost:2380 \
  -e ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380 \
  -e ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379 \
  -e ETCD_ADVERTISE_CLIENT_URLS=http://localhost:2379 \
  charmed-etcd:${version}
)

discovery_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "${discovery_node}")

# generate unique cluster token
TOKEN="random-token"

# register expected cluster size
docker exec discovery-node etcdctl put /_etcd/registry/${TOKEN}/_config/size 3

# start cluster members
MEMBERS=(etcd0 etcd1 etcd2)
for NAME in "${MEMBERS[@]}"; do
  docker run -d \
    --name "$NAME" \
    -e ETCD_NAME="${NAME}" \
    -e ETCD_INITIAL_ADVERTISE_PEER_URLS="http://localhost:2380" \
    -e ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380" \
    -e ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379" \
    -e ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379" \
    -e ETCD_DISCOVERY_TOKEN="${TOKEN}" \
    -e ETCD_DISCOVERY_ENDPOINTS="http://${discovery_ip}:2379" \
    charmed-etcd:${version}
done

# discovery node can now be removed
docker rm -f discovery-node
```
## License:
The Charmed etcd rock is free software, distributed under the Apache Software License, version 2.0. See licenses for 
more information.
