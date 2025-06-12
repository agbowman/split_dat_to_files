CREATE PROGRAM dsm_rpt_cn_order_catalog
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD facility_array
 RECORD facility_array(
   1 qual[*]
     2 code_value = f8
     2 facility = vc
     2 reply_col = i2
   1 over_cnt = c1
 )
 DECLARE dcp_syn_cd = f8
 DECLARE max_facilities = i2
 DECLARE cnt = i2
 DECLARE positions = vc
 SET max_facilities = 51
 SET stat = alterlist(reply->collist,11)
 SET reply->collist[1].header_text = "Catalog Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Activity Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Legal Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Primary Synonym"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Task Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Task Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Task/Form Linked"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Positions to Chart"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Overdue Time"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Alternate Name"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Alternate Name #2"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SELECT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="DCP"
  DETAIL
   dcp_syn_cd = cv.code_value
  WITH noheading, nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    order_catalog oc
   PLAN (cv
    WHERE cv.code_set=6000
     AND cv.active_ind=1
     AND  NOT (cv.cdf_meaning IN ("RADIOLOGY", "PHARMACY", "GENERAL LAB", "SURGERY")))
    JOIN (oc
    WHERE oc.catalog_type_cd=cv.code_value
     AND oc.active_ind=1
     AND oc.orderable_type_flag != 6)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY")
  HEAD REPORT
   cnt = 0, stat = alterlist(facility_array->qual,15), facility_array->over_cnt = "N"
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt=1)
    facility_array->qual[cnt].facility = "All Facilities", facility_array->qual[cnt].code_value =
    0.00, cnt = (cnt+ 1)
   ENDIF
   IF (cnt=max_facilities)
    facility_array->over_cnt = "Y"
   ENDIF
   IF (mod(cnt,15)=0)
    stat = alterlist(facility_array->qual,(15+ cnt))
   ENDIF
   facility_array->qual[cnt].facility = cv.display, facility_array->qual[cnt].code_value = cv
   .code_value
  FOOT REPORT
   stat = alterlist(facility_array->qual,cnt)
  WITH noheading, nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display, cv3.display, oc.description,
  oc.primary_mnemonic, oc.catalog_cd
  FROM code_value cv,
   order_catalog oc,
   order_catalog_synonym ocs,
   code_value cv3
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.active_ind=1
    AND  NOT (cv.cdf_meaning IN ("RADIOLOGY", "PHARMACY", "GENERAL LAB", "SURGERY")))
   JOIN (oc
   WHERE oc.catalog_type_cd=cv.code_value
    AND oc.active_ind=1
    AND oc.orderable_type_flag != 6)
   JOIN (cv3
   WHERE cv3.code_value=oc.activity_type_cd)
   JOIN (ocs
   WHERE ocs.catalog_cd=outerjoin(oc.catalog_cd)
    AND ocs.active_ind=outerjoin(1)
    AND ocs.mnemonic_type_cd=outerjoin(dcp_syn_cd))
  ORDER BY oc.catalog_type_cd, oc.activity_type_cd, oc.primary_mnemonic
  HEAD REPORT
   cnt = 0, synonym_tot = 2, new_size = 11,
   stat = alterlist(reply->rowlist,250)
  HEAD oc.primary_mnemonic
   synonym_cnt = 0, cnt = (cnt+ 1)
   IF (mod(cnt,250))
    stat = alterlist(reply->rowlist,(250+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,new_size), reply->rowlist[cnt].celllist[1].
   string_value = cv.display, reply->rowlist[cnt].celllist[2].string_value = cv3.display,
   reply->rowlist[cnt].celllist[3].string_value = oc.description, reply->rowlist[cnt].celllist[4].
   string_value = oc.primary_mnemonic, reply->rowlist[cnt].celllist[4].double_value = oc.catalog_cd
  DETAIL
   synonym_cnt = (synonym_cnt+ 1)
   CASE (synonym_cnt)
    OF 1:
     reply->rowlist[cnt].celllist[10].string_value = ocs.mnemonic
    OF 2:
     reply->rowlist[cnt].celllist[11].string_value = ocs.mnemonic
    ELSE
     IF (synonym_cnt > 2
      AND synonym_tot < synonym_cnt)
      synonym_tot = synonym_cnt, new_size = (new_size+ 1), stat = alterlist(reply->collist,new_size),
      stat = alterlist(reply->rowlist[cnt].celllist,new_size), reply->collist[new_size].header_text
       = concat("Alternate Name #",cnvtstring(synonym_cnt)), reply->collist[new_size].data_type = 1
     ENDIF
     ,reply->rowlist[cnt].celllist[(9+ synonym_cnt)].string_value = ocs.mnemonic
   ENDCASE
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SELECT INTO "NL:"
  cv_task.display, ot.task_description, dcp.description,
  ot.overdue_min
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   order_task_xref otx,
   order_task ot,
   dummyt d2,
   dcp_forms_ref dcp,
   code_value cv_task
  PLAN (d)
   JOIN (otx
   WHERE (otx.catalog_cd=reply->rowlist[d.seq].celllist[4].double_value))
   JOIN (ot
   WHERE ot.reference_task_id=otx.reference_task_id
    AND ot.task_type_cd != 2668
    AND ot.task_activity_cd=2695
    AND ot.active_ind=1)
   JOIN (cv_task
   WHERE cv_task.code_value=ot.task_type_cd)
   JOIN (d2)
   JOIN (dcp
   WHERE dcp.dcp_forms_ref_id=ot.dcp_forms_ref_id
    AND dcp.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), reply->rowlist[d.seq].celllist[5].string_value = cv_task.display, reply->rowlist[d
   .seq].celllist[6].string_value = ot.task_description,
   reply->rowlist[d.seq].celllist[7].string_value = dcp.description
   CASE (ot.overdue_min)
    OF 0:
     reply->rowlist[d.seq].celllist[9].string_value = ""
    ELSE
     reply->rowlist[d.seq].celllist[9].string_value = cnvtstring(ot.overdue_min)
   ENDCASE
  WITH outerjoin = d, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  cv_position.display
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   order_task_xref otx,
   order_task_position_xref otp,
   code_value cv_position
  PLAN (d)
   JOIN (otx
   WHERE (otx.catalog_cd=reply->rowlist[d.seq].celllist[4].double_value))
   JOIN (otp
   WHERE otp.reference_task_id=otx.reference_task_id)
   JOIN (cv_position
   WHERE cv_position.code_value=otp.position_cd)
  HEAD d.seq
   position_cnt = 0, positions = ""
  DETAIL
   position_cnt = (position_cnt+ 1)
   IF (position_cnt=1)
    positions = cv_position.display
   ELSE
    positions = concat(positions,", ",cv_position.display)
   ENDIF
  FOOT  d.seq
   reply->rowlist[d.seq].celllist[8].string_value = positions
  WITH noheading, nocounter
 ;end select
 SET cur_size = size(reply->collist,5)
 SET stat = alterlist(reply->collist,(10+ cur_size))
 SET reply->collist[(cur_size+ 1)].header_text = "Clinical Category"
 SET reply->collist[(cur_size+ 1)].data_type = 1
 SET reply->collist[(cur_size+ 1)].hide_ind = 0
 SET reply->collist[(cur_size+ 2)].header_text = "Order Entry Format"
 SET reply->collist[(cur_size+ 2)].data_type = 1
 SET reply->collist[(cur_size+ 2)].hide_ind = 0
 SET reply->collist[(cur_size+ 3)].header_text = "Duplicate Checking Level"
 SET reply->collist[(cur_size+ 3)].data_type = 1
 SET reply->collist[(cur_size+ 3)].hide_ind = 0
 SET reply->collist[(cur_size+ 4)].header_text = "Behind Action"
 SET reply->collist[(cur_size+ 4)].data_type = 1
 SET reply->collist[(cur_size+ 4)].hide_ind = 0
 SET reply->collist[(cur_size+ 5)].header_text = "Behind Minutes"
 SET reply->collist[(cur_size+ 5)].data_type = 1
 SET reply->collist[(cur_size+ 5)].hide_ind = 0
 SET reply->collist[(cur_size+ 6)].header_text = "Ahead Action"
 SET reply->collist[(cur_size+ 6)].data_type = 1
 SET reply->collist[(cur_size+ 6)].hide_ind = 0
 SET reply->collist[(cur_size+ 7)].header_text = "Ahead Minutes"
 SET reply->collist[(cur_size+ 7)].data_type = 1
 SET reply->collist[(cur_size+ 7)].hide_ind = 0
 SET reply->collist[(cur_size+ 8)].header_text = "Exact Action"
 SET reply->collist[(cur_size+ 8)].data_type = 1
 SET reply->collist[(cur_size+ 8)].hide_ind = 0
 SET reply->collist[(cur_size+ 9)].header_text = "Nurse Review"
 SET reply->collist[(cur_size+ 9)].data_type = 1
 SET reply->collist[(cur_size+ 9)].hide_ind = 0
 SET reply->collist[(cur_size+ 10)].header_text = "Physician Co-sign"
 SET reply->collist[(cur_size+ 10)].data_type = 1
 SET reply->collist[(cur_size+ 10)].hide_ind = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   order_catalog oc,
   order_entry_format_parent oefp,
   code_value cv,
   dummyt d2,
   dup_checking dc,
   code_value cv_behind,
   code_value cv_ahead,
   code_value cv_exact
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=reply->rowlist[d.seq].celllist[4].double_value))
   JOIN (oefp
   WHERE oefp.oe_format_id=oc.oe_format_id)
   JOIN (cv
   WHERE cv.code_value=oc.dcp_clin_cat_cd)
   JOIN (d2)
   JOIN (dc
   WHERE dc.catalog_cd=oc.catalog_cd
    AND dc.active_ind=1)
   JOIN (cv_behind
   WHERE cv_behind.code_value=dc.min_behind_action_cd)
   JOIN (cv_ahead
   WHERE cv_ahead.code_value=dc.min_ahead_action_cd)
   JOIN (cv_exact
   WHERE cv_exact.code_value=dc.exact_hit_action_cd)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->rowlist[cnt].celllist,(cur_size+ 10)), reply->rowlist[d
   .seq].celllist[(cur_size+ 1)].string_value = cv.display,
   reply->rowlist[d.seq].celllist[(cur_size+ 2)].string_value = oefp.oe_format_name
   IF (dc.catalog_cd > 0)
    CASE (dc.dup_check_seq)
     OF 1:
      reply->rowlist[d.seq].celllist[(cur_size+ 3)].string_value = "Orderable"
     OF 2:
      reply->rowlist[d.seq].celllist[(cur_size+ 3)].string_value = "Catalog Type"
     OF 3:
      reply->rowlist[d.seq].celllist[(cur_size+ 3)].string_value = "Activity Type"
    ENDCASE
    reply->rowlist[d.seq].celllist[(cur_size+ 4)].string_value = cv_behind.display, reply->rowlist[d
    .seq].celllist[(cur_size+ 5)].string_value = cnvtstring(dc.min_behind), reply->rowlist[d.seq].
    celllist[(cur_size+ 6)].string_value = cv_ahead.display,
    reply->rowlist[d.seq].celllist[(cur_size+ 7)].string_value = cnvtstring(dc.min_behind), reply->
    rowlist[d.seq].celllist[(cur_size+ 8)].string_value = cv_exact.display
   ENDIF
  WITH noheading, nocounter, outerjoin = d2
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   order_catalog_review ocr,
   dm_flags df_nurse
  PLAN (d)
   JOIN (ocr
   WHERE (ocr.catalog_cd=reply->rowlist[d.seq].celllist[4].double_value))
   JOIN (df_nurse
   WHERE df_nurse.flag_value=ocr.nurse_review_flag
    AND df_nurse.table_name="ORDER_CATALOG_REVIEW"
    AND df_nurse.column_name="NURSE_REVIEW_FLAG")
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), reply->rowlist[d.seq].celllist[(cur_size+ 9)].string_value = df_nurse.description
  WITH nocounter, noheading
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   order_catalog_review ocr,
   dm_flags df_doctor
  PLAN (d)
   JOIN (ocr
   WHERE (ocr.catalog_cd=reply->rowlist[d.seq].celllist[4].double_value))
   JOIN (df_doctor
   WHERE df_doctor.flag_value=ocr.doctor_cosign_flag
    AND df_doctor.table_name="ORDER_CATALOG_REVIEW"
    AND df_doctor.column_name="DOCTOR_REVIEW_FLAG")
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), reply->rowlist[d.seq].celllist[(cur_size+ 10)].string_value = df_doctor
   .description
  WITH nocounter, noheading
 ;end select
 SET cur_size = size(reply->collist,5)
 IF ((facility_array->over_cnt="Y"))
  SET stat = alterlist(reply->collist,(cur_size+ 2))
  SET reply->collist[(cur_size+ 1)].header_text = "All Facilities"
  SET reply->collist[(cur_size+ 1)].data_type = 1
  SET reply->collist[(cur_size+ 1)].hide_ind = 0
  SET reply->collist[(cur_size+ 2)].header_text = "Additional Facilities"
  SET reply->collist[(cur_size+ 2)].data_type = 1
  SET reply->collist[(cur_size+ 2)].hide_ind = 0
 ELSE
  SET cnt = 0
  SET fac_size = size(facility_array->qual,5)
  SET stat = alterlist(reply->collist,(cur_size+ fac_size))
  WHILE (fac_size > cnt)
    SET cnt = (cnt+ 1)
    SET reply->collist[(cur_size+ cnt)].header_text = facility_array->qual[cnt].facility
    SET reply->collist[(cur_size+ cnt)].data_type = 1
    SET reply->collist[(cur_size+ cnt)].hide_ind = 0
    SET facility_array->qual[cnt].reply_col = (cur_size+ cnt)
  ENDWHILE
 ENDIF
 SELECT INTO "NL:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   order_catalog_synonym ocs,
   ocs_facility_r ofr,
   (dummyt d2  WITH seq = value(size(facility_array->qual,5))),
   dummyt d3
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning="PRIMARY")
   JOIN (d)
   JOIN (ocs
   WHERE ocs.mnemonic_type_cd=cv.code_value
    AND (ocs.catalog_cd=reply->rowlist[d.seq].celllist[4].double_value))
   JOIN (d3)
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id)
   JOIN (d2
   WHERE (ofr.facility_cd=facility_array->qual[d2.seq].code_value))
  HEAD d.seq
   stat = alterlist(reply->rowlist[d.seq].celllist,size(reply->collist,5))
  DETAIL
   IF ((facility_array->over_cnt="Y")
    AND ofr.facility_cd > 0)
    reply->rowlist[d.seq].celllist[(cur_size+ 2)].string_value = "See System for Virtual Views"
   ELSEIF ((facility_array->over_cnt="Y")
    AND ofr.facility_cd=0)
    reply->rowlist[d.seq].celllist[(cur_size+ 1)].string_value = "X"
   ELSEIF (ofr.facility_cd=0
    AND ofr.synonym_id=0)
    reply->rowlist[d.seq].celllist[(cur_size+ 1)].string_value = "No Virtual Views Set"
   ELSE
    reply->rowlist[d.seq].celllist[facility_array->qual[d2.seq].reply_col].string_value = "X"
   ENDIF
  WITH noheading, nocounter, outerjoin = d3
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("carenet_order_catalog.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 DECLARE excel_cnt = i4
 DECLARE excel_list = i4
 DECLARE header_line = vc
 DECLARE row_line = vc
 DECLARE file_name = vc
 SET file_name = build(curprog,"_",curdate)
 CALL echo("Creating File")
 SET excel_cnt = 0
 SET excel_list = size(reply->collist,5)
 WHILE (excel_cnt < excel_list)
  SET excel_cnt = (excel_cnt+ 1)
  IF (excel_cnt=1)
   SET header_line = reply->collist[excel_cnt].header_text
  ELSE
   SET header_line = concat(header_line,",",reply->collist[excel_cnt].header_text)
  ENDIF
 ENDWHILE
 SELECT INTO value(file_name)
  header_line
  FROM dummyt d
  WITH noheading, nocounter
 ;end select
 SET excel_cnt = 0
 SET excel_list = size(reply->rowlist,5)
 WHILE (excel_cnt < excel_list)
   SET excel_cnt = (excel_cnt+ 1)
   SET int_cnt = 0
   SET int_list = size(reply->rowlist[excel_cnt].celllist,5)
   WHILE (int_cnt < int_list)
    SET int_cnt = (int_cnt+ 1)
    IF (int_cnt=1)
     CASE (reply->collist[int_cnt].data_type)
      OF 1:
       SET row_line = concat('"',reply->rowlist[excel_cnt].celllist[int_cnt].string_value,'"')
      OF 2:
       SET row_line = concat('"',cnvtstring(reply->rowlist[excel_cnt].celllist[int_cnt].double_value),
        '"')
      OF 3:
       SET row_line = concat('"',cnvtstring(reply->rowlist[excel_cnt].celllist[int_cnt].nbr_value),
        '"')
      OF 4:
       SET row_line = concat('"',cnvtstring(reply->rowlist[excel_cnt].celllist[int_cnt].date_value),
        '"')
      ELSE
       SET row_line = '""'
     ENDCASE
    ELSE
     CASE (reply->collist[int_cnt].data_type)
      OF 1:
       SET row_line = concat(row_line,",",'"',reply->rowlist[excel_cnt].celllist[int_cnt].
        string_value,'"')
      OF 2:
       SET row_line = concat(row_line,",",'"',cnvtstring(reply->rowlist[excel_cnt].celllist[int_cnt].
         double_value),'"')
      OF 3:
       SET row_line = concat(row_line,",",'"',cnvtstring(reply->rowlist[excel_cnt].celllist[int_cnt].
         nbr_value),'"')
      OF 4:
       SET row_line = concat(row_line,",",'"',cnvtstring(reply->rowlist[excel_cnt].celllist[int_cnt].
         date_value),'"')
      ELSE
       SET row_line = concat(row_line,',""')
     ENDCASE
    ENDIF
   ENDWHILE
   IF (row_line != "")
    SELECT INTO value(file_name)
     row_line
     FROM dummyt d
     WITH noheading, nocounter, append,
      maxrow = 1
    ;end select
   ENDIF
   SET row_line = ""
 ENDWHILE
END GO
