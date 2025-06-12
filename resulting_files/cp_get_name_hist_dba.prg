CREATE PROGRAM cp_get_name_hist:dba
 RECORD reply(
   1 name_hist[*]
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 name_full = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE curr_name_type_cd = f8
 DECLARE prev_name_type_cd = f8
 DECLARE namehistcount = i4
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(213,"CURRENT",1,curr_name_type_cd)
 SET stat = uar_get_meaning_by_codeset(213,"PREVIOUS",1,prev_name_type_cd)
 DECLARE bhistoption = i2 WITH noconstant(false)
 DECLARE dhistcd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(20790,"HISTORY",1,dhistcd)
 SELECT INTO "nl:"
  FROM code_value_extension cve
  WHERE cve.code_value=dhistcd
   AND cve.field_name="OPTION"
   AND cve.code_set=20790
  DETAIL
   IF (trim(cve.field_value,3)="1")
    bhistoption = cnvtint(trim(cve.field_value,3))
   ELSE
    bhistoption = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (bhistoption)
  SET namehistcount = 0
  SELECT
   IF ((request->sort_order_ind=1))
    ORDER BY pn.transaction_dt_tm DESC
   ELSE
    ORDER BY pn.transaction_dt_tm
   ENDIF
   INTO "nl:"
   pn.transaction_dt_tm, pn.name_full, pn.name_type_cd,
   pn.person_id
   FROM person_name_hist pn
   WHERE (pn.person_id=request->person_id)
    AND pn.name_type_cd=curr_name_type_cd
    AND pn.active_ind=1
   HEAD pn.transaction_dt_tm
    namehistcount = (namehistcount+ 1)
    IF (mod(namehistcount,10)=1)
     stat = alterlist(reply->name_hist,(namehistcount+ 9))
    ENDIF
    reply->name_hist[namehistcount].name_full = pn.name_full, reply->name_hist[namehistcount].
    beg_effective_dt_tm = pn.transaction_dt_tm
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET stat = alterlist(reply->name_hist,namehistcount)
   SET x = 0
   IF ((request->sort_order_ind=1))
    SET reply->name_hist[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    FOR (x = 2 TO namehistcount)
      SET reply->name_hist[x].end_effective_dt_tm = reply->name_hist[(x - 1)].beg_effective_dt_tm
    ENDFOR
   ELSE
    FOR (x = 1 TO namehistcount)
      IF (x=namehistcount)
       SET reply->name_hist[x].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      ELSE
       SET reply->name_hist[x].end_effective_dt_tm = reply->name_hist[(x+ 1)].beg_effective_dt_tm
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ELSE
  SELECT
   IF ((request->sort_order_ind=1))
    ORDER BY pn.end_effective_dt_tm DESC
   ELSE
    ORDER BY pn.end_effective_dt_tm
   ENDIF
   INTO "nl:"
   pn.end_effective_dt_tm, pn.beg_effective_dt_tm, pn.name_full,
   pn.name_type_cd, pn.person_id
   FROM person_name pn
   WHERE (pn.person_id=request->person_id)
    AND ((pn.name_type_cd=prev_name_type_cd) OR (pn.name_type_cd=curr_name_type_cd))
    AND pn.active_ind=1
   HEAD REPORT
    namehistcount = 0
   HEAD pn.end_effective_dt_tm
    IF (pn.name_type_cd=prev_name_type_cd
     AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     do_nothing = 0
    ELSE
     namehistcount = (namehistcount+ 1)
     IF (mod(namehistcount,10)=1)
      stat = alterlist(reply->name_hist,(namehistcount+ 9))
     ENDIF
     reply->name_hist[namehistcount].name_full = pn.name_full, reply->name_hist[namehistcount].
     beg_effective_dt_tm = pn.beg_effective_dt_tm, reply->name_hist[namehistcount].
     end_effective_dt_tm = pn.end_effective_dt_tm
    ENDIF
   DETAIL
    do_nothing = 0
   FOOT  pn.end_effective_dt_tm
    do_nothing = 0
   FOOT REPORT
    stat = alterlist(reply->name_hist,namehistcount)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "Select"
  SET reply->status_data.operationstatus = "F"
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.targetobjectname = "Qualifications"
   SET reply->status_data.targetobjectvalue = "No matching records"
  ENDIF
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
