CREATE PROGRAM bed_get_mos_oe_fields:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 oe_formats[*]
      2 oe_format_id = f8
      2 fields[*]
        3 oe_field_id = f8
        3 oe_field_label = vc
        3 oe_field_meaning = vc
        3 default_disp_value = vc
        3 default_code_value = f8
        3 group_seq = i4
        3 field_seq = i4
        3 codeset = i4
        3 field_type_flag = i2
        3 clin_line_label = vc
        3 label_text = vc
        3 clin_suffix_ind = i2
        3 clin_line_ind = i2
        3 codes[*]
          4 value = f8
          4 display = vc
        3 decimal_places = i4
        3 disp_yes_no_flag = i2
        3 required_ind = i2
        3 accept_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE frequency_codeset = i4 WITH protect, constant(4003)
 DECLARE pharm_ct = f8 WITH protect
 DECLARE pharm_at = f8 WITH protect
 DECLARE order_cd = f8 WITH protect
 DECLARE lab_share = f8 WITH protect
 DECLARE rx_share = f8 WITH protect
 DECLARE req_cnt = i4 WITH protect
 DECLARE tcnt = i4 WITH protect
 DECLARE oe_code_value = f8 WITH protect
 DECLARE system_code_value = f8 WITH protect
 DECLARE inpatient_code_value = f8 WITH protect
 DECLARE field_cd = f8 WITH protect
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET order_cd = 0.0
 IF ((request->usage_flag=2))
  SET order_cd = uar_get_code_by("MEANING",6003,"DISORDER")
 ELSE
  SET order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 ENDIF
 SET field_cd = uar_get_code_by("DISPLAYKEY",16449,"RECEIVINGMEDICALLYRESPONSIBLECAREUNI")
 SET tcnt = 0
 SET lab_share = 0
 SET rx_share = 0
 RECORD temp(
   1 oe_formats[*]
     2 qual[*]
       3 filter = i2
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6000
    AND c.cdf_meaning IN ("GENERAL LAB", "PHARMACY"))
  DETAIL
   IF (c.cdf_meaning="GENERAL LAB")
    IF (c.definition="cer_exe:lab_shrorder")
     lab_share = 1
    ENDIF
   ENDIF
   IF (c.cdf_meaning="PHARMACY")
    IF (c.definition="cer_exe:rx_shrorder")
     rx_share = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET req_cnt = size(request->oe_formats,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->oe_formats,req_cnt)
 SET stat = alterlist(temp->oe_formats,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->oe_formats[x].oe_format_id = request->oe_formats[x].oe_format_id
 ENDFOR
 IF ((request->do_not_display_ind=0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    oe_format_fields off,
    order_entry_fields oef,
    oe_field_meaning oe
   PLAN (d)
    JOIN (off
    WHERE (off.oe_format_id=request->oe_formats[d.seq].oe_format_id)
     AND off.action_type_cd=order_cd
     AND off.accept_flag IN (0, 1, 3))
    JOIN (oef
    WHERE oef.oe_field_id=off.oe_field_id
     AND oef.oe_field_id != field_cd)
    JOIN (oe
    WHERE oe.oe_field_meaning_id=oef.oe_field_meaning_id)
   ORDER BY d.seq, off.group_seq, off.field_seq
   HEAD d.seq
    cnt = 0, tcnt = 0, stat = alterlist(reply->oe_formats[d.seq].fields,10),
    stat = alterlist(temp->oe_formats[d.seq].qual,10)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->oe_formats[d.seq].fields,(tcnt+ 10)), stat = alterlist(temp->oe_formats[
      d.seq].qual,(tcnt+ 10)), cnt = 1
    ENDIF
    reply->oe_formats[d.seq].fields[tcnt].oe_field_id = off.oe_field_id, reply->oe_formats[d.seq].
    fields[tcnt].oe_field_label = off.label_text, reply->oe_formats[d.seq].fields[tcnt].
    default_disp_value = off.default_value,
    reply->oe_formats[d.seq].fields[tcnt].group_seq = off.group_seq, reply->oe_formats[d.seq].fields[
    tcnt].field_seq = off.field_seq, reply->oe_formats[d.seq].fields[tcnt].codeset = oef.codeset,
    reply->oe_formats[d.seq].fields[tcnt].field_type_flag = oef.field_type_flag, reply->oe_formats[d
    .seq].fields[tcnt].oe_field_meaning = oe.oe_field_meaning, reply->oe_formats[d.seq].fields[tcnt].
    clin_line_label = off.clin_line_label,
    reply->oe_formats[d.seq].fields[tcnt].clin_suffix_ind = off.clin_suffix_ind, reply->oe_formats[d
    .seq].fields[tcnt].label_text = off.label_text, reply->oe_formats[d.seq].fields[tcnt].
    clin_line_ind = off.clin_line_ind,
    reply->oe_formats[d.seq].fields[tcnt].accept_flag = off.accept_flag
    IF (off.filter_params IN ("ORDERABLE", "CATALOG TYPE", "ACTIVITY TYPE"))
     temp->oe_formats[d.seq].qual[tcnt].filter = 1
    ELSE
     temp->oe_formats[d.seq].qual[tcnt].filter = 0
    ENDIF
    reply->oe_formats[d.seq].fields[tcnt].decimal_places = cnvtint(trim(off.input_mask)), reply->
    oe_formats[d.seq].fields[tcnt].disp_yes_no_flag = off.disp_yes_no_flag
    IF (off.accept_flag=0)
     reply->oe_formats[d.seq].fields[tcnt].required_ind = 1
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->oe_formats[d.seq].fields,tcnt), stat = alterlist(temp->oe_formats[d.seq].
     qual,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->do_not_display_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    oe_format_fields off,
    order_entry_fields oef,
    oe_field_meaning oe
   PLAN (d)
    JOIN (off
    WHERE (off.oe_format_id=request->oe_formats[d.seq].oe_format_id)
     AND off.action_type_cd=order_cd)
    JOIN (oef
    WHERE oef.oe_field_id=off.oe_field_id
     AND oef.oe_field_id != field_cd)
    JOIN (oe
    WHERE oe.oe_field_meaning_id=oef.oe_field_meaning_id)
   ORDER BY d.seq, off.group_seq, off.field_seq
   HEAD d.seq
    cnt = 0, tcnt = 0, stat = alterlist(reply->oe_formats[d.seq].fields,10),
    stat = alterlist(temp->oe_formats[d.seq].qual,10)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->oe_formats[d.seq].fields,(tcnt+ 10)), stat = alterlist(temp->oe_formats[
      d.seq].qual,(tcnt+ 10)), cnt = 1
    ENDIF
    reply->oe_formats[d.seq].fields[tcnt].oe_field_id = off.oe_field_id, reply->oe_formats[d.seq].
    fields[tcnt].oe_field_label = off.label_text, reply->oe_formats[d.seq].fields[tcnt].
    default_disp_value = off.default_value,
    reply->oe_formats[d.seq].fields[tcnt].group_seq = off.group_seq, reply->oe_formats[d.seq].fields[
    tcnt].field_seq = off.field_seq, reply->oe_formats[d.seq].fields[tcnt].codeset = oef.codeset,
    reply->oe_formats[d.seq].fields[tcnt].field_type_flag = oef.field_type_flag, reply->oe_formats[d
    .seq].fields[tcnt].oe_field_meaning = oe.oe_field_meaning, reply->oe_formats[d.seq].fields[tcnt].
    clin_line_label = off.clin_line_label,
    reply->oe_formats[d.seq].fields[tcnt].clin_suffix_ind = off.clin_suffix_ind, reply->oe_formats[d
    .seq].fields[tcnt].label_text = off.label_text, reply->oe_formats[d.seq].fields[tcnt].
    clin_line_ind = off.clin_line_ind,
    reply->oe_formats[d.seq].fields[tcnt].accept_flag = off.accept_flag
    IF (off.filter_params IN ("ORDERABLE", "CATALOG TYPE", "ACTIVITY TYPE"))
     temp->oe_formats[d.seq].qual[tcnt].filter = 1
    ELSE
     temp->oe_formats[d.seq].qual[tcnt].filter = 0
    ENDIF
    reply->oe_formats[d.seq].fields[tcnt].decimal_places = cnvtint(trim(off.input_mask)), reply->
    oe_formats[d.seq].fields[tcnt].disp_yes_no_flag = off.disp_yes_no_flag
    IF (off.accept_flag=0)
     reply->oe_formats[d.seq].fields[tcnt].required_ind = 1
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->oe_formats[d.seq].fields,tcnt), stat = alterlist(temp->oe_formats[d.seq].
     qual,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE volume = f8
 DECLARE volume_unit = f8
 DECLARE strength = f8
 DECLARE strength_unit = f8
 DECLARE free_txt = vc
 DECLARE route_cd = f8
 DECLARE freq_cd = f8
 DECLARE prn_ind = i2
 DECLARE prn_res = f8
 DECLARE form = f8
 IF ((request->item_id > 0))
  SET oe_code_value = uar_get_code_by("MEANING",4063,"OEDEF")
  SET system_code_value = uar_get_code_by("MEANING",4062,"SYSTEM")
  SET inpatient_code_value = uar_get_code_by("MEANING",4500,"INPATIENT")
  SELECT INTO "nl:"
   FROM medication_definition md,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_oe_defaults oe
   PLAN (md
    WHERE (md.item_id=request->item_id))
    JOIN (mdf
    WHERE mdf.item_id=md.item_id
     AND mdf.flex_type_cd=system_code_value
     AND ((mdf.pharmacy_type_cd+ 0)=inpatient_code_value)
     AND ((mdf.sequence+ 0)=0)
     AND ((mdf.med_def_flex_id+ 0) != 0)
     AND ((mdf.active_ind+ 0)=1))
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
     AND mfoi.flex_object_type_cd=oe_code_value
     AND ((mfoi.parent_entity_id+ 0) != 0)
     AND ((mfoi.sequence+ 0)=1)
     AND ((mfoi.active_ind+ 0)=1))
    JOIN (oe
    WHERE (oe.med_oe_defaults_id=(mfoi.parent_entity_id+ 0)))
   DETAIL
    volume = oe.volume, volume_unit = oe.volume_unit_cd, strength = oe.strength,
    strength_unit = oe.strength_unit_cd, free_txt = oe.freetext_dose, route_cd = oe.route_cd,
    freq_cd = oe.frequency_cd, prn_ind = oe.prn_ind, prn_res = oe.prn_reason_cd,
    form = md.form_cd
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO req_cnt)
  SET tcnt = size(reply->oe_formats[x].fields,5)
  IF (tcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     dcp_entity_reltn der
    PLAN (d
     WHERE (reply->oe_formats[x].fields[d.seq].codeset > 0)
      AND (temp->oe_formats[x].qual[d.seq].filter=1))
     JOIN (der
     WHERE der.entity_reltn_mean=concat("ORC/",cnvtstring(reply->oe_formats[x].fields[d.seq].codeset)
      )
      AND (der.entity1_id=request->catalog_code_value)
      AND der.entity1_name="ORDER_CATALOG")
    ORDER BY d.seq
    HEAD d.seq
     cnt = 0, fcnt = size(reply->oe_formats[x].fields[d.seq].codes,5), stat = alterlist(reply->
      oe_formats[x].fields[d.seq].codes,(fcnt+ 10))
    DETAIL
     cnt = (cnt+ 1), fcnt = (fcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,(fcnt+ 10)), cnt = 1
     ENDIF
     reply->oe_formats[x].fields[d.seq].codes[fcnt].value = der.entity2_id, reply->oe_formats[x].
     fields[d.seq].codes[fcnt].display = der.entity2_display
    FOOT  d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,fcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     dcp_entity_reltn der
    PLAN (d
     WHERE (reply->oe_formats[x].fields[d.seq].codeset > 0)
      AND (temp->oe_formats[x].qual[d.seq].filter=1)
      AND size(reply->oe_formats[x].fields[d.seq].codes,5)=0)
     JOIN (der
     WHERE der.entity_reltn_mean=concat("AT/",cnvtstring(reply->oe_formats[x].fields[d.seq].codeset))
      AND der.entity1_id=pharm_at
      AND der.entity1_name="CODE_VALUE"
      AND (der.entity3_id=reply->oe_formats[x].fields[d.seq].oe_field_id))
    ORDER BY d.seq
    HEAD d.seq
     cnt = 0, fcnt = size(reply->oe_formats[x].fields[d.seq].codes,5), stat = alterlist(reply->
      oe_formats[x].fields[d.seq].codes,(fcnt+ 10))
    DETAIL
     cnt = (cnt+ 1), fcnt = (fcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,(fcnt+ 10)), cnt = 1
     ENDIF
     reply->oe_formats[x].fields[d.seq].codes[fcnt].value = der.entity2_id, reply->oe_formats[x].
     fields[d.seq].codes[fcnt].display = der.entity2_display
    FOOT  d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,fcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     dcp_entity_reltn der
    PLAN (d
     WHERE (reply->oe_formats[x].fields[d.seq].codeset > 0)
      AND (temp->oe_formats[x].qual[d.seq].filter=1)
      AND size(reply->oe_formats[x].fields[d.seq].codes,5)=0)
     JOIN (der
     WHERE der.entity_reltn_mean=concat("CT/",cnvtstring(reply->oe_formats[x].fields[d.seq].codeset))
      AND der.entity1_id=pharm_ct
      AND der.entity1_name="CODE_VALUE"
      AND (der.entity3_id=reply->oe_formats[x].fields[d.seq].oe_field_id))
    ORDER BY d.seq
    HEAD d.seq
     cnt = 0, fcnt = size(reply->oe_formats[x].fields[d.seq].codes,5), stat = alterlist(reply->
      oe_formats[x].fields[d.seq].codes,(fcnt+ 10))
    DETAIL
     cnt = (cnt+ 1), fcnt = (fcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,(fcnt+ 10)), cnt = 1
     ENDIF
     reply->oe_formats[x].fields[d.seq].codes[fcnt].value = der.entity2_id, reply->oe_formats[x].
     fields[d.seq].codes[fcnt].display = der.entity2_display
    FOOT  d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,fcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt))
    PLAN (d
     WHERE lab_share=1
      AND (reply->oe_formats[x].fields[d.seq].oe_field_meaning="SPECIMEN TYPE"))
    ORDER BY d.seq
    HEAD d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,0)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     procedure_specimen_type p,
     code_value c
    PLAN (d
     WHERE lab_share=1
      AND (reply->oe_formats[x].fields[d.seq].oe_field_meaning="SPECIMEN TYPE"))
     JOIN (p
     WHERE (p.catalog_cd=request->catalog_code_value))
     JOIN (c
     WHERE c.code_value=p.specimen_type_cd)
    ORDER BY d.seq
    HEAD d.seq
     cnt = 0, fcnt = size(reply->oe_formats[x].fields[d.seq].codes,5), stat = alterlist(reply->
      oe_formats[x].fields[d.seq].codes,(fcnt+ 10))
    DETAIL
     cnt = (cnt+ 1), fcnt = (fcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,(fcnt+ 10)), cnt = 1
     ENDIF
     reply->oe_formats[x].fields[d.seq].codes[fcnt].value = c.code_value, reply->oe_formats[x].
     fields[d.seq].codes[fcnt].display = c.display
    FOOT  d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,fcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt))
    PLAN (d
     WHERE lab_share=1
      AND (reply->oe_formats[x].fields[d.seq].oe_field_meaning="BODYSITE"))
    ORDER BY d.seq
    HEAD d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,0)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt))
    PLAN (d
     WHERE rx_share=1
      AND (reply->oe_formats[x].fields[d.seq].oe_field_meaning="FREQ"))
    ORDER BY d.seq
    HEAD d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,0)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM sch_book_instr sbi,
     sch_instr_list sil,
     (dummyt d  WITH seq = value(tcnt))
    PLAN (d
     WHERE (reply->oe_formats[x].fields[d.seq].oe_field_meaning="SCHEDULINGINSTRUCTIONS"))
     JOIN (sbi
     WHERE sbi.book_instr_id > 0
      AND sbi.active_ind=1)
     JOIN (sil
     WHERE sil.book_instr_id=sbi.book_instr_id)
    ORDER BY d.seq
    HEAD d.seq
     cnt = 0, fcnt = size(reply->oe_formats[x].fields[d.seq].codes,5), stat = alterlist(reply->
      oe_formats[x].fields[d.seq].codes,(fcnt+ 10))
    DETAIL
     cnt = (cnt+ 1), fcnt = (fcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,(fcnt+ 10)), cnt = 1
     ENDIF
     reply->oe_formats[x].fields[d.seq].codes[fcnt].value = sbi.book_instr_id, reply->oe_formats[x].
     fields[d.seq].codes[fcnt].display = sbi.description
    FOOT  d.seq
     stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,fcnt)
    WITH nocounter
   ;end select
   IF ((request->usage_flag=2))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tcnt)),
      code_value cv,
      frequency_schedule fs
     PLAN (d
      WHERE (reply->oe_formats[x].fields[d.seq].codeset=frequency_codeset)
       AND size(reply->oe_formats[x].fields[d.seq].codes,5)=0)
      JOIN (cv
      WHERE cv.code_set=frequency_codeset
       AND cv.active_ind=1)
      JOIN (fs
      WHERE fs.frequency_cd=cv.code_value
       AND fs.active_ind=1)
     ORDER BY d.seq, cv.code_value
     HEAD d.seq
      cnt = 0, fcnt = size(reply->oe_formats[x].fields[d.seq].codes,5), stat = alterlist(reply->
       oe_formats[x].fields[d.seq].codes,(fcnt+ 10))
     HEAD cv.code_value
      cnt = (cnt+ 1), fcnt = (fcnt+ 1)
      IF (cnt > 10)
       stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,(fcnt+ 10)), cnt = 1
      ENDIF
      reply->oe_formats[x].fields[d.seq].codes[fcnt].value = cv.code_value, reply->oe_formats[x].
      fields[d.seq].codes[fcnt].display = cv.display
     FOOT  d.seq
      stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,fcnt)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tcnt)),
      code_value_group cvg,
      code_value cv,
      code_value cv2
     PLAN (d
      WHERE (reply->oe_formats[x].fields[d.seq].codeset=4003)
       AND size(reply->oe_formats[x].fields[d.seq].codes,5)=0)
      JOIN (cvg)
      JOIN (cv
      WHERE cv.code_set=106
       AND cv.cdf_meaning="PHARMACY"
       AND cv.active_ind=1
       AND cv.code_value=cvg.parent_code_value)
      JOIN (cv2
      WHERE cv2.code_set=4003
       AND cv2.code_value=cvg.child_code_value
       AND cv2.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      cnt = 0, fcnt = size(reply->oe_formats[x].fields[d.seq].codes,5), stat = alterlist(reply->
       oe_formats[x].fields[d.seq].codes,(fcnt+ 10))
     DETAIL
      cnt = (cnt+ 1), fcnt = (fcnt+ 1)
      IF (cnt > 10)
       stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,(fcnt+ 10)), cnt = 1
      ENDIF
      reply->oe_formats[x].fields[d.seq].codes[fcnt].value = cv2.code_value, reply->oe_formats[x].
      fields[d.seq].codes[fcnt].display = cv2.display
     FOOT  d.seq
      stat = alterlist(reply->oe_formats[x].fields[d.seq].codes,fcnt)
     WITH nocounter
    ;end select
   ENDIF
   DECLARE tstr = vc
   IF ((request->item_id > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tcnt))
     PLAN (d)
     ORDER BY d.seq
     DETAIL
      IF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="VOLUMEDOSE"))
       tstr = build(volume), tdec = findstring(".",tstr,0,0), tpos = (tdec+ reply->oe_formats[x].
       fields[d.seq].decimal_places),
       reply->oe_formats[x].fields[d.seq].default_disp_value = substring(1,tpos,tstr), found = 0
       WHILE (found=0)
        t2 = findstring("0",reply->oe_formats[x].fields[d.seq].default_disp_value,1,1),
        IF (t2=tpos
         AND tpos > tdec)
         tpos = (tpos - 1), reply->oe_formats[x].fields[d.seq].default_disp_value = substring(1,tpos,
          reply->oe_formats[x].fields[d.seq].default_disp_value)
        ELSEIF (tpos=tdec)
         tpos = (tpos - 1), reply->oe_formats[x].fields[d.seq].default_disp_value = substring(1,tpos,
          reply->oe_formats[x].fields[d.seq].default_disp_value), found = 1
        ELSE
         found = 1
        ENDIF
       ENDWHILE
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="VOLUMEDOSEUNIT"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = uar_get_code_display(volume_unit),
       reply->oe_formats[x].fields[d.seq].default_code_value = volume_unit
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="STRENGTHDOSE"))
       tstr = build(strength), tdec = findstring(".",tstr,0,0), tpos = (tdec+ reply->oe_formats[x].
       fields[d.seq].decimal_places),
       reply->oe_formats[x].fields[d.seq].default_disp_value = substring(1,tpos,tstr), found = 0
       WHILE (found=0)
        t2 = findstring("0",reply->oe_formats[x].fields[d.seq].default_disp_value,1,1),
        IF (t2=tpos
         AND tpos > tdec)
         tpos = (tpos - 1), reply->oe_formats[x].fields[d.seq].default_disp_value = substring(1,tpos,
          reply->oe_formats[x].fields[d.seq].default_disp_value)
        ELSEIF (tpos=tdec)
         tpos = (tpos - 1), reply->oe_formats[x].fields[d.seq].default_disp_value = substring(1,tpos,
          reply->oe_formats[x].fields[d.seq].default_disp_value), found = 1
        ELSE
         found = 1
        ENDIF
       ENDWHILE
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="STRENGTHDOSEUNIT"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = uar_get_code_display(strength_unit),
       reply->oe_formats[x].fields[d.seq].default_code_value = strength_unit
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="RXROUTE"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = uar_get_code_display(route_cd), reply
       ->oe_formats[x].fields[d.seq].default_code_value = route_cd
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="FREQ"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = uar_get_code_display(freq_cd), reply->
       oe_formats[x].fields[d.seq].default_code_value = freq_cd
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="PRNREASON"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = uar_get_code_display(prn_res), reply->
       oe_formats[x].fields[d.seq].default_code_value = prn_res
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="SCH/PRN"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = build(prn_ind)
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="FREETXTDOSE"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = free_txt
      ELSEIF ((reply->oe_formats[x].fields[d.seq].oe_field_meaning="DRUGFORM"))
       reply->oe_formats[x].fields[d.seq].default_disp_value = uar_get_code_display(form), reply->
       oe_formats[x].fields[d.seq].default_code_value = form
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
