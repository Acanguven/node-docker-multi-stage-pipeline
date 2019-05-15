# Docker Multi-Stage NodeJs Pipeline

Example implementation of Docker multi-stage pipeline for Nodejs

One of the challenges facing Nodejs developers is providing a reliable build, test, prepare for production pipeline.

To solve this issue we use Docker multi-stage pipeline. Checkout [Dockerfile](./Dockerfile) for better understanding

## [Multi-stage pipeline](,/Dockerfile) 
### no-cache run
```bash
time docker build . -t optimized --no-cache
```
* Duration: 57.856 seconds
* Image Size: 73MB

### cache run (source file changed)
```bash
time docker build . -t optimized 
```
* Duration: 10.790 seconds
* Image Size: 374MB


## [Unoptimized pipeline](,/Dockerfile_unoptimized)
### no-cache run
```bash
time docker build -f Dockerfile_unoptimized . -t unoptimized --no-cache
```
* Duration: 41.761 seconds
* Image Size: 374MB

### cache run (source file changed)
```bash
time docker build -f Dockerfile_unoptimized . -t unoptimized
```
* Duration: 12.372 seconds
* Image Size: 374MB
