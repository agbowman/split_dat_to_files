CREATE PROGRAM dcp_does_io_2g_exist:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 table_exists = i2
    1 data_exists = i2
    1 data_conversion = i2
    1 force_old = i2
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
 SET reply->data_conversion = false
 SET reply->table_exists = false
 SET reply->data_exists = false
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="IO2G CONVERSION DATA FLAG"
   AND di.info_char="READ USING IO DATA MODEL AND WRITE USING I&O2G DATA MODEL"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->data_conversion = true
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="IO DATA FLAG"
   AND di.info_char="USING ORIGINAL IO DATA MODEL"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->force_old = true
  GO TO exit_program
 ENDIF
 IF (checkdic("CE_INTAKE_OUTPUT_RESULT","T",0)=2)
  SET reply->table_exists = true
  SET reply->force_old = false
  IF ((reply->data_conversion=true))
   GO TO exit_program
  ELSE
   SET reply->data_conversion = false
  ENDIF
  SELECT INTO "nl:"
   cir.ce_io_result_id
   FROM ce_intake_output_result cir
   WHERE cir.ce_io_result_id > 0.0
   DETAIL
    reply->data_exists = true
   WITH nocounter, maxrec = 1
  ;end select
 ENDIF
#exit_program
 SET reply->status_data.status = "S"
END GO
