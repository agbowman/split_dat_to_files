CREATE PROGRAM bbt_chg_product_patient_comp:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET person_aborh_cnt = request->person_aborh_cnt
 SET cur_updt_cnt = 0
 SET y = 1
 IF ((request->person_flag="F")
  AND (request->product_flag="F"))
  SET reply->status_data.status = "P"
  GO TO exit_script
 ENDIF
 IF ((request->product_flag="T"))
  SELECT INTO "nl:"
   p.*
   FROM product_aborh p
   WHERE (p.product_cd=request->product_cd)
    AND (p.product_aborh_cd=request->product_aborh_cd)
    AND (p.sequence_nbr=request->prod_sequence_nbr)
   DETAIL
    cur_updt_cnt = p.updt_cnt
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->person_flag="T"))
  FOR (x = 1 TO person_aborh_cnt)
   SELECT INTO "nl:"
    per.*
    FROM product_patient_aborh per
    WHERE (per.product_cd=request->product_cd)
     AND (per.prod_aborh_cd=request->product_aborh_cd)
     AND (per.prsn_aborh_cd=request->person_aborh_data[x].person_aborh_cd)
     AND (per.sequence_nbr=request->person_aborh_data[x].prsn_sequence_nbr)
     AND per.active_ind=1
    WITH nocounter, forupdate(per)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF ((request->product_flag="T"))
  UPDATE  FROM product_aborh p
   SET p.product_cd = request->product_cd, p.product_aborh_cd = request->product_aborh_cd, p
    .sequence_nbr = request->prod_sequence_nbr,
    p.no_gt_on_prsn_flag = request->no_gt_on_prsn_flag, p.no_gt_autodir_prsn_flag = request->
    no_ad_on_prsn_flag, p.disp_no_curraborh_prsn_flag = request->disp_no_curraborh_prsn_flag,
    p.active_ind = request->prod_active_ind, p.active_status_cd = reqdata->active_status_cd, p
    .updt_cnt = (p.updt_cnt+ 1),
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
    reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.aborh_option_flag = request->aborh_indicator
   WHERE (p.product_cd=request->product_cd)
    AND (p.product_aborh_cd=request->product_aborh_cd)
    AND (p.sequence_nbr=request->prod_sequence_nbr)
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->person_flag="T"))
  FOR (y = 1 TO person_aborh_cnt)
   UPDATE  FROM product_patient_aborh per
    SET per.product_cd = request->product_cd, per.prod_aborh_cd = request->product_aborh_cd, per
     .prsn_aborh_cd = request->person_aborh_data[y].person_aborh_cd,
     per.sequence_nbr = request->person_aborh_data[y].prsn_sequence_nbr, per.active_ind = 0, per
     .active_status_cd = reqdata->active_status_cd,
     per.warn_ind = request->person_aborh_data[y].warn_indicator, per.updt_cnt = (per.updt_cnt+ 1),
     per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     per.updt_id = reqinfo->updt_id, per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->
     updt_applctx
    WHERE (per.product_cd=request->product_cd)
     AND (per.prod_aborh_cd=request->product_aborh_cd)
     AND (per.prsn_aborh_cd=request->person_aborh_data[y].person_aborh_cd)
     AND (per.sequence_nbr=request->person_aborh_data[y].prsn_sequence_nbr)
     AND per.active_ind=1
   ;end update
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF ((((reply->status_data.status="P")) OR ((reply->status_data.status="F"))) )
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
