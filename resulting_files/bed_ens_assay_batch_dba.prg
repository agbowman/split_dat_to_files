CREATE PROGRAM bed_ens_assay_batch:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assay_list[*]
      2 code_value = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE bed_ens_assay  WITH replace("REQUEST",request), replace("REPLY",reply)
END GO
