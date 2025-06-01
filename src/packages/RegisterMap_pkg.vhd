library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Register_Map is 
	
	constant reg_control_status : std_logic_vector(3 downto 0) := "0000";
	constant reg_start_address	 : std_logic_vector(3 downto 0) := "0001";
	constant reg_length 		    : std_logic_vector(3 downto 0) := "0010";
	constant reg_key_0			 : std_logic_vector(3 downto 0) := "0011";
	constant	reg_key_1			 : std_logic_vector(3 downto 0) := "0100";
	constant reg_key_2			 : std_logic_vector(3 downto 0) := "0101";
	constant reg_key_3			 :	std_logic_vector(3 downto 0) := "0110";
	constant reg_iv_0				 : std_logic_vector(3 downto 0) := "0111";
	constant reg_iv_1				 : std_logic_vector(3 downto 0) := "1000";
	constant reg_iv_2				 : std_logic_vector(3 downto 0) := "1001";
	constant reg_iv_3 			 : std_logic_vector(3 downto 0) := "1010";
	constant block_0            : std_logic_vector(3 downto 0) := "1011";
	constant block_1				 : std_logic_vector(3 downto 0) := "1100";
	constant block_2				 : std_logic_vector(3 downto 0) := "1110";
	constant block_3				 : std_logic_vector(3 downto 0) := "1111";
	
end package Register_Map;