----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/18/2016 02:03:55 PM
-- Design Name: 
-- Module Name: rgb - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;

entity rgb_ctrl is
    Generic( led_width: integer := 2);
    Port ( clk : in STD_LOGIC;
           pwm_duty: in std_logic_vector(31 downto 0);
           pwm_period: in std_logic_vector(31 downto 0);
           r_en: in std_logic;
           g_en: in std_logic;
           b_en: in std_logic;
           auto_test_en: in std_logic;
           auto_test_delay: in std_logic_vector(31 downto 0);
           led_en: in std_logic_vector(led_width - 1 downto 0);
           rgb : out STD_LOGIC_VECTOR (3 * led_width - 1 downto 0)
           
    );
end rgb_ctrl;

architecture Behavioral of rgb_ctrl is
    component cnt_generic
        generic(width: integer := 32);
        port(CLK, RST, CE : in std_logic;
             Q : out std_logic_vector(width - 1 downto 0));
    end component;
    
    signal auto_test_en_1, auto_en: std_logic := '0';
    
    signal pwm_rst: std_logic := '0';
    signal pwm_cnt: std_logic_vector(31 downto 0) := (others => '0');
    signal pwm_q: std_logic := '0';
    
    signal auto_rst: std_logic := '0';
    signal auto_cnt: std_logic_vector(31 downto 0) := (others => '0');
        
    signal rgb_rst: std_logic := '0';
    signal rgb_cnt: std_logic_vector(1 downto 0) := (others => '0');
    signal rgb_signal: std_logic_vector(2 downto 0) := (others => '0');
            
    signal leds_rst: std_logic := '0';
    signal leds_cnt: std_logic_vector(led_width - 1 downto 0) := (others => '0');
    
    signal auto_rgb, nAuto_rgb: std_logic_vector(3 * led_width - 1 downto 0) := (others => '0');
begin


    process(clk)
    begin
        if(rising_edge(clk)) then
            auto_test_en_1 <= auto_test_en;
        end if;
    end process;
        
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(auto_test_en_1 = '0' and auto_test_en = '1') then
                auto_en <= '1';
            elsif(leds_rst = '1') then
                auto_en <= '0';
            end if;
        end if;
    end process;
    
    pwm_rst <= '1' when pwm_cnt = pwm_period else
                '1' when auto_test_en_1 = '0' and auto_test_en = '1' and auto_en = '0' else
                '0';
    pwm_q <= '1' when pwm_cnt < pwm_duty else '0';
    
    pwm_cnt_gen: cnt_generic
        generic map(width => 32)
        port map(   CLK => clk,
                    RST => pwm_rst,
                    CE  => '1',
                    Q => pwm_cnt
     );
     
     auto_rst <=    '1' when auto_cnt = auto_test_delay and auto_en = '1' else 
                    '1' when auto_test_en_1 = '0' and auto_test_en = '1' and auto_en = '0' else
                    '0';
     
     auto_gen: cnt_generic
        generic map(width => 32)
        port map(   CLK => clk,
                    RST => auto_rst,
                    CE  => pwm_rst,
                    Q => auto_cnt
    );
    
    rgb_rst <=  '1' when rgb_cnt = "11" and auto_rst = '1' else 
                '1' when auto_test_en_1 = '0' and auto_test_en = '1' and auto_en = '0' else
                '0';
    rgb_signal <=   "001" when rgb_cnt = "00" else
                    "010" when rgb_cnt = "01" else
                    "100" when rgb_cnt = "10" else
                    "111" when rgb_cnt = "11" else
                    "000";
    
    rgb_gen: cnt_generic
        generic map(width => 2)
        port map(   CLK => clk,
            RST => rgb_rst,
            CE  => auto_rst,
            Q => rgb_cnt
    );
    
    
    leds_rst <= '1' when leds_cnt = conv_std_logic_vector(led_width - 1, 2) and rgb_rst = '1' else
                '1' when auto_test_en_1 = '0' and auto_test_en = '1' and auto_en = '0' else
                '0';
    
    leds_gen: cnt_generic
        generic map(width => led_width)
        port map(   CLK => clk,
            RST => leds_rst,
            CE  => rgb_rst,
            Q => leds_cnt
    );
    
    auto_rgb_gen: for i in 0 to led_width - 1 generate
        auto_rgb(3 * i + 2 downto 3 * i) <= rgb_signal and (pwm_q & pwm_q & pwm_q) when leds_cnt = conv_std_logic_vector(i, led_width) else
                                            "000";
    end generate;
    
    nAuto_rgb_gen: for i in 0 to led_width - 1 generate
        nAuto_rgb(3 * i + 2 downto 3 * i) <= (pwm_q and r_en) & (pwm_q and g_en) & (pwm_q and b_en) when led_en(i) = '1' else
                                            "000";
    end generate;
    
    rgb <= auto_rgb when auto_en = '1' else
           nAuto_rgb;
    
end Behavioral;
