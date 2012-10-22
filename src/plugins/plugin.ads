with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

-- Misc functions for plugins development aid
package Plugin
is
   package Vectors is new Ada.Containers.Vectors (Positive, Unbounded_String);
   use Vectors;

   function Words (Str : Unbounded_String) return Vector;

   function Unwords (Words : Vector) return Unbounded_String;

   function Bold (Input : String) return String;

   function Link (Input : Unbounded_String) return Boolean;

   function GSub (Str  : Unbounded_String;
                  From : String;
                  To   : String) return Unbounded_String;

end Plugin;
