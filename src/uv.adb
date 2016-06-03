with Ada.Unchecked_Conversion;

with System.Memory;

package body UV is

   type Loop_Data_Access is access Loop_Data_Type;

   function Get_Data_Access is new Ada.Unchecked_Conversion
     (Loop_Type, Loop_Data_Access);

   function Loop_Size return Interfaces.C.size_t
      with Import        => True,
           Convention    => C,
           External_Name => "uv_loop_size";

   function Loop_Alive (L : Loop_Type) return Interfaces.C.int
      with Import        => True,
           Convention    => C,
           External_Name => "uv_loop_alive";

   function UV_Close (L : Loop_Type) return Errno_T
      with Import        => True,
           Convention    => C,
           External_Name => "uv_loop_close";

   --  TODO??? Explain the closure hack

   type Walk_Cb is access procedure
     (Handle : Handle_Access;
      Arg    : access procedure (Handle : Handle_Access))
      with Convention => C;
   --  Callback passed to uv_walk

   procedure Walk_Cb_Wrapper
     (Handle : Handle_Access;
      Arg    : access procedure (Handle : Handle_Access))
      with Convention    => C;

   procedure Walk
     (L   : Loop_Type;
      Cb  : Walk_Cb;
      Arg : access procedure (Handle : Handle_Access))
      with Import        => True,
           Convention    => C,
           External_Name => "uv_loop_alive";

   -----------
   -- Alloc --
   -----------

   function Alloc return Loop_Type is

      function Convert is new Ada.Unchecked_Conversion
        (System.Address, Loop_Type);

      Size   : constant System.Memory.size_t :=
         System.Memory.size_t (Loop_Size);
      Result : constant System.Address := System.Memory.Alloc (Size);

   begin
      return Convert (Result);
   end Alloc;

   --------------
   -- Get_Data --
   --------------

   function Get_Data (L : Loop_Type) return Loop_Data_Type is
   begin
      return Get_Data_Access (L).all;
   end Get_Data;

   --------------
   -- Set_Data --
   --------------

   procedure Set_Data (L : Loop_Type; D : Loop_Data_Type) is
   begin
      Get_Data_Access (L).all := D;
   end Set_Data;

   -----------
   -- Close --
   -----------

   function Close (L : in out Loop_Type) return Errno_T is
      Result : constant Errno_T := UV_Close (L);
   begin
      if Result = OK then
         System.Memory.Free (System.Address (L));
         L := No_Loop;
      end if;
      return Result;
   end Close;

   ----------------
   -- Loop_Alive --
   ----------------

   function Loop_Alive (L : Loop_Type) return Boolean is
   begin
      return Interfaces.C."=" (Loop_Alive (L), 0);
   end Loop_Alive;

   ---------------------
   -- Walk_Cb_Wrapper --
   ---------------------

   procedure Walk_Cb_Wrapper
     (Handle : Handle_Access;
      Arg    : access procedure (Handle : Handle_Access))
   is
   begin
      Arg.all (Handle);
   end Walk_Cb_Wrapper;

   ----------
   -- Walk --
   ----------

   procedure Walk
     (L  : Loop_Type;
      Cb : access procedure (Handle : Handle_Access))
   is
   begin
      Walk (L, Walk_Cb_Wrapper'Access, Cb);
   end Walk;

end UV;
