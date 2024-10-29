# where py object files go (they have a name prefix to prevent filename clashes)
PY_BUILD = $(BUILD)/py

# where autogenerated header files go
HEADER_BUILD = $(BUILD)/genhdr

# file containing qstr defs for the core Python bit
PY_QSTR_DEFS = $(PY_SRC)/qstrdefs.h

# If qstr autogeneration is not disabled we specify the output header
# for all collected qstrings.
ifneq ($(QSTR_AUTOGEN_DISABLE),1)
QSTR_DEFS_COLLECTED = $(HEADER_BUILD)/qstrdefs.collected.h
endif

# Any files listed by these variables will cause a full regeneration of qstrs
# DEPENDENCIES: included in qstr processing; REQUIREMENTS: not included
QSTR_GLOBAL_DEPENDENCIES += $(PY_SRC)/mpconfig.h mpconfigport.h
QSTR_GLOBAL_REQUIREMENTS += $(HEADER_BUILD)/mpversion.h

# some code is performance bottleneck and compiled with other optimization options
CSUPEROPT = -O3

# Enable building 32-bit code on 64-bit host.
ifeq ($(MICROPY_FORCE_32BIT),1)
CC += -m32
CXX += -m32
LD += -m32
endif

#LittlevGL
LVGL_BINDING_DIR = $(TOP)/lib/lv_bindings
LVGL_DIR = $(LVGL_BINDING_DIR)/lvgl
LVGL_GENERIC_DRV_DIR = $(LVGL_BINDING_DIR)/driver/generic
INC += -I$(LVGL_BINDING_DIR) -I${LVGL_DIR}
ALL_LVGL_SRC = $(shell find $(LVGL_DIR) -type f -name '*.h') $(LVGL_BINDING_DIR)/lv_conf.h
LVGL_PP = $(BUILD)/lvgl/lvgl.pp.c
LVGL_MPY = $(BUILD)/lvgl/lv_mpy.c
LVGL_MPY_METADATA = $(BUILD)/lvgl/lv_mpy.json
QSTR_GLOBAL_DEPENDENCIES += $(LVGL_MPY)
CFLAGS_MOD += $(LV_CFLAGS)

$(LVGL_MPY): $(ALL_LVGL_SRC) $(LVGL_BINDING_DIR)/gen/gen_mpy.py
	$(ECHO) "LVGL-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CPP) $(CFLAGS_MOD) -DPYCPARSER -x c -I $(LVGL_BINDING_DIR)/pycparser/utils/fake_libc_include $(INC) $(LVGL_DIR)/lvgl.h > $(LVGL_PP)
	$(Q)$(PYTHON) $(LVGL_BINDING_DIR)/gen/gen_mpy.py -M lvgl -MP lv -MD $(LVGL_MPY_METADATA) -E $(LVGL_PP) $(LVGL_DIR)/lvgl.h > $@

.PHONY: LVGL_MPY
LVGL_MPY: $(LVGL_MPY)

CFLAGS_MOD += -Wno-unused-function
SRC_MOD += $(subst $(TOP)/,,$(shell find $(LVGL_DIR)/src $(LVGL_DIR)/examples $(LVGL_GENERIC_DRV_DIR) -type f -name "*.c") $(LVGL_MPY))

#lodepng
LODEPNG_DIR = $(TOP)/lib/lv_bindings/driver/png/lodepng
MP_LODEPNG_C = $(TOP)/lib/lv_bindings/driver/png/mp_lodepng.c
ALL_LODEPNG_SRC = $(shell find $(LODEPNG_DIR) -type f)
LODEPNG_MODULE = $(BUILD)/lodepng/mp_lodepng.c
LODEPNG_C = $(BUILD)/lodepng/lodepng.c
LODEPNG_PP = $(BUILD)/lodepng/lodepng.pp.c
INC += -I$(LODEPNG_DIR)
LODEPNG_CFLAGS += -DLODEPNG_NO_COMPILE_ENCODER -DLODEPNG_NO_COMPILE_DISK -DLODEPNG_NO_COMPILE_ALLOCATORS
CFLAGS_MOD += $(LODEPNG_CFLAGS)

$(LODEPNG_MODULE): $(ALL_LODEPNG_SRC) $(LVGL_BINDING_DIR)/gen/gen_mpy.py
	$(ECHO) "LODEPNG-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CPP) $(LODEPNG_CFLAGS) -DPYCPARSER -x c $(INC) -I $(LVGL_BINDING_DIR)/pycparser/utils/fake_libc_include $(LODEPNG_DIR)/lodepng.h > $(LODEPNG_PP)
	$(Q)$(PYTHON) $(LVGL_BINDING_DIR)/gen/gen_mpy.py -M lodepng -E $(LODEPNG_PP) $(LODEPNG_DIR)/lodepng.h > $@

$(LODEPNG_C): $(LODEPNG_DIR)/lodepng.cpp $(LODEPNG_DIR)/*
	$(Q)mkdir -p $(dir $@)
	cp $< $@

SRC_MOD += $(subst $(TOP)/,,$(LODEPNG_C) $(MP_LODEPNG_C) $(LODEPNG_MODULE))

# External modules written in C.
ifneq ($(USER_C_MODULES),)
# pre-define USERMOD variables as expanded so that variables are immediate
# expanded as they're added to them
SRC_USERMOD :=
SRC_USERMOD_CXX :=
CFLAGS_USERMOD :=
CXXFLAGS_USERMOD :=
LDFLAGS_USERMOD :=
$(foreach module, $(wildcard $(USER_C_MODULES)/*/micropython.mk), \
    $(eval USERMOD_DIR = $(patsubst %/,%,$(dir $(module))))\
    $(info Including User C Module from $(USERMOD_DIR))\
	$(eval include $(module))\
)

SRC_MOD += $(patsubst $(USER_C_MODULES)/%.c,%.c,$(SRC_USERMOD))
SRC_MOD_CXX += $(patsubst $(USER_C_MODULES)/%.cpp,%.cpp,$(SRC_USERMOD_CXX))
CFLAGS_MOD += $(CFLAGS_USERMOD)
CXXFLAGS_MOD += $(CXXFLAGS_USERMOD)
LDFLAGS_MOD += $(LDFLAGS_USERMOD)
endif

# py object files
PY_CORE_O_BASENAME = $(addprefix py/,\
	mpstate.o \
	nlr.o \
	nlrx86.o \
	nlrx64.o \
	nlrthumb.o \
	nlraarch64.o \
	nlrpowerpc.o \
	nlrxtensa.o \
	nlrsetjmp.o \
	malloc.o \
	gc.o \
	pystack.o \
	qstr.o \
	vstr.o \
	mpprint.o \
	unicode.o \
	mpz.o \
	reader.o \
	lexer.o \
	parse.o \
	scope.o \
	compile.o \
	emitcommon.o \
	emitbc.o \
	asmbase.o \
	asmx64.o \
	emitnx64.o \
	asmx86.o \
	emitnx86.o \
	asmthumb.o \
	emitnthumb.o \
	emitinlinethumb.o \
	asmarm.o \
	emitnarm.o \
	asmxtensa.o \
	emitnxtensa.o \
	emitinlinextensa.o \
	emitnxtensawin.o \
	formatfloat.o \
	parsenumbase.o \
	parsenum.o \
	emitglue.o \
	persistentcode.o \
	runtime.o \
	runtime_utils.o \
	scheduler.o \
	nativeglue.o \
	pairheap.o \
	ringbuf.o \
	stackctrl.o \
	argcheck.o \
	warning.o \
	profile.o \
	map.o \
	obj.o \
	objarray.o \
	objattrtuple.o \
	objbool.o \
	objboundmeth.o \
	objcell.o \
	objclosure.o \
	objcomplex.o \
	objdeque.o \
	objdict.o \
	objenumerate.o \
	objexcept.o \
	objfilter.o \
	objfloat.o \
	objfun.o \
	objgenerator.o \
	objgetitemiter.o \
	objint.o \
	objint_longlong.o \
	objint_mpz.o \
	objlist.o \
	objmap.o \
	objmodule.o \
	objobject.o \
	objpolyiter.o \
	objproperty.o \
	objnone.o \
	objnamedtuple.o \
	objrange.o \
	objreversed.o \
	objset.o \
	objsingleton.o \
	objslice.o \
	objstr.o \
	objstrunicode.o \
	objstringio.o \
	objtuple.o \
	objtype.o \
	objzip.o \
	opmethods.o \
	sequence.o \
	stream.o \
	binary.o \
	builtinimport.o \
	builtinevex.o \
	builtinhelp.o \
	modarray.o \
	modbuiltins.o \
	modcollections.o \
	modgc.o \
	modio.o \
	modmath.o \
	modcmath.o \
	modmicropython.o \
	modstruct.o \
	modsys.o \
	moduerrno.o \
	modthread.o \
	vm.o \
	bc.o \
	showbc.o \
	repl.o \
	smallint.o \
	frozenmod.o \
	)

PY_EXTMOD_O_BASENAME = \
	extmod/moduasyncio.o \
	extmod/moductypes.o \
	extmod/modujson.o \
	extmod/moduos.o \
	extmod/modure.o \
	extmod/moduzlib.o \
	extmod/moduheapq.o \
	extmod/modutimeq.o \
	extmod/moduhashlib.o \
	extmod/moducryptolib.o \
	extmod/modubinascii.o \
	extmod/virtpin.o \
	extmod/machine_bitstream.o \
	extmod/machine_mem.o \
	extmod/machine_pinbase.o \
	extmod/machine_signal.o \
	extmod/machine_pulse.o \
	extmod/machine_pwm.o \
	extmod/machine_i2c.o \
	extmod/machine_spi.o \
	extmod/modbluetooth.o \
	extmod/modussl_axtls.o \
	extmod/modussl_mbedtls.o \
	extmod/moduplatform.o\
	extmod/modurandom.o \
	extmod/moduselect.o \
	extmod/moduwebsocket.o \
	extmod/modwebrepl.o \
	extmod/modframebuf.o \
	extmod/vfs.o \
	extmod/vfs_blockdev.o \
	extmod/vfs_reader.o \
	extmod/vfs_posix.o \
	extmod/vfs_posix_file.o \
	extmod/vfs_fat.o \
	extmod/vfs_fat_diskio.o \
	extmod/vfs_fat_file.o \
	extmod/vfs_lfs.o \
	extmod/utime_mphal.o \
	extmod/uos_dupterm.o \
	shared/libc/abort_.o \
	shared/libc/printf.o \

# prepend the build destination prefix to the py object files
PY_CORE_O = $(addprefix $(BUILD)/, $(PY_CORE_O_BASENAME))
PY_EXTMOD_O = $(addprefix $(BUILD)/, $(PY_EXTMOD_O_BASENAME))

# this is a convenience variable for ports that want core, extmod and frozen code
PY_O = $(PY_CORE_O) $(PY_EXTMOD_O)

# object file for frozen code specified via a manifest
ifneq ($(FROZEN_MANIFEST),)
PY_O += $(BUILD)/$(BUILD)/frozen_content.o
endif

# Sources that may contain qstrings
SRC_QSTR_IGNORE = py/nlr%
SRC_QSTR += $(SRC_MOD) $(filter-out $(SRC_QSTR_IGNORE),$(PY_CORE_O_BASENAME:.o=.c)) $(PY_EXTMOD_O_BASENAME:.o=.c)

# Anything that depends on FORCE will be considered out-of-date
FORCE:
.PHONY: FORCE

$(HEADER_BUILD)/mpversion.h: FORCE | $(HEADER_BUILD)
	$(Q)$(PYTHON) $(PY_SRC)/makeversionhdr.py $@

# mpconfigport.mk is optional, but changes to it may drastically change
# overall config, so they need to be caught
MPCONFIGPORT_MK = $(wildcard mpconfigport.mk)

# qstr data
# Adding an order only dependency on $(HEADER_BUILD) causes $(HEADER_BUILD) to get
# created before we run the script to generate the .h
# Note: we need to protect the qstr names from the preprocessor, so we wrap
# the lines in "" and then unwrap after the preprocessor is finished.
# See more information about this process in docs/develop/qstr.rst.
$(HEADER_BUILD)/qstrdefs.generated.h: $(PY_QSTR_DEFS) $(QSTR_DEFS) $(QSTR_DEFS_COLLECTED) $(PY_SRC)/makeqstrdata.py mpconfigport.h $(MPCONFIGPORT_MK) $(PY_SRC)/mpconfig.h | $(HEADER_BUILD)
	$(ECHO) "GEN $@"
	$(Q)$(CAT) $(PY_QSTR_DEFS) $(QSTR_DEFS) $(QSTR_DEFS_COLLECTED) | $(SED) 's/^Q(.*)/"&"/' | $(CPP) $(CFLAGS) - | $(SED) 's/^\"\(Q(.*)\)\"/\1/' > $(HEADER_BUILD)/qstrdefs.preprocessed.h
	$(Q)$(PYTHON) $(PY_SRC)/makeqstrdata.py $(HEADER_BUILD)/qstrdefs.preprocessed.h > $@

$(HEADER_BUILD)/compressed.data.h: $(HEADER_BUILD)/compressed.collected
	$(ECHO) "GEN $@"
	$(Q)$(PYTHON) $(PY_SRC)/makecompresseddata.py $< > $@

# build a list of registered modules for py/objmodule.c.
$(HEADER_BUILD)/moduledefs.h: $(HEADER_BUILD)/moduledefs.collected
	@$(ECHO) "GEN $@"
	$(Q)$(PYTHON) $(PY_SRC)/makemoduledefs.py $< > $@

# Standard C functions like memset need to be compiled with special flags so
# the compiler does not optimise these functions in terms of themselves.
CFLAGS_BUILTIN ?= -ffreestanding -fno-builtin -fno-lto
$(BUILD)/shared/libc/string0.o: CFLAGS += $(CFLAGS_BUILTIN)

# Force nlr code to always be compiled with space-saving optimisation so
# that the function preludes are of a minimal and predictable form.
$(PY_BUILD)/nlr%.o: CFLAGS += -Os

# optimising gc for speed; 5ms down to 4ms on pybv2
$(PY_BUILD)/gc.o: CFLAGS += $(CSUPEROPT)

# optimising vm for speed, adds only a small amount to code size but makes a huge difference to speed (20% faster)
$(PY_BUILD)/vm.o: CFLAGS += $(CSUPEROPT)
# Optimizing vm.o for modern deeply pipelined CPUs with branch predictors
# may require disabling tail jump optimization. This will make sure that
# each opcode has its own dispatching jump which will improve branch
# branch predictor efficiency.
# https://marc.info/?l=lua-l&m=129778596120851
# http://hg.python.org/cpython/file/b127046831e2/Python/ceval.c#l828
# http://www.emulators.com/docs/nx25_nostradamus.htm
#-fno-crossjumping

# Include rules for extmod related code
include $(TOP)/extmod/extmod.mk
