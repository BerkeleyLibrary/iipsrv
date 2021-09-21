# iipsrv

A single-container deployment of [IIPImage](https://iipimage.sourceforge.io),
running on [nginx](http://nginx.org/en/) with FastCGI.

(Forked from [iiip-nginx-single](https://git.lib.berkeley.edu/lap/iiip-nginx-single).)

## Notes for developers

### Default development configuration

#### Building and running

To build and run the container based on the configuration in
[`docker-compose.yml`](docker-compose.yml):

```sh
docker-compose build --pull
docker compose up
```

Note that nginx/IIPImage runs on port 80, and is exposed on host port 80.

The `iipsrv-data` directory is not copied into the container, but is mounted
as a volume when running with `docker-compose`. Any files in this directory
will be available to the container under `/iipsrv-data`.

#### Testing

To test that the container has come up correctly, using the image file
[`iipsrv-data/test.tif`](iipsrv-data/test.tif):

```sh
curl -v 'http://localhost/iiif/test.tif/info.json'
```

This should produce a IIIF [information response](https://iiif.io/api/image/2.0/#information-request)
in JSON format, e.g.:

```json
{
  "@context" : "http://iiif.io/api/image/2/context.json",
  "@id" : "http://localhost/iiif/test.tif",
  "protocol" : "http://iiif.io/api/image",
  "width" : 2769,
  "height" : 3855,
  "sizes" : [
     { "width" : 173, "height" : 240 },
     { "width" : 346, "height" : 481 },
     { "width" : 692, "height" : 963 },
     { "width" : 1384, "height" : 1927 }
  ],
  "tiles" : [
     { "width" : 256, "height" : 256, "scaleFactors" : [ 1, 2, 4, 8, 16 ] }
  ],
  "profile" : [
     "http://iiif.io/api/image/2/level1.json",
     { "formats" : [ "jpg" ],
       "qualities" : [ "native","color","gray","bitonal" ],
       "supports" : ["regionByPct","regionSquare","sizeByForcedWh","sizeByWh","sizeAboveFull","rotationBy90s","mirroring"],
       "maxWidth" : 5000,
       "maxHeight" : 5000
     }
  ]
}
```

### Custom configuration 

You also can build an image directly from the Dockerfile and point it at an
external image directory.


```sh
docker build . -t iipsrv:latest
```

This builds an image and tag it `iipsrv:latest`.

```sh
docker run --rm \
  --volume /tmp/iipsrv-images:/images \
  --env FILESYSTEM_PREFIX=/images/ \
  --env CORS='*' \
  --publish 127.0.0.1:80:80 \
  iipsrv:latest
```

**Note:** `FILESYSTEM_PREFIX` **must** have a trailing slash.

This runs the image built above with the following configuration:

1. serving images from a host directory `/tmp/iipsrv-images`, mounted as `/images` in the container directory
2. sending CORS header `Access-Control-Allow-Origin: *`
3. publishing container port 80 (the IIPImage/nginx port) to port 80 on 127.0.0.1
