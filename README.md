# Edge Central with Modbus at Scale

## Introduction

Edge Central builds on top of the [device services](https://docs.iotechsys.com/edge-xpert23/device-services/device-services-overview.html) provided by [EdgeX](https://docs.edgexfoundry.org/3.1/microservices/device/DeviceService/). There are three components to device services:

1. A device microservice; each device service is an independent microservice that support 100s/1000s of devices. Device microservices are specific to device protocols. In other words, there is a Modbus device microservice that is seperate from the BACnet device microservice.
2. A device profile; each device service is provided one or more device profiles to define the device types and the supported opperations.
3. A device configuration; each device profile is linked to device configuration that describes how to connect and poll the device.

For the purposes of this exercise, we therefore need

1. The device-modbus microservice started.
2. The Modbus (simulator) device profile.
3. The device configuration. Each device configuration references the Modbus device profile and points to a unique simulator instance.
4. One or more Modbus simulator(s) generating data

## Prerequisites

- Docker and Docker Compose
- GNU Make
- [IOTEch Edge Central](https://www.iotechsys.com/products/edge-central/edge-central-installer-download/) or [EdgeX](https://github.com/edgexfoundry/edgex-go#get-started).

The underlying Docker containers do use Python and Go. You will need a Python and/or Go environment if you decide to run things outside of the containers.

## Start Edge Central

- Load the profile
- Load the configs

## Start the Simulator

