CREATE PROGRAM bhs_athn_mpg_idr_diagnoses
 RECORD rrec(
   1 row[*]
     2 key_name = vc
     2 label = vc
     2 content[*]
       3 columnname = vc
       3 properties[*]
         4 name = vc
         4 value = vc
 )
 DECLARE dinitiated = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"INITIATED"))
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lgrpcnt = i4 WITH protect, noconstant(0)
 DECLARE ddynamicgrpid = f8 WITH protect, noconstant(0.0)
 DECLARE skeyname = vc WITH protect, noconstant("")
 SELECT INTO "NL:"
  priority_srt =
  IF (d.clinical_diag_priority=0) 999
  ELSE d.clinical_diag_priority
  ENDIF
  , nomenid =
  IF (n.nomenclature_id > 0) n.nomenclature_id
  ELSE d.nomenclature_id
  ENDIF
  FROM diagnosis d,
   nomenclature n,
   nomenclature n2,
   code_value cv,
   code_value cv1,
   (
   (
   (SELECT
    group_mean = ctgroup.display, cust_mpg_code_group_id = ctkey.cust_tags_id, config_key = ctkey
    .display,
    parent_entity_str = cki.display, parent_entity_name = "NOMENCLATURECONCEPTCKI"
    FROM cust_tags ctgroup,
     (inner JOIN cust_tags_r groupkeyr ON ctgroup.cust_tags_id=groupkeyr.parent_entity_id
      AND groupkeyr.parent_entity_name="CUST_TAGS"),
     (inner JOIN cust_tags ctkey ON ctkey.cust_tags_id=groupkeyr.cust_tags_id),
     (inner JOIN cust_tags_r keyckir ON keyckir.parent_entity_id=ctkey.cust_tags_id
      AND keyckir.parent_entity_name="CUST_TAGS"),
     (inner JOIN cust_tags cki ON cki.cust_tags_id=keyckir.cust_tags_id)
    WHERE ctgroup.display_key IN ("INPATIENTQM")
    WITH sqltype("vc","f8","vc","vc","vc")))
   cmcg),
   cmt_icd10_normalize cin,
   cmt_cross_map c,
   nomenclature n3,
   problem p,
   cust_mpg_long_text cmlt
  PLAN (d
   WHERE (d.encntr_id= $2)
    AND d.active_ind=1
    AND d.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND d.contributor_system_cd IN (0, value(uar_get_code_by("MEANING",89,"POWERCHART"))))
   JOIN (n
   WHERE n.nomenclature_id=d.originating_nomenclature_id)
   JOIN (n2
   WHERE n2.nomenclature_id=d.nomenclature_id)
   JOIN (cv
   WHERE cv.code_value=n2.source_vocabulary_cd
    AND cv.display_key="ICD*")
   JOIN (cv1
   WHERE cv1.code_value=d.diag_type_cd)
   JOIN (cmcg
   WHERE (cmcg.parent_entity_str= Outerjoin(n2.concept_cki))
    AND (cmcg.parent_entity_name= Outerjoin("NOMENCLATURECONCEPTCKI")) )
   JOIN (cin
   WHERE (cin.concept_cki= Outerjoin(n2.concept_cki))
    AND (cin.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (cin.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (c
   WHERE (c.concept_cki= Outerjoin(n.concept_cki))
    AND (c.active_ind= Outerjoin(1))
    AND (c.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (n3
   WHERE (n3.concept_cki= Outerjoin(c.target_concept_cki))
    AND (n3.active_ind= Outerjoin(1))
    AND (n3.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (p
   WHERE (p.person_id= Outerjoin( $1))
    AND (p.nomenclature_id= Outerjoin(n3.nomenclature_id))
    AND (p.active_ind= Outerjoin(1))
    AND (p.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (p.life_cycle_status_cd= Outerjoin(value(uar_get_code_by("MEANING",12030,"ACTIVE")))) )
   JOIN (cmlt
   WHERE (cmlt.parent_entity_id= Outerjoin(d.diagnosis_id))
    AND (cmlt.parent_entity_name= Outerjoin("DIAGNOSIS"))
    AND (cmlt.updt_id= Outerjoin(reqinfo->updt_id)) )
  ORDER BY priority_srt, d.diagnosis_display, nomenid,
   p.problem_id DESC, cmlt.updt_dt_tm DESC
  HEAD REPORT
   lcnt = size(rrec->row,5), lconcnt = 0
  HEAD nomenid
   lcnt += 1, stat = alterlist(rrec->row,lcnt), lconcnt = 0,
   rrec->row[lcnt].key_name = concat("DIAG_",trim(cnvtstring(d.diagnosis_group))), rrec->row[lcnt].
   label = concat(trim(d.diagnosis_display)," (",trim(n2.source_identifier),")"), lconcnt += 1,
   stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].columnname =
   "LABEL", stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,2),
   rrec->row[lcnt].content[lconcnt].properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].
   properties[1].value = concat(trim(d.diagnosis_display)," (",trim(n2.source_identifier),")"), rrec
   ->row[lcnt].content[lconcnt].properties[2].name = "CLICKFN",
   rrec->row[lcnt].content[lconcnt].properties[2].value = "modifyDx", lconcnt += 1, stat = alterlist(
    rrec->row[lcnt].content,lconcnt),
   rrec->row[lcnt].content[lconcnt].columnname = "PLAN", stat = alterlist(rrec->row[lcnt].content[
    lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].properties[1].name = "TEXT",
   rrec->row[lcnt].content[lconcnt].properties[1].value = cmlt.long_text, lconcnt += 1, stat =
   alterlist(rrec->row[lcnt].content,lconcnt),
   rrec->row[lcnt].content[lconcnt].columnname = "INNOTE", stat = alterlist(rrec->row[lcnt].content[
    lconcnt].properties,3), rrec->row[lcnt].content[lconcnt].properties[1].name = "FUNCTIONNAME",
   rrec->row[lcnt].content[lconcnt].properties[1].value = "renderIncludeInNote", rrec->row[lcnt].
   content[lconcnt].properties[2].name = "USER_SPECIFIC", rrec->row[lcnt].content[lconcnt].
   properties[2].value = "false",
   rrec->row[lcnt].content[lconcnt].properties[3].name = "DEFAULT_CHECKED", rrec->row[lcnt].content[
   lconcnt].properties[3].value = "true", lconcnt += 1,
   stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].columnname =
   "CHRONIC", stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,7),
   rrec->row[lcnt].content[lconcnt].properties[1].name = "CLICKFN", rrec->row[lcnt].content[lconcnt].
   properties[1].value = "cnvtDxtoProblem", rrec->row[lcnt].content[lconcnt].properties[2].name =
   "TARGET_VOCAB_CD",
   rrec->row[lcnt].content[lconcnt].properties[2].value = cnvtstring(value(uar_get_code_by("MEANING",
      400,"SNMCT"))), rrec->row[lcnt].content[lconcnt].properties[3].name = "PROB_CLASS_CD", rrec->
   row[lcnt].content[lconcnt].properties[3].value = cnvtstring(value(uar_get_code_by("MEANING",12033,
      "MEDICAL"))),
   rrec->row[lcnt].content[lconcnt].properties[4].name = "PROB_CONFIRM_CD", rrec->row[lcnt].content[
   lconcnt].properties[4].value = cnvtstring(value(uar_get_code_by("MEANING",12031,"CONFIRMED"))),
   rrec->row[lcnt].content[lconcnt].properties[5].name = "NOMENCLATURE_ID",
   rrec->row[lcnt].content[lconcnt].properties[5].value = cnvtstring(d.originating_nomenclature_id),
   rrec->row[lcnt].content[lconcnt].properties[6].name = "CHECKED", rrec->row[lcnt].content[lconcnt].
   properties[6].value = "false",
   rrec->row[lcnt].content[lconcnt].properties[7].name = "DISABLED", rrec->row[lcnt].content[lconcnt]
   .properties[7].value = "false"
   IF (p.problem_id > 0)
    rrec->row[lcnt].content[lconcnt].properties[6].value = "checked", rrec->row[lcnt].content[lconcnt
    ].properties[7].value = "disabled"
   ENDIF
   IF (cmcg.cust_mpg_code_group_id > 0)
    lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt]
    .columnname = "MEASURESET",
    stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,3), rrec->row[lcnt].content[lconcnt]
    .properties[1].name = "CONFIGKEY", rrec->row[lcnt].content[lconcnt].properties[1].value = cmcg
    .config_key,
    rrec->row[lcnt].content[lconcnt].properties[2].name = "FUNCTIONNAME", rrec->row[lcnt].content[
    lconcnt].properties[2].value = "openMeasureSet", rrec->row[lcnt].content[lconcnt].properties[3].
    name = "NOMENCLATURE_ID",
    rrec->row[lcnt].content[lconcnt].properties[3].value = cnvtstring(d.nomenclature_id), lconcnt +=
    1, stat = alterlist(rrec->row[lcnt].content,lconcnt),
    rrec->row[lcnt].content[lconcnt].columnname = "QUALITY", stat = alterlist(rrec->row[lcnt].
     content[lconcnt].properties,3), rrec->row[lcnt].content[lconcnt].properties[1].name =
    "TITLETEXT",
    rrec->row[lcnt].content[lconcnt].properties[1].value = cmcg.group_mean, rrec->row[lcnt].content[
    lconcnt].properties[2].name = "ICON", rrec->row[lcnt].content[lconcnt].properties[2].value =
    "ui-icon-alert",
    rrec->row[lcnt].content[lconcnt].properties[3].name = "CLASS", rrec->row[lcnt].content[lconcnt].
    properties[3].value = "ui-state-error"
   ENDIF
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "SPECIFICITY",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,4), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = "N",
   rrec->row[lcnt].content[lconcnt].properties[2].name = "ICON", rrec->row[lcnt].content[lconcnt].
   properties[2].value = "uhspa-unspecified-condition", rrec->row[lcnt].content[lconcnt].properties[3
   ].name = "CLICKFN",
   rrec->row[lcnt].content[lconcnt].properties[3].value = "openDxAssist", rrec->row[lcnt].content[
   lconcnt].properties[4].name = "TITLETEXT", rrec->row[lcnt].content[lconcnt].properties[4].value =
   "Unspecified"
   IF (cin.cmt_icd10_normalize_id > 0)
    rrec->row[lcnt].content[lconcnt].properties[1].value = cin.i10_specific
    IF (cin.i10_specific="Y")
     rrec->row[lcnt].content[lconcnt].properties[2].value = "uhspa-specified-condition", rrec->row[
     lcnt].content[lconcnt].properties[4].value = "Specified"
    ENDIF
   ENDIF
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "DIAGNOSIS_ID",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = cnvtstring(d
    .diagnosis_id),
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "DIAGNOSIS_GROUP",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = cnvtstring(d
    .diagnosis_group),
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "NOMENCLATURE_ID",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = cnvtstring(d
    .nomenclature_id),
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "ORIGINATING_NOMENCLATURE_ID",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = cnvtstring(d
    .originating_nomenclature_id),
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "DIAGNOSIS_DISPLAY",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT"
   IF (size(trim(d.diagnosis_display)) > 0)
    rrec->row[lcnt].content[lconcnt].properties[1].value = trim(d.diagnosis_display)
   ELSE
    rrec->row[lcnt].content[lconcnt].properties[1].value = trim(n2.source_string)
   ENDIF
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "DIAGNOSIS_TYPE_CD",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = cnvtstring(d
    .diag_type_cd),
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "DIAGNOSIS_TYPE_VALUE",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = cv1.display,
   lconcnt += 1, stat = alterlist(rrec->row[lcnt].content,lconcnt), rrec->row[lcnt].content[lconcnt].
   columnname = "DIAGNOSIS_TYPE_CODE",
   stat = alterlist(rrec->row[lcnt].content[lconcnt].properties,1), rrec->row[lcnt].content[lconcnt].
   properties[1].name = "TEXT", rrec->row[lcnt].content[lconcnt].properties[1].value = cv1
   .display_key
  WITH nocounter
 ;end select
END GO
