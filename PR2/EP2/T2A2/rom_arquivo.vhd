library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo is
    port (
        addr : in bit_vector(4 downto 0) ;
        data : out bit_vector(7 downto 0)
    );
end rom_arquivo;

architecture arch_rom_arquivo of rom_arquivo is

    type mem_type is array (0 to 4) of bit_vector(7 downto 0);
    
    impure function init_mem return mem_type is
        file mif_file : text open read_mode is "conteudo_rom_ativ_02_carga.dat";
        variable mif_line : line;
        variable temp_bv : bit_vector(7 downto 0);
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

end arch_rom_arquivo;