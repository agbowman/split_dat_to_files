CREATE PROGRAM bbt_chg_spec_testing:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE exist_count = i4 WITH protect, noconstant(0)
 DECLARE hold_spec_tests_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_count = i4 WITH protect, noconstant(0)
 DECLARE next_code = f8 WITH protect, noconstant(0.0)
 DECLARE corr_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET chg_demogr_cd = 0.0
 SET emerg_dispense_cd = 0.0
 SET chg_state_cd = 0.0
 SET unlock_prod_cd = 0.0
 SET spec_test_cd = 0.0
 SET chg_pool_cd = 0.0
 SET chg_reconrbc_cd = 0.0
 SET chg_disp_prod_order_cd = 0.0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=14115
   AND c.active_ind=1
  DETAIL
   IF (c.cdf_meaning="DEMOG")
    chg_demogr_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="ERDIS")
    emerg_dispense_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="STATE")
    chg_state_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="UNLOCK")
    unlock_prod_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="SPECTEST")
    spec_test_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="POOL")
    chg_pool_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="RECONRBC")
    chg_reconrbc_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="DISPPRODORD")
    chg_disp_prod_order_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.*
  FROM product p
  WHERE (p.product_id=request->product_id)
   AND (p.updt_cnt=request->updt_cnt)
   AND p.active_ind=1
  WITH counter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET count2 += 1
  SET reply->status_data.subeventstatus[count2].operationname = "Lock"
  SET reply->status_data.subeventstatus[count2].operationstatus = "F"
  SET reply->status_data.subeventstatus[count2].targetobjectname = "Product"
  SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,32,
   2)
  GO TO exit_script
 ELSE
  UPDATE  FROM product p
   SET p.locked_ind = 0, p.updt_cnt = (request->updt_cnt+ 1), p.corrected_ind = 1,
    p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
    updt_task,
    p.updt_applctx = reqinfo->updt_applctx
   WHERE (p.product_id=request->product_id)
    AND (p.updt_cnt=request->updt_cnt)
    AND p.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET count2 += 1
   SET reply->status_data.subeventstatus[count2].operationname = "update"
   SET reply->status_data.subeventstatus[count2].operationstatus = "F"
   SET reply->status_data.subeventstatus[count2].targetobjectname = "product"
   SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,
    32,2)
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET corr_id = new_pathnet_seq
 INSERT  FROM corrected_product cp
  SET cp.correction_id = corr_id, cp.product_id = request->product_id, cp.correction_type_cd =
   spec_test_cd,
   cp.correction_reason_cd = request->corr_reason_cd, cp.correction_note = request->corr_note, cp
   .product_nbr = null,
   cp.product_sub_nbr = null, cp.alternate_nbr = null, cp.product_cd = 0,
   cp.product_class_cd = 0, cp.product_cat_cd = 0, cp.supplier_id = 0,
   cp.recv_dt_tm = null, cp.volume = null, cp.unit_meas_cd = 0,
   cp.expire_dt_tm = null, cp.abo_cd = 0, cp.rh_cd = 0,
   cp.segment_nbr = null, cp.orig_updt_cnt = request->orig_updt_cnt, cp.orig_updt_dt_tm =
   cnvtdatetime(request->orig_updt_dt_tm),
   cp.orig_updt_id = request->orig_updt_id, cp.orig_updt_task = request->orig_updt_task, cp
   .orig_updt_applctx = request->orig_updt_applctx,
   cp.product_event_id = 0, cp.event_dt_tm = null, cp.reason_cd = 0,
   cp.autoclave_ind = null, cp.destruction_method_cd = 0, cp.destruction_org_id = 0,
   cp.manifest_nbr = null, cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate),
   cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->
   updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET count2 += 1
  SET reply->status_data.subeventstatus[count2].operationname = "update"
  SET reply->status_data.subeventstatus[count2].operationstatus = "F"
  SET reply->status_data.subeventstatus[count2].targetobjectname = "corrected product"
  SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,32,
   2)
  GO TO exit_script
 ENDIF
 FOR (exist_count = 1 TO request->exist_count)
   SELECT INTO "nl:"
    s.*
    FROM special_testing s
    WHERE (s.special_testing_id=request->exist_list[exist_count].special_testing_id)
     AND (s.updt_cnt=request->exist_list[exist_count].spec_test_updt_cnt)
     AND s.active_ind=1
    WITH counter, forupdate(s)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "Lock"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "Special Testing"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,
     32,2)
    GO TO exit_script
   ENDIF
   UPDATE  FROM special_testing s
    SET s.active_ind = 0, s.updt_cnt = (s.updt_cnt+ 1), s.updt_dt_tm = cnvtdatetime(sysdate),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx
    WHERE (s.special_testing_id=request->exist_list[exist_count].special_testing_id)
     AND (s.updt_cnt=request->exist_list[exist_count].spec_test_updt_cnt)
     AND s.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "update"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "special testing"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,
     32,2)
    GO TO exit_script
   ENDIF
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM corrected_special_tests c
    SET c.correct_spec_tests_id = new_pathnet_seq, c.orig_special_testing_id = request->exist_list[
     exist_count].special_testing_id, c.correction_id = corr_id,
     c.special_testing_cd = request->exist_list[exist_count].special_testing_cd, c.new_spec_test_ind
      = 0, c.updt_cnt = 0,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "insert"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "corrected spec testing1"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,
     32,2)
    GO TO exit_script
   ENDIF
 ENDFOR
 FOR (new_count = 1 TO request->new_count)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   SET hold_spec_tests_id = new_pathnet_seq
   INSERT  FROM special_testing s
    SET s.special_testing_id = new_pathnet_seq, s.product_id = request->product_id, s
     .special_testing_cd = request->new_list[new_count].special_testing_cd,
     s.confirmed_ind = request->new_list[new_count].confirmed_ind, s.updt_cnt = 0, s.updt_dt_tm =
     cnvtdatetime(sysdate),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx,
     s.active_ind = 1, s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm =
     cnvtdatetime(sysdate),
     s.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "insert"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "special testing"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,
     32,2)
    GO TO exit_script
   ENDIF
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM corrected_special_tests c
    SET c.correct_spec_tests_id = new_pathnet_seq, c.orig_special_testing_id = hold_spec_tests_id, c
     .correction_id = corr_id,
     c.special_testing_cd = request->new_list[new_count].special_testing_cd, c.new_spec_test_ind = 1,
     c.updt_cnt = 0,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count2 += 1
    SET reply->status_data.subeventstatus[count2].operationname = "insert"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "corrected spec testing2"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = cnvtstring(request->product_id,
     32,2)
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "T"
 ENDIF
END GO
