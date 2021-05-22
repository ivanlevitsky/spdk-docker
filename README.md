# Usage:

```bash
make [options] [arguments] [targets]
```

**Targets:**<br />

```bash
all		"Build SPDK docker image"
build		"Build SPDK docker image"
test		"Run unit tests SPDK in docker container"
run		"Run SPDK in docker container"
clean		"Remove generated files"
help		"Display help message and exit"
```

**Arguments:**<br />

```bash
SPDK_VERSION		"SPDK release version number. Matches tags in SPDK git. Example: SPDK_VERSION=21.04"
ARCH			"Build architecture. Must be a valid GNU arch. Default: native"
```

# Step by step:

```bash
# build spdk container image
make build

# allocate 4G hugepages (2048*2M)
sudo echo 2048 > /proc/sys/vm/nr_hugepages

# start spdk target
sudo make run

# run below commands in another console

# create 1G malloc bdev blocksize 4k
sudo docker exec -it spdk-docker /app/spdk/scripts/rpc.py bdev_malloc_create -b Malloc0 1024 4096

# create lvstore
sudo docker exec -it spdk-docker /app/spdk/scripts/rpc.py bdev_lvol_create_lvstore Malloc0 lvs0

# start jsonrpc http proxy on 127.0.0.1:9009
sudo docker exec -it spdk-docker /app/spdk/scripts/rpc_http_proxy.py 127.0.0.1 9009 spdkrpcuser spdkrpcpass
```
