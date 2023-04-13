library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo_generica is
    generic (
        addressSize : natural := 5;
        wordSize : natural := 8;
        datFileName : string := "rom.dat"
    );
    port (
        addr : in bit_vector(addressSize -1 downto 0);
        data : out bit_vector(wordSize -1 downto 0)
    );
end rom_arquivo_generica ;

architecture arch of rom_arquivo_generica is

    constant MEM_DEPTH : integer := 2**addressSize;
    type mem_type is array (0 to MEM_DEPTH-1) of bit_vector(wordSize-1 downto 0);
    
    impure function init_mem return mem_type is
        file mif_file : text open read_mode is datFileName;
        variable mif_line : line;
        variable temp_bv : bit_vector(wordSize-1 downto 0);
        variable temp_mem : mem_type;
    begin
        for i in mem_type'range loop
            readline(mif_file, mif_line);
            read(mif_line, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;
    end function;
    
    signal mem : mem_type := init_mem;
    
    begin
        data <= mem(to_integer(unsigned(addr)));
    
end arch;