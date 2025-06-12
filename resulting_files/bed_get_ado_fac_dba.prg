CREATE PROGRAM bed_get_ado_fac:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facility[*]
      2 fac_code_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_ado_detail adod
  PLAN (adod)
  ORDER BY adod.facility_cd
  HEAD adod.facility_cd
   cnt = (cnt+ 1), stat = alterlist(reply->facility,cnt), reply->facility[cnt].fac_code_value = adod
   .facility_cd
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
