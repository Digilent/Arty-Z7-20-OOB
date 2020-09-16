library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
library unisim;
   use unisim.vcomponents.all;

entity iobuf_v1_0 is
	port (
		I : in std_logic;
		O : out std_logic;
		T : in std_logic;
		IO : inout std_logic
	);
end iobuf_v1_0;

architecture arch_imp of iobuf_v1_0 is

begin

   IOBUF_inst : IOBUF
   port map (
      O => O,     -- Buffer output
      IO => IO,   -- Buffer inout port (connect directly to top-level port)
      I => I,     -- Buffer input
      T => T      -- 3-state enable input, high=input, low=output 
   );

end arch_imp;
