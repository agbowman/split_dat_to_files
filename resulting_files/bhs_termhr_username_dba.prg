CREATE PROGRAM bhs_termhr_username:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.username = concat("TERMHR",p.username,"_",format(curdate,"YYYYMMDD;;d")), p
   .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_cd = 194,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
  WHERE ((p.physician_ind != 1) OR (p.physician_ind=1
   AND ((p.position_cd=227480046) OR (p.position_cd=228835487))
   AND p.active_ind=1))
   AND p.active_status_cd != 189.00
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,0)
   AND ((p.username="Z99999999") OR (((p.username="EN06487") OR (((p.username="EN10676") OR (((p
  .username="EN12075") OR (((p.username="EN12085") OR (((p.username="EN12090") OR (((p.username=
  "EN12098") OR (((p.username="EN12125") OR (((p.username="EN12128") OR (((p.username="EN13484") OR (
  ((p.username="EN13494") OR (((p.username="EN13496") OR (((p.username="EN13501") OR (((p.username=
  "EN13503") OR (((p.username="EN13507") OR (((p.username="EN13509") OR (((p.username="EN13510") OR (
  ((p.username="EN13511") OR (((p.username="EN13519") OR (((p.username="EN13523") OR (((p.username=
  "EN13526") OR (((p.username="EN13533") OR (((p.username="EN13534") OR (((p.username="EN13541") OR (
  ((p.username="EN13542") OR (((p.username="EN13547") OR (((p.username="EN13557") OR (((p.username=
  "EN13561") OR (((p.username="EN13562") OR (((p.username="EN13564") OR (((p.username="EN13570") OR (
  ((p.username="EN14550") OR (((p.username="EN14551") OR (((p.username="EN14552") OR (((p.username=
  "EN14555") OR (((p.username="EN14558") OR (((p.username="EN14564") OR (((p.username="EN14580") OR (
  ((p.username="EN14591") OR (((p.username="EN14592") OR (((p.username="EN14593") OR (((p.username=
  "EN14601") OR (((p.username="EN14616") OR (((p.username="EN14617") OR (((p.username="EN14621") OR (
  ((p.username="EN14623") OR (((p.username="EN14626") OR (((p.username="EN14627") OR (((p.username=
  "EN14629") OR (((p.username="EN14631") OR (((p.username="EN14641") OR (((p.username="EN14787") OR (
  ((p.username="EN14891") OR (((p.username="EN15498") OR (((p.username="EN15506") OR (((p.username=
  "EN15544") OR (((p.username="EN15564") OR (((p.username="EN15566") OR (((p.username="EN16513") OR (
  ((p.username="EN16540") OR (((p.username="EN16544") OR (((p.username="EN16551") OR (((p.username=
  "EN16558") OR (((p.username="EN16580") OR (((p.username="EN16581") OR (((p.username="EN16588") OR (
  ((p.username="EN16597") OR (((p.username="EN16614") OR (((p.username="EN16623") OR (((p.username=
  "EN16644") OR (((p.username="EN43963") OR (p.username="EN47334")) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   AND p.username != "*RF*"
  WITH maxrec = 100
 ;end update
 COMMIT
END GO
