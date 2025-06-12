CREATE PROGRAM aps_add_requeued_query:dba
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
   1 case_query_id = f8
   1 search_type_flag = i2
   1 param_qual[*]
     2 query_detail_id = f8
     2 sequence = i4
     2 param_name = c20
     2 criteria_type_flag = i2
     2 date_type_flag = i2
     2 beg_value_id = f8
     2 beg_value_disp = c40
     2 beg_value_dt_tm = dq8
     2 end_value_id = f8
     2 end_value_disp = c40
     2 end_value_dt_tm = dq8
     2 negation_ind = i2
     2 source_vocabulary_cd = f8
     2 freetext_query_flag = i2
     2 freetext_query = vc
     2 freetext_long_text_id = f8
     2 synoptic_query_flag = i2
     2 synoptic_ccl_query = vc
     2 synoptic_xml_query = vc
     2 synoptic_ccl_long_text_id = f8
     2 synoptic_xml_long_text_id = f8
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET param_cnt = 0
 SET index = 0
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
   temp->case_query_id = seq_nbr, reply->case_query_id = seq_nbr
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 SELECT INTO "nl:"
  acq.case_query_id, acqd.case_query_id
  FROM ap_case_query acq,
   ap_case_query_details acqd,
   long_text lt,
   long_text lt2,
   long_text lt3
  PLAN (acq
   WHERE (request->qual[1].case_query_id=acq.case_query_id))
   JOIN (acqd
   WHERE acq.case_query_id=acqd.case_query_id)
   JOIN (lt
   WHERE acqd.freetext_long_text_id=lt.long_text_id)
   JOIN (lt2
   WHERE lt2.long_text_id=acqd.synoptic_ccl_long_text_id)
   JOIN (lt3
   WHERE lt3.long_text_id=acqd.synoptic_xml_long_text_id)
  HEAD REPORT
   param_cnt = 0, temp->search_type_flag = acq.search_type_flag, nmaxcnt = 0
  DETAIL
   IF (trim(acqd.param_name) != "PATIENTALIASFLAG"
    AND trim(acqd.param_name) != "SNOMEDCODEFLAG")
    param_cnt = (param_cnt+ 1)
    IF (mod(param_cnt,10)=1)
     stat = alterlist(temp->param_qual,(param_cnt+ 9))
    ENDIF
    temp->param_qual[param_cnt].sequence = acqd.sequence
    IF ((temp->param_qual[param_cnt].sequence > nmaxcnt))
     nmaxcnt = temp->param_qual[param_cnt].sequence
    ENDIF
    temp->param_qual[param_cnt].param_name = acqd.param_name, temp->param_qual[param_cnt].
    criteria_type_flag = acqd.criteria_type_flag, temp->param_qual[param_cnt].date_type_flag = acqd
    .date_type_flag,
    temp->param_qual[param_cnt].beg_value_id = acqd.beg_value_id, temp->param_qual[param_cnt].
    beg_value_disp = acqd.beg_value_disp, temp->param_qual[param_cnt].beg_value_dt_tm = acqd
    .beg_value_dt_tm,
    temp->param_qual[param_cnt].end_value_id = acqd.end_value_id, temp->param_qual[param_cnt].
    end_value_disp = acqd.end_value_disp, temp->param_qual[param_cnt].end_value_dt_tm = acqd
    .end_value_dt_tm,
    temp->param_qual[param_cnt].negation_ind = acqd.negation_ind, temp->param_qual[param_cnt].
    source_vocabulary_cd = acqd.source_vocabulary_cd, temp->param_qual[param_cnt].freetext_query_flag
     = acqd.freetext_query_flag,
    temp->param_qual[param_cnt].synoptic_query_flag = acqd.synoptic_query_flag
    IF (acqd.freetext_long_text_id != 0.0)
     temp->param_qual[param_cnt].freetext_query = lt.long_text
    ENDIF
    IF (acqd.synoptic_ccl_long_text_id != 0.0
     AND acqd.synoptic_xml_long_text_id != 0.0)
     temp->param_qual[param_cnt].synoptic_xml_query = lt3.long_text, temp->param_qual[param_cnt].
     synoptic_ccl_query = lt2.long_text
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->param_qual,(param_cnt+ 2)), param_cnt = (param_cnt+ 1), nmaxcnt = (nmaxcnt
   + 1),
   temp->param_qual[param_cnt].sequence = nmaxcnt, temp->param_qual[param_cnt].param_name =
   "PATIENTALIASFLAG", temp->param_qual[param_cnt].criteria_type_flag = 4,
   temp->param_qual[param_cnt].beg_value_disp = request->print_aliases, param_cnt = (param_cnt+ 1),
   nmaxcnt = (nmaxcnt+ 1),
   temp->param_qual[param_cnt].sequence = nmaxcnt, temp->param_qual[param_cnt].param_name =
   "SNOMEDCODEFLAG", temp->param_qual[param_cnt].criteria_type_flag = 4,
   temp->param_qual[param_cnt].beg_value_disp = request->print_snomed
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO get_failed
 ENDIF
 IF ((request->del_case_query_id != 0.0))
  SET request->qual[1].case_query_id = request->del_case_query_id
  EXECUTE aps_del_purge_case_query
  IF ((reply->status_data.status != "S"))
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM ap_case_query acq
  SET acq.case_query_id = temp->case_query_id, acq.result_name = request->result_name, acq
   .result_name_key = cnvtupper(request->result_name),
   acq.output_dest_id = request->output_dest_id, acq.nbr_copies = request->nbr_copies, acq
   .report_type_flag = request->report_type_flag,
   acq.report_history_cd = request->report_history_grping, acq.started_prsnl_id = reqinfo->updt_id,
   acq.search_type_flag = temp->search_type_flag,
   acq.status_flag = 1, acq.activity_type_cd = ap_activity_type_cd, acq.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   acq.updt_id = reqinfo->updt_id, acq.updt_task = reqinfo->updt_task, acq.updt_applctx = reqinfo->
   updt_applctx,
   acq.updt_cnt = 0
  PLAN (acq
   WHERE (acq.case_query_id=temp->case_query_id))
  WITH nocounter, dontexist
 ;end insert
 IF (curqual=0)
  GO TO acq_failed
 ENDIF
 FOR (index = 1 TO cnvtint(size(temp->param_qual,5)))
   SELECT INTO "nl:"
    seq_nbr = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     temp->param_qual[index].query_detail_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   IF ((temp->param_qual[index].param_name="CRITERIA_FREETEXT"))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      temp->param_qual[index].freetext_long_text_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO ltseq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = temp->param_qual[index].freetext_long_text_id, lt.long_text = temp->
      param_qual[index].freetext_query, lt.parent_entity_name = "AP_CASE_QUERY_DETAILS",
      lt.parent_entity_id = temp->param_qual[index].query_detail_id, lt.active_ind = 1, lt
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
   IF ((temp->param_qual[index].param_name="CRITERIA_SYNOPTIC"))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      temp->param_qual[index].synoptic_xml_long_text_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO ltseq_failed
    ENDIF
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      temp->param_qual[index].synoptic_ccl_long_text_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO ltseq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = temp->param_qual[index].synoptic_xml_long_text_id, lt.long_text = temp->
      param_qual[index].synoptic_xml_query, lt.parent_entity_name = "AP_CASE_QUERY_DETAILS",
      lt.parent_entity_id = temp->param_qual[index].query_detail_id, lt.active_ind = 1, lt
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
     SET lt.long_text_id = temp->param_qual[index].synoptic_ccl_long_text_id, lt.long_text = temp->
      param_qual[index].synoptic_ccl_query, lt.parent_entity_name = "AP_CASE_QUERY_DETAILS",
      lt.parent_entity_id = temp->param_qual[index].query_detail_id, lt.active_ind = 1, lt
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
   (dummyt d  WITH seq = value(size(temp->param_qual,5)))
  SET acqd.query_detail_id = temp->param_qual[d.seq].query_detail_id, acqd.case_query_id = temp->
   case_query_id, acqd.sequence = temp->param_qual[d.seq].sequence,
   acqd.param_name = temp->param_qual[d.seq].param_name, acqd.criteria_type_flag = temp->param_qual[d
   .seq].criteria_type_flag, acqd.date_type_flag = temp->param_qual[d.seq].date_type_flag,
   acqd.beg_value_id = temp->param_qual[d.seq].beg_value_id, acqd.beg_value_disp = temp->param_qual[d
   .seq].beg_value_disp, acqd.beg_value_dt_tm =
   IF ((temp->param_qual[d.seq].beg_value_dt_tm > 0)) cnvtdatetime(temp->param_qual[d.seq].
     beg_value_dt_tm)
   ELSE null
   ENDIF
   ,
   acqd.end_value_id = temp->param_qual[d.seq].end_value_id, acqd.end_value_disp = temp->param_qual[d
   .seq].end_value_disp, acqd.end_value_dt_tm =
   IF ((temp->param_qual[d.seq].end_value_dt_tm > 0)) cnvtdatetime(temp->param_qual[d.seq].
     end_value_dt_tm)
   ELSE null
   ENDIF
   ,
   acqd.negation_ind = temp->param_qual[d.seq].negation_ind, acqd.source_vocabulary_cd = temp->
   param_qual[d.seq].source_vocabulary_cd, acqd.freetext_query_flag = temp->param_qual[d.seq].
   freetext_query_flag,
   acqd.freetext_long_text_id = temp->param_qual[d.seq].freetext_long_text_id, acqd
   .synoptic_query_flag = temp->param_qual[d.seq].synoptic_query_flag, acqd.synoptic_ccl_long_text_id
    = temp->param_qual[d.seq].synoptic_ccl_long_text_id,
   acqd.synoptic_xml_long_text_id = temp->param_qual[d.seq].synoptic_xml_long_text_id, acqd
   .updt_dt_tm = cnvtdatetime(curdate,curtime3), acqd.updt_id = reqinfo->updt_id,
   acqd.updt_task = reqinfo->updt_task, acqd.updt_applctx = reqinfo->updt_applctx, acqd.updt_cnt = 0
  PLAN (d)
   JOIN (acqd
   WHERE (acqd.query_detail_id=temp->param_qual[d.seq].query_detail_id))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != value(size(temp->param_qual,5)))
  GO TO acqd_failed
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
#get_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
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
