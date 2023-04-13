entity testbench is
end testbench;

architecture tb of testbench is
	component controlunit is
		port (
			reg2loc : out bit;
			uncondBranch : out bit;
			branch : out bit;
			memRead : out bit;
			memToReg : out bit;
			aluOp: out bit_vector(1 downto 0);
			memWrite : out bit;
			aluSrc : out bit;
			regWrite : out bit;
			opcode : in bit_vector (10 downto 0)
		);
	end component;
	signal opcode_in : bit_vector (10 downto 0);
	signal aluOp_out : bit_vector (1 downto 0);
	signal reg2loc_out, uncondBranch_out, branch_out, memRead_out, memToReg_out, memWrite_out, aluSrc_out, regWrite_out, opcode_out : bit;
begin
	DUT : controlunit port map (reg2loc_out, uncondBranch_out, branch_out, memRead_out, memToReg_out, aluOp_out, memWrite_out, aluSrc_out, regWrite_out, opcode_in);
	process
	begin
		opcode_in <= "11111000010";
		wait for 2 ns;
		assert uncondBranch_out ='0' report "Erro uncondBranch" severity error;
		assert branch_out = '0' report "Erro branch" severity error;
		assert memRead_out = '1' report "Erro memRead" severity error;
		assert memToReg_out = '1' report "Erro memToReg" severity error;
		assert aluOp_out = "00" report "Erro aluOp" severity error;
		assert memWrite_out = '0' report "Erro memWrite" severity error;
		assert aluSrc_out = '1' report "Erro aluSrc" severity error;
		assert regWrite_out = '1' report "Erro regWrite" severity error;
		wait for 2 ns;
		assert false report "Test done" severity note;
		wait;
	end process;
end tb;
