library IEEE;
use IEEE.numeric_bit.all;

entity mmc is
    port(
        reset, clock: in bit;
        inicia: in bit;
        A,B: in bit_vector(7 downto 0);
        fim: out bit;
        nSomas: out bit_vector(8 downto 0);
        MMC: out bit_vector(15 downto 0)
    );
end mmc;

architecture mmc_arch of mmc is
    component mmc_UC is
        port(
            clock, reset: in bit;
            iniciar: in bit;
            diferente, menor, zero: in bit;
            h1, h2, s1, s2, x1, rst_count: out bit;
            fim: out bit
        );
    end component;

    component mmc_FD is
        port(
            clock, reset: in bit;
            h1, h2, s1, s2, x1, rst_count: in bit;
            diferente, menor, zero: out bit;
            a_en, b_en: in bit_vector(7 downto 0);
            iniciar: in bit;
            nSomas: out bit_vector(8 downto 0);
            mmc: out bit_vector(15 downto 0)
        );
    end component;

    signal h1, h2, s1, s2, x1, diferente, menor, zero, s_rst_count: bit;
    signal clock_n: bit;

    begin
        clock_n <= not(clock);

        xUC: mmc_UC
        port map(
            clock=> clock,
            reset=> reset,
            iniciar=> inicia,
            diferente=> diferente,
            menor=> menor,
            zero=> zero,
            rst_count=> s_rst_count,
            h1=> h1,
            h2=> h2,
            s1=> s1,
            s2=> s2,
            x1=> x1,
            fim=> fim
        );

        xFD: mmc_FD
        port map(
            clock=> clock_n,
            reset=> reset,
            h1=> h1,
            h2=> h2,
            s1=> s1,
            s2=> s2,
            x1=> x1,
            diferente=> diferente,
            menor=> menor,
            zero=> zero,
            rst_count=> s_rst_count,
            a_en=> A,
            b_en=> B,
            iniciar=> inicia,
            nSomas=> nSomas,
            mmc=> MMC
        );
end mmc_arch;

library IEEE;
use IEEE.numeric_bit.all;

entity mmc_UC is
    port(
        clock, reset: in bit;
        iniciar: in bit;
        diferente, menor, zero: in bit;
        h1, h2, s1, s2, x1, rst_count: out bit;
        fim: out bit
    );
end entity;

architecture arch_UC of mmc_UC is

    type state is (espera, igual_zero, teste_a_b, ma_igual_mb, ma_maior_mb, ma_menor_mb);
    signal next_state, current_state: state;

    begin
        process(clock, reset)
        begin
            if reset = '1' then
                current_state <= espera;
            elsif (clock'event and clock = '1') then
                current_state <= next_state;
            end if;
        end process;

    --Proximo estado
    next_state <= espera when (current_state = espera) and (iniciar = '0') else
        teste_a_b when (current_state = espera) and (iniciar = '1') else
        
        igual_zero when (current_state = teste_a_b) and (zero = '1') else
        ma_igual_mb when (current_state = teste_a_b) and (diferente = '0') else
        ma_maior_mb when (current_state = teste_a_b) and (diferente = '1') and (menor = '0') else
        ma_menor_mb when (current_state = teste_a_b) and (diferente = '1') and (menor = '1') else
            
        teste_a_b when (current_state = ma_maior_mb) else
        teste_a_b when (current_state = ma_maior_mb);

    --Decodificando estados
    h1 <= '1' when (current_state = espera) or (current_state = ma_maior_mb) else '0';
    h2 <= '1' when (current_state = espera) or (current_state = ma_menor_mb) else '0';
    s1 <= '1' when (current_state = ma_maior_mb) else '0';
    s2 <= '1' when (current_state = ma_menor_mb) else '0';

    fim <= '1' when (current_state = ma_igual_mb) or (current_state = igual_zero) else '0';
    x1 <= '1' when (current_state = ma_igual_mb) or (current_state = igual_zero) else '0';

    rst_count <= '1' when (current_state = espera) else '0';

end arch_UC;

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

entity register16 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        parallel_in:  in  bit_vector(15 downto 0);
        parallel_out: out bit_vector(15 downto 0)
    );
end entity;

architecture arch_reg of register16 is
    signal internal: bit_vector(15 downto 0);
    begin
        process(clock, reset)
        begin
            if reset = '1' then -- reset assincrono
                internal <= (others => '0'); -- "000000"
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    internal <= parallel_in;
                end if;
            end if; 
        end process;
        parallel_out <= internal;
end architecture;

entity register9 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        parallel_in:  in  bit_vector(8 downto 0);
        parallel_out: out bit_vector(8 downto 0)
    );
end entity;

architecture arch_reg of register9 is
    signal internal: bit_vector(8 downto 0);
    begin
        process(clock, reset)
        begin
            if reset = '1' then -- reset assincrono
                internal <= (others => '0'); -- "000000"
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    internal <= parallel_in;
                end if;
            end if; 
        end process;
        parallel_out <= internal;
end architecture;

entity register8 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        parallel_in:  in  bit_vector(7 downto 0);
        parallel_out: out bit_vector(7 downto 0)
    );
end entity;

architecture arch_reg of register8 is
    signal internal: bit_vector(7 downto 0);
    begin
        process(clock, reset)
        begin
            if reset = '1' then -- reset assincrono
                internal <= (others => '0'); -- "000000"
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    internal <= parallel_in;
                end if;
            end if; 
        end process;
        parallel_out <= internal;
end architecture;