CREATE PROGRAM cp_load_chart_format:dba
 RECORD reply(
   1 chart_format_id = f8
   1 chart_format_desc = vc
   1 template_loc = vc
   1 abnormal_symbol = vc
   1 corrected_symbol = vc
   1 critical_symbol = vc
   1 high_symbol = vc
   1 interp_data_symbol = vc
   1 low_symbol = vc
   1 new_result_symbol = vc
   1 ref_lab_symbol = vc
   1 review_symbol = vc
   1 sex_age_change_symbol = vc
   1 stat_symbol = vc
   1 ftnotes_symbol = vc
   1 date_mask = vc
   1 time_mask = vc
   1 program_name = vc
   1 document_name = vc
   1 facesheet_sec_id = f8
   1 ftnote_loc_flag = i2
   1 interp_loc_flag = i2
   1 ord_comment_flag = i2
   1 ref_lab_flag = i2
   1 prsnl_ident_flag = i2
   1 page_brk_ind = i2
   1 header_page_ind = i2
   1 repaginate_off_ind = i2
   1 address_page_ind = i2
   1 address_row_nbr = i4
   1 address_col_nbr = i4
   1 address_rotate = i2
   1 blank_page_statement = vc
   1 resubmit_disclaimer = vc
   1 all_sects_have_pgbrks = i2
   1 i_doc_ftr_nbr = i4
   1 i_doc_hdr_nbr = i4
   1 e_doc_ftr_nbr = i4
   1 e_doc_hdr_nbr = i4
   1 left_margin_nbr = i4
   1 right_margin_nbr = i4
   1 chart_section_list[*]
     2 chart_section_id = f8
     2 cs_sequence_num = i4
   1 cf_mm_field_list[*]
     2 cdf_meaning = vc
     2 name = vc
   1 suppress_na_ind = i2
   1 ascii_ind = i2
   1 cf_mm_image_field_list[*]
     2 image_cdf = vc
     2 image_cd = f8
     2 image_disp = c40
     2 image_desc = c60
     2 image_mean = c12
     2 location_ind = i2
   1 preserve_interp_ind = i2
   1 alt_head_foot_text = vc
   1 enhanced_layout_xml = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE seccount = i4 WITH noconstant(0)
 DECLARE all_sects_have_pgbrks = i2 WITH noconstant(1)
 DECLARE mmcount = i4 WITH noconstant(0)
 DECLARE mmimgcount = i4 WITH noconstant(0)
 DECLARE long_text_id = f8 WITH noconstant(0.0)
 DECLARE facesheet_type = i4 WITH constant(36)
 SET status = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cf.chart_format_id, cfs.chart_section_id, cfs_exists_yn = decode(cfs.seq,"Y","N"),
  cs.sect_page_brk_ind
  FROM chart_format cf,
   chart_form_sects cfs,
   chart_section cs,
   long_text_reference ltr
  PLAN (cf
   WHERE (cf.chart_format_id=request->chart_format_id))
   JOIN (cfs
   WHERE cfs.chart_format_id=outerjoin(cf.chart_format_id))
   JOIN (cs
   WHERE cs.chart_section_id=outerjoin(cfs.chart_section_id))
   JOIN (ltr
   WHERE ltr.long_text_id=cf.additional_info_id)
  ORDER BY cfs.cs_sequence_num
  HEAD REPORT
   seccount = 0, reply->chart_format_id = cf.chart_format_id, reply->chart_format_desc = cf
   .chart_format_desc,
   reply->template_loc = cf.template_loc, reply->abnormal_symbol = cf.abnormal_symbol, reply->
   corrected_symbol = cf.corrected_symbol,
   reply->critical_symbol = cf.critical_symbol, reply->high_symbol = cf.high_symbol, reply->
   interp_data_symbol = cf.interp_data_symbol,
   reply->low_symbol = cf.low_symbol, reply->new_result_symbol = cf.new_result_symbol, reply->
   ref_lab_symbol = cf.ref_lab_symbol,
   reply->review_symbol = cf.review_symbol, reply->sex_age_change_symbol = cf.sex_age_change_symbol,
   reply->stat_symbol = cf.stat_symbol,
   reply->ftnotes_symbol = cf.ftnotes_symbol, reply->date_mask = cf.date_mask, reply->time_mask = cf
   .time_mask,
   reply->ftnote_loc_flag = cf.ftnote_loc_flag, reply->interp_loc_flag = cf.interp_loc_flag, reply->
   ord_comment_flag = cf.ord_comment_flag,
   reply->ref_lab_flag = cf.ref_lab_flag, reply->prsnl_ident_flag = cf.prsnl_ident_flag, reply->
   page_brk_ind = cf.page_brk_ind,
   reply->program_name = cf.program_name, reply->document_name = cf.document_name, reply->
   header_page_ind = cf.header_page_ind,
   reply->repaginate_off_ind = cf.repaginate_off_ind, reply->blank_page_statement = cf
   .blank_page_stmt, reply->address_page_ind = cf.address_page_ind,
   reply->address_row_nbr = cf.address_row_nbr, reply->address_col_nbr = cf.address_col_nbr, reply->
   address_rotate = cf.address_rotate_ind,
   long_text_id = cf.resubmit_disclaimer_id, reply->i_doc_ftr_nbr = cf.i_doc_ftr_nbr, reply->
   i_doc_hdr_nbr = cf.i_doc_hdr_nbr,
   reply->e_doc_ftr_nbr = cf.e_doc_ftr_nbr, reply->e_doc_hdr_nbr = cf.e_doc_hdr_nbr, reply->
   left_margin_nbr = cf.left_margin_nbr,
   reply->right_margin_nbr = cf.right_margin_nbr, reply->suppress_na_ind = cf.suppress_na_ind, reply
   ->ascii_ind = cf.ascii_ind,
   reply->preserve_interp_ind = cf.preserve_interp_ind
   IF (ltr.long_text_id > 0.0)
    reply->alt_head_foot_text = ltr.long_text
   ENDIF
  DETAIL
   IF (cfs_exists_yn="Y")
    IF (cs.section_type_flag=facesheet_type)
     reply->facesheet_sec_id = cfs.chart_section_id
    ELSE
     seccount = (seccount+ 1)
     IF (mod(seccount,10)=1)
      stat = alterlist(reply->chart_section_list,(seccount+ 9))
     ENDIF
     IF (all_sects_have_pgbrks=1
      AND cs.sect_page_brk_ind=0)
      all_sects_have_pgbrks = 0
     ENDIF
     reply->chart_section_list[seccount].chart_section_id = cfs.chart_section_id, reply->
     chart_section_list[seccount].cs_sequence_num = cfs.cs_sequence_num
    ENDIF
   ENDIF
   reply->all_sects_have_pgbrks = all_sects_have_pgbrks
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET status = "S"
 ENDIF
 SELECT INTO "nl:"
  cfm.field_seq
  FROM chart_form_mm_flds cfm
  PLAN (cfm
   WHERE (cfm.chart_format_id=request->chart_format_id))
  ORDER BY cfm.field_seq
  HEAD REPORT
   mmcount = 0
  DETAIL
   mmcount = (mmcount+ 1)
   IF (mod(mmcount,10)=1)
    stat = alterlist(reply->cf_mm_field_list,(mmcount+ 9))
   ENDIF
   reply->cf_mm_field_list[mmcount].cdf_meaning = cfm.cdf_meaning, reply->cf_mm_field_list[mmcount].
   name = cfm.field_desc
  WITH nocounter
 ;end select
 IF (long_text_id > 0)
  SELECT INTO "nl:"
   lt.long_text
   FROM long_text lt
   WHERE lt.long_text_id=long_text_id
    AND (lt.parent_entity_id=request->chart_format_id)
   DETAIL
    reply->resubmit_disclaimer = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  cfm.field_seq
  FROM chart_image_mm_flds cfm
  PLAN (cfm
   WHERE (cfm.chart_format_id=request->chart_format_id))
  ORDER BY cfm.field_seq
  HEAD REPORT
   mmimgcount = 0
  DETAIL
   mmimgcount = (mmimgcount+ 1)
   IF (mod(mmimgcount,10)=1)
    stat = alterlist(reply->cf_mm_image_field_list,(mmimgcount+ 9))
   ENDIF
   reply->cf_mm_image_field_list[mmimgcount].image_cdf = cfm.cdf_meaning, reply->
   cf_mm_image_field_list[mmimgcount].image_cd = uar_get_code_by("MEANING",14005,reply->
    cf_mm_image_field_list[mmimgcount].image_cdf), reply->cf_mm_image_field_list[mmimgcount].
   location_ind = cfm.location_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM long_text_reference ltr
  PLAN (ltr
   WHERE (ltr.parent_entity_id=request->chart_format_id)
    AND ltr.parent_entity_name="ChartFormatEnhancedLayoutXML")
  ORDER BY ltr.updt_dt_tm
  DETAIL
   reply->enhanced_layout_xml = ltr.long_text
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->chart_section_list,seccount)
 SET stat = alterlist(reply->cf_mm_field_list,mmcount)
 SET stat = alterlist(reply->cf_mm_image_field_list,mmimgcount)
 SET reply->status_data.status = status
END GO
