CREATE PROGRAM dcp_get_susc_hist
 RECORD reply(
   1 susc_hist_list[*]
     2 event_id = f8
     2 antibiotic_cd = f8
     2 antibiotic_cd_disp = c40
     2 antibiotic_cd_desc = c60
     2 antibiotic_cd_mean = vc
     2 detail_susc_cd = f8
     2 detail_susc_cd_disp = c40
     2 detail_susc_cd_desc = c60
     2 detail_susc_cd_mean = vc
     2 result_cd = f8
     2 result_cd_disp = c40
     2 result_cd_desc = c60
     2 result_cd_mean = vc
     2 result_dt_tm = dq8
     2 result_numeric_value = f8
     2 result_text_value = vc
     2 result_tz = i4
     2 result_unit_cd = f8
     2 result_unit_cd_disp = c40
     2 result_unit_cd_desc = c60
     2 result_unit_cd_mean = vc
     2 suscep_seq_nbr = i4
     2 valid_until_dt_tm = dq8
     2 valid_from_dt_tm = dq8
     2 susceptibility_status_cd = f8
     2 susceptibility_status_disp = c40
     2 susceptibility_status_desc = c60
     2 susceptibility_status_mean = vc
     2 chartable_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 IF ((((request->event_id=0)) OR ((request->event_id=null))) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ce_susceptibility ces
  WHERE (ces.event_id=request->event_id)
   AND (ces.micro_seq_nbr=request->micro_seq_nbr)
   AND (ces.suscep_seq_nbr=request->suscep_seq_nbr)
  ORDER BY ces.valid_from_dt_tm DESC
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->susc_hist_list,5))
    stat = alterlist(reply->susc_hist_list,(count+ 5))
   ENDIF
   reply->susc_hist_list[count].event_id = ces.event_id, reply->susc_hist_list[count].antibiotic_cd
    = ces.antibiotic_cd, reply->susc_hist_list[count].detail_susc_cd = ces.detail_susceptibility_cd,
   reply->susc_hist_list[count].result_cd = ces.result_cd, reply->susc_hist_list[count].
   suscep_seq_nbr = ces.suscep_seq_nbr, reply->susc_hist_list[count].valid_from_dt_tm = ces
   .valid_from_dt_tm,
   reply->susc_hist_list[count].valid_until_dt_tm = ces.valid_until_dt_tm, reply->susc_hist_list[
   count].result_dt_tm = ces.result_dt_tm, reply->susc_hist_list[count].result_numeric_value = ces
   .result_numeric_value,
   reply->susc_hist_list[count].result_text_value = ces.result_text_value, reply->susc_hist_list[
   count].result_tz = ces.result_tz, reply->susc_hist_list[count].result_unit_cd = ces.result_unit_cd,
   reply->susc_hist_list[count].susceptibility_status_cd = ces.susceptibility_status_cd, reply->
   susc_hist_list[count].chartable_flag = ces.chartable_flag
  FOOT REPORT
   stat = alterlist(reply->susc_hist_list,count)
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 SET dcp_script_version = "000 09/01/05 JD5581"
END GO
