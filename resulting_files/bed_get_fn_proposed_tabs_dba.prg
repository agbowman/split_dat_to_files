CREATE PROGRAM bed_get_fn_proposed_tabs:dba
 FREE SET reply
 RECORD reply(
   1 proposed_tabs[*]
     2 list_type = vc
     2 name = vc
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_name_value b
  PLAN (b
   WHERE b.br_nv_key1="FNTRKTAB*"
    AND b.br_nv_key1 != "FNTRKTAB")
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->proposed_tabs,50)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(reply->proposed_tabs,(cnt+ 49))
   ENDIF
   reply->proposed_tabs[cnt].list_type = b.br_name, reply->proposed_tabs[cnt].name = b.br_value,
   reply->proposed_tabs[cnt].sequence = cnvtint(substring(9,2,b.br_nv_key1))
  FOOT REPORT
   stat = alterlist(reply->proposed_tabs,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
