CREATE PROGRAM aps_add_batch_query:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_param(
   1 qual[10]
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
 )
 RECORD temp(
   1 qual[*]
     2 query_detail_id = f8
     2 freetext_long_text_id = f8
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET raw_query_name = fillstring(100," ")
 SET raw_report_history_grping = fillstring(100," ")
 SET raw_output_dest = fillstring(100," ")
 SET raw_printer_name = fillstring(100," ")
 SET raw_nbr_copies = 0
 SET raw_report_type = fillstring(7," ")
 SET raw_results_type = fillstring(6," ")
 SET report_type = 0
 SET result_name = fillstring(100," ")
 SET param_cnt = 0
 SET max_param_cnt = 0
 SET error_number = 0
 SET search_type = 0
 SET nbr_to_insert = 0
 SET index = 0
 SET result_date_time = fillstring(20," ")
 SET space_string = fillstring(1," ")
 DECLARE report_history_grouping_cd = f8 WITH public, noconstant(0.0)
 DECLARE query_id = f8 WITH public, noconstant(0.0)
 DECLARE output_dest_id = f8 WITH public, noconstant(0.0)
 DECLARE query_detail_id = f8 WITH public, noconstant(0.0)
 DECLARE temp_report_cd = f8 WITH public, noconstant(0.0)
 DECLARE ap_activity_type_cd = f8 WITH public, noconstant(0.0)
 SET ap_activity_type_cd = uar_get_code_by("MEANING",106,"AP")
 DECLARE ap_alpha_source_vocab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,
   "ANATOMIC PAT"))
 DECLARE patient_alias_flag = c1
 DECLARE snomed_code_flag = c1
 IF (ap_activity_type_cd <= 0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failure - Error retriving activity type cd"
  GO TO exit_script
 ENDIF
 DECLARE text = c100
 DECLARE real = f8
 DECLARE six = i2
 DECLARE pos = i2
 DECLARE startpos2 = i2
 DECLARE len = i4
 DECLARE endstring = c2
 SUBROUTINE get_text(startpos,textstring,delimit)
   SET siz = size(trim(textstring),1)
   SET pos = startpos
   SET endstring = "F"
   WHILE (pos <= siz)
    IF (substring(pos,1,trim(textstring))=delimit)
     IF (pos=siz)
      SET endstring = "T"
     ENDIF
     SET len = (pos - startpos)
     SET text = substring(startpos,len,trim(textstring))
     SET real = cnvtreal(trim(text))
     SET startpos = (pos+ 1)
     SET startpos2 = (pos+ 1)
     SET pos = siz
    ENDIF
    SET pos = (pos+ 1)
   ENDWHILE
 END ;Subroutine
 SELECT INTO "nl:"
  x = 1
  DETAIL
   CALL get_text(x,trim(request->batch_selection),"|"), raw_query_name = trim(text),
   CALL get_text(startpos2,trim(request->batch_selection),"|"),
   raw_report_history_grping = trim(text),
   CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_report_type = trim(text),
   CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_results_type = trim(text),
   CALL get_text(startpos2,trim(request->batch_selection),"|"),
   patient_alias_flag = trim(text)
   IF (trim(patient_alias_flag) != "Y")
    patient_alias_flag = "N"
   ENDIF
   CALL get_text(startpos2,trim(request->batch_selection),"|"), snomed_code_flag = trim(text)
   IF (trim(snomed_code_flag) != "Y")
    snomed_code_flag = "N"
   ENDIF
   IF (textlen(trim(request->output_dist)) > 0)
    CALL get_text(1,trim(request->output_dist),"|"), raw_output_dest = trim(text), raw_printer_name
     = substring(1,4,trim(raw_output_dest))
   ENDIF
   CALL get_text(startpos2,trim(request->output_dist),"|"), raw_nbr_copies = cnvtint(trim(text))
  WITH nocounter
 ;end select
 IF (textlen(trim(raw_query_name))=0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failure - Error with query name!"
  SET error_number = 1
  GO TO end_script
 ENDIF
 IF (textlen(trim(raw_report_history_grping)) > 0)
  SET report_history_grouping_cd = uar_get_code_by("DISPLAY",1311,nullterm(raw_report_history_grping)
   )
  IF (report_history_grouping_cd <= 0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with Report History Grouping"
   SET error_number = 2
   GO TO end_script
  ENDIF
 ENDIF
 IF (cnvtupper(trim(raw_report_type))="SUMMARY")
  SET report_type = 1
 ELSEIF (cnvtupper(trim(raw_report_type))="DETAILS")
  SET report_type = 2
 ELSE
  SET report_type = 0
 ENDIF
 IF (cnvtupper(trim(raw_results_type))="ONLINE")
  SET result_date_time = concat(space_string,trim(format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  SET result_name = concat(trim(raw_query_name),result_date_time)
 ELSEIF (textlen(trim(request->output_dist))=0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failure - Error with output_dist!"
  GO TO end_script
 ELSEIF (report_type=0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failure - Error with Report Type"
  SET error_number = 3
  GO TO end_script
 ELSE
  SET result_name = ""
 ENDIF
 IF (trim(raw_output_dest) != "")
  SELECT INTO "nl:"
   o.output_dest_cd
   FROM output_dest o
   WHERE raw_output_dest=o.name
   DETAIL
    output_dest_id = o.output_dest_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dest_id!"
   SET error_number = 4
   GO TO end_script
  ENDIF
  IF (raw_nbr_copies < 1)
   SET raw_nbr_copies = 1
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, cv2.code_value, adqp.query_cd,
  n.nomenclature_id, n2.nomenclature_id, p.person_id,
  ap.prefix_id
  FROM code_value cv,
   code_value cv2,
   long_text lt,
   ap_diag_query_param adqp,
   nomenclature n,
   nomenclature n2,
   prsnl p,
   ap_prefix ap,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1)
  PLAN (cv
   WHERE cv.display_key=trim(cnvtupper(cnvtalphanum(raw_query_name)))
    AND cv.code_set=14252
    AND cv.cdf_meaning IN ("", "PATHNET-AP"))
   JOIN (adqp
   WHERE adqp.query_cd=cv.code_value)
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (cv2
   WHERE cv2.code_value=adqp.beg_value_id
    AND adqp.param_name IN ("PATIENT_ETHNICGROUP", "PATIENT_GENDER", "PATIENT_RACE",
   "PATIENT_SPECIES", "PATIENT_MILITARY",
   "CASE_CASETYPE", "CASE_TASKASSAY"))
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (ap
   WHERE ap.prefix_id=adqp.beg_value_id
    AND adqp.param_name="CASE_ACCPREFIX")
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (p
   WHERE p.person_id=adqp.beg_value_id
    AND adqp.param_name IN ("CASE_VERID", "CASE_REQPHYS", "CASE_RESPPATH", "CASE_RESPRESI"))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (n
   WHERE n.nomenclature_id=adqp.beg_value_id
    AND adqp.criteria_type_flag=3)
   JOIN (n2
   WHERE n2.nomenclature_id=adqp.end_value_id
    AND adqp.criteria_type_flag=3)
   JOIN (lt
   WHERE lt.long_text_id=adqp.freetext_long_text_id)
  HEAD REPORT
   param_cnt = 0
  DETAIL
   param_cnt = (param_cnt+ 1)
   IF (param_cnt > max_param_cnt)
    stat = alter(temp_param->qual,(param_cnt+ 9)), stat = alterlist(temp->qual,(param_cnt+ 9)),
    max_param_cnt = (param_cnt+ 9)
   ENDIF
   temp_param->qual[param_cnt].sequence = param_cnt, temp_param->qual[param_cnt].param_name = adqp
   .param_name, temp_param->qual[param_cnt].criteria_type_flag = adqp.criteria_type_flag,
   temp_param->qual[param_cnt].date_type_flag = adqp.date_type_flag, temp_param->qual[param_cnt].
   beg_value_id = adqp.beg_value_id, temp_param->qual[param_cnt].beg_value_dt_tm = adqp
   .beg_value_dt_tm,
   temp_param->qual[param_cnt].end_value_id = adqp.end_value_id, temp_param->qual[param_cnt].
   end_value_dt_tm = adqp.end_value_dt_tm, temp_param->qual[param_cnt].negation_ind = adqp
   .negation_ind,
   temp_param->qual[param_cnt].source_vocabulary_cd = adqp.source_vocabulary_cd, temp_param->qual[
   param_cnt].freetext_query_flag = adqp.freetext_query_flag, temp_param->qual[param_cnt].
   freetext_query = lt.long_text
   IF ((temp_param->qual[param_cnt].param_name="CASE_TASKASSAY"))
    temp_report_cd = temp_param->qual[param_cnt].beg_value_id
   ENDIF
   IF ((temp_param->qual[param_cnt].criteria_type_flag=3))
    IF ((temp_param->qual[param_cnt].source_vocabulary_cd=ap_alpha_source_vocab_cd))
     temp_param->qual[param_cnt].beg_value_disp = n.source_string, temp_param->qual[param_cnt].
     end_value_disp = n2.source_string
    ELSE
     temp_param->qual[param_cnt].beg_value_disp = n.source_identifier, temp_param->qual[param_cnt].
     end_value_disp = n2.source_identifier
    ENDIF
   ELSEIF ((temp_param->qual[param_cnt].param_name IN ("PATIENT_ETHNICGROUP", "PATIENT_GENDER",
   "PATIENT_RACE", "PATIENT_SPECIES", "PATIENT_MILITARY",
   "CASE_CASETYPE", "CASE_TASKASSAY")))
    temp_param->qual[param_cnt].beg_value_disp = cv2.display
   ELSEIF ((temp_param->qual[param_cnt].param_name="CASE_ACCPREFIX"))
    temp_param->qual[param_cnt].beg_value_disp = ap.prefix_name
   ELSEIF ((temp_param->qual[param_cnt].param_name IN ("CASE_VERID", "CASE_REQPHYS", "CASE_RESPPATH",
   "CASE_RESPRESI")))
    temp_param->qual[param_cnt].beg_value_disp = p.name_full_formatted
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = p, outerjoin = d3, dontcare = ap,
   outerjoin = d4, dontcare = cv2
 ;end select
 IF (curqual=0)
  GO TO cv_failed
 ENDIF
 IF (temp_report_cd > 0)
  SELECT INTO "nl:"
   oc.catalog_cd
   FROM order_catalog oc
   WHERE oc.catalog_cd=temp_report_cd
   DETAIL
    search_type = 1
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET search_type = 2
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failure - Error with query name!"
  SET error_number = 6
  GO TO end_script
 ENDIF
 IF (param_cnt > 0)
  SET param_cnt = (param_cnt+ 1)
  IF (param_cnt > max_param_cnt)
   SET stat = alter(temp_param->qual,(param_cnt+ 2))
   SET stat = alterlist(temp->qual,(param_cnt+ 2))
  ENDIF
  SET max_param_cnt = (max_param_cnt+ 2)
  SET temp_param->qual[param_cnt].sequence = param_cnt
  SET temp_param->qual[param_cnt].param_name = "PATIENTALIASFLAG"
  SET temp_param->qual[param_cnt].criteria_type_flag = 4
  SET temp_param->qual[param_cnt].beg_value_disp = patient_alias_flag
  SET param_cnt = (param_cnt+ 1)
  IF (param_cnt > max_param_cnt)
   SET stat = alter(temp_param->qual,(param_cnt+ 1))
   SET stat = alterlist(temp->qual,(param_cnt+ 1))
  ENDIF
  SET max_param_cnt = (max_param_cnt+ 1)
  SET temp_param->qual[param_cnt].sequence = param_cnt
  SET temp_param->qual[param_cnt].param_name = "SNOMEDCODEFLAG"
  SET temp_param->qual[param_cnt].criteria_type_flag = 4
  SET temp_param->qual[param_cnt].beg_value_disp = snomed_code_flag
  IF (param_cnt < max_param_cnt)
   SET stat = alter(temp_param->qual,param_cnt)
   SET stat = alterlist(temp->qual,param_cnt)
  ENDIF
  SET nbr_to_insert = param_cnt
 ENDIF
 FOR (index = 1 TO param_cnt)
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
   IF ((temp_param->qual[index].param_name="CRITERIA_FREETEXT"))
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
     SET lt.long_text_id = temp->qual[index].freetext_long_text_id, lt.long_text = temp_param->qual[
      index].freetext_query, lt.parent_entity_name = "AP_CASE_QUERY_DETAILS",
      lt.parent_entity_id = temp->qual[index].query_detail_id, lt.active_ind = 1, lt.active_status_cd
       = reqdata->active_status_cd,
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
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   query_id = seq_nbr
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO pathseq_failed
 ENDIF
 INSERT  FROM ap_case_query acq
  SET acq.case_query_id = query_id, acq.output_dest_id = output_dest_id, acq.nbr_copies =
   raw_nbr_copies,
   acq.report_type_flag = report_type, acq.search_type_flag = search_type, acq.result_name =
   result_name,
   acq.result_name_key = cnvtupper(result_name), acq.started_prsnl_id = reqinfo->updt_id, acq
   .report_history_cd = report_history_grouping_cd,
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
 INSERT  FROM ap_case_query_details acqd,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET acqd.query_detail_id = temp->qual[d.seq].query_detail_id, acqd.case_query_id = query_id, acqd
   .sequence = temp_param->qual[d.seq].sequence,
   acqd.param_name = temp_param->qual[d.seq].param_name, acqd.criteria_type_flag = temp_param->qual[d
   .seq].criteria_type_flag, acqd.date_type_flag = temp_param->qual[d.seq].date_type_flag,
   acqd.beg_value_id = temp_param->qual[d.seq].beg_value_id, acqd.beg_value_disp = temp_param->qual[d
   .seq].beg_value_disp, acqd.beg_value_dt_tm =
   IF ((temp_param->qual[d.seq].beg_value_dt_tm > 0)) cnvtdatetime(temp_param->qual[d.seq].
     beg_value_dt_tm)
   ELSE null
   ENDIF
   ,
   acqd.end_value_id = temp_param->qual[d.seq].end_value_id, acqd.end_value_disp = temp_param->qual[d
   .seq].end_value_disp, acqd.end_value_dt_tm =
   IF ((temp_param->qual[d.seq].end_value_dt_tm > 0)) cnvtdatetime(temp_param->qual[d.seq].
     end_value_dt_tm)
   ELSE null
   ENDIF
   ,
   acqd.negation_ind = temp_param->qual[d.seq].negation_ind, acqd.source_vocabulary_cd = temp_param->
   qual[d.seq].source_vocabulary_cd, acqd.freetext_long_text_id = temp->qual[d.seq].
   freetext_long_text_id,
   acqd.updt_dt_tm = cnvtdatetime(curdate,curtime3), acqd.updt_id = reqinfo->updt_id, acqd.updt_task
    = reqinfo->updt_task,
   acqd.updt_applctx = reqinfo->updt_applctx, acqd.updt_cnt = 0
  PLAN (d)
   JOIN (acqd
   WHERE (acqd.query_detail_id=temp->qual[d.seq].query_detail_id))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_to_insert)
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
#pathseq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "pathnet_seq"
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
#cv_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET failed = "T"
 GO TO exit_script
#lt_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#end_script
 SET reply->status_data.subeventstatus[1].operationname = "Invalid Operations Parameters"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "Param Number"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(error_number)
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
