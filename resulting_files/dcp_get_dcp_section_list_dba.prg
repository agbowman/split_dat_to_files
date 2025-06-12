CREATE PROGRAM dcp_get_dcp_section_list:dba
 RECORD reply(
   1 sect_cnt = i2
   1 sect_list[*]
     2 dcp_section_ref_id = f8
     2 dcp_section_instance_id = f8
     2 description = vc
     2 definition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  dsr.dcp_section_ref_id
  FROM dcp_section_ref dsr
  PLAN (dsr
   WHERE dsr.dcp_section_ref_id > 0
    AND dsr.active_ind > 0)
  ORDER BY dsr.description
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->sect_list,5))
    stat = alterlist(reply->sect_list,(count1+ 20))
   ENDIF
   reply->sect_list[count1].dcp_section_ref_id = dsr.dcp_section_ref_id, reply->sect_list[count1].
   dcp_section_instance_id = dsr.dcp_section_instance_id, reply->sect_list[count1].description = dsr
   .description,
   reply->sect_list[count1].definition = dsr.definition
  FOOT REPORT
   reply->sect_cnt = count1, stat = alterlist(reply->sect_list,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
