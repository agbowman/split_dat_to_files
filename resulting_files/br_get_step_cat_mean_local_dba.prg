CREATE PROGRAM br_get_step_cat_mean_local:dba
 FREE SET reply
 RECORD reply(
   1 sclist[*]
     2 step_cat_mean = vc
     2 step_cat_disp = vc
     2 selected_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET lcnt = 0
 SET new_security = 0
 SELECT INTO "NL"
  FROM br_name_value b
  WHERE b.br_nv_key1="SOLUTION_STATUS"
  HEAD REPORT
   new_security = 1
  WITH nocounter
 ;end select
 IF (new_security=0)
  SELECT INTO "nl:"
   FROM br_name_value bnv
   PLAN (bnv
    WHERE bnv.br_nv_key1="STEP_CAT_MEAN")
   ORDER BY bnv.br_value
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->sclist,cnt), reply->sclist[cnt].step_cat_mean = bnv
    .br_name,
    reply->sclist[cnt].step_cat_disp = bnv.br_value, reply->sclist[cnt].selected_ind = bnv
    .default_selected_ind
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_name_value bnv1,
    br_name_value bnv2
   PLAN (bnv1
    WHERE bnv1.br_nv_key1="STEP_CAT_MEAN")
    JOIN (bnv2
    WHERE bnv2.br_nv_key1=outerjoin("SOLUTION_STATUS")
     AND bnv2.br_value=outerjoin(bnv1.br_name))
   ORDER BY bnv1.br_value
   HEAD bnv1.br_value
    cnt = (cnt+ 1), stat = alterlist(reply->sclist,cnt), reply->sclist[cnt].step_cat_mean = bnv1
    .br_name,
    reply->sclist[cnt].step_cat_disp = bnv1.br_value, reply->sclist[cnt].selected_ind = 0
   DETAIL
    IF (bnv2.br_name_value_id > 0)
     IF (bnv2.br_name="LIVE_IN_PROD")
      reply->sclist[cnt].selected_ind = 1
     ELSEIF (bnv2.br_name="GOING_LIVE")
      reply->sclist[cnt].selected_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
