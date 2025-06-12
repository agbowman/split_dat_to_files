CREATE PROGRAM aps_del_purge_case_query:dba
 IF (validate(reply->status_data.status,null)=null)
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
 ENDIF
#script
 SET reply->status_data.status = "F"
 FREE SET temp_batch
 RECORD temp_batch(
   1 user_qual[*]
     2 user_name = vc
     2 user_id = f8
   1 status_qual[*]
     2 status_flag = i2
   1 begin_day_val = c4
   1 end_day_val = c4
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 DECLARE retval = i2 WITH protect, noconstant(0)
 DECLARE x_idx = i4 WITH protect, noconstant(0)
 DECLARE l_idx = i4 WITH protect, noconstant(0)
 DECLARE batch_exists = i2 WITH protect, noconstant(0)
 SET raw_user_name = fillstring(100," ")
 SET raw_status_flag = fillstring(100," ")
 SET raw_beg_day_value = fillstring(100," ")
 SET raw_end_day_value = fillstring(100," ")
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
    SET pos += 1
   ENDWHILE
 END ;Subroutine
 IF (size(trim(request->batch_selection)) > 0)
  SET batch_exists = 1
 ENDIF
 IF (batch_exists)
  DECLARE ap_activity_type_cd = f8 WITH public, noconstant(0.0)
  SET ap_activity_type_cd = uar_get_code_by("MEANING",106,"AP")
  IF (ap_activity_type_cd <= 0)
   SET reply->ops_event = "Failure - Error retrieving AP activity type code"
   GO TO end_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|"), raw_user_name = trim(text,3), retval =
    processbatchparams(raw_user_name,"USERS"),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_status_flag = trim(text,3),
    retval = processbatchparams(raw_status_flag,"STATUS"),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), temp_batch->begin_day_val = trim(
     text,3),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    temp_batch->end_day_val = trim(text,3)
   WITH nocounter
  ;end select
  IF (size(temp_batch->user_qual,5) > 0)
   SELECT INTO "nl:"
    FROM prsnl pl
    PLAN (pl
     WHERE expand(x_idx,1,size(temp_batch->user_qual,5),pl.username,temp_batch->user_qual[x_idx].
      user_name))
    DETAIL
     val = locateval(l_idx,1,size(temp_batch->user_qual,5),pl.username,temp_batch->user_qual[l_idx].
      user_name)
     IF (val > 0)
      temp_batch->user_qual[val].user_id = pl.person_id
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (size(temp_batch->status_qual,5)=0)
   SET stat = alterlist(temp_batch->status_qual,13)
   FOR (val = 1 TO 13)
     SET temp_batch->status_qual[val].status_flag = val
   ENDFOR
  ENDIF
  SET raw_date_num_str = cnvtint(substring(1,3,temp_batch->begin_day_val))
  IF (value(raw_date_num_str) <= 0)
   SET reply->ops_event = "Failure - Begin Date Value is set to 000"
   GO TO end_script
  ENDIF
  CASE (substring(4,1,temp_batch->begin_day_val))
   OF "D":
    SET temp_batch->beg_dt_tm = cnvtagedatetime(0,0,0,raw_date_num_str)
   OF "M":
    SET temp_batch->beg_dt_tm = cnvtagedatetime(0,raw_date_num_str,0,0)
   OF "Y":
    SET temp_batch->beg_dt_tm = cnvtagedatetime(raw_date_num_str,0,0,0)
   ELSE
    SET reply->ops_event = "Failure - Error with setting begin date"
    GO TO end_script
  ENDCASE
  SET raw_date_num_str = cnvtint(substring(1,3,temp_batch->end_day_val))
  IF (value(raw_date_num_str) <= 0)
   SET reply->ops_event = "Failure - End Date Value is set to 000"
   GO TO end_script
  ENDIF
  CASE (substring(4,1,temp_batch->end_day_val))
   OF "D":
    SET temp_batch->end_dt_tm = cnvtdatetime(cnvtdate(cnvtagedatetime(0,0,0,raw_date_num_str)),
     curtime3)
   OF "M":
    SET temp_batch->end_dt_tm = cnvtdatetime(cnvtdate(cnvtagedatetime(0,raw_date_num_str,0,0)),
     curtime3)
   OF "Y":
    SET temp_batch->end_dt_tm = cnvtdatetime(cnvtdate(cnvtagedatetime(raw_date_num_str,0,0,0)),
     curtime3)
   ELSE
    SET reply->ops_event = "Failure - Error with setting end date"
    GO TO end_script
  ENDCASE
  IF (datetimediff(temp_batch->end_dt_tm,temp_batch->beg_dt_tm) < 0)
   SET reply->ops_event = "Failure - Begin Date is after End Date"
   GO TO end_script
  ENDIF
  DECLARE param_cnt = i4 WITH protect, noconstant(0)
  SELECT
   IF (size(temp_batch->user_qual,5) > 0)
    PLAN (acq
     WHERE expand(x_idx,1,size(temp_batch->user_qual,5),acq.started_prsnl_id,temp_batch->user_qual[
      x_idx].user_id)
      AND ((acq.activity_type_cd=ap_activity_type_cd) OR (acq.activity_type_cd=0)) )
   ELSE
    PLAN (acq
     WHERE ((acq.activity_type_cd=ap_activity_type_cd) OR (acq.activity_type_cd=0)) )
   ENDIF
   INTO "nl:"
   FROM ap_case_query acq
   HEAD REPORT
    param_cnt = 0, val = 0
   DETAIL
    val = locateval(l_idx,1,size(temp_batch->status_qual,5),acq.status_flag,temp_batch->status_qual[
     l_idx].status_flag)
    IF (val > 0)
     IF (acq.query_start_dt_tm != null)
      IF (acq.query_start_dt_tm BETWEEN cnvtdatetime(temp_batch->beg_dt_tm) AND cnvtdatetime(
       temp_batch->end_dt_tm))
       param_cnt += 1
       IF (param_cnt > size(request->qual,5))
        stat = alterlist(request->qual,(param_cnt+ 9))
       ENDIF
       request->qual[param_cnt].case_query_id = acq.case_query_id
      ENDIF
     ELSE
      IF (acq.updt_dt_tm BETWEEN cnvtdatetime(temp_batch->beg_dt_tm) AND cnvtdatetime(temp_batch->
       end_dt_tm))
       param_cnt += 1
       IF (param_cnt > size(request->qual,5))
        stat = alterlist(request->qual,(param_cnt+ 9))
       ENDIF
       request->qual[param_cnt].case_query_id = acq.case_query_id
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(request->qual,param_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE (processbatchparams(batchselection=vc,filterparam=vc) =i2)
   DECLARE temp_pos = i4 WITH protect, noconstant(0)
   DECLARE temp_str = vc
   SET temp_str = batchselection
   IF (size(trim(batchselection,3)) > 0)
    SET val = 0
    SET temp_pos = cnvtint(value(findstring(",",temp_str)))
    WHILE (temp_pos > 0)
      SET val += 1
      CASE (filterparam)
       OF "USERS":
        SET stat = alterlist(temp_batch->user_qual,val)
        SET temp_batch->user_qual[val].user_name = cnvtupper(trim(substring(1,(temp_pos - 1),temp_str
           ),3))
       OF "STATUS":
        SET stat = alterlist(temp_batch->status_qual,val)
        SET temp_batch->status_qual[val].status_flag = cnvtint(trim(substring(1,(temp_pos - 1),
           temp_str),3))
      ENDCASE
      SET temp_str = trim(substring((temp_pos+ 1),size(trim(temp_str,3)),temp_str),3)
      SET temp_pos = cnvtint(value(findstring(",",temp_str)))
    ENDWHILE
    SET val += 1
    CASE (filterparam)
     OF "USERS":
      SET stat = alterlist(temp_batch->user_qual,val)
      SET temp_batch->user_qual[val].user_name = cnvtupper(trim(substring(1,size(trim(temp_str,3)),
         temp_str),3))
     OF "STATUS":
      SET stat = alterlist(temp_batch->status_qual,val)
      SET temp_batch->status_qual[val].status_flag = cnvtint(trim(substring(1,size(trim(temp_str,3)),
         temp_str),3))
    ENDCASE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET number_queries_to_del = cnvtint(size(request->qual,5))
 SET number_results_to_del = 0
 SET number_offsets_to_del = 0
 SET number_details_to_del = 0
 SET number_successful_dels = 0
 SET number_failed_dels = 0
 SET x = 0
 SET failed_ind = 0
 SET del_long_text_id = 0.0
 DECLARE opr_name = vc WITH protect
 DECLARE obj_name = vc WITH protect
 RECORD temp_long_text(
   1 qual[*]
     2 long_text_id = f8
 )
 FOR (x = 1 TO number_queries_to_del)
   SET ret = initrec(temp_long_text)
   SET failed_ind = 0
   SELECT INTO "nl:"
    aqro.query_result_id
    FROM ap_query_result_offset aqro,
     ap_query_result aqr
    PLAN (aqr
     WHERE (request->qual[x].case_query_id=aqr.case_query_id))
     JOIN (aqro
     WHERE aqro.query_result_id=aqr.query_result_id)
    HEAD REPORT
     number_offsets_to_del = 0
    DETAIL
     number_offsets_to_del += 1
    WITH nocounter
   ;end select
   IF (curqual != 0)
    DELETE  FROM ap_query_result_offset aqro,
      ap_query_result aqr,
      dummyt d
     SET d.seq = 1
     PLAN (aqro)
      JOIN (d)
      JOIN (aqr
      WHERE (request->qual[x].case_query_id=aqr.case_query_id)
       AND aqro.query_result_id=aqr.query_result_id)
     WITH nocounter
    ;end delete
    IF (curqual != number_offsets_to_del)
     SET failed_ind = 1
     SET opr_name = "Delete"
     SET obj_name = "AP_QUERY_RESULT_OFFSET"
    ENDIF
   ENDIF
   IF (failed_ind=0)
    SELECT INTO "nl:"
     aqr.case_query_id
     FROM ap_query_result aqr
     WHERE (aqr.case_query_id=request->qual[x].case_query_id)
     HEAD REPORT
      number_results_to_del = 0
     DETAIL
      number_results_to_del += 1
     WITH nocounter
    ;end select
    IF (curqual != 0)
     DELETE  FROM ap_query_result aqr
      PLAN (aqr
       WHERE (request->qual[x].case_query_id=aqr.case_query_id))
      WITH nocounter
     ;end delete
     IF (curqual != number_results_to_del)
      SET failed_ind = 1
      SET opr_name = "Delete"
      SET obj_name = "AP_QUERY_RESULT"
     ENDIF
    ENDIF
   ENDIF
   IF (failed_ind=0)
    SELECT INTO "nl:"
     acqd.case_query_id
     FROM ap_case_query_details acqd
     WHERE (acqd.case_query_id=request->qual[x].case_query_id)
     HEAD REPORT
      number_details_to_del = 0, del_long_text_id = 0.0, tmp_cnt = 0
     DETAIL
      number_details_to_del += 1
      IF (acqd.param_name="CRITERIA_FREETEXT")
       tmp_cnt += 1, stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[tmp_cnt].
       long_text_id = acqd.freetext_long_text_id
      ENDIF
      IF (acqd.param_name="CRITERIA_SYNOPTIC")
       tmp_cnt += 1, stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[tmp_cnt].
       long_text_id = acqd.synoptic_xml_long_text_id,
       tmp_cnt += 1, stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[tmp_cnt].
       long_text_id = acqd.synoptic_ccl_long_text_id
      ENDIF
     WITH nocounter
    ;end select
    IF (failed_ind=0)
     DELETE  FROM ap_case_query_details acqd,
       (dummyt d  WITH seq = value(number_details_to_del))
      SET acqd.case_query_id = request->qual[x].case_query_id
      PLAN (d)
       JOIN (acqd
       WHERE (acqd.case_query_id=request->qual[x].case_query_id))
      WITH nocounter
     ;end delete
     IF (curqual != number_details_to_del)
      SET failed_ind = 1
      SET opr_name = "Delete"
      SET obj_name = "AP_CASE_QUERY_DETAILS"
     ENDIF
    ENDIF
    IF (failed_ind=0)
     SET param_del_cnt = size(temp_long_text->qual,5)
     IF (param_del_cnt != 0)
      DELETE  FROM long_text lt,
        (dummyt d  WITH seq = value(param_del_cnt))
       SET lt.long_text_id = temp_long_text->qual[d.seq].long_text_id
       PLAN (d)
        JOIN (lt
        WHERE (lt.long_text_id=temp_long_text->qual[d.seq].long_text_id))
       WITH nocounter
      ;end delete
      IF (curqual != param_del_cnt)
       SET failed_ind = 1
       SET opr_name = "Delete"
       SET obj_name = "LONG_TEXT"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failed_ind=0)
    DELETE  FROM ap_case_query acq
     WHERE (request->qual[x].case_query_id=acq.case_query_id)
     WITH nocounter
    ;end delete
    IF (curqual != 1)
     SET failed_ind = 1
     SET opr_name = "Delete"
     SET obj_name = "AP_CASE_QUERY"
    ENDIF
   ENDIF
   IF (failed_ind=0)
    SET number_successful_dels += 1
    COMMIT
   ELSE
    SET number_failed_dels += 1
    SET stat = alter(reply->status_data.subeventstatus,number_failed_dels)
    SET reply->status_data.subeventstatus[number_failed_dels].operationstatus = "F"
    SET reply->status_data.subeventstatus[number_failed_dels].operationname = opr_name
    SET reply->status_data.subeventstatus[number_failed_dels].targetobjectname = obj_name
    SET reply->status_data.subeventstatus[number_failed_dels].targetobjectvalue = build("query_cd: ",
     request->qual[x].case_query_id)
    ROLLBACK
   ENDIF
 ENDFOR
 IF (number_queries_to_del=0)
  SET reply->status_data.status = "Z"
  IF (batch_exists)
   SET reply->ops_event = "No data qualified to purge"
  ENDIF
 ELSEIF (number_queries_to_del=number_successful_dels)
  SET reply->status_data.status = "S"
  IF (batch_exists)
   SET reply->ops_event = "Data qualified is completely purged"
  ENDIF
 ELSEIF (number_successful_dels > 0)
  SET reply->status_data.status = "P"
  IF (batch_exists)
   SET reply->ops_event = "Data qualified is partially purged"
  ENDIF
 ENDIF
#end_script
 FREE SET temp_batch
END GO
