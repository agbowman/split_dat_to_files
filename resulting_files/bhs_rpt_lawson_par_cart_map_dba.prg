CREATE PROGRAM bhs_rpt_lawson_par_cart_map:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pick Location" = "*",
  "Lawson in Alias" = "*",
  "Email Recipients (Leave blank to display to screen)" = ""
  WITH outdev, s_pick_loc, s_lawson_in_alias,
  s_recipients
 FREE RECORD rec
 RECORD rec(
   1 data[*]
     2 s_surgical_area = vc
     2 s_pick_location = vc
     2 s_lawson_in_alias = vc
     2 s_lawson_out_alias = vc
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 DECLARE ms_file_name = vc WITH protect, constant(build2("lawson_par_cart_mapping_report_",format(
    cnvtdatetime(sysdate),"MMDDYYYYHHMM;;D"),".csv"))
 DECLARE ms_subject = vc WITH protect, constant("Lawson Par Cart Mapping Report")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_pick_loc = vc WITH protect, noconstant(" ")
 DECLARE ms_lawson_in_alias = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_LAWSON_PAR_CART_MAP"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (( $S_PICK_LOC="'*'"))
  SET ms_pick_loc = "1=1"
 ELSEIF (((textlen(trim( $S_PICK_LOC,3))=0) OR (cnvtupper( $S_PICK_LOC)="NULL")) )
  SET ms_lawson_in_alias = "cv.description is NULL"
 ELSE
  SET ms_pick_loc = concat('cv.description = "',trim( $S_PICK_LOC,3),'"')
 ENDIF
 IF (( $S_LAWSON_IN_ALIAS="'*'"))
  SET ms_lawson_in_alias = "1=1"
 ELSEIF (((textlen(trim( $S_LAWSON_IN_ALIAS,3))=0) OR (cnvtupper( $S_LAWSON_IN_ALIAS)="NULL")) )
  SET ms_lawson_in_alias = "cva.alias is NULL"
 ELSE
  SET ms_lawson_in_alias = concat('cva.alias = "',trim( $S_LAWSON_IN_ALIAS,3),'"')
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_alias cva,
   code_value_outbound cvo,
   location_group l
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="INVLOC"
    AND parser(ms_pick_loc))
   JOIN (cva
   WHERE (cva.code_value= Outerjoin(cv.code_value))
    AND parser(ms_lawson_in_alias))
   JOIN (cvo
   WHERE (cvo.code_value= Outerjoin(cv.code_value)) )
   JOIN (l
   WHERE l.child_loc_cd=cv.code_value)
  ORDER BY uar_get_code_display(l.parent_loc_cd), cv.description, cva.alias
  HEAD REPORT
   ml_idx = 0
  DETAIL
   ml_idx += 1
   IF (ml_idx > size(rec->data,5))
    CALL alterlist(rec->data,(ml_idx+ 9))
   ENDIF
   rec->data[ml_idx].s_surgical_area = uar_get_code_display(l.parent_loc_cd), rec->data[ml_idx].
   s_pick_location = cv.description, rec->data[ml_idx].s_lawson_in_alias = cva.alias,
   rec->data[ml_idx].s_lawson_out_alias = cvo.alias
  FOOT REPORT
   stat = alterlist(rec->data,ml_idx)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_program
 ENDIF
 IF (((mn_ops=1) OR (textlen( $S_RECIPIENTS) > 1)) )
  SELECT INTO value(ms_file_name)
   FROM (dummyt d  WITH seq = value(size(rec->data,5)))
   PLAN (d)
   HEAD REPORT
    ms_temp = concat("SURGICAL_AREA,PICK_LOCATION,LAWSON_IN_ALIAS,LAWSON_OUT_ALIAS"), col 0, ms_temp
   DETAIL
    row + 1, ms_temp = build('"',trim(rec->data[d.seq].s_surgical_area),'",','"',trim(rec->data[d.seq
      ].s_pick_location),
     '",','"',trim(rec->data[d.seq].s_lawson_in_alias),'",','"',
     trim(rec->data[d.seq].s_lawson_out_alias),'"'), col 0,
    ms_temp
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 5000
  ;end select
  IF (textlen(trim(ms_recipients,3)) > 0)
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_file_name,ms_file_name,ms_recipients,ms_subject,1)
  ENDIF
 ELSE
  SELECT INTO value( $OUTDEV)
   surgical_area = substring(1,100,rec->data[d.seq].s_surgical_area), pick_location = substring(1,100,
    rec->data[d.seq].s_pick_location), lawson_in_alias = substring(1,100,rec->data[d.seq].
    s_lawson_in_alias),
   lawson_out_alias = substring(1,100,rec->data[d.seq].s_lawson_out_alias)
   FROM (dummyt d  WITH seq = value(size(rec->data,5)))
   PLAN (d)
   ORDER BY surgical_area, pick_location, lawson_in_alias
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_program
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen( $S_RECIPIENTS) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = build2("The report has been sent to: ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)), msg1
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
