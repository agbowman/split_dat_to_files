CREATE PROGRAM bbt_add_product_patient_comp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 person_aborh_data[1]
      2 person_aborh_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET number_of_person_aborh = 0
 SET stat = alter(reply->person_aborh_data,request->person_aborh_cnt)
 SET failures = 0
 SET y = 1
 SET product_exist_cnt = 1
 SET person_exist_cnt = 1
 SET continue_product = "T"
 SET continue_person = "T"
 IF ((request->product_status=0))
  GO TO insert_person
 ENDIF
 WHILE (continue_product="T")
  SELECT INTO "nl:"
   p.*
   FROM product_aborh p
   WHERE (p.product_cd=request->product_cd)
    AND (p.product_aborh_cd=request->product_aborh_cd)
    AND p.active_ind=0
    AND p.sequence_nbr=product_exist_cnt
  ;end select
  IF (curqual != 0)
   SET product_exist_cnt = (product_exist_cnt+ 1)
  ELSE
   SET continue_product = "N"
  ENDIF
 ENDWHILE
#insert_product
 INSERT  FROM product_aborh p
  SET p.product_cd = request->product_cd, p.product_aborh_cd = request->product_aborh_cd, p
   .sequence_nbr = product_exist_cnt,
   p.no_gt_on_prsn_flag = request->no_gt_on_prsn_flag, p.no_gt_autodir_prsn_flag = request->
   no_ad_on_prsn_flag, p.disp_no_curraborh_prsn_flag = request->disp_no_curraborh_prsn_flag,
   p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_prsnl_id =
   reqinfo->updt_id,
   p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.aborh_option_flag =
   request->aborh_indicator
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failures = 1
  GO TO exit_script
 ENDIF
#insert_person
 SET number_of_person_aborh = request->person_aborh_cnt
 FOR (y = 1 TO number_of_person_aborh)
   SET person_exist_cnt = 1
   SET continue_person = "T"
   WHILE (continue_person="T")
    SELECT INTO "nl:"
     per.sequence_nbr
     FROM product_patient_aborh per
     WHERE (per.product_cd=request->product_cd)
      AND (per.prod_aborh_cd=request->product_aborh_cd)
      AND (per.prsn_aborh_cd=request->person_aborh_data[y].person_aborh_cd)
      AND per.active_ind=0
      AND per.sequence_nbr=person_exist_cnt
    ;end select
    IF (curqual != 0)
     SET person_exist_cnt = (person_exist_cnt+ 1)
    ELSE
     SET continue_person = "F"
    ENDIF
   ENDWHILE
   INSERT  FROM product_patient_aborh prs
    SET prs.product_cd = request->product_cd, prs.prod_aborh_cd = request->product_aborh_cd, prs
     .prsn_aborh_cd = request->person_aborh_data[y].person_aborh_cd,
     prs.sequence_nbr = person_exist_cnt, prs.active_ind = 1, prs.active_status_cd = reqdata->
     active_status_cd,
     prs.active_status_prsnl_id = reqinfo->updt_id, prs.warn_ind = request->person_aborh_data[y].
     warn_indicator, prs.updt_cnt = 0,
     prs.updt_dt_tm = cnvtdatetime(curdate,curtime3), prs.updt_id = reqinfo->updt_id, prs.updt_task
      = reqinfo->updt_task,
     prs.updt_applctx = reqinfo->updt_applctx
   ;end insert
   SET reply->person_aborh_data[y].person_aborh_cd = request->person_aborh_data[y].person_aborh_cd
   IF (curqual=0)
    SET failures = 1
    GO TO exit_script
   ENDIF
 ENDFOR
 COMMIT
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ELSE
  ROLLBACK
  SET reply->status_data.status = "F"
 ENDIF
END GO
