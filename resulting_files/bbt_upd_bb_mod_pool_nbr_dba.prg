CREATE PROGRAM bbt_upd_bb_mod_pool_nbr:dba
 RECORD reply(
   1 product_nbr = c20
   1 sequence = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE yr = i2 WITH protect, noconstant(0)
 DECLARE yr_size = i2 WITH protect, noconstant(0)
 DECLARE ptr = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 RECORD mod_opt(
   1 prod_nbr_prefix = vc
   1 prod_nbr_ccyy_ind = i2
 )
 RECORD prod_nbr(
   1 mod_pool_nbr_id = f8
   1 prefix = vc
   1 year = i2
   1 seq_nbr = i4
   1 isbt_barcode = c15
 )
 IF ((request->isbt_ind=0))
  SELECT INTO "nl:"
   mo.option_id
   FROM bb_mod_option mo
   PLAN (mo
    WHERE (mo.option_id=request->option_id)
     AND mo.active_ind=1)
   DETAIL
    mod_opt->prod_nbr_prefix = mo.prod_nbr_prefix, mod_opt->prod_nbr_ccyy_ind = mo.prod_nbr_ccyy_ind
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("SELECT","F","BB_MOD_OPTION",errmsg)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET errmsg = "Modification option not found."
   CALL errorhandler("SELECT","F","BB_MOD_OPTION",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SET yr = year(cnvtdatetime(curdate,curtime3))
 SELECT
  IF ((request->isbt_ind=0))
   PLAN (mpn
    WHERE (mpn.option_id=request->option_id)
     AND (mpn.prefix=mod_opt->prod_nbr_prefix)
     AND mpn.year=yr)
  ELSEIF ((request->isbt_ind=1))
   PLAN (mpn
    WHERE (mpn.option_id=request->option_id)
     AND mpn.year=yr
     AND (mpn.isbt_supplier_fin=request->isbt_fin_nbr))
  ELSE
  ENDIF
  INTO "nl:"
  mpn.mod_pool_nbr_id
  FROM bb_mod_pool_nbr mpn
  DETAIL
   prod_nbr->mod_pool_nbr_id = mpn.mod_pool_nbr_id
   IF ((mod_opt->prod_nbr_ccyy_ind=0))
    prod_nbr->prefix = trim(substring(1,5,mpn.prefix))
   ELSE
    prod_nbr->prefix = trim(substring(1,3,mpn.prefix))
   ENDIF
   prod_nbr->year = mpn.year, prod_nbr->seq_nbr = mpn.seq_nbr
  WITH nocounter, forupdate(mpn)
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BB_MOD_POOL_NBR",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  IF ((request->set_seq_ind=1)
   AND (request->isbt_ind=1))
   IF ((request->new_seq <= prod_nbr->seq_nbr))
    SET prod_nbr->seq_nbr = (prod_nbr->seq_nbr+ 1)
   ELSE
    SET prod_nbr->seq_nbr = request->new_seq
   ENDIF
   IF (updatebbmodpoolnbr(0)=0)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
   GO TO build_prod_nbr
  ELSE
   SET prod_nbr->seq_nbr = (prod_nbr->seq_nbr+ 1)
   IF (updatebbmodpoolnbr(0)=0)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SET prod_nbr->prefix = mod_opt->prod_nbr_prefix
  SET prod_nbr->year = yr
  SET prod_nbr->seq_nbr = 1
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    prod_nbr->mod_pool_nbr_id = y
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET errmsg = "Unable to obtain reference sequence id"
   CALL errorhandler("SELECT","F","DUAL",errmsg)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  INSERT  FROM bb_mod_pool_nbr mpn
   SET mpn.isbt_supplier_fin = request->isbt_fin_nbr, mpn.mod_pool_nbr_id = prod_nbr->mod_pool_nbr_id,
    mpn.option_id = request->option_id,
    mpn.prefix = prod_nbr->prefix, mpn.year = prod_nbr->year, mpn.seq_nbr = prod_nbr->seq_nbr,
    mpn.updt_applctx = reqinfo->updt_applctx, mpn.updt_task = reqinfo->updt_task, mpn.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    mpn.updt_id = reqinfo->updt_id, mpn.updt_cnt = 0
   WITH nocounter
  ;end insert
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("INSERT","F","BB_MOD_POOL_NBR",errmsg)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET errmsg = "Insert failed."
   CALL errorhandler("INSERT","F","BB_MOD_POOL_NBR",errmsg)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  IF ((request->isbt_ind=0))
   SELECT INTO "nl:"
    mo.option_id
    FROM bb_mod_option mo
    PLAN (mo
     WHERE (mo.option_id=request->option_id))
    WITH nocounter, forupdate(mo)
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("SELECT","F","BB_MOD_OPTION",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET errmsg = "Select failed."
    CALL errorhandler("SELECT","F","BB_MOD_OPTION",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
   UPDATE  FROM bb_mod_option mo
    SET mo.prod_nbr_starting_nbr = 1, mo.updt_applctx = reqinfo->updt_applctx, mo.updt_task = reqinfo
     ->updt_task,
     mo.updt_dt_tm = cnvtdatetime(curdate,curtime3), mo.updt_id = reqinfo->updt_id, mo.updt_cnt = 0
    PLAN (mo
     WHERE (mo.option_id=request->option_id))
    WITH nocounter
   ;end update
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("UPDATE","F","BB_MOD_OPTION",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET errmsg = "Update failed."
    CALL errorhandler("UPDATE","F","BB_MOD_OPTION",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#build_prod_nbr
 IF ((request->isbt_ind=1))
  SET reply->product_nbr = build(request->isbt_fin_nbr,substring(3,2,build(yr)),format(prod_nbr->
    seq_nbr,"######;P0;I"))
 ELSEIF ((mod_opt->prod_nbr_ccyy_ind=1))
  SET reply->product_nbr = build(prod_nbr->prefix,prod_nbr->year,format(prod_nbr->seq_nbr,
    "#####;P0;I"))
 ELSE
  SET yr_size = size(build(prod_nbr->year),1)
  SET ptr = (yr_size - 1)
  SET reply->product_nbr = build(prod_nbr->prefix,substring(ptr,2,build(prod_nbr->year)),format(
    prod_nbr->seq_nbr,"#####;P0;I"))
 ENDIF
 SELECT INTO "nl:"
  p.product_nbr
  FROM product p
  PLAN (p
   WHERE (p.product_nbr=reply->product_nbr))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET prod_nbr->seq_nbr = (prod_nbr->seq_nbr+ 1)
  IF (updatebbmodpoolnbr(0)=0)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  GO TO build_prod_nbr
 ENDIF
 SELECT INTO "nl:"
  bp.product_nbr
  FROM bbhist_product bp
  PLAN (bp
   WHERE (bp.product_nbr=reply->product_nbr))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET prod_nbr->seq_nbr = (prod_nbr->seq_nbr+ 1)
  IF (updatebbmodpoolnbr(0)=0)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  GO TO build_prod_nbr
 ENDIF
 IF ((request->set_seq_ind=1)
  AND (request->isbt_ind=1))
  SET prod_nbr->seq_nbr = (prod_nbr->seq_nbr - 1)
  IF (updatebbmodpoolnbr(0)=0)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE updatebbmodpoolnbr(none) = i2
 SUBROUTINE updatebbmodpoolnbr(none)
   UPDATE  FROM bb_mod_pool_nbr mpn
    SET mpn.seq_nbr = prod_nbr->seq_nbr, mpn.updt_applctx = reqinfo->updt_applctx, mpn.updt_task =
     reqinfo->updt_task,
     mpn.updt_dt_tm = cnvtdatetime(curdate,curtime3), mpn.updt_id = reqinfo->updt_id, mpn.updt_cnt =
     (mpn.updt_cnt+ 1)
    PLAN (mpn
     WHERE (mpn.mod_pool_nbr_id=prod_nbr->mod_pool_nbr_id))
    WITH nocounter
   ;end update
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("UPDATE","F","BB_MOD_POOL_NBR",errmsg)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET errmsg = "Update failed."
    CALL errorhandler("UPDATE","F","BB_MOD_POOL_NBR",errmsg)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE errorhandler(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc)
  = null
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SET reply->sequence = prod_nbr->seq_nbr
#exit_script
 FREE RECORD mod_opt
 FREE RECORD prod_nbr
END GO
