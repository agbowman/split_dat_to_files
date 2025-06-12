CREATE PROGRAM dcp_del_patient_list:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE patientlistid = f8 WITH noconstant(0.0)
 DECLARE validret = i2 WITH noconstant(0)
 SET validret = validate(request->patient_list_id,1)
 IF (validret=1)
  SELECT INTO "nl:"
   DETAIL
    patientlistid =  $1
   WITH nocounter
  ;end select
 ELSE
  SET patientlistid = request->patient_list_id
 ENDIF
 DELETE  FROM dcp_pl_argument pla
  WHERE pla.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_pl_encntr_filter plef
  WHERE plef.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_pl_reltn plr
  WHERE plr.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_pl_prioritization plp
  WHERE plp.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_pl_custom_entry plce
  WHERE plce.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_pl_query_value plce
  WHERE plce.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_pl_query_list plce
  WHERE plce.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 SELECT INTO nl
  FROM dprotect d
  WHERE d.object="T"
   AND d.object_name="DCP_PL_STATISTICS"
   AND d.group=0
  WITH nocounter
 ;end select
 IF (curqual=1)
  UPDATE  FROM dcp_pl_statistics stat
   SET stat.patient_list_id = 0.0
   WHERE stat.patient_list_id=patientlistid
   WITH nocounter
  ;end update
 ENDIF
 DELETE  FROM dcp_patient_list pl
  WHERE pl.patient_list_id=patientlistid
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
