with Ada.Strings.Unbounded;   use Ada.Strings.Unbounded;
with GNAT.Sockets;            use GNAT.Sockets;

package IRC is

   type Mode is (Quit, Part, Privmsg, Join);
   Modes : array (Mode) of Unbounded_String :=
     (To_Unbounded_String ("QUIT"),
      To_Unbounded_String ("PART"),
      To_Unbounded_String ("PRIVMSG"),
      To_Unbounded_String ("JOIN"));

   type Message is
      record
         Sender  : Unbounded_String;
         Mode    : Unbounded_String;
         Channel : Unbounded_String;
         Content : Unbounded_String;
      end record;

   procedure Connect_To (Server : Sock_Addr_Type);

   function Get_Line return Unbounded_String;

   procedure Put_Line (Line : String);

   procedure Set_Nick (Nick : String);

   procedure Join_Channel (Chan : String);

   function Get_Message return Message;

   procedure Put_Message (Msg : Message);

   procedure Pong;

   function Get_Nick (Msg : Message) return Unbounded_String;

   procedure Identify (Password : String);

end IRC;
