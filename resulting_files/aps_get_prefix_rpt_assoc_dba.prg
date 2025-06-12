CREATE PROGRAM aps_get_prefix_rpt_assoc:dba
 RECORD reply(
   1 report_qual[5]
     2 catalog_cd = f8
     2 primary_ind = i2
     2 mult_allowed_ind = i2
     2 system_order_ind = i2
     2 reporting_sequence = i4
     2 updt_cnt = i4
     2 mnemonic = vc
     2 dflt_task_assay_cd = f8
     2 dflt_task_assay_disp = c40
     2 report_type_cd = f8
     2 style_qual[*]
       3 catalog_cd = f8
       3 section_flag = i4
       3 font_attrib_flag = i4
       3 font_size = i4
       3 font_name = c32
       3 font_color = i4
       3 updt_cnt = i4
       3 task_assay_cd = f8
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
 SET report_cnt = 0
 SELECT INTO "nl:"
  prr.prefix_id, prr.catalog_cd, prr.updt_dt_tm,
  prr.dflt_diagnostic_task_assay_cd, d.seq, system_order_ind = decode(apat.seq,1,0)
  FROM prefix_report_r prr,
   order_catalog oc,
   (dummyt d  WITH seq = 1),
   ap_prefix_auto_task apat
  PLAN (prr
   WHERE (request->prefix_cd=prr.prefix_id))
   JOIN (oc
   WHERE prr.catalog_cd=oc.catalog_cd)
   JOIN (d
   WHERE 1=d.seq)
   JOIN (apat
   WHERE (request->prefix_cd=apat.prefix_id)
    AND prr.catalog_cd=apat.catalog_cd)
  ORDER BY prr.catalog_cd
  HEAD REPORT
   report_cnt = 0, style_cnt = 0
  HEAD prr.catalog_cd
   style_cnt = 0, proc_cnt = 0, report_cnt = (report_cnt+ 1)
   IF (mod(report_cnt,5)=1
    AND report_cnt != 1)
    stat = alter(reply->report_qual,(report_cnt+ 4))
   ENDIF
   reply->report_qual[report_cnt].catalog_cd = prr.catalog_cd, reply->report_qual[report_cnt].
   primary_ind = prr.primary_ind, reply->report_qual[report_cnt].mult_allowed_ind = prr
   .mult_allowed_ind,
   reply->report_qual[report_cnt].reporting_sequence = prr.reporting_sequence, reply->report_qual[
   report_cnt].system_order_ind = system_order_ind, reply->report_qual[report_cnt].updt_cnt = prr
   .updt_cnt,
   reply->report_qual[report_cnt].mnemonic = oc.primary_mnemonic, reply->report_qual[report_cnt].
   dflt_task_assay_cd = prr.dflt_diagnostic_task_assay_cd, reply->report_qual[report_cnt].
   report_type_cd = prr.report_type_cd
  WITH outerjoin = d, nocounter
 ;end select
 SET stat = alter(reply->report_qual,report_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->report_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET style_cnt = 0
 SELECT INTO "nl:"
  d1.seq, prfi.prefix_id, prfi.section_type_flag
  FROM (dummyt d1  WITH seq = value(report_cnt)),
   prefix_rpt_font_info prfi
  PLAN (d1)
   JOIN (prfi
   WHERE (request->prefix_cd=prfi.prefix_id)
    AND (reply->report_qual[d1.seq].catalog_cd=prfi.catalog_cd))
  ORDER BY prfi.catalog_cd, prfi.section_type_flag
  HEAD prfi.catalog_cd
   style_cnt = 0
  DETAIL
   style_cnt = (style_cnt+ 1), stat = alterlist(reply->report_qual[d1.seq].style_qual,style_cnt),
   reply->report_qual[d1.seq].style_qual[style_cnt].catalog_cd = prfi.catalog_cd,
   reply->report_qual[d1.seq].style_qual[style_cnt].section_flag = prfi.section_type_flag, reply->
   report_qual[d1.seq].style_qual[style_cnt].font_attrib_flag = prfi.font_attribute_flag, reply->
   report_qual[d1.seq].style_qual[style_cnt].font_size = prfi.font_size,
   reply->report_qual[d1.seq].style_qual[style_cnt].font_name = prfi.font_name, reply->report_qual[d1
   .seq].style_qual[style_cnt].font_color = prfi.font_color, reply->report_qual[d1.seq].style_qual[
   style_cnt].updt_cnt = prfi.updt_cnt,
   reply->report_qual[d1.seq].style_qual[style_cnt].task_assay_cd = prfi.task_assay_cd
  WITH nocounter
 ;end select
END GO
