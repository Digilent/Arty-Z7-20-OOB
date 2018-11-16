

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cnt_generic is
    generic(width: integer := 32);
    port(CLK, RST, CE : in std_logic;
         Q : out std_logic_vector(width - 1 downto 0));
end cnt_generic;

architecture archi of cnt_generic is
    signal cnt : std_logic_vector(width - 1 downto 0) := (others => '0');
begin
    process (CLK)
    begin
        if (CLK'event and CLK='1') then
            if (RST='1') then
                cnt <= (others => '0');
            elsif(ce = '1') then
                cnt <= cnt + '1';
            end if;
        end if;
    end process;

    Q <= cnt;

end archi;
				
				