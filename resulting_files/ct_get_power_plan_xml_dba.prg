CREATE PROGRAM ct_get_power_plan_xml:dba
 RECORD reply(
   1 list[*]
     2 power_plan_xml = gvc
     2 file_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET length = size(request->kcw_id,5)
 SET i = 0
 SELECT
  l.long_blob, pcb.prot_file_name
  FROM long_blob l,
   prot_crpc_billing pcb
  PLAN (pcb)
   JOIN (l
   WHERE pcb.prot_kcw_long_blob_id=l.long_blob_id
    AND pcb.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND expand(i,1,length,l.long_blob_id,request->kcw_id[i].id))
  HEAD REPORT
   outbuf = fillstring(32000," "), offset = 0, retlen = 0,
   j = 0
  DETAIL
   j += 1, outbuf = fillstring(32000," "), offset = 0,
   retlen = 0, stat = alterlist(reply->list,j), reply->list[j].file_name = pcb.prot_file_name,
   retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(outbuf,offset,l.long_blob)
     IF (retlen=size(outbuf))
      reply->list[j].power_plan_xml = notrim(concat(reply->list[j].power_plan_xml,outbuf))
     ELSEIF (retlen > 0)
      reply->list[j].power_plan_xml = notrim(concat(reply->list[j].power_plan_xml,substring(1,retlen,
         outbuf)))
     ENDIF
     offset += retlen
   ENDWHILE
  WITH nocounter, rdbarrayfetch = 1
 ;end select
 SET reply->status_data.status = "S"
 SET last_mod = "001"
 SET mod_date = "June 22, 2017"
END GO
