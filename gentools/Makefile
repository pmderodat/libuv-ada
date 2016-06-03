HOST_GCC=g++
TARGET_GCC=gcc
PLUGIN_SOURCE_FILES= bind-enums.cc
GCCPLUGINS_DIR:= $(shell $(TARGET_GCC) -print-file-name=plugin)
CXXFLAGS+= -I$(GCCPLUGINS_DIR)/include -fPIC -fno-rtti -O0 -g3 -Wall -Wextra

bind-enums.so: $(PLUGIN_SOURCE_FILES)
	$(HOST_GCC) -shared $(CXXFLAGS) $^ -o $@
