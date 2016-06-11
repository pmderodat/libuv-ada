with Ada.Text_IO; use Ada.Text_IO;

with UV;
use type UV.Errno_T;

package body Idle_Simple_Pkg is

   procedure Idle_Cb (I : UV.Idle_Handle_Access)
      with Convention => C;

   Counter : Integer := 0;

   ---------------
   -- Expect_OK --
   ---------------

   procedure Expect_OK (E : UV.Errno_T) is
   begin
      if E /= UV.OK then
         raise Program_Error;
      end if;
   end Expect_OK;

   -------------
   -- Idle_Cb --
   -------------

   procedure Idle_Cb (I : UV.Idle_Handle_Access) is
   begin
      Counter := Counter + 1;
      if Counter = 1000 then
         Expect_OK (UV.Idle_Stop (I));
         UV.Close (UV.As_Handle (I), null);
      end if;
   end Idle_Cb;

   ----------
   -- Main --
   ----------

   procedure Main is
      L : UV.Loop_Type := UV.Alloc;
      I : UV.Idle_Handle_Access := new UV.Idle_Handle;
   begin
      Expect_OK (UV.Init (L));
      Expect_OK (UV.Idle_Init (L, I));
      Expect_OK (UV.Idle_Start (I, Idle_Cb'Access));

      Put_Line ("Entering loop...");
      Expect_OK (UV.Run (L, UV.Default));
      Put_Line ("Loop finished");

      Expect_OK (UV.Close (L));
      UV.Destroy (I);
   end Main;

end Idle_Simple_Pkg;
