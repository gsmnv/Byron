with Ada.Text_IO; use Ada.Text_IO;

package body Config
is

   procedure Parse (File_Name : String)
   is

      function Get_Value (Input : Unbounded_String) return Unbounded_String
      is
         Result : Unbounded_String;
      begin
         for I in Index (Input, ":") + 1 .. Length (Input) loop
            Result := Result & Element (Input, I);
         end loop;
         return Result;
      end Get_Value;

      Config_File : File_Type;
      Line        : Unbounded_String;
      Char        : Character;

   begin
      Open (Config_File, In_File, File_Name);

      while not End_Of_File (Config_File) loop
         while not End_Of_Line (Config_File) loop
            Get (Config_File, Char);
            if not (Char = ' ') then
               Line := Line & Char;
            end if;
         end loop;
         declare
            Str : constant String := To_String (Line);
         begin
            if Str (1 .. 6) = "server" then
               Server := Get_Value (Line);
            elsif Str (1 .. 4) = "port" then
               Port := Integer'Value (To_String (Get_Value (Line)));
            elsif Str (1 .. 4) = "nick" then
               Nick := Get_Value (Line);
            elsif Str (1 .. 8) = "password" then
               Password := Get_Value (Line);
            elsif Str (1 .. 8) = "channels" then
               Channels := Words (GSub (Get_Value (Line), "#", " "));
            elsif Str (1 .. 5) = "owner" then
               Owner := Get_Value (Line);
            elsif Str (1 .. 6) = "prefix" then
               Prefix := Element (Get_Value (Line), 1);
            end if;
         end;
         Delete (Line, 1, Length (Line));
         Skip_Line (Config_File);
      end loop;

      Close (Config_File);

   end Parse;

end Config;
