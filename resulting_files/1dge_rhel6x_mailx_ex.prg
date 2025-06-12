CREATE PROGRAM 1dge_rhel6x_mailx_ex
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Email To:" = "USER@DOM.TLD"
  WITH outdev, emailto
 DECLARE fname = vc WITH noconstant("zzzztest.csv"), protect
 SET stat = remove(fname)
 DECLARE dclcommandstring1 = vc WITH noconstant(" "), protect
 DECLARE dclcommandstring2 = vc WITH noconstant(" "), protect
 DECLARE dclstatus = i4
 SELECT INTO value(fname)
  p.active_ind, p.username, p.position_cd,
  p.updt_dt_tm
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  WITH format, format = pcformat
 ;end select
 SET dclcommandstring1 = build2("uuencode ",fname," ",fname,
  ' | mailx -s "Test Email using UUENCODE" ',
   $EMAILTO)
 SET dcllen1 = size(trim(dclcommandstring1))
 SET dclstatus = 0
 CALL dcl(dclcommandstring1,dcllen1,dclstatus)
 CALL echo(dclcommandstring1)
 CALL echo(build("Status=",dclstatus))
 SET dclcommandstring2 = build2('echo "Test for email attachments on RHEL 6.x"'," | mailx -s ",fname,
  " -a ",fname,
  " ", $EMAILTO)
 SET dcllen1 = size(trim(dclcommandstring2))
 SET dclstatus = 0
 CALL dcl(dclcommandstring2,dcllen1,dclstatus)
 CALL echo(dclcommandstring2)
 CALL echo(build("Status=",dclstatus))
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   col 0, "Command string for RHEL 5.x email:", row + 1,
   col 0, dclcommandstring1, row + 2,
   col 0, "Command string for RHEL 6.x email:", row + 1,
   col 0, dclcommandstring2
 ;end select
END GO
