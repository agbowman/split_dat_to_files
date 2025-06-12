CREATE PROGRAM bed_get_logical_domains:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 logical_domain[*]
      2 logical_domain_id = f8
      2 description = vc
      2 mnemonic = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 DECLARE reply_index = i4
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM logical_domain ld
  PLAN (ld
   WHERE ld.active_ind=1)
  HEAD REPORT
   reply_index = 0, stat = alterlist(reply->logical_domain,10)
  DETAIL
   reply_index = (reply_index+ 1)
   IF (mod(reply_index,10)=0)
    stat = alterlist(reply->logical_domain,(reply_index+ 10))
   ENDIF
   reply->logical_domain[reply_index].description = ld.description, reply->logical_domain[reply_index
   ].logical_domain_id = ld.logical_domain_id, reply->logical_domain[reply_index].mnemonic = ld
   .mnemonic
  FOOT REPORT
   stat = alterlist(reply->logical_domain,reply_index)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
