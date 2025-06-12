CREATE PROGRAM bed_assoc_prsnl_orgs
 FREE SET tempreq
 RECORD tempreq(
   1 org_set_name = vc
 )
 FREE SET personnel_list
 RECORD personnel_list(
   1 plist[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 action_flag = i2
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
#1000_initialize
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET active_cd = get_code_value(48,"ACTIVE")
 SET auth_cd = get_code_value(8,"AUTH")
 SET security_cd = get_code_value(28881,"SECURITY")
 SET tempreq->org_set_name =  $1
 SET error_flag = "Y"
 SET anything = 0
 IF ((tempreq->org_set_name > ""))
  SET anything = 1
 ENDIF
 IF (anything=0)
  SET error_msg = "No Organization Set Name Passed"
  GO TO exit_script
 ENDIF
 SET org_set_id = 0
 SELECT INTO "NL:"
  FROM org_set os
  PLAN (os
   WHERE (os.name=tempreq->org_set_name)
    AND os.active_ind=1)
  DETAIL
   org_set_id = os.org_set_id
  WITH nocounter
 ;end select
 IF (org_set_id=0)
  SET error_msg = "Invalid Organization Set"
  GO TO exit_script
 ENDIF
 SET pcount = 0
 SELECT INTO "NL:"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1)
  DETAIL
   pcount = (pcount+ 1), stat = alterlist(personnel_list->plist,pcount), personnel_list->plist[pcount
   ].person_id = p.person_id,
   personnel_list->plist[pcount].name_full_formatted = p.name_full_formatted, personnel_list->plist[
   pcount].action_flag = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_msg = "No Active Personnel"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM org_set_prsnl_r o,
   (dummyt d  WITH seq = pcount)
  PLAN (d)
   JOIN (o
   WHERE (personnel_list->plist[d.seq].person_id=o.prsnl_id)
    AND o.active_ind=1)
  DETAIL
   personnel_list->plist[d.seq].action_flag = 2
  WITH nocounter
 ;end select
 INSERT  FROM org_set_prsnl_r o,
   (dummyt d  WITH seq = pcount)
  SET o.seq = 1, o.org_set_prsnl_r_id = seq(organization_seq,nextval), o.org_set_id = org_set_id,
   o.prsnl_id = personnel_list->plist[d.seq].person_id, o.org_set_type_cd = security_cd, o.active_ind
    = 1,
   o.active_status_cd = active_cd, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
   .active_status_prsnl_id = reqinfo->updt_id,
   o.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), o.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), o.updt_id = reqinfo->updt_id,
   o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0
  PLAN (d
   WHERE (personnel_list->plist[d.seq].action_flag=1))
   JOIN (o)
  WITH nocounter
 ;end insert
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 RETURN
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
     IF (write_mode=0)
      col 30, "AUDIT MODE: NO CHANGES HAVE BEEN MADE TO THE DATABASE"
     ELSE
      col 30, "COMMIT MODE: CHANGES HAVE BEEN MADE TO THE DATABASE"
     ENDIF
    DETAIL
     row + 2, col 2, "ROW",
     col 10, "HEALTH PLAN", col 30,
     "PROPERTY", col 50, "DETAIL",
     col 90, "STATUS", col 100,
     "ERROR"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE get_cv_by_disp(xcodeset,xdisp)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp)))
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
