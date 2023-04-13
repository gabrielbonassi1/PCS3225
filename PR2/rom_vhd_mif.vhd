library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity rom_vhd_mif is
    generic (
        ADDR_WIDTH       : integer := 8;        
        DATA_WIDTH       : integer := 8
    );
    port (
        clk_i     : in  std_logic;
        addr_i    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);          
        data_o    : out signed(DATA_WIDTH-1 downto 0)
    );
end rom_vhd_mif;

architecture rtl of rom_vhd_mif is

constant MEM_DEPTH : integer := 2**ADDR_WIDTH;
type mem_type is array (0 to MEM_DEPTH-1) of signed(DATA_WIDTH-1 downto 0);

impure function init_mem(mif_file_name : in string) return mem_type is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
    variable temp_mem : mem_type;
begin
    for i in mem_type'range loop
        readline(mif_file, mif_line);
        read(mif_line, temp_bv);
        temp_mem(i) := signed(to_stdlogicvector(temp_bv));
    end loop;
    return temp_mem;
end function;

constant mem : mem_type := init_mem("mem_init_vhd.mif");

begin

process (clk_i)
begin
    if rising_edge(clk_i) then
	     data_o <= mem(to_integer(unsigned(addr_i)));
    end if;
end process;

end rtl;
