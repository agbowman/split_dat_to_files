CREATE PROGRAM bed_rec_emar_dta_ord:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 CALL echo(pharm_at)
 SET ap_at = 0.0
 SET ap_at = uar_get_code_by("MEANING",106,"AP")
 CALL echo(ap_at)
 SET bb_at = 0.0
 SET bb_at = uar_get_code_by("MEANING",106,"BB")
 CALL echo(bb_at)
 SET glb_at = 0.0
 SET glb_at = uar_get_code_by("MEANING",106,"GLB")
 CALL echo(glb_at)
 SET micro_at = 0.0
 SET micro_at = uar_get_code_by("MEANING",106,"MICROBIOLOGY")
 CALL echo(micro_at)
 SELECT INTO "nl:"
  FROM order_catalog oc,
   discrete_task_assay dta
  PLAN (oc
   WHERE trim(oc.primary_mnemonic) > ""
    AND oc.activity_type_cd=pharm_at)
   JOIN (dta
   WHERE dta.mnemonic_key_cap=cnvtupper(oc.primary_mnemonic)
    AND dta.activity_type_cd IN (ap_at, bb_at, glb_at, micro_at))
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
