CREATE PROGRAM bbd_get_prod_pat_comp:dba
 RECORD reply(
   1 no_gt_on_prsn_flag = i4
   1 no_gt_autodir_prsn_flag = i4
   1 bbd_no_gt_dir_prsn_flag = i4
   1 warn_ind = i2
   1 no_compatibility_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET person_aborh_cd = 0
 SET product_aborh_cd = 0
 SET reply->no_compatibility_ind = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value_extension cve1,
   code_value_extension cve2,
   code_value cv
  PLAN (cve1
   WHERE cve1.code_set=1640
    AND cve1.field_value=cnvtstring(request->person_abo_cd)
    AND cve1.field_name="ABOOnly_cd")
   JOIN (cve2
   WHERE cve2.code_value=cve1.code_value
    AND cve2.field_value=cnvtstring(request->person_rh_cd)
    AND cve2.field_name="RhOnly_cd"
    AND cve2.code_set=1640)
   JOIN (cv
   WHERE cv.code_value=cve2.code_value
    AND cv.active_ind=1)
  DETAIL
   person_aborh_cd = cv.code_value,
   CALL echo(person_aborh_cd)
  WITH counter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value_extension cve1,
   code_value_extension cve2,
   code_value cv
  PLAN (cve1
   WHERE cve1.code_set=1640
    AND cve1.field_value=cnvtstring(request->product_abo_cd)
    AND cve1.field_name="ABOOnly_cd")
   JOIN (cve2
   WHERE cve2.code_value=cve1.code_value
    AND cve2.field_value=cnvtstring(request->product_rh_cd)
    AND cve2.field_name="RhOnly_cd"
    AND cve2.code_set=1640)
   JOIN (cv
   WHERE cv.code_value=cve2.code_value
    AND cv.active_ind=1)
  DETAIL
   product_aborh_cd = cv.code_value,
   CALL echo(product_aborh_cd)
  WITH counter
 ;end select
 IF (person_aborh_cd > 0)
  SELECT INTO "nl:"
   p.product_cd, per.product_cd
   FROM product_aborh p,
    product_patient_aborh per
   PLAN (p
    WHERE (p.product_cd=request->product_cd)
     AND p.product_aborh_cd=product_aborh_cd
     AND p.active_ind=1)
    JOIN (per
    WHERE per.product_cd=p.product_cd
     AND per.prod_aborh_cd=product_aborh_cd
     AND per.prsn_aborh_cd=person_aborh_cd
     AND per.active_ind=1)
   DETAIL
    reply->no_gt_on_prsn_flag = - (2), reply->no_gt_autodir_prsn_flag = - (2), reply->
    bbd_no_gt_dir_prsn_flag = - (2),
    reply->warn_ind = per.warn_ind, reply->no_compatibility_ind = - (2)
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->no_compatibility_ind = 1
  ENDIF
 ELSE
  SELECT INTO "nl:"
   p.product_cd
   FROM product_aborh p
   WHERE (p.product_cd=request->product_cd)
    AND p.product_aborh_cd=product_aborh_cd
    AND p.active_ind=1
   DETAIL
    reply->no_gt_on_prsn_flag = p.no_gt_on_prsn_flag, reply->no_gt_autodir_prsn_flag = p
    .no_gt_autodir_prsn_flag, reply->bbd_no_gt_dir_prsn_flag = p.bbd_no_gt_dir_prsn_flag,
    reply->warn_ind = - (2), reply->no_compatibility_ind = - (2)
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->no_gt_on_prsn_flag = 0
   SET reply->no_gt_autodir_prsn_flag = 0
   SET reply->bbd_no_gt_dir_prsn_flag = 0
   SET reply->warn_ind = - (2)
   SET reply->no_compatibility_ind = - (2)
  ENDIF
 ENDIF
END GO
