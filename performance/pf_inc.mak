##########
# MY_INCLUDE
# MY_MACRO
# MY_FLAGS
# MY_LIBS
#########

TARGET_TIME = $(TARGET_SRC:_pftest.cc=_pftest.time)
TARGET_GPROF = $(TARGET_SRC:_pftest.cc=_pftest.gprof)
TARGET_GPERF = $(TARGET_SRC:_pftest.cc=_pftest.gperf)
TARGET_PERF = $(TARGET_SRC:_pftest.cc=_pftest.perf)

MAIN_DIR := ../..
MARINE_DIR := $(MAIN_DIR)/marine

INCLUDE := $(MY_INCLUDE) -I$(MAIN_DIR)

CXXFLAGS := $(MY_MACRO) $(MY_FLAGS) -Wall -pthread $(INCLUDE)
LIB := $(MY_LIBS) -lrt
CFLAGS := $(CXXFLAGS)
PROTOC := protoc
PROTOCFLAGS := --cpp_out=.

TARGET_SRC := $(wildcard *_pftest.cc)
PB_SRC := $(wildcard *.proto)
PB_CC_SRC := $(PB_SRC:.proto=.pb.cc)
ALL_CC_SRC := $(wildcard *.cc) $(PB_CC_SRC)
CC_SRC := $(filter-out $(TARGET_SRC),$(ALL_CC_SRC))
C_SRC := $(wildcard *.c)

TIME_OBJ := $(CC_SRC:.cc=.time.o) $(C_SRC:.c=.time.o)
GPROF_OBJ := $(CC_SRC:.cc=.gprof.o) $(C_SRC:.c=.gprof.o)
GPERF_OBJ := $(CC_SRC:.cc=.gperf.o) $(C_SRC:.c=.gperf.o)
PERF_OBJ := $(CC_SRC:.cc=.perf.o) $(C_SRC:.c=.perf.o)
TARGET_TIME_OBJ := $(TARGET_SRC:.cc=.time.o)
TARGET_GPROF_OBJ := $(TARGET_SRC:.cc=.gprof.o)
TARGET_GPERF_OBJ := $(TARGET_SRC:.cc=.gperf.o)
TARGET_PERF_OBJ := $(TARGET_SRC:.cc=.perf.o)
ALL_OBJ := $(TIME_OBJ) $(GPROF_OBJ) $(GPERF_OBJ) $(PERF_OBJ) $(TARGET_TIME_OBJ) $(TARGET_GPROF_OBJ) $(TARGET_GPERF_OBJ) $(TARGET_PERF_OBJ)

DEP := $(ALL_CC_SRC:.cc=.d) $(C_SRC:.c=.d)

CXXFLAGS += -MD
CFLAGS += -MD

TIME_FLAGS :=  -D__TIME  -O2 -DNDEBUG
GPROF_FLAGS := -D__GPROF -g -pg
GPERF_FLAGS := -D__GPERF -O2 -DNDEBUG -g
PERF_FLAGS :=  -D__PERF  -O2 -DNDEBUG -g

all: time gprof gperf perf

time: $(TARGET_TIME)

gprof: $(TARGET_GPROF)

gperf: $(TARGET_GPERF)

perf: $(TARGET_PERF)

proto: $(PB_CC_SRC)

%.time: %.time.o $(TIME_OBJ)
	$(CXX) $(TIME_FLAGS) $(CXXFLAGS) -o $@ $^ $(LIB)
	@strip $@

%.gprof: %.gprof.o $(GPROF_OBJ)
	$(CXX) $(GPROF_FLAGS) $(CXXFLAGS) -o $@ $^ $(LIB)

%.gperf: %.gperf.o $(GPERF_OBJ)
	$(CXX) $(GPERF_FLAGS) $(CXXFLAGS) -o $@ $^ $(LIB) -lprofiler

%.perf: %.perf.o $(PERF_OBJ)
	$(CXX) $(PERF_FLAGS) $(CXXFLAGS) -o $@ $^ $(LIB)

%.time.o: %.cc
	$(CXX) $(TIME_FLAGS) $(CXXFLAGS) -c -o $@ $<

%.time.o: %.c
	$(CC) $(TIME_FLAGS) $(CFLAGS) -c -o $@ $<

%.gprof.o: %.cc
	$(CXX) $(GPROF_FLAGS) $(CXXFLAGS) -c -o $@ $<

%.gprof.o: %.c
	$(CC) $(GPROF_FLAGS) $(CFLAGS) -c -o $@ $<

%.gperf.o: %.cc
	$(CXX) $(GPERF_FLAGS) $(CXXFLAGS) -c -o $@ $<

%.gperf.o: %.c
	$(CC) $(GPERF_FLAGS) $(CFLAGS) -c -o $@ $<

%.perf.o: %.cc
	$(CXX) $(PERF_FLAGS) $(CXXFLAGS) -c -o $@ $<

%.perf.o: %.c
	$(CC) $(PERF_FLAGS) $(CFLAGS) -c -o $@ $<

%.pb.cc: %.proto
	$(PROTOC) $(PROTOCFLAGS) $<

clean:
	$(RM) *.time *.gprof *.gperf *.perf perf.data* gmon.out *.pprof
	@find . -name "*.o" | xargs rm -f
	@find . -name "*.d" | xargs rm -f

cleanall: clean
	$(RM) *.log tags
	@find . -name "*.pb.h" | xargs rm -f
	@find . -name "*.pb.cc" | xargs rm -f

.PHONY: all time gprof gperf perf proto clean cleanall

.SECONDARY: $(ALL_OBJ)

ifneq ($(MAKECMDGOALS),clean)      
ifneq ($(MAKECMDGOALS),cleanall)   
sinclude $(DEP)
endif
endif
