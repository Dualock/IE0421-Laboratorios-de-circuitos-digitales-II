#Banderas:
CC = iverilog #Compilador
#TIME = #Valores de tiempos a utilizar
#LIBS =	#Librerias externas
TESTB = test.v
VCD = arr_multiplier_4b.vcd
EXE = arr_multiplier_4b.o

all: verificacion_array

verificacion_array : exe_Multiplier
#Simular:
	vvp $(EXE)
#Ver en gtkwave:
	gtkwave $(VCD)

exe_Multiplier:
#Compilar:
	@echo "Realizando auto-instanciación..."
	emacs --batch $(TESTB) -f verilog-batch-auto
	@echo "Compilando..."
	$(CC) $(TESTB) cmos_cells.v -o $(EXE)

.PHONY: all clean help
clean:
	rm -f *.o *.vcd
	rm -f $(SYNTH)
help:
	cat README
