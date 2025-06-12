CREATE PROGRAM bed_get_funct_measures_by_ent:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 svc_entities[*]
      2 svc_entity_id = f8
      2 stage_one_defined = i2
      2 stage_two_defined = i2
      2 measures[*]
        3 measure_id = f8
        3 measure_name = vc
        3 stage_type = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE req_cnt = i4 WITH noconstant(0), protect
 DECLARE meas_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE move_req_into_rep(request_cnt=i2) = null
 DECLARE populate_defined_ind(reply_cnt=i2) = null
 DECLARE get_meas_for_entities(reply_cnt=i2) = null
 SUBROUTINE move_req_into_rep(request_cnt)
  SET stat = alterlist(reply->svc_entities,request_cnt)
  FOR (x = 1 TO request_cnt)
    SET reply->svc_entities[x].svc_entity_id = request->svc_entities[x].svc_entity_id
  ENDFOR
 END ;Subroutine
 SUBROUTINE populate_defined_ind(reply_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = reply_cnt),
    br_svc_entity_report_reltn svc,
    br_datamart_report rep,
    br_datamart_category cat
   PLAN (d)
    JOIN (svc
    WHERE (svc.parent_entity_id=reply->svc_entities[d.seq].svc_entity_id)
     AND svc.active_ind=1
     AND svc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (rep
    WHERE rep.br_datamart_report_id=svc.br_datamart_report_id)
    JOIN (cat
    WHERE cat.br_datamart_category_id=rep.br_datamart_category_id)
   ORDER BY d.seq, cat.category_mean
   HEAD d.seq
    stat = 1
   HEAD cat.category_mean
    IF (cat.category_mean="MUSE_FUNCTIONAL")
     reply->svc_entities[d.seq].stage_one_defined = 1
    ENDIF
    IF (cat.category_mean="MUSE_FUNCTIONAL_2")
     reply->svc_entities[d.seq].stage_two_defined = 1
    ENDIF
   FOOT  d.seq
    stat = 1
   WITH nocounter
  ;end select
  CALL bederrorcheck("GETDEFINEDINDERROR")
 END ;Subroutine
 SUBROUTINE get_meas_for_entities(reply_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = reply_cnt),
    br_svc_entity_report_reltn svc,
    br_datamart_report rep,
    br_datamart_category cat
   PLAN (d)
    JOIN (svc
    WHERE (svc.parent_entity_id=reply->svc_entities[d.seq].svc_entity_id)
     AND svc.active_ind=1
     AND svc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (rep
    WHERE rep.br_datamart_report_id=svc.br_datamart_report_id)
    JOIN (cat
    WHERE cat.br_datamart_category_id=rep.br_datamart_category_id)
   ORDER BY d.seq, rep.br_datamart_report_id
   HEAD d.seq
    cnt = 0, meas_cnt = 0, stat = alterlist(reply->svc_entities[d.seq].measures,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(reply->svc_entities[d.seq].measures,(meas_cnt+ 10))
    ENDIF
    meas_cnt = (meas_cnt+ 1), reply->svc_entities[d.seq].measures[meas_cnt].measure_id = rep
    .br_datamart_report_id, reply->svc_entities[d.seq].measures[meas_cnt].measure_name = rep
    .report_name
    IF (cat.category_mean="MUSE_FUNCTIONAL")
     reply->svc_entities[d.seq].measures[meas_cnt].stage_type = 1
    ELSEIF (cat.category_mean="MUSE_FUNCTIONAL_2")
     reply->svc_entities[d.seq].measures[meas_cnt].stage_type = 2
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->svc_entities[d.seq].measures,meas_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("GETMEASURESERROR")
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET req_cnt = size(request->svc_entities,5)
 IF (req_cnt=0)
  CALL bederror("Request size is 0")
 ENDIF
 CALL move_req_into_rep(req_cnt)
 CALL populate_defined_ind(req_cnt)
 IF ((request->return_meas_ind=1))
  CALL get_meas_for_entities(req_cnt)
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
