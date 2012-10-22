with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Sockets;          use GNAT.Sockets;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Plugin_Management;     use Plugin_Management;
with Ada.Command_Line;      use Ada.Command_Line;
with Plugin;
with IRC;
with Config;

with Ada.Streams;

use type Ada.Streams.Stream_Element_Count;

procedure Byron is
   Invalid_Arguments : exception;
   Verbose           : Boolean := False;
begin

   if Argument_Count < 1 then
      raise Invalid_Arguments;
   elsif Argument (1) = "-v" then
      if Argument_Count < 2 then
         raise Invalid_Arguments;
      else
         Verbose := True;
         Config.Parse (Argument (2));
      end if;
   else
      Config.Parse (Argument (1));
   end if;

   declare

      Address : constant Sock_Addr_Type :=
        (Addr   => Addresses (Get_Host_By_Name (To_String (Config.Server))),
         Port   => Port_Type (Config.Port),
         Family => Family_Inet);

   begin

      IRC.Connect_To (Address);
      IRC.Set_Nick (To_String (Config.Nick));
      IRC.Identify (To_String (Config.Password));

      for C in Plugin.Vectors.Iterate (Config.Channels) loop
         IRC.Join_Channel ('#' & To_String (Plugin.Vectors.Element (C)));
      end loop;

      loop
         declare
            Line     : constant String := To_String (IRC.Get_Line);
            Message  : constant IRC.Message := IRC.Get_Message;
         begin
            if Verbose then
               Put_Line (Line);
            end if;
            IRC.Pong;
            if Message.Mode = IRC.Modes (IRC.Privmsg) then
               Execute_Commands (Message, Config.Owner, Config.Prefix);
            end if;
         end;
      end loop;

   end;

exception
   when Invalid_Arguments =>
      Put_Line ("Usage: byron [-v] CONFIG_FILE");
      Put_Line ("-v     verbose mode");
end Byron;
