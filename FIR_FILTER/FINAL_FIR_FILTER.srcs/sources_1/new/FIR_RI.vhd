Library IEEE;  
 USE IEEE.Std_logic_1164.all;   
 USE IEEE.Std_logic_signed.all;
 use IEEE.NUMERIC_STD.ALL;
   
 entity FIR_RI is  
 generic (  
           input_width      : integer:=32;-- set input width by user  
           output_width     : integer:=32;-- set output width by user  
           coef_width       : integer:=32;-- set coefficient width by user  
           tap             : integer :=5);-- set filter order  
            
 port(  
      Din      : in std_logic_vector(input_width-1 downto 0);-- input data  
      Clk      : in std_logic                               ;-- input clk  
      Dout     : out std_logic_vector(output_width-1 downto 0); --output data from FIR filter
      rclk: in std_logic;
      we: in std_logic);--write enable
      
 end FIR_RI;  
 
 architecture behavioral of FIR_RI is  
 
 -- N bit Register  
 component N_bit_Reg   
 generic (  
           input_width : integer     :=32
           );  
   port(  
    Q : out std_logic_vector(input_width-1 downto 0);     
    Clk :in std_logic;    
    D :in std_logic_vector(input_width-1 downto 0)    
   );  
 end component;
 
 type Coeficient_type is array (0 to tap-1) of std_logic_vector(coef_width-1 downto 0);  
 -----------------------------------FIR filter coefficients----------------------------------------------------------------  
 constant coeficient: coeficient_type :=   
                               (    X"000000C1",  --193
                                    X"000000CB",  --203
                                    X"000000CE", --206 
                                    X"000000CB",  --203
                                    X"000000C1"  --193
                                    );                                         
 ----------------------------------------------------------------------------------------------                                     
 type shift_reg_type is array (0 to tap-1) of std_logic_vector(input_width-1 downto 0);  
 signal shift_reg : shift_reg_type;  
 type mult_type is array (0 to tap-1) of std_logic_vector(input_width+coef_width-1 downto 0);  
 signal mult : mult_type;  
 type ADD_type is array (0 to tap-1) of std_logic_vector(input_width+coef_width-1 downto 0);  
 signal ADD: ADD_type;  
 
 
 begin  
 
           shift_reg(0) <= Din;  
           mult(0) <= Din*coeficient(tap-1);  
           ADD(0) <= Din*coeficient(tap-1);
           
           GEN_FIR:  
           for i in 0 to tap-2 generate  
           begin  
                 -- N-bit reg unit  
                 N_bit_Reg_unit : N_bit_Reg generic map (input_width => 32)   
                 port map ( Clk => Clk,   
                                    --reset => reset,  
                                    D => shift_reg(i),  
                                    Q => shift_reg(i+1)  
                                    );       
                -- filter multiplication  
                mult(i+1)<= shift_reg(i+1)*coeficient(tap-1-i-1);  
                -- filter combinational addition  
                ADD(i+1)<=ADD(i)+mult(i+1);  
           end generate GEN_FIR;  
           Dout <= std_logic_vector(resize(SIGNED(ADD(tap-1)),32)); 
           
 end behavioral;  

 Library IEEE;  
 USE IEEE.Std_logic_1164.all;  
 
 -- N-bit Register in VHDL used for FIR filter calculation
 entity N_bit_Reg is   
 generic (  
           input_width : integer     :=32
           );  
   port(  
    Q : out std_logic_vector(input_width-1 downto 0);    
    Clk :in std_logic;    
    D :in std_logic_vector(input_width-1 downto 0)    
   );  
 end N_bit_Reg;  
 
 architecture Behavioral of N_bit_Reg is   
 begin   
      process(Clk)  
      begin   
        if ( rising_edge(Clk) ) then  
                Q <= D;   
       end if;      
      end process;   
 end Behavioral;