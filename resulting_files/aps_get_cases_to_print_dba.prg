CREATE PROGRAM aps_get_cases_to_print:dba
 RECORD reply(
   1 qual[*]
     2 case_query_id = f8
     2 output_dest_id = f8
     2 output_dest_name = vc
     2 nbr_copies = i2
     2 report_type_flag = i2
     2 search_type_flag = i2
     2 query_start_dt_tm = dq8
     2 started_prsnl_id = f8
     2 status_flag = i2
     2 report_history_grping = f8
     2 result_name = vc
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 param_qual[*]
       3 sequence = i4
       3 param_name = c20
       3 criteria_type_flag = i2
       3 date_type_flag = i2
       3 beg_value_id = f8
       3 beg_value_disp = c40
       3 beg_value_dt_tm = dq8
       3 end_value_id = f8
       3 end_value_disp = c40
       3 end_value_dt_tm = dq8
       3 negation_ind = i2
       3 source_vocabulary_cd = f8
       3 freetext_query_flag = i2
       3 freetext_query = vc
       3 synoptic_query_flag = i2
       3 synoptic_ccl_query = vc
       3 synoptic_xml_query = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET param_cnt = 0
 SET nbr_to_select = 0
 DECLARE ap_activity_type_cd = f8 WITH public, noconstant(0.0)
 SET ap_activity_type_cd = uar_get_code_by("MEANING",106,"AP")
 IF (ap_activity_type_cd <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "uar_get_code_by"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "activity_type_cd"
  GO TO exit_script
 ENDIF
 IF ((request->search_flag=0))
  SET nbr_to_select = 1
 ELSE
  SET nbr_to_select = cnvtint(size(request->qual,5))
 ENDIF
 SELECT
  IF ((request->search_flag=1))
   PLAN (d1)
    JOIN (acq
    WHERE (request->qual[d1.seq].case_query_id=acq.case_query_id))
    JOIN (acqd
    WHERE acq.case_query_id=acqd.case_query_id)
    JOIN (lt
    WHERE acqd.freetext_long_text_id=lt.long_text_id)
    JOIN (lt2
    WHERE acqd.synoptic_ccl_long_text_id=lt2.long_text_id)
    JOIN (lt3
    WHERE acqd.synoptic_xml_long_text_id=lt3.long_text_id)
    JOIN (od
    WHERE acq.output_dest_id=od.output_dest_cd)
  ELSE
   PLAN (d1)
    JOIN (acq
    WHERE acq.status_flag=1
     AND ((acq.activity_type_cd=ap_activity_type_cd) OR (acq.activity_type_cd=0))
     AND (acq.started_prsnl_id=reqinfo->updt_id))
    JOIN (acqd
    WHERE acq.case_query_id=acqd.case_query_id)
    JOIN (lt
    WHERE acqd.freetext_long_text_id=lt.long_text_id)
    JOIN (lt2
    WHERE acqd.synoptic_ccl_long_text_id=lt2.long_text_id)
    JOIN (lt3
    WHERE acqd.synoptic_xml_long_text_id=lt3.long_text_id)
    JOIN (od
    WHERE acq.output_dest_id=od.output_dest_cd)
  ENDIF
  INTO "nl:"
  acq.case_query_id, acqd.case_query_id
  FROM ap_case_query acq,
   ap_case_query_details acqd,
   (dummyt d1  WITH seq = value(nbr_to_select)),
   long_text lt,
   long_text lt2,
   long_text lt3,
   output_dest od
  ORDER BY acq.case_query_id
  HEAD REPORT
   cnt = 0
  HEAD acq.case_query_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   param_cnt = 0, reply->qual[cnt].case_query_id = acq.case_query_id, reply->qual[cnt].output_dest_id
    = acq.output_dest_id,
   reply->qual[cnt].output_dest_name = od.name, reply->qual[cnt].nbr_copies = acq.nbr_copies, reply->
   qual[cnt].report_type_flag = acq.report_type_flag,
   reply->qual[cnt].search_type_flag = acq.search_type_flag, reply->qual[cnt].query_start_dt_tm = acq
   .query_start_dt_tm, reply->qual[cnt].started_prsnl_id = acq.started_prsnl_id,
   reply->qual[cnt].status_flag = acq.status_flag, reply->qual[cnt].report_history_grping = acq
   .report_history_cd, reply->qual[cnt].result_name = acq.result_name,
   reply->qual[cnt].updt_dt_tm = acq.updt_dt_tm, reply->qual[cnt].updt_id = acq.updt_id, reply->qual[
   cnt].updt_cnt = acq.updt_cnt
  DETAIL
   param_cnt += 1
   IF (mod(param_cnt,10)=1)
    stat = alterlist(reply->qual[cnt].param_qual,(param_cnt+ 9))
   ENDIF
   reply->qual[cnt].param_qual[param_cnt].sequence = acqd.sequence, reply->qual[cnt].param_qual[
   param_cnt].param_name = acqd.param_name, reply->qual[cnt].param_qual[param_cnt].criteria_type_flag
    = acqd.criteria_type_flag,
   reply->qual[cnt].param_qual[param_cnt].date_type_flag = acqd.date_type_flag, reply->qual[cnt].
   param_qual[param_cnt].beg_value_id = acqd.beg_value_id, reply->qual[cnt].param_qual[param_cnt].
   beg_value_disp = acqd.beg_value_disp,
   reply->qual[cnt].param_qual[param_cnt].beg_value_dt_tm = acqd.beg_value_dt_tm, reply->qual[cnt].
   param_qual[param_cnt].end_value_id = acqd.end_value_id, reply->qual[cnt].param_qual[param_cnt].
   end_value_disp = acqd.end_value_disp,
   reply->qual[cnt].param_qual[param_cnt].end_value_dt_tm = acqd.end_value_dt_tm, reply->qual[cnt].
   param_qual[param_cnt].negation_ind = acqd.negation_ind, reply->qual[cnt].param_qual[param_cnt].
   source_vocabulary_cd = acqd.source_vocabulary_cd,
   reply->qual[cnt].param_qual[param_cnt].freetext_query_flag = acqd.freetext_query_flag
   IF (acqd.freetext_long_text_id != 0.0)
    reply->qual[cnt].param_qual[param_cnt].freetext_query = lt.long_text
   ENDIF
   reply->qual[cnt].param_qual[param_cnt].synoptic_query_flag = acqd.synoptic_query_flag
   IF (acqd.synoptic_ccl_long_text_id != 0.0
    AND acqd.synoptic_xml_long_text_id != 0.0)
    reply->qual[cnt].param_qual[param_cnt].synoptic_ccl_query = lt2.long_text, reply->qual[cnt].
    param_qual[param_cnt].synoptic_xml_query = lt3.long_text
   ENDIF
  FOOT  acq.case_query_id
   stat = alterlist(reply->qual[cnt].param_qual,param_cnt)
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_QUERY"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
