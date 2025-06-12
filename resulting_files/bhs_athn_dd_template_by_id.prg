CREATE PROGRAM bhs_athn_dd_template_by_id
 RECORD out_rec(
   1 template_title = vc
   1 template_id = vc
   1 template_contents = vc
   1 emr_content[*]
     2 content_title = vc
     2 emr_content_type = vc
     2 format_id = vc
     2 format = vc
     2 filter_id = vc
     2 filter = vc
 )
 SELECT INTO "nl:"
  FROM dd_ref_template drt,
   long_blob_reference lbr,
   dd_ref_template_content_r drtcr,
   dd_ref_emr_content drec
  PLAN (drt
   WHERE (drt.dd_ref_template_id= $2))
   JOIN (lbr
   WHERE lbr.parent_entity_id=drt.dd_ref_template_id
    AND lbr.active_ind=1)
   JOIN (drtcr
   WHERE drtcr.dd_ref_template_id=outerjoin(drt.dd_ref_template_id))
   JOIN (drec
   WHERE drec.dd_ref_emr_content_id=outerjoin(drtcr.dd_ref_emr_content_id)
    AND drec.active_ind=outerjoin(1))
  ORDER BY drec.title_txt
  HEAD REPORT
   out_rec->template_title = drt.title_txt, out_rec->template_id = cnvtstring(drt.dd_ref_template_id),
   out_rec->template_contents = lbr.long_blob,
   cnt = 0
  HEAD drec.title_txt
   cnt = (cnt+ 1), stat = alterlist(out_rec->emr_content,cnt), out_rec->emr_content[cnt].
   content_title = drec.title_txt,
   out_rec->emr_content[cnt].emr_content_type = uar_get_code_meaning(drec.emr_content_type_cd),
   out_rec->emr_content[cnt].format_id = cnvtstring(drec.dd_ref_format_id), out_rec->emr_content[cnt]
   .filter_id = cnvtstring(drec.dd_ref_filter_id)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->emr_content,5)),
   long_blob_reference lbr
  PLAN (d)
   JOIN (lbr
   WHERE lbr.parent_entity_id=cnvtreal(out_rec->emr_content[d.seq].format_id)
    AND lbr.parent_entity_id != 0)
  DETAIL
   out_rec->emr_content[d.seq].format = lbr.long_blob
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->emr_content,5)),
   long_blob_reference lbr
  PLAN (d)
   JOIN (lbr
   WHERE lbr.parent_entity_id=cnvtreal(out_rec->emr_content[d.seq].filter_id)
    AND lbr.parent_entity_id != 0)
  DETAIL
   out_rec->emr_content[d.seq].filter = lbr.long_blob
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
