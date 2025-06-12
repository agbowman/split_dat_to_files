CREATE PROGRAM ct_get_billing_grid_xml:dba
 RECORD reply(
   1 list[*]
     2 billing_grid_xml = gvc
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
 SELECT
  l.long_blob, pcb.prot_file_name
  FROM long_blob l,
   prot_crpc_billing pcb
  PLAN (pcb
   WHERE (pcb.prot_master_id=request->prot_id)
    AND pcb.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (l
   WHERE (pcb.prot_rpe_long_blob_id= Outerjoin(l.long_blob_id)) )
  HEAD REPORT
   outbuf = fillstring(30000," "), offset = 0, retlen = 0,
   j = 0
  DETAIL
   j += 1, stat = alterlist(reply->list,j), reply->list[j].file_name = pcb.prot_file_name,
   retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(outbuf,offset,l.long_blob)
     IF (retlen=size(outbuf))
      reply->list[j].billing_grid_xml = notrim(concat(reply->list[j].billing_grid_xml,outbuf))
     ELSEIF (retlen > 0)
      reply->list[j].billing_grid_xml = notrim(concat(reply->list[j].billing_grid_xml,substring(1,
         retlen,outbuf)))
     ENDIF
     offset += retlen
   ENDWHILE
  WITH nocounter, rdbarrayfetch = 1
 ;end select
 SET reply->status_data.status = "S"
 SET last_mod = "000"
 SET mod_date = "May 02, 2017"
END GO
