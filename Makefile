START_PORT ?= 5020
COUNT ?= 1
END_PORT := $(shell echo $(START_PORT) + $(COUNT) - 1 | bc)

edgexpert_edgex-network:
	-docker network create edgexpert_edgex-network >/dev/null 2>&1

start-simulators: edgexpert_edgex-network
	for port in $$(seq $(START_PORT) $(END_PORT)); do \
		SIM_PORT=$${port} docker compose -p pymodbus-sim-$${port} up -d; \
	done

stop-simulators:
	docker kill $$(docker ps --filter "name=pymodbus" --format "{{print .Names}}")

CORE_METADATA := $(shell docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}  {{end}}" core-metadata | xargs)
CORE_METADATA_PORT = 59881

add-profile:
	http -f $(CORE_METADATA):$(CORE_METADATA_PORT)/api/v2/deviceprofile/uploadfile file@./edge-central-modbus-profile.yaml

remove-profile:
	http delete $(CORE_METADATA):$(CORE_METADATA_PORT)/api/v2/deviceprofile/name/modbus-sim

add-devices:
	for port in $$(seq $(START_PORT) $(END_PORT)); do \
		SIM_CONTAINER=pymodbus-sim-$${port} envsubst<./edge-central-modbus-device-template.json | http $(CORE_METADATA):$(CORE_METADATA_PORT)/api/v2/device; \
	done

remove-devices:
	for d in $$(http $(CORE_METADATA):$(CORE_METADATA_PORT)/api/v2/device/all | jq -r '.devices[].name'); do \
		http delete $(CORE_METADATA):$(CORE_METADATA_PORT)/api/v2/device/name/$${d}; \
	done

start-and-add-simulators: start-simulators add-profile add-devices

remove-events:
	echo To Do

clean: stop-simulators remove-devices

very-clean: clean remove-profile remove-events
