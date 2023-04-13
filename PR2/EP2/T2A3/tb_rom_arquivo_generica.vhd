library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity tb_rom_arquivo_generica is
end tb_rom_arquivo_generica;

architecture tb of tb_rom_arquivo_generica is
    component rom_arquivo_generica
      generic (
        addressSize : natural := 4;
        wordSize : natural := 8;
        datFileName : string := "rom.dat"
      );
      port(
        addr : in bit_vector(addressSize -1 downto 0);
        data : out bit_vector(wordSize -1 downto 0)
      );
    end component;
    signal addr : bit_vector (3 downto 0);
    signal data : bit_vector (7 downto 0);

    begin
        rom: rom_arquivo_generica port map(
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
