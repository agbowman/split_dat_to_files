CREATE PROGRAM cr_del_report_template:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD long_text_ids(
   1 qual[*]
     2 id = f8
 )
 SET template_cnt = size(request->templates,5)
 SET static_region_cnt = size(request->static_regions,5)
 SET section_cnt = size(request->sections,5)
 SET style_profile_cnt = size(request->style_profiles,5)
 SET legend_cnt = size(request->legends,5)
 SET qual_cnt = 0
 IF (template_cnt > 0)
  SELECT INTO "nl:"
   FROM cr_report_template crt,
    (dummyt d  WITH seq = value(template_cnt))
   PLAN (d)
    JOIN (crt
    WHERE (crt.template_id=request->templates[d.seq].id))
   DETAIL
    qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1)
     stat = alterlist(long_text_ids->qual,(qual_cnt+ 9))
    ENDIF
    long_text_ids->qual[qual_cnt].id = crt.long_text_id
   WITH nocounter
  ;end select
 ENDIF
 IF (static_region_cnt > 0)
  SELECT INTO "nl:"
   FROM cr_report_static_region crsr,
    (dummyt d  WITH seq = value(static_region_cnt))
   PLAN (d)
    JOIN (crsr
    WHERE (crsr.static_region_id=request->static_regions[d.seq].id))
   DETAIL
    qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1)
     stat = alterlist(long_text_ids->qual,(qual_cnt+ 9))
    ENDIF
    long_text_ids->qual[qual_cnt].id = crsr.long_text_id
   WITH nocounter
  ;end select
 ENDIF
 IF (section_cnt > 0)
  SELECT INTO "nl:"
   FROM cr_report_section crs,
    (dummyt d  WITH seq = value(section_cnt))
   PLAN (d)
    JOIN (crs
    WHERE (crs.section_id=request->sections[d.seq].id))
   DETAIL
    qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1)
     stat = alterlist(long_text_ids->qual,(qual_cnt+ 9))
    ENDIF
    long_text_ids->qual[qual_cnt].id = crs.long_text_id
   WITH nocounter
  ;end select
 ENDIF
 IF (style_profile_cnt > 0)
  SELECT INTO "nl:"
   FROM cr_report_style_profile crsp,
    (dummyt d  WITH seq = value(style_profile_cnt))
   PLAN (d)
    JOIN (crsp
    WHERE (crsp.style_profile_id=request->style_profiles[d.seq].id))
   DETAIL
    qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1)
     stat = alterlist(long_text_ids->qual,(qual_cnt+ 9))
    ENDIF
    long_text_ids->qual[qual_cnt].id = crsp.long_text_id
   WITH nocounter
  ;end select
 ENDIF
 IF (legend_cnt > 0)
  SELECT INTO "nl:"
   FROM cr_report_legend crl,
    (dummyt d  WITH seq = value(legend_cnt))
   PLAN (d)
    JOIN (crl
    WHERE (crl.legend_id=request->legends[d.seq].id))
   DETAIL
    qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1)
     stat = alterlist(long_text_ids->qual,(qual_cnt+ 9))
    ENDIF
    long_text_ids->qual[qual_cnt].id = crl.long_text_id
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(long_text_ids->qual,qual_cnt)
 IF (template_cnt > 0)
  DELETE  FROM cr_template_snapshot cts,
    (dummyt d  WITH seq = value(template_cnt))
   SET cts.seq = 1
   PLAN (d)
    JOIN (cts
    WHERE (cts.template_id=request->templates[d.seq].id))
  ;end delete
 ENDIF
 IF (static_region_cnt > 0)
  DELETE  FROM cr_template_snapshot cts,
    (dummyt d  WITH seq = value(static_region_cnt))
   SET cts.seq = 1
   PLAN (d)
    JOIN (cts
    WHERE (cts.static_region_id=request->static_regions[d.seq].id))
  ;end delete
 ENDIF
 IF (section_cnt > 0)
  DELETE  FROM cr_template_snapshot cts,
    (dummyt d  WITH seq = value(section_cnt))
   SET cts.seq = 1
   PLAN (d)
    JOIN (cts
    WHERE (cts.section_id=request->sections[d.seq].id))
  ;end delete
 ENDIF
 IF (template_cnt > 0)
  DELETE  FROM cr_template_publish ctp,
    (dummyt d  WITH seq = value(template_cnt))
   SET ctp.seq = 1
   PLAN (d)
    JOIN (ctp
    WHERE (ctp.template_id=request->templates[d.seq].id))
  ;end delete
  DELETE  FROM cr_template_position_reltn cpos,
    (dummyt d  WITH seq = value(template_cnt))
   SET cpos.seq = 1
   PLAN (d)
    JOIN (cpos
    WHERE (cpos.template_id=request->templates[d.seq].id))
  ;end delete
  DELETE  FROM cr_report_template crt,
    (dummyt d  WITH seq = value(template_cnt))
   SET crt.seq = 1
   PLAN (d)
    JOIN (crt
    WHERE (crt.template_id=request->templates[d.seq].id))
  ;end delete
 ENDIF
 IF (static_region_cnt > 0)
  DELETE  FROM cr_static_region_org_reltn csror,
    (dummyt d  WITH seq = value(static_region_cnt))
   SET csror.seq = 1
   PLAN (d)
    JOIN (csror
    WHERE (csror.static_region_id=request->static_regions[d.seq].id))
  ;end delete
  DELETE  FROM cr_static_region_loc_reltn csrlr,
    (dummyt d  WITH seq = value(static_region_cnt))
   SET csrlr.seq = 1
   PLAN (d)
    JOIN (csrlr
    WHERE (csrlr.static_region_id=request->static_regions[d.seq].id))
  ;end delete
  DELETE  FROM cr_report_static_region crsr,
    (dummyt d  WITH seq = value(static_region_cnt))
   SET crsr.seq = 1
   PLAN (d)
    JOIN (crsr
    WHERE (crsr.static_region_id=request->static_regions[d.seq].id))
  ;end delete
 ENDIF
 IF (section_cnt > 0)
  DELETE  FROM cr_report_section crs,
    (dummyt d  WITH seq = value(section_cnt))
   SET crs.seq = 1
   PLAN (d)
    JOIN (crs
    WHERE (crs.section_id=request->sections[d.seq].id))
  ;end delete
 ENDIF
 IF (style_profile_cnt > 0)
  DELETE  FROM cr_report_style_profile crsp,
    (dummyt d  WITH seq = value(style_profile_cnt))
   SET crsp.seq = 1
   PLAN (d)
    JOIN (crsp
    WHERE (crsp.style_profile_id=request->style_profiles[d.seq].id))
  ;end delete
 ENDIF
 IF (legend_cnt > 0)
  DELETE  FROM cr_report_legend crl,
    (dummyt d  WITH seq = value(legend_cnt))
   SET crl.seq = 1
   PLAN (d)
    JOIN (crl
    WHERE (crl.legend_id=request->legends[d.seq].id))
  ;end delete
 ENDIF
 IF (size(long_text_ids->qual,5) > 0)
  DELETE  FROM long_text_reference ltr,
    (dummyt d  WITH seq = value(size(long_text_ids->qual,5)))
   SET ltr.seq = 1
   PLAN (d)
    JOIN (ltr
    WHERE (ltr.long_text_id=long_text_ids->qual[d.seq].id))
  ;end delete
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
