package body Plugin
is

   function Words (Str : Unbounded_String) return Vector
   is
      Result : Vector;
      Word   : Unbounded_String;
   begin
      for I in 1 .. Length (Str) loop
         if Element (Str, I) /= ' ' and I /= Length (Str) then
            Append (Word, Element (Str, I));
         else
            if I = Length (Str) then
               Append (Word, Element (Str, I));
            end if;
            Append (Result, Word);
            Delete (Word, 1, Length (Word));
         end if;
      end loop;
      return Result;
   end Words;

   function Unwords (Words : Vector) return Unbounded_String
   is
      Result : Unbounded_String;
   begin
      for C in Iterate (Words) loop
         Append (Result, Element (C) & " ");
      end loop;
      return Result;
   end Unwords;

   function Bold (Input : String) return String is
      (Character'Val (8#02#) & Input & Character'Val (8#02#));

   function Link (Input : Unbounded_String) return Boolean
   is
   begin
      if Length (Input) > 7 then
         declare
            Maybe_Link : constant String := To_String (Input) (1 .. 7);
         begin
            if Maybe_Link = "http://" or Maybe_Link = "https:/" then
               return True;
            end if;
         end;
      end if;
      return False;
   exception
      when others =>
         return False;
   end Link;

   function GSub (Str  : Unbounded_String;
                  From : String;
                  To   : String) return Unbounded_String
   is
      Result    : Unbounded_String := Str;
      Start_Pos : Integer := Index (Result, From (From'First) & "");
      End_Pos   : Natural := Index (Result, From (From'Last) & "");
   begin
      loop
         if Start_Pos /= 0 then
            Replace_Slice (Result, Start_Pos, End_Pos, To);
            Start_Pos := Index (Result, From (From'First) & "");
            End_Pos := Index (Result, From (From'Last) & "");
         else
            exit;
         end if;
      end loop;
      return Result;
   end GSub;

end Plugin;
