CREATE PROGRAM cr_rdm_updt_long_text_ref:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script cr_rdm_updt_long_text_ref..."
 DECLARE rdm_errmsg = vc WITH protect, noconstant("")
 FREE RECORD reptcomponent
 RECORD reptcomponent(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 long_text_id = f8
 )
 DECLARE needupdtnbr = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  c.report_template_id, c.long_text_id
  FROM cr_report_template c
  WHERE cnvtdatetime(curdate,curtime3) BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm
   AND c.long_text_id IN (
  (SELECT
   l.long_text_id
   FROM long_text_reference l
   WHERE l.parent_entity_name="CR_REPORT_TEMPLATE"
    AND l.parent_entity_id != c.report_template_id))
  DETAIL
   needupdtnbr = (needupdtnbr+ 1)
   IF (mod(needupdtnbr,10)=1)
    stat = alterlist(reptcomponent->qual,(needupdtnbr+ 9))
   ENDIF
   reptcomponent->qual[needupdtnbr].parent_entity_id = c.report_template_id, reptcomponent->qual[
   needupdtnbr].parent_entity_name = "CR_REPORT_TEMPLATE", reptcomponent->qual[needupdtnbr].
   long_text_id = c.long_text_id
  WITH nocounter
 ;end select
 IF (error(rdm_errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failed to get rows from cr_report_template and long_text_reference tables.",rdm_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.report_section_id, c.long_text_id
  FROM cr_report_section c
  WHERE cnvtdatetime(curdate,curtime3) BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm
   AND c.long_text_id IN (
  (SELECT
   l.long_text_id
   FROM long_text_reference l
   WHERE l.parent_entity_name="CR_REPORT_SECTION"
    AND l.parent_entity_id != c.report_section_id))
  DETAIL
   needupdtnbr = (needupdtnbr+ 1)
   IF (mod(needupdtnbr,10)=1)
    stat = alterlist(reptcomponent->qual,(needupdtnbr+ 9))
   ENDIF
   reptcomponent->qual[needupdtnbr].parent_entity_id = c.report_section_id, reptcomponent->qual[
   needupdtnbr].parent_entity_name = "CR_REPORT_SECTION", reptcomponent->qual[needupdtnbr].
   long_text_id = c.long_text_id
  WITH nocounter
 ;end select
 IF (error(rdm_errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failed to get rows from cr_report_section and long_text_reference tables.",rdm_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.report_static_region_id, c.long_text_id
  FROM cr_report_static_region c
  WHERE cnvtdatetime(curdate,curtime3) BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm
   AND c.long_text_id IN (
  (SELECT
   l.long_text_id
   FROM long_text_reference l
   WHERE l.parent_entity_name="CR_REPORT_STATIC_REGION"
    AND l.parent_entity_id != c.report_static_region_id))
  DETAIL
   needupdtnbr = (needupdtnbr+ 1)
   IF (mod(needupdtnbr,10)=1)
    stat = alterlist(reptcomponent->qual,(needupdtnbr+ 9))
   ENDIF
   reptcomponent->qual[needupdtnbr].parent_entity_id = c.report_static_region_id, reptcomponent->
   qual[needupdtnbr].parent_entity_name = "CR_REPORT_STATIC_REGION", reptcomponent->qual[needupdtnbr]
   .long_text_id = c.long_text_id
  WITH nocounter
 ;end select
 IF (error(rdm_errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failed to get rows from cr_report_static_region and long_text_reference tables.",rdm_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.report_style_profile_id, c.long_text_id
  FROM cr_report_style_profile c
  WHERE cnvtdatetime(curdate,curtime3) BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm
   AND c.long_text_id IN (
  (SELECT
   l.long_text_id
   FROM long_text_reference l
   WHERE l.parent_entity_name="CR_REPORT_STYLE_PROFILE"
    AND l.parent_entity_id != c.report_style_profile_id))
  DETAIL
   needupdtnbr = (needupdtnbr+ 1)
   IF (mod(needupdtnbr,10)=1)
    stat = alterlist(reptcomponent->qual,(needupdtnbr+ 9))
   ENDIF
   reptcomponent->qual[needupdtnbr].parent_entity_id = c.report_style_profile_id, reptcomponent->
   qual[needupdtnbr].parent_entity_name = "CR_REPORT_STYLE_PROFILE", reptcomponent->qual[needupdtnbr]
   .long_text_id = c.long_text_id
  WITH nocounter
 ;end select
 IF (error(rdm_errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failed to get rows from cr_report_style_profile and long_text_reference tables.",rdm_errmsg)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reptcomponent->qual,needupdtnbr)
 CALL echorecord(reptcomponent)
 IF (needupdtnbr > 0)
  UPDATE  FROM (dummyt d  WITH seq = value(needupdtnbr)),
    long_text_reference ltr
   SET ltr.parent_entity_id = reptcomponent->qual[d.seq].parent_entity_id, ltr.updt_task = reqinfo->
    updt_task, ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr.updt_id = reqinfo->updt_id, ltr.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (ltr
    WHERE (ltr.long_text_id=reptcomponent->qual[d.seq].long_text_id)
     AND (ltr.parent_entity_name=reptcomponent->qual[d.seq].parent_entity_name))
   WITH nocounter
  ;end update
  IF (error(rdm_errmsg,0) > 0)
   ROLLBACK
   SET readme_data->message = concat("Failed to update long_text_reference.parent_entity_id",
    rdm_errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  ROLLBACK
  SET readme_data->status = "S"
  SET readme_data->message = build(rdm_errmsg,
   "No parent entity id needs be updated in long_text_reference table")
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Success: The readme has updated all the desired fields"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
