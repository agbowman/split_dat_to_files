CREATE PROGRAM bed_get_ps_sel_srch_settings:dba
 FREE SET reply
 RECORD reply(
   1 srch_filters[*]
     2 name = vc
     2 display = vc
     2 sequence = i4
     2 required_ind = i2
     2 encounter_fltr_ind = i2
   1 default_filters[*]
     2 name = vc
     2 value = f8
     2 value_disp = vc
     2 value_mean = vc
   1 encntr_info[*]
     2 name = vc
     2 display = vc
     2 sequence = i4
   1 reltn_info[*]
     2 name = vc
     2 display = vc
     2 sequence = i4
   1 person_info[*]
     2 name = vc
     2 display = vc
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET setup_id = 0
 SELECT INTO "nl:"
  FROM pm_sch_setup p
  PLAN (p
   WHERE (p.application_number=request->application_number)
    AND (p.task_number=request->task_number)
    AND p.person_id=0
    AND (p.position_cd=request->position_code_value))
  DETAIL
   setup_id = p.setup_id
  WITH nocounter
 ;end select
 IF ((request->search_mean="SEARCH_FILTERS"))
  SELECT INTO "nl:"
   FROM pm_sch_filter p,
    br_person_search_settings b
   PLAN (p
    WHERE p.setup_id=setup_id
     AND p.data_type_flag > 0
     AND p.hidden_ind=0)
    JOIN (b
    WHERE b.setting_mean="SEARCH_FILTERS"
     AND b.data_type_flag=p.data_type_flag
     AND ((b.meaning=p.meaning) OR (b.meaning="")) )
   ORDER BY p.sequence
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(reply->srch_filters,fcnt), reply->srch_filters[fcnt].name = b
    .description
    IF (p.display > " ")
     reply->srch_filters[fcnt].display = p.display
    ELSE
     reply->srch_filters[fcnt].display = b.description
    ENDIF
    reply->srch_filters[fcnt].sequence = (fcnt - 1), reply->srch_filters[fcnt].required_ind = p
    .required_ind
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((request->empi_ind=1))
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="SEARCH_FILTERS"
       AND b.empi_ind=1)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->srch_filters,fcnt), reply->srch_filters[fcnt].name =
      b2.description,
      reply->srch_filters[fcnt].display = b2.display, reply->srch_filters[fcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="SEARCH_FILTERS"
       AND b.empi_ind=0)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->srch_filters,fcnt), reply->srch_filters[fcnt].name =
      b2.description,
      reply->srch_filters[fcnt].display = b2.display, reply->srch_filters[fcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF ((request->search_mean="DEFAULT_FILTERS"))
  SET fcnt = 0
  SELECT INTO "nl:"
   FROM pm_sch_filter p,
    br_person_search_settings b
   PLAN (p
    WHERE p.setup_id=setup_id
     AND p.data_type_flag > 0
     AND p.value > " ")
    JOIN (b
    WHERE b.setting_mean="DEFAULT_FILTERS"
     AND b.data_type_flag=p.data_type_flag
     AND ((b.meaning=p.meaning) OR (b.meaning="")) )
   ORDER BY p.sequence
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(reply->default_filters,fcnt), reply->default_filters[fcnt].
    name = b.description,
    reply->default_filters[fcnt].value = cnvtreal(p.value)
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((request->empi_ind=1))
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="DEFAULT_FILTERS"
       AND b.empi_ind=1)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->default_filters,fcnt), reply->default_filters[fcnt].
      name = b2.description
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="DEFAULT_FILTERS"
       AND b.empi_ind=0)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->default_filters,fcnt), reply->default_filters[fcnt].
      name = b2.description
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  FOR (x = 1 TO fcnt)
    IF ((reply->default_filters[x].name="Client"))
     SELECT INTO "nl:"
      FROM organization o
      PLAN (o
       WHERE (o.organization_id=reply->default_filters[x].value))
      DETAIL
       reply->default_filters[x].value_disp = o.org_name, reply->default_filters[x].value_mean = o
       .org_name_key
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE (c.code_value=reply->default_filters[x].value))
      DETAIL
       reply->default_filters[x].value_disp = c.display, reply->default_filters[x].value_mean = c
       .cdf_meaning
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->search_mean="PERSON_RESULTS"))
  SET rcnt = 0
  SELECT INTO "nl:"
   FROM pm_sch_result p,
    br_person_search_settings b
   PLAN (p
    WHERE p.setup_id=setup_id)
    JOIN (b
    WHERE b.setting_mean="PERSON_RESULTS"
     AND b.data_type_flag=p.data_type_flag
     AND ((b.meaning=p.meaning) OR (b.meaning="")) )
   ORDER BY p.sequence
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->person_info,rcnt), reply->person_info[rcnt].name = b
    .description
    IF (p.display > " ")
     reply->person_info[rcnt].display = p.display
    ELSE
     reply->person_info[rcnt].display = b.description
    ENDIF
    reply->person_info[rcnt].sequence = (rcnt - 1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((request->empi_ind=1))
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="PERSON_RESULTS"
       AND b.empi_ind=1)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      rcnt = (rcnt+ 1), stat = alterlist(reply->person_info,rcnt), reply->person_info[rcnt].name = b2
      .description,
      reply->person_info[rcnt].display = b2.display, reply->person_info[rcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="PERSON_RESULTS"
       AND b.empi_ind=0)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      rcnt = (rcnt+ 1), stat = alterlist(reply->person_info,rcnt), reply->person_info[rcnt].name = b2
      .description,
      reply->person_info[rcnt].display = b2.display, reply->person_info[rcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF ((request->search_mean="ENCOUNTER_RESULTS"))
  SET rcnt = 0
  SELECT INTO "nl:"
   FROM pm_sch_result p,
    br_person_search_settings b
   PLAN (p
    WHERE p.setup_id=setup_id)
    JOIN (b
    WHERE b.setting_mean="ENCOUNTER_RESULTS"
     AND b.data_type_flag=p.data_type_flag
     AND ((b.meaning=p.meaning) OR (b.meaning="")) )
   ORDER BY p.sequence
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->encntr_info,rcnt), reply->encntr_info[rcnt].name = b
    .description
    IF (p.display > " ")
     reply->encntr_info[rcnt].display = p.display
    ELSE
     reply->encntr_info[rcnt].display = b.description
    ENDIF
    reply->encntr_info[rcnt].sequence = (rcnt - 1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((request->empi_ind=1))
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="ENCOUNTER_RESULTS"
       AND b.empi_ind=1)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      rcnt = (rcnt+ 1), stat = alterlist(reply->encntr_info,rcnt), reply->encntr_info[rcnt].name = b2
      .description,
      reply->encntr_info[rcnt].display = b2.display, reply->encntr_info[rcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="ENCOUNTER_RESULTS"
       AND b.empi_ind=0)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      rcnt = (rcnt+ 1), stat = alterlist(reply->encntr_info,rcnt), reply->encntr_info[rcnt].name = b2
      .description,
      reply->encntr_info[rcnt].display = b2.display, reply->encntr_info[rcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF ((request->search_mean="RELTN_RESULTS"))
  SET rcnt = 0
  SELECT INTO "nl:"
   FROM pm_sch_result p,
    br_person_search_settings b
   PLAN (p
    WHERE p.setup_id=setup_id)
    JOIN (b
    WHERE b.setting_mean="RELTN_RESULTS"
     AND b.data_type_flag=p.data_type_flag
     AND ((b.meaning=p.meaning) OR (b.meaning="")) )
   ORDER BY p.sequence
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->reltn_info,rcnt), reply->reltn_info[rcnt].name = b
    .description
    IF (p.display > " ")
     reply->reltn_info[rcnt].display = p.display
    ELSE
     reply->reltn_info[rcnt].display = b.description
    ENDIF
    reply->reltn_info[rcnt].sequence = (rcnt - 1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((request->empi_ind=1))
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="RELTN_RESULTS"
       AND b.empi_ind=1)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      rcnt = (rcnt+ 1), stat = alterlist(reply->reltn_info,rcnt), reply->reltn_info[rcnt].name = b2
      .description,
      reply->reltn_info[rcnt].display = b2.display, reply->reltn_info[rcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM br_default_person_search b,
      br_person_search_settings b2
     PLAN (b
      WHERE b.setting_mean="RELTN_RESULTS"
       AND b.empi_ind=0)
      JOIN (b2
      WHERE b2.setting_mean=b.setting_mean
       AND b2.display=b.display)
     ORDER BY b.sequence
     DETAIL
      rcnt = (rcnt+ 1), stat = alterlist(reply->reltn_info,rcnt), reply->reltn_info[rcnt].name = b2
      .description,
      reply->reltn_info[rcnt].display = b2.display, reply->reltn_info[rcnt].sequence = b.sequence
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
