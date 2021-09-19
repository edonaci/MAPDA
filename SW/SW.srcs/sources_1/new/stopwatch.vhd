library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- describes the interface (I / O terminals) of each module of the model
entity stopwatch is
    port(
        clk : in std_logic;
        rst_in :in std_logic;
        start_in :in std_logic;
        stop_in :in std_logic;
        ledA: out std_logic;
        ledB: out std_logic;
        ledC: out std_logic;
        ledD: out std_logic);
end stopwatch;

-- associated with an ENTITY; describes what the module does
architecture Behavioral of stopwatch is

signal timer : unsigned (3 downto 0) :=(others =>'0'); 
signal rst : std_logic := '0' ;
signal start: std_logic := '0' ;
signal stop : std_logic := '0' ;
signal steady: std_logic := '1' ; 
-- steady is kept as '1' at the beginning, so that in testbench when start=1 and stop=0 then steady=0 

begin 
-- the order of execution of process does not depend from the order with which they 
-- appear in the model. “parallel“ signal processing   
    
    timer_process: process(clk,rst_in,start_in,stop_in) is 
        -- sequential
        begin
       
        rst <= rst_in;
        start <= start_in;
        stop <= stop_in;
       
        -- Reset 
        if (rst = '1') then 
           timer <= (others => '0' );--reset all the bits of timer array to 0.  
           steady <= '0';-- when steady=0, it starts counting again
        end if;
        
        -- start and stop
        if (start = '1') and (stop ='0') then 
           steady <= '0'; -- steady is useful for updating timer  
        elsif (start = '0') and (stop ='1') then 
           steady <= '1';
        else steady <= steady; 
        end if;
         
        if rising_edge(clk) then
           if (steady='0') then
               timer <= timer + 1;
           else timer <= timer;
            end if;
            
        end if;
   
    end process;
    
    led_process: process(timer, clk)
        begin
        ledA <= timer(0);
        ledB <= timer(1);
        ledC <= timer(2);
        ledD <= timer(3);
     end process;
    
end Behavioral;