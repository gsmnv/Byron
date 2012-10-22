package body Plugin.Base
is

   procedure Say (Message : IRC.Message)
   is
      Arguments : Vector := Words (Message.Content);
      Answer : IRC.Message := Message;
   begin
      Answer.Channel := Arguments (2);
      Delete (Arguments, 1);
      Delete (Arguments, 1);
      Answer.Content := Unwords (Arguments);
      IRC.Put_Message (Answer);
   end Say;

   procedure Join (Message : IRC.Message)
   is
      Channel : Unbounded_String := Words (Message.Content)(2);
   begin
      if Element (Channel, 1) /= '#' then
         Channel := "#" & Channel;
      end if;
      IRC.Join_Channel (To_String (Channel));
   end Join;

   procedure Leave (Message : IRC.Message)
   is
   begin
      IRC.Put_Line (To_String ("PART " & Message.Channel));
   end Leave;

   procedure Nick (Message : IRC.Message)
   is
   begin
      IRC.Set_Nick (To_String (Element (Words (Message.Content), 2)));
   end Nick;

end Plugin.Base;
