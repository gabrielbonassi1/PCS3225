library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity tb_rom_arquivo is
end tb_rom_arquivo;

architecture tb of tb_rom_arquivo is
    component rom_arquivo
      port(
        addr : in bit_vector(3 downto 0);
        data : out bit_vector(7 downto 0)
      );
    end component;
    signal addr : bit_vector (3 downto 0);
    signal data : bit_vector (7 downto 0);

    begin
        rom: rom_arquivo port map(
            addr => addr,
            data => data
        );

        test: process
        begin
            report "inicio dos testes";

            addr <= "0001";
            wait for 5 fs;
            assert(data = "00000000")
            report "saidas incorretas";
            wait;
        end process test;
end tb;