CREATE PROGRAM bed_ens_rad_acc_pool:dba
 FREE SET reply
 RECORD reply(
   1 accession_assignment_pool_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE activity_type_cd = f8
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET activity_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
   AND cdf_meaning="RADIOLOGY"
  DETAIL
   activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->accession_pool.accession_assignment_pool_id=0))
  SET aap_id = 0.0
  SELECT INTO "NL:"
   j = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    aap_id = cnvtreal(j)
   WITH format, counter
  ;end select
  INSERT  FROM accession_assign_pool ap
   SET ap.accession_assignment_pool_id = aap_id, ap.initial_value = 1.00, ap.reset_frequency = 1.00,
    ap.description = request->accession_pool.description, ap.increment_value = 1.00, ap
    .activity_type_cd = activity_type_cd,
    ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.activity_type_cd = activity_type_cd, ap
    .updt_id = reqinfo->updt_id,
    ap.updt_task = reqinfo->updt_task, ap.updt_cnt = 0, ap.updt_applctx = reqinfo->updt_applctx
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to add accession pool: ",trim(request->accession_pool.
     description)," into the accession_assign_pool table.")
   GO TO exit_script
  ENDIF
  SET reply->accession_assignment_pool_id = aap_id
 ELSE
  SET reply->accession_assignment_pool_id = request->accession_pool.accession_assignment_pool_id
 ENDIF
 INSERT  FROM accession_assign_xref a
  SET a.accession_format_cd = request->accession_format_code_value, a.site_prefix_cd = 0, a
   .accession_assignment_pool_id = reply->accession_assignment_pool_id,
   a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.activity_type_cd = activity_type_cd, a.updt_id =
   reqinfo->updt_id,
   a.updt_task = reqinfo->updt_task, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to add accession pool: ",trim(request->
    accession_pool_description)," with accession format: ",trim(cnvtstring(request->
     accession_format_code_value))," into the accession_assign_xref table.")
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
