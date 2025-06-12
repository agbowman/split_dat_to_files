CREATE PROGRAM dcp_get_pl_new_res:dba
 RECORD reply(
   1 prsnl_list[*]
     2 prsnl_id = f8
     2 person_list[*]
       3 person_id = f8
       3 results_avail_ind = i2
       3 ppa_last_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE sz = i4 WITH private, noconstant(size(request->prsnl_list[1].person_list,5))
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE code_set = f8 WITH noconstant(0.0)
 DECLARE cdf_meaning = vc WITH noconstant(fillstring(12,""))
 DECLARE results_review_cd = f8 WITH noconstant(0.0)
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE select_error = i2 WITH constant(7)
 DECLARE table_name = vc WITH noconstant(fillstring(50," "))
 DECLARE serrmsg = vc WITH noconstant(fillstring(132," "))
 DECLARE results_review_cd = f8 WITH constant(uar_get_code_by("MEANING",104,"RESULT REVIE"))
 IF (results_review_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning RESULT REVIE from code_set 104"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  event_ind = nullind(pp.last_event_updt_dt_tm)
  FROM (dummyt d  WITH seq = value(sz)),
   person_patient pp,
   person_prsnl_activity ppa
  PLAN (d)
   JOIN (pp
   WHERE (pp.person_id=request->prsnl_list[1].person_list[d.seq].person_id))
   JOIN (ppa
   WHERE ppa.person_id=outerjoin(pp.person_id)
    AND ppa.prsnl_id=outerjoin(reqinfo->updt_id)
    AND ppa.ppa_type_cd=outerjoin(results_review_cd)
    AND ppa.active_ind=outerjoin(1))
  ORDER BY pp.person_id
  DETAIL
   stat = alterlist(reply->prsnl_list,1), x = (x+ 1), stat = alterlist(reply->prsnl_list[1].
    person_list,x),
   reply->prsnl_list[1].person_list[x].person_id = pp.person_id, reply->prsnl_list[1].person_list[x].
   ppa_last_dt_tm = ppa.ppa_last_dt_tm
   IF (event_ind=0)
    IF (ppa.ppa_id > 0)
     IF (ppa.ppa_last_dt_tm < pp.last_event_updt_dt_tm)
      reply->prsnl_list[1].person_list[x].results_avail_ind = 1
     ELSE
      reply->prsnl_list[1].person_list[x].results_avail_ind = 0
     ENDIF
    ELSE
     reply->prsnl_list[1].person_list[x].results_avail_ind = 1
    ENDIF
   ELSE
    reply->prsnl_list[1].person_list[x].results_avail_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (failed != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
 ELSEIF (curqual)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
