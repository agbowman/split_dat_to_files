CREATE PROGRAM dcp_icu_get_required_dtas:dba
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 task_assay_cd_desc = c60
   1 dta[*]
     2 task_assay_cd = f8
     2 task_assay_cd_desc = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET x = 0
 CALL echo(build("Specialty Event Set Code: ",request->specialty_event_set_cd))
 CALL echo(build("Position Code: ",request->position_cd))
 SELECT INTO "nl:"
  dta.task_assay_cd, etr.required_ind, dta.description
  FROM eventset_task_rltn etr,
   discrete_task_assay dta
  PLAN (etr
   WHERE (etr.specialty_event_set_cd=request->specialty_event_set_cd)
    AND (etr.position_cd=request->position_cd)
    AND etr.required_ind=1)
   JOIN (dta
   WHERE etr.task_assay_cd=dta.task_assay_cd)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].task_assay_cd =
   dta.task_assay_cd,
   reply->qual[count1].task_assay_cd_desc = dta.description
  WITH nocounter
 ;end select
 SET count2 = 0
 SELECT INTO "nl:"
  esc.event_set_cd, esc.event_set_cd_disp
  FROM v500_event_set_explode ese,
   discrete_task_assay dta
  PLAN (ese
   WHERE (ese.event_set_cd=request->specialty_event_set_cd))
   JOIN (dta
   WHERE dta.event_cd=ese.event_cd
    AND dta.active_ind != 0
    AND dta.event_cd != 0
    AND dta.task_assay_cd != 0)
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->dta,count2), reply->dta[count2].task_assay_cd = dta
   .task_assay_cd,
   reply->dta[count2].task_assay_cd_desc = dta.description
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
