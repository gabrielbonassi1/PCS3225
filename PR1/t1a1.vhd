entity mmc is
    port(
        reset, clock: in bit;
        inicia: in bit;
        A, B: in bit_vector(7 downto 0);
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