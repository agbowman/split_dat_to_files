CREATE PROGRAM aps_add_case_query:dba
 RECORD reply(
   1 case_query_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 query_detail_id = f8
     2 freetext_long_text_id = f8
     2 synoptic_ccl_long_text_id = f8
     2 synoptic_xml_long_text_id = f8
 )
#script
 SET failed = "F"
 DECLARE query_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET nbr_to_insert = cnvtint(value(size(request->qual,5)))
 SET stat = alterlist(temp->qual,nbr_to_insert)
 DECLARE ap_activity_type_cd = f8 WITH public, noconstant(0.0)
 SET ap_activity_type_cd = uar_get_code_by("MEANING",106,"AP")
 IF (ap_activity_type_cd <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "uar_get_code_by"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "activity_type_cd"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   query_id = seq_nbr, reply->case_query_id = query_id
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 INSERT  FROM ap_case_query acq
  SET acq.case_query_id = query_id, acq.output_dest_id = request->output_dest_id, acq.nbr_copies =
   request->nbr_copies,
   acq.result_name = request->result_name, acq.result_name_key = cnvtupper(request->result_name), acq
   .report_type_flag = request->report_type_flag,
   acq.search_type_flag = request->search_type_flag, acq.started_prsnl_id =
   IF ((request->started_prsnl_id=0)) reqinfo->updt_id
   ELSE request->started_prsnl_id
   ENDIF
   , acq.report_history_cd = request->report_history_grping,
   acq.status_flag = 1, acq.activity_type_cd = ap_activity_type_cd, acq.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   acq.updt_id = reqinfo->updt_id, acq.updt_task = reqinfo->updt_task, acq.updt_applctx = reqinfo->
   updt_applctx,
   acq.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  GO TO acq_failed
 ENDIF
 IF (nbr_to_insert > 0)
  FOR (index = 1 TO nbr_to_insert)
    SELECT INTO "nl:"
     seq_nbr = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      temp->qual[index].query_detail_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO seq_failed
    ENDIF
    IF ((request->qual[index].param_name="CRITERIA_FREETEXT"))
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       temp->qual[index].freetext_long_text_id = seq_nbr
      WITH format, counter
     ;end select
     IF (curqual=0)
      GO TO ltseq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = temp->qual[index].freetext_long_text_id, lt.long_text = request->qual[
       index].freetext_query, lt.parent_entity_name = "AP_CASE_QUERY_DETAILS",
       lt.parent_entity_id = temp->qual[index].query_detail_id, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual != 1)
      GO TO lt_failed
     ENDIF
    ENDIF
    IF ((request->qual[index].param_name="CRITERIA_SYNOPTIC"))
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       temp->qual[index].synoptic_xml_long_text_id = seq_nbr
      WITH format, counter
     ;end select
     IF (curqual=0)
      GO TO ltseq_failed
     ENDIF
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       temp->qual[index].synoptic_ccl_long_text_id = seq_nbr
      WITH format, counter
     ;end select
     IF (curqual=0)
      GO TO ltseq_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = temp->qual[index].synoptic_xml_long_text_id, lt.long_text = request->
       qual[index].synoptic_xml_query, lt.parent_entity_name = "AP_CASE_QUERY_DETAILS",
       lt.parent_entity_id = temp->qual[index].query_detail_id, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual != 1)
      GO TO lt_failed
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = temp->qual[index].synoptic_ccl_long_text_id, lt.long_text = request->
       qual[index].synoptic_ccl_query, lt.parent_entity_name = "AP_CASE_QUERY_DETAILS",
       lt.parent_entity_id = temp->qual[index].query_detail_id, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual != 1)
      GO TO lt_failed
     ENDIF
    ENDIF
  ENDFOR
  INSERT  FROM ap_case_query_details acqd,
    (dummyt d  WITH seq = value(nbr_to_insert))
   SET acqd.case_query_id = query_id, acqd.query_detail_id = temp->qual[d.seq].query_detail_id, acqd
    .sequence = request->qual[d.seq].sequence,
    acqd.param_name = request->qual[d.seq].param_name, acqd.criteria_type_flag = request->qual[d.seq]
    .criteria_type_flag, acqd.date_type_flag = request->qual[d.seq].date_type_flag,
    acqd.beg_value_id = request->qual[d.seq].beg_value_id, acqd.beg_value_disp = request->qual[d.seq]
    .beg_value_disp, acqd.beg_value_dt_tm =
    IF ((request->qual[d.seq].beg_value_dt_tm > 0)) cnvtdatetime(request->qual[d.seq].beg_value_dt_tm
      )
    ELSE null
    ENDIF
    ,
    acqd.end_value_id = request->qual[d.seq].end_value_id, acqd.end_value_disp = request->qual[d.seq]
    .end_value_disp, acqd.end_value_dt_tm =
    IF ((request->qual[d.seq].end_value_dt_tm > 0)) cnvtdatetime(request->qual[d.seq].end_value_dt_tm
      )
    ELSE null
    ENDIF
    ,
    acqd.negation_ind = request->qual[d.seq].negation_ind, acqd.source_vocabulary_cd = request->qual[
    d.seq].source_vocabulary_cd, acqd.freetext_query_flag = request->qual[d.seq].freetext_query_flag,
    acqd.freetext_long_text_id = temp->qual[d.seq].freetext_long_text_id, acqd.synoptic_query_flag =
    request->qual[d.seq].synoptic_query_flag, acqd.synoptic_ccl_long_text_id = temp->qual[d.seq].
    synoptic_ccl_long_text_id,
    acqd.synoptic_xml_long_text_id = temp->qual[d.seq].synoptic_xml_long_text_id, acqd.updt_dt_tm =
    cnvtdatetime(curdate,curtime3), acqd.updt_id = reqinfo->updt_id,
    acqd.updt_task = reqinfo->updt_task, acqd.updt_applctx = reqinfo->updt_applctx, acqd.updt_cnt = 0
   PLAN (d)
    JOIN (acqd
    WHERE (acqd.query_detail_id=temp->qual[d.seq].query_detail_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_to_insert)
   GO TO acqd_failed
  ENDIF
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#ltseq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_data_seq"
 SET failed = "T"
 GO TO exit_script
#acq_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_QUERY"
 SET failed = "T"
 GO TO exit_script
#acqd_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_QUERY_DETAILS"
 SET failed = "T"
 GO TO exit_script
#lt_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
