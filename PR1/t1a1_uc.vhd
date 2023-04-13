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