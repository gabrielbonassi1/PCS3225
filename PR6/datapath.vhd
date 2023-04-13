library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

entity datapath is
    port(
        -- Common
        clock: in bit;
        reset: in bit;
        -- From Control Unit
        reg2loc: in bit;
        pcsrc: in bit;
        memToReg: in bit;
        aluCtrl: in bit_vector(3 downto 0);
        aluSrc: in bit;
        regWrite: in bit;
        -- To Control Unit
        opcode: out bit_vector(10 downto 0);
        zero: out bit;
        -- IM interface
        imAddr: out bit_vector(63 downto 0);
        imOut: in bit_vector(31 downto 0);
        -- DM interface
        dmAddr: out bit_vector(63 downto 0);
        dmIn: out bit_vector(63 downto 0);
        dmOut: in bit_vector(63 downto 0)
    );
end datapath;

architecture datapath_arch of datapath is
    --Componentes

    component regfile is --Banco de registradores
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

    component alu is --Unidade Logico-Aritmetica (serve para os dois somadores)
        generic(
            size: natural := 10
        );
        port(
            A, B: in bit_vector(size-1 downto 0); -- inputs
            F: out bit_vector(size-1 downto 0); -- outputs
            S: in bit_vector(3 downto 0); -- op selection
            Z: out bit; -- zero flag
            Ov: out bit; -- overflow flag
            Co: out bit -- carry out
        );
    end component;

    component signExtend is --Unidade funcional signExtend
        port(
            i: in  bit_vector(31 downto 0); -- input
            o: out bit_vector(63 downto 0) -- output
        );
    end component;

    component Shiftleft2 is --Unidade funcional Shiftleft2
        port(
            i: in bit_vector(63 downto 0);
            o: out bit_vector(63 downto 0)
        );
    end component Shiftleft2;

    component reg is -- Program Counter
        generic(
            wordSize: natural := 64 -- Parametrizado para o tamanho de palavra do PoliLegv8
        );
        port(
            clock: in bit; --! entrada de clock
            reset: in bit; --! clear assincrono
            load: in bit; --! write enable (carga paralela)
            d: in bit_vector(wordSize-1 downto 0); --! entrada
            q: out bit_vector(wordSize-1 downto 0) --! saida
        );
    end component;

    constant num_Reg: natural := 32; --Numero de registradores
    constant word_Size: natural := 64; --Tamanho de palavra
    constant reg_addr_Size: natural := 5; --Tamanho do endereco dos registradores
    constant inst_Size: natural := 32; --Tamanho da instrucao

    --Signals do regFile
    signal s_q1, s_q2, s_d: bit_vector(word_Size-1 downto 0);
    signal s_rr1, s_rr2, s_wr: bit_vector(reg_addr_Size-1 downto 0);

    --Signals da ULA
    signal s_Alu_A, s_Alu_B, s_Alu_F: bit_vector(word_Size-1 downto 0);
    signal s_Ov, s_Co: bit;

    --Signals do signExtend
    signal s_signExt_o: bit_vector(word_Size-1 downto 0);

    --Signals do somador usado no program counter
    signal s_fourAdder: bit_vector(word_Size-1 downto 0);
    signal s_fA_zero, s_fA_Ov, s_fA_Co: bit;

    --Signals do somador usado no shiftleft2
    signal s_shiftAdder: bit_vector(word_Size-1 downto 0);
    signal s_sA_zero, s_sA_Ov, s_sA_Co: bit;

    --Signals do Shiftleft2
    signal s_shiftOut: bit_vector(word_Size-1 downto 0);

    --Signals do Program Counter
    signal s_pc_i, s_pc_o: bit_vector(word_Size-1 downto 0);


    begin
        opcode <= imOut(inst_Size-1 downto inst_Size-11);

        s_rr1 <= imOut(9 downto 5);
        s_rr2 <= imOut(4 downto 0) when reg2loc = '1' else imOut(20 downto 16);
        s_wr <= imOut(4 downto 0);
        s_d <= dmOut when memToReg = '1' else s_Alu_F;

        s_Alu_A <= s_q1;
        s_Alu_B <= s_signExt_o when aluSrc = '1' else s_q2;

        dmAddr <= s_Alu_F;
        dmIn <= s_q2;

        s_pc_i <= s_shiftAdder when pcsrc = '1' else s_fourAdder;

        imAddr <= s_pc_o;
        --Componentes
        regBank: regfile
            generic map(num_Reg, word_Size)
            port map(
                clock=> clock,
                reset=> reset,
                regWrite=> regWrite,
                rr1=> s_rr1,
                rr2=> s_rr2,
                wr=> s_wr,
                d=> s_d,
                q1=> s_q1,
                q2=> s_q2
            );
            
        dataAlu: alu
            generic map(word_Size)
            port map(
                A=> s_Alu_A,
                B=> s_Alu_B,
                F=> s_Alu_F,
                S=> aluCtrl,
                Z=> zero,
                Ov=> s_Ov,
                Co=> s_Co
            );

        signExt: signExtend
            port map(
                i=> imOut(31 downto 0),
                o=> s_signExt_o
            );

        fourAdder: alu
            generic map(word_Size)
            port map(
                A=> s_pc_o,
                B=> (2 => '1', others => '0'),
                F=> s_fourAdder,
                S=> "0010",
                Z=> s_fA_zero,
                Ov=> s_fA_Ov,
                Co=> s_fA_Co
            );
        
        shiftl2: Shiftleft2
            port map(
                i=>s_signExt_o,
                o=>s_shiftOut
            );

        shiftAdder: alu
            generic map(word_Size)
            port map(
                A=> s_pc_o,
                B=> s_shiftOut,
                F=> s_shiftAdder,
                S=> "0010",
                Z=> s_sA_zero,
                Ov=> s_sA_Ov,
                Co=> s_sA_Co
            );
        
        pc: reg
            generic map(word_Size)
            port map(
                clock=> clock,
                reset=> reset,
                load=> '1',
                d=> s_pc_i,
                q=> s_pc_o
            );
        

end datapath_arch;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

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

architecture toplevel of regfile is

    component reg is
        generic(
            wordSize: natural := 64
        );
        port(
            clock, reset, load: in bit;
            d: in bit_vector(wordSize-1 downto 0);
            q: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    component decoder is
        generic(
            inp_Size: natural := 5
        );
        port(
            in_bv: in bit_vector(inp_Size-1 downto 0);
            out_bv: out bit_vector((2**inp_Size)-1 downto 0)
        );
    end component;

    constant bank_Size: natural := natural(ceil(log2(real(regn))));
    signal regWriteSelect: bit_vector(regn-1 downto 0);
    type bankOutType is array(regn-2 downto 0)
        of bit_vector(wordSize-1 downto 0);
    signal registerBankOut: bankOutType;
    signal intR1, intR2: natural;

begin
    dec: decoder
        generic map(bank_Size)
        port map(wr, regWriteSelect);

    regBank: for i in regn-2 downto 0 generate
        Xi: reg
            generic map(
                wordSize
            )
            port map(
                clock, reset, regWriteSelect(i),
                d,
                registerBankOut(i)
            );
    end generate;

    intR1 <= to_integer(unsigned(rr1));
    intR2 <= to_integer(unsigned(rr2));

    q1 <= (others => '0') when intR1 = regn-1 else
        registerBankOut(intR1);
    q2 <= (others => '0') when intR2 = regn-1 else
        registerBankOut(intR2);

end architecture;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

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

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity reg is
    generic(wordSize: natural :=64);
    port(
        clock: in bit;
        reset: in bit;
        load: in bit;
        d: in bit_vector(wordSize-1 downto 0);
        q: out bit_vector(wordSize-1 downto 0)
    );
end reg;

architecture arch_reg of reg is
    begin
        ffdr: process(clock, reset)
        begin
            if reset='1' then
                q <= (others => '0');
            elsif clock='1' and clock'event then
                if load = '1' then
                    q <= d;
                end if;
            end if;
        end process;
end arch_reg;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity alu is
    generic(
        size: natural := 10
    );
    port(
        A, B: in bit_vector(size-1 downto 0);
        F: out bit_vector(size-1 downto 0);
        S: in bit_vector(3 downto 0);
        Z, Ov, Co: out bit
    );
end entity;
architecture stuctural of alu is

    component alu1bit is
        port(
            a, b, less, cin: in bit;
            result, cout, set, overflow: out bit;
            ainvert, binvert: in bit;
            operation: in bit_vector(1 downto 0)
        );
    end component;

    signal ainvert, binvert: bit;
    signal operation: bit_vector(1 downto 0);
    signal coutBv: bit_vector(size-2 downto 0);
    signal resultBv, setBv, overflowBv, zero: bit_vector(size-1 downto 0);

begin

    ainvert <= S(3);
    binvert <= S(2);
    operation <= S(1 downto 0);

    firstAlu: alu1bit port map(
        A(0), B(0), '0', binvert,
        resultBv(0), coutBv(0), setBv(0), overflowBv(0),
        ainvert, binvert,
        operation
    );
    zero(0) <= resultBv(0);

    lastAlu: alu1bit port map(
       A(size-1), B(size-1), '0', coutBv(size-2),
       resultBv(size-1), Co, setBv(size-1), Ov,
       ainvert, binvert,
       operation
    );
    zero(size-1) <= zero(size-2) or resultBv(size-1);

    Alus: for i in size-2 downto 1 generate
        Alu_i: alu1bit port map(
            A(i), B(i), '0', coutBv(i-1),
            resultBv(i), coutBv(i), setBv(i), overflowBv(i),
            ainvert, binvert,
            operation
        );
        zero(i) <= zero(i-1) or resultBv(i);
    end generate;

    Z <= not zero(size-1);
    F <= resultBv;

end architecture;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity alu1bit is
    port (
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
end entity;

architecture alu_arch of alu1bit is

  component fa1bit is
    port(
        a, b, cin: in bit;
        result, cout: out bit
    );
  end component;

  signal firstOp, secondOp, sum, Co: bit;
  begin

    adder: fa1bit port map(
        firstOp, secondOp, cin,
        sum, Co
    );

    firstOp <=
        a when ainvert = '0' else
        not a;
    secondOp <=
        b when binvert = '0' else
        not b;

    with operation select result <=
        firstOp and secondOp when "00",
        firstOp or secondOp when "01",
        sum when "10",
        b when "11";

    set <= sum;
    overflow <= cin xor Co;
    cout <= Co;

  end alu_arch;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity fa1bit is
  port(
      a, b, cin: in bit;
      result, cout: out bit
  );
end entity;


architecture structural of fa1bit is
begin
  result <= a xor b xor cin;
  cout <= (a and b) or (a and cin) or (b and cin);
end architecture;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port(
        i: in bit_vector(31 downto 0);
        o: out bit_vector(63 downto 0)
    );
end signExtend;

architecture signExtend_arch of signExtend is

    signal s_add_cb_i, s_add_b_i, s_add_d_i: integer;
    signal s_cb, s_b, s_d: bit;
    signal s_op_cb: bit_vector(7 downto 0);
    signal s_op_b: bit_vector(5 downto 0);
    signal s_op_d: bit_vector(10 downto 0);

    begin
        s_op_cb <= i(31 downto 24);
        s_op_b <= i(31 downto 26);
        s_op_d <= i(31 downto 21);

        s_cb <= '1' when s_op_cb = "10110100" else '0';
        s_b <= '1' when s_op_b = "000101" else '0';
        s_d <= '1' when s_op_d = "11111000000" or s_op_d = "11111000010" else '0';

        s_add_cb_i <= to_integer(signed(i(23 downto 5))) when s_cb = '1';
        s_add_b_i <= to_integer(signed(i(25 downto 0))) when s_b = '1';
        s_add_d_i <= to_integer(signed(i(20 downto 12))) when s_d = '1';

        o <= bit_vector(to_signed(s_add_cb_i, 64)) when s_cb = '1' else
            bit_vector(to_signed(s_add_b_i, 64)) when s_b = '1' else
                bit_vector(to_signed(s_add_d_i, 64)) when s_d = '1';
        
end signExtend_arch;

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

entity Shiftleft2 is
    port(
        i: in bit_vector(63 downto 0);
        o: out bit_vector(63 downto 0)
    );
end entity Shiftleft2;

architecture arch of Shiftleft2 is
begin
    o <= i(61 downto 0) & "00";
end architecture arch;