--Bancada de Testes para a ULA de 1 bit
entity bancadaTestes is
  --Vazio
end entity;

architecture testes of bancadaTestes is

--Componentes
component alu1bit is
  port(
    a, b, less, cin : in bit;
    result, cout, set, overflow : out bit;
    ainvert, binvert: in bit;
    operation: in bit_vector(1 downto 0)
  );
end component;

--Sinais
signal a_in, b_in, less_in, cin_in, result_out, cout_out, set_out, overflow_out, ainvert_in, binvert_in : bit;
signal operation_in : bit_vector(1 downto 0);

begin

  --Conectar DUT
  ULA: alu1bit port map(
    a => a_in,
    b => b_in,
    less => less_in,
    cin => cin_in,
    result => result_out,
    cout => cout_out,
    set => set_out,
    overflow => overflow_out,
    ainvert => ainvert_in,
    binvert => binvert_in,
    operation => operation_in
  );

  process
  begin

    --Testes AND
    a_in <= '0';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "00";
    wait for 4 ns;
    assert (result_out = '0')
    report "Falha no Teste AND 1, AND"
    severity error;
    assert (set_out = '0')
    report "Falha no Teste AND 1, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste AND 1, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste AND 1, OVRFLW"
    severity error;

    a_in <= '1';
    b_in <= '1';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "00";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste AND 2, AND"
    severity error;
    assert (set_out = '0')
    report "Falha no Teste AND 2, SET"
    severity error;
    assert (cout_out = '1')
    report "Falha no Teste AND 2, COUT"
    severity error;
    assert (overflow_out = '1')
    report "Falha no Teste AND 2, OVRFLW"
    severity error;

    a_in <= '1';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '1';
    operation_in <= "00";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste AND 3, AND"
    severity error;
    assert (set_out = '0')
    report "Falha no Teste AND 3, SET"
    severity error;
    assert (cout_out = '1')
    report "Falha no Teste AND 3, COUT"
    severity error;
    assert (overflow_out = '1')
    report "Falha no Teste AND 3, OVRFLW"
    severity error;

    --Testes OR
    a_in <= '0';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "01";
    wait for 4 ns;
    assert (result_out = '0')
    report "Falha no Teste OR 1, OR"
    severity error;
    assert (set_out = '0')
    report "Falha no Teste OR 1, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste OR 1, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste OR 1, OVRFLW"
    severity error;

    a_in <= '0';
    b_in <= '1';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "01";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste OR 2, OR"
    severity error;
    assert (set_out = '1')
    report "Falha no Teste OR 2, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste OR 2, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste OR 2, OVRFLW"
    severity error;

    a_in <= '0';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '1';
    operation_in <= "01";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste OR 3, OR"
    severity error;
    assert (set_out = '1')
    report "Falha no Teste OR 3, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste OR 3, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste OR 3, OVRFLW"
    severity error;

    --Testes ADD
    a_in <= '0';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "10";
    wait for 4 ns;
    assert (result_out = '0')
    report "Falha no Teste ADD 1, ADD"
    severity error;
    assert (set_out = '0')
    report "Falha no Teste ADD 1, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste ADD 1, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste ADD 1, OVRFLW"
    severity error;

    a_in <= '0';
    b_in <= '1';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "10";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste ADD 2, ADD"
    severity error;
    assert (set_out = '1')
    report "Falha no Teste ADD 2, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste ADD 2, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste ADD 2, OVRFLW"
    severity error;

    a_in <= '0';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '1';
    operation_in <= "10";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste ADD 3, ADD"
    severity error;
    assert (set_out = '1')
    report "Falha no Teste ADD 3, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste ADD 3, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste ADD 3, OVRFLW"
    severity error;

    a_in <= '0';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '1';
    binvert_in <= '1';
    operation_in <= "10";
    wait for 4 ns;
    assert (result_out = '0')
    report "Falha no Teste ADD 4, ADD"
    severity error;
    assert (set_out = '0')
    report "Falha no Teste ADD 4, SET"
    severity error;
    assert (cout_out = '1')
    report "Falha no Teste ADD 4, COUT"
    severity error;
    assert (overflow_out = '1')
    report "Falha no Teste ADD 4, OVRFLW"
    severity error;

    --Testes SLT
    a_in <= '0';
    b_in <= '0';
    less_in <= '1';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "11";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste SLT 1, SLT"
    severity error;
    assert (set_out = '0')
    report "Falha no Teste SLT 1, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste SLT 1, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste SLT 1, OVRFLW"
    severity error;

    a_in <= '1';
    b_in <= '0';
    less_in <= '1';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "11";
    wait for 4 ns;
    assert (result_out = '1')
    report "Falha no Teste SLT 2, SLT"
    severity error;
    assert (set_out = '1')
    report "Falha no Teste SLT 2, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste SLT 2, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste SLT 2, OVRFLW"
    severity error;

    a_in <= '1';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '1';
    binvert_in <= '1';
    operation_in <= "11";
    wait for 4 ns;
    assert (result_out = '0')
    report "Falha no Teste SLT 3, SLT"
    severity error;
    assert (set_out = '1')
    report "Falha no Teste SLT 3, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste SLT 3, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste SLT 3, OVRFLW"
    severity error;

    a_in <= '0';
    b_in <= '1';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "11";
    wait for 4 ns;
    assert (result_out = '0')
    report "Falha no Teste SLT 4, SLT"
    severity error;
    assert (set_out = '1')
    report "Falha no Teste SLT 4, SET"
    severity error;
    assert (cout_out = '0')
    report "Falha no Teste SLT 4, COUT"
    severity error;
    assert (overflow_out = '0')
    report "Falha no Teste SLT 4, OVRFLW"
    severity error;

    --Limpar inputs
    a_in <= '0';
    b_in <= '0';
    less_in <= '0';
    cin_in <= '0';
    ainvert_in <= '0';
    binvert_in <= '0';
    operation_in <= "00";
    wait for 4 ns;
    assert(false)
    report "Testes Finalizados"
    severity note;

    wait;
  end process;
end architecture;
