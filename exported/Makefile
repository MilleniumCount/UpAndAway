ifneq ($(wildcard ../make/config.mk),)
 include ../make/config.mk
endif

LUA?=lua

ifndef SCML_COMPILER
 $(error Define and export the path to the scml compiler executable in the variable SCML_COMPILER of your config.mk)
else
 export SCML_COMPILER
endif

FORCEDRUN:=$(findstring B, $(MAKEFLAGS))

MODDIR:=..
TOOLSDIR:=$(MODDIR)/tools

# Lists all the possible build directories.
POSSIBLE_BUILD_NAMES:=$(wildcard *)

# Filters the above by requiring a scml file with the same name of the directories.
BUILD_NAMES:=$(foreach f, $(POSSIBLE_BUILD_NAMES),\
	$(if $(wildcard $(f)/$(f).scml),\
		$(f),\
	)\
)

#SCML_FILES=$(foreach f, $(BUILD_NAMES), $(f)/$(f).scml)

# Build zip names.
BUILD_ZIPS:=$(addprefix $(MODDIR)/anim/, $(addsuffix .zip, $(BUILD_NAMES)))

# Intermediate zips created by the scml compiler.
INTERMEDIATE_ZIPS=$(foreach f, $(BUILD_NAMES), $(f)/$(f).zip)


SCML_FLAGS:=-f --ignore-self-date

# This specifies the log file path used by the scml compiler.
export MODTOOLS_LOG=$(MODDIR)/log/scml_log.txt


# Receives the build name (i.e., scml file name without the ".scml") as argument.
IMAGE_DEPS_OF=$(addprefix $(1)/, $(shell $(LUA) $(TOOLSDIR)/scml_deps.lua $(1)/$(1).scml))

define ADD_BUILD_RULE
 $(MODDIR)/anim/$(1).zip: $(1)/$(1).scml $(call IMAGE_DEPS_OF,$(1)) | cleanlog
	$(TOOLSDIR)/scml_wrapper.sh $(SCML_FLAGS) "$$<" "$(MODDIR)"
endef


.PHONY: cleanlog all clean distclean fiximages


all: $(BUILD_ZIPS)

cleanlog:
	$(RM) $(MODTOOLS_LOG)

clean: cleanlog
	$(RM) $(INTERMEDIATE_ZIPS) $(BUILD_ZIPS)

distclean: cleanlog

fiximages:
	find . -type f -name '*.png' -exec convert {} -colorspace sRGB png32:{} \;

$(foreach build, $(BUILD_NAMES), $(eval $(call ADD_BUILD_RULE,$(build))))
