CREATE PROGRAM cv_ins_updt_reg_from_clin:dba
 FREE SET register
 RECORD register(
   1 rec[*]
     2 xref_id = f8
     2 event_id = f8
     2 parent_event_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 clinical_event_id = f8
     2 insert_ind = i2
     2 dub_ind = i2
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET register_size = 0
 SET failed = "F"
 SET event_cnt = 0
 SELECT DISTINCT INTO "NL:"
  ce.event_id
  FROM cv_xref ref,
   clinical_event ce,
   dummyt u
  PLAN (u)
   JOIN (ref)
   JOIN (ce
   WHERE ref.event_cd=ce.event_cd)
  ORDER BY ce.event_id
  DETAIL
   event_cnt = (event_cnt+ 1), event_size = alterlist(register->rec,event_cnt), register->rec[
   event_cnt].encntr_id = ce.encntr_id,
   register->rec[event_cnt].person_id = ce.person_id, register->rec[event_cnt].parent_event_id = ce
   .parent_event_id, register->rec[event_cnt].event_id = ce.event_id,
   register->rec[event_cnt].event_cd = ce.event_cd, register->rec[event_cnt].xref_id = ref.xref_id,
   register->rec[event_cnt].clinical_event_id = ce.clinical_event_id,
   register->rec[event_cnt].insert_ind = 1
  WITH nocounter
 ;end select
 IF (event_cnt=0)
  GO TO clin_select_failure
 ENDIF
 SET nomatch_size = 0
 SET initial_cnt = 0
 SET clin_rec_cnt = 0
 SET rec_cnt = 0
 SELECT INTO "NL:"
  reg.event_id
  FROM cv_registry_event reg,
   (dummyt f  WITH seq = value(size(register->rec,5)))
  PLAN (f)
   JOIN (reg
   WHERE (reg.event_id=register->rec[f.seq].event_id)
    AND reg.active_ind=1)
  DETAIL
   rec_cnt = (rec_cnt+ 1), register->rec[f.seq].dub_ind = 1
  WITH nocounter
 ;end select
 SET insert_rec = size(register->rec,5)
 IF (curqual > 0)
  INSERT  FROM cv_registry_event reg,
    (dummyt q  WITH seq = value(size(register->rec,5)))
   SET reg.registry_event_id = seq(card_vas_seq,nextval), reg.encntr_id = register->rec[q.seq].
    encntr_id, reg.person_id = register->rec[q.seq].person_id,
    reg.parent_event_id = register->rec[q.seq].parent_event_id, reg.xref_id = register->rec[q.seq].
    xref_id, reg.event_id = register->rec[q.seq].event_id,
    reg.event_cd = register->rec[q.seq].event_cd, reg.clinical_event_id = register->rec[q.seq].
    clinical_event_id, reg.harvested = 0,
    reg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), reg.end_effective_dt_tm = cnvtdatetime(
     "31-Dec-2100 00:00:00.00"), reg.active_ind = 1,
    reg.active_status_cd = reqdata->active_status_cd, reg.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), reg.active_status_prsnl_id = reqinfo->updt_id,
    reg.data_status_cd = reqdata->data_status_cd, reg.data_status_prsnl_id = reqinfo->updt_id, reg
    .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
    reg.updt_cnt = 0, reg.updt_id = reqinfo->updt_id, reg.updt_task = reqinfo->updt_task,
    reg.updt_applctx = reqinfo->updt_applctx, reg.updt_app = reqinfo->updt_app, reg.updt_req = 410043,
    reg.updt_id = reqinfo->updt_id, reg.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (q
    WHERE (register->rec[q.seq].dub_ind != 1))
    JOIN (reg)
   WITH nocounter
  ;end insert
 ELSE
  SET event_size = alterlist(register->rec,event_cnt)
  INSERT  FROM cv_registry_event reg,
    (dummyt q  WITH seq = value(insert_rec))
   SET reg.registry_event_id = seq(card_vas_seq,nextval), reg.encntr_id = register->rec[q.seq].
    encntr_id, reg.person_id = register->rec[q.seq].person_id,
    reg.parent_event_id = register->rec[q.seq].parent_event_id, reg.xref_id = register->rec[q.seq].
    xref_id, reg.event_cd = register->rec[q.seq].event_cd,
    reg.event_id = register->rec[q.seq].event_id, reg.clinical_event_id = register->rec[q.seq].
    clinical_event_id, reg.harvested = 0,
    reg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), reg.end_effective_dt_tm = cnvtdatetime(
     "31-Dec-2100 00:00:00.00"), reg.active_ind = 1,
    reg.active_status_cd = reqdata->active_status_cd, reg.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), reg.active_status_prsnl_id = reqinfo->updt_id,
    reg.data_status_cd = reqdata->data_status_cd, reg.data_status_prsnl_id = reqinfo->updt_id, reg
    .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
    reg.updt_cnt = 0, reg.updt_id = reqinfo->updt_id, reg.updt_task = 410043,
    reg.updt_applctx = reqinfo->updt_applctx, reg.updt_app = reqinfo->updt_app, reg.updt_req = 410043,
    reg.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (q
    WHERE (register->rec[q.seq].insert_ind=1))
    JOIN (reg)
   WITH nocounter
  ;end insert
 ENDIF
 EXECUTE cv_add_fld_registry_event
#clin_select_failure
 IF (event_cnt=0)
  CALL echo("selection from clinical event table error")
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "clinical_event_table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "clinical_event_table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "Z"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
#end_program
 FREE SET reply
 FREE SET register
END GO
