with Ada.Unchecked_Deallocation;

with System.Memory;

package body UV is

   -------------------
   -- Loop handling --
   -------------------

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

   -------------------------
   -- Base handle support --
   -------------------------

   function Is_Active (H : Handle_Access) return Interfaces.C.int
      with Import        => True,
           Convention    => C,
           External_Name => "uv_is_active";

   function Is_Closing (H : Handle_Access) return Interfaces.C.int
      with Import        => True,
           Convention    => C,
           External_Name => "uv_is_closing";

   function Has_Ref (H : Handle_Access) return Interfaces.C.int
      with Import        => True,
           Convention    => C,
           External_Name => "uv_has_ref";

   --------------
   -- Get_Loop --
   --------------

   function Get_Loop (H : Handle_Access) return Loop_Type is
   begin
      return H.UV_Loop;
   end Get_Loop;

   --------------
   -- Get_Data --
   --------------

   function Get_Data (H : Handle_Access) return Handle_Data_Type is
   begin
      return H.Data;
   end Get_Data;

   --------------
   -- Set_Data --
   --------------

   procedure Set_Data (H : Handle_Access; D : Handle_Data_Type) is
   begin
      H.Data := D;
   end Set_Data;

   ---------------
   -- Is_Active --
   ---------------

   function Is_Active (H : Handle_Access) return Boolean is
   begin
      return Interfaces.C."/=" (Is_Active (H), 0);
   end Is_Active;

   ----------------
   -- Is_Closing --
   ----------------

   function Is_Closing (H : Handle_Access) return Boolean is
   begin
      return Interfaces.C."/=" (Is_Closing (H), 0);
   end Is_Closing;

   -------------
   -- Has_Ref --
   -------------

   function Has_Ref (H : Handle_Access) return Boolean is
   begin
      return Interfaces.C."/=" (Has_Ref (H), 0);
   end Has_Ref;

   ---------------------------
   -- Base request handling --
   ---------------------------

   --------------
   -- Get_Kind --
   --------------

   function Get_Kind (R : Req_Access) return Req_Kind is
   begin
      return R.Kind;
   end Get_Kind;

   --------------
   -- Get_Data --
   --------------

   function Get_Data (R : Req_Access) return Req_Data_Type is
   begin
      return R.Data;
   end Get_Data;

   --------------
   -- Set_Data --
   --------------

   procedure Set_Data (R : Req_Access; D : Req_Data_Type) is
   begin
      R.Data := D;
   end Set_Data;

   -----------------
   -- Idle handle --
   -----------------

   -------------
   -- Destroy --
   -------------

   procedure Destroy (Idle : in out Idle_Handle_Access)
   is
      procedure Destroy is new Ada.Unchecked_Deallocation
        (Idle_Handle, Idle_Handle_Access);
   begin
      Destroy (Idle);
   end Destroy;

end UV;
