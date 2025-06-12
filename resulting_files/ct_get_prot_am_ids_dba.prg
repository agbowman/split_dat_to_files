CREATE PROGRAM ct_get_prot_am_ids:dba
 RECORD reply(
   1 prot_id = f8
   1 amd_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET counter = 0
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE (pm.primary_mnemonic=request->prot_mne)
  DETAIL
   reply->prot_id = pm.prot_master_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  CALL echo("no such protocol mnemonic")
  GO TO exit_script
 ENDIF
 CALL echo(build("the prot id is ",reply->prot_id))
 SELECT INTO "nl:"
  FROM prot_amendment pa
  WHERE (pa.amendment_nbr=request->amd_nbr)
   AND (pa.prot_master_id=reply->prot_id)
  DETAIL
   reply->amd_id = pa.prot_amendment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  CALL echo("no such amendment number")
  GO TO exit_script
 ENDIF
 CALL echo(build("the amd id is ",reply->amd_id))
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
END GO
