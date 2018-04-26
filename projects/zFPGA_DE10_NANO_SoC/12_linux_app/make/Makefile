#
TARGET = my_first_hps-fpga

#
CROSS_COMPILE = arm-linux-gnueabihf-
CFLAGS = -static -g -Wall  -I${SOCEDS_DEST_ROOT}/ip/altera/hps/altera_hps/hwlib/include
LDFLAGS =  -g -Wall -lpthread
CC = $(CROSS_COMPILE)gcc
ARCH= arm

VPATH = ../source:../include

OBJECTS = main.o cnn.o npu.o hps_fpga_inf.o optical_flow.o merge_bbox.o plot.o sample.o pedestrian.o graphic.o key_respond.o 

$(TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -g $^ -o $@  
	
main.o : main.c
	$(CC) $(CFLAGS) -c $< -lpthread -o $@	
	
cnn.o : cnn.c
	$(CC) $(CFLAGS) -c $< -o $@
	
npu.o : npu.c
	$(CC) $(CFLAGS) -c $< -o $@
	
hps_fpga_inf.o : hps_fpga_inf.c
	$(CC) $(CFLAGS) -c $< -o $@
	
optical_flow.o : optical_flow.c
	$(CC) $(CFLAGS) -c $< -o $@
	
merge_bbox.o : merge_bbox.c
	$(CC) $(CFLAGS) -c $< -o $@
	
plot.o : plot.c
	$(CC) $(CFLAGS) -c $< -o $@
	
sample.o : sample.c
	$(CC) $(CFLAGS) -c $< -o $@
	
pedestrian.o : pedestrian.c
	$(CC) $(CFLAGS) -c $< -o $@
	
graphic.o : graphic.c
	$(CC) $(CFLAGS) -c $< -o $@
	
key_respond.o : key_respond.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ 
