CREATE PROGRAM dcp_get_encntrs_by_nurse_loc:dba
 RECORD reply(
   1 loc_nurse_unit_list[*]
     2 loc_nurse_unit_cd = f8
     2 encntr_list[*]
       3 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE nurseunitlistcnt = i4 WITH constant(size(request->loc_nurse_unit_list,5))
 DECLARE errcode = i4 WITH protected, noconstant(1)
 DECLARE errmsg = c132 WITH protected, noconstant(fillstring(132," "))
 IF (nurseunitlistcnt <= 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "An empty loc_nurse_unit_list was passed in the request"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO nurseunitlistcnt)
   IF ((request->loc_nurse_unit_list[i].loc_nurse_unit_cd <= 0.0))
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "An invalid loc_nurse_unit_cd was passed in the request"
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nurseunitlistcnt)),
   encntr_domain ed
  PLAN (d)
   JOIN (ed
   WHERE (ed.loc_nurse_unit_cd=request->loc_nurse_unit_list[d.seq].loc_nurse_unit_cd)
    AND ed.active_ind=1)
  ORDER BY ed.loc_nurse_unit_cd, ed.encntr_id
  HEAD REPORT
   nurseunitcnt = 0
  HEAD ed.loc_nurse_unit_cd
   nurseunitcnt = (nurseunitcnt+ 1)
   IF (nurseunitcnt > size(reply->loc_nurse_unit_list,5))
    stat = alterlist(reply->loc_nurse_unit_list,(nurseunitcnt+ 10))
   ENDIF
   reply->loc_nurse_unit_list[nurseunitcnt].loc_nurse_unit_cd = ed.loc_nurse_unit_cd, encntrcnt = 0
  DETAIL
   encntrcnt = (encntrcnt+ 1)
   IF (encntrcnt > size(reply->loc_nurse_unit_list[nurseunitcnt].encntr_list,5))
    stat = alterlist(reply->loc_nurse_unit_list[nurseunitcnt].encntr_list,(encntrcnt+ 50))
   ENDIF
   reply->loc_nurse_unit_list[nurseunitcnt].encntr_list[encntrcnt].encntr_id = ed.encntr_id
  FOOT  ed.loc_nurse_unit_cd
   stat = alterlist(reply->loc_nurse_unit_list[nurseunitcnt].encntr_list,encntrcnt)
  FOOT REPORT
   stat = alterlist(reply->loc_nurse_unit_list,nurseunitcnt)
  WITH check, nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->subeventstatus[1].operationname = "SELECT"
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].targetobjectname = "ENCNTR_DOMAIN"
  SET reply->subeventstatus[1].targetobjectvalue = errmsg
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
