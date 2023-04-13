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