CREATE PROGRAM bbt_add_product_event:dba
 RECORD reply(
   1 qual[1]
     2 product_id = f8
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE bb_result_seq = f8
 DECLARE event_type_cd = f8
 DECLARE event_prsnl_id = f8
 SET reply->status_data.status = "F"
 SET number_of_process = cnvtint(size(request->qual,5))
 SET failed = "F"
 SET status_count = 0
 SET partial_update = "F"
 SET stat = alter(reply->qual,number_of_process)
 SET product_event_id = 0.0
 SET gsub_product_event_status = "  "
 SET event_type_mean = "               "
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SUBROUTINE add_product_event_with_inventory_area_cd(sub_product_id,sub_person_id,sub_encntr_id,
  sub_order_id,sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,
  sub_event_status_flag,sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,
  sub_active_ind,sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id,sub_locn_cd)
   CALL echo(build(" PRODUCT_ID - ",sub_product_id," PERSON_ID - ",sub_person_id," ENCNTR_ID - ",
     sub_encntr_id," SUB_RODER_ID - ",sub_order_id," BB_RESULT_ID - ",sub_bb_result_id,
     " EVENT_TYPE_ID - ",sub_event_type_cd," EVENT_DT_TM_ID - ",sub_event_dt_tm," PRSNL_ID - ",
     sub_event_prsnl_id," EVENT_STATUS_FLAG - ",sub_event_status_flag," override_ind - ",
     sub_override_ind,
     " override_reason_cd - ",sub_override_reason_cd," related_pe_id - ",sub_related_product_event_id,
     " active_ind - ",
     sub_active_ind," active_status_cd - ",sub_active_status_cd," active_status_dt_tm - ",
     sub_active_status_dt_tm,
     " status_prsnl_id - ",sub_active_status_prsnl_id," inventoy_area_cd - ",sub_locn_cd))
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
      , pe.inventory_area_cd = sub_locn_cd
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
 FOR (x = 1 TO number_of_process)
   SET event_type_cd = 0.0
   SET bb_result_seq = 0.0
   SET event_type_mean = request->qual[x].event_type_meaning
   SET event_type_cd = get_code_value(1610,event_type_mean)
   IF (event_type_cd=0.0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "GET"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Code Value"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to retrieve code value"
   ELSE
    IF ((request->qual[x].bb_result_id > 0))
     SET bb_result_seq = request->qual[x].bb_result_id
    ENDIF
    IF ((request->qual[x].event_dt_tm > 0))
     SET event_dt_tm = cnvtdatetime(request->qual[x].event_dt_tm)
    ELSE
     SET event_dt_tm = cnvtdatetime(curdate,curtime3)
    ENDIF
    IF ((request->qual[x].event_prsnl_id > 0))
     SET event_prsnl_id = request->qual[x].event_prsnl_id
    ELSE
     SET event_prsnl_id = reqinfo->updt_id
    ENDIF
    CALL add_product_event(request->qual[x].product_id,request->qual[x].person_id,request->qual[x].
     encntr_id,request->qual[x].order_id,bb_result_seq,
     event_type_cd,event_dt_tm,event_prsnl_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id)
    IF (gsub_product_event_status="FS")
     SET failed = "T"
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert product event due to product event id"
    ELSEIF (gsub_product_event_status="FA")
     SET failed = "T"
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to insert product event"
    ELSE
     SET partial_update = "T"
    ENDIF
    SET reply->qual[x].product_id = request->qual[x].product_id
    SET reply->qual[x].event_id = product_event_id
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T"
  AND partial_update="F")
  SET reqinfo->commit_ind = 0
 ELSEIF (failed="T"
  AND partial_update="T")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "P"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
