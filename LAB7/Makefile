GHDL = ghdl
WAVE = gtkwave
SIM  = processador_tb
GHW  = result_proc.ghw

all: simulate

analyze:
	$(GHDL) -a reg16bits.vhd
	$(GHDL) -a reg1bit.vhd
	$(GHDL) -a banco_regs.vhd
	$(GHDL) -a ULA.vhd
	$(GHDL) -a pc.vhd
	$(GHDL) -a ir.vhd
	$(GHDL) -a maq_estados.vhd
	$(GHDL) -a ram.vhd
	$(GHDL) -a rom.vhd
	$(GHDL) -a uc7.vhd
	$(GHDL) -a processador7.vhd
	$(GHDL) -a processador_tb.vhd

elaborate: analyze
	$(GHDL) -e $(SIM)

simulate: elaborate
	$(GHDL) -r $(SIM) --wave=$(GHW)

wave:
	$(WAVE) $(GHW)

clean:
	rm -f *.o *.cf $(GHW)
