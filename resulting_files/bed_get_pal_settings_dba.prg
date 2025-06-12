CREATE PROGRAM bed_get_pal_settings:dba
 FREE SET reply
 RECORD reply(
   1 section_types[*]
     2 code_value = f8
     2 display = vc
     2 sequence = i4
     2 task_group_time_interval = vc
     2 column_types[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 sequence = i4
       3 title = vc
       3 notification_item = vc
       3 detail_code_value = f8
       3 activity_type
         4 code_value = f8
         4 display = vc
       3 orderable
         4 code_value = f8
         4 display = vc
       3 format
         4 id = f8
         4 name = vc
       3 field
         4 id = f8
         4 name = vc
       3 show_when_collapsed_ind = i2
       3 event_set_name = vc
       3 duration = vc
       3 catalog_type
         4 code_value = f8
         4 display = vc
       3 ord_activity_type
         4 code_value = f8
         4 display = vc
       3 note
         4 code_value = f8
         4 display = vc
       3 task_group
         4 code_value = f8
         4 display = vc
       3 col_width = vc
       3 report_code_value = f8
     2 sect_color = vc
     2 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 RECORD section(
   1 qual[*]
     2 id = f8
 )
 SET demographic_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="DEMOGRAPHIC"
  DETAIL
   demographic_cd = cv.code_value
  WITH nocounter
 ;end select
 SET notify_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="NOTIFY"
  DETAIL
   notify_cd = cv.code_value
  WITH nocounter
 ;end select
 SET task_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="TASK"
  DETAIL
   task_cd = cv.code_value
  WITH nocounter
 ;end select
 SET result_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25491
   AND cv.cdf_meaning="RESULT"
  DETAIL
   result_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pip p,
   pip_section s,
   code_value c,
   pip_prefs f
  PLAN (p
   WHERE (p.position_cd=request->position_code_value)
    AND (p.location_cd=request->location_code_value)
    AND p.prsnl_id=0)
   JOIN (s
   WHERE s.pip_id=p.pip_id)
   JOIN (c
   WHERE c.code_value=s.section_type_cd)
   JOIN (f
   WHERE f.parent_entity_name=outerjoin("PIP_SECTION")
    AND f.parent_entity_id=outerjoin(s.pip_section_id)
    AND f.pref_name=outerjoin("COLOR"))
  ORDER BY s.sequence
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->section_types,scnt), reply->section_types[scnt].
   code_value = s.section_type_cd,
   reply->section_types[scnt].display = c.display, reply->section_types[scnt].mean = c.cdf_meaning,
   reply->section_types[scnt].sequence = s.sequence,
   reply->section_types[scnt].sect_color = f.pref_value, stat = alterlist(section->qual,scnt),
   section->qual[scnt].id = s.pip_section_id
  WITH nocounter
 ;end select
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO scnt)
   SET ccnt = 0
   IF ((reply->section_types[x].code_value=demographic_cd))
    SELECT INTO "nl:"
     FROM pip_column p,
      code_value c,
      pip_prefs s
     PLAN (p
      WHERE (p.pip_section_id=section->qual[x].id)
       AND p.prsnl_id=0)
      JOIN (c
      WHERE c.code_value=p.column_type_cd)
      JOIN (s
      WHERE s.parent_entity_name="PIP_COLUMN"
       AND s.parent_entity_id=p.pip_column_id
       AND s.prsnl_id=0)
     ORDER BY p.sequence
     HEAD p.sequence
      ccnt = (ccnt+ 1), stat = alterlist(reply->section_types[x].column_types,ccnt), reply->
      section_types[x].column_types[ccnt].code_value = p.column_type_cd,
      reply->section_types[x].column_types[ccnt].display = c.display, reply->section_types[x].
      column_types[ccnt].mean = c.cdf_meaning, reply->section_types[x].column_types[ccnt].sequence =
      p.sequence
     DETAIL
      IF (s.pref_name="SHOW_WHEN_COLLAPSED")
       reply->section_types[x].column_types[ccnt].show_when_collapsed_ind = cnvtint(s.pref_value)
      ELSEIF (s.pref_name="TITLE")
       reply->section_types[x].column_types[ccnt].title = s.pref_value
      ELSEIF (s.pref_name="DETAIL_CD")
       reply->section_types[x].column_types[ccnt].detail_code_value = s.merge_id
      ELSEIF (s.pref_name="ACTIVITY_TYPE")
       reply->section_types[x].column_types[ccnt].activity_type.code_value = s.merge_id
      ELSEIF (s.pref_name="CATALOG_CD")
       reply->section_types[x].column_types[ccnt].orderable.code_value = s.merge_id
      ELSEIF (s.pref_name="FORMAT_CD")
       reply->section_types[x].column_types[ccnt].format.id = s.merge_id
      ELSEIF (s.pref_name="OE_FIELD_ID")
       reply->section_types[x].column_types[ccnt].field.id = s.merge_id
      ELSEIF (s.pref_name="WIDTH")
       reply->section_types[x].column_types[ccnt].col_width = s.pref_value
      ELSEIF (s.pref_name="REPORT_CD")
       reply->section_types[x].column_types[ccnt].report_code_value = s.merge_id
      ENDIF
     WITH nocounter
    ;end select
    FOR (y = 1 TO ccnt)
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE (c.code_value=reply->section_types[x].column_types[y].activity_type.code_value)
         AND c.code_value > 0)
       DETAIL
        reply->section_types[x].column_types[y].activity_type.display = c.display
       WITH nocounter
      ;end select
      SELECT INTO "NL:"
       FROM order_catalog oc
       PLAN (oc
        WHERE (oc.catalog_cd=reply->section_types[x].column_types[y].orderable.code_value)
         AND oc.catalog_cd > 0)
       DETAIL
        reply->section_types[x].column_types[y].orderable.display = oc.primary_mnemonic
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM order_entry_format o
       PLAN (o
        WHERE (o.oe_format_id=reply->section_types[x].column_types[y].format.id)
         AND o.oe_format_id > 0)
       DETAIL
        reply->section_types[x].column_types[y].format.name = o.oe_format_name
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM order_entry_fields o
       PLAN (o
        WHERE (o.oe_field_id=reply->section_types[x].column_types[y].field.id)
         AND o.oe_field_id > 0)
       DETAIL
        reply->section_types[x].column_types[y].field.name = o.description
       WITH nocounter
      ;end select
    ENDFOR
   ENDIF
   IF ((reply->section_types[x].code_value=notify_cd))
    SELECT INTO "nl:"
     FROM pip_column p,
      code_value c,
      pip_prefs s
     PLAN (p
      WHERE (p.pip_section_id=section->qual[x].id)
       AND p.prsnl_id=0)
      JOIN (c
      WHERE c.code_value=p.column_type_cd)
      JOIN (s
      WHERE s.parent_entity_name="PIP_COLUMN"
       AND s.parent_entity_id=p.pip_column_id
       AND s.prsnl_id=0)
     ORDER BY p.sequence
     HEAD p.sequence
      ccnt = (ccnt+ 1), stat = alterlist(reply->section_types[x].column_types,ccnt), reply->
      section_types[x].column_types[ccnt].code_value = p.column_type_cd,
      reply->section_types[x].column_types[ccnt].display = c.display, reply->section_types[x].
      column_types[ccnt].mean = c.cdf_meaning, reply->section_types[x].column_types[ccnt].sequence =
      p.sequence
     DETAIL
      IF (s.pref_name="SHOW_WHEN_COLLAPSED")
       reply->section_types[x].column_types[ccnt].show_when_collapsed_ind = cnvtint(s.pref_value)
      ELSEIF (s.pref_name="TITLE")
       reply->section_types[x].column_types[ccnt].title = s.pref_value
      ELSEIF (s.pref_name="EVENT_SET_NAME")
       reply->section_types[x].column_types[ccnt].event_set_name = s.pref_value
      ELSEIF (s.pref_name="ACTIVITY_TYPE")
       reply->section_types[x].column_types[ccnt].ord_activity_type.code_value = s.merge_id
      ELSEIF (s.pref_name IN ("CATALOG_TYPE", "ALL_ORDERS"))
       reply->section_types[x].column_types[ccnt].catalog_type.code_value = s.merge_id
      ELSEIF (s.pref_name="NOTE_TYPE")
       reply->section_types[x].column_types[ccnt].note.code_value = s.merge_id
      ELSEIF (s.pref_name="WIDTH")
       reply->section_types[x].column_types[ccnt].col_width = s.pref_value
      ENDIF
     WITH nocounter
    ;end select
    FOR (y = 1 TO ccnt)
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE (c.code_value=reply->section_types[x].column_types[y].ord_activity_type.code_value)
         AND c.code_value > 0)
       DETAIL
        reply->section_types[x].column_types[y].ord_activity_type.display = c.display
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE (c.code_value=reply->section_types[x].column_types[y].catalog_type.code_value)
         AND c.code_value != 1
         AND c.code_value > 0)
       DETAIL
        reply->section_types[x].column_types[y].catalog_type.display = c.display
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE (c.code_value=reply->section_types[x].column_types[y].note.code_value)
         AND c.code_value > 0)
       DETAIL
        reply->section_types[x].column_types[y].note.display = c.display
       WITH nocounter
      ;end select
    ENDFOR
   ENDIF
   IF ((reply->section_types[x].code_value=task_cd))
    SELECT INTO "nl:"
     FROM pip_prefs p,
      pip_prefs s,
      code_value c
     PLAN (p
      WHERE p.parent_entity_name="PIP_SECTION"
       AND (p.parent_entity_id=section->qual[x].id)
       AND p.pref_name="TIME_INTERVAL")
      JOIN (s
      WHERE s.parent_entity_name=outerjoin("PIP_SECTION")
       AND s.parent_entity_id=outerjoin(p.parent_entity_id)
       AND s.pref_name=outerjoin("TASK_GROUP")
       AND s.prsnl_id=0)
      JOIN (c
      WHERE c.code_value=outerjoin(s.merge_id))
     ORDER BY s.sequence
     HEAD REPORT
      reply->section_types[x].task_group_time_interval = p.pref_value
     HEAD s.sequence
      ccnt = (ccnt+ 1), stat = alterlist(reply->section_types[x].column_types,ccnt), reply->
      section_types[x].column_types[ccnt].task_group.code_value = s.merge_id,
      reply->section_types[x].column_types[ccnt].task_group.display = c.display, reply->
      section_types[x].column_types[ccnt].sequence = s.sequence
     WITH nocounter
    ;end select
   ENDIF
   IF ((reply->section_types[x].code_value=result_cd))
    SELECT INTO "nl:"
     FROM pip_column p,
      code_value c,
      pip_prefs s
     PLAN (p
      WHERE (p.pip_section_id=section->qual[x].id)
       AND p.prsnl_id=0)
      JOIN (c
      WHERE c.code_value=p.column_type_cd)
      JOIN (s
      WHERE s.parent_entity_name="PIP_COLUMN"
       AND s.parent_entity_id=p.pip_column_id
       AND s.prsnl_id=0)
     ORDER BY p.sequence
     HEAD p.sequence
      ccnt = (ccnt+ 1), stat = alterlist(reply->section_types[x].column_types,ccnt), reply->
      section_types[x].column_types[ccnt].code_value = p.column_type_cd,
      reply->section_types[x].column_types[ccnt].display = c.display, reply->section_types[x].
      column_types[ccnt].mean = c.cdf_meaning, reply->section_types[x].column_types[ccnt].sequence =
      p.sequence
     DETAIL
      IF (s.pref_name="SHOW_WHEN_COLLAPSED")
       reply->section_types[x].column_types[ccnt].show_when_collapsed_ind = cnvtint(s.pref_value)
      ELSEIF (s.pref_name="TITLE")
       reply->section_types[x].column_types[ccnt].title = s.pref_value
      ELSEIF (s.pref_name="EVENT_SET_NAME")
       reply->section_types[x].column_types[ccnt].event_set_name = s.pref_value
      ELSEIF (s.pref_name="DURATION")
       reply->section_types[x].column_types[ccnt].duration = s.pref_value
      ELSEIF (s.pref_name="WIDTH")
       reply->section_types[x].column_types[ccnt].col_width = s.pref_value
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (scnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
