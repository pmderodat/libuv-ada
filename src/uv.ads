with Interfaces;
with Interfaces.C;

with System;

--  Unless rare exceptions, all types and subprograms exposed in this package
--  bind a corresponding C entity. For extra details, please refer to libuv's
--  own documentation: <http://docs.libuv.org/>.

package UV is

   --  %uv_errno_t
   --  Post-processing will replace this with real errno codes
   type Errno_T is (Some_Error, OK)
      with Convention => C;
   for Errno_T use (Some_Error => -1, OK => 0);
   --  %end

   type Loop_Type is private;
   --  Loop data type

   No_Loop : constant Loop_Type;
   --  Constant to mean the absence of loop

   type Run_Mode is (Default, Once, No_Wait);
   --  Mode used to run the loop with

   type Loop_Data_Type is new System.Address;

   type Handle_Type (<>) is limited private;
   type Handle_Access is access Handle_Type;
   --  The base libuv handle type

   type Handle_Data_Type is new System.Address;

   type Handle_Kind is
     (Unknown_Handle, Async, Check, FS_Event, FS_Poll, Handle, Idle,
      Named_Pipe, Poll, Prepare, Process, Stream, TCP, Timer, TTY, UDP, Signal,
      File)
      with Convention => C;

   type Buf_T is record
      Base : System.Address;
      Len  : Interfaces.C.size_t;
   end record
      with Convention => C_Pass_By_Copy;
   type Buf_Access is access Buf_T;

   --------------------
   -- Loops handling --
   --------------------

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

   -------------------------
   -- Base handle support --
   -------------------------

   type Alloc_Cb is access procedure (Handle         : Handle_Access;
                                      Suggested_Size : Interfaces.C.size_t;
                                      Buf            : Buf_Access)
      with Convention => C;
   --  Callback passed to Read_Start and UDP_Recv_Start

   type Close_Cb is access procedure (Handle : Handle_Access)
      with Convention => C;
   --  Callback passed to Close

   function Get_Loop (H : Handle_Access) return Loop_Type
      with Inline_Always;
   --  Return the loop where the H handle is running on

   function Get_Data (H : Handle_Access) return Handle_Data_Type
      with Inline_Always;
   --  Return the user-defined arbitrary data stored in the H handle

   procedure Set_Data (H : Handle_Access; D : Handle_Data_Type)
      with Inline_Always;
   --  Initialize the user-defined arbitrary data stored in the H handle to D

   function Is_Active (H : Handle_Access) return Boolean
      with Inline_Always;
   --  Return whether the H handle is active

   function Is_Closing (H : Handle_Access) return Boolean
      with Inline_Always;
   --  Return whether the H handle is closing or closed

   procedure Close (H : Handle_Access; Cb : Close_Cb)
      with Import        => True,
           Convention    => C,
           External_Name => "uv_close";
   --  Request the H handle to be closed. Close_Cb wil be called asynchronously
   --  after this call.

   procedure Ref (H : Handle_Access)
      with Import        => True,
           Convention    => C,
           External_Name => "uv_ref";
   --  Reference the given handle

   procedure Unref (H : Handle_Access)
      with Import        => True,
           Convention    => C,
           External_Name => "uv_unref";
   --  Un-reference the given handle

   function Has_Ref (H : Handle_Access) return Boolean
      with Inline_Always;
   --  Return whether the handle is referenced

   function Handle_Size (K : Handle_Kind) return Interfaces.C.size_t
      with Import        => True,
           Convention    => C,
           External_Name => "uv_handle_size";
   --  Return the size of the given handle type

private

   type Handle_Type is limited record
      Data    : Handle_Data_Type;
      UV_Loop : Loop_Type;
   end record
      with Convention => C;
   --  This is an incomplete view of the uv_handle_s structure that exposes
   --  only the fields we need.

   type Loop_Type is new System.Address;

   No_Loop : constant Loop_Type := Loop_Type (System.Null_Address);

end UV;
