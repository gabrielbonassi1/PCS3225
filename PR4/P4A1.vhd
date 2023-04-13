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

    signal alu_result: bit;
    signal s_and, s_or, s_add, s_slt: bit;
    signal s_a, s_b: bit;

    component fulladder
      port (
        a, b, cin: in bit;
        s, cout: out bit
      );
    end component;

    component ofdetec
      port (
        x, y, z: in bit;
        v: out bit
      );
    end component;

begin
  s_a <= not a when ainvert='1' else a;
  s_b <= not b when binvert='1' else b;

  s_and <= s_a and s_b;
  s_or <= s_a or s_b;
  s_slt <= less;

  ADDER: fulladder port map (
            a=> s_a,
            b=> s_b,
            cin=> cin,
            s=> s_add,
            cout=> cout
  );

  OVEFLOW: ofdetec port map (
    x=> s_a,
    y=> s_b,
    z=> s_add,
    v=> overflow
  );

  result <= s_and when operation="00" else
    s_or when operation="01" else
    s_add when operation="10" else
    s_slt when operation="11";

end alu_arch; -- alu_arch


entity fulladder is
  port (
    a, b, cin: in bit;
    s, cout: out bit
  );
end entity;
-------------------------------------------------------
architecture structural of fulladder is
  signal axorb: bit;
begin
  axorb <= a xor b;
  s <= axorb xor cin;
  cout <= (axorb and cin) or (a and b);
end architecture;


entity ofdetec is
  port (
      x, y, z: in bit;
      v: out bit
  );
end ofdetec;

architecture ofdetec_arch of ofdetec is
  
  signal s_g1, s_g2: bit_vector(2 downto 0);
  
  begin
      s_g1 <= (not x) & (not y) & z;
      s_g2 <= x & y & (not z);

      v <= s_g1(2) or s_g2(2);

end ofdetec_arch;