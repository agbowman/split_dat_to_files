CREATE PROGRAM bed_aud_lab_oef
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM code_value cv,
    order_entry_format_parent oefp,
    oe_format_fields off,
    code_value cv2,
    order_entry_fields oefields,
    dm_flags df,
    dm_flags dm,
    oe_field_meaning oe,
    code_value_set cvs,
    code_value cv3
   PLAN (cv
    WHERE cv.code_set=6000
     AND cv.active_ind=1
     AND cv.cdf_meaning="GENERAL LAB")
    JOIN (oefp
    WHERE oefp.catalog_type_cd=cv.code_value)
    JOIN (off
    WHERE off.oe_format_id=oefp.oe_format_id)
    JOIN (df
    WHERE df.table_name="OE_FORMAT_FIELDS"
     AND df.column_name="ACCEPT_FLAG"
     AND df.flag_value=off.accept_flag)
    JOIN (cv2
    WHERE cv2.code_value=off.action_type_cd
     AND cv2.active_ind=1)
    JOIN (oefields
    WHERE oefields.oe_field_id=off.oe_field_id)
    JOIN (cv3
    WHERE cv3.code_value=outerjoin(off.default_parent_entity_id)
     AND cv3.active_ind=outerjoin(1))
    JOIN (dm
    WHERE dm.table_name="ORDER_ENTRY_FIELDS"
     AND dm.column_name="FIELD_TYPE_FLAG"
     AND dm.flag_value=oefields.field_type_flag)
    JOIN (oe
    WHERE oe.oe_field_meaning_id=oefields.oe_field_meaning_id)
    JOIN (cvs
    WHERE cvs.code_set=oefields.codeset)
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1)
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,16)
 SET reply->collist[1].header_text = "Order Entry Format Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Order Action"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Field Label"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Field Meaning"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Field Description"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Default"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Accept Value"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Field Type"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Code Set Associated to Field"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Show on Clinical Display Line?"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Clinical Display Line Label"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Show label as suffix?"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Display Yes/No Values?"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Nurse Review?"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Doctor Cosign?"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Pharmacist Verify?"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 DECLARE codeset = vc
 SELECT INTO "nl:"
  FROM code_value cv,
   order_entry_format_parent oefp,
   oe_format_fields off,
   code_value cv2,
   order_entry_fields oefields,
   dm_flags df,
   dm_flags dm,
   oe_field_meaning oe,
   code_value_set cvs,
   code_value cv3
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.active_ind=1
    AND cv.cdf_meaning="GENERAL LAB")
   JOIN (oefp
   WHERE oefp.catalog_type_cd=cv.code_value)
   JOIN (off
   WHERE off.oe_format_id=oefp.oe_format_id)
   JOIN (df
   WHERE df.table_name="OE_FORMAT_FIELDS"
    AND df.column_name="ACCEPT_FLAG"
    AND df.flag_value=off.accept_flag)
   JOIN (cv2
   WHERE cv2.code_value=off.action_type_cd
    AND cv2.active_ind=1)
   JOIN (oefields
   WHERE oefields.oe_field_id=off.oe_field_id)
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(off.default_parent_entity_id)
    AND cv3.active_ind=outerjoin(1))
   JOIN (dm
   WHERE dm.table_name="ORDER_ENTRY_FIELDS"
    AND dm.column_name="FIELD_TYPE_FLAG"
    AND dm.flag_value=oefields.field_type_flag)
   JOIN (oe
   WHERE oe.oe_field_meaning_id=oefields.oe_field_meaning_id)
   JOIN (cvs
   WHERE cvs.code_set=oefields.codeset)
  ORDER BY oefp.oe_format_name, off.action_type_cd, off.group_seq,
   off.field_seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,250)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,250)=0)
    stat = alterlist(reply->rowlist,(250+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,16), reply->rowlist[cnt].celllist[1].string_value =
   oefp.oe_format_name, reply->rowlist[cnt].celllist[2].string_value = cv2.display,
   reply->rowlist[cnt].celllist[3].string_value = off.label_text, reply->rowlist[cnt].celllist[4].
   string_value = oe.oe_field_meaning, reply->rowlist[cnt].celllist[5].string_value = oefields
   .description
   IF (off.default_value="1")
    reply->rowlist[cnt].celllist[6].string_value = "Yes"
   ELSEIF (off.default_value="0")
    reply->rowlist[cnt].celllist[6].string_value = "No"
   ELSEIF (off.default_parent_entity_name="CODE_VALUE")
    reply->rowlist[cnt].celllist[6].string_value = cv3.display
   ELSE
    reply->rowlist[cnt].celllist[6].string_value = off.default_value
   ENDIF
   reply->rowlist[cnt].celllist[7].string_value = df.description, reply->rowlist[cnt].celllist[8].
   string_value = dm.description
   IF (oefields.codeset > 0)
    reply->rowlist[cnt].celllist[9].string_value = concat(trim(cnvtstring(oefields.codeset))," (",
     trim(cvs.display),")"), reply->rowlist[cnt].celllist[9].double_value = oefields.codeset
   ELSE
    reply->rowlist[cnt].celllist[9].string_value = ""
   ENDIF
   IF (off.clin_line_ind=1)
    reply->rowlist[cnt].celllist[10].string_value = "X"
   ELSE
    reply->rowlist[cnt].celllist[10].string_value = ""
   ENDIF
   reply->rowlist[cnt].celllist[11].string_value = off.clin_line_label
   IF (off.clin_suffix_ind=1)
    reply->rowlist[cnt].celllist[12].string_value = "X"
   ELSE
    reply->rowlist[cnt].celllist[12].string_value = ""
   ENDIF
   IF (off.disp_yes_no_flag=1)
    reply->rowlist[cnt].celllist[13].string_value = "Only Display Yes"
   ELSEIF (off.disp_yes_no_flag=2)
    reply->rowlist[cnt].celllist[13].string_value = "Only Display No"
   ELSEIF (off.disp_yes_no_flag=0)
    reply->rowlist[cnt].celllist[13].string_value = "Both"
   ENDIF
   IF (off.require_review_ind=1)
    reply->rowlist[cnt].celllist[14].string_value = "X"
   ELSE
    reply->rowlist[cnt].celllist[14].string_value = ""
   ENDIF
   IF (off.require_cosign_ind=1)
    reply->rowlist[cnt].celllist[15].string_value = "X"
   ELSE
    reply->rowlist[cnt].celllist[15].string_value = ""
   ENDIF
   IF (off.require_verify_ind=1)
    reply->rowlist[cnt].celllist[16].string_value = "X"
   ELSE
    reply->rowlist[cnt].celllist[16].string_value = ""
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("lab_order_entry_formats.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
