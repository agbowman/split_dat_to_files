CREATE PROGRAM cdi_add_license_usage_data:dba
 FREE RECORD reply
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE license_rows = i4 WITH noconstant(value(size(request->details,5))), protect
 SET reply->status_data.status = "F"
 INSERT  FROM (dummyt d  WITH seq = license_rows),
   cdi_axlic_usage s
  SET s.cdi_axlic_usage_id = seq(cdi_seq,nextval), s.license_dt_tm = cnvtdatetime(request->details[d
    .seq].license_dt_tm), s.license_type_flag = request->details[d.seq].license_type_flag,
   s.license_group_nm = request->details[d.seq].license_group, s.total_licenses_nbr = request->
   details[d.seq].total_licenses, s.licenses_in_use_nbr = request->details[d.seq].licenses_in_use,
   s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (s)
  WITH nocounter
 ;end insert
 IF (curqual != license_rows)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
