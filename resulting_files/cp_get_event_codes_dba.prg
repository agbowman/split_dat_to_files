CREATE PROGRAM cp_get_event_codes:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 chart_format_id = f8
     2 chart_section_id = f8
     2 section_type_flag = i4
     2 ap_history_flag = i2
     2 flex_type_flag = i2
     2 cs_sequence_num = i4
     2 chart_group_id = f8
     2 cg_sequence_num = i4
     2 zone = i4
     2 event_set_name = vc
     2 event_set_seq = i4
     2 order_catalog_cd = f8
     2 procedure_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cfc.event_cd
  FROM chart_format_codes cfc
  WHERE cfc.active_ind=1
  ORDER BY cfc.chart_format_id, cfc.cs_sequence_num, cfc.cg_sequence_num,
   cfc.event_set_name, cfc.event_cd
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].event_cd = cfc.event_cd, reply->qual[count].chart_format_id = cfc
   .chart_format_id, reply->qual[count].chart_section_id = cfc.chart_section_id,
   reply->qual[count].section_type_flag = cfc.section_type_flag, reply->qual[count].ap_history_flag
    = cfc.ap_history_flag, reply->qual[count].flex_type_flag = cfc.flex_type_flag,
   reply->qual[count].cs_sequence_num = cfc.cs_sequence_num, reply->qual[count].chart_group_id = cfc
   .chart_group_id, reply->qual[count].cg_sequence_num = cfc.cg_sequence_num,
   reply->qual[count].zone = cfc.zone, reply->qual[count].event_set_name = cfc.event_set_name, reply
   ->qual[count].event_set_seq = cfc.event_set_seq,
   reply->qual[count].order_catalog_cd = cfc.order_catalog_cd, reply->qual[count].procedure_type_flag
    = cfc.procedure_type_flag
  FOOT REPORT
   stat = alterlist(reply->qual,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
