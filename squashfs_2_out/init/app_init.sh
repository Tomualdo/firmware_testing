#!/bin/sh

############# Setting register and insert wifi ko ############
insmod /system/driver/tx-isp-t31.ko isp_clk=100000000
insmod /system/driver/exfat.ko
insmod /system/driver/audio.ko spk_gpio=-1 alc_mode=0 mic_gain=0
insmod /system/driver/avpu.ko
insmod /system/driver/sinfo.ko
insmod /system/driver/sample_pwm_core.ko
insmod /system/driver/sample_pwm_hal.ko
insmod /system/driver/rtl8189ftv.ko
insmod /system/driver/speaker_ctl.ko

# Unknown, Don't change!
devmem 0x10011110 32 0x6e094800
# Clear the drive capability setting for PB04 (minimum drive capability)
devmem 0x10011138 32 0x300
# Set the drive capability of PB04
devmem 0x10011134 32 0x200

############ make resolv.conf file for ntp service ###########
touch /tmp/resolv.conf

OLD_USR_CONFIG_FILE='/configs/.parameters'
NEW_USR_CONFIG_FILE='/configs/.user_config'

if [ -e $OLD_USR_CONFIG_FILE ]; then
	mv $OLD_USR_CONFIG_FILE $NEW_USR_CONFIG_FILE -f
	rm $OLD_USR_CONFIG_FILE -f
fi

############ update time to time firmware was built at ###########
FIRMWARE_BUILD_TIME_FILE='/system/init/firmware_build_epoch_time.txt'
if [ -e $FIRMWARE_BUILD_TIME_FILE ]; then
	CURRENT_EPOCH_TIME=$(date +%s)
	FIRMWARE_BUILD_EPOCH_TIME=$(cat $FIRMWARE_BUILD_TIME_FILE)
	FIRMWARE_BUILD_MINUS_ONE_DAY_EPOCH_TIME=$(($FIRMWARE_BUILD_EPOCH_TIME-86400))
	# If "current time" < ("firmware build time" - "one day")
	# Then update time to "firmware build time"
	if [ "$CURRENT_EPOCH_TIME" -lt "$FIRMWARE_BUILD_MINUS_ONE_DAY_EPOCH_TIME" ]; then
		echo "Updating device time to:"
		date -s "@$FIRMWARE_BUILD_EPOCH_TIME"
	fi
fi

#################### Run app process (1) #####################
#telnetd &
/system/bin/ver-comp

############### Select user mode or debug mode ###############
DEBUG_STATUS='/configs/.debug_flag'

if [ ! -f $DEBUG_STATUS ]; then
	echo "#######################"
	echo "#   IS USER PROCESS   #"
	echo "#######################"
	/system/init/factory.sh &
	/system/bin/factorycheck

	if [ -f /tmp/factory ]; then
		exit
	fi

	/system/bin/assis &
	/system/bin/hl_client &
	/system/bin/iCamera &
else
	sleep 0.5
	echo "#######################"
	echo "#   IS DEBUG STATUS   #"
	echo "#######################"
fi
