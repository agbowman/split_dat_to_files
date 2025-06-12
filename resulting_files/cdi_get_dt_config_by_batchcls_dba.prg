CREATE PROGRAM cdi_get_dt_config_by_batchcls:dba
 RECORD reply(
   1 document_type_list[*]
     2 event_cd = f8
     2 cdi_document_type_id = f8
     2 cdi_ac_batchclass_id = f8
     2 combine_ind = i2
     2 max_page_cnt = i4
     2 delete_first_ind = i2
     2 updt_cnt = i4
     2 combine_all_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE batchclass_count = i4 WITH noconstant(value(size(request->batchclass_list,5))), protect
 DECLARE n = i4 WITH noconstant(0), protect
 SET i = 0
 SET count1 = 0
 SET detail_count = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cdt.cdi_ac_batchclass_id, cdt.cdi_document_type_id, cdt.event_cd,
  cdt.combine_ind, cdt.combine_all_ind, cdt.max_page_cnt,
  cdt.delete_first_ind, cdt.updt_cnt
  FROM cdi_document_type cdt
  WHERE cdt.event_cd > 0
   AND ((expand(n,1,batchclass_count,cdt.cdi_ac_batchclass_id,request->batchclass_list[n].
   cdi_ac_batchclass_id)) OR (cdt.cdi_ac_batchclass_id=0))
  ORDER BY cdt.event_cd, cdt.cdi_ac_batchclass_id DESC
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->document_type_list,10)
  HEAD cdt.event_cd
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->document_type_list,(count1+ 9))
   ENDIF
   reply->document_type_list[count1].event_cd = cdt.event_cd, reply->document_type_list[count1].
   cdi_document_type_id = cdt.cdi_document_type_id, reply->document_type_list[count1].
   cdi_ac_batchclass_id = cdt.cdi_ac_batchclass_id,
   reply->document_type_list[count1].combine_ind = cdt.combine_ind, reply->document_type_list[count1]
   .combine_all_ind = cdt.combine_all_ind, reply->document_type_list[count1].max_page_cnt = cdt
   .max_page_cnt,
   reply->document_type_list[count1].delete_first_ind = cdt.delete_first_ind, reply->
   document_type_list[count1].updt_cnt = cdt.updt_cnt
  DETAIL
   detail_count = (detail_count+ 1)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->document_type_list,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
