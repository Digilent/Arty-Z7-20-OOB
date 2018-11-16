----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/08/2016 04:09:50 PM
-- Design Name: 
-- Module Name: user_io2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity user_io is
    generic( btn_dim: integer := 4;
             sw_dim: integer := 2);
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (btn_dim - 1 downto 0);
           sw : in STD_LOGIC_VECTOR (sw_dim - 1 downto 0);
           write_leds: STD_LOGIC_VECTOR (btn_dim - 1 downto 0);
           led : out STD_LOGIC_VECTOR (btn_dim - 1 downto 0);
           en_btn : in STD_LOGIC;
           en_sw : in STD_LOGIC);
end user_io;

architecture Behavioral of user_io is

    signal sw_value: std_logic := '0';
    signal btn_value: std_logic_vector(btn_dim - 1 downto 0) := (others => '0');
    signal xor_temp: std_logic_vector(sw_dim - 1 downto 0) := (others => '0');
    
    signal temp_led_val: std_logic_vector(btn_dim - 1 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if(clk'event and clk = '1') then
            if(en_btn = '1') then
                btn_value <= btn;
            else
                btn_value <= (others => '0');
            end if;
        end if;
    end process;
    
    xor_temp(0) <= sw(0);
    sw_gen: for i in 1 to sw_dim - 1 generate
        xor_temp(i) <= xor_temp(i - 1) xnor sw(i);
    end generate;
    
    sw_value <= xor_temp(sw_dim - 1) when en_sw = '1' else
                '0';
    
    temp_led_val <= btn_value when sw_value = '0' else
        not btn_value;
        
    led <= temp_led_val or write_leds;

end Behavioral;
