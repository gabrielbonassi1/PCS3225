library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity regfile is
    generic(
        regn: natural := 32;
        wordSize: natural := 64
    );
    port(
        clock: in bit;
        reset: in bit;
        regWrite: in bit;
        rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d: in bit_vector(wordSize-1 downto 0);
        q1, q2: out bit_vector(wordSize-1 downto 0)
    );
end regfile;

architecture arch_regfile of regfile is
    type registrador is array(0 to regn-1) of bit_vector(wordSize-1 downto 0);
    signal registradores : registrador;

    begin
        regFile: process(clock, reset)
        begin
            if reset = '1' then
                for I in 0 to regn-1 loop
                    registradores(I) <= (others => '0');
                 end loop;
            elsif clock='1' and clock'event then
                if regWrite='1' and wr/="11111" then
                    registradores(to_integer(unsigned(wr))) <= d;
                end if;
            end if;
            q1 <= registradores(to_integer(unsigned(rr1)));
            q2 <= registradores(to_integer(unsigned(rr2)));
        end process;
end arch_regfile;