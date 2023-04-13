library ieee;
use IEEE.numeric_bit.all;
entity contador is
    port(
        clock, reset: in bit;
        count: out bit_vector(8 downto 0)
    );
end entity;

architecture cont_arch of contador is
    signal count1: bit_vector(8 downto 0);
    begin
        p0: process (Clock, Reset) is
            variable counter: integer range 0 to 511;
            begin
             if (Reset = '1') then
                counter := 0; -- valor inicial
            elsif (clock'event and clock='1') then
                    counter := counter + 1;
            end if;
            count1 <= bit_vector(to_unsigned(counter, 9));
            count<= count1;
        end process p0;
end architecture;