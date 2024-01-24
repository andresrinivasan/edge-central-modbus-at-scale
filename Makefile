edgexpert_edgex-network:
	-docker network create edgexpert_edgex-network >/dev/null 2>&1

start-simulators: edgexpert_edgex-network
	end_port=$$(expr $${START_PORT} + $$(expr $${COUNT} - 1)); \
	for port in $$(seq $${START_PORT} $${end_port}); do \
		SIM_PORT=$${port} docker compose -p pymodbus-sim-$${port} up -d; \
	done

stop-simulators:
	docker kill $$(docker ps --filter "name=pymodbus" --format "{{print .Names}}")

start-and-add-simulators: start-simulators
	core_metadata=$(docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}  {{end}}" core-metadata); \
	http -f $$core_metadata/api/v2/deviceprofiles/uploadfile file@./edge-central-modbus-profile.yaml; \
	end_port=$$(expr $${START_PORT} + $$(expr $${COUNT} - 1)); \
	for port in $$(seq $${START_PORT} $${end_port}); do \
		SIM_CONTAINER=pymodbus-sim-$${port} envsubst<./edge-central-modbus-device-template.json | http $$core_metadata/api/v2/device 
	done
