library IEEE;
use IEEE.numeric_bit.all;
use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity testbench is
end testbench;

architecture arch_tb of testbench is

component regfile is 
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
    constant regn_in: natural := 8;
    constant ws_in: natural := 5; 
    signal d_in: bit_vector(ws_in-1 downto 0);
    signal q1_out, q2_out: bit_vector(ws_in-1 downto 0);
    signal rr1_in, rr2_in, wr_in: bit_vector(natural(ceil(log2(real(regn_in))))-1 downto 0);
    constant clockPeriod : time := 2 ns;
    signal clock_in: bit := '0';
    signal reset_in, regWrite_in: bit;
    signal simulando: bit := '0';
    
begin

	DUT: regfile
    generic map (regn_in, ws_in)
    port map (clock_in, reset_in, regWrite_in, rr1_in, rr2_in, wr_in, d_in, q1_out, q2_out);
    
    clock_in <= (simulando and (not clock_in)) after clockPeriod/2;

    stimulus: process is

		type test_record is record
  			d: bit_vector(ws_in-1 downto 0);
            regWrite: bit;
  			rr1, rr2, wr: bit_vector(natural(ceil(log2(real(regn_in))))-1 downto 0);
            q1, q2: bit_vector(ws_in-1 downto 0);
			str : string(1 to 2);
		end record;


		type tests_array is array (natural range <>) of test_record;
		constant tests : tests_array :=
--         d  regWrite rr1    rr2    wr      q1       q2     msg
      (("00001", '1', "001", "010", "001", "00001", "00000", "01"),
       ("00011", '1', "001", "010", "010", "00001", "00011", "02"), 
       ("00001", '0', "001", "010", "001", "00001", "00011", "03"),
       ("00001", '1', "111", "010", "111", "00001", "00000", "04")
           );
           
		begin 
			assert false report "Test start." severity note;
			simulando <= '1';
            reset_in <= '1';
            wait for clockPeriod;
            reset_in <= '0';
		for k in tests'range loop
			

            wait for clockPeriod;
			d_in <= tests(k).d;
            regWrite_in <= tests(k).regWrite;
            rr1_in <= tests(k).rr1;
            rr2_in <= tests(k).rr2;
            wr <= tests(k).wr;
            wait for 2*clockPeriod;
            
          assert (tests(k).q1 = q1_out)
                report "Fail: q1" & tests(k).str severity error;
          assert (tests(k).q2 = q2_out)
                report "Fail: q2" & tests(k).str severity error;

		end loop;


		assert false report "Test done." severity note;
		simulando <= '0';
		wait; 
	end process;
end architecture;