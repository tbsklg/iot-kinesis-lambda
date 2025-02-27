for i in $(seq 1 10);
do
	aws iot-data publish --topic device/data --payload "$(echo $RANDOM)"
done
