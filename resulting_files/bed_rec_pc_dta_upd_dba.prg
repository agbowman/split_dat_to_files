CREATE PROGRAM bed_rec_pc_dta_upd:dba
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->run_status_flag = 3
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="KNOWLEDGE INDEX APPLICATIONS"
   AND d.info_name="DTA UPDATE"
  DETAIL
   IF (d.info_number=0)
    reply->run_status_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->run_status_flag = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
