package body IRC
is

   Client  : Socket_Type;
   Channel : Stream_Access;

   Current_Line : Unbounded_String;

   procedure Connect_To (Server : Sock_Addr_Type)
   is
   begin
      Create_Socket (Client);
      Connect_Socket (Client, Server);
      Channel := Stream (Client);
   end Connect_To;

   function Get_Line return Unbounded_String
   is
      Line    : Unbounded_String;
      Char    : Character;
   begin
      loop
         Char := Character'Input (Channel);
         if Char = ASCII.LF then
            Current_Line := Line;
            return Line;
         elsif Char /= ASCII.CR then
            Append (Line, Char);
         end if;
      end loop;
   end Get_Line;

   procedure Put_Line (Line : String)
   is
      CRLF : constant String := ASCII.CR & ASCII.LF;
   begin
      String'Write (Channel, Line & CRLF);
   end Put_Line;

   procedure Set_Nick (Nick : String)
   is
   begin
      Put_Line ("NICK " & Nick);
      Put_Line ("USER " & Nick & " 0 * :Byron IRC bot, https://github.com/gsmnv/Byron");
   end Set_Nick;

   procedure Join_Channel (Chan : String)
   is
   begin
      Put_Line ("JOIN " & Chan);
   end Join_Channel;

   function Get_Message return Message
   is
      Msg    : Message;
      Count  : Integer := 1;
   begin
      for I in 1 .. Length (Current_Line) loop
         if Count > 3 then
               Append (Msg.Content, Element (Current_Line, I));
         elsif Element (Current_Line, I) /= ' ' then
            if Count = 1 then
               Append (Msg.Sender, Element (Current_Line, I));
            elsif Count = 2 then
               Append (Msg.Mode, Element (Current_Line, I));
            elsif Count = 3 then
               Append (Msg.Channel, Element (Current_Line, I));
            end if;
         else
            Count := Count + 1;
         end if;
      end loop;

      if Element (Current_Line, 1) = ':' then
         -- Remove ':' from Message
         Replace_Slice (Msg.Sender, 1, 1, "");
         Replace_Slice (Msg.Content, 1, 1, "");

         -- Check if private message
         if Element (Msg.Channel, 1) /= '#' then
            Msg.Channel := Get_Nick (Msg);
         end if;
      end if;

      return Msg;
   end Get_Message;

   procedure Put_Message (Msg : Message)
   is
   begin
      Put_Line (To_String (Msg.Mode & " " & Msg.Channel & " :" & Msg.Content));
   end Put_Message;

   procedure Pong
   is
      Line : constant String := To_String (Current_Line);
   begin
      if Line (1 .. 4) = "PING" then
         Put_Line ("PONG " & Line (6 .. Line'Length));
      else
         null;
      end if;
   end Pong;

   function Get_Nick (Msg : Message) return Unbounded_String
   is
      Nick : Unbounded_String := Msg.Sender;
   begin
      Replace_Slice (Nick, Index (Nick, "!"), Length (Nick), "");
      return Nick;
   exception
      when Constraint_Error =>
         return Nick;
   end Get_Nick;

   procedure Identify (Password : String)
   is
   begin
      Put_Line ("NICKSERV IDENTIFY " & Password);
   end Identify;

end IRC;
