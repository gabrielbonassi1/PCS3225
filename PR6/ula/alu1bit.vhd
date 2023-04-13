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