CREATE PROGRAM bed_fix_accession_assign_xref
 FREE SET pool_request
 RECORD pool_request(
   1 accession_assign_pool_id = f8
   1 description = vc
   1 initial_value = f8
   1 increment_value = f8
   1 reset_frequency = i4
   1 activity_type_cd = f8
   1 activity_ind = i2
   1 xref_qual[1]
     2 site_prefix_cd = f8
     2 accession_format_cd = f8
 )
 FREE SET pool_reply
 RECORD pool_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE aap_id = f8
 DECLARE aax_found = vc
 SET aap_id = 0.0
 SET aax_found = "N"
 SELECT INTO "nl:"
  FROM accession_assign_pool aap
  PLAN (aap
   WHERE aap.description="JULIAN"
    AND aap.activity_type_cd=0.0
    AND aap.initial_value=1
    AND aap.reset_frequency=0)
  DETAIL
   aap_id = aap.accession_assignment_pool_id
  WITH nocounter
 ;end select
 IF (aap_id=0.0)
  CALL echo(build("Adding rows to accession_assign_pool and accession_assign_xref"))
  SET pool_request->description = "JULIAN"
  SET pool_request->initial_value = 1
  SET pool_request->increment_value = 1
  SET pool_request->reset_frequency = 0
  SET pool_request->activity_type_cd = 0.00
  SET pool_request->activity_ind = 2
  SET pool_request->xref_qual[1].site_prefix_cd = 0
  SET pool_request->xref_qual[1].accession_format_cd = 0.00
  SET trace = recpersist
  EXECUTE pcs_add_acc_pool  WITH replace("REQUEST",pool_request), replace("REPLY",pool_reply)
  CALL echorecord(pool_reply)
 ELSE
  SELECT INTO "nl:"
   FROM accession_assign_xref aax
   PLAN (aax
    WHERE aax.accession_assignment_pool_id=aap_id
     AND aax.accession_format_cd=0.0
     AND aax.activity_type_cd=0.0
     AND aax.site_prefix_cd=0.0)
   DETAIL
    aax_found = "Y"
   WITH nocounter
  ;end select
  IF (aax_found="N")
   CALL echo(build("Adding row to accession_assign_xref"))
   INSERT  FROM accession_assign_xref aax
    SET aax.accession_assignment_pool_id = aap_id, aax.site_prefix_cd = 0, aax.accession_format_cd =
     0.0,
     aax.activity_type_cd = 0.0, aax.updt_dt_tm = cnvtdatetime(curdate,curtime), aax.updt_id = 1,
     aax.updt_task = 1, aax.updt_applctx = 1, aax.updt_cnt = 0
    WITH nocounter
   ;end insert
  ELSE
   CALL echo(build("No rows added - already present in database"))
  ENDIF
 ENDIF
END GO
