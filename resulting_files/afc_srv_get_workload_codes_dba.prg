CREATE PROGRAM afc_srv_get_workload_codes:dba
 RECORD reply(
   1 standard_qual = i2
   1 standards[*]
     2 workload_standard_id = f8
     2 description = c200
     2 department_cd = f8
     2 code_sched_cd = f8
     2 code_format = i4
     2 bill_code_ind = i2
     2 code_qual = i2
     2 codes[*]
       3 workload_code_id = f8
       3 workload_standard_id = f8
       3 nomen_id = f8
       3 event_cd = f8
       3 code = c50
       3 interval_template_cd = f8
       3 item_for_count_cd = f8
       3 units = f8
       3 multiplier = i4
       3 labor_type = i4
       3 description = c200
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET std_count = 0
 SET cd_count = 0
 SELECT
  IF ((request->workload_standard_id > 0)
   AND (request->workload_code_id <= 0))
   PLAN (ws
    WHERE (ws.workload_standard_id=request->workload_standard_id)
     AND ws.active_ind=1)
    JOIN (wc
    WHERE wc.workload_standard_id=ws.workload_standard_id
     AND wc.active_ind=1
     AND cnvtdatetime(curdate,curtime) BETWEEN wc.beg_effective_dt_tm AND wc.end_effective_dt_tm)
  ELSEIF ((request->workload_standard_id > 0)
   AND (request->workload_code_id > 0))
   PLAN (ws
    WHERE (ws.workload_standard_id=request->workload_standard_id)
     AND ws.active_ind=1)
    JOIN (wc
    WHERE wc.workload_standard_id=ws.workload_standard_id
     AND wc.active_ind=1
     AND (wc.workload_code_id=request->workload_code_id)
     AND cnvtdatetime(curdate,curtime) BETWEEN wc.beg_effective_dt_tm AND wc.end_effective_dt_tm)
  ELSE
   PLAN (ws
    WHERE ws.active_ind=1)
    JOIN (wc
    WHERE wc.workload_standard_id=ws.workload_standard_id
     AND wc.active_ind=1
     AND cnvtdatetime(curdate,curtime) BETWEEN wc.beg_effective_dt_tm AND wc.end_effective_dt_tm)
  ENDIF
  INTO "nl:"
  ws.workload_standard_id, ws.department_cd, ws.description,
  ws.code_sched_cd, ws.code_format, ws.bill_code_ind,
  wc.workload_code_id, wc.workload_standard_id, wc.nomen_id,
  wc.event_cd, wc.code, wc.interval_template_cd,
  wc.item_for_count_cd, wc.units, wc.multiplier,
  wc.labor_type, wc.description
  FROM workload_standard ws,
   workload_code wc
  PLAN (ws
   WHERE ws.active_ind=1)
   JOIN (wc
   WHERE wc.workload_standard_id=ws.workload_standard_id
    AND wc.active_ind=1)
  ORDER BY ws.workload_standard_id, wc.workload_code_id
  HEAD ws.workload_standard_id
   std_count += 1, stat = alterlist(reply->standards,std_count), reply->standards[std_count].
   workload_standard_id = ws.workload_standard_id,
   reply->standards[std_count].description = ws.description, reply->standards[std_count].
   department_cd = ws.department_cd, reply->standards[std_count].code_sched_cd = ws.code_sched_cd,
   reply->standards[std_count].code_format = ws.code_format, reply->standards[std_count].
   bill_code_ind = ws.bill_code_ind,
   CALL echo(build("standard_id ",reply->standards[std_count].workload_standard_id))
  DETAIL
   cd_count += 1, stat = alterlist(reply->standards[std_count].codes,cd_count), reply->standards[
   std_count].codes[cd_count].workload_code_id = wc.workload_code_id,
   reply->standards[std_count].codes[cd_count].workload_standard_id = wc.workload_standard_id, reply
   ->standards[std_count].codes[cd_count].nomen_id = wc.nomen_id, reply->standards[std_count].codes[
   cd_count].event_cd = wc.event_cd,
   reply->standards[std_count].codes[cd_count].code = wc.code, reply->standards[std_count].codes[
   cd_count].interval_template_cd = wc.interval_template_cd, reply->standards[std_count].codes[
   cd_count].item_for_count_cd = wc.item_for_count_cd,
   reply->standards[std_count].codes[cd_count].units = wc.units, reply->standards[std_count].codes[
   cd_count].multiplier = wc.multiplier, reply->standards[std_count].codes[cd_count].labor_type = wc
   .labor_type,
   reply->standards[std_count].codes[cd_count].description = wc.description, reply->standards[
   std_count].code_qual = cd_count,
   CALL echo(build("	code id: ",wc.workload_code_id," code: ",wc.code))
  WITH nocounter
 ;end select
 SET reply->standard_qual = std_count
 CALL echo(build("standard_qual: ",reply->standard_qual))
 CALL echo(build("	code_qual: ",reply->standards[1].code_qual))
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
