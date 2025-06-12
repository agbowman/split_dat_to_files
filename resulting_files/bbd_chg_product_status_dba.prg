CREATE PROGRAM bbd_chg_product_status:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET struct_counter = 0
 DECLARE tested_cd = f8
 DECLARE drawn_cd = f8
 DECLARE available_cd = f8
 DECLARE verified_cd = f8
 SET counter = 0
 SET tested_ind = 0
 SET drawn_ind = 0
 SET tested_cd = 0.0
 SET drawn_cd = 0.0
 SET available_cd = 0.0
 SET verified_cd = 0.0
 SET code_cnt = 1
 SET code_set = 1610
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "12"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,available_cd)
 SET code_cnt = 1
 SET code_set = 1610
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "23"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,verified_cd)
 SET code_cnt = 1
 SET code_set = 1610
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "21"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,tested_cd)
 IF (((available_cd=0.0) OR (((verified_cd=0.0) OR (tested_cd=0.0)) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_product_status.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Retrieve"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (available_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the AVAILABLE code value."
  ELSEIF (verified_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the VERIFIED result status code value."
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the TESTED result status code value."
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pe.event_type_cd
  FROM product_event pe
  WHERE (pe.product_id=request->product_id)
   AND pe.event_type_cd > 0
   AND pe.active_ind=1
  DETAIL
   cdf_meaning = fillstring(12," "), cdf_meaning = uar_get_code_meaning(pe.event_type_cd)
   CASE (cdf_meaning)
    OF "21":
     tested_ind = 1
    OF "20":
     drawn_ind = 1
   ENDCASE
  WITH nocounter
 ;end select
 SET gsub_product_event_status = "  "
 SET product_event_id = 0.0
 CALL add_product_event(request->product_id,0.0,0.0,0.0,0.0,
  verified_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
  0,0,
  IF (drawn_ind=1) 1
  ELSE 0
  ENDIF
  ,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id)
 IF (gsub_product_event_status != "OK")
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_product_status.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error on inserting new a verified product event."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
  GO TO exit_script
 ENDIF
 IF (tested_ind=1)
  SELECT INTO "nl:"
   pe.product_event_id
   FROM product_event pe
   WHERE pe.product_id=product_id
    AND pe.event_type_cd=tested_cd
   WITH counter, forupdate(pe)
  ;end select
  UPDATE  FROM product_event pe
   SET pe.active_ind = 0
   WHERE (pe.product_id=request->product_id)
    AND pe.event_type_cd=tested_cd
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "BBD_CHG_PRODUCT_STATUS"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT EVENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error inactivating the Tested product event."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
   GO TO exit_script
  ENDIF
  SET gsub_product_event_status = "  "
  SET product_event_id = 0.0
  CALL add_product_event(request->product_id,0.0,0.0,0.0,0.0,
   available_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
   0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id)
  IF (gsub_product_event_status != "OK")
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_product_status.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRODUCT_EVENT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error on inserting new an available product event."
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 4
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE add_product_event(sub_product_id,sub_person_id,sub_encntr_id,sub_order_id,
  sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,sub_event_status_flag,
  sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
END GO
