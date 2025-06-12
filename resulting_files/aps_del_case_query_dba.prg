CREATE PROGRAM aps_del_case_query:dba
 RECORD reply(
   1 qual[*]
     2 case_query_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_long_text(
   1 qual[*]
     2 long_text_id = f8
 )
#script
 SET number_details_to_del = 0
 SET reply->status_data.status = "F"
 SET number_queries_to_del = cnvtint(size(request->qual,5))
 SET number_successful_dels = 0
 SET number_failed_dels = 0
 SET failed_ind = 0
 SET x = 0
 SET del_long_text_id = 0.0
 SET stat = alterlist(reply->qual,number_queries_to_del)
 FOR (x = 1 TO number_queries_to_del)
   SET failed_ind = 0
   SELECT INTO "nl:"
    acqd.case_query_id
    FROM ap_case_query_details acqd
    WHERE (acqd.case_query_id=request->qual[x].case_query_id)
    HEAD REPORT
     number_details_to_del = 0, del_long_text_id = 0.0, tmp_cnt = 0
    DETAIL
     number_details_to_del = (number_details_to_del+ 1)
     IF (acqd.param_name="CRITERIA_FREETEXT")
      tmp_cnt = (tmp_cnt+ 1), stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[
      tmp_cnt].long_text_id = acqd.freetext_long_text_id
     ENDIF
     IF (acqd.param_name="CRITERIA_SYNOPTIC")
      tmp_cnt = (tmp_cnt+ 1), stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[
      tmp_cnt].long_text_id = acqd.synoptic_xml_long_text_id,
      tmp_cnt = (tmp_cnt+ 1), stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[
      tmp_cnt].long_text_id = acqd.synoptic_ccl_long_text_id
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed_ind = 1
   ELSE
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
      ENDIF
     ENDIF
    ENDIF
    IF (failed_ind=0)
     SELECT INTO "nl:"
      acq.case_query_id
      FROM ap_case_query acq
      WHERE (request->qual[x].case_query_id=acq.case_query_id)
      WITH forupdate(acq)
     ;end select
     IF (curqual != 1)
      SET failed_ind = 1
     ELSE
      UPDATE  FROM ap_case_query acq
       SET acq.status_flag = request->status_flag, acq.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        acq.updt_id = reqinfo->updt_id,
        acq.updt_cnt = (acq.updt_cnt+ 1), acq.updt_task = reqinfo->updt_task, acq.updt_applctx =
        reqinfo->updt_applctx
       WHERE (acq.case_query_id=request->qual[x].case_query_id)
       WITH nocounter
      ;end update
      IF (curqual != 1)
       SET failed_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (failed_ind=0)
    SET number_successful_dels = (number_successful_dels+ 1)
    SET reply->qual[number_successful_dels].case_query_id = request->qual[x].case_query_id
    COMMIT
   ELSE
    SET number_failed_dels = (number_failed_dels+ 1)
    ROLLBACK
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->qual,number_successful_dels)
 IF (number_successful_dels=0)
  SET reply->status_data.status = "Z"
 ELSEIF (number_queries_to_del != number_successful_dels)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
