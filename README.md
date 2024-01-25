# Edge Central with Modbus at Scale

## Introduction

Edge Central builds on top of the [device services](https://docs.iotechsys.com/edge-xpert23/device-services/device-services-overview.html) provided by [EdgeX](https://docs.edgexfoundry.org/3.1/microservices/device/DeviceService/). There are three components to device services:

1. A device microservice; each device service is an independent microservice that support 100s/1000s of devices. Device microservices are specific to device protocols. In other words, there is a Modbus device microservice that is seperate from the BACnet device microservice.
2. A device profile; each device service is provided one or more device profiles to define the device types and the supported operations.
3. A device configuration; each device profile is linked to device configuration that describes how to connect and poll the device. There can be multiple device configurations per profile.

For the purposes of this exercise, we therefore need

1. The device-modbus microservice started.
2. The Modbus (simulator) device profile.
3. The device configuration. Each device configuration references the Modbus device profile and points to a unique simulator instance.
4. One or more Modbus simulator(s) generating data

## Prerequisites

- Docker and Docker Compose
- GNU Make
- [IOTEch Edge Central](https://www.iotechsys.com/products/edge-central/edge-central-installer-download/) or [EdgeX](https://github.com/edgexfoundry/edgex-go#get-started).
- curl or httpie
- jq

The underlying Docker containers do use Python and Go. You will need a Python and/or Go environment if you decide to run things outside of the containers.

## Start the Simulator

Edge Central isn't the right tool to help debug your devices (or simulated devices). I recommend starting the simulator first and verify it's working before moving on to Edge Central.

### Start a Simulator Instance

`START_PORT=5020 COUNT=1 make start-simulators`

### Smoke Test

We know that Edge Central uses the Docker network edgexpert_edgex-network

`docker run --network edgexpert_edgex-network  --rm oitc/modbus-client:latest -s pymodbus-sim-5020 -p 5020 -t 4`

`make stop-simulators`

## Start Edge Central and Add the Simulated Devices

Follow IOTech docs
Be sure to start modbus service

```sh
START_PORT=5020 COUNT=10 make start-and-add-simulators
```

Check simulators are running

```sh
docker ps --filter "name=pymodbus" --format "{{print .Names}}"
```

Check profile is loaded

```sh
http $(docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}  {{end}}" core-metadata | xargs):59881/api/v2/deviceprofile/name/modbus-sim
```

Check device-modbus container for errors

```sh
docker logs device-modbus
```