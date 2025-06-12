CREATE PROGRAM core_get_client:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 client_mnemonic = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
  )
 ENDIF
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="CLIENT MNEMONIC"
  DETAIL
   reply->client_mnemonic = d.info_char
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No client mnemonic found")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(concat("reply->status_data.status: ",reply->status_data.status))
 CALL echo(concat("reply->client_mnemonic: ",reply->client_mnemonic))
END GO
