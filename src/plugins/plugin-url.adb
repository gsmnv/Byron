with Scape;                           use Scape;
with Ada.Characters.Conversions;      use Ada.Characters.Conversions;
with Ada.Strings.Wide_Wide_Unbounded; use Ada.Strings.Wide_Wide_Unbounded;
with AWS.Client;                      use AWS.Client;
with GNAT.Regpat;                     use Gnat.Regpat;
with AWS.Response;                    use AWS.Response;
with ZLib;                            use ZLib;
use AWS;

package body Plugin.URL
is

   function Unescape (Str : String) return String is
     (To_String (To_Wide_Wide_String (Decode (Str))));

   -- FIXME: Fix this crap
   function Get_Body (URL : Unbounded_String) return String
   is
      Limit : constant Content_Range := (1, 3000);
   begin
      return Message_Body (Get (URL => To_String (URL), Data_Range => Limit));
   exception
      when Zlib_Error => return Message_Body (Get (To_String (URL)));
   end Get_Body;

   -- Strip newlines from title, just a corner case.
   function Normalize_Title (Raw : String) return Unbounded_String is
     (GSub (To_Unbounded_String (Bold ("Title: ") & Unescape (Raw)), ASCII.CR & ASCII.LF, ""));

   function Get_Title (URL : Unbounded_String) return Unbounded_String
   is
      Header  : constant Data := Head (To_String (URL));
      Regex   : constant Pattern_Matcher :=
        Compile ("<title>(.*)<\/title>", Case_Insensitive or Single_Line);
      Result  : Match_Array (0 .. 1);
   begin
      if Response.Header (Header, "Content-Type") (1 .. 4) = "text" then
         declare
            Content : constant String := Get_Body (URL);
         begin
            Match(Regex, Content, Result);
            if not (Result(1) = No_Match) then
               return Normalize_Title (Content (Result(1).First .. Result(1).Last));
            else
               return To_Unbounded_String ("Title not found");
            end if;
         end;
      else
         return To_Unbounded_String
           (Bold ("Content-Type: ")
            & Response.Header (Header, "Content-Type")
            & ", " & Bold ("Size: ")
            & Response.Header (Header, "Content-Length"));
      end if;
   end Get_Title;

   procedure URL_Title (Message : IRC.Message)
   is
      Answer : IRC.Message := Message;
   begin
      for C in Iterate (Words (Message.Content)) loop
         if Link (Element (C)) then
            Answer.Content := Get_Title (Element (C));
            IRC.Put_Message (Answer);
            exit;
         end if;
      end loop;
   exception
         -- Silently ignore exceptions like malformed url or connection problems
      when others => null;
   end URL_Title;


end Plugin.URL;
