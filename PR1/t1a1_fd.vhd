library IEEE;
use IEEE.numeric_bit.all;

entity mmc_FD is
    port(
        clock, reset: in bit;
        h1, h2, s1, s2, x1, rst_count: in bit;
        diferente, menor, zero: out bit;
        a_en, b_en: in bit_vector(7 downto 0);
        iniciar: in bit;
        nSomas: out bit_vector(8 downto 0);
        mmc: out bit_vector(15 downto 0)
    );
end entity;

architecture arch_FD of mmc_FD is

    component register8 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            parallel_in:  in  bit_vector(7 downto 0);
            parallel_out: out bit_vector(7 downto 0)
        );
    end component;

    component register9 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            parallel_in:  in  bit_vector(8 downto 0);
            parallel_out: out bit_vector(8 downto 0)
        );
    end component;

    component register16 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            parallel_in:  in  bit_vector(15 downto 0);
            parallel_out: out bit_vector(15 downto 0)
        );
    end component;

    component contador is
        port(
            clock, reset: in bit;
            count: out bit_vector(8 downto 0)
        );
    end component;

    signal ma, mb: bit_vector(7 downto 0);
    signal a_in, b_in: bit_vector(7 downto 0);
    signal arm_a: bit_vector(15 downto 0);
    signal counter: bit_vector(8 downto 0);

    begin

        

        regmA: register8
        port map (
            clock=> clock,
            reset=> reset,
            load=> h1,
            parallel_in=> a_in,
            parallel_out=> ma
        );

        regmB: register8
        port map (
            clock=> clock,
            reset=> reset,
            load=> h2,
            parallel_in=> b_in,
            parallel_out=> mb
        );

        regSomas: register9
        port map (
            clock=> clock,
            reset=> reset,
            load=> h2,
            parallel_in=> counter,
            parallel_out=> nSomas
        );

        regMMC: register16
        port map (
            clock=> clock,
            reset=> reset,
            load=> x1,
            parallel_in=> arm_a,
            parallel_out=> mmc
        );

        cont: contador
        port map (
            clock=> clock,
            reset=> rst_count,
            count=> counter
        );
        

        a_in <= "00000000" when (a_en = "00000000") else
            bit_vector(unsigned(a_en)) when (s1 = '0') else
                bit_vector(to_unsigned((to_integer(unsigned(ma))) + (to_integer(unsigned(a_en))), 8));

        b_in <= "00000000" when (b_en = "00000000") else
            bit_vector(unsigned(b_en)) when (s2 = '0') else
                bit_vector(to_unsigned((to_integer(unsigned(mb))) + (to_integer(unsigned(b_en))), 8));

        arm_a <= "00000000" & a_in;

        diferente <= '1' when (ma /= mb) else '0';
        menor <= '1' when (ma < mb) else '0';
        zero <= '1' when (ma = "00000000") or (mb = "00000000") else '0';

end arch_FD;