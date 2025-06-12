CREATE PROGRAM bbt_get_trans_require:dba
 RECORD reply(
   1 qual[*]
     2 requirement_cd = f8
     2 requirement_disp = c40
     2 updt_cnt = i4
     2 person_trans_req_id = f8
     2 added_user_name = c20
     2 added_dt_tm = dq8
     2 removed_user_name = c20
     2 removed_dt_tm = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET require_cnt = 0
 SET reply->status_data.status = "F"
 DECLARE active_status_codeset = i4 WITH public, constant(48)
 DECLARE combined_meaning = vc WITH public, constant("COMBINED")
 DECLARE inactive_meaning = vc WITH public, constant("INACTIVE")
 DECLARE combined_cd = f8 WITH protected, noconstant(0.0)
 DECLARE inactive_cd = f8 WITH protected, noconstant(0.0)
 SET combined_cd = uar_get_code_by("MEANING",active_status_codeset,nullterm(combined_meaning))
 SET inactive_cd = uar_get_code_by("MEANING",active_status_codeset,nullterm(inactive_meaning))
 IF (combined_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "COMBINED"
  GO TO exit_program
 ENDIF
 IF (inactive_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "INACTIVE"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  p.requirement_cd, p.person_id, p.updt_cnt,
  pr.username
  FROM person_trans_req p,
   prsnl pr,
   (dummyt d1  WITH seq = 1)
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND  NOT (p.active_status_cd IN (combined_cd, inactive_cd)))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pr
   WHERE pr.person_id IN (p.updt_id, p.removed_prsnl_id, p.added_prsnl_id)
    AND pr.person_id > 0)
  ORDER BY p.person_trans_req_id
  HEAD REPORT
   require_cnt = 0, err_cnt = 0
  HEAD p.person_trans_req_id
   require_cnt += 1, stat = alterlist(reply->qual,require_cnt), reply->qual[require_cnt].
   requirement_cd = p.requirement_cd,
   reply->qual[require_cnt].updt_cnt = p.updt_cnt, reply->qual[require_cnt].person_trans_req_id = p
   .person_trans_req_id, reply->qual[require_cnt].active_ind = p.active_ind
  DETAIL
   IF (pr.person_id=p.removed_prsnl_id)
    IF (p.active_ind=0)
     reply->qual[require_cnt].removed_user_name = pr.username, reply->qual[require_cnt].removed_dt_tm
      = cnvtdatetime(p.removed_dt_tm)
    ELSE
     IF (p.added_prsnl_id=0)
      reply->qual[require_cnt].added_user_name = pr.username, reply->qual[require_cnt].added_dt_tm =
      cnvtdatetime(p.updt_dt_tm)
     ENDIF
    ENDIF
   ENDIF
   IF (pr.person_id=p.added_prsnl_id
    AND p.added_prsnl_id > 0)
    reply->qual[require_cnt].added_user_name = pr.username, reply->qual[require_cnt].added_dt_tm =
    cnvtdatetime(p.added_dt_tm)
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET err_cnt += 1
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "PERSON_TRANS_REQ"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return requirements specified"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
