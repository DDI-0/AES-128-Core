library ieee;
use ieee.std_logic_1164.all;
use iee.numeric_std.all;

entity aes_fsm is
	generic (
	       enable_host : boolean := true
	);
	port (
		  clock  : in std_logic;
		  reset	: in std_logic
   );
	
end entity aes_fsm;

architecture fsm of aes_fsm is
	 type state_type is
		  ( RESET, IDLE, LOAD_KEY_IV, 
		    LOAD_DATA, PROCESSING, STORE_RESULT, 
			 DMA_NEXT_BLOCK, COMPLETE);
	 signal current_state, next_state: state_type'
begin
	 save_state: process(clock, reset) is
	 begin
		  if reset = '0' then
			   current_state <= RESET;
		  elsif rising_edge(clock) is
		      current_state <= next_state;
		  end if;
	 end process save_state;
	 
	 transition_function: process(current_state, placeholder) is 
	 begin
		  next_state <= current_state; -- avoid latch behavior
		  case current_state is
		      when RESET =>
					 if reset = '0' then
						next_state <= IDLE;
					 end if;
				when IDLE =>
					 if start = '1' then
						next_state <= LOAD_KEY_IV;
					 elsif enable_host then
						   if dma_start = '1' then
						     next_state <= LOAD_DATA;
							end if;
					 end if;
				when LOAD_KEY_IV =>
					 if loaded = '1'then
						next_state <= LOAD_DATA;
					 end if;
			   when LOAD_DATA =>
					 if loaded = '1' then 
						next_state <= PROCESSING;
				when PROCESSING =>
					 if aes_done = '1' then
					   next_state <= STORE_RESULT;
					 end if;
				when STORE_RESULT =>
					 if data_load = '1' then 
						next_state <= COMPLETE;
					 end if;
			   when COMPLETE => 
					 next_state <= COMPLETE;
			   when others =>
					 next_state <= RESET;
		  end case;
	
end architecture fsm;