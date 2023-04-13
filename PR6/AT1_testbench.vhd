-- Feito por Larissa Albuquerque
library IEEE;

entity testbench is
end testbench;

architecture tb of testbench is

    -- DUT
    component polilegsc is
        port(
            clock, reset: in bit;
            --Data Memory
            dmem_addr: out bit_vector(63 downto 0);
            dmem_dati: out bit_vector(63 downto 0);
            dmem_dato: in bit_vector(63 downto 0);
            dmem_we: out bit;
            --Instruction Memory
            imem_addr: out bit_vector(63 downto 0);
            imem_data: in bit_vector(31 downto 0)
        );
    end component;

    component rom_arquivo_generica is
        generic(
            addressSize: natural := 5;
            wordSize: natural := 8;
            datFileName: string := "conteudo_rom_ativ_02_carga.dat"
        );
        port(
            addr: in bit_vector(addressSize-1 downto 0);
            data: out bit_vector(wordSize-1 downto 0)
        );
    end component;

    component ram is
        generic(
            addressSize: natural := 5;
            wordSize: natural := 8;
            datFileName: string := "ram.dat"
        );
        port(
            ck, wr: in bit;
            addr: in bit_vector(addressSize-1 downto 0);
            data_i: in bit_vector(wordSize-1 downto 0);
            data_o: out bit_vector(wordSize-1 downto 0)
        );
    end component;
    
    -- SINAIS DE TESTE
    signal clock_in, reset_in, dm_we: bit;
    signal dm_addr, dm_dati, dm_dato, im_addr: bit_vector(63 downto 0);
    signal im_data: bit_vector(31 downto 0);
    
    constant clockPeriod : time := 4 ns; -- periodo do clock
    signal keep_simulating: bit := '0'; -- interrompe simulação

    begin
        DUT: polilegsc port map(clock_in, reset_in,
                                dm_addr, dm_dati, dm_dato, dm_we,
                                im_addr, im_data);

        IM: rom_arquivo_generica generic map(8, 32, "rom.dat") port map (im_addr(9 downto 2), im_data);

        DM: ram generic map(8, 64, "ram.dat") port map(clock_in, dm_we, dm_addr(10 downto 3), dm_dati, dm_dato);

        clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

        wstimulo: process is
            begin
    
            assert false report "Test start." severity note;
            reset_in <= '1';
			keep_simulating <= '1'; -- habilita clock
            

            wait for clockPeriod/4;
            
            reset_in <= '0';

            wait for 800 ns;
    
        assert false report "Simulation end" severity note;
        keep_simulating <= '0';
   wait; -- end of simulation
  end process;

end architecture;