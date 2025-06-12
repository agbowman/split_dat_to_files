CREATE PROGRAM bbt_chg_trans_req_r:dba
 RECORD reply(
   1 qual[1]
     2 relationship_id = f8
     2 requirement_cd = f8
     2 special_testing_cd = f8
     2 warn_ind = i2
     2 override_ind = i2
     2 updt_cnt = i4
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 excluded_prod_cat_qual[*]
     2 excld_trans_req_prod_cat_r_id = f8
     2 requirement_cd = f8
     2 prod_cat_cd = f8
     2 updt_cnt = i4
     2 status = c1
 )
 DECLARE addexcludedprodcatupdatestatus(repidx=i4,updt_cnt=i4,updt_status=c1) = null
 SET reply->status_data.status = "F"
 SET cur_updt_cn = 0
 SET cur_active_ind = 0
 SET failed = "F"
 SET count1 = 0
 SET nbr_to_chg = size(request->qual,5)
 SET failures = 0
 SET cur_updt_cnt = 0
 SET x = 1
 SET y = 1
#start_loop
 FOR (y = y TO nbr_to_chg)
   IF ((request->qual[y].relationship_id > 0))
    SELECT INTO "nl:"
     t.*
     FROM trans_req_r t
     WHERE (t.relationship_id=request->qual[y].relationship_id)
     HEAD REPORT
      count1 = 0
     DETAIL
      cur_updt_cnt = t.updt_cnt, cur_active_ind = t.active_ind
     WITH nocounter, forupdate(t)
    ;end select
   ENDIF
   IF (((curqual=0) OR ((request->qual[y].relationship_id=0))) )
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    INSERT  FROM trans_req_r t
     SET t.relationship_id = new_pathnet_seq, t.requirement_cd = request->qual[y].requirement_cd, t
      .special_testing_cd = request->qual[y].special_testing_cd,
      t.warn_ind = request->qual[y].warn_ind, t.allow_override_ind = request->qual[y].override_ind, t
      .active_ind = 1,
      t.active_status_dt_tm = cnvtdatetime(curdate,curtime3), t.active_status_cd = reqdata->
      active_status_cd, t.active_status_prsnl_id = reqinfo->updt_id,
      t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->updt_id, t.updt_task =
      reqinfo->updt_task,
      t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO next_code
    ELSE
     SET count1 = (count1+ 1)
     SET stat = alter(reply->qual,count1)
     SET reply->qual[count1].relationship_id = request->qual[y].relationship_id
     SET reply->qual[count1].requirement_cd = request->qual[y].requirement_cd
     SET reply->qual[count1].special_testing_cd = request->qual[y].special_testing_cd
     SET reply->qual[count1].warn_ind = request->qual[y].warn_ind
     SET reply->qual[count1].override_ind = request->qual[y].override_ind
     SET reply->qual[count1].updt_cnt = 0
     SET reply->qual[count1].status = "S"
     COMMIT
     SET y = (y+ 1)
     GO TO start_loop
    ENDIF
   ENDIF
   IF ((request->qual[y].updt_cnt != cur_updt_cnt))
    GO TO next_code
   ENDIF
   UPDATE  FROM trans_req_r t
    SET t.active_ind =
     IF ((request->qual[y].updt_ind=2)) 0
     ELSE 1
     ENDIF
     , t.active_status_dt_tm =
     IF (cur_active_ind=1) t.active_status_dt_tm
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     , t.active_status_cd = reqdata->active_status_cd,
     t.active_status_prsnl_id = reqinfo->updt_id, t.warn_ind = request->qual[y].warn_ind, t
     .allow_override_ind = request->qual[y].override_ind,
     t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo
     ->updt_id,
     t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
    WHERE (t.relationship_id=request->qual[y].relationship_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    GO TO next_code
   ENDIF
   SET count1 = (count1+ 1)
   SET stat = alter(reply->qual,count1)
   SET reply->qual[count1].requirement_cd = request->qual[y].requirement_cd
   SET reply->qual[count1].special_testing_cd = request->qual[y].special_testing_cd
   SET reply->qual[count1].warn_ind = request->qual[y].warn_ind
   SET reply->qual[count1].override_ind = request->qual[y].override_ind
   SET reply->qual[count1].updt_cnt = (cur_updt_cnt+ 1)
   SET reply->qual[count1].status = "S"
   COMMIT
 ENDFOR
 GO TO start_prod_cat_assoc
#next_code
 SET failures = (failures+ 1)
 IF (failures > 1)
  SET stat = alter(reply->status_data.subeventstatus,failures)
 ENDIF
 SET count1 = (count1+ 1)
 SET stat = alter(reply->qual,count1)
 SET reply->qual[count1].requirement_cd = request->qual[y].requirement_cd
 SET reply->qual[count1].special_testing_cd = request->qual[y].special_testing_cd
 SET reply->qual[count1].warn_ind = request->qual[y].warn_ind
 SET reply->qual[count1].override_ind = request->qual[y].override_ind
 SET reply->qual[count1].updt_cnt = cur_updt_cnt
 SET reply->qual[count1].status = "F"
 IF (failed="F")
  SET reply->status_data.subeventstatus[failures].operationstatus = "F"
 ELSE
  SET reply->status_data.subeventstatus[failures].operationstatus = "C"
 ENDIF
 SET reply->status_data.subeventstatus[failures].targetobjectvalue = cnvtstring(request->qual[y].
  special_testing_cd,32,2)
 ROLLBACK
 SET y = (y+ 1)
 GO TO start_loop
#start_prod_cat_assoc
 SET nbr_to_chg = size(request->excluded_prod_cat_qual,5)
 IF (nbr_to_chg > 0)
  SET stat = alterlist(reply->excluded_prod_cat_qual,nbr_to_chg)
 ENDIF
 SET y = 1
#start_prod_cat_assoc_loop
 FOR (y = y TO nbr_to_chg)
   IF ((request->excluded_prod_cat_qual[y].excld_trans_req_prod_cat_r_id > 0))
    SELECT INTO "nl:"
     etp.*
     FROM excld_trans_req_prod_cat_r etp
     WHERE (etp.excld_trans_req_prod_cat_r_id=request->excluded_prod_cat_qual[y].
     excld_trans_req_prod_cat_r_id)
     HEAD REPORT
      count1 = 0
     DETAIL
      cur_updt_cnt = etp.updt_cnt, cur_active_ind = etp.active_ind
     WITH nocounter, forupdate(etp)
    ;end select
   ENDIF
   IF (((curqual=0) OR ((request->excluded_prod_cat_qual[y].excld_trans_req_prod_cat_r_id=0))) )
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    INSERT  FROM excld_trans_req_prod_cat_r etp
     SET etp.excld_trans_req_prod_cat_r_id = new_pathnet_seq, etp.product_cat_cd = request->
      excluded_prod_cat_qual[y].prod_cat_cd, etp.requirement_cd = request->excluded_prod_cat_qual[y].
      requirement_cd,
      etp.active_ind = 1, etp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .active_status_cd = reqdata->active_status_cd,
      etp.active_status_prsnl_id = reqinfo->updt_id, etp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      etp.updt_id = reqinfo->updt_id,
      etp.updt_task = reqinfo->updt_task, etp.updt_applctx = reqinfo->updt_applctx, etp.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO prod_cat_assoc_updt_err
    ELSE
     CALL addexcludedprodcatupdatestatus(y,0,"S")
     COMMIT
     SET y = (y+ 1)
     GO TO start_prod_cat_assoc_loop
    ENDIF
   ENDIF
   IF ((request->excluded_prod_cat_qual[y].updt_cnt != cur_updt_cnt))
    GO TO prod_cat_assoc_updt_err
   ENDIF
   UPDATE  FROM excld_trans_req_prod_cat_r etp
    SET etp.active_ind =
     IF ((request->excluded_prod_cat_qual[y].updt_ind=2)) 0
     ELSE 1
     ENDIF
     , etp.active_status_dt_tm =
     IF (cur_active_ind=1) etp.active_status_dt_tm
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     , etp.active_status_cd = reqdata->active_status_cd,
     etp.active_status_prsnl_id = reqinfo->updt_id, etp.updt_cnt = (etp.updt_cnt+ 1), etp.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     etp.updt_id = reqinfo->updt_id, etp.updt_task = reqinfo->updt_task, etp.updt_applctx = reqinfo->
     updt_applctx
    WHERE (etp.excld_trans_req_prod_cat_r_id=request->excluded_prod_cat_qual[y].
    excld_trans_req_prod_cat_r_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    GO TO prod_cat_assoc_updt_err
   ENDIF
   CALL addexcludedprodcatupdatestatus(y,(cur_updt_cnt+ 1),"S")
   COMMIT
 ENDFOR
 GO TO exit_script
#prod_cat_assoc_updt_err
 CALL addexcludedprodcatupdatestatus(y,cur_updt_cnt,"F")
 SET failures = (failures+ 1)
 IF (failures > 1)
  SET stat = alter(reply->status_data.subeventstatus,failures)
 ENDIF
 IF (failed="F")
  SET reply->status_data.subeventstatus[failures].operationstatus = "F"
 ELSE
  SET reply->status_data.subeventstatus[failures].operationstatus = "C"
 ENDIF
 SET reply->status_data.subeventstatus[failures].targetobjectname = "EXCLD_TRANS_REQ_PROD_CAT_R"
 SET reply->status_data.subeventstatus[failures].targetobjectvalue = build(
  "Failed to insert or update record with product category id of (",cnvtstring(request->
   excluded_prod_cat_qual[y].prod_cat_cd,32,2),") and requirement id of ( ",cnvtstring(request->
   excluded_prod_cat_qual[y].requirement_cd,32,2),").")
 ROLLBACK
 SET y = (y+ 1)
 GO TO start_prod_cat_assoc_loop
#exit_script
 IF (failures > 0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE addexcludedprodcatupdatestatus(repidx,updt_cnt,updt_status)
   SET reply->excluded_prod_cat_qual[repidx].excld_trans_req_prod_cat_r_id = request->
   excluded_prod_cat_qual[repidx].excld_trans_req_prod_cat_r_id
   SET reply->excluded_prod_cat_qual[repidx].prod_cat_cd = request->excluded_prod_cat_qual[repidx].
   prod_cat_cd
   SET reply->excluded_prod_cat_qual[repidx].requirement_cd = request->excluded_prod_cat_qual[repidx]
   .requirement_cd
   SET reply->excluded_prod_cat_qual[repidx].updt_cnt = updt_cnt
   SET reply->excluded_prod_cat_qual[repidx].status = updt_status
 END ;Subroutine
END GO
