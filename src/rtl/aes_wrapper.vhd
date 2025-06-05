library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.CSR_pkg.all;
use work.RegisterMap_pkg.all;

entity aes_core is
   generic(
      enable_host : boolean := true
   );
   port(
         -- Avalon agent
      clk         : in  std_logic;
      reset_n     : in  std_logic;
      read        : in  std_logic;
      write       : in  std_logic;
      readdata    : out std_logic_vector(31 downto 0);
      writedata   : in  std_logic_vector(31 downto 0);
      address     : in  std_logic_vector(3  downto 0);
      interrupt   : out std_logic;
      
      -- Avalon host
      clk_h       : in  std_logic;
      reset_h_n   : in  std_logic;
      read_h      : out std_logic;
      write_h     : out std_logic;
      readdata_h  : in  std_logic_vector(7 downto 0);
      writedata_h : out std_logic_vector (7 downto 0);
      address_h   : out std_logic_vector(31 downto 0)
   );
end entity aes_core;

architecture rtl of aes_core is 

   -- outputs
   signal block_total         : std_logic_vector(127 downto 0);
   signal key_total           : std_logic_vector(127 downto 0);
   signal iv_total            : std_logic_vector(127 downto 0);
   
   --interrupt signals
   signal interrupt_pending   : std_logic; -- when the core starts 
   -- if we wnated to debug we can add a pulse signal 
   
	signal   control_status      : std_logic_vector(31 downto 0); := (others => '0'); -- 32 bits wide
   signal   aes_done            : std_logic_vector(1 downto 0);
   signal   dma_done            : std_logic_vector(1 downto 0);
   signal   CSR                 : CSR_bits;
   signal   RM                  : Register_Map;
	constant bad_value			  : std_logic_vector(31 downto 0); := x"0bad0bad";
   
begin 
   
  interrupt_logic: process(clk) is
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
          interrupt_pending <= '0';
      elsif write = '1' and address = RM.reg_control_status and writedata(CSR.int_clear) = '1' then -- issue
          interrupt_pending <= '0';
      elsif aes_done = "10" then 
          interrupt_pending <= '1';
          CSR.ready         <= '1';
        if enable_host = true then 
          if dma_done = "10" then 
               CSR.done           <= '1';
           end if;   
         end if; 
      end if;     
      interrupt <= interrupt_pending;
    end if;
end process;
      
         
   done_rising_edge: process(clk) is
   begin
     if rising_edge(clk) then
       if reset_n = '0' then
           aes_done(1) <= '0';
       else
           aes_done(1) <= aes_done(0);
       end if;
     end if;
end process;
    
   reading_logic:   process(clk) is
   begin 
     if rising_edge(clk) then 
       if reset_n = '0' then
           readdata <= (others => '0');
     elsif write = '1' then 
          case 
			   when address =>
				 when RM.reg_control_status => 
				    control_status(CSR.reset)     <= writedata(CSR.reset);
				    control_status(CSR.mode)      <= writedata(CSR.mode);
					 control_status(CSR.start)     <= writedata(CSR.star);
                control_status(CSR.int_clear) <= writedata(CSR.int_clear);
					 if enable_host then
					   control_status(CSR.dma_start) <= writedata(CSR.dma_start);  
				 when RM.reg_start_address =>
	             if enable_host then
						  start_address <= writedata;
				    end if;
				 when RM.reg_length 		  =>
				 when RM.reg_key_0		  =>  writedata <= key_total(31 downto 0);
				 when RM.reg_key_1		  =>	writedata <= key_total(63 downto 32);
				 when RM.reg_key_2		  => 	writedata <= key_total(95 downto 64);
				 when RM.reg_key_3        => 	writedata <= key_total(127 downto 96);
				 when RM.reg_iv_0			  => 	writedata <= iv_total(31 downto 0);
				 when RM.reg_iv_1			  => 	writedata <= iv_total(63 downto 32);
				 when RM.reg_iv_2			  =>  writedata <= iv_total(95 downto 64);
				 when RM.reg_iv_3			  =>  writedata <= iv_total(127 downto 96);
				 when RM.reg_block_0		  =>  writedata <= block_total(31 downto 0);
				 when RM.reg_block_1      =>  writedata <= block_total(63 downto 32);
				 when RM.reg_block_2		  =>  writedata <= block_total(95 downto 64);
				 when RM.reg_block_2      =>  writedata <= block_total(127 downto 96);
				 when others 				  =>  writedata <= (others => '0');
			end case;

     elsif read = '1' then
	       case address is
				when RM.reg_control_status =>
					readdata(CSR.reset)      <= CSR.reset;
					readdata(CSR.mode)       <= CSR.mode;
					readdata(CSR.start)      <= '0'
					readdata(CSR.ready)      <= CSR.ready;
					readdata(CSR.int_clear)  <= '0';
					readdata(CSR.dma_start)  <= '0';
					readdata(CSR.done)		 <= aes_done(1);
					readdata(CSR.reserved_0) <= (others => '0');
					readdata(has_host)		 <= CSR.host;
					readdata(CSR.reserved_1) <= (others => '0');
					readdata(CSR.revision)   <= "000000001" -- revision 1 
				when RM.reg_start_address =>
				    if enable_host then 
						readdata <= 
					 else
						readdata <= x"00000000";
					 end if;
				when RM.reg_length        =>
					 if enable_host then 
					   readdata <=
					 else
						readdata <= x"00000000";
				when RM.reg_key_0			  => readdata <= bad_value;
				when RM.reg_key_1			  => readdata <= bad_value;
				when RM.reg_key_2			  => readdata <= bad_value;
				when RM.reg_key_3			  => readdata <= bad_value;
				when RM.reg_iv_0			  => readdata <= bad_value;
				when RM.reg_iv_1			  => readdata <= bad_value;
				when RM.reg_iv_2			  => readdata <= bad_value;
				when RM.reg_iv_3			  => readdata <= bad_value;
				when RM.reg_block_0		  => readdata <= block_total(31 downto 0);
				when RM.reg_block_1       => readdata <= block_total(63 downto 32);
				when RM.reg_block_2		  => readdata <= block_total(95 downto 64);
				when RM.reg_block_2       => readdata <=block_total(127 downto 96);
				when others 				  => readdata <= (others => '0');
			end case;
		end if;
	end if
end process;