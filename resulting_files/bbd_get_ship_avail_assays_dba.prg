CREATE PROGRAM bbd_get_ship_avail_assays:dba
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 task_assay_cd_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET count = 0
 SET activity_type_cd = 0.0
 SET eligibility_cd = 0.0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(106,"BBDONORPROD",cv_cnt,activity_type_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14237,"GOOD",cv_cnt,eligibility_cd)
 IF (((activity_type_cd=0.0) OR (eligibility_cd=0.0)) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to read bbdonorprod code value"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  r.included_assay_cd
  FROM discrete_task_assay d,
   interp_task_assay i,
   interp_component c,
   result_hash r
  PLAN (d
   WHERE d.activity_type_cd=activity_type_cd
    AND d.active_ind=1)
   JOIN (i
   WHERE i.task_assay_cd=d.task_assay_cd
    AND i.active_ind=1)
   JOIN (c
   WHERE c.interp_id=i.interp_id
    AND c.active_ind=1)
   JOIN (r
   WHERE r.interp_id=c.interp_id
    AND r.donor_eligibility_cd IN (eligibility_cd)
    AND r.active_ind=1)
  ORDER BY r.included_assay_cd, 0
  HEAD r.included_assay_cd
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].task_assay_cd = r
   .included_assay_cd
  DETAIL
   row + 0
  FOOT  r.included_assay_cd
   row + 0
  WITH counter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
