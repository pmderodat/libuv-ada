with Interfaces;
with Interfaces.C;

with System;

package UV is

   --  %uv_errno_t
   type Errno_T is (OK)
      with Convention => C;
   --  %end

   type Handle_Type is private;
   type Handle_Access is access Handle_Type;
   --  The base libuv handle type

   --  TODO??? Alloc_Cb

   type Loop_Type is private;
   --  Loop data type

   No_Loop : constant Loop_Type;
   --  Constant to mean the absence of loop

   type Run_Mode is (Default, Once, No_Wait);
   --  Mode used to run the loop with

   type Loop_Data_Type is new System.Address;

   function Alloc return Loop_Type;
   --  Allocate and return a new loop

   function Init (L : Loop_Type) return Errno_T
      with Import        => True,
           Convention    => C,
           External_Name => "uv_loop_init";
   --  Initialize a loop

   function Get_Data (L : Loop_Type) return Loop_Data_Type
      with Inline_Always;
   --  Return the user-defined arbitrary data stored in the L loop

   procedure Set_Data (L : Loop_Type; D : Loop_Data_Type)
      with Inline_Always;
   --  Initialize the user-defined arbitrary data stored in the L loop to D

   --  TODO??? Loop_Configure

   function Close (L : in out Loop_Type) return Errno_T;
   --  Release all internal loop resources and deallocate the loop itself

   pragma Export
     (Convention    => Ada,
      Entity        => Close,
      External_Name => "_ada_uv__close");
   --  This is exported under a special name not to clash with an internal
   --  symbol from libuv (uv__close). TODO??? Turn the Export pragma into an
   --  aspect once its compiler support is fixed.

   function Default_Loop return Loop_Type
      with Import        => True,
           Convention    => C,
           External_Name => "uv_default_loop";
   --  Return the initialized default loop, or No_Loop in case of allocation
   --  failure.

   function Run (L : Loop_Type; Mode : Run_Mode) return Errno_T
      with Import        => True,
           Convention    => C,
           External_Name => "uv_run";
   --  Run the event loop

   function Loop_Alive (L : Loop_Type) return Boolean
      with Inline_Always;
   --  Return non-zero if there are active handles or request in the loop

   procedure Stop (L : Loop_Type)
      with Import        => True,
           Convention    => C,
           External_Name => "uv_stop";
   --  Stop the event loop, causing Run to end as soon as possible.

   function Now (L : Loop_Type) return Interfaces.Unsigned_64
      with Import        => True,
           Convention    => C,
           External_Name => "uv_loop";
   --  Return the current timestamp in milliseconds

   procedure Update_Time (L : Loop_Type)
      with Import        => True,
           Convention    => C,
           External_Name => "uv_update_time";
   --  Update the event loop's concept of "now"

   procedure Walk
     (L  : Loop_Type;
      Cb : access procedure (Handle : Handle_Access))
      with Inline_Always;
   --  Walk the list of handles

private

   type Handle_Type is null record;
   --  TODO???

   type Loop_Type is new System.Address;

   No_Loop : constant Loop_Type := Loop_Type (System.Null_Address);

end UV;
