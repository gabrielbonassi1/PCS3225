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