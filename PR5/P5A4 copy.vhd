library ieee;
use ieee.numeric_bit.all;

entity controlunit is
    port (
        reg2loc: out bit;
        uncondBranch: out bit;
        branch: out bit;
        memRead: out bit;
        memToReg: out bit;
        aluOp: out bit_vector(1 downto 0);
        memWrite: out bit;
        aluSrc: out bit;
        regWrite: out bit;

        opcode: in bit_vector(10 downto 0)
    );
end controlunit;

architecture controlunit_arch of controlunit is

begin
    p_CASE : process (opcode)
    begin
        case opcode is
            when "11111000010" => --LDUR
                uncondBranch <= '0';
                branch <= '0';
                memRead <= '1';
                memToReg <= '1';
                aluOp <= "00";
                memWrite <= '0';
                aluSrc <= '1';
                regWrite <= '1';
            when "11111000000" => --STUR
                reg2loc <= '1';
                uncondBranch <= '0';
                branch <= '0';
                memRead <= '0';
                aluOp <= "00";
                memWrite <= '1';
                aluSrc <= '1';
                regWrite <= '0';
            when "10110100000" => --CBZ
                reg2loc <= '1';
                uncondBranch <= '0';
                branch <= '1';
                memRead <= '0';
                aluOp <= "01";
                memWrite <= '0';
                aluSrc <= '0';
                regWrite <= '0';
            when "10001011000" or "11001011000" or "10001010000" or "10101010000" => --R
                reg2loc <= '0';
                uncondBranch <= '1';
                branch <= '0';
                memRead <= '0';
                memToReg <= '0';
                aluOp <= "10";
                memWrite <= '0';
                aluSrc <= '0';
                regWrite <= '1';
            when others =>
                
        end case;

    end process;

end controlunit_arch; -- arch