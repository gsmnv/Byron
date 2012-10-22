with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Plugin.Base;           use Plugin.Base;
with Plugin.URL;            use Plugin.URL;
with IRC;

package Plugin_Management
is

   type Callback is access procedure (Message : IRC.Message);

   type Plugins is (Say, Title, Join, Leave, Nick);

   Callbacks : constant array (Plugins) of Callback :=
     (Say   => Say'Access,
      Title => URL_Title'Access,
      Join  => Join'Access,
      Leave => Leave'Access,
      Nick  => Nick'Access);

   type Options is (Contextual, Secure);
   type Options_Arguments is array (Options) of Boolean;

   Settings : constant array (Plugins) of Options_Arguments :=
     (Say   => (Contextual => False,
                Secure     => True),
      Title => (True, False),
      Join  => (False, True),
      Leave => (False, True),
      Nick  => (False, True));

   function Get_Command (Message : IRC.Message) return Unbounded_String;

   procedure Execute_Commands (Message : IRC.Message;
                               Owner   : Unbounded_String;
                               Prefix  : Character);

end Plugin_Management;
