library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_bit.all;

entity testbench is
end testbench;

architecture arch_tb of testbench is

component alu is
    generic (
        size: natural := 10
    );
    port (
        A, B: in bit_vector(size-1 downto 0);
        F: out bit_vector(size-1 downto 0);
        S: in bit_vector(3 downto 0);
        Z: out bit;
        Ov: out bit;
        Co: out bit
    );
end component;
    constant tamanho: natural := 5;
    signal a_in, b_in, F_out: bit_vector(tamanho-1 downto 0);
    signal S_in: bit_vector(3 downto 0);
    signal z_out, ov_out, co_out: bit;
    constant clockPeriod : time := 2 ns;
    signal clock_in: bit := '0';
    signal simulando: bit := '0';
    
begin

	DUT: alu generic map (tamanho)
    port map (a_in, b_in, F_out, S_in, z_out, ov_out, co_out);
    

    clock_in <= (simulando and (not clock_in)) after clockPeriod/2;

    stimulus: process is

		type test_record is record
  			operation: bit_vector(1 downto 0);
            ainvert: bit;
            binvert: bit;
            a: bit_vector(tamanho-1 downto 0);
            b: bit_vector(tamanho-1 downto 0);
            F: bit_vector(tamanho-1 downto 0);
            z: bit;
            ov: bit;
            co: bit;
			str : string(1 to 2);
		end record;


		type tests_array is array (natural range <>) of test_record;
		constant tests : tests_array :=
--      op   ainv  binv     A         B       F      z    ov   co   str
      (("00", '0' ,'0' , "10011", "01001", "00001", '0', '0', '0', "01"),
       ("10", '0' ,'0' , "10011", "01001", "11100", '0', '0', '0', "02"),
       ("10", '0', '1' , "01001", "01100", "11101", '0', '0', '0', "03"),
       ("10", '0', '0' , "01111", "00010", "10001", '0', '1', '0', "04"),
       ("11", '0', '1' , "01001", "01101", "00001", '0', '0', '0', "05"),
       ("11", '0', '1' , "01101", "01001", "00000", '1', '0', '1', "06"),
       ("01", '0' ,'0' , "10011", "01001", "11011", '0', '0', '0', "07"),
       ("10", '0' ,'0' , "10011", "01101", "00000", '1', '0', '1', "08"),
       ("10", '0' ,'1' , "01001", "01001", "00000", '1', '0', '1', "09")
    
        );
           
		begin 
			assert false report "Test start." severity note;
			simulando <= '1';
    
		for k in tests'range loop

            wait for clockPeriod;
			a_in <= tests(k).a;
			b_in <= tests(k).b;
            S_in <=  tests(k).ainvert & tests(k).binvert & tests(k).operation;

            wait for 1*clockPeriod;
            
          assert (tests(k).F = F_out)
                report "Fail:F" & tests(k).str severity error;
          assert (tests(k).z = z_out)
                report "Fail:z" & tests(k).str severity error;
          assert (tests(k).ov = ov_out)
                report "Fail:ov" & tests(k).str severity error;
          assert (tests(k).co = co_out)
                report "Fail:co" & tests(k).str severity error;


		end loop;

		assert false report "Test done." severity note;
		simulando <= '0';
		wait;
	end process;
end architecture;