CREATE PROGRAM cclorasession:dba
 PROMPT
  "Enter output (MINE): " = "MINE",
  "Sort by (M)achine, (U)sername, (O)suser, (P)rocess:  " = "M"
 SET sort1 = cnvtupper( $2)
 SELECT
  IF (sort1="M")
   ORDER BY machine, username
  ELSEIF (sort1="U")
   ORDER BY username, machine
  ELSEIF (sort1="O")
   ORDER BY osuser, machine
  ELSEIF (sort1="P")
   ORDER BY process, machine
  ELSE
  ENDIF
  INTO trim( $1)
  machine = substring(1,10,r.machine), username = substring(1,10,r.username), osuser = substring(1,10,
   r.osuser),
  r.process, r.terminal, r.sid"########",
  r.serial#"########", r.user#"########", r.lockwait,
  r.status, r.server, schemaname = substring(1,10,r.schemaname),
  r.type, r.logon_time";;q", r.program
  FROM v$session r
  WITH nocounter
 ;end select
END GO
