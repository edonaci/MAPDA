library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_stopwatch is
--  Port ( );
end tb_stopwatch;

architecture Behavioral of tb_stopwatch is

component stopwatch is
    port(
        clk : in std_logic;
        rst_in :in std_logic;
        start_in :in std_logic;
        stop_in :in std_logic;
        ledA: out  std_logic:='0';
        ledB: out std_logic :='0'; 
        ledC: out std_logic :='0'; 
        ledD: out std_logic :='0');
end component;

signal clk_t: std_logic := '0'; 
signal rst_t: std_logic := '0'; 
signal start: std_logic := '0'; 
signal stop:  std_logic := '0'; 
signal ledA:  std_logic := '0'; 
signal ledB:  std_logic := '0'; 
signal ledC:  std_logic := '0'; 
signal ledD:  std_logic := '0'; 
-- signals are used to connect the component under test (Unit Under Test) to the stimulus.
 
begin
-- Instantiation of the component. Each port is connected through the internal signals.
    uut: stopwatch port map (clk=>clk_t, rst_in => rst_t,start_in => start, stop_in => stop,
                                ledA=>ledA, ledB=>ledB, ledC=>ledC, ledD=>ledD);
    
    clock: process
        begin
        wait for 5 ns; 
        clk_t<='1';
        wait for 5 ns;
        clk_t<='0'; 
    end process;
        
    rst: process
        begin
        wait for 405 ns;
        rst_t<='1';
        wait for 5 ns;
        rst_t <='0';
        wait for 350 ns;
        rst_t<='1';
        wait for 5 ns;
        rst_t <='0';
    end process;
    
    start_p: process
        begin
        wait for 5 ns;
        start<='1';
        wait for 5 ns;
        start<='0';
        wait for 300 ns;
        start<='1';
        wait for 5 ns;
        start<='0';
        wait for 600 ns;
        end process;
    
    stop_p: process
        begin
        wait for 200 ns;
        stop<='1';
        wait for 5 ns;
        stop <='0';
        wait for 500 ns;
        stop<='1';
        wait for 5 ns;
        stop <='0';
        wait for 300 ns;
        stop<='1';
        wait for 5 ns;
        stop <='0';
    end process;
        
end Behavioral;





