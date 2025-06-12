CREATE PROGRAM bb_upd_qc_inquiry_results:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET modify = predeclare
 DECLARE serror = c132 WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  *
  FROM bb_qc_result r,
   (dummyt d1  WITH seq = value(size(request->review_qual,5)))
  PLAN (d1)
   JOIN (r
   WHERE (r.qc_result_id=request->review_qual[d1.seq].qc_result_id))
  WITH nocounter, forupdate(r)
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("SELECT","F","bb_qc_result","Error locking rows for update.")
  GO TO exit_script
 ELSE
  UPDATE  FROM bb_qc_result r,
    (dummyt d1  WITH seq = value(size(request->review_qual,5)))
   SET r.primary_review_dt_tm =
    IF ((request->review_qual[d1.seq].primary_review_prsnl_id > 0)) cnvtdatetime(request->
      review_qual[d1.seq].primary_review_dt_tm)
    ELSE r.primary_review_dt_tm
    ENDIF
    , r.primary_review_prsnl_id =
    IF ((request->review_qual[d1.seq].primary_review_prsnl_id > 0)) request->review_qual[d1.seq].
     primary_review_prsnl_id
    ELSE r.primary_review_prsnl_id
    ENDIF
    , r.secondary_review_dt_tm =
    IF ((request->review_qual[d1.seq].secondary_review_prsnl_id > 0)) cnvtdatetime(request->
      review_qual[d1.seq].secondary_review_dt_tm)
    ELSE r.secondary_review_dt_tm
    ENDIF
    ,
    r.secondary_review_prsnl_id =
    IF ((request->review_qual[d1.seq].secondary_review_prsnl_id > 0)) request->review_qual[d1.seq].
     secondary_review_prsnl_id
    ELSE r.secondary_review_prsnl_id
    ENDIF
    , r.updt_applctx =
    IF ((((request->review_qual[d1.seq].primary_review_prsnl_id > 0)) OR ((request->review_qual[d1
    .seq].secondary_review_prsnl_id > 0))) ) reqinfo->updt_applctx
    ELSE r.updt_applctx
    ENDIF
    , r.updt_cnt =
    IF ((((request->review_qual[d1.seq].primary_review_prsnl_id > 0)) OR ((request->review_qual[d1
    .seq].secondary_review_prsnl_id > 0))) ) (r.updt_cnt+ 1)
    ELSE r.updt_cnt
    ENDIF
    ,
    r.updt_dt_tm =
    IF ((((request->review_qual[d1.seq].primary_review_prsnl_id > 0)) OR ((request->review_qual[d1
    .seq].secondary_review_prsnl_id > 0))) ) cnvtdatetime(curdate,curtime3)
    ELSE r.updt_dt_tm
    ENDIF
    , r.updt_id =
    IF ((((request->review_qual[d1.seq].primary_review_prsnl_id > 0)) OR ((request->review_qual[d1
    .seq].secondary_review_prsnl_id > 0))) ) reqinfo->updt_id
    ELSE r.updt_id
    ENDIF
    , r.updt_task =
    IF ((((request->review_qual[d1.seq].primary_review_prsnl_id > 0)) OR ((request->review_qual[d1
    .seq].secondary_review_prsnl_id > 0))) ) reqinfo->updt_task
    ELSE r.updt_task
    ENDIF
   PLAN (d1)
    JOIN (r
    WHERE (r.qc_result_id=request->review_qual[d1.seq].qc_result_id))
   WITH nocounter
  ;end update
  IF (error(serror,0) > 0)
   CALL subevent_add("UPDATE","F","bb_upd_qc_inquiry_results",serror)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_upd_qc_inquiry_results",serror)
  GO TO exit_script
 ENDIF
 IF (value(size(request->review_qual,5))=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("UPDATE","Z","bb_upd_qc_inquiry_results","No results were passed in to update.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
