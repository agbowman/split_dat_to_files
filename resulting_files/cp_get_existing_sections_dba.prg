CREATE PROGRAM cp_get_existing_sections:dba
 RECORD reply(
   1 table_qual = i4
   1 chart_section_list[*]
     2 chart_section_id = f8
     2 chart_section_desc = c32
     2 section_type_flag = i2
     2 chart_format_id = f8
     2 cs_sequence_num = i4
     2 chart_format_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET seccount = 0
 SELECT INTO "nl:"
  cs.chart_section_id, cs.chart_section_desc, cfs.chart_format_id,
  cfs.cs_sequence_num, cf.chart_format_desc, cf.active_ind
  FROM chart_section cs,
   chart_form_sects cfs,
   chart_format cf
  PLAN (cf
   WHERE cf.chart_format_id > 0
    AND cf.active_ind=1)
   JOIN (cfs
   WHERE cfs.chart_format_id=cf.chart_format_id)
   JOIN (cs
   WHERE cs.chart_section_id=cfs.chart_section_id
    AND cs.active_ind=1)
  ORDER BY cs.chart_section_id
  HEAD REPORT
   seccount = 0
  HEAD cs.chart_section_id
   seccount = (seccount+ 1)
   IF (mod(seccount,10)=1)
    stat = alterlist(reply->chart_section_list,(seccount+ 9))
   ENDIF
   reply->chart_section_list[seccount].chart_section_id = cs.chart_section_id, reply->
   chart_section_list[seccount].chart_section_desc = cs.chart_section_desc, reply->
   chart_section_list[seccount].section_type_flag = cs.section_type_flag,
   reply->chart_section_list[seccount].chart_format_id = cfs.chart_format_id, reply->
   chart_section_list[seccount].cs_sequence_num = cfs.cs_sequence_num, reply->chart_section_list[
   seccount].chart_format_desc = cf.chart_format_desc,
   reply->table_qual = seccount
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
