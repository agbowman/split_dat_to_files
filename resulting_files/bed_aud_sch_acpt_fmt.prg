CREATE PROGRAM bed_aud_sch_acpt_fmt
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
 DECLARE sched_type_cd = f8
 SET stat = alterlist(reply->collist,12)
 SET reply->collist[1].header_text = "Accept Format Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Scheduling Action Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Label Text"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Field Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Field Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Required or Optional"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Code Set Associated to Field"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Default Value"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Last Updated By "
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Last Updated Date"
 SET reply->collist[10].data_type = 4
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "OE_FORMAT_ID "
 SET reply->collist[11].data_type = 2
 SET reply->collist[11].hide_ind = 1
 SET reply->collist[12].header_text = "OE_FIELD_ID"
 SET reply->collist[12].data_type = 2
 SET reply->collist[12].hide_ind = 1
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="SCHEDULING"
  DETAIL
   sched_type_cd = cv.code_value
  WITH noheading, nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_entry_format oef
   PLAN (oef
    WHERE oef.catalog_type_cd=sched_type_cd)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 2000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM order_entry_format oef,
   oe_format_fields off,
   code_value cv,
   order_entry_fields oefields,
   person p
  PLAN (oef
   WHERE oef.catalog_type_cd=sched_type_cd)
   JOIN (cv
   WHERE cv.code_value=oef.action_type_cd
    AND cv.active_ind=1
    AND cv.code_set=14232)
   JOIN (off
   WHERE off.action_type_cd=oef.action_type_cd
    AND off.oe_format_id=oef.oe_format_id)
   JOIN (oefields
   WHERE oefields.oe_field_id=off.oe_field_id)
   JOIN (p
   WHERE p.person_id=outerjoin(off.updt_id)
    AND p.active_ind=outerjoin(1))
  ORDER BY oef.oe_format_name, cv.display, off.group_seq,
   off.field_seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,12), reply->rowlist[cnt].celllist[1].string_value =
   oef.oe_format_name, reply->rowlist[cnt].celllist[2].string_value = cv.display,
   reply->rowlist[cnt].celllist[3].string_value = off.label_text, reply->rowlist[cnt].celllist[4].
   string_value = oefields.description
   CASE (oefields.field_type_flag)
    OF 0:
     reply->rowlist[cnt].celllist[5].string_value = "Free Text"
    OF 1:
     reply->rowlist[cnt].celllist[5].string_value = "Integer"
    OF 2:
     reply->rowlist[cnt].celllist[5].string_value = "Decimal"
    OF 3:
     reply->rowlist[cnt].celllist[5].string_value = "Date"
    OF 5:
     reply->rowlist[cnt].celllist[5].string_value = "Date/Time"
    OF 6:
     reply->rowlist[cnt].celllist[5].string_value = "Codeset"
    OF 7:
     reply->rowlist[cnt].celllist[5].string_value = "Y/N"
    OF 8:
     reply->rowlist[cnt].celllist[5].string_value = "Physician/Provider"
    OF 9:
     reply->rowlist[cnt].celllist[5].string_value = "Location"
    OF 10:
     reply->rowlist[cnt].celllist[5].string_value = "ICD9"
    OF 11:
     reply->rowlist[cnt].celllist[5].string_value = "Printer"
    OF 12:
     reply->rowlist[cnt].celllist[5].string_value = "List"
    OF 13:
     reply->rowlist[cnt].celllist[5].string_value = "User/Personnel"
    OF 14:
     reply->rowlist[cnt].celllist[5].string_value = "Accession"
    OF 15:
     reply->rowlist[cnt].celllist[5].string_value = "Surgical Duration"
    ELSE
     reply->rowlist[cnt].celllist[5].string_value = " "
   ENDCASE
   CASE (off.accept_flag)
    OF 0:
     reply->rowlist[cnt].celllist[6].string_value = "Required"
    OF 1:
     reply->rowlist[cnt].celllist[6].string_value = "Optional"
    OF 2:
     reply->rowlist[cnt].celllist[6].string_value = "No Display"
    OF 3:
     reply->rowlist[cnt].celllist[6].string_value = "Display Only"
   ENDCASE
   CASE (off.default_parent_entity_id)
    OF 0:
     IF (oefields.field_type_flag=7)
      CASE (off.default_value)
       OF "0":
        reply->rowlist[cnt].celllist[8].string_value = "No"
       OF "1":
        reply->rowlist[cnt].celllist[8].string_value = "Yes"
      ENDCASE
     ELSE
      reply->rowlist[cnt].celllist[8].string_value = off.default_value
     ENDIF
   ENDCASE
   IF (off.default_parent_entity_name="CODE_VALUE")
    reply->rowlist[cnt].celllist[7].string_value = cnvtstring(oefields.codeset)
    IF (off.default_parent_entity_id > 0)
     reply->rowlist[cnt].celllist[8].double_value = off.default_parent_entity_id
    ELSEIF (off.default_parent_entity_id=0)
     IF (off.default_value > " ")
      reply->rowlist[cnt].celllist[8].string_value = "<Invalid code value>"
     ENDIF
    ENDIF
   ENDIF
   reply->rowlist[cnt].celllist[9].string_value = p.name_full_formatted, reply->rowlist[cnt].
   celllist[10].date_value = oefields.updt_dt_tm, reply->rowlist[cnt].celllist[11].double_value = oef
   .oe_format_id,
   reply->rowlist[cnt].celllist[12].double_value = off.oe_field_id
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   code_value cv,
   order_entry_fields oefields,
   oe_format_fields off
  PLAN (d
   WHERE (reply->rowlist[d.seq].celllist[8].double_value > 0))
   JOIN (oefields
   WHERE (oefields.description=reply->rowlist[d.seq].celllist[4].string_value)
    AND (cnvtstring(oefields.codeset)=reply->rowlist[d.seq].celllist[7].string_value))
   JOIN (off
   WHERE off.oe_field_id=oefields.oe_field_id
    AND (off.default_parent_entity_id=reply->rowlist[d.seq].celllist[8].double_value)
    AND off.default_parent_entity_name="CODE_VALUE")
   JOIN (cv
   WHERE cv.code_set=oefields.codeset
    AND (cv.code_value=reply->rowlist[d.seq].celllist[8].double_value))
  DETAIL
   reply->rowlist[d.seq].celllist[8].string_value = cv.display
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   code_value cv,
   order_entry_fields oefields,
   oe_format_fields off,
   dummyt d1
  PLAN (d
   WHERE (reply->rowlist[d.seq].celllist[8].double_value > 0))
   JOIN (oefields
   WHERE (oefields.description=reply->rowlist[d.seq].celllist[4].string_value)
    AND (cnvtstring(oefields.codeset)=reply->rowlist[d.seq].celllist[7].string_value))
   JOIN (off
   WHERE off.oe_field_id=oefields.oe_field_id
    AND (off.default_parent_entity_id=reply->rowlist[d.seq].celllist[8].double_value)
    AND off.default_parent_entity_name="CODE_VALUE")
   JOIN (d1)
   JOIN (cv
   WHERE cv.code_set=oefields.codeset
    AND (cv.code_value=reply->rowlist[d.seq].celllist[8].double_value))
  DETAIL
   reply->rowlist[d.seq].celllist[8].string_value = "<Invalid code value>"
  WITH nocounter, noheading, outerjoin = d1,
   dontexist
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   code_value cv,
   oe_format_fields off
  PLAN (d
   WHERE (reply->rowlist[d.seq].celllist[8].double_value > 0))
   JOIN (off
   WHERE (off.default_parent_entity_id=reply->rowlist[d.seq].celllist[8].double_value)
    AND off.default_parent_entity_name="")
   JOIN (cv
   WHERE (cv.code_value=reply->rowlist[d.seq].celllist[8].double_value))
  DETAIL
   reply->rowlist[d.seq].celllist[8].string_value = cv.display, reply->rowlist[d.seq].celllist[8].
   double_value = 0.00
  WITH nocounter, noheading
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("sch_accept_format.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
