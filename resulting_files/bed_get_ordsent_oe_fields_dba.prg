CREATE PROGRAM bed_get_ordsent_oe_fields:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 fields[*]
      2 oe_field_id = f8
      2 label = vc
      2 default_value = vc
      2 group_seq = i4
      2 field_seq = i4
      2 codeset = i4
      2 field_type_flag = i2
      2 field_meaning = vc
      2 codes[*]
        3 code_value = f8
        3 display = vc
      2 decimal_places = i4
      2 accept_size = i4
      2 clin_line_label = vc
      2 disp_yes_no_flag = i2
      2 required_ind = i2
      2 accept_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cnt = i2
 DECLARE lab_share = i2
 DECLARE rx_share = i2
 DECLARE order_cd = f8
 DECLARE catalog_cd = f8
 DECLARE catalog_type_cd = f8
 DECLARE activity_type_cd = f8
 DECLARE field_cd = f8
 DECLARE fcnt = i4
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET lab_share = 0
 SET rx_share = 0
 RECORD temp(
   1 qual[*]
     2 filter = i2
 )
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
 SET order_cd = 0.0
 IF ((request->usage_flag=2))
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=6003
     AND c.cdf_meaning="DISORDER"
     AND c.active_ind=1)
   DETAIL
    order_cd = c.code_value
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=6003
     AND c.cdf_meaning="ORDER"
     AND c.active_ind=1)
   DETAIL
    order_cd = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 SET catalog_cd = 0.0
 SET catalog_type_cd = 0.0
 SET activity_type_cd = 0.0
 SELECT INTO "nl:"
  FROM order_catalog_synonym o
  PLAN (o
   WHERE (o.synonym_id=request->synonym_id))
  DETAIL
   catalog_cd = o.catalog_cd, catalog_type_cd = o.catalog_type_cd, activity_type_cd = o
   .activity_type_cd
  WITH nocounter
 ;end select
 SET field_cd = uar_get_code_by("DISPLAYKEY",16449,"RECEIVINGMEDICALLYRESPONSIBLECAREUNI")
 DECLARE oe_format_id = f8
 SET oe_format_id = request->oe_format_id
 DECLARE parse_txt = vc
 SET parse_txt = "off.oe_format_id = oe_format_id and off.action_type_cd = order_cd"
 IF ((request->do_not_display_ind=0))
  SET parse_txt = concat(parse_txt," and off.accept_flag in (0,1,3)")
 ENDIF
 SELECT INTO "nl:"
  FROM oe_format_fields off,
   order_entry_fields oef,
   oe_field_meaning oe
  PLAN (off
   WHERE parser(parse_txt))
   JOIN (oef
   WHERE oef.oe_field_id=off.oe_field_id
    AND oef.oe_field_id != field_cd)
   JOIN (oe
   WHERE oe.oe_field_meaning_id=oef.oe_field_meaning_id)
  ORDER BY off.group_seq, off.field_seq
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->fields,cnt), reply->fields[cnt].oe_field_id = off
   .oe_field_id,
   reply->fields[cnt].label = off.label_text, reply->fields[cnt].default_value = off.default_value,
   reply->fields[cnt].group_seq = off.group_seq,
   reply->fields[cnt].field_seq = off.field_seq, reply->fields[cnt].codeset = oef.codeset, reply->
   fields[cnt].field_type_flag = oef.field_type_flag,
   reply->fields[cnt].field_meaning = oe.oe_field_meaning, reply->fields[cnt].accept_flag = off
   .accept_flag, stat = alterlist(temp->qual,cnt)
   IF (off.filter_params IN ("ORDERABLE", "CATALOG TYPE", "ACTIVITY TYPE"))
    temp->qual[cnt].filter = 1
   ELSE
    temp->qual[cnt].filter = 0
   ENDIF
   reply->fields[cnt].decimal_places = cnvtint(off.input_mask), reply->fields[cnt].accept_size = oef
   .accept_size, reply->fields[cnt].clin_line_label = off.clin_line_label,
   reply->fields[cnt].disp_yes_no_flag = off.disp_yes_no_flag
   IF (off.accept_flag=0)
    reply->fields[cnt].required_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE astring = vc
 DECLARE cstring = vc
 DECLARE ostring = vc
 FOR (x = 1 TO cnt)
   IF ((reply->fields[x].codeset > 0)
    AND (temp->qual[x].filter=1))
    SET fcnt = 0
    SET astring = concat("AT/",cnvtstring(reply->fields[x].codeset))
    SET cstring = concat("CT/",cnvtstring(reply->fields[x].codeset))
    SET ostring = concat("ORC/",cnvtstring(reply->fields[x].codeset))
    SELECT INTO "nl:"
     FROM dcp_entity_reltn der
     PLAN (der
      WHERE der.entity_reltn_mean=ostring
       AND der.entity1_id=catalog_cd)
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->fields[x].codes,fcnt), reply->fields[x].codes[fcnt].
      code_value = der.entity2_id,
      reply->fields[x].codes[fcnt].display = der.entity2_display
     WITH nocounter
    ;end select
    IF (fcnt=0)
     SELECT INTO "nl:"
      FROM dcp_entity_reltn der
      PLAN (der
       WHERE der.entity_reltn_mean=astring
        AND der.entity1_id=activity_type_cd)
      DETAIL
       fcnt = (fcnt+ 1), stat = alterlist(reply->fields[x].codes,fcnt), reply->fields[x].codes[fcnt].
       code_value = der.entity2_id,
       reply->fields[x].codes[fcnt].display = der.entity2_display
      WITH nocounter
     ;end select
    ENDIF
    IF (fcnt=0)
     SELECT INTO "nl:"
      FROM dcp_entity_reltn der
      PLAN (der
       WHERE der.entity_reltn_mean=cstring
        AND der.entity1_id=catalog_type_cd)
      DETAIL
       fcnt = (fcnt+ 1), stat = alterlist(reply->fields[x].codes,fcnt), reply->fields[x].codes[fcnt].
       code_value = der.entity2_id,
       reply->fields[x].codes[fcnt].display = der.entity2_display
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (lab_share=1
    AND (reply->fields[x].field_meaning="SPECIMEN TYPE"))
    SET stat = alterlist(reply->fields[x].codes,0)
    SET fcnt = 0
    SELECT INTO "nl:"
     FROM procedure_specimen_type p,
      code_value c
     PLAN (p
      WHERE p.catalog_cd=catalog_cd)
      JOIN (c
      WHERE c.code_value=p.specimen_type_cd)
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->fields[x].codes,fcnt), reply->fields[x].codes[fcnt].
      code_value = c.code_value,
      reply->fields[x].codes[fcnt].display = c.description
     WITH nocounter
    ;end select
   ENDIF
   IF (lab_share=1
    AND (reply->fields[x].field_meaning="BODYSITE"))
    SET stat = alterlist(reply->fields[x].codes,0)
   ENDIF
   IF (rx_share=1
    AND (reply->fields[x].field_meaning="FREQ"))
    SET stat = alterlist(reply->fields[x].codes,0)
   ENDIF
   IF ((reply->fields[x].field_meaning="SCHEDULINGINSTRUCTIONS"))
    SET stat = alterlist(reply->fields[x].codes,0)
    SET fcnt = 0
    SELECT INTO "nl:"
     FROM sch_book_instr sbi,
      sch_instr_list sil
     PLAN (sbi
      WHERE sbi.book_instr_id > 0
       AND sbi.active_ind=1)
      JOIN (sil
      WHERE sil.book_instr_id=sbi.book_instr_id)
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->fields[x].codes,fcnt), reply->fields[x].codes[fcnt].
      code_value = sbi.book_instr_id,
      reply->fields[x].codes[fcnt].display = sbi.description
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
