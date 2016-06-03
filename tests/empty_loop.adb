with Ada.Text_IO; use Ada.Text_IO;

with UV;
use type UV.Errno_T;

procedure Empty_Loop is

   procedure Expect_OK (E : UV.Errno_T) is
   begin
      if E /= UV.OK then
         raise Program_Error;
      end if;
   end Expect_OK;

   L : UV.Loop_Type := UV.Alloc;
begin
   Expect_OK (UV.Init (L));

   Put_Line ("Entering loop...");
   Expect_OK (UV.Run (L, UV.Default));
   Put_Line ("Loop finished");

   Expect_OK (UV.Close (L));
end Empty_Loop;
