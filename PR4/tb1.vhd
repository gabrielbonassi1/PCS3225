library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_bit.all;

entity testbench is
end testbench;

architecture arch_tb of testbench is

    component alu1bit is 
    port(
    a, b, less, cin: in bit;
    result, cout, set, overflow: out bit;
    ainvert, binvert: in bit;
    operation: in bit_vector(1 downto 0)
);
end component;
    
    signal a_in, b_in, less_in, cin_in, ainvert_in, binvert_in, result_out, cout_out, set_out, overflow_out: bit;
    signal op_in: bit_vector(1 downto 0);
    constant clockPeriod : time := 2 ns;
    signal clock_in: bit := '0';
    signal simulando: bit := '0';
    
begin

	DUT: alu1bit
    port map (a_in, b_in, less_in, cin_in, result_out, cout_out, set_out, overflow_out, ainvert_in, binvert_in, op_in);
    

    clock_in <= (simulando and (not clock_in)) after clockPeriod/2;

    stimulus: process is

		type test_record is record
  			operation: bit_vector(1 downto 0); --00 and 01 or 10 soma 11 lst
            a: bit;
            b: bit;
            less: bit;
            cin: bit;
            ainvert: bit;
            binvert: bit;
  			result: bit;
            cout: bit;
            set: bit;
            overflow: bit; 
			str : string(1 to 2);
		end record;

		type tests_array is array (natural range <>) of test_record;
		constant tests : tests_array :=
       --op    a    b   less cin  ainv binv res  cout set  ovf   str
      (("00", '1', '0', '1', '0', '0', '0', '0', '0', '1', '0', "01"),
       ("00", '1', '0', '1', '0', '1', '0', '0', '0', '0', '0', "02"),
       ("00", '1', '0', '1', '0', '0', '1', '1', '1', '0', '1', "03"),
       ("01", '1', '0', '1', '0', '0', '0', '1', '0', '1', '0', "04"),
       ("01", '1', '0', '1', '0', '1', '0', '0', '0', '0', '0', "05"),
       ("01", '1', '0', '1', '0', '0', '1', '1', '1', '0', '1', "06"),
       ("10", '1', '0', '1', '0', '0', '0', '1', '0', '1', '0', "07"),
       ("10", '1', '0', '1', '1', '0', '0', '0', '1', '0', '0', "08"),
       ("10", '1', '0', '1', '0', '0', '1', '0', '1', '0', '1', "09"),
       ("10", '1', '0', '1', '1', '0', '1', '1', '1', '1', '0', "10"),
       ("10", '1', '0', '1', '0', '1', '0', '0', '0', '0', '0', "11"),
       ("10", '1', '0', '1', '1', '1', '0', '1', '0', '1', '1', "12"),
       ("11", '1', '0', '1', '0', '0', '0', '1', '0', '1', '0', "13"),
       ("11", '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', "14")
        );
           
		begin 
			assert false report "Test start." severity note;
			simulando <= '1';
    
		for k in tests'range loop
			

            wait for clockPeriod;
			a_in <= tests(k).a;
			b_in <= tests(k).b;
			less_in <= tests(k).less;
			cin_in <= tests(k).cin;
			ainvert_in <= tests(k).ainvert;
			binvert_in <= tests(k).binvert;
			op_in <= tests(k).operation;

            wait for 1*clockPeriod;
            
          assert (tests(k).result = result_out)
                report "Fail:res" & tests(k).str severity error;
          assert (tests(k).cout = cout_out)
                report "Fail:cout" & tests(k).str severity error;
          assert (tests(k).set = set_out)
                report "Fail:set" & tests(k).str severity error;
          assert (tests(k).overflow = overflow_out)
                report "Fail:overflow" & tests(k).str severity error;


		end loop;

		assert false report "Test done." severity note;
		simulando <= '0';
		wait;
	end process;
end architecture;