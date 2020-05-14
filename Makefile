#
# This is the makefile for diablo.
# To compile the code, just type make.  Such an approach makes
# recompilation of the code easy, recompiling only as necessary
# to account for recent changes to the code.
#

COMPILER = mpif90  -qopenmp -g -traceback#-vec-report0 -nus -mcmodel=medium #-debug -vec-report0 #-check all -warn all,nodec,interfaces -gen-interfaces -traceback -fpe0 -fp-stack-check
COMPOPTS = #-O3 #-I/usr/local/include -I/opt/intel/fce/10.1.008/lib/ #-i-dynamic 
LINKOPTS =  -lrfftw -lfftw -shared-intel # -i-dynamic
PARALLEL = TRUE
LES = FALSE
DUCT = TRUE
CHAN = FALSE

ifeq ($(LES),TRUE)
LES_CHAN = les_chan.o les_chan_th.o
#LES_CHAN = les_chan.o 
else
LES_CHAN = no_les.o
endif

#ifeq ($(DUCT),TRUE)
#DUCT_CASE = duct.o
#else
#CHAN_CASE = chan_baines.o
#endif


ifeq ($(PARALLEL),TRUE)
diablo: diablo.F90 modules.o allocation.o periodic.o $(LES_CHAN) \
	duct.o cavity.o fft.o mpi_duct.o wall_model.o boundary.o flow_statistic.o saved_stat_file.o create_flow_duct.o dstretch.o dmgd9v.o\
	 grid_def 
	$(COMPILER) $(COMPOPTS) diablo.F90 -o diablo \
	periodic.o $(LES_CHAN) \
	duct.o cavity.o fft.o mpi_duct.o wall_model.o boundary.o flow_statistic.o saved_stat_file.o create_flow_duct.o dstretch.o dmgd9v.o modules.o allocation.o $(LINKOPTS)
else
diablo: diablo.F90 modules.o allocation.o periodic.o $(LES_CHAN) \
        duct.o cavity.o fft.o mpi_chan_serial.o wall_model.o boundary.o flow_statistic.o saved_stat_file.o create_flow_duct.o dstretch.o dmgd9v.o\
         grid_def 
	$(COMPILER) $(COMPOPTS) diablo.F90 -o diablo \
        periodic.o $(LES_CHAN) \
	duct.o cavity.o fft.o mpi_chan_serial.o wall_model.o boundary.o flow_statistic.o saved_stat_file.o create_flow_duct.o dstretch.o dmgd9v.o modules.o allocation.o $(LINKOPTS)
endif

periodic.o: periodic.F90 fft.o  grid_def
	$(COMPILER) $(COMPOPTS) -c periodic.F90

#channel_baines.o: channel_baines.f fft.o mpi_chan_serial.o wall_model.o  grid_def
#	$(COMPILER) $(COMPOPTS) -c channel_baines.f

ifeq ($(LES),TRUE) 
les_chan.o: les_chan.F90 fft.o   grid_def
	$(COMPILER) $(COMPOPTS) -c les_chan.F90

les_chan_th.o: les_chan_th.F90 fft.o   grid_def
	$(COMPILER) $(COMPOPTS) -c les_chan_th.F90
else
no_les.o: no_les.F90
	$(COMPILER) $(COMPOPTS) -c no_les.F90
endif

ifeq ($(PARALLEL),TRUE)
mpi_duct.o: mpi_duct.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c mpi_duct.F90

duct.o: duct.F90 fft.o mpi_duct.o wall_model.o  grid_def
	$(COMPILER) $(COMPOPTS) -c duct.F90
else
mpi_chan_serial.o: mpi_chan_serial.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c mpi_chan_serial.F90

duct.o: duct.F90 fft.o mpi_chan_serial.o wall_model.o  grid_def
	$(COMPILER) $(COMPOPTS) -c duct.F90
endif



cavity.o: cavity.F90  grid_def
	$(COMPILER) $(COMPOPTS) -c cavity.F90

fft.o:  fft.F90  grid_def
	$(COMPILER) $(COMPOPTS) -c fft.F90

wall_model.o:   wall_model.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c wall_model.F90

boundary.o: boundary.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c boundary.F90

flow_statistic.o: flow_statistic.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c flow_statistic.F90

saved_stat_file.o: saved_stat_file.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c saved_stat_file.F90

create_flow_duct.o: create_flow_duct.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c create_flow_duct.F90

dmgd9v.o: dmgd9v.f   grid_def
	$(COMPILER) $(COMPOPTS) -c dmgd9v.f

dstretch.o: dstretch.F90   grid_def
	$(COMPILER) $(COMPOPTS) -c dstretch.F90

allocation.o:   allocation.F90  modules.o
	$(COMPILER) $(COMPOPTS) -c allocation.F90

modules.o:      modules.F90 grid_def
	$(COMPILER) $(COMPOPTS) -c modules.F90

clean:
	rm -f *.o fort.* *~ diablo core *.mod *.o* *genmod*

# Compiler specific notes:
#
# Compilation with Absoft Linux Fortran 77 appears to be impossible, as it
# cannot handle the INTEGER*8 option required by FFTW.  If someone finds
# a way around this, please let me know.
# 
# Compilation with Absoft Linux Fortran 90 is possible, but the option
# -YEXT_NAMES=LCS must be used as one of the link options so the compiler
# can find the lowercase external library function names.
#
# Compilation with Lahey Fortran 95 (lf95) is possible, but there is an
# underscore incompatability with the FFTW libraries, which are compiled
# with g77.  To get around this, you need to go into fft.f and add 
# trailing underscores to the name of every fftw function where they
# appear throughout the code.

