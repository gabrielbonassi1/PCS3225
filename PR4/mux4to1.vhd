entity mux_4to1 is
    port(
    
        op_and, op_or, op_add, op_slt : in bit;
        operation: in bit_vector(1 downto 0);
        Z: out bit
     );
   end mux_4to1;
   