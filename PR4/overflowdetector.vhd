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