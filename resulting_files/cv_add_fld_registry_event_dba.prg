CREATE PROGRAM cv_add_fld_registry_event:dba
 RECORD internal(
   1 event_id = f8
   1 parent_event_id = f8
   1 encntr_id = f8
   1 person_id = f8
   1 clinical_event_id = f8
   1 event_cd = f8
 )
 SET reply->status_data.status = "F"
 SET success = "T"
 SET index = 0
 SET cntx = 0
 SET parent_event_id = 0
 SET called = "F"
 SET cntx = value(size(register->rec,5))
 DECLARE recursive_sub(parent_event_id) = f8
 FOR (index = 1 TO cntx)
  SET parent_event_id = register->rec[index].parent_event_id
  CALL recursive_sub(parent_event_id)
 ENDFOR
 SUBROUTINE recursive_sub(cur_parent_event_id)
   SET passed_in_value = cur_parent_event_id
   FREE SET cur_parent_event_id
   DECLARE new_parent_event_id = f8
   SELECT INTO "nl:"
    cr.event_id
    FROM cv_registry_event cr
    WHERE cr.event_id=passed_in_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     ce.event_id, ce.parent_event_id
     FROM clinical_event ce
     WHERE ce.event_id=passed_in_value
     DETAIL
      internal->event_id = ce.event_id, internal->encntr_id = ce.encntr_id, internal->person_id = ce
      .person_id,
      internal->clinical_event_id = ce.clinical_event_id, internal->parent_event_id = ce
      .parent_event_id, internal->event_cd = ce.event_cd,
      new_parent_event_id = ce.parent_event_id
     WITH nocounter
    ;end select
    INSERT  FROM cv_registry_event cr
     SET cr.registry_event_id = seq(card_vas_seq,nextval), cr.event_id = internal->event_id, cr
      .encntr_id = internal->encntr_id,
      cr.person_id = internal->person_id, cr.clinical_event_id = internal->clinical_event_id, cr
      .parent_event_id = internal->parent_event_id,
      cr.event_cd = internal->event_cd, cr.harvested = 0, cr.provider_id = 0,
      cr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cr.end_effective_dt_tm = cnvtdatetime(
       "31-Dec-2100 00:00:00.00"), cr.updt_cnt = 0,
      cr.active_ind = 1, cr.active_status_cd = reqdata->active_status_cd, cr.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cr.active_status_prsnl_id = reqinfo->updt_id, cr.data_status_cd = reqdata->data_status_cd, cr
      .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
      cr.data_status_prsnl_id = reqinfo->updt_id, cr.updt_id = reqinfo->updt_id, cr.updt_task =
      reqinfo->updt_task,
      cr.updt_req = reqinfo->updt_req, cr.updt_applctx = reqinfo->updt_applctx, cr.updt_app = reqinfo
      ->updt_app,
      cr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (internal->event_id > 0)
      AND (internal->parent_event_id > 0)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET success = "F"
     GO TO error_check
    ENDIF
    IF ((internal->event_id=internal->parent_event_id)
     AND called="F")
     SET top_parent_event_id = internal->parent_event_id
     SET called = "T"
     CALL echo(" ")
    ELSE
     CALL recursive_sub(new_parent_event_id)
    ENDIF
   ELSE
    IF (called="F")
     SET top_parent_event_id = passed_in_value
     SET called = "T"
    ENDIF
   ENDIF
   RETURN(100)
 END ;Subroutine
#error_check
 IF (success="T")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_add_fld_registry_event"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_add_fld_registry_event"
  GO TO end_program
 ENDIF
#end_program
END GO
