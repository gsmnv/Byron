with IRC;

package Plugin.Base
is

   procedure Say (Message : IRC.Message);

   procedure Join (Message : IRC.Message);

   procedure Leave (Message : IRC.Message);

   procedure Nick (Message : IRC.Message);

end Plugin.Base;
