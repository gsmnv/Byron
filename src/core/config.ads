with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Plugin;                use Plugin;

package Config
is

   Channels : Plugin.Vectors.Vector;
   Port     : Integer;
   Prefix   : Character;
   Server, Nick, Password, Owner : Unbounded_String;

   procedure Parse (File_Name : String);

end Config;
