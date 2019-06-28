SUBDIRS = kernel

.PHONY: all clean

all:
	for dir in $(SUBDIRS); do $(MAKE) all -C $$dir $@; done

clean:
	rm ./kernel-pack/*.log
	rm ./kernel-pack/*.render
	rm ./kernel-pack/driver.*
	for dir in $(SUBDIRS); do $(MAKE) clean -C $$dir $@; done
	
