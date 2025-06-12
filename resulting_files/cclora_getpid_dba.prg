CREATE PROGRAM cclora_getpid:dba
 PROMPT
  "Enter output device (MINE): " = "MINE",
  "Enter process id (0=get ORA pid of current process): " = "0"
 DECLARE _pid = vc
 IF (curenv=0)
  IF (cnvtint( $2) > 0)
   SET _pid = trim( $2)
  ELSE
   CALL echo("Reading pid from CURPRCNAME..")
   IF (cursys="AIX")
    SET userlen = textlen(trim(curuser))
    SET prclen = textlen(trim(curprcname))
    SET _pid = substring((userlen+ 1),((prclen - userlen) - 1),curprcname)
   ELSE
    SET _pid = substring(1,8,curprcname)
   ENDIF
   CALL echo(concat("CURPRCNAME= ",trim(curprcname),", CCL pid= ",_pid))
  ENDIF
  SELECT INTO  $1
   hnam_pid = _pid, machine = substring(1,10,s.machine), ora_pid = p.spid,
   ora_user = substring(1,10,s.username), os_user = substring(1,10,s.osuser), s.program
   FROM v$process p,
    v$session s
   WHERE p.addr=s.paddr
    AND s.process=_pid
   WITH format, separator = " ", nocounter
  ;end select
 ELSE
  SELECT INTO  $1
   cclora_getpid = "cclora_getpid is supported only for CCL sessions"
   FROM dummyt d
   WITH format, separator = " ", nocounter
  ;end select
 ENDIF
END GO
