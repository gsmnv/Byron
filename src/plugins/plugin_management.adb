with Ada.Characters.Handling; use Ada.Characters.Handling;

package body Plugin_Management
is

   function Get_Command (Message : IRC.Message) return Unbounded_String
   is
      Command : Unbounded_String;
   begin
      for I in 1 .. Length (Message.Content) loop
         if Element (Message.Content, I) /= ' ' then
            Append (Command, Element (Message.Content, I));
         else
            exit;
         end if;
      end loop;
      return Command;
   end Get_Command;

   procedure Execute_Commands (Message : IRC.Message;
                               Owner   : Unbounded_String;
                               Prefix  : Character)
   is
      Command : constant String := To_Upper (To_String (Get_Command (Message)));
      Answer  : IRC.Message := Message;
   begin
      for I in 0 .. Plugins'Pos (Plugins'Last) loop
         if Command = Prefix & To_Upper (Plugins'Image (Plugins'Val (I))) then
            if Settings (Plugins'Val (I)) (Secure) and Message.Sender /= Owner then
               Answer.Content := To_Unbounded_String ("You can't do that.");
               IRC.Put_Message (Answer);
               exit;
            else
               Callbacks (Plugins'Val (I)) (Message);
               exit;
            end if;
         end if;
         if Settings (Plugins'Val (I)) (Contextual) then
            Callbacks (Plugins'Val (I)) (Message);
         end if;
      end loop;
   end Execute_Commands;

end Plugin_Management;
