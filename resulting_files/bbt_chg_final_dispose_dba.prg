CREATE PROGRAM bbt_chg_final_dispose:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE next_code = f8 WITH protect, noconstant(0.0)
 DECLARE corr_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 DECLARE ddemogcd = f8 WITH protect, noconstant(0.0)
 DECLARE derdiscd = f8 WITH protect, noconstant(0.0)
 DECLARE dunlockcd = f8 WITH protect, noconstant(0.0)
 DECLARE ddispcd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  p.*
  FROM product p
  WHERE (p.product_id=request->product_id)
   AND (p.updt_cnt=request->product_updt_cnt)
   AND p.active_ind=1
  WITH counter, forupdate(p)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "Lock"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 UPDATE  FROM product p
  SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.corrected_ind = 1,
   p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
   updt_task,
   p.updt_applctx = reqinfo->updt_applctx
  WHERE (p.product_id=request->product_id)
   AND (p.updt_cnt=request->product_updt_cnt)
   AND p.active_ind=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product Table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET ddemogcd = uar_get_code_by("MEANING",14115,"DEMOG")
 SET derdiscd = uar_get_code_by("MEANING",14115,"ERDIS")
 SET ddispcd = uar_get_code_by("MEANING",14115,"FINALDISP")
 SET dunlockcd = uar_get_code_by("MEANING",14115,"UNLOCK")
 IF ((request->dispose_ind="T"))
  IF ((request->dispose_event_ind="T"))
   SELECT INTO "nl:"
    p.*
    FROM product_event p
    WHERE (p.product_id=request->product_id)
     AND (p.product_event_id=request->dispose_product_event_id)
     AND (p.updt_cnt=request->dispose_pe_updt_cnt)
     AND (p.active_ind=request->dispose_pe_active_ind)
    WITH counter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product event"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->dispose_table_ind="T"))
   SELECT INTO "nl:"
    d.*
    FROM disposition d
    WHERE (d.product_id=request->product_id)
     AND (d.product_event_id=request->dispose_product_event_id)
     AND (d.updt_cnt=request->dispose_d_updt_cnt)
    WITH counter, forupdate(d)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "disposition"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Disposition"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->dispose_event_ind="T"))
   UPDATE  FROM product_event p
    SET p.event_dt_tm = cnvtdatetime(request->dispose_dt_tm), p.updt_cnt = (p.updt_cnt+ 1), p
     .updt_dt_tm = cnvtdatetime(sysdate),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx,
     p.event_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    WHERE (p.product_id=request->product_id)
     AND (p.product_event_id=request->dispose_product_event_id)
     AND (p.updt_cnt=request->dispose_pe_updt_cnt)
     AND (p.active_ind=request->dispose_pe_active_ind)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product Table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->dispose_table_ind="T"))
   UPDATE  FROM disposition d
    SET d.reason_cd = request->dispose_reason_cd, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm =
     cnvtdatetime(sysdate),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx
    WHERE (d.product_id=request->product_id)
     AND (d.product_event_id=request->dispose_product_event_id)
     AND (d.updt_cnt=request->dispose_d_updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "disposition"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Disposition Table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  SET new_pathnet_seq = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)"###########################;rp0"
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET corr_id = new_pathnet_seq
  INSERT  FROM corrected_product cp
   SET cp.correction_id = corr_id, cp.product_id = request->product_id, cp.correction_type_cd =
    IF ((request->correction_mode="DEMOG")) ddemogcd
    ELSEIF ((request->correction_mode="ERDIS")) derdiscd
    ELSEIF ((request->correction_mode="FINAL")) ddispcd
    ELSE dunlockcd
    ENDIF
    ,
    cp.correction_reason_cd = request->corr_reason_cd, cp.product_nbr = null, cp.product_sub_nbr =
    null,
    cp.alternate_nbr = null, cp.product_cd = 0, cp.product_class_cd = 0,
    cp.product_cat_cd = 0, cp.supplier_id = 0, cp.recv_dt_tm = null,
    cp.volume = null, cp.unit_meas_cd = 0, cp.expire_dt_tm = null,
    cp.abo_cd = 0, cp.rh_cd = 0, cp.segment_nbr = null,
    cp.orig_updt_cnt = request->disp_orig_updt_cnt, cp.orig_updt_dt_tm = cnvtdatetime(request->
     orig_dispose_dt_tm), cp.orig_updt_id =
    IF ((request->disp_orig_updt_id > - (1))) request->disp_orig_updt_id
    ELSE 0
    ENDIF
    ,
    cp.orig_updt_task = request->disp_orig_updt_task, cp.orig_updt_applctx = request->
    disp_orig_updt_applctx, cp.correction_note =
    IF ((request->corr_note="-1")) null
    ELSE request->corr_note
    ENDIF
    ,
    cp.unknown_patient_text = null, cp.event_dt_tm =
    IF ((request->disp_orig_updt_dt_tm=- (1))) null
    ELSE cnvtdatetime(request->disp_orig_updt_dt_tm)
    ENDIF
    , cp.reason_cd = request->orig_dispose_reason_cd,
    cp.autoclave_ind = - (2), cp.destruction_method_cd = 0, cp.destruction_org_id = 0,
    cp.destruction_org_id_flag = 2, cp.manifest_nbr = null, cp.product_event_id =
    IF ((request->dispose_product_event_id > - (1))) request->dispose_product_event_id
    ELSE 0
    ENDIF
    ,
    cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id,
    cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "corrected product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Corrected Product Table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->destruction_ind="T"))
  IF ((request->destruction_event_ind="T"))
   SELECT INTO "nl:"
    p.*
    FROM product_event p
    WHERE (p.product_id=request->product_id)
     AND (p.product_event_id=request->destruction_product_event_id)
     AND (p.updt_cnt=request->destruction_pe_updt_cnt)
     AND (p.active_ind=request->destruction_pe_active_ind)
    WITH counter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product_event"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product Event Table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->destruction_table_ind="T"))
   SELECT INTO "nl:"
    d.*
    FROM destruction d
    WHERE (d.product_id=request->product_id)
     AND (d.product_event_id=request->destruction_product_event_id)
     AND (d.updt_cnt=request->destruction_d_updt_cnt)
    WITH counter, forupdate(d)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "destruction"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Destruction Table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->destruction_event_ind="T"))
   UPDATE  FROM product_event p
    SET p.event_dt_tm = cnvtdatetime(request->destruction_dt_tm), p.updt_cnt = (p.updt_cnt+ 1), p
     .updt_dt_tm = cnvtdatetime(sysdate),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx,
     p.event_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
    WHERE (p.product_id=request->product_id)
     AND (p.product_event_id=request->destruction_product_event_id)
     AND (p.updt_cnt=request->destruction_pe_updt_cnt)
     AND (p.active_ind=request->destruction_pe_active_ind)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product event2"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Product Event Table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->destruction_table_ind="T"))
   UPDATE  FROM destruction d
    SET d.method_cd =
     IF ((request->destruction_method_cd=- (1))) d.method_cd
     ELSE request->destruction_method_cd
     ENDIF
     , d.autoclave_ind =
     IF ((request->autoclave_ind=- (1))) d.autoclave_ind
     ELSE request->autoclave_ind
     ENDIF
     , d.manifest_nbr =
     IF ((request->manifest_nbr="-1")) d.manifest_nbr
     ELSE request->manifest_nbr
     ENDIF
     ,
     d.destruction_org_id =
     IF ((request->destruction_org_id=- (1))) d.destruction_org_id
     ELSE request->destruction_org_id
     ENDIF
     , d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(sysdate),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx
    WHERE (d.product_id=request->product_id)
     AND (d.product_event_id=request->destruction_product_event_id)
     AND (d.updt_cnt=request->destruction_d_updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "destruction"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Destruction Table"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDIF
  SET new_pathnet_seq = 0.0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)"###########################;rp0"
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET corr_id = new_pathnet_seq
  INSERT  FROM corrected_product cp
   SET cp.correction_id = corr_id, cp.product_id = request->product_id, cp.correction_type_cd =
    IF ((request->correction_mode="DEMOG")) ddemogcd
    ELSEIF ((request->correction_mode="ERDIS")) derdiscd
    ELSEIF ((request->correction_mode="FINAL")) ddispcd
    ELSE dunlockcd
    ENDIF
    ,
    cp.correction_reason_cd = request->corr_reason_cd, cp.product_nbr = null, cp.product_sub_nbr =
    null,
    cp.alternate_nbr = null, cp.product_cd = 0, cp.product_class_cd = 0,
    cp.product_cat_cd = 0, cp.supplier_id = 0, cp.recv_dt_tm = null,
    cp.volume = null, cp.unit_meas_cd = 0, cp.expire_dt_tm = null,
    cp.abo_cd = 0, cp.rh_cd = 0, cp.segment_nbr = null,
    cp.orig_updt_cnt = request->dest_orig_updt_cnt, cp.orig_updt_dt_tm =
    IF ((request->orig_destruction_dt_tm=0.0)) null
    ELSE cnvtdatetime(request->orig_destruction_dt_tm)
    ENDIF
    , cp.orig_updt_id =
    IF ((request->dest_orig_updt_id > - (1))) request->dest_orig_updt_id
    ELSE 0
    ENDIF
    ,
    cp.orig_updt_task = request->dest_orig_updt_task, cp.orig_updt_applctx = request->
    dest_orig_updt_applctx, cp.correction_note =
    IF ((request->corr_note="-1")) null
    ELSE request->corr_note
    ENDIF
    ,
    cp.unknown_patient_text = null, cp.event_dt_tm =
    IF ((request->dest_orig_updt_dt_tm=0.0)) null
    ELSE cnvtdatetime(request->dest_orig_updt_dt_tm)
    ENDIF
    , cp.reason_cd = 0,
    cp.autoclave_ind = request->orig_autoclave_ind, cp.destruction_method_cd = request->
    orig_destruction_method_cd, cp.destruction_org_id =
    IF ((request->orig_destruction_org_id > - (1))) request->orig_destruction_org_id
    ELSE 0
    ENDIF
    ,
    cp.destruction_org_id_flag =
    IF ((request->orig_destruction_org_id > - (1))) 1
    ELSE 2
    ENDIF
    , cp.manifest_nbr = request->orig_manifest_nbr, cp.product_event_id =
    IF ((request->destruction_product_event_id > - (1))) request->destruction_product_event_id
    ELSE 0
    ENDIF
    ,
    cp.updt_cnt = 0, cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id,
    cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_final_dispose"
   SET reply->status_data.subeventstatus[1].operationname = "update2"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "corrected product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Corrected Product Table"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "T"
 ENDIF
END GO
