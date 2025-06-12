CREATE PROGRAM bhs_sys_cleanup_dups
 PROMPT
  "Enter File name" = "<<File Name without extension>>",
  "Mode" = "TEST"
  WITH outdev, mode
 SET filepath = build("bhscust:", $1,".dat")
 CALL echo(build("Reading File:",filepath))
 IF (findfile(filepath) > 0)
  CALL echo("Found File")
 ELSE
  CALL echo("Did not find the file, will exit")
  GO TO exit_code
 ENDIF
 FREE RECORD duplist
 RECORD duplist(
   1 dupcnt = i4
   1 qual[*]
     2 eid = f8
     2 pid = f8
 )
 DECLARE finnbr = vc
 DECLARE name = vc
 FREE DEFINE rtl
 DEFINE rtl filepath
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  DETAIL
   duplist->dupcnt = (duplist->dupcnt+ 1), stat = alterlist(duplist->qual,duplist->dupcnt), duplist->
   qual[duplist->dupcnt].eid = cnvtreal(r.line)
  WITH noocunter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(duplist->dupcnt)),
   encounter e
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=duplist->qual[d.seq].eid))
  DETAIL
   duplist->qual[d.seq].pid = e.person_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO duplist->dupcnt)
   UPDATE  FROM encntr_alias ea
    SET ea.active_ind = 0, ea.end_effective_dt_tm = (sysdate - 1), ea.updt_dt_tm = sysdate,
     ea.updt_cnt = (ea.updt_cnt+ 1)
    WHERE (ea.encntr_id=duplist->qual[x].eid)
    WITH nocounter
   ;end update
   UPDATE  FROM encounter e
    SET e.disch_dt_tm = sysdate, e.active_ind = 0, e.data_status_cd = 28,
     e.updt_dt_tm = sysdate, e.end_effective_dt_tm = sysdate, e.updt_cnt = (e.updt_cnt+ 1)
    WHERE (e.encntr_id=duplist->qual[x].eid)
   ;end update
   UPDATE  FROM encntr_domain ed
    SET end_effective_dt_tm = sysdate, updt_dt_tm = sysdate
    WHERE (encntr_id=duplist->qual[x].eid)
   ;end update
   COMMIT
 ENDFOR
END GO
