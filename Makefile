# based on http://voidptr.io/blog/2017/01/21/GameBoy.html

rwildcard       =   $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
ASM             :=  rgbasm
LINKER          :=  rgblink
FIX             :=  rgbfix
BUILD_DIR       :=  build
SRC_DIR         :=  src
SRC_ASM         :=  
INC_DIR         :=  inc/
ASMFLAGS        :=  -p0
FIXFLAGS        :=  -O -f gh
FIX16			:=	0
DX				:=	0

ifeq ($(FIX16),0)
ifeq ($(DX),0)
FIX16			:= 	2
DX				:= 	1
endif
endif

ifneq ($(FIX16),0)
PROJECT_NAME    :=  fb2k_16
SRC_ASM			+= 	$(SRC_DIR)/16.asm
ifeq ($(FIX16),2)
ASMFLAGS 		+= 	-D _FIX16_FULL
endif
endif

ifneq ($(DX),0)
PROJECT_NAME    =  	fb2k_dx
SRC_ASM			+= 	$(SRC_DIR)/dx.asm
ifeq ($(DX),2)
ASMFLAGS 		+= 	-D _USE_GDMA
endif
endif

OUTPUT          :=  $(BUILD_DIR)/$(PROJECT_NAME)
OBJ_FILES       :=  $(addprefix $(BUILD_DIR)/obj/, $(SRC_ASM:src/%.asm=%.obj))
OBJ_DIRS        :=  $(sort $(addprefix $(BUILD_DIR)/obj/, $(dir $(SRC_ASM:src/%.asm=%.obj))))
LINKERFLAGS     :=  -m $(OUTPUT).map -n $(OUTPUT).sym -d

.PHONY: all clean

all: build

build: $(OBJ_FILES)
	$(LINKER) -O fb2k.gb -o $(OUTPUT).gb $(LINKERFLAGS) $(OBJ_FILES)
	$(FIX) $(FIXFLAGS) $(OUTPUT).gb
 
$(BUILD_DIR)/obj/%.obj : src/%.asm | $(OBJ_DIRS)
	$(ASM) -o $@ $(ASMFLAGS) $<

$(OBJ_DIRS): 
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
