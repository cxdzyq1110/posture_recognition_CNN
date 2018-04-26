#!/bin/sh
sopc2dts --input ../../01_altera_ip/soc_system/soc_system.sopcinfo \
		--output soc_system.dts --type dts \
		--board soc_system_board_info.xml \
		--board hps_common_board_info.xml \
		--bridge-removal all --clocks

sopc2dts --input ../../01_altera_ip/soc_system/soc_system.sopcinfo \
		--output soc_system.dtb --type dtb \
		--board soc_system_board_info.xml \
		--board hps_common_board_info.xml \
		--bridge-removal all --clocks