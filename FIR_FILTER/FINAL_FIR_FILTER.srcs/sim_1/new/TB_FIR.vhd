Library IEEE;  
USE IEEE.Std_logic_1164.all;    
USE IEEE.numeric_std.all;  
Use STD.TEXTIO.all;  

  -- Testbench VHDL code for FIR Filter and DPRAM 
 
 entity TB_FIR is  
 
 end TB_FIR; 
 
 architecture behavioral of TB_FIR is  
 
 Component FIR_RI is  
 generic (  
           input_width      : integer     :=32              ; -- set input width by user  
           output_width     : integer     :=32               ; -- set output width by user  
           coef_width       : integer     :=32               ; -- set coefficient width by user  
           tap              : integer     :=5)               ; -- set filter order  
            
 port(  
      Din      : in      std_logic_vector(input_width-1 downto 0)     ;     -- input data to filter  
      Clk      : in      std_logic                              ;               -- input clk  
      Dout     : out     std_logic_vector(output_width-1 downto 0);  -- output data from filter
      rclk: in std_logic;   -- clk for dpram
      we: in std_logic)     ;-- write enable  
      
 end Component;  
  
 
 signal Din       :      std_logic_vector(31 downto 0)     ;  
 signal Clk       :      std_logic:='0'                              ;  
 signal output_ready     :      std_logic:='0';                                
 signal Dout      :      std_logic_vector(31 downto 0)     ;  
 --signal q2: std_logic_vector(31 downto 0);
 signal rclk:  std_logic:='0';
 signal we:  std_logic := '1';
 signal d:  std_logic_vector(31 downto 0) := (others => '0');
-- signal q:  std_logic_vector(31 downto 0);
 
 -- here we simulate dpram by creating an array where index is used as address for it
 type ram_array is array( 0 to 500000) of std_logic_vector(31 downto 0);
 shared variable ram: ram_array;
 
 file my_input : TEXT open READ_MODE is "C:/Users/edoardo antonaci/Desktop/FINAL_FIR_FILTER/input_sq.txt";  
 file my_output : TEXT open WRITE_MODE is "C:/Users/edoardo antonaci/Desktop/FINAL_FIR_FILTER/output_sq.txt";  
 
 begin  
   FIR_int : FIR_RI  
           generic map(  
           input_width  =>     32,  
           output_width =>     32,  
           coef_width   =>     32,  
           tap          =>     5)  
           
             
           port map     (  
                          Din   => Din,  
                          Clk   => Clk,  
                          Dout  => Dout,
                           rclk => rclk,
                           we => we
                           );
                           
                           
           --clk is 10ns high and 10 ns low       
           process(clk)  
           begin  
           Clk          <= not Clk after 10 ns;  
           end process;  
           
           --rclk is 10ns high and 10ns low
           process(rclk)  
           begin  
           rclk  <= not rclk after 10 ns;  
           end process;  
           
           --we is 20 ns high and 20 ns low 
           we <= not we after 20ns ; --we is already 1
           
           --------------------------------------------------------- Here we write into the DPRAM 
           process(rclk)
           variable my_input_line : LINE;  
           variable input1: integer;
           variable index : integer range 0 to 100000; 
           
           begin
               if rising_edge(rclk) then     
                 if (we='1') then -- when we = '1', we write into dpram 
                       readline(my_input, my_input_line);  
                       read(my_input_line,input1);  
                       d <= std_logic_vector(to_signed(input1,32)); 
                       ram(index) := d; --index represents address of simulated dpram which is array
                       index := index+1;
                    end if;
                 end if;
              end process;
           
            
           -------------------------------------------------------------------Here we read from DPRAM and send it to FIR filter
           process(rclk)
            variable my_input_line : LINE;  
            variable my_output_line : LINE;  
            variable index : integer range 0 to 100000; 
           
             begin
                if rising_edge(rclk) then --read from DPRAM to FIR
                  if (we='0') then -- when we='0' we read the data from ram array and send it to FIR    
                   Din <= ram(index); --via Din
                   output_ready <= '1';
                   index := index+1;
                 end if;
               end if;
               --end loop;
            end process;
            
                       
           ---------------------------------------------------------------- Here we obtain data from fir filter and write into DPRAM 
           process(clk)  
           variable index : integer:=100000; 
           begin  
                if falling_edge(clk) then  
                     if output_ready='1' then
                       if we='1' then  
                          ram(index):=Dout;
                          index:=index+1;
                       end if;
                     end if;  
                end if;  
           end process;  
           
          
           --------------------------------------------------------------------- Here we read from DPRAM and write it into output file.
           process(rclk)  
           variable my_output_line : LINE;  
           variable index : integer:=100000; 
           begin  
                if rising_edge(rclk) then  
                     if output_ready='1' then
                       if we='0' then  
                       
                       write(my_output_line, to_integer(signed(ram(index))));  
                       writeline(my_output,my_output_line);  
                       index:=index+1;
                       end if;
                     end if;  
                end if;  
           end process;  
            
                                
 end behavioral; 
 
 