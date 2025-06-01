library ieee;
use ieee.std_logic_1164.all;

package CSR_pkg is
	-- CSR
	type CSR_bits is record	
		reset			: std_logic_vector(0 downto 0); -- RW - [0]
		mode			: std_logic_vector(1 downto 1); -- RW
		start			: std_logic_vector(2 downto 2); -- WO
		ready			: std_logic_vector(3 downto 3); -- RO
		int_clear	: std_logic_vector(4 downto 4); -- WO
		dma_start	: std_logic_vector(5 downto 5); -- WO
		done			: std_logic_vector(6 downto 6); -- RO
		reserved_0	: std_logic_vector(15 downto 7);  -- RO  --[7]  -> [15]
		has_host		: std_logic_vector(16 downto 16);
		reserved_1	: std_logic_vector(23 downto 17); -- RO  --[17] -> [23]
		revision		: std_logic_vector(31 downto 24); -- RO	
	end record;
	
	function to_stdlogicvector(reg : CSR_bits) return std_logic_vector;  -- avalon read
	function to_CSR_bits (slv : std_logic_vector(31 downto 0);           -- avalon write 
								 old : CSR_bits) return CSR_bits;

end package;
	
package body CSR_pkg is
	
	function to_stdlogicvector(reg : CSR_bits) return std_logic_vector is
	
		variable result : std_logic_vector(31 downto 0) := (others <= '0');
		
		begin
			result(0) 				:= reg.reset;
			result(1) 				:= reg.mode;
			result(2) 				:= '0'; 			-- WO | start
			result(3) 				:= reg.ready;
			result(4) 				:= '0'; 			-- WO | int_clear
			result(5) 				:= '0'; 			-- WO | dma_start
			result(6)				:= reg.done;
			result(15 downto 7)	:= reg.reserved_0;
			result(16)				:= reg.has_host;
			result(23 downto 17) := reg.reserved_1;
			result(31 downto 24) := reg.revision;
			return result;
			
	end function;
	
	function to_CSR_bits(
		slv : std_logic_vector(31 downto 0);
		old : CSR_bits
		) return CSR_bits is
		
		variable reg : CSR_bits := old;
		
		begin
		
			reg.reset 	  := slv(0);
			reg.mode	 	  := slv(1);
			reg.start 	  := slv(2);
			reg.int_clear := slv(4);
			reg.dma_start := slv(5);
		   
			-- RO fields are preserved.
			return reg;
			
	end function;

end package body;
								
								