CREATE PROGRAM bbt_get_task_assay_info:dba
 RECORD reply(
   1 assays[*]
     2 task_assay_cd = f8
     2 task_assay_mnemonic = vc
     2 event_cd = f8
     2 default_result_type_cd = f8
     2 default_result_type_disp = vc
     2 default_result_type_mean = c12
     2 data_map_ind = i2
     2 max_digits = i4
     2 min_decimal_places = i4
     2 min_digits = i4
     2 result_entry_format = i4
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = vc
     2 bb_result_processing_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_of_assay = size(request->task_assay_qual,5)
 SET data_map_type_flag = 0
 DECLARE a_cnt = i4
 SELECT INTO "nl:"
  d1.seq, dta.seq, apr.seq,
  d2.seq, data_map_yn = decode(dm.seq,"Y","N"), dm.seq,
  d3.seq, data_map_group_exists = decode(dmg.seq,"Y","N"), dmg.seq
  FROM (dummyt d1  WITH seq = value(number_of_assay)),
   discrete_task_assay dta,
   assay_processing_r apr,
   dummyt d2,
   data_map dm,
   dummyt d3,
   data_map dmg
  PLAN (d1)
   JOIN (dta
   WHERE (dta.task_assay_cd=request->task_assay_qual[d1.seq].task_assay_cd)
    AND dta.active_ind=1
    AND dta.task_assay_cd > 0)
   JOIN (apr
   WHERE (apr.service_resource_cd=request->service_resource_cd)
    AND apr.task_assay_cd=dta.task_assay_cd
    AND apr.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (dm
   WHERE dm.service_resource_cd=apr.service_resource_cd
    AND dm.active_ind=1
    AND dm.task_assay_cd=apr.task_assay_cd
    AND dm.data_map_type_flag=data_map_type_flag)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (dmg
   WHERE dmg.service_resource_cd=0.0
    AND dmg.active_ind=1
    AND dmg.task_assay_cd=apr.task_assay_cd
    AND dmg.data_map_type_flag=data_map_type_flag)
  HEAD REPORT
   stat = alterlist(reply->assays,2), a_cnt = 0
  DETAIL
   a_cnt += 1
   IF (mod(a_cnt,2)=1
    AND a_cnt != 1)
    stat = alterlist(reply->assays,(a_cnt+ 2))
   ENDIF
   reply->assays[a_cnt].task_assay_cd = dta.task_assay_cd, reply->assays[a_cnt].task_assay_mnemonic
    = dta.mnemonic, reply->assays[a_cnt].event_cd = dta.event_cd,
   reply->assays[a_cnt].default_result_type_cd = apr.default_result_type_cd
   IF (data_map_yn="Y")
    reply->assays[a_cnt].data_map_ind = 1, reply->assays[a_cnt].max_digits = dm.max_digits, reply->
    assays[a_cnt].min_decimal_places = dm.min_decimal_places,
    reply->assays[a_cnt].min_digits = dm.min_digits, reply->assays[a_cnt].result_entry_format = dm
    .result_entry_format
   ELSEIF (data_map_group_exists="Y")
    reply->assays[a_cnt].data_map_ind = 1, reply->assays[a_cnt].max_digits = dmg.max_digits, reply->
    assays[a_cnt].min_decimal_places = dmg.min_decimal_places,
    reply->assays[a_cnt].min_digits = dmg.min_digits, reply->assays[a_cnt].result_entry_format = dmg
    .result_entry_format
   ELSE
    reply->assays[a_cnt].data_map_ind = 0
   ENDIF
   reply->assays[a_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
  WITH nocounter, outerjoin = d2, dontcare = dm,
   dontcare = dmg, outerjoin = d3
 ;end select
#resize_reply
 IF (a_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET a_cnt = 1
 ENDIF
 SET stat = alterlist(reply->assays,a_cnt)
END GO
