library ieee;
use ieee.numeric_bit.all;

entity decoder is
    generic(
        inp_Size: natural := 5
    );
    port(
        in_bv: in bit_vector(inp_Size-1 downto 0);
        out_bv: out bit_vector((2**inp_Size)-1 downto 0)
    );
end entity;

architecture decoder_arch of decoder is
    signal index: integer;
begin
    index <= to_integer(unsigned(in_bv));
    dec: for i in (2**inp_Size)-1 downto 0 generate
        out_bv(i) <= '1' when index = i else '0';
    end generate;
end architecture;