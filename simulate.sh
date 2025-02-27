for i in $(seq 1 100);
do
	aws iot-data publish --topic device/data --payload "$(echo $RANDOM)"
done
