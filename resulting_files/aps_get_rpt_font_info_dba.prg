CREATE PROGRAM aps_get_rpt_font_info:dba
 RECORD reply(
   1 style_qual[*]
     2 section_flag = i4
     2 font_attrib_flag = i4
     2 font_size = i4
     2 font_name = c32
     2 font_color = i4
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET style_cnt = 0
 SELECT INTO "nl:"
  prfi.prefix_id, prfi.catalog_cd, prfi.section_type_flag
  FROM prefix_rpt_font_info prfi
  PLAN (prfi
   WHERE (request->prefix_cd=prfi.prefix_id)
    AND (request->catalog_cd=prfi.catalog_cd))
  ORDER BY prfi.prefix_id, prfi.catalog_cd, prfi.section_type_flag
  HEAD REPORT
   style_cnt = 0
  DETAIL
   style_cnt = (style_cnt+ 1), stat = alterlist(reply->style_qual,style_cnt), reply->style_qual[
   style_cnt].section_flag = prfi.section_type_flag,
   reply->style_qual[style_cnt].font_attrib_flag = prfi.font_attribute_flag, reply->style_qual[
   style_cnt].font_size = prfi.font_size, reply->style_qual[style_cnt].font_name = prfi.font_name,
   reply->style_qual[style_cnt].font_color = prfi.font_color, reply->style_qual[style_cnt].
   task_assay_cd = prfi.task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->style_qual,style_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->style_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
