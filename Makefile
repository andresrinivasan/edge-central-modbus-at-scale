SIM_COUNT ?= 1
export SIM_COUNT

edgexpert_edgex-network:
	-docker network create edgexpert_edgex-network >/dev/null 2>&1

start-simulators: edgexpert_edgex-network
	docker compose up -d

stop-simulators:
	docker kill $$(docker ps --filter "name=pymodbus-sim" --format "{{print .Names}}")

CORE_METADATA := $(shell docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}  {{end}}" core-metadata | xargs):59881

add-profile:
	http -f $(CORE_METADATA)/api/v2/deviceprofile/uploadfile file@./edge-central-modbus-profile.yaml

remove-profile:
	http delete $(CORE_METADATA)/api/v2/deviceprofile/name/modbus-sim

add-devices:
	for c in $$(docker ps --filter "name=pymodbus-sim" --format "{{ print .Names }}"); do \
		SIM_CONTAINER=$${c} envsubst<./edge-central-modbus-device-template.json | http $(CORE_METADATA)/api/v2/device; \
	done

remove-devices:
	for d in $$(http $(CORE_METADATA)/api/v2/device/all | jq -r '.devices[].name'); do \
		http delete $(CORE_METADATA)/api/v2/device/name/$${d}; \
	done

start-and-add-simulators: start-simulators add-profile add-devices

remove-events:
	echo To Do

clean: stop-simulators remove-devices

veryclean: clean remove-profile remove-events
