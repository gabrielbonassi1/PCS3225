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

    signal alu_result : bit;
    signal s_a, s_b : bit;
    signal s_set : bit;

    component fulladder
      port (
        a, b, cin: in bit;
        s, cout: out bit
      );
    end component;

    begin
        process(a, b)
        begin
            if ainvert = '1' then
                s_a <= not a;
            else
                s_a <= a;
            end if;
            if binvert = '1' then
                s_b <= not b;
            else
                s_b <= b;
            end if;
        end process;
        ADDER: fulladder port map (
            a=> s_a,
            b=> s_b,
            cin=> cin,
            s=> s_set,
            cout=> cout
        );
        process(a, b, operation)
        begin
                        case(operation) is
            when "00" => --AND
              alu_result <= s_a and s_b;
            when "01" => --OR
              alu_result <= s_a or s_b;
            when "10" => --ADD
              alu_result <= s_set;
            when "11" => --SLT
              if s_a = '1' and s_b = '0' then
                --less <= '1';
                alu_result <= '1';
              end if;
            end case;
        end process;
        result <= alu_result;
end alu_arch;
            
              