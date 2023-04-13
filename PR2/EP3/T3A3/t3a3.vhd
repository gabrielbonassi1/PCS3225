library ieee;
use ieee.numeric_bit.all;

entity calc is
    port(
        clock: in bit;
        reset: in bit;
        instruction: in bit_vector(15 downto 0);
        overflow: out bit;
        q1: out bit_vector(15 downto 0)
    );
end calc;

architecture arch_calc of calc is

    component regfile
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
    end component;

    signal s_regWrite: bit;
    signal s_rr1, s_rr2, s_wr: bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
    signal s_d, s_q1, s_q2: bit_vector(wordSize-1 downto 0);

    begin

        REG: regfile port map (
            clock=> clock,
            reset=> reset,
            regWrite=> s_regWrite,
            rr1=> s_rr1,
            rr2=> s_rr2,
            wr=> s_wr,
            d=> s_d,
            q1=> s_q1,
            q2=> s_q2
        );

        process(clock, reset)
        begin
            if reset = '1' then
                for I in 0 to regn-1 loop
                    registradores(I) <= (others => '0');
                 end loop;
            elsif clock='1' and clock'event then
                if instruction(0) = '1' then
                    s_rr2 <= instruction(1) & instruction(2) & instruction(3) & instruction(4) & instruction(5);
                    s_rr1 <= instruction(6) & instruction(7) & instruction(8) & instruction(9) & instruction(10);
                    
            end if;
        end process;