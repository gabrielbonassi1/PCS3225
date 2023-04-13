library ieee;
use ieee.numeric_bit.all;

entity tb_ram is
end tb_ram;

architecture arch_tb_ram of tb_ram is
    component ram
    generic(
        adressSize : natural := 4;
        wordSize : natural := 8
    );
    port (
        ck, wr : in bit;
        addr : in bit_vector(adressSize -1 downto 0);
        data_i : in bit_vector(wordSize -1 downto 0);
        data_o : out bit_vector(wordSize -1 downto 0)
    );
    end component;

    signal ck, wr : bit;
    signal addr : bit_vector(3 downto 0);
    signal data_i : bit_vector(7 downto 0);
    signal data_o : bit_vector(7 downto 0);

    begin
        raam: ram port map(
            ck => ck,
            wr => wr,
            addr => addr,
            data_i => data_i,
            data_o => data_o
        );

        test: process
        begin
            data_i <= "01010011";
            wait for 100 fs;
            addr <= "0000";
            ck <= '1';
            wr <= '1';
            wait for 100 fs;
            addr <= "0000";
            wait;
        end process;
end arch_tb_ram;
