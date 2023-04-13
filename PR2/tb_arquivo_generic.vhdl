library IEEE;
use IEEE.numeric_bit.all;

entity testbench is
end testbench;

architecture tb of testbench is
	component rom_arquivo_generica is
    generic(
        addressSize: natural := 5;
        wordSize:   natural := 8;
        datFileName: string := "conteudo_rom_ativ_02_carga.dat"
    );
    port(
        addr: in bit_vector(addressSize-1 downto 0);
        data: out bit_vector(wordSize-1 downto 0)
    );
end component;
    
 signal address: bit_vector(4 downto 0);
 signal dado: bit_vector(7 downto 0);
    
 begin
 	DUT: rom_arquivo_generica port map (address,dado);
    stimulo:process is
    type test_record is record
    	endereco_entry: bit_vector (4 downto 0);
        dado_saida: bit_vector(7 downto 0);
        str: string(1 to 3);
    end record;
    type tests_array is array(natural range <>) of test_record;
    constant tests: tests_array:=
	(("00000","00000000","T01"),
     ("00001","00000011","T02"),
     ("00010","11000000","T03"),
     ("00011","00001100","T04"),
     ("00100","00110000","T05")
	);
     
 begin
 	assert false report "Test Start."severity note;
 for k in tests'range loop
   address <= tests(k).endereco_entry;
   wait for 20 ns;
   
 if(tests(k).str = "T01") then
 	wait for 20 ns;
    assert(tests(k).dado_saida = dado) report "Fail T01" severity error;
 end if;
 
  if(tests(k).str = "T02") then
 	wait for 20 ns;
    assert(tests(k).dado_saida = dado) report "Fail T02" severity error;
 end if;
  if(tests(k).str = "T03") then
 	wait for 20 ns;
    assert(tests(k).dado_saida = dado) report "Fail T01" severity error;
 end if;
 
   if(tests(k).str = "T04") then
 	wait for 20 ns;
    assert(tests(k).dado_saida = dado) report "Fail T04" severity error;
 end if;
   if(tests(k).str = "T05") then
 	wait for 20 ns;
    assert(tests(k).dado_saida = dado) report "Fail T05" severity error;
 end if;

end loop;

assert false report "Test Done" severity note;
wait; end process;

end tb;	