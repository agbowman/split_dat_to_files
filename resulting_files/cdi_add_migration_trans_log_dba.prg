CREATE PROGRAM cdi_add_migration_trans_log:dba
 FREE SET reply
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 tran_id = f8
     2 blob_handle = vc
     2 valid = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD documents(
   1 qual_cnt = i4
   1 qual[*]
     2 cdi_trans_log_id = f8
     2 patient_name = vc
     2 mrn = c200
     2 action = i2
     2 financial_nbr = c200
     2 blob_handle = vc
     2 encntr_id = f8
     2 person_id = f8
     2 create_dttm = dq8
     2 event_cd = f8
     2 batch_name = vc
     2 action_type_flag = i2
     2 page_deleted_cnt = i4
     2 page_cnt = i4
     2 event_id = f8
     2 blob_ref_id = f8
     2 blob_type_flag = i2
     2 ax_docid = i4
     2 ax_appid = i2
     2 queue = f8
     2 cdi_queue = vc
     2 old_queue = vc
     2 reason = vc
     2 doc_type = vc
     2 subject = vc
     2 create_date = vc
     2 create_time = vc
     2 external_batch_ident = i4
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 parent_entity_alias = vc
     2 batch_name_key = vc
     2 cdi_pending_document_id = f8
     2 doc_type_alias = vc
     2 patient_name = vc
 )
 DECLARE action = i2 WITH public
 DECLARE queue = f8 WITH public
 DECLARE new_queue = f8 WITH public
 DECLARE blob_handle = vc WITH public
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE ncnt = i4 WITH public, noconstant(0)
 DECLARE ncnt2 = i4 WITH public, noconstant(0)
 DECLARE entitysize = i2 WITH public, noconstant(0)
 SET entitysize = size(request->entity_list,5)
 IF (entitysize=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_migration_trans_log"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "List is empty."
  GO TO exit_script
 ENDIF
 SET reason_var = uar_get_code_by("MEANING",257572,"CPDIMIGRATE")
 SET reply->qual_cnt = 1
 SELECT
  *
  FROM cdi_trans_log c
  WHERE expand(num,1,entitysize,c.blob_handle,request->entity_list[num].blob_handle)
   AND c.active_ind=1
  HEAD REPORT
   documents->qual_cnt = 0, stat = alterlist(documents->qual,10)
  DETAIL
   ncnt = 0, ncnt2 = 0, documents->qual_cnt = (documents->qual_cnt+ 1)
   IF (mod(documents->qual_cnt,10)=1)
    stat = alterlist(documents->qual,(documents->qual_cnt+ 9))
   ENDIF
   documents->qual[documents->qual_cnt].patient_name = c.patient_name, action = c.action_type_flag,
   documents->qual[documents->qual_cnt].cdi_trans_log_id = c.cdi_trans_log_id,
   documents->qual[documents->qual_cnt].batch_name = c.batch_name, documents->qual[documents->
   qual_cnt].batch_name_key = c.batch_name_key, documents->qual[documents->qual_cnt].blob_handle = c
   .blob_handle,
   documents->qual[documents->qual_cnt].blob_ref_id = c.blob_ref_id, documents->qual[documents->
   qual_cnt].blob_type_flag = c.blob_type_flag, queue = c.cdi_queue_cd,
   documents->qual[documents->qual_cnt].cdi_pending_document_id = c.cdi_pending_document_id,
   documents->qual[documents->qual_cnt].create_dttm = c.create_dt_tm, documents->qual[documents->
   qual_cnt].doc_type_alias = c.document_type_alias,
   documents->qual[documents->qual_cnt].doc_type = c.doc_type, documents->qual[documents->qual_cnt].
   encntr_id = c.encntr_id, documents->qual[documents->qual_cnt].event_cd = c.event_cd,
   documents->qual[documents->qual_cnt].event_id = c.event_id, documents->qual[documents->qual_cnt].
   external_batch_ident = c.external_batch_ident, documents->qual[documents->qual_cnt].financial_nbr
    = c.financial_nbr,
   documents->qual[documents->qual_cnt].mrn = c.mrn, documents->qual[documents->qual_cnt].page_cnt =
   c.page_cnt, documents->qual[documents->qual_cnt].page_deleted_cnt = c.page_deleted_cnt,
   documents->qual[documents->qual_cnt].parent_entity_alias = c.parent_entity_alias, documents->qual[
   documents->qual_cnt].parent_entity_id = c.parent_entity_id, documents->qual[documents->qual_cnt].
   parent_entity_name = c.parent_entity_name,
   documents->qual[documents->qual_cnt].patient_name = c.patient_name, documents->qual[documents->
   qual_cnt].person_id = c.person_id, documents->qual[documents->qual_cnt].subject = c.subject,
   r = locateval(ncnt2,1,size(request->entity_list,5),blob_handle,request->entity_list[ncnt2].
    blob_handle), documents->qual[documents->qual_cnt].ax_docid = request->entity_list[r].ax_docid,
   documents->qual[documents->qual_cnt].ax_appid = request->entity_list[r].ax_appid
   IF (action=0)
    IF (queue=uar_get_code_by("MEANING",257571,"AUTO_INDEX"))
     new_queue = uar_get_code_by("MEANING",257571,"HNAM")
    ELSEIF (queue=uar_get_code_by("MEANING",257571,"MAN_INDEX"))
     new_queue = uar_get_code_by("MEANING",257571,"HNAM")
    ELSEIF (queue=uar_get_code_by("MEANING",257571,"BATCH_PREP"))
     new_queue = uar_get_code_by("MEANING",257571,"MAN_INDEX")
    ELSEIF (queue=uar_get_code_by("MEANING",257571,"PHARMACY"))
     new_queue = uar_get_code_by("MEANING",257571,"AUTO_INDEX")
    ENDIF
   ELSEIF (action=1)
    IF (uar_get_code_by("MEANING",257571,"AUTO_INDEX"))
     new_queue = uar_get_code_by("MEANING",257571,"MAN_INDEX")
    ENDIF
   ELSEIF (action=2)
    new_queue = uar_get_code_by("MEANING",257571,"AUTO_INDEX")
   ELSEIF (action=3)
    new_queue = uar_get_code_by("MEANING",257571,"DELETE")
   ELSEIF (action=4)
    new_queue = queue
   ELSEIF (action=5)
    new_queue = uar_get_code_by("MEANING",257571,"HNAM")
   ELSEIF (action=6)
    new_queue = queue
   ELSEIF (action=7)
    new_queue = uar_get_code_by("MEANING",257571,"AC_VALIDATE")
   ELSEIF (action=8)
    new_queue = queue
   ENDIF
   documents->qual[documents->qual_cnt].queue = new_queue
  FOOT REPORT
   stat = alterlist(documents->qual,documents->qual_cnt)
  WITH nocounter
 ;end select
 UPDATE  FROM cdi_trans_log e
  SET e.active_ind = 0
  WHERE expand(num,1,size(documents->qual,5),e.cdi_trans_log_id,documents->qual[num].cdi_trans_log_id
   )
 ;end update
 INSERT  FROM (dummyt dt  WITH seq = documents->qual_cnt),
   cdi_trans_log d
  SET d.patient_name = documents->qual[dt.seq].patient_name, d.action_type_flag = 8, d
   .cdi_trans_log_id = seq(cdi_seq,nextval),
   d.active_ind = 1, d.batch_name = documents->qual[dt.seq].batch_name, d.batch_name_key = documents
   ->qual[dt.seq].batch_name_key,
   d.blob_handle = documents->qual[dt.seq].blob_handle, d.blob_ref_id = documents->qual[dt.seq].
   blob_ref_id, d.blob_type_flag = documents->qual[dt.seq].blob_type_flag,
   d.cdi_queue_cd = documents->qual[dt.seq].queue, d.cdi_pending_document_id = documents->qual[dt.seq
   ].cdi_pending_document_id, d.create_dt_tm = cnvtdatetime(documents->qual[dt.seq].create_dttm),
   d.document_type_alias = documents->qual[dt.seq].doc_type_alias, d.doc_type = documents->qual[dt
   .seq].doc_type, d.encntr_id = documents->qual[dt.seq].encntr_id,
   d.event_cd = documents->qual[dt.seq].event_cd, d.event_id = documents->qual[dt.seq].event_id, d
   .external_batch_ident = documents->qual[dt.seq].external_batch_ident,
   d.financial_nbr = documents->qual[dt.seq].financial_nbr, d.mrn = documents->qual[dt.seq].mrn, d
   .page_cnt = documents->qual[dt.seq].page_cnt,
   d.page_deleted_cnt = documents->qual[dt.seq].page_deleted_cnt, d.parent_entity_alias = documents->
   qual[dt.seq].parent_entity_alias, d.parent_entity_id = documents->qual[dt.seq].parent_entity_id,
   d.parent_entity_name = documents->qual[dt.seq].parent_entity_name, d.patient_name = documents->
   qual[dt.seq].patient_name, d.person_id = documents->qual[dt.seq].person_id,
   d.subject = documents->qual[dt.seq].subject, d.reason_cd = reason_var, d.action_type_flag = 8,
   d.perf_prsnl_id = reqinfo->updt_id, d.updt_cnt = 0, d.updt_applctx = reqinfo->updt_applctx,
   d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.ax_docid = documents->qual[dt
   .seq].ax_docid,
   d.ax_docid = documents->qual[dt.seq].ax_appid
  PLAN (dt)
   JOIN (d)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_migration_trans_log"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert trans_log row."
  GO TO exit_script
 ENDIF
 SET reqinfo->commit_ind = 1
#exit_script
END GO
