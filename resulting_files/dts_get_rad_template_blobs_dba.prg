CREATE PROGRAM dts_get_rad_template_blobs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[10]
      2 task_assay_cd = f8
      2 rad_section_type_cd = f8
      2 rad_section_type_disp = c40
      2 rad_section_type_desc = c60
      2 rad_section_type_mean = c12
      2 template_id = f8
      2 text[*]
        3 sequence = i4
        3 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET failed = "F"
 SET skip_general = 0
 SET reply->status_data.status = "F"
 SET count1 = 0
 DECLARE code_value = f8
 DECLARE temp_type_cd = f8
 SET code_value = 0.0
 SET code_set = 1303
 SET cdf_meaning = "TEMPLATE"
 EXECUTE cpm_get_cd_for_cdf
 SET temp_type_cd = code_value
 CALL echo(build(" code value for template = ",temp_type_cd))
 SELECT INTO "nl:"
  rta.template_id
  FROM rad_template_assoc rta,
   discrete_task_assay dta,
   wp_template wt,
   wp_template_text wtt,
   long_text lt
  PLAN (rta
   WHERE (rta.template_group_id=request->template_group_id))
   JOIN (dta
   WHERE dta.task_assay_cd=rta.task_assay_cd)
   JOIN (wt
   WHERE wt.template_id=rta.template_id
    AND wt.template_type_cd=temp_type_cd
    AND wt.active_ind=1)
   JOIN (wtt
   WHERE wtt.template_id=wt.template_id)
   JOIN (lt
   WHERE lt.long_text_id=wtt.long_text_id
    AND lt.active_ind=1)
  HEAD REPORT
   count1 = 0
  HEAD rta.template_id
   count2 = 0, count1 = (count1+ 1), stat = alter(reply->qual,count1),
   reply->qual[count1].task_assay_cd = rta.task_assay_cd, reply->qual[count1].rad_section_type_cd =
   dta.rad_section_type_cd, reply->qual[count1].template_id = rta.template_id,
   count2 = (count2+ 1), stat = alterlist(reply->qual[count1].text,count2), reply->qual[count1].text[
   count2].sequence = wtt.sequence,
   reply->qual[count1].text[count2].text = lt.long_text
  WITH nocounter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
