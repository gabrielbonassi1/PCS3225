entity polilegsc is
    port(
        clock, reset: in bit;
        -- Data Memory
        dmem_addr,
        dmem_dati: out bit_vector(63 downto 0);
        dmem_dato: in bit_vector(63 downto 0);
        dmem_we: out bit;
        -- Instruction memory
        imem_addr: out bit_vector(63 downto 0);
        imem_data: in bit_vector(31 downto 0)
    );
end entity;

architecture arch of polilegsc is

    component controlunit is
        port(
            -- To Datapath
            reg2loc,
            uncondBranch,
            branch,
            memRead,
            memToReg: out bit;
            aluOp: out bit_vector(1 downto 0);
            memWrite,
            aluSrc,
            regWrite: out bit;
            -- From Datapath
            opcode: in bit_vector(10 downto 0)
        );
    end component;

    component alucontrol is
        port(
            aluop: in bit_vector(1 downto 0);
            opcode: in bit_vector(10 downto 0);
            aluCtrl: out bit_vector(3 downto 0)
        );
    end component;

    component datapath is
        port(
            -- Common
            clock,
            reset,
            -- From Control Unit
            reg2loc,
            pcSrc,
            memToReg: in bit;
            aluCtrl: in bit_vector(3 downto 0);
            aluSrc,
            regWrite: in bit;
            -- To Control Unit
            opcode: out bit_vector(10 downto 0);
            zero: out bit;
            -- IM interface
            imAddr: out bit_vector(63 downto 0);
            imOut: in bit_vector(31 downto 0);
            -- DM interface
            dmAddr,
            dmIn: out bit_vector(63 downto 0);
            dmOut: in bit_vector(63 downto 0)
        );
    end component datapath;
    
    signal uncondBranch, branch: bit;
    signal memRead, memWrite: bit;
    signal aluOp: bit_vector(1 downto 0);

    signal reg2loc, pcSrc, memToReg: bit;
    signal aluCtrl: bit_vector(3 downto 0);
    signal aluSrc, regWrite: bit;
    -- To Control Unit
    signal opcode: bit_vector(10 downto 0);
    signal zero: bit;
    -- IM terface
    signal imAddr: bit_vector(63 downto 0);
    signal imOut: bit_vector(31 downto 0);
    -- DM terface
    signal dmAddr, dmIn: bit_vector(63 downto 0);
    signal dmOut: bit_vector(63 downto 0);

begin

    dmem_we <= memWrite and (not memRead);

    pcSrc <= uncondBranch or (branch and zero);

    cu: controlunit port map(
        reg2loc,
        uncondBranch,
        branch,
        memRead,
        memToReg,
        aluOp,
        memWrite,
        aluSrc,
        regWrite,
        opcode
    );

    aluCu: alucontrol port map(
        aluOp,
        opcode,
        aluCtrl
    );

    dp: datapath port map(
        clock, reset,
        reg2loc,
        pcSrc,
        memToReg,
        aluCtrl,
        aluSrc,
        regWrite,
        opcode,
        zero,
        imem_addr,
        imem_data,
        dmem_addr,
        dmem_dati,
        dmem_dato
    );

end architecture arch;

library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

entity datapath is
    port(
        -- Common
        clock,
        reset,
        -- From Control Unit
        reg2loc,
        pcSrc,
        memToReg: in bit;
        aluCtrl: in bit_vector(3 downto 0);
        aluSrc,
        regWrite: in bit;
        -- To Control Unit
        opcode: out bit_vector(10 downto 0);
        zero: out bit;
        -- IM interface
        imAddr: out bit_vector(63 downto 0);
        imOut: in bit_vector(31 downto 0);
        -- DM interface
        dmAddr,
        dmIn: out bit_vector(63 downto 0);
        dmOut: in bit_vector(63 downto 0)
    );
end entity datapath;

architecture arch of datapath is

    component regfile is
        generic(
            regn: natural := 32;
            wordSize: natural := 64
        );
        port(
            clock, reset, regWrite: in bit;
            rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
            d: in bit_vector(wordSize-1 downto 0);
            q1, q2: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    component alu is
        generic(
            size: natural := 10
        );
        port(
            A, B: in bit_vector(size-1 downto 0);
            F: out bit_vector(size-1 downto 0);
            S: in bit_vector(3 downto 0);
            Z, Ov, Co: out bit
        );
    end component;

    component signExtend is
        port(
            i: in  bit_vector(31 downto 0); 
            o: out bit_vector(63 downto 0)
        );
    end component;

    component Shiftleft2 is
        port(
            i: in bit_vector(63 downto 0);
            o: out bit_vector(63 downto 0)
        );
    end component Shiftleft2;

    component reg is
        generic(
            wordSize: natural := 64
        );
        port(
            clock, reset, enable, wr: in bit;
            dataIn: in bit_vector(wordSize-1 downto 0);
            dataOut: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    constant NUMBER_OF_REGISTERS: natural := 32;
    constant REGISTER_ADDR_SIZE: natural := 5;
    constant WORD_SIZE: natural := 64;
    constant INSTRUCTION_SIZE: natural := 32;

    signal rr1, rr2, wr: bit_vector(REGISTER_ADDR_SIZE-1 downto 0);
    signal q1, q2, d: bit_vector(WORD_SIZE-1 downto 0);

    signal dataAluA, dataAluB, dataAluResult: bit_vector(WORD_SIZE-1 downto 0);
    signal dataOverflow, dataCarryOut: bit;

    signal signExtendOut: bit_vector(WORD_SIZE-1 downto 0);

    signal pcPlusFour: bit_vector(WORD_SIZE-1 downto 0);
    signal pfZero, pfOverflow, pfCarryOut: bit;

    signal shiftOut: bit_vector(WORD_SIZE-1 downto 0);

    signal pcPlusShift: bit_vector(WORD_SIZE-1 downto 0);
    signal psZero, psOverflow, psCarryOut: bit;

    signal pcIn, pcOut: bit_vector(WORD_SIZE-1 downto 0);

begin

    opcode <= imOut(INSTRUCTION_SIZE-1 downto INSTRUCTION_SIZE-11);


    rr1 <= imOut(9 downto 5);
    rr2 <= 
        imOut(4 downto 0) when reg2loc = '1' else
        imOut(20 downto 16);
    wr <= imOut(4 downto 0);
    d <= 
        dmOut when memToReg = '1' else
        dataAluResult;

    registers: regfile
        generic map(NUMBER_OF_REGISTERS, WORD_SIZE)
        port map(
            clock, reset, regWrite,
            rr1, rr2, wr,
            d,
            q1, q2
        );


    extend: signExtend
        port map(
            imOut(31 downto 0),
            signExtendOut
        );


    dataAluA <= q1;
    dataAluB <=
        signExtendOut when aluSrc = '1' else
        q2; 

    dataAlu: alu
        generic map(WORD_SIZE)
        port map(
            dataAluA, dataAluB,
            dataAluResult,
            aluCtrl,
            zero, dataOverflow, dataCarryOut
        );

 
    dmAddr <= dataAluResult;
    dmIn <= q2;

    fourAdder: alu
        generic map(WORD_SIZE)
        port map(
            pcOut, (2 => '1', others => '0'),
            pcPlusFour,
            "0010",
            pfZero, pfOverflow, pfCarryOut
        );    


    shift2: Shiftleft2
        port map(signExtendOut, shiftOut);

    shiftAdder: alu
        generic map(WORD_SIZE)
        port map(
            pcOut, shiftOut,
            pcPlusShift,
            "0010",
            psZero, psOverflow, psCarryOut
        );
        

    pcIn <=
        pcPlusShift when pcSrc = '1' else
        pcPlusFour;

    pc: reg
        generic map(WORD_SIZE)
        port map(
            clock, reset, '1', '1',
            pcIn, pcOut
        );

    imAddr <= pcOut;

end architecture arch;

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

entity alu1bit is
    port(
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation: in bit_vector(1 downto 0)
    );
end entity;
architecture arch of alu1bit is

    component fa1bit is
        port(
            a, b, cin: in bit;
            result, cout: out bit
        );
    end component;

    signal firstOperand, secondOperand, sum, CO: bit;
begin

    firstOperand <=
        a when ainvert = '0' else
        not a;
    secondOperand <=
        b when binvert = '0' else
        not b;

    adder: fa1bit port map(
        firstOperand, secondOperand, cin,
        sum, CO
    );

    with operation select result <=
        firstOperand and secondOperand when "00",
        firstOperand or secondOperand when "01",
        sum when "10",
        b when "11";

    set <= sum;
    overflow <= cin xor CO;
    cout <= CO;

end architecture;

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

entity alucontrol is
    port(
        aluop: in bit_vector(1 downto 0);
        opcode: in bit_vector(10 downto 0);
        aluCtrl: out bit_vector(3 downto 0)
    );
end entity;
architecture arch of alucontrol is
    signal aluCtrlR: bit_vector(3 downto 0);
begin

    aluCtrlR <= (
        3 => '0',
        2 => opcode(9),
        1 => opcode(3),
        0 => opcode(8)
    );

    with aluop select aluCtrl <=
        "0010"      when "00",
        "0111"      when "01",
        aluCtrlR    when others;

end architecture arch;

entity controlunit is
    port(
        -- To Datapath
        reg2loc,
        uncondBranch,
        branch,
        memRead,
        memToReg: out bit;
        aluOp: out bit_vector(1 downto 0);
        memWrite,
        aluSrc,
        regWrite: out bit;
        -- From Datapath
        opcode: in bit_vector(10 downto 0)
    );
end entity;

architecture arch of controlunit is

begin

    reg2loc <= opcode(7);
    memToReg <= opcode(1);
    branch <= opcode(5);
    aluOp <= opcode(4) & opcode(5);
    uncondBranch <= not opcode(10);

    with opcode(7) select aluSrc <=
        opcode(9)   when '1',
        '0'         when others;

    with opcode(5) select memRead <=
        opcode(1)   when '0',
        '0'         when others;

    regWrite <= (opcode(10) and opcode(9) and opcode(1))
        or (not opcode(7));
    memWrite <= opcode(10) and opcode(9) and (not opcode(1))
        and opcode(7);

end architecture arch;

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

entity signExtend is
    port(
        i: in  bit_vector(31 downto 0);
        o: out bit_vector(63 downto 0)
    );
end signExtend;

architecture combinational of signExtend is
    signal dFormatToExtend: bit_vector(8 downto 0);
    signal cbzToExtend:     bit_vector(18 downto 0);
    signal bToExtend:       bit_vector(25 downto 0);
begin
    dFormatToExtend <= i(20 downto 12);
    cbzToExtend <= i(23 downto 5);
    bToExtend <= i(25 downto 0);

    o <=
        (37 downto 0 => bToExtend(25)) & bToExtend
            when i(31) = '0' else
        (44 downto 0 => cbzToExtend(18)) & cbzToExtend
            when i(30) = '0' else
        (54 downto 0 => dFormatToExtend(8)) & dFormatToExtend;

end architecture combinational;

library ieee;
use ieee.numeric_bit.all;

entity decoder is
    generic(
        inputSizeInBits: natural := 5
    );
    port(
        in_bv: in bit_vector(inputSizeInBits-1 downto 0);
        out_bv: out bit_vector((2**inputSizeInBits)-1 downto 0)
    );
end entity;

architecture combinatorial of decoder is
    signal index: integer;
begin
    index <= to_integer(unsigned(in_bv));
    dec: for i in (2**inputSizeInBits)-1 downto 0 generate
        out_bv(i) <= '1' when index = i else '0';
    end generate;
end architecture;

library ieee;
use ieee.numeric_bit.rising_edge;

entity reg is
    generic(
        wordSize: natural := 64
    );
    port(
        clock, reset, enable, wr: in bit;
        dataIn: in bit_vector(wordSize-1 downto 0);
        dataOut: out bit_vector(wordSize-1 downto 0)
    );
end entity;
architecture functional of reg is
    signal internalData: bit_vector(wordSize-1 downto 0);
begin
    dataOut <= internalData;
    update: process(clock, reset)
    begin
        if reset = '1' then
            internalData <= (others => '0');
        elsif wr = '1' and enable = '1'
                and rising_edge(clock) then
            internalData <= dataIn;
        end if;
    end process;
end architecture;

library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

entity regfile is
    generic(
        regn: natural := 32;
        wordSize: natural := 64
    );
    port(
        clock, reset, regWrite: in bit;
        rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d: in bit_vector(wordSize-1 downto 0);
        q1, q2: out bit_vector(wordSize-1 downto 0)
    );
end entity;
architecture toplevel of regfile is

    component reg is
        generic(
            wordSize: natural := 64
        );
        port(
            clock, reset, enable, wr: in bit;
            dataIn: in bit_vector(wordSize-1 downto 0);
            dataOut: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    component decoder is
        generic(
            inputSizeInBits: natural := 5
        );
        port(
            in_bv: in bit_vector(inputSizeInBits-1 downto 0);
            out_bv: out bit_vector((2**inputSizeInBits)-1 downto 0)
        );
    end component;

    constant BANK_SIZE_IN_BITS: natural := natural(ceil(log2(real(regn))));
    signal registerWriteSelect: bit_vector(regn-1 downto 0);
    type bankOutType is array(regn-2 downto 0)
        of bit_vector(wordSize-1 downto 0);
    signal registerBankOut: bankOutType;
    signal integerR1, integerR2: natural;

begin
    dec: decoder
        generic map(BANK_SIZE_IN_BITS)
        port map(wr, registerWriteSelect);

    regBank: for i in regn-2 downto 0 generate
        Xi: reg
            generic map(
                wordSize
            )
            port map(
                clock, reset, regWrite, registerWriteSelect(i),
                d,
                registerBankOut(i)
            );
    end generate;

    integerR1 <= to_integer(unsigned(rr1));
    integerR2 <= to_integer(unsigned(rr2));

    q1 <= (others => '0') when integerR1 = regn-1 else
        registerBankOut(integerR1);
    q2 <= (others => '0') when integerR2 = regn-1 else
        registerBankOut(integerR2);

end architecture;