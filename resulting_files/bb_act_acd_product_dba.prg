CREATE PROGRAM bb_act_acd_product:dba
 RECORD reply(
   1 dup_product[*]
     2 generated_product_id = f8
     2 db_product_id = f8
     2 history_ind = i2
     2 eligible_for_rereceive_ind = i2
     2 eligible_for_ship_receipt_ind = i2
   1 conflicting_aborh[*]
     2 generated_product_id = f8
     2 db_product_id = f8
     2 db_abo_cd = f8
     2 db_abo_disp = c40
     2 db_rh_cd = f8
     2 db_rh_disp = c40
     2 history_ind = i2
     2 db_product_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD acd_status(
   1 statuslist[*]
     2 status = i4
     2 module_name = c40
     2 errnum = i4
     2 errmsg = c132
 )
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updateedncomplete(ednid=f8(value),ednproductid=f8(value),productid=f8(value),
  edncompleteind=i2(value)) =i2)
   UPDATE  FROM bb_edn_product bep
    SET bep.product_complete_ind = 1, bep.product_id = productid, bep.updt_applctx = reqinfo->
     updt_applctx,
     bep.updt_dt_tm = cnvtdatetime(sysdate), bep.updt_id = reqinfo->updt_id, bep.updt_task = reqinfo
     ->updt_task,
     bep.person_id = 0.0
    WHERE bep.bb_edn_product_id=ednproductid
    WITH nocounter
   ;end update
   IF (curqual != 1)
    CALL log_message("Error updating BB_EDN_PRODUCT table.",log_level_error)
    RETURN(1)
   ENDIF
   IF (edncompleteind=1)
    UPDATE  FROM bb_edn_admin bea
     SET bea.edn_complete_ind = 1, bea.updt_applctx = reqinfo->updt_applctx, bea.updt_dt_tm =
      cnvtdatetime(sysdate),
      bea.updt_id = reqinfo->updt_id, bea.updt_task = reqinfo->updt_task
     WHERE bea.bb_edn_admin_id=ednid
    ;end update
    IF (curqual != 1)
     CALL log_message("Error updating BB_EDN_ADMIN table.",log_level_error)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE nmaxproduct = i4
 DECLARE nmaxproductevent = i4
 DECLARE failures = c2
 DECLARE dup_cnt = i2
 DECLARE con_cnt = i2
 DECLARE deriv_cur_avail_qty = i4
 DECLARE deriv_cur_intl_units = i4
 DECLARE pe_assgn_or_quar_ind = i2 WITH protect, noconstant(0)
 DECLARE cdf_meaning = c12
 DECLARE ndonorproductind = i2 WITH protect, noconstant(0)
 DECLARE bb_exception_id = f8 WITH protect, noconstant(0.0)
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE dshippedeventtype = f8 WITH protect, noconstant(0.0)
 DECLARE dintransiteventtype = f8 WITH protect, noconstant(0.0)
 DECLARE davailableeventtype = f8 WITH protect, noconstant(0.0)
 DECLARE dproductclassblood = f8 WITH protect, noconstant(0.0)
 DECLARE dproductclassder = f8 WITH protect, noconstant(0.0)
 DECLARE dup_var = i4 WITH protect, noconstant(0)
 DECLARE conf_var = i4 WITH protect, noconstant(0)
 SET nstatus = uar_get_meaning_by_codeset(1610,"15",1,dshippedeventtype)
 SET nstatus = uar_get_meaning_by_codeset(1610,"25",1,dintransiteventtype)
 SET nstatus = uar_get_meaning_by_codeset(1610,"12",1,davailableeventtype)
 SET nstatus = uar_get_meaning_by_codeset(1606,"BLOOD",1,dproductclassblood)
 SET nstatus = uar_get_meaning_by_codeset(1606,"DERIVATIVE",1,dproductclassder)
 SET ndonorproductind = validate(request->donor_product_ind,0)
 SET dup_cnt = 0
 SET con_cnt = 0
 SET failures = "Y"
 SET nmaxproduct = size(request->products,5)
 SET nmaxproductevent = request->max_product_events
 SET nmaxspecialtestings = request->max_special_testings
 SET stat = alterlist(reply->dup_product,10)
 SET stat = alterlist(reply->conflicting_aborh,10)
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 IF ((request->add_exists_ind=1))
  IF (ndonorproductind=1)
   SELECT INTO "nl:"
    p.*
    FROM product p,
     (dummyt d  WITH seq = value(nmaxproduct))
    PLAN (d)
     JOIN (p
     WHERE p.product_nbr=cnvtupper(request->products[d.seq].product_nbr)
      AND p.active_ind=1
      AND (request->products[d.seq].add_ind=1))
    DETAIL
     dup_cnt += 1
     IF (mod(dup_cnt,10)=1
      AND dup_cnt != 1)
      stat = alterlist(reply->dup_product,(dup_cnt+ 10))
     ENDIF
     reply->dup_product[dup_cnt].generated_product_id = request->products[d.seq].product_id, reply->
     dup_product[dup_cnt].db_product_id = p.product_id, reply->dup_product[dup_cnt].history_ind = 0
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on product - dup check for blood products"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   ENDIF
   IF (curqual > 0)
    SET failures = "Z"
   ENDIF
   SELECT INTO "nl:"
    hp.*
    FROM (dummyt d  WITH seq = value(nmaxproduct)),
     bbhist_product hp
    PLAN (d)
     JOIN (hp
     WHERE hp.product_nbr=cnvtupper(request->products[d.seq].product_nbr)
      AND hp.active_ind=1
      AND (request->products[d.seq].add_ind=1))
    DETAIL
     dup_cnt += 1
     IF (mod(dup_cnt,10)=1
      AND dup_cnt != 1)
      stat = alterlist(reply->dup_product,(dup_cnt+ 10))
     ENDIF
     reply->dup_product[dup_cnt].generated_product_id = request->products[d.seq].product_id, reply->
     dup_product[dup_cnt].db_product_id = hp.product_id, reply->dup_product[dup_cnt].history_ind = 1
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on bbhist_product - dup check for blood products"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   ENDIF
   IF (curqual > 0)
    SET failures = "Z"
   ENDIF
  ELSE
   SELECT INTO "nl:"
    *
    FROM product p,
     blood_product bp,
     (dummyt d  WITH seq = value(nmaxproduct))
    PLAN (d)
     JOIN (p
     WHERE p.product_nbr=cnvtupper(request->products[d.seq].product_nbr)
      AND (p.product_cd=request->products[d.seq].product_cd)
      AND (((request->products[d.seq].product_sub_nbr <= " ")
      AND ((nullind(p.product_sub_nbr)=1) OR (p.product_sub_nbr <= " ")) ) OR ((p.product_sub_nbr=
     request->products[d.seq].product_sub_nbr)))
      AND p.active_ind=1
      AND (request->products[d.seq].add_ind=1))
     JOIN (bp
     WHERE bp.product_id=p.product_id
      AND (((request->products[d.seq].bloodproducts.supplier_prefix > " ")
      AND (bp.supplier_prefix=request->products[d.seq].bloodproducts.supplier_prefix)) OR ((request->
     products[d.seq].bloodproducts.supplier_prefix <= " ")
      AND (p.cur_supplier_id=request->products[d.seq].cur_supplier_id))) )
    DETAIL
     dup_cnt += 1
     IF (mod(dup_cnt,10)=1
      AND dup_cnt != 1)
      stat = alterlist(reply->dup_product,(dup_cnt+ 10))
     ENDIF
     reply->dup_product[dup_cnt].generated_product_id = request->products[d.seq].product_id, reply->
     dup_product[dup_cnt].db_product_id = p.product_id, reply->dup_product[dup_cnt].history_ind = 0
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on product - dup check for blood products"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   ENDIF
   IF (curqual > 0)
    SET failures = "Z"
   ENDIF
   SELECT INTO "nl:"
    d1.seq
    FROM product p,
     blood_product bp,
     product_category pc,
     product_category pcr,
     (dummyt d1  WITH seq = value(nmaxproduct))
    PLAN (d1)
     JOIN (p
     WHERE p.product_nbr=cnvtupper(request->products[d1.seq].product_nbr)
      AND (p.cur_supplier_id=request->products[d1.seq].cur_supplier_id)
      AND p.active_ind=1)
     JOIN (pc
     WHERE pc.product_cat_cd=p.product_cat_cd)
     JOIN (pcr
     WHERE (pcr.product_cat_cd=request->products[d1.seq].product_cat_cd))
     JOIN (bp
     WHERE bp.product_id=p.product_id
      AND (((bp.cur_abo_cd != request->products[d1.seq].bloodproducts.cur_abo_cd)) OR ((request->
     products[d1.seq].bloodproducts.cur_rh_cd != bp.cur_rh_cd)
      AND bp.cur_rh_cd > 0
      AND (request->products[d1.seq].bloodproducts.cur_rh_cd > 0)
      AND  NOT (((pc.rh_required_ind=0
      AND bp.cur_rh_cd=0) OR (pcr.rh_required_ind=0
      AND (request->products[d1.seq].bloodproducts.cur_rh_cd=0))) ))) )
    ORDER BY d1.seq, p.create_dt_tm
    DETAIL
     val = locateval(dup_var,1,size(reply->dup_product,5),p.product_id,reply->dup_product[dup_var].
      db_product_id), val1 = locateval(conf_var,1,size(reply->conflicting_aborh,5),request->products[
      d1.seq].product_id,reply->conflicting_aborh[conf_var].generated_product_id)
     IF (val > 0
      AND val1 > 0)
      IF ((request->copy_aborh_from_orig_prod_ind=1))
       request->products[d1.seq].bloodproducts.cur_abo_cd = bp.cur_abo_cd, request->products[d1.seq].
       bloodproducts.cur_rh_cd = bp.cur_rh_cd
      ENDIF
      IF ((request->products[d1.seq].add_ind=1))
       reply->conflicting_aborh[val1].generated_product_id = request->products[d1.seq].product_id,
       reply->conflicting_aborh[val1].db_product_id = p.product_id, reply->conflicting_aborh[val1].
       db_abo_cd = bp.cur_abo_cd,
       reply->conflicting_aborh[val1].db_rh_cd = bp.cur_rh_cd, reply->conflicting_aborh[val1].
       history_ind = 0, reply->conflicting_aborh[val1].db_product_cd = p.product_cd
      ENDIF
     ELSE
      IF (((con_cnt=0) OR ((reply->conflicting_aborh[con_cnt].generated_product_id != request->
      products[d1.seq].product_id))) )
       IF ((request->copy_aborh_from_orig_prod_ind=1))
        request->products[d1.seq].bloodproducts.cur_abo_cd = bp.cur_abo_cd, request->products[d1.seq]
        .bloodproducts.cur_rh_cd = bp.cur_rh_cd
       ENDIF
       IF ((request->products[d1.seq].add_ind=1))
        con_cnt += 1
        IF (mod(con_cnt,10)=1
         AND con_cnt != 1)
         stat = alterlist(reply->conflicting_aborh,(con_cnt+ 10))
        ENDIF
        reply->conflicting_aborh[con_cnt].generated_product_id = request->products[d1.seq].product_id,
        reply->conflicting_aborh[con_cnt].db_product_id = p.product_id, reply->conflicting_aborh[
        con_cnt].db_abo_cd = bp.cur_abo_cd,
        reply->conflicting_aborh[con_cnt].db_rh_cd = bp.cur_rh_cd, reply->conflicting_aborh[con_cnt].
        history_ind = 0, reply->conflicting_aborh[con_cnt].db_product_cd = p.product_cd
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET failures = "Z"
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on product for conflicting aborh"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   ENDIF
   IF (curqual > 0
    AND (request->continue_on_aborh_conflict_ind=0)
    AND con_cnt > 0)
    SET failures = "Z"
   ENDIF
   SELECT INTO "nl:"
    d2.seq
    FROM product p,
     derivative der,
     (dummyt d2  WITH seq = value(nmaxproduct))
    PLAN (d2)
     JOIN (p
     WHERE p.product_nbr=cnvtupper(request->products[d2.seq].product_nbr)
      AND (p.product_cd=request->products[d2.seq].product_cd)
      AND (((request->products[d2.seq].product_sub_nbr <= " ")
      AND ((nullind(p.product_sub_nbr)=1) OR (p.product_sub_nbr <= " ")) ) OR ((p.product_sub_nbr=
     request->products[d2.seq].product_sub_nbr)))
      AND (((((request->products[d2.seq].serial_number_txt <= " ")) OR ((request->products[d2.seq].
     serial_number_txt <= "")))
      AND ((nullind(p.serial_number_txt)=1) OR (p.serial_number_txt <= " ")) ) OR ((p
     .serial_number_txt=request->products[d2.seq].serial_number_txt)))
      AND (((p.cur_owner_area_cd=request->products[d2.seq].cur_owner_area_cd)) OR ((request->
     products[d2.seq].cur_owner_area_cd=0)))
      AND (((p.cur_inv_area_cd=request->products[d2.seq].cur_inv_area_cd)) OR ((request->products[d2
     .seq].cur_inv_area_cd=0)))
      AND p.active_ind=1
      AND (request->products[d2.seq].add_ind=1))
     JOIN (der
     WHERE der.product_id=p.product_id
      AND (request->products[d2.seq].derivatives.manufacturer_id=der.manufacturer_id))
    DETAIL
     dup_cnt += 1
     IF (mod(dup_cnt,10)=1
      AND dup_cnt != 1)
      stat = alterlist(reply->dup_product,(dup_cnt+ 10))
     ENDIF
     reply->dup_product[dup_cnt].generated_product_id = request->products[d2.seq].product_id, reply->
     dup_product[dup_cnt].db_product_id = p.product_id, reply->dup_product[dup_cnt].history_ind = 0
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET failures = "Z"
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on product - dup check for derivatives"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   ENDIF
   IF (curqual > 0)
    SET failures = "Z"
   ENDIF
   SELECT INTO "nl:"
    d4.seq
    FROM (dummyt d4  WITH seq = value(nmaxproduct)),
     bbhist_product hp
    PLAN (d4)
     JOIN (hp
     WHERE hp.product_nbr=cnvtupper(request->products[d4.seq].product_nbr)
      AND (hp.product_cd=request->products[d4.seq].product_cd)
      AND (((request->products[d4.seq].product_sub_nbr <= " ")
      AND ((nullind(hp.product_sub_nbr)=1) OR (hp.product_sub_nbr <= " ")) ) OR ((hp.product_sub_nbr=
     request->products[d4.seq].product_sub_nbr)))
      AND (((hp.owner_area_cd=request->products[d4.seq].cur_owner_area_cd)) OR ((request->products[d4
     .seq].cur_owner_area_cd=0)))
      AND (((hp.inv_area_cd=request->products[d4.seq].cur_inv_area_cd)) OR ((request->products[d4.seq
     ].cur_inv_area_cd=0)))
      AND hp.active_ind=1
      AND (request->products[d4.seq].add_ind=1))
    DETAIL
     dup_cnt += 1
     IF (mod(dup_cnt,10)=1
      AND dup_cnt != 1)
      stat = alterlist(reply->dup_product,(dup_cnt+ 10))
     ENDIF
     IF (hp.product_class_cd=dproductclassder)
      IF (validate(request->products[d4.seq].derivatives.manufacturer_id,0.0) > 0.0)
       IF ((hp.supplier_id=request->products[d4.seq].derivatives.manufacturer_id))
        reply->dup_product[dup_cnt].generated_product_id = request->products[d4.seq].product_id,
        reply->dup_product[dup_cnt].db_product_id = hp.product_id, reply->dup_product[dup_cnt].
        history_ind = 1
       ENDIF
      ELSEIF (validate(request->products[d4.seq].derivatives.manufacturer_id,0.0)=0.0)
       IF ((hp.supplier_id=request->products[d4.seq].cur_supplier_id))
        reply->dup_product[dup_cnt].generated_product_id = request->products[d4.seq].product_id,
        reply->dup_product[dup_cnt].db_product_id = hp.product_id, reply->dup_product[dup_cnt].
        history_ind = 1
       ENDIF
      ENDIF
     ELSEIF ((hp.supplier_id=request->products[d4.seq].cur_supplier_id))
      reply->dup_product[dup_cnt].generated_product_id = request->products[d4.seq].product_id, reply
      ->dup_product[dup_cnt].db_product_id = hp.product_id, reply->dup_product[dup_cnt].history_ind
       = 1
     ENDIF
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on product - dups for bp and de"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   ENDIF
   IF (curqual > 0)
    SET failures = "Z"
   ENDIF
   SELECT INTO "nl:"
    d5.seq, hp.abo_cd, hp.rh_cd,
    pcr.rh_required_ind
    FROM (dummyt d5  WITH seq = value(nmaxproduct)),
     bbhist_product hp,
     product_category pcr,
     product_index pi,
     product_category pc
    PLAN (d5)
     JOIN (pcr
     WHERE (pcr.product_cat_cd=request->products[d5.seq].product_cat_cd))
     JOIN (hp
     WHERE hp.product_nbr=cnvtupper(request->products[d5.seq].product_nbr)
      AND (hp.supplier_id=request->products[d5.seq].cur_supplier_id))
     JOIN (pi
     WHERE pi.product_cd=hp.product_cd)
     JOIN (pc
     WHERE pc.product_cat_cd=pi.product_cat_cd
      AND (((hp.abo_cd != request->products[d5.seq].bloodproducts.cur_abo_cd)) OR ((request->
     products[d5.seq].bloodproducts.cur_rh_cd != hp.rh_cd)
      AND hp.rh_cd > 0
      AND (request->products[d5.seq].bloodproducts.cur_rh_cd > 0)
      AND  NOT (((pc.rh_required_ind=0
      AND hp.rh_cd=0) OR (pcr.rh_required_ind=0
      AND (request->products[d5.seq].bloodproducts.cur_rh_cd=0))) ))) )
    ORDER BY d5.seq, hp.active_status_dt_tm
    DETAIL
     val = locateval(dup_var,1,size(reply->dup_product,5),hp.product_id,reply->dup_product[dup_var].
      db_product_id), val1 = locateval(conf_var,1,size(reply->conflicting_aborh,5),request->products[
      d5.seq].product_id,reply->conflicting_aborh[conf_var].generated_product_id)
     IF (val > 0
      AND val1 > 0)
      IF ((request->copy_aborh_from_orig_prod_ind=1))
       request->products[d5.seq].bloodproducts.cur_abo_cd = hp.abo_cd, request->products[d5.seq].
       bloodproducts.cur_rh_cd = hp.rh_cd
      ENDIF
      IF ((request->products[d5.seq].add_ind=1))
       IF (hp.product_class_cd=dproductclassblood)
        reply->conflicting_aborh[val1].generated_product_id = request->products[d5.seq].product_id,
        reply->conflicting_aborh[val1].db_product_id = hp.product_id, reply->conflicting_aborh[val1].
        db_abo_cd = hp.abo_cd,
        reply->conflicting_aborh[val1].db_rh_cd = hp.rh_cd, reply->conflicting_aborh[val1].
        history_ind = 1, reply->conflicting_aborh[val1].db_product_cd = hp.product_cd
       ENDIF
      ENDIF
     ELSE
      IF (((con_cnt=0) OR ((reply->conflicting_aborh[con_cnt].generated_product_id != request->
      products[d5.seq].product_id))) )
       IF ((request->copy_aborh_from_orig_prod_ind=1))
        request->products[d5.seq].bloodproducts.cur_abo_cd = hp.abo_cd, request->products[d5.seq].
        bloodproducts.cur_rh_cd = hp.rh_cd
       ENDIF
       IF ((request->products[d5.seq].add_ind=1))
        con_cnt += 1
        IF (mod(con_cnt,10)=1
         AND con_cnt != 1)
         stat = alterlist(reply->conflicting_aborh,(con_cnt+ 10))
        ENDIF
        IF (hp.product_class_cd=dproductclassblood)
         reply->conflicting_aborh[con_cnt].generated_product_id = request->products[d5.seq].
         product_id, reply->conflicting_aborh[con_cnt].db_product_id = hp.product_id, reply->
         conflicting_aborh[con_cnt].db_abo_cd = hp.abo_cd,
         reply->conflicting_aborh[con_cnt].db_rh_cd = hp.rh_cd, reply->conflicting_aborh[con_cnt].
         history_ind = 1, reply->conflicting_aborh[con_cnt].db_product_cd = hp.product_cd
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname =
    "Select on bbhist_product - history dup check"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   ENDIF
   IF (curqual > 0
    AND (request->continue_on_aborh_conflict_ind=0)
    AND con_cnt > 0)
    SET failures = "Z"
   ENDIF
   SET stat = alterlist(reply->conflicting_aborh,con_cnt)
   SET stat = alterlist(reply->dup_product,dup_cnt)
   IF (size(reply->dup_product,5) > 0)
    SET cdf_meaning = "14"
    SET dest_event_type_cd = 0.0
    SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,dest_event_type_cd)
    SELECT INTO "nl:"
     di_reason_mean = uar_get_code_meaning(di.reason_cd), di_ind = decode(di.seq,1,0)
     FROM (dummyt d  WITH seq = value(size(reply->dup_product,5))),
      product p,
      (dummyt d_pe  WITH seq = 1),
      product_event pe,
      (dummyt d_di  WITH seq = 1),
      disposition di
     PLAN (d)
      JOIN (p
      WHERE (p.product_id=reply->dup_product[d.seq].db_product_id))
      JOIN (d_pe)
      JOIN (pe
      WHERE pe.product_id=p.product_id
       AND ((pe.event_type_cd IN (dest_event_type_cd, dshippedeventtype, dintransiteventtype)
       AND pe.active_ind=1) OR (pe.event_type_cd=davailableeventtype
       AND p.product_class_cd=dproductclassder
       AND pe.event_status_flag=0)) )
      JOIN (d_di)
      JOIN (di
      WHERE di.product_event_id=pe.related_product_event_id)
     DETAIL
      IF (p.product_class_cd=dproductclassder)
       IF (pe.active_ind=1
        AND pe.event_type_cd=davailableeventtype)
        reply->dup_product[d.seq].eligible_for_rereceive_ind = 1
       ENDIF
      ELSE
       IF (di_ind=1
        AND di_reason_mean="RE RECEIVE")
        reply->dup_product[d.seq].eligible_for_rereceive_ind = 1
       ENDIF
      ENDIF
      IF (((pe.event_type_cd=dshippedeventtype) OR (pe.event_type_cd=dintransiteventtype)) )
       reply->dup_product[d.seq].eligible_for_ship_receipt_ind = 1
      ELSE
       reply->dup_product[d.seq].eligible_for_ship_receipt_ind = 0
      ENDIF
     WITH nocounter, outerjoin(d_pe), outerjoin(d_di)
    ;end select
    SET serror_check = error(serrormsg,0)
    IF (serror_check != 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Select for re-receive eligibility"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ENDIF
   ENDIF
  ENDIF
  IF (failures="Z")
   GO TO exit_script
  ENDIF
  IF ((request->pr_add_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   INSERT  FROM product p,
     (dummyt d  WITH seq = value(nmaxproduct))
    SET p.product_id = request->products[d.seq].product_id, p.product_cd = request->products[d.seq].
     product_cd, p.product_cat_cd = request->products[d.seq].product_cat_cd,
     p.product_class_cd = request->products[d.seq].product_class_cd, p.product_nbr = request->
     products[d.seq].product_nbr, p.product_sub_nbr = request->products[d.seq].product_sub_nbr,
     p.alternate_nbr = request->products[d.seq].alternate_nbr, p.flag_chars = request->products[d.seq
     ].flag_chars, p.pooled_product_id = request->products[d.seq].pooled_product_id,
     p.modified_product_id = request->products[d.seq].modified_product_id, p.locked_ind = request->
     products[d.seq].locked_ind, p.cur_inv_locn_cd = request->products[d.seq].cur_inv_locn_cd,
     p.orig_inv_locn_cd = request->products[d.seq].orig_inv_locn_cd, p.cur_supplier_id = request->
     products[d.seq].cur_supplier_id, p.recv_dt_tm = cnvtdatetime(request->products[d.seq].recv_dt_tm
      ),
     p.recv_prsnl_id = request->products[d.seq].recv_prsnl_id, p.orig_ship_cond_cd = request->
     products[d.seq].orig_ship_cond_cd, p.orig_vis_insp_cd = request->products[d.seq].
     orig_vis_insp_cd,
     p.storage_temp_cd = request->products[d.seq].storage_temp_cd, p.cur_unit_meas_cd = request->
     products[d.seq].cur_unit_meas_cd, p.orig_unit_meas_cd = request->products[d.seq].
     orig_unit_meas_cd,
     p.pooled_product_ind = request->products[d.seq].pooled_product_ind, p.modified_product_ind =
     request->products[d.seq].modified_product_ind, p.corrected_ind = request->products[d.seq].
     corrected_ind,
     p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.active_ind = request
     ->products[d.seq].active_ind,
     p.cur_expire_dt_tm = cnvtdatetime(request->products[d.seq].cur_expire_dt_tm), p
     .cur_owner_area_cd = request->products[d.seq].cur_owner_area_cd, p.cur_inv_area_cd = request->
     products[d.seq].cur_inv_area_cd,
     p.cur_inv_device_id = request->products[d.seq].cur_inv_device_id, p.cur_dispense_device_id =
     request->products[d.seq].cur_dispense_device_id, p.contributor_system_cd = request->products[d
     .seq].contributor_system_cd,
     p.pool_option_id = request->products[d.seq].pool_option_id, p.barcode_nbr = request->products[d
     .seq].barcode_nbr, p.create_dt_tm = cnvtdatetime(request->products[d.seq].create_dt_tm),
     p.active_status_cd =
     IF ((request->products[d.seq].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , p.active_status_dt_tm = cnvtdatetime(sysdate), p.active_status_prsnl_id = reqinfo->updt_id,
     p.donated_by_relative_ind = request->products[d.seq].donated_by_relative_ind, p.disease_cd =
     request->products[d.seq].disease_cd, p.donation_type_cd = request->products[d.seq].
     donation_type_cd,
     p.electronic_entry_flag = request->products[d.seq].electronic_entry_flag, p.req_label_verify_ind
      = request->products[d.seq].req_label_verify_ind, p.intended_use_print_parm_txt = request->
     products[d.seq].intended_use_print_parm_txt,
     p.product_type_barcode = request->products[d.seq].product_type_barcode, p.serial_number_txt =
     IF ((((request->products[d.seq].serial_number_txt != " ")) OR ((request->products[d.seq].
     serial_number_txt != null))) ) request->products[d.seq].serial_number_txt
     ENDIF
     , p.interface_product_id = request->products[d.seq].interface_product_id
    PLAN (d
     WHERE (request->products[d.seq].add_ind=1))
     JOIN (p)
    WITH nocounter, status(acd_status->statuslist[d.seq].status)
   ;end insert
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pr_add_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Add count doesn't match insert count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "insert into product"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->de_add_cnt > 0))
   SET p_cnt_sub = value(nmaxproduct)
   FOR (p_cnt = 1 TO p_cnt_sub)
     SET pe_assgn_or_quar_ind = 0
     SET deriv_cur_avail_qty = request->products[p_cnt].derivatives.cur_avail_qty
     SET deriv_cur_intl_units = request->products[p_cnt].derivatives.cur_intl_units
     SET pe_cnt_sub = size(request->products[p_cnt].productevents,5)
     FOR (pe_cnt = 1 TO pe_cnt_sub)
      SET cdf_meaning = trim(uar_get_code_meaning(request->products[p_cnt].productevents[pe_cnt].
        event_type_cd))
      IF ((request->products[p_cnt].productevents[pe_cnt].add_ind=1)
       AND ((cdf_meaning="1") OR (cdf_meaning="2")) )
       SET pe_assgn_or_quar_ind = 1
       SET pe_cnt = pe_cnt_sub
      ENDIF
     ENDFOR
     IF ((request->products[p_cnt].derivatives.add_ind=1))
      INSERT  FROM derivative d
       SET d.product_id = request->products[p_cnt].product_id, d.product_cd = request->products[p_cnt
        ].derivatives.product_cd, d.item_volume = request->products[p_cnt].derivatives.item_volume,
        d.item_unit_meas_cd = request->products[p_cnt].derivatives.item_unit_meas_cd, d.updt_cnt = 0,
        d.active_ind = request->products[p_cnt].derivatives.active_ind,
        d.manufacturer_id = request->products[p_cnt].derivatives.manufacturer_id, d.cur_avail_qty =
        IF (pe_assgn_or_quar_ind) 0
        ELSE deriv_cur_avail_qty
        ENDIF
        , d.units_per_vial = request->products[p_cnt].derivatives.units_per_vial,
        d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
        updt_task,
        d.updt_applctx = reqinfo->updt_applctx, d.active_status_cd =
        IF ((request->products[p_cnt].derivatives.active_ind=1)) reqdata->active_status_cd
        ELSE reqdata->inactive_status_cd
        ENDIF
        , d.active_status_dt_tm = cnvtdatetime(sysdate),
        d.active_status_prsnl_id = reqinfo->updt_id, d.cur_intl_units = deriv_cur_intl_units
       WITH nocounter
      ;end insert
      SET serror_check = error(serrormsg,0)
      IF (serror_check != 0)
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "insert into derivative"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  IF ((request->bp_add_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   INSERT  FROM blood_product bp,
     (dummyt d2  WITH seq = value(nmaxproduct))
    SET bp.product_id = request->products[d2.seq].product_id, bp.product_cd = request->products[d2
     .seq].bloodproducts.product_cd, bp.supplier_prefix = request->products[d2.seq].bloodproducts.
     supplier_prefix,
     bp.cur_volume = request->products[d2.seq].bloodproducts.cur_volume, bp.orig_label_abo_cd =
     request->products[d2.seq].bloodproducts.orig_label_abo_cd, bp.orig_label_rh_cd = request->
     products[d2.seq].bloodproducts.orig_label_rh_cd,
     bp.cur_abo_cd = request->products[d2.seq].bloodproducts.cur_abo_cd, bp.cur_rh_cd = request->
     products[d2.seq].bloodproducts.cur_rh_cd, bp.segment_nbr = request->products[d2.seq].
     bloodproducts.segment_nbr,
     bp.orig_expire_dt_tm = cnvtdatetime(request->products[d2.seq].bloodproducts.orig_expire_dt_tm),
     bp.orig_volume = request->products[d2.seq].bloodproducts.orig_volume, bp.lot_nbr = request->
     products[d2.seq].bloodproducts.lot_nbr,
     bp.autologous_ind = request->products[d2.seq].bloodproducts.autologous_ind, bp.directed_ind =
     request->products[d2.seq].bloodproducts.directed_ind, bp.drawn_dt_tm = cnvtdatetime(request->
      products[d2.seq].bloodproducts.drawn_dt_tm),
     bp.updt_cnt = 0, bp.active_ind = request->products[d2.seq].bloodproducts.active_ind, bp
     .donor_person_id = request->products[d2.seq].bloodproducts.donor_person_id,
     bp.updt_dt_tm = cnvtdatetime(sysdate), bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->
     updt_task,
     bp.updt_applctx = reqinfo->updt_applctx, bp.active_status_cd =
     IF ((request->products[d2.seq].bloodproducts.active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , bp.active_status_dt_tm = cnvtdatetime(sysdate),
     bp.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d2
     WHERE (request->products[d2.seq].bloodproducts.add_ind=1))
     JOIN (bp)
    WITH nocounter, status(acd_status->statuslist[d2.seq].status)
   ;end insert
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->bp_add_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Add count doesn't match insert count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "insert into blood_product"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->pn_add_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   INSERT  FROM product_note pn,
     (dummyt d2  WITH seq = value(nmaxproduct))
    SET pn.product_id = request->products[d2.seq].product_id, pn.product_note_id = request->products[
     d2.seq].productnote.new_product_note_id, pn.long_text_id = request->products[d2.seq].productnote
     .new_long_text_id,
     pn.updt_cnt = 0, pn.active_ind = 1, pn.updt_dt_tm = cnvtdatetime(sysdate),
     pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
     updt_applctx,
     pn.active_status_cd = reqdata->active_status_cd, pn.active_status_dt_tm = cnvtdatetime(sysdate),
     pn.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d2
     WHERE (request->products[d2.seq].productnote.add_ind=1))
     JOIN (pn)
    WITH nocounter, status(acd_status->statuslist[d2.seq].status)
   ;end insert
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pn_add_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Add count doesn't match insert count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "insert into product_note"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->pn_add_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   INSERT  FROM long_text lt,
     (dummyt d2  WITH seq = value(nmaxproduct))
    SET lt.long_text_id = request->products[d2.seq].productnote.new_long_text_id, lt.long_text =
     request->products[d2.seq].productnote.product_note, lt.parent_entity_name = "PRODUCT_NOTE",
     lt.parent_entity_id = request->products[d2.seq].productnote.new_product_note_id, lt.updt_cnt = 0,
     lt.active_ind = 1,
     lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->
     updt_task,
     lt.updt_applctx = reqinfo->updt_applctx, lt.active_status_cd = reqdata->active_status_cd, lt
     .active_status_dt_tm = cnvtdatetime(sysdate),
     lt.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d2
     WHERE (request->products[d2.seq].productnote.add_ind=1))
     JOIN (lt)
    WITH nocounter, status(acd_status->statuslist[d2.seq].status)
   ;end insert
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pn_add_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Add count doesn't match insert count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "insert into long_text"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->st_add_cnt > 0))
   SET nmaxsize = (nmaxproduct * nmaxspecialtestings)
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxsize)
   INSERT  FROM special_testing st,
     (dummyt d3  WITH seq = value(nmaxproduct)),
     (dummyt d4  WITH seq = value(nmaxspecialtestings))
    SET st.product_id = request->products[d3.seq].product_id, st.special_testing_id = request->
     products[d3.seq].specialtests[d4.seq].special_testing_id, st.special_testing_cd = request->
     products[d3.seq].specialtests[d4.seq].special_testing_cd,
     st.confirmed_ind = request->products[d3.seq].specialtests[d4.seq].confirmed_ind, st.updt_cnt = 0,
     st.active_ind = request->products[d3.seq].specialtests[d4.seq].active_ind,
     st.updt_dt_tm = cnvtdatetime(sysdate), st.updt_id = reqinfo->updt_id, st.updt_task = reqinfo->
     updt_task,
     st.updt_applctx = reqinfo->updt_applctx, st.active_status_cd =
     IF ((request->products[d3.seq].specialtests[d4.seq].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , st.active_status_dt_tm = cnvtdatetime(sysdate),
     st.active_status_prsnl_id = reqinfo->updt_id, st.product_rh_phenotype_id = request->products[d3
     .seq].specialtests[d4.seq].product_rh_phenotype_id, st.barcode_value_txt = request->products[d3
     .seq].specialtests[d4.seq].barcode_value,
     st.modifiable_flag = request->products[d3.seq].specialtests[d4.seq].modifiable_flag
    PLAN (d3)
     JOIN (d4
     WHERE d4.seq <= size(request->products[d3.seq].specialtests,5)
      AND (request->products[d3.seq].specialtests[d4.seq].add_ind=1))
     JOIN (st)
    WITH nocounter, status(request->products[d3.seq].specialtests[d4.seq].status)
   ;end insert
   SET success_count = 0
   FOR (i = 1 TO size(request->products,5))
     FOR (j = 1 TO size(request->products[i].specialtests,5))
       IF ((request->products[i].specialtests[j].status=1))
        SET success_count += 1
        SET request->products[i].specialtests[j].status = 0
       ENDIF
     ENDFOR
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->st_add_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Add count doesn't match insert count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "insert into special_testing"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->pe_add_cnt > 0))
   SET nmaxsize = (nmaxproduct * nmaxproductevent)
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxsize)
   INSERT  FROM product_event pe,
     (dummyt d4  WITH seq = value(nmaxproduct)),
     (dummyt d5  WITH seq = value(nmaxproductevent))
    SET pe.product_event_id = request->products[d4.seq].productevents[d5.seq].product_event_id, pe
     .product_id = request->products[d4.seq].product_id, pe.order_id = request->products[d4.seq].
     productevents[d5.seq].order_id,
     pe.bb_result_id = request->products[d4.seq].productevents[d5.seq].bb_result_id, pe.event_type_cd
      = request->products[d4.seq].productevents[d5.seq].event_type_cd, pe.event_dt_tm = cnvtdatetime(
      request->products[d4.seq].productevents[d5.seq].event_dt_tm),
     pe.event_prsnl_id =
     IF ((request->products[d4.seq].productevents[d5.seq].event_prsnl_id > 0.0)) request->products[d4
      .seq].productevents[d5.seq].event_prsnl_id
     ELSE reqinfo->updt_id
     ENDIF
     , pe.updt_cnt = 0, pe.active_ind = request->products[d4.seq].productevents[d5.seq].active_ind,
     pe.person_id = request->products[d4.seq].productevents[d5.seq].person_id, pe.encntr_id = request
     ->products[d4.seq].productevents[d5.seq].encntr_id, pe.override_ind = request->products[d4.seq].
     productevents[d5.seq].override_ind,
     pe.override_reason_cd = request->products[d4.seq].productevents[d5.seq].override_reason_cd, pe
     .related_product_event_id = 0, pe.updt_dt_tm = cnvtdatetime(sysdate),
     pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
     updt_applctx,
     pe.active_status_cd =
     IF ((request->products[d4.seq].productevents[d5.seq].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , pe.active_status_dt_tm = cnvtdatetime(sysdate), pe.active_status_prsnl_id = reqinfo->updt_id,
     pe.event_status_flag = request->products[d4.seq].productevents[d5.seq].event_status_flag, pe
     .event_tz =
     IF (curutc=1) curtimezoneapp
     ELSE 0
     ENDIF
     , pe.owner_area_cd =
     IF ((request->products[d4.seq].productevents[d5.seq].owner_area_cd <= 0)) request->products[d4
      .seq].cur_owner_area_cd
     ELSE request->products[d4.seq].productevents[d5.seq].owner_area_cd
     ENDIF
     ,
     pe.inventory_area_cd =
     IF ((request->products[d4.seq].productevents[d5.seq].inventory_area_cd <= 0)) request->products[
      d4.seq].cur_inv_area_cd
     ELSE request->products[d4.seq].productevents[d5.seq].inventory_area_cd
     ENDIF
    PLAN (d4)
     JOIN (d5
     WHERE d5.seq <= size(request->products[d4.seq].productevents,5)
      AND (request->products[d4.seq].productevents[d5.seq].add_ind=1))
     JOIN (pe)
    WITH nocounter, status(request->products[d4.seq].productevents[d5.seq].status)
   ;end insert
   SET success_count = 0
   UPDATE  FROM product_event pe,
     (dummyt d4  WITH seq = value(nmaxproduct)),
     (dummyt d5  WITH seq = value(nmaxproductevent))
    SET pe.related_product_event_id = request->products[d4.seq].productevents[d5.seq].
     related_product_event_id
    PLAN (d4)
     JOIN (d5
     WHERE d5.seq <= size(request->products[d4.seq].productevents,5)
      AND (request->products[d4.seq].productevents[d5.seq].add_ind=1))
     JOIN (pe
     WHERE (pe.product_event_id=request->products[d4.seq].productevents[d5.seq].product_event_id))
    WITH nocounter, status(request->products[d4.seq].productevents[d5.seq].status)
   ;end update
   FOR (i = 1 TO size(request->products,5))
     FOR (j = 1 TO size(request->products[i].productevents,5))
       IF ((request->products[i].productevents[j].status=1))
        SET success_count += 1
        SET request->products[i].productevents[j].status = 0
       ENDIF
     ENDFOR
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pe_add_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Add count doesn't match insert count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "insert into product_event"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
   FOR (i = 1 TO size(request->products,5))
     FOR (j = 1 TO size(request->products[i].productevents,5))
      SET cdf_meaning = uar_get_code_meaning(request->products[i].productevents[j].event_type_cd)
      IF (cdf_meaning="5")
       IF ((request->products[i].productevents[j].disposition.add_ind=1))
        INSERT  FROM disposition d
         SET d.product_event_id = request->products[i].productevents[j].product_event_id, d
          .product_id = request->products[i].product_id, d.reason_cd = request->products[i].
          productevents[j].disposition.reason_cd,
          d.disposed_qty = request->products[i].productevents[j].disposition.disposed_qty, d.updt_cnt
           = 0, d.active_ind = request->products[i].productevents[j].disposition.active_ind,
          d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
          updt_task,
          d.updt_applctx = reqinfo->updt_applctx, d.active_status_cd =
          IF ((request->products[i].productevents[j].active_ind=1)) reqdata->active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , d.active_status_dt_tm = cnvtdatetime(sysdate),
          d.active_status_prsnl_id = reqinfo->updt_id, d.disposed_intl_units = request->products[i].
          productevents[j].disposition.disposed_intl_units
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into disposition"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="2")
       IF ((request->products[i].productevents[j].quarantine.add_ind=1))
        INSERT  FROM quarantine q
         SET q.product_event_id = request->products[i].productevents[j].product_event_id, q
          .product_id = request->products[i].product_id, q.quar_reason_cd = request->products[i].
          productevents[j].quarantine.quar_reason_cd,
          q.updt_cnt = 0, q.active_ind = request->products[i].productevents[j].quarantine.active_ind,
          q.orig_quar_qty = request->products[i].productevents[j].quarantine.orig_quar_qty,
          q.cur_quar_qty = request->products[i].productevents[j].quarantine.cur_quar_qty, q
          .orig_quar_intl_units = request->products[i].productevents[j].quarantine.
          orig_quar_intl_units, q.cur_quar_intl_units = request->products[i].productevents[j].
          quarantine.cur_quar_intl_units,
          q.updt_dt_tm = cnvtdatetime(sysdate), q.updt_id = reqinfo->updt_id, q.updt_task = reqinfo->
          updt_task,
          q.updt_applctx = reqinfo->updt_applctx, q.active_status_cd =
          IF ((request->products[i].productevents[j].quarantine.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , q.active_status_dt_tm = cnvtdatetime(sysdate),
          q.active_status_prsnl_id = reqinfo->updt_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into quarantine"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (((cdf_meaning="10") OR (cdf_meaning="11")) )
       IF ((request->products[i].productevents[j].autodirected.add_ind=1))
        INSERT  FROM auto_directed ad
         SET ad.product_event_id = request->products[i].productevents[j].product_event_id, ad
          .product_id = request->products[i].product_id, ad.person_id = request->products[i].
          productevents[j].autodirected.person_id,
          ad.associated_dt_tm = cnvtdatetime(request->products[i].productevents[j].autodirected.
           associated_dt_tm), ad.updt_cnt = 0, ad.active_ind = request->products[i].productevents[j].
          autodirected.active_ind,
          ad.encntr_id = request->products[i].productevents[j].autodirected.encntr_id, ad
          .expected_usage_dt_tm = cnvtdatetime(request->products[i].productevents[j].autodirected.
           expected_usage_dt_tm), ad.donated_by_relative_ind = request->products[i].productevents[j].
          autodirected.donated_by_relative_ind,
          ad.updt_dt_tm = cnvtdatetime(sysdate), ad.updt_id = reqinfo->updt_id, ad.updt_task =
          reqinfo->updt_task,
          ad.updt_applctx = reqinfo->updt_applctx, ad.active_status_cd =
          IF ((request->products[i].productevents[j].autodirected.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , ad.active_status_dt_tm = cnvtdatetime(sysdate),
          ad.active_status_prsnl_id = reqinfo->updt_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into auto_directed"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (((cdf_meaning="8") OR (cdf_meaning="17")) )
       IF ((request->products[i].productevents[j].modification.add_ind=1))
        INSERT  FROM modification m
         SET m.product_event_id = request->products[i].productevents[j].product_event_id, m
          .product_id = request->products[i].product_id, m.orig_expire_dt_tm = cnvtdatetime(request->
           products[i].productevents[j].modification.orig_expire_dt_tm),
          m.orig_volume = request->products[i].productevents[j].modification.orig_volume, m
          .orig_unit_meas_cd = request->products[i].productevents[j].modification.orig_unit_meas_cd,
          m.cur_expire_dt_tm = cnvtdatetime(request->products[i].productevents[j].modification.
           cur_expire_dt_tm),
          m.cur_volume = request->products[i].productevents[j].modification.cur_volume, m
          .cur_unit_meas_cd = request->products[i].productevents[j].modification.cur_unit_meas_cd, m
          .modified_qty = request->products[i].productevents[j].modification.modified_qty,
          m.updt_cnt = 0, m.active_ind = request->products[i].productevents[j].modification.
          active_ind, m.crossover_reason_cd = request->products[i].productevents[j].modification.
          crossover_reason_cd,
          m.option_id = request->products[i].productevents[j].modification.option_id, m
          .device_type_cd = request->products[i].productevents[j].modification.device_type_cd, m
          .start_dt_tm = cnvtdatetime(request->products[i].productevents[j].modification.start_dt_tm),
          m.stop_dt_tm = cnvtdatetime(request->products[i].productevents[j].modification.stop_dt_tm),
          m.lot_nbr = request->products[i].productevents[j].modification.lot_nbr, m.accessory =
          request->products[i].productevents[j].modification.accessory,
          m.vis_insp_cd = request->products[i].productevents[j].modification.vis_insp_cd, m
          .updt_dt_tm = cnvtdatetime(sysdate), m.updt_id = reqinfo->updt_id,
          m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->updt_applctx, m
          .active_status_cd =
          IF ((request->products[i].productevents[j].modification.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          ,
          m.active_status_dt_tm = cnvtdatetime(sysdate), m.active_status_prsnl_id = reqinfo->updt_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into modification"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="1")
       IF ((request->products[i].productevents[j].assign.add_ind=1))
        INSERT  FROM assign a
         SET a.product_event_id = request->products[i].productevents[j].product_event_id, a
          .product_id = request->products[i].product_id, a.assign_reason_cd = request->products[i].
          productevents[j].assign.assign_reason_cd,
          a.person_id = request->products[i].productevents[j].assign.person_id, a.prov_id = request->
          products[i].productevents[j].assign.prov_id, a.updt_cnt = 0,
          a.active_ind = request->products[i].productevents[j].assign.active_ind, a.orig_assign_qty
           = request->products[i].productevents[j].assign.orig_assign_qty, a.cur_assign_qty = request
          ->products[i].productevents[j].assign.cur_assign_qty,
          a.orig_assign_intl_units = request->products[i].productevents[j].assign.
          orig_assign_intl_units, a.cur_assign_intl_units = request->products[i].productevents[j].
          assign.cur_assign_intl_units, a.updt_dt_tm = cnvtdatetime(sysdate),
          a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
          updt_applctx,
          a.active_status_cd =
          IF ((request->products[i].productevents[j].assign.active_ind=1)) reqdata->active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , a.active_status_dt_tm = cnvtdatetime(sysdate), a.active_status_prsnl_id = reqinfo->
          updt_id,
          a.bb_id_nbr = request->products[i].productevents[j].assign.bb_id_nbr
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into assign"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="7")
       IF ((request->products[i].productevents[j].transfusion.add_ind=1))
        INSERT  FROM transfusion t
         SET t.product_event_id = request->products[i].productevents[j].product_event_id, t
          .product_id = request->products[i].product_id, t.person_id = request->products[i].
          productevents[j].transfusion.person_id,
          t.transfused_intl_units = request->products[i].productevents[j].transfusion.
          transfused_intl_units, t.bag_returned_ind = request->products[i].productevents[j].
          transfusion.bag_returned_ind, t.tag_returned_ind = request->products[i].productevents[j].
          transfusion.tag_returned_ind,
          t.transfused_vol = request->products[i].productevents[j].transfusion.transfused_vol, t
          .updt_cnt = 0, t.active_ind = request->products[i].productevents[j].transfusion.active_ind,
          t.orig_transfused_qty = request->products[i].productevents[j].transfusion.
          orig_transfused_qty, t.cur_transfused_qty = request->products[i].productevents[j].
          transfusion.cur_transfused_qty, t.updt_dt_tm = cnvtdatetime(sysdate),
          t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
          updt_applctx,
          t.active_status_cd =
          IF ((request->products[i].productevents[j].transfusion.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , t.active_status_dt_tm = cnvtdatetime(sysdate), t.active_status_prsnl_id = reqinfo->
          updt_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into transfusion"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="14")
       IF ((request->products[i].productevents[j].destruction.add_ind=1))
        INSERT  FROM destruction d
         SET d.product_event_id = request->products[i].productevents[j].product_event_id, d
          .product_id = request->products[i].product_id, d.method_cd = request->products[i].
          productevents[j].destruction.method_cd,
          d.box_nbr = request->products[i].productevents[j].destruction.box_nbr, d.manifest_nbr =
          request->products[i].productevents[j].destruction.manifest_nbr, d.destroyed_qty = request->
          products[i].productevents[j].destruction.destroyed_qty,
          d.autoclave_ind = request->products[i].productevents[j].destruction.autoclave_ind, d
          .destruction_org_id = request->products[i].productevents[j].destruction.destruction_org_id,
          d.updt_cnt = 0,
          d.active_ind = request->products[i].productevents[j].destruction.active_ind, d.updt_dt_tm
           = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id,
          d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d
          .active_status_cd =
          IF ((request->products[i].productevents[j].destruction.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          ,
          d.active_status_dt_tm = cnvtdatetime(sysdate), d.active_status_prsnl_id = reqinfo->updt_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into destruction"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="12")
       IF ((request->products[i].productevents[j].abotesting.add_ind=1))
        INSERT  FROM abo_testing at
         SET at.product_event_id = request->products[i].productevents[j].product_event_id, at
          .product_id = request->products[i].product_id, at.abo_testing_id = request->products[i].
          productevents[j].abotesting.abo_testing_id,
          at.result_id = request->products[i].productevents[j].abotesting.result_id, at.abo_group_cd
           = request->products[i].productevents[j].abotesting.abo_group_cd, at.rh_type_cd = request->
          products[i].productevents[j].abotesting.rh_type_cd,
          at.current_updated_ind = request->products[i].productevents[j].abotesting.
          current_updated_ind, at.updt_cnt = 0, at.active_ind = request->products[i].productevents[j]
          .abotesting.active_ind,
          at.updt_dt_tm = cnvtdatetime(sysdate), at.updt_id = reqinfo->updt_id, at.updt_task =
          reqinfo->updt_task,
          at.updt_applctx = reqinfo->updt_applctx, at.active_status_cd =
          IF ((request->products[i].productevents[j].abotesting.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , at.active_status_dt_tm = cnvtdatetime(sysdate),
          at.active_status_prsnl_id = reqinfo->updt_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into abo_testing"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="6")
       IF ((request->products[i].productevents[j].transfer.add_ind=1))
        INSERT  FROM transfer t
         SET t.product_event_id = request->products[i].productevents[j].product_event_id, t
          .product_id = request->products[i].product_id, t.transferring_locn_cd = request->products[i
          ].productevents[j].transfer.transferring_locn_cd,
          t.transfer_cond_cd = request->products[i].productevents[j].transfer.transfer_cond_cd, t
          .transfer_reason_cd = request->products[i].productevents[j].transfer.transfer_reason_cd, t
          .transfer_vis_insp_cd = request->products[i].productevents[j].transfer.transfer_vis_insp_cd,
          t.transfer_qty = request->products[i].productevents[j].transfer.transfer_qty, t.login_dt_tm
           = cnvtdatetime(request->products[i].productevents[j].transfer.login_dt_tm), t
          .login_prsnl_id = request->products[i].productevents[j].transfer.login_prsnl_id,
          t.login_cond_cd = request->products[i].productevents[j].transfer.login_cond_cd, t
          .login_vis_insp_cd = request->products[i].productevents[j].transfer.login_vis_insp_cd, t
          .login_qty = request->products[i].productevents[j].transfer.login_qty,
          t.return_dt_tm = cnvtdatetime(request->products[i].productevents[j].transfer.return_dt_tm),
          t.return_prsnl_id = request->products[i].productevents[j].transfer.return_prsnl_id, t
          .return_reason_cd = request->products[i].productevents[j].transfer.return_reason_cd,
          t.return_cond_cd = request->products[i].productevents[j].transfer.return_cond_cd, t
          .return_vis_insp_cd = request->products[i].productevents[j].transfer.return_vis_insp_cd, t
          .return_qty = request->products[i].productevents[j].transfer.return_qty,
          t.updt_cnt = 0, t.active_ind = request->products[i].productevents[j].transfer.active_ind, t
          .updt_dt_tm = cnvtdatetime(sysdate),
          t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
          updt_applctx,
          t.active_status_cd =
          IF ((request->products[i].productevents[j].transfer.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , t.active_status_dt_tm = cnvtdatetime(sysdate), t.active_status_prsnl_id = reqinfo->
          updt_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into transfer"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((request->products[i].productevents[j].bbdevicetransfer.add_ind=1))
        INSERT  FROM bb_device_transfer bd
         SET bd.product_event_id = request->products[i].productevents[j].product_event_id, bd
          .product_id = request->products[i].product_id, bd.from_device_id = request->products[i].
          productevents[j].bbdevicetransfer.from_device_id,
          bd.to_device_id = request->products[i].productevents[j].bbdevicetransfer.to_device_id, bd
          .reason_cd = request->products[i].productevents[j].bbdevicetransfer.reason_cd, bd.updt_cnt
           = 0,
          bd.updt_dt_tm = cnvtdatetime(sysdate), bd.updt_id = reqinfo->updt_id, bd.updt_task =
          reqinfo->updt_task,
          bd.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into bbdevice_transfer"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((request->products[i].productevents[j].bbinventorytransfer.add_ind=1))
        INSERT  FROM bb_inventory_transfer bit
         SET bit.from_owner_area_cd = request->products[i].productevents[j].bbinventorytransfer.
          from_owner_area_cd, bit.from_inv_area_cd = request->products[i].productevents[j].
          bbinventorytransfer.from_inv_area_cd, bit.product_event_id = request->products[i].
          productevents[j].product_event_id,
          bit.transfer_reason_cd = request->products[i].productevents[j].bbinventorytransfer.
          transfer_reason_cd, bit.to_owner_area_cd = request->products[i].productevents[j].
          bbinventorytransfer.to_owner_area_cd, bit.to_inv_area_cd = request->products[i].
          productevents[j].bbinventorytransfer.to_inv_area_cd,
          bit.updt_cnt = 0, bit.updt_dt_tm = cnvtdatetime(sysdate), bit.updt_id = reqinfo->updt_id,
          bit.updt_task = reqinfo->updt_task, bit.updt_applctx = reqinfo->updt_applctx, bit
          .transferred_qty = request->products[i].productevents[j].bbinventorytransfer.
          transferred_qty,
          bit.transferred_intl_unit = request->products[i].productevents[j].bbinventorytransfer.
          transferred_iu, bit.to_product_event_id = request->products[i].productevents[j].
          related_product_event_id, bit.event_type_cd = request->products[i].productevents[j].
          bbinventorytransfer.event_type_cd
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname =
         "insert into bb_inventory_transfer"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="3")
       IF ((request->products[i].productevents[j].crossmatch.add_ind=1))
        INSERT  FROM crossmatch c
         SET c.product_event_id = request->products[i].productevents[j].product_event_id, c
          .product_id = request->products[i].product_id, c.crossmatch_qty = request->products[i].
          productevents[j].crossmatch.crossmatch_qty,
          c.release_dt_tm = cnvtdatetime(request->products[i].productevents[j].crossmatch.
           release_dt_tm), c.release_prsnl_id =
          IF ((request->products[i].productevents[j].crossmatch.release_prsnl_id > 0)) request->
           products[i].productevents[j].crossmatch.release_prsnl_id
          ELSE reqinfo->updt_id
          ENDIF
          , c.release_reason_cd = request->products[i].productevents[j].crossmatch.release_reason_cd,
          c.release_qty = request->products[i].productevents[j].crossmatch.release_qty, c.updt_cnt =
          0, c.active_ind = request->products[i].productevents[j].crossmatch.active_ind,
          c.crossmatch_exp_dt_tm = cnvtdatetime(request->products[i].productevents[j].crossmatch.
           crossmatch_exp_dt_tm), c.reinstate_reason_cd = request->products[i].productevents[j].
          crossmatch.reinstate_reason_cd, c.bb_id_nbr = request->products[i].productevents[j].
          crossmatch.bb_id_nbr,
          c.xm_reason_cd = request->products[i].productevents[j].crossmatch.xm_reason_cd, c
          .updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id,
          c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c
          .active_status_cd =
          IF ((request->products[i].productevents[j].crossmatch.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          ,
          c.active_status_dt_tm = cnvtdatetime(sysdate), c.active_status_prsnl_id = reqinfo->updt_id,
          c.person_id = request->products[i].productevents[j].crossmatch.person_id
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into crossmatch"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="4")
       IF ((request->products[i].productevents[j].patientdispense.add_ind=1))
        INSERT  FROM patient_dispense pd
         SET pd.product_event_id = request->products[i].productevents[j].product_event_id, pd
          .product_id = request->products[i].product_id, pd.person_id = request->products[i].
          productevents[j].patientdispense.person_id,
          pd.dispense_prov_id = request->products[i].productevents[j].patientdispense.
          dispense_prov_id, pd.dispense_reason_cd = request->products[i].productevents[j].
          patientdispense.dispense_reason_cd, pd.dispense_to_locn_cd = request->products[i].
          productevents[j].patientdispense.dispense_to_locn_cd,
          pd.dispense_from_locn_cd = request->products[i].productevents[j].patientdispense.
          dispense_from_locn_cd, pd.device_id = request->products[i].productevents[j].patientdispense
          .device_id, pd.dispense_vis_insp_cd = request->products[i].productevents[j].patientdispense
          .dispense_vis_insp_cd,
          pd.dispense_cooler_id = request->products[i].productevents[j].patientdispense.
          dispense_cooler_id, pd.dispense_cooler_text = request->products[i].productevents[j].
          patientdispense.dispense_cooler_text, pd.dispense_courier_id = request->products[i].
          productevents[j].patientdispense.dispense_courier_id,
          pd.dispense_status_flag = request->products[i].productevents[j].patientdispense.
          dispense_status_flag, pd.orig_dispense_intl_units = request->products[i].productevents[j].
          patientdispense.orig_dispense_intl_units, pd.cur_dispense_intl_units = request->products[i]
          .productevents[j].patientdispense.cur_dispense_intl_units,
          pd.orig_dispense_qty = request->products[i].productevents[j].patientdispense.
          orig_dispense_qty, pd.cur_dispense_qty = request->products[i].productevents[j].
          patientdispense.cur_dispense_qty, pd.unknown_patient_ind = request->products[i].
          productevents[j].patientdispense.unknown_patient_ind,
          pd.unknown_patient_text = request->products[i].productevents[j].patientdispense.
          unknown_patient_text, pd.updt_cnt = 0, pd.active_ind = request->products[i].productevents[j
          ].patientdispense.active_ind,
          pd.dispense_courier_text = request->products[i].productevents[j].patientdispense.
          dispense_courier_text, pd.updt_dt_tm = cnvtdatetime(sysdate), pd.updt_id = reqinfo->updt_id,
          pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo->updt_applctx, pd
          .active_status_cd =
          IF ((request->products[i].productevents[j].patientdispense.active_ind=1)) reqdata->
           active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          ,
          pd.active_status_dt_tm = cnvtdatetime(sysdate), pd.active_status_prsnl_id = reqinfo->
          updt_id, pd.bb_id_nbr = request->products[i].productevents[j].patientdispense.bb_id_nbr
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into patient_dispense"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="13")
       IF ((request->products[i].productevents[j].receipt.add_ind=1))
        INSERT  FROM receipt r
         SET r.product_event_id = request->products[i].productevents[j].product_event_id, r
          .product_id = request->products[i].product_id, r.active_ind = request->products[i].
          productevents[j].receipt.active_ind,
          r.ship_cond_cd = request->products[i].productevents[j].receipt.ship_cond_cd, r.vis_insp_cd
           = request->products[i].productevents[j].receipt.vis_insp_cd, r.orig_rcvd_qty = request->
          products[i].productevents[j].receipt.orig_rcvd_qty,
          r.orig_intl_units = request->products[i].productevents[j].receipt.orig_intl_units, r
          .updt_cnt = 0, r.bb_supplier_id = request->products[i].productevents[j].receipt.
          bb_supplier_id,
          r.alpha_translation_id = request->products[i].productevents[j].receipt.alpha_translation_id,
          r.temperature_value = request->products[i].productevents[j].receipt.temperature_value, r
          .temperature_degree_cd = request->products[i].productevents[j].receipt.
          temperature_degree_cd,
          r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
          updt_task,
          r.updt_applctx = reqinfo->updt_applctx, r.active_status_cd =
          IF ((request->products[i].productevents[j].receipt.active_ind=1)) reqdata->active_status_cd
          ELSE reqdata->inactive_status_cd
          ENDIF
          , r.active_status_dt_tm = cnvtdatetime(sysdate),
          r.active_status_prsnl_id = reqinfo->updt_id, r.electronic_receipt_ind = request->products[i
          ].productevents[j].receipt.electronic_receipt_ind
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into receipt"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ELSEIF (cdf_meaning="23")
       IF ((request->products[i].productevents[j].bblabelverify.add_ind=1))
        INSERT  FROM bb_label_verify blv
         SET blv.active_ind = 1, blv.active_status_cd = reqdata->active_status_cd, blv
          .active_status_dt_tm = cnvtdatetime(sysdate),
          blv.active_status_prsnl_id = reqinfo->updt_id, blv.bb_label_verify_id = request->products[i
          ].productevents[j].bblabelverify.bb_label_verify_id, blv.label_verf_dt_tm = cnvtdatetime(
           request->products[i].productevents[j].bblabelverify.label_verf_dt_tm),
          blv.personnel_id = reqinfo->updt_id, blv.product_id = request->products[i].product_id, blv
          .updt_applctx = reqinfo->updt_applctx,
          blv.updt_cnt = 0, blv.updt_dt_tm = cnvtdatetime(sysdate), blv.updt_id = reqinfo->updt_id,
          blv.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "insert into bb_label_verify"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->chg_exists_ind=1))
  IF ((request->pr_chg_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   UPDATE  FROM product p,
     (dummyt d  WITH seq = value(nmaxproduct))
    SET p.product_id = request->products[d.seq].product_id, p.product_cd = request->products[d.seq].
     product_cd, p.product_cat_cd = request->products[d.seq].product_cat_cd,
     p.product_class_cd = request->products[d.seq].product_class_cd, p.product_nbr = request->
     products[d.seq].product_nbr, p.product_sub_nbr = request->products[d.seq].product_sub_nbr,
     p.alternate_nbr = request->products[d.seq].alternate_nbr, p.flag_chars = request->products[d.seq
     ].flag_chars, p.pooled_product_id = request->products[d.seq].pooled_product_id,
     p.modified_product_id = request->products[d.seq].modified_product_id, p.locked_ind = request->
     products[d.seq].locked_ind, p.cur_inv_locn_cd = request->products[d.seq].cur_inv_locn_cd,
     p.orig_inv_locn_cd = request->products[d.seq].orig_inv_locn_cd, p.cur_supplier_id = request->
     products[d.seq].cur_supplier_id, p.recv_dt_tm = cnvtdatetime(request->products[d.seq].recv_dt_tm
      ),
     p.recv_prsnl_id = request->products[d.seq].recv_prsnl_id, p.orig_ship_cond_cd = request->
     products[d.seq].orig_ship_cond_cd, p.orig_vis_insp_cd = request->products[d.seq].
     orig_vis_insp_cd,
     p.storage_temp_cd = request->products[d.seq].storage_temp_cd, p.cur_unit_meas_cd = request->
     products[d.seq].cur_unit_meas_cd, p.orig_unit_meas_cd = request->products[d.seq].
     orig_unit_meas_cd,
     p.pooled_product_ind = request->products[d.seq].pooled_product_ind, p.modified_product_ind =
     request->products[d.seq].modified_product_ind, p.corrected_ind = request->products[d.seq].
     corrected_ind,
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.active_ind = request
     ->products[d.seq].active_ind,
     p.cur_expire_dt_tm = cnvtdatetime(request->products[d.seq].cur_expire_dt_tm), p
     .cur_owner_area_cd = request->products[d.seq].cur_owner_area_cd, p.cur_inv_area_cd = request->
     products[d.seq].cur_inv_area_cd,
     p.cur_inv_device_id = request->products[d.seq].cur_inv_device_id, p.cur_dispense_device_id =
     request->products[d.seq].cur_dispense_device_id, p.contributor_system_cd = request->products[d
     .seq].contributor_system_cd,
     p.pool_option_id = request->products[d.seq].pool_option_id, p.barcode_nbr = request->products[d
     .seq].barcode_nbr, p.create_dt_tm = cnvtdatetime(request->products[d.seq].create_dt_tm),
     p.active_status_cd =
     IF ((request->products[d.seq].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , p.active_status_dt_tm =
     IF ((request->products[d.seq].active_status_chg_ind=1)) cnvtdatetime(sysdate)
     ELSE p.active_status_dt_tm
     ENDIF
     , p.active_status_prsnl_id =
     IF ((request->products[d.seq].active_status_chg_ind=1)) reqinfo->updt_id
     ELSE p.active_status_prsnl_id
     ENDIF
     ,
     p.donated_by_relative_ind = request->products[d.seq].donated_by_relative_ind, p.disease_cd =
     request->products[d.seq].disease_cd, p.donation_type_cd = request->products[d.seq].
     donation_type_cd,
     p.electronic_entry_flag =
     IF ((request->products[d.seq].electronic_entry_chg_ind=1)) request->products[d.seq].
      electronic_entry_flag
     ELSE p.electronic_entry_flag
     ENDIF
     , p.req_label_verify_ind = request->products[d.seq].req_label_verify_ind, p
     .intended_use_print_parm_txt = request->products[d.seq].intended_use_print_parm_txt,
     p.product_type_barcode = request->products[d.seq].product_type_barcode, p.serial_number_txt =
     IF ((((request->products[d.seq].serial_number_txt != " ")) OR ((request->products[d.seq].
     serial_number_txt != null))) ) trim(request->products[d.seq].serial_number_txt)
     ENDIF
    PLAN (d
     WHERE (request->products[d.seq].change_ind=1))
     JOIN (p
     WHERE (p.product_id=request->products[d.seq].product_id)
      AND (p.updt_cnt=request->products[d.seq].updt_cnt))
    WITH nocounter, status(acd_status->statuslist[d.seq].status)
   ;end update
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pr_chg_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Change count doesn't match update count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "update into product"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->de_chg_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   SET p_cnt_sub = value(nmaxproduct)
   FOR (p_cnt = 1 TO p_cnt_sub)
     SET pe_assgn_or_quar_ind = 0
     SET deriv_cur_avail_qty = request->products[p_cnt].derivatives.cur_avail_qty
     SET deriv_cur_intl_units = request->products[p_cnt].derivatives.cur_intl_units
     SET pe_cnt_sub = size(request->products[p_cnt].productevents,5)
     FOR (pe_cnt = 1 TO pe_cnt_sub)
      SET cdf_meaning = trim(uar_get_code_meaning(request->products[p_cnt].productevents[pe_cnt].
        event_type_cd))
      IF ((((request->products[p_cnt].productevents[pe_cnt].add_ind=1)) OR ((request->products[p_cnt]
      .productevents[pe_cnt].change_ind=1)))
       AND ((cdf_meaning="1") OR (cdf_meaning="2")) )
       SET pe_assgn_or_quar_ind = 1
       SET pe_cnt = pe_cnt_sub
      ENDIF
     ENDFOR
     UPDATE  FROM derivative d
      SET d.product_id = request->products[p_cnt].product_id, d.product_cd = request->products[p_cnt]
       .derivatives.product_cd, d.item_volume = request->products[p_cnt].derivatives.item_volume,
       d.item_unit_meas_cd = request->products[p_cnt].derivatives.item_unit_meas_cd, d.updt_cnt = (d
       .updt_cnt+ 1), d.active_ind = request->products[p_cnt].derivatives.active_ind,
       d.manufacturer_id = request->products[p_cnt].derivatives.manufacturer_id, d.cur_avail_qty =
       IF (pe_assgn_or_quar_ind) d.cur_avail_qty
       ELSE deriv_cur_avail_qty
       ENDIF
       , d.units_per_vial = request->products[p_cnt].derivatives.units_per_vial,
       d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
       updt_task,
       d.updt_applctx = reqinfo->updt_applctx, d.active_status_cd =
       IF ((request->products[p_cnt].derivatives.active_ind=1)) reqdata->active_status_cd
       ELSE reqdata->inactive_status_cd
       ENDIF
       , d.active_status_dt_tm =
       IF ((request->products[p_cnt].derivatives.active_status_chg_ind=1)) cnvtdatetime(sysdate)
       ELSE d.active_status_dt_tm
       ENDIF
       ,
       d.active_status_prsnl_id =
       IF ((request->products[p_cnt].derivatives.active_status_chg_ind=1)) reqinfo->updt_id
       ELSE d.active_status_prsnl_id
       ENDIF
       , d.cur_intl_units =
       IF (pe_assgn_or_quar_ind=1) d.cur_intl_units
       ELSE deriv_cur_intl_units
       ENDIF
      WHERE (d.product_id=request->products[p_cnt].product_id)
       AND (d.updt_cnt=request->products[p_cnt].derivatives.updt_cnt)
       AND (request->products[p_cnt].derivatives.change_ind=1)
      WITH nocounter, status(acd_status->statuslist[p_cnt].status)
     ;end update
   ENDFOR
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->de_chg_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Change count doesn't match update count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "update into derivative"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->bp_chg_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   UPDATE  FROM blood_product bp,
     (dummyt d2  WITH seq = value(nmaxproduct))
    SET bp.product_id = request->products[d2.seq].product_id, bp.product_cd = request->products[d2
     .seq].bloodproducts.product_cd, bp.supplier_prefix = request->products[d2.seq].bloodproducts.
     supplier_prefix,
     bp.cur_volume = request->products[d2.seq].bloodproducts.cur_volume, bp.orig_label_abo_cd =
     request->products[d2.seq].bloodproducts.orig_label_abo_cd, bp.orig_label_rh_cd = request->
     products[d2.seq].bloodproducts.orig_label_rh_cd,
     bp.cur_abo_cd = request->products[d2.seq].bloodproducts.cur_abo_cd, bp.cur_rh_cd = request->
     products[d2.seq].bloodproducts.cur_rh_cd, bp.segment_nbr = request->products[d2.seq].
     bloodproducts.segment_nbr,
     bp.orig_expire_dt_tm = cnvtdatetime(request->products[d2.seq].bloodproducts.orig_expire_dt_tm),
     bp.orig_volume = request->products[d2.seq].bloodproducts.orig_volume, bp.lot_nbr = request->
     products[d2.seq].bloodproducts.lot_nbr,
     bp.autologous_ind = request->products[d2.seq].bloodproducts.autologous_ind, bp.directed_ind =
     request->products[d2.seq].bloodproducts.directed_ind, bp.drawn_dt_tm = cnvtdatetime(request->
      products[d2.seq].bloodproducts.drawn_dt_tm),
     bp.updt_cnt = (bp.updt_cnt+ 1), bp.active_ind = request->products[d2.seq].bloodproducts.
     active_ind, bp.donor_person_id = request->products[d2.seq].bloodproducts.donor_person_id,
     bp.updt_dt_tm = cnvtdatetime(sysdate), bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->
     updt_task,
     bp.updt_applctx = reqinfo->updt_applctx, bp.active_status_cd =
     IF ((request->products[d2.seq].bloodproducts.active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , bp.active_status_dt_tm =
     IF ((request->products[d2.seq].bloodproducts.active_status_chg_ind=1)) cnvtdatetime(sysdate)
     ELSE bp.active_status_dt_tm
     ENDIF
     ,
     bp.active_status_prsnl_id =
     IF ((request->products[d2.seq].bloodproducts.active_status_chg_ind=1)) reqinfo->updt_id
     ELSE bp.active_status_prsnl_id
     ENDIF
    PLAN (d2
     WHERE (request->products[d2.seq].bloodproducts.change_ind=1))
     JOIN (bp
     WHERE (bp.product_id=request->products[d2.seq].product_id)
      AND (bp.updt_cnt=request->products[d2.seq].bloodproducts.updt_cnt))
    WITH nocounter, status(acd_status->statuslist[d2.seq].status)
   ;end update
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->bp_chg_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Change count doesn't match update count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "update into blood_product"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->pn_chg_cnt > 0))
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   UPDATE  FROM product_note pn,
     (dummyt d2  WITH seq = value(nmaxproduct))
    SET pn.updt_cnt = (pn.updt_cnt+ 1), pn.active_ind = 0, pn.updt_dt_tm = cnvtdatetime(sysdate),
     pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
     updt_applctx,
     pn.active_status_cd = reqdata->inactive_status_cd, pn.active_status_dt_tm = cnvtdatetime(sysdate
      ), pn.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d2
     WHERE (request->products[d2.seq].productnote.change_ind=1))
     JOIN (pn
     WHERE (pn.product_note_id=request->products[d2.seq].productnote.old_product_note_id)
      AND (pn.updt_cnt=request->products[d2.seq].productnote.old_updt_cnt))
    WITH nocounter, status(acd_status->statuslist[d2.seq].status)
   ;end update
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pn_chg_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Change count doesn't match update count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "update into product_note"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
   SET nchgprod = 0
   FOR (idx = 1 TO size(request->products,5))
     IF ((request->products[idx].productnote.change_ind=1)
      AND (request->products[idx].productnote.add_ind=0))
      SET nchgprod += 1
     ENDIF
   ENDFOR
   IF (nchgprod > 0)
    SET stat = alterlist(acd_status->statuslist,0)
    SET stat = alterlist(acd_status->statuslist,nmaxproduct)
    INSERT  FROM product_note pn,
      (dummyt d2  WITH seq = value(nmaxproduct))
     SET pn.product_id = request->products[d2.seq].product_id, pn.product_note_id = request->
      products[d2.seq].productnote.new_product_note_id, pn.long_text_id = request->products[d2.seq].
      productnote.new_long_text_id,
      pn.updt_cnt = 0, pn.active_ind = 1, pn.updt_dt_tm = cnvtdatetime(sysdate),
      pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->
      updt_applctx,
      pn.active_status_cd = reqdata->active_status_cd, pn.active_status_dt_tm = cnvtdatetime(sysdate),
      pn.active_status_prsnl_id = reqinfo->updt_id
     PLAN (d2
      WHERE (request->products[d2.seq].productnote.change_ind=1)
       AND (request->products[d2.seq].productnote.add_ind=0))
      JOIN (pn)
     WITH nocounter, status(acd_status->statuslist[d2.seq].status)
    ;end insert
    SET success_count = 0
    FOR (i = 1 TO size(acd_status->statuslist,5))
      IF ((acd_status->statuslist[i].status=1))
       SET success_count += 1
      ENDIF
    ENDFOR
    SET serror_check = error(serrormsg,0)
    IF (nchgprod != success_count)
     IF (serror_check != 0)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
     ELSE
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Change count doesn't match insert count"
     ENDIF
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "insert into product_note"
     GO TO exit_script
    ENDIF
    SET stat = alterlist(acd_status->statuslist,0)
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxproduct)
   UPDATE  FROM long_text lt,
     (dummyt d2  WITH seq = value(nmaxproduct))
    SET lt.updt_cnt = (lt.updt_cnt+ 1), lt.active_ind = 0, lt.updt_dt_tm = cnvtdatetime(sysdate),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_status_cd = reqdata->inactive_status_cd, lt.active_status_dt_tm = cnvtdatetime(sysdate
      ), lt.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d2
     WHERE (request->products[d2.seq].productnote.change_ind=1))
     JOIN (lt
     WHERE (lt.long_text_id=request->products[d2.seq].productnote.old_long_text_id)
      AND (lt.updt_cnt=request->products[d2.seq].productnote.old_updt_cnt))
    WITH nocounter, status(acd_status->statuslist[d2.seq].status)
   ;end update
   SET success_count = 0
   FOR (i = 1 TO size(acd_status->statuslist,5))
     IF ((acd_status->statuslist[i].status=1))
      SET success_count += 1
     ENDIF
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pn_chg_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Chg count doesn't match update count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "update into long_text"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
   IF (nchgprod > 0)
    SET stat = alterlist(acd_status->statuslist,0)
    SET stat = alterlist(acd_status->statuslist,nmaxproduct)
    INSERT  FROM long_text lt,
      (dummyt d2  WITH seq = value(nmaxproduct))
     SET lt.long_text_id = request->products[d2.seq].productnote.new_long_text_id, lt.long_text =
      request->products[d2.seq].productnote.product_note, lt.parent_entity_name = "PRODUCT_NOTE",
      lt.parent_entity_id = request->products[d2.seq].productnote.new_product_note_id, lt.updt_cnt =
      0, lt.active_ind = 1,
      lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->
      updt_task,
      lt.updt_applctx = reqinfo->updt_applctx, lt.active_status_cd = reqdata->active_status_cd, lt
      .active_status_dt_tm = cnvtdatetime(sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id
     PLAN (d2
      WHERE (request->products[d2.seq].productnote.change_ind=1)
       AND (request->products[d2.seq].productnote.add_ind=0))
      JOIN (lt)
     WITH nocounter, status(acd_status->statuslist[d2.seq].status)
    ;end insert
    SET success_count = 0
    FOR (i = 1 TO size(acd_status->statuslist,5))
      IF ((acd_status->statuslist[i].status=1))
       SET success_count += 1
      ENDIF
    ENDFOR
    SET serror_check = error(serrormsg,0)
    IF (nchgprod != success_count)
     IF (serror_check != 0)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
     ELSE
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Change count doesn't match insert count"
     ENDIF
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "insert into long_text"
     GO TO exit_script
    ENDIF
    SET stat = alterlist(acd_status->statuslist,0)
   ENDIF
  ENDIF
  IF ((request->st_chg_cnt > 0))
   SET nmaxsize = (nmaxproduct * nmaxspecialtestings)
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxsize)
   UPDATE  FROM special_testing st,
     (dummyt d3  WITH seq = value(nmaxproduct)),
     (dummyt d4  WITH seq = value(nmaxspecialtestings))
    SET st.product_id = request->products[d3.seq].product_id, st.special_testing_id = request->
     products[d3.seq].specialtests[d4.seq].special_testing_id, st.special_testing_cd = request->
     products[d3.seq].specialtests[d4.seq].special_testing_cd,
     st.confirmed_ind = request->products[d3.seq].specialtests[d4.seq].confirmed_ind, st.updt_cnt = (
     st.updt_cnt+ 1), st.active_ind = request->products[d3.seq].specialtests[d4.seq].active_ind,
     st.updt_dt_tm = cnvtdatetime(sysdate), st.updt_id = reqinfo->updt_id, st.updt_task = reqinfo->
     updt_task,
     st.updt_applctx = reqinfo->updt_applctx, st.active_status_cd =
     IF ((request->products[d3.seq].specialtests[d4.seq].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , st.active_status_dt_tm =
     IF ((request->products[d3.seq].specialtests[d4.seq].active_status_chg_ind=1)) cnvtdatetime(
       sysdate)
     ELSE st.active_status_dt_tm
     ENDIF
     ,
     st.active_status_prsnl_id =
     IF ((request->products[d3.seq].specialtests[d4.seq].active_status_chg_ind=1)) reqinfo->updt_id
     ELSE st.active_status_prsnl_id
     ENDIF
     , st.product_rh_phenotype_id = request->products[d3.seq].specialtests[d4.seq].
     product_rh_phenotype_id
    PLAN (d3)
     JOIN (d4
     WHERE d4.seq <= size(request->products[d3.seq].specialtests,5)
      AND (request->products[d3.seq].specialtests[d4.seq].change_ind=1))
     JOIN (st
     WHERE (st.product_id=request->products[d3.seq].product_id)
      AND (st.special_testing_id=request->products[d3.seq].specialtests[d4.seq].special_testing_id)
      AND (st.updt_cnt=request->products[d3.seq].specialtests[d4.seq].updt_cnt))
    WITH nocounter, status(request->products[d3.seq].specialtests[d4.seq].status)
   ;end update
   SET success_count = 0
   FOR (i = 1 TO size(request->products,5))
     FOR (j = 1 TO size(request->products[i].specialtests,5))
       IF ((request->products[i].specialtests[j].status=1))
        SET success_count += 1
        SET request->products[i].specialtests[j].status = 0
       ENDIF
     ENDFOR
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->st_chg_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Change count doesn't match update count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "update into special_testing"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  IF ((request->pe_chg_cnt > 0))
   SET nmaxsize = (nmaxproduct * nmaxproductevent)
   SET stat = alterlist(acd_status->statuslist,0)
   SET stat = alterlist(acd_status->statuslist,nmaxsize)
   UPDATE  FROM product_event pe,
     (dummyt d4  WITH seq = value(nmaxproduct)),
     (dummyt d5  WITH seq = value(nmaxproductevent))
    SET pe.product_event_id = request->products[d4.seq].productevents[d5.seq].product_event_id, pe
     .product_id = request->products[d4.seq].product_id, pe.order_id = request->products[d4.seq].
     productevents[d5.seq].order_id,
     pe.bb_result_id = request->products[d4.seq].productevents[d5.seq].bb_result_id, pe.event_type_cd
      = request->products[d4.seq].productevents[d5.seq].event_type_cd, pe.event_dt_tm = cnvtdatetime(
      request->products[d4.seq].productevents[d5.seq].event_dt_tm),
     pe.event_prsnl_id =
     IF ((request->products[d4.seq].productevents[d5.seq].event_prsnl_id > 0.0)) request->products[d4
      .seq].productevents[d5.seq].event_prsnl_id
     ELSE reqinfo->updt_id
     ENDIF
     , pe.updt_cnt = (pe.updt_cnt+ 1), pe.active_ind = request->products[d4.seq].productevents[d5.seq
     ].active_ind,
     pe.person_id = request->products[d4.seq].productevents[d5.seq].person_id, pe.encntr_id = request
     ->products[d4.seq].productevents[d5.seq].encntr_id, pe.override_ind = request->products[d4.seq].
     productevents[d5.seq].override_ind,
     pe.override_reason_cd = request->products[d4.seq].productevents[d5.seq].override_reason_cd, pe
     .related_product_event_id = request->products[d4.seq].productevents[d5.seq].
     related_product_event_id, pe.updt_dt_tm = cnvtdatetime(sysdate),
     pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
     updt_applctx,
     pe.active_status_cd =
     IF ((request->products[d4.seq].productevents[d5.seq].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , pe.active_status_dt_tm =
     IF ((request->products[d4.seq].productevents[d5.seq].active_status_chg_ind=1)) cnvtdatetime(
       sysdate)
     ELSE pe.active_status_dt_tm
     ENDIF
     , pe.active_status_prsnl_id =
     IF ((request->products[d4.seq].productevents[d5.seq].active_status_chg_ind=1)) reqinfo->updt_id
     ELSE pe.active_status_prsnl_id
     ENDIF
     ,
     pe.event_status_flag = request->products[d4.seq].productevents[d5.seq].event_status_flag, pe
     .owner_area_cd =
     IF ((request->products[d4.seq].productevents[d5.seq].owner_area_cd <= 0)) request->products[d4
      .seq].cur_owner_area_cd
     ELSE request->products[d4.seq].productevents[d5.seq].owner_area_cd
     ENDIF
     , pe.inventory_area_cd =
     IF ((request->products[d4.seq].productevents[d5.seq].inventory_area_cd <= 0)) request->products[
      d4.seq].cur_inv_area_cd
     ELSE request->products[d4.seq].productevents[d5.seq].inventory_area_cd
     ENDIF
    PLAN (d4)
     JOIN (d5
     WHERE d5.seq <= size(request->products[d4.seq].productevents,5)
      AND (request->products[d4.seq].productevents[d5.seq].change_ind=1))
     JOIN (pe
     WHERE (pe.product_event_id=request->products[d4.seq].productevents[d5.seq].product_event_id)
      AND (pe.updt_cnt=request->products[d4.seq].productevents[d5.seq].updt_cnt))
    WITH nocounter, status(request->products[d4.seq].productevents[d5.seq].status)
   ;end update
   SET success_count = 0
   FOR (i = 1 TO size(request->products,5))
     FOR (j = 1 TO size(request->products[i].productevents,5))
       IF ((request->products[i].productevents[j].status=1))
        SET success_count += 1
        SET request->products[i].productevents[j].status = 0
       ENDIF
     ENDFOR
   ENDFOR
   SET serror_check = error(serrormsg,0)
   IF ((request->pe_chg_cnt != success_count))
    IF (serror_check != 0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Change count doesn't match update count"
    ENDIF
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "update into product_event"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(acd_status->statuslist,0)
  ENDIF
  FOR (i = 1 TO size(request->products,5))
    FOR (j = 1 TO size(request->products[i].productevents,5))
     SET cdf_meaning = uar_get_code_meaning(request->products[i].productevents[j].event_type_cd)
     IF (cdf_meaning="5")
      IF ((request->products[i].productevents[j].disposition.change_ind=1))
       UPDATE  FROM disposition d
        SET d.product_event_id = request->products[i].productevents[j].product_event_id, d.product_id
          = request->products[i].product_id, d.reason_cd = request->products[i].productevents[j].
         disposition.reason_cd,
         d.disposed_qty = request->products[i].productevents[j].disposition.disposed_qty, d.updt_cnt
          = (d.updt_cnt+ 1), d.active_ind = request->products[i].productevents[j].disposition.
         active_ind,
         d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
         updt_task,
         d.updt_applctx = reqinfo->updt_applctx, d.active_status_cd =
         IF ((request->products[i].productevents[j].active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         , d.active_status_dt_tm =
         IF ((request->products[i].productevents[j].disposition.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE d.active_status_dt_tm
         ENDIF
         ,
         d.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].disposition.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE d.active_status_prsnl_id
         ENDIF
         , d.disposed_intl_units = request->products[i].productevents[j].disposition.
         disposed_intl_units
        WHERE (d.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (d.updt_cnt=request->products[i].productevents[j].disposition.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into disposition"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="2")
      IF ((request->products[i].productevents[j].quarantine.change_ind=1))
       UPDATE  FROM quarantine q
        SET q.product_event_id = request->products[i].productevents[j].product_event_id, q.product_id
          = request->products[i].product_id, q.quar_reason_cd = request->products[i].productevents[j]
         .quarantine.quar_reason_cd,
         q.updt_cnt = (q.updt_cnt+ 1), q.active_ind = request->products[i].productevents[j].
         quarantine.active_ind, q.orig_quar_qty = request->products[i].productevents[j].quarantine.
         orig_quar_qty,
         q.cur_quar_qty = request->products[i].productevents[j].quarantine.cur_quar_qty, q
         .orig_quar_intl_units = request->products[i].productevents[j].quarantine.
         orig_quar_intl_units, q.cur_quar_intl_units = request->products[i].productevents[j].
         quarantine.cur_quar_intl_units,
         q.updt_dt_tm = cnvtdatetime(sysdate), q.updt_id = reqinfo->updt_id, q.updt_task = reqinfo->
         updt_task,
         q.updt_applctx = reqinfo->updt_applctx, q.active_status_cd =
         IF ((request->products[i].productevents[j].quarantine.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         , q.active_status_dt_tm =
         IF ((request->products[i].productevents[j].quarantine.active_status_chg_ind=1)) cnvtdatetime
          (sysdate)
         ELSE q.active_status_dt_tm
         ENDIF
         ,
         q.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].quarantine.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE q.active_status_prsnl_id
         ENDIF
        WHERE (q.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (q.updt_cnt=request->products[i].productevents[j].quarantine.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into quarantine"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].quarantinerelease.add_ind=1))
       INSERT  FROM quarantine_release qr
        SET qr.product_event_id = request->products[i].productevents[j].product_event_id, qr
         .product_id = request->products[i].product_id, qr.quar_release_id = request->products[i].
         productevents[j].quarantinerelease.quar_release_id,
         qr.release_dt_tm = cnvtdatetime(request->products[i].productevents[j].quarantinerelease.
          release_dt_tm), qr.release_prsnl_id =
         IF ((request->products[i].productevents[j].quarantinerelease.release_prsnl_id > 0)) request
          ->products[i].productevents[j].quarantinerelease.release_prsnl_id
         ELSE reqinfo->updt_id
         ENDIF
         , qr.release_reason_cd = request->products[i].productevents[j].quarantinerelease.
         release_reason_cd,
         qr.release_qty = request->products[i].productevents[j].quarantinerelease.release_qty, qr
         .updt_cnt = 0, qr.active_ind = request->products[i].productevents[j].quarantinerelease.
         active_ind,
         qr.release_intl_units = request->products[i].productevents[j].quarantinerelease.
         release_intl_units, qr.updt_dt_tm = cnvtdatetime(sysdate), qr.updt_id = reqinfo->updt_id,
         qr.updt_task = reqinfo->updt_task, qr.updt_applctx = reqinfo->updt_applctx, qr
         .active_status_cd =
         IF ((request->products[i].productevents[j].quarantinerelease.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         qr.active_status_dt_tm = cnvtdatetime(sysdate), qr.active_status_prsnl_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "insert into quarantine_release"
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].quarantinerelease.change_ind=1))
       UPDATE  FROM quarantine_release qr
        SET qr.product_event_id = request->products[i].productevents[j].product_event_id, qr
         .product_id = request->products[i].product_id, qr.quar_release_id = request->products[i].
         productevents[j].quarantinerelease.quar_release_id,
         qr.release_dt_tm = cnvtdatetime(request->products[i].productevents[j].quarantinerelease.
          release_dt_tm), qr.release_prsnl_id =
         IF ((request->products[i].productevents[j].quarantinerelease.release_prsnl_id > 0)) request
          ->products[i].productevents[j].quarantinerelease.release_prsnl_id
         ELSE reqinfo->updt_id
         ENDIF
         , qr.release_reason_cd = request->products[i].productevents[j].quarantinerelease.
         release_reason_cd,
         qr.release_qty = request->products[i].productevents[j].quarantinerelease.release_qty, qr
         .updt_cnt = (qr.updt_cnt+ 1), qr.active_ind = request->products[i].productevents[j].
         quarantinerelease.active_ind,
         qr.release_intl_units = request->products[i].productevents[j].quarantinerelease.
         release_intl_units, qr.updt_dt_tm = cnvtdatetime(sysdate), qr.updt_id = reqinfo->updt_id,
         qr.updt_task = reqinfo->updt_task, qr.updt_applctx = reqinfo->updt_applctx, qr
         .active_status_cd =
         IF ((request->products[i].productevents[j].quarantinerelease.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         qr.active_status_dt_tm =
         IF ((request->products[i].productevents[j].quarantinerelease.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE qr.active_status_dt_tm
         ENDIF
         , qr.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].quarantinerelease.active_status_chg_ind=1))
          reqinfo->updt_id
         ELSE qr.active_status_prsnl_id
         ENDIF
        WHERE (qr.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (qr.updt_cnt=request->products[i].productevents[j].quarantinerelease.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into quarantine_release"
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (((cdf_meaning="10") OR (cdf_meaning="11")) )
      IF ((request->products[i].productevents[j].autodirected.change_ind=1))
       UPDATE  FROM auto_directed ad
        SET ad.product_event_id = request->products[i].productevents[j].product_event_id, ad
         .product_id = request->products[i].product_id, ad.person_id = request->products[i].
         productevents[j].autodirected.person_id,
         ad.associated_dt_tm = cnvtdatetime(request->products[i].productevents[j].autodirected.
          associated_dt_tm), ad.updt_cnt = (ad.updt_cnt+ 1), ad.active_ind = request->products[i].
         productevents[j].autodirected.active_ind,
         ad.encntr_id = request->products[i].productevents[j].autodirected.encntr_id, ad
         .expected_usage_dt_tm = cnvtdatetime(request->products[i].productevents[j].autodirected.
          expected_usage_dt_tm), ad.donated_by_relative_ind = request->products[i].productevents[j].
         autodirected.donated_by_relative_ind,
         ad.updt_dt_tm = cnvtdatetime(sysdate), ad.updt_id = reqinfo->updt_id, ad.updt_task = reqinfo
         ->updt_task,
         ad.updt_applctx = reqinfo->updt_applctx, ad.active_status_cd =
         IF ((request->products[i].productevents[j].autodirected.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         , ad.active_status_dt_tm =
         IF ((request->products[i].productevents[j].autodirected.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE ad.active_status_dt_tm
         ENDIF
         ,
         ad.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].autodirected.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE ad.active_status_prsnl_id
         ENDIF
        WHERE (ad.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (ad.updt_cnt=request->products[i].productevents[j].autodirected.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into auto_directed"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (((cdf_meaning="8") OR (cdf_meaning="17")) )
      IF ((request->products[i].productevents[j].modification.change_ind=1))
       UPDATE  FROM modification m
        SET m.product_event_id = request->products[i].productevents[j].product_event_id, m.product_id
          = request->products[i].product_id, m.orig_expire_dt_tm = cnvtdatetime(request->products[i].
          productevents[j].modification.orig_expire_dt_tm),
         m.orig_volume = request->products[i].productevents[j].modification.orig_volume, m
         .orig_unit_meas_cd = request->products[i].productevents[j].modification.orig_unit_meas_cd, m
         .cur_expire_dt_tm = cnvtdatetime(request->products[i].productevents[j].modification.
          cur_expire_dt_tm),
         m.cur_volume = request->products[i].productevents[j].modification.cur_volume, m
         .cur_unit_meas_cd = request->products[i].productevents[j].modification.cur_unit_meas_cd, m
         .modified_qty = request->products[i].productevents[j].modification.modified_qty,
         m.updt_cnt = (m.updt_cnt+ 1), m.active_ind = request->products[i].productevents[j].
         modification.active_ind, m.crossover_reason_cd = request->products[i].productevents[j].
         modification.crossover_reason_cd,
         m.option_id = request->products[i].productevents[j].modification.option_id, m.device_type_cd
          = request->products[i].productevents[j].modification.device_type_cd, m.start_dt_tm =
         cnvtdatetime(request->products[i].productevents[j].modification.start_dt_tm),
         m.stop_dt_tm = cnvtdatetime(request->products[i].productevents[j].modification.stop_dt_tm),
         m.lot_nbr = request->products[i].productevents[j].modification.lot_nbr, m.accessory =
         request->products[i].productevents[j].modification.accessory,
         m.vis_insp_cd = request->products[i].productevents[j].modification.vis_insp_cd, m.updt_dt_tm
          = cnvtdatetime(sysdate), m.updt_id = reqinfo->updt_id,
         m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->updt_applctx, m.active_status_cd
          =
         IF ((request->products[i].productevents[j].modification.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         m.active_status_dt_tm =
         IF ((request->products[i].productevents[j].modification.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE m.active_status_dt_tm
         ENDIF
         , m.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].modification.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE m.active_status_prsnl_id
         ENDIF
        WHERE (m.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (m.updt_cnt=request->products[i].productevents[j].modification.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into modification"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="1")
      IF ((request->products[i].productevents[j].assign.change_ind=1))
       UPDATE  FROM assign a
        SET a.product_event_id = request->products[i].productevents[j].product_event_id, a.product_id
          = request->products[i].product_id, a.assign_reason_cd = request->products[i].productevents[
         j].assign.assign_reason_cd,
         a.prov_id = request->products[i].productevents[j].assign.prov_id, a.person_id = request->
         products[i].productevents[j].assign.person_id, a.updt_cnt = (a.updt_cnt+ 1),
         a.active_ind = request->products[i].productevents[j].assign.active_ind, a.orig_assign_qty =
         request->products[i].productevents[j].assign.orig_assign_qty, a.cur_assign_qty = request->
         products[i].productevents[j].assign.cur_assign_qty,
         a.orig_assign_intl_units = request->products[i].productevents[j].assign.
         orig_assign_intl_units, a.cur_assign_intl_units = request->products[i].productevents[j].
         assign.cur_assign_intl_units, a.updt_dt_tm = cnvtdatetime(sysdate),
         a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
         updt_applctx,
         a.active_status_cd =
         IF ((request->products[i].productevents[j].assign.active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         , a.active_status_dt_tm =
         IF ((request->products[i].productevents[j].assign.active_status_chg_ind=1)) cnvtdatetime(
           sysdate)
         ELSE a.active_status_dt_tm
         ENDIF
         , a.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].assign.active_status_chg_ind=1)) reqinfo->updt_id
         ELSE a.active_status_prsnl_id
         ENDIF
         ,
         a.bb_id_nbr = request->products[i].productevents[j].assign.bb_id_nbr
        WHERE (a.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (a.updt_cnt=request->products[i].productevents[j].assign.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into assign"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].assignrelease.add_ind=1))
       INSERT  FROM assign_release ar
        SET ar.product_event_id = request->products[i].productevents[j].product_event_id, ar
         .assign_release_id = request->products[i].productevents[j].assignrelease.assign_release_id,
         ar.product_id = request->products[i].product_id,
         ar.release_dt_tm = cnvtdatetime(request->products[i].productevents[j].assignrelease.
          release_dt_tm), ar.release_prsnl_id =
         IF ((request->products[i].productevents[j].assignrelease.release_prsnl_id > 0)) request->
          products[i].productevents[j].assignrelease.release_prsnl_id
         ELSE reqinfo->updt_id
         ENDIF
         , ar.release_reason_cd = request->products[i].productevents[j].assignrelease.
         release_reason_cd,
         ar.release_qty = request->products[i].productevents[j].assignrelease.release_qty, ar
         .updt_cnt = 0, ar.active_ind = request->products[i].productevents[j].assignrelease.
         active_ind,
         ar.release_intl_units = request->products[i].productevents[j].assignrelease.
         release_intl_units, ar.updt_dt_tm = cnvtdatetime(sysdate), ar.updt_id = reqinfo->updt_id,
         ar.updt_task = reqinfo->updt_task, ar.updt_applctx = reqinfo->updt_applctx, ar
         .active_status_cd =
         IF ((request->products[i].productevents[j].assignrelease.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         ar.active_status_dt_tm = cnvtdatetime(sysdate), ar.active_status_prsnl_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "insert into assign_release"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].assignrelease.change_ind=1))
       UPDATE  FROM assign_release ar
        SET ar.product_event_id = request->products[i].productevents[j].product_event_id, ar
         .assign_release_id = request->products[i].productevents[j].assignrelease.assign_release_id,
         ar.product_id = request->products[i].product_id,
         ar.release_dt_tm = cnvtdatetime(request->products[i].productevents[j].assignrelease.
          release_dt_tm), ar.release_prsnl_id =
         IF ((request->products[i].productevents[j].assignrelease.release_prsnl_id > 0)) request->
          products[i].productevents[j].assignrelease.release_prsnl_id
         ELSE reqinfo->updt_id
         ENDIF
         , ar.release_reason_cd = request->products[i].productevents[j].assignrelease.
         release_reason_cd,
         ar.release_qty = request->products[i].productevents[j].assignrelease.release_qty, ar
         .updt_cnt = (ar.updt_cnt+ 1), ar.active_ind = request->products[i].productevents[j].
         assignrelease.active_ind,
         ar.release_intl_units = request->products[i].productevents[j].assignrelease.
         release_intl_units, ar.updt_dt_tm = cnvtdatetime(sysdate), ar.updt_id = reqinfo->updt_id,
         ar.updt_task = reqinfo->updt_task, ar.updt_applctx = reqinfo->updt_applctx, ar
         .active_status_cd =
         IF ((request->products[i].productevents[j].assignrelease.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         ar.active_status_dt_tm =
         IF ((request->products[i].productevents[j].assignrelease.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE ar.active_status_dt_tm
         ENDIF
         , ar.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].assignrelease.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE ar.active_status_prsnl_id
         ENDIF
        WHERE (ar.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (ar.updt_cnt=request->products[i].productevents[j].assignrelease.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into assign_release"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="7")
      IF ((request->products[i].productevents[j].transfusion.change_ind=1))
       UPDATE  FROM transfusion t
        SET t.product_event_id = request->products[i].productevents[j].product_event_id, t.product_id
          = request->products[i].product_id, t.person_id = request->products[i].productevents[j].
         transfusion.person_id,
         t.transfused_intl_units = request->products[i].productevents[j].transfusion.
         transfused_intl_units, t.bag_returned_ind = request->products[i].productevents[j].
         transfusion.bag_returned_ind, t.tag_returned_ind = request->products[i].productevents[j].
         transfusion.tag_returned_ind,
         t.transfused_vol = request->products[i].productevents[j].transfusion.transfused_vol, t
         .updt_cnt = (t.updt_cnt+ 1), t.active_ind = request->products[i].productevents[j].
         transfusion.active_ind,
         t.orig_transfused_qty = request->products[i].productevents[j].transfusion.
         orig_transfused_qty, t.cur_transfused_qty = request->products[i].productevents[j].
         transfusion.cur_transfused_qty, t.updt_dt_tm = cnvtdatetime(sysdate),
         t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
         updt_applctx,
         t.active_status_cd =
         IF ((request->products[i].productevents[j].transfusion.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         , t.active_status_dt_tm =
         IF ((request->products[i].productevents[j].transfusion.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE t.active_status_dt_tm
         ENDIF
         , t.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].transfusion.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE t.active_status_prsnl_id
         ENDIF
        WHERE (t.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (t.updt_cnt=request->products[i].productevents[j].transfusion.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into transfusion"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="14")
      IF ((request->products[i].productevents[j].destruction.change_ind=1))
       UPDATE  FROM destruction d
        SET d.product_event_id = request->products[i].productevents[j].product_event_id, d.product_id
          = request->products[i].product_id, d.method_cd = request->products[i].productevents[j].
         destruction.method_cd,
         d.box_nbr = request->products[i].productevents[j].destruction.box_nbr, d.manifest_nbr =
         request->products[i].productevents[j].destruction.manifest_nbr, d.destroyed_qty = request->
         products[i].productevents[j].destruction.destroyed_qty,
         d.autoclave_ind = request->products[i].productevents[j].destruction.autoclave_ind, d
         .destruction_org_id = request->products[i].productevents[j].destruction.destruction_org_id,
         d.updt_cnt = (d.updt_cnt+ 1),
         d.active_ind = request->products[i].productevents[j].destruction.active_ind, d.updt_dt_tm =
         cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id,
         d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.active_status_cd
          =
         IF ((request->products[i].productevents[j].destruction.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         d.active_status_dt_tm =
         IF ((request->products[i].productevents[j].destruction.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE d.active_status_dt_tm
         ENDIF
         , d.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].destruction.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE d.active_status_prsnl_id
         ENDIF
        WHERE (d.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (d.updt_cnt=request->products[i].productevents[j].destruction.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into destruction"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="12")
      IF ((request->products[i].productevents[j].abotesting.change_ind=1))
       UPDATE  FROM abo_testing at
        SET at.product_event_id = request->products[i].productevents[j].product_event_id, at
         .product_id = request->products[i].product_id, at.abo_testing_id = request->products[i].
         productevents[j].abotesting.abo_testing_id,
         at.result_id = request->products[i].productevents[j].abotesting.result_id, at.abo_group_cd
          = request->products[i].productevents[j].abotesting.abo_group_cd, at.rh_type_cd = request->
         products[i].productevents[j].abotesting.rh_type_cd,
         at.current_updated_ind = request->products[i].productevents[j].abotesting.
         current_updated_ind, at.updt_cnt = (at.updt_cnt+ 1), at.active_ind = request->products[i].
         productevents[j].abotesting.active_ind,
         at.updt_dt_tm = cnvtdatetime(sysdate), at.updt_id = reqinfo->updt_id, at.updt_task = reqinfo
         ->updt_task,
         at.updt_applctx = reqinfo->updt_applctx, at.active_status_cd =
         IF ((request->products[i].productevents[j].abotesting.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         , at.active_status_dt_tm =
         IF ((request->products[i].productevents[j].abotesting.active_status_chg_ind=1)) cnvtdatetime
          (sysdate)
         ELSE at.active_status_dt_tm
         ENDIF
         ,
         at.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].abotesting.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE at.active_status_prsnl_id
         ENDIF
        WHERE (at.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (at.updt_cnt=request->products[i].productevents[j].abotesting.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into abo_testing"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="6")
      IF ((request->products[i].productevents[j].transfer.change_ind=1))
       UPDATE  FROM transfer t
        SET t.product_event_id = request->products[i].productevents[j].product_event_id, t.product_id
          = request->products[i].product_id, t.transferring_locn_cd = request->products[i].
         productevents[j].transfer.transferring_locn_cd,
         t.transfer_cond_cd = request->products[i].productevents[j].transfer.transfer_cond_cd, t
         .transfer_reason_cd = request->products[i].productevents[j].transfer.transfer_reason_cd, t
         .transfer_vis_insp_cd = request->products[i].productevents[j].transfer.transfer_vis_insp_cd,
         t.transfer_qty = request->products[i].productevents[j].transfer.transfer_qty, t.login_dt_tm
          = cnvtdatetime(request->products[i].productevents[j].transfer.login_dt_tm), t
         .login_prsnl_id = request->products[i].productevents[j].transfer.login_prsnl_id,
         t.login_cond_cd = request->products[i].productevents[j].transfer.login_cond_cd, t
         .login_vis_insp_cd = request->products[i].productevents[j].transfer.login_vis_insp_cd, t
         .login_qty = request->products[i].productevents[j].transfer.login_qty,
         t.return_dt_tm = cnvtdatetime(request->products[i].productevents[j].transfer.return_dt_tm),
         t.return_prsnl_id = request->products[i].productevents[j].transfer.return_prsnl_id, t
         .return_reason_cd = request->products[i].productevents[j].transfer.return_reason_cd,
         t.return_cond_cd = request->products[i].productevents[j].transfer.return_cond_cd, t
         .return_vis_insp_cd = request->products[i].productevents[j].transfer.return_vis_insp_cd, t
         .return_qty = request->products[i].productevents[j].transfer.return_qty,
         t.updt_cnt = 0, t.active_ind = request->products[i].productevents[j].transfer.active_ind, t
         .updt_dt_tm = cnvtdatetime(sysdate),
         t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
         updt_applctx,
         t.active_status_cd =
         IF ((request->products[i].productevents[j].transfer.active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         , t.active_status_dt_tm =
         IF ((request->products[i].productevents[j].transfer.active_status_chg_ind=1)) cnvtdatetime(
           sysdate)
         ELSE t.active_status_dt_tm
         ENDIF
         , t.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].transfer.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE t.active_status_prsnl_id
         ENDIF
        WHERE (t.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (t.updt_cnt=request->products[i].productevents[j].transfer.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into transfer"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].bbdevicetransfer.change_ind=1))
       UPDATE  FROM bb_device_transfer bd
        SET bd.product_event_id = request->products[i].productevents[j].product_event_id, bd
         .product_id = request->products[i].product_id, bd.from_device_id = request->products[i].
         productevents[j].bbdevicetransfer.from_device_id,
         bd.to_device_id = request->products[i].productevents[j].bbdevicetransfer.to_device_id, bd
         .reason_cd = request->products[i].productevents[j].bbdevicetransfer.reason_cd, bd.updt_cnt
          = (bd.updt_cnt+ 1),
         bd.updt_dt_tm = cnvtdatetime(sysdate), bd.updt_id = reqinfo->updt_id, bd.updt_task = reqinfo
         ->updt_task,
         bd.updt_applctx = reqinfo->updt_applctx
        WHERE (bd.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (bd.updt_cnt=request->products[i].productevents[j].bbdevicetransfer.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into bbdevice_transfer"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].bbinventorytransfer.change_ind=1))
       UPDATE  FROM bb_inventory_transfer bit
        SET bit.from_owner_area_cd = request->products[i].productevents[j].bbinventorytransfer.
         from_owner_area_cd, bit.from_inv_area_cd = request->products[i].productevents[j].
         bbinventorytransfer.from_inv_area_cd, bit.transfer_reason_cd = request->products[i].
         productevents[j].bbinventorytransfer.transfer_reason_cd,
         bit.to_owner_area_cd = request->products[i].productevents[j].bbinventorytransfer.
         to_owner_area_cd, bit.to_inv_area_cd = request->products[i].productevents[j].
         bbinventorytransfer.to_inv_area_cd, bit.transferred_qty = request->products[i].
         productevents[j].bbinventorytransfer.transferred_qty,
         bit.transferred_intl_unit = request->products[i].productevents[j].bbinventorytransfer.
         transferred_iu, bit.to_product_event_id = request->products[i].productevents[j].
         related_product_event_id, bit.event_type_cd = request->products[i].productevents[j].
         bbinventorytransfer.event_type_cd,
         bit.updt_cnt = (bit.updt_cnt+ 1), bit.updt_dt_tm = cnvtdatetime(sysdate), bit.updt_id =
         reqinfo->updt_id,
         bit.updt_task = reqinfo->updt_task, bit.updt_applctx = reqinfo->updt_applctx
        WHERE (bit.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (bit.updt_cnt=request->products[i].productevents[j].bbinventorytransfer.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname =
        "update into bb_inventory_transfer"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="3")
      IF ((request->products[i].productevents[j].crossmatch.change_ind=1))
       UPDATE  FROM crossmatch c
        SET c.product_event_id = request->products[i].productevents[j].product_event_id, c.product_id
          = request->products[i].product_id, c.crossmatch_qty = request->products[i].productevents[j]
         .crossmatch.crossmatch_qty,
         c.release_dt_tm = cnvtdatetime(request->products[i].productevents[j].crossmatch.
          release_dt_tm), c.release_prsnl_id =
         IF ((request->products[i].productevents[j].crossmatch.release_prsnl_id > 0)) request->
          products[i].productevents[j].crossmatch.release_prsnl_id
         ELSE reqinfo->updt_id
         ENDIF
         , c.release_reason_cd = request->products[i].productevents[j].crossmatch.release_reason_cd,
         c.release_qty = request->products[i].productevents[j].crossmatch.release_qty, c.updt_cnt = (
         c.updt_cnt+ 1), c.active_ind = request->products[i].productevents[j].crossmatch.active_ind,
         c.crossmatch_exp_dt_tm = cnvtdatetime(request->products[i].productevents[j].crossmatch.
          crossmatch_exp_dt_tm), c.reinstate_reason_cd = request->products[i].productevents[j].
         crossmatch.reinstate_reason_cd, c.bb_id_nbr = request->products[i].productevents[j].
         crossmatch.bb_id_nbr,
         c.xm_reason_cd = request->products[i].productevents[j].crossmatch.xm_reason_cd, c.updt_dt_tm
          = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id,
         c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.active_status_cd
          =
         IF ((request->products[i].productevents[j].crossmatch.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         c.active_status_dt_tm =
         IF ((request->products[i].productevents[j].crossmatch.active_status_chg_ind=1)) cnvtdatetime
          (sysdate)
         ELSE c.active_status_dt_tm
         ENDIF
         , c.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].crossmatch.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE c.active_status_prsnl_id
         ENDIF
         , c.person_id = request->products[i].productevents[j].crossmatch.person_id
        WHERE (c.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (c.updt_cnt=request->products[i].productevents[j].crossmatch.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into crossmatch"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="4")
      IF ((request->products[i].productevents[j].patientdispense.change_ind=1))
       UPDATE  FROM patient_dispense pd
        SET pd.product_event_id = request->products[i].productevents[j].product_event_id, pd
         .product_id = request->products[i].product_id, pd.person_id = request->products[i].
         productevents[j].patientdispense.person_id,
         pd.dispense_prov_id = request->products[i].productevents[j].patientdispense.dispense_prov_id,
         pd.dispense_reason_cd = request->products[i].productevents[j].patientdispense.
         dispense_reason_cd, pd.dispense_to_locn_cd = request->products[i].productevents[j].
         patientdispense.dispense_to_locn_cd,
         pd.dispense_from_locn_cd = request->products[i].productevents[j].patientdispense.
         dispense_from_locn_cd, pd.device_id = request->products[i].productevents[j].patientdispense.
         device_id, pd.dispense_vis_insp_cd = request->products[i].productevents[j].patientdispense.
         dispense_vis_insp_cd,
         pd.dispense_cooler_id = request->products[i].productevents[j].patientdispense.
         dispense_cooler_id, pd.dispense_cooler_text = request->products[i].productevents[j].
         patientdispense.dispense_cooler_text, pd.dispense_courier_id = request->products[i].
         productevents[j].patientdispense.dispense_courier_id,
         pd.dispense_status_flag = request->products[i].productevents[j].patientdispense.
         dispense_status_flag, pd.orig_dispense_intl_units = request->products[i].productevents[j].
         patientdispense.orig_dispense_intl_units, pd.cur_dispense_intl_units = request->products[i].
         productevents[j].patientdispense.cur_dispense_intl_units,
         pd.orig_dispense_qty = request->products[i].productevents[j].patientdispense.
         orig_dispense_qty, pd.cur_dispense_qty = request->products[i].productevents[j].
         patientdispense.cur_dispense_qty, pd.unknown_patient_ind = request->products[i].
         productevents[j].patientdispense.unknown_patient_ind,
         pd.unknown_patient_text = request->products[i].productevents[j].patientdispense.
         unknown_patient_text, pd.updt_cnt = (pd.updt_cnt+ 1), pd.active_ind = request->products[i].
         productevents[j].patientdispense.active_ind,
         pd.dispense_courier_text = request->products[i].productevents[j].patientdispense.
         dispense_courier_text, pd.updt_dt_tm = cnvtdatetime(sysdate), pd.updt_id = reqinfo->updt_id,
         pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo->updt_applctx, pd
         .active_status_cd =
         IF ((request->products[i].productevents[j].patientdispense.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         pd.active_status_dt_tm =
         IF ((request->products[i].productevents[j].patientdispense.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE pd.active_status_dt_tm
         ENDIF
         , pd.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].patientdispense.active_status_chg_ind=1)) reqinfo
          ->updt_id
         ELSE pd.active_status_prsnl_id
         ENDIF
         , pd.bb_id_nbr = request->products[i].productevents[j].patientdispense.bb_id_nbr
        WHERE (pd.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (pd.updt_cnt=request->products[i].productevents[j].patientdispense.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into patient_dispense"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].dispensereturn.add_ind=1))
       INSERT  FROM dispense_return dr
        SET dr.product_event_id = request->products[i].productevents[j].product_event_id, dr
         .product_id = request->products[i].product_id, dr.dispense_return_id = request->products[i].
         productevents[j].dispensereturn.dispense_return_id,
         dr.return_dt_tm = cnvtdatetime(request->products[i].productevents[j].dispensereturn.
          return_dt_tm), dr.return_prsnl_id = request->products[i].productevents[j].dispensereturn.
         return_prsnl_id, dr.return_reason_cd = request->products[i].productevents[j].dispensereturn.
         return_reason_cd,
         dr.return_vis_insp_cd = request->products[i].productevents[j].dispensereturn.
         return_vis_insp_cd, dr.return_courier_id = request->products[i].productevents[j].
         dispensereturn.return_courier_id, dr.return_qty = request->products[i].productevents[j].
         dispensereturn.return_qty,
         dr.return_intl_units = request->products[i].productevents[j].dispensereturn.
         return_intl_units, dr.updt_cnt = 0, dr.active_ind = request->products[i].productevents[j].
         dispensereturn.active_ind,
         dr.return_courier_text = request->products[i].productevents[j].dispensereturn.
         return_courier_text, dr.updt_dt_tm = cnvtdatetime(sysdate), dr.updt_id = reqinfo->updt_id,
         dr.updt_task = reqinfo->updt_task, dr.updt_applctx = reqinfo->updt_applctx, dr
         .active_status_cd =
         IF ((request->products[i].productevents[j].dispensereturn.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         dr.active_status_dt_tm = cnvtdatetime(sysdate), dr.active_status_prsnl_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "insert into dispense_return"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((request->products[i].productevents[j].dispensereturn.change_ind=1))
       UPDATE  FROM dispense_return dr
        SET dr.product_event_id = request->products[i].productevents[j].product_event_id, dr
         .product_id = request->products[i].product_id, dr.dispense_return_id = request->products[i].
         productevents[j].dispensereturn.dispense_return_id,
         dr.return_dt_tm = cnvtdatetime(request->products[i].productevents[j].dispensereturn.
          return_dt_tm), dr.return_prsnl_id = request->products[i].productevents[j].dispensereturn.
         return_prsnl_id, dr.return_reason_cd = request->products[i].productevents[j].dispensereturn.
         return_reason_cd,
         dr.return_vis_insp_cd = request->products[i].productevents[j].dispensereturn.
         return_vis_insp_cd, dr.return_courier_id = request->products[i].productevents[j].
         dispensereturn.return_courier_id, dr.return_qty = request->products[i].productevents[j].
         dispensereturn.return_qty,
         dr.return_intl_units = request->products[i].productevents[j].dispensereturn.
         return_intl_units, dr.updt_cnt = (dr.updt_cnt+ 1), dr.active_ind = request->products[i].
         productevents[j].dispensereturn.active_ind,
         dr.return_courier_text = request->products[i].productevents[j].dispensereturn.
         return_courier_text, dr.updt_dt_tm = cnvtdatetime(sysdate), dr.updt_id = reqinfo->updt_id,
         dr.updt_task = reqinfo->updt_task, dr.updt_applctx = reqinfo->updt_applctx, dr
         .active_status_cd =
         IF ((request->products[i].productevents[j].dispensereturn.active_ind=1)) reqdata->
          active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         dr.active_status_dt_tm =
         IF ((request->products[i].productevents[j].dispensereturn.active_status_chg_ind=1))
          cnvtdatetime(sysdate)
         ELSE dr.active_status_dt_tm
         ENDIF
         , dr.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].dispensereturn.active_status_chg_ind=1)) reqinfo
          ->updt_id
         ELSE dr.active_status_prsnl_id
         ENDIF
        WHERE (dr.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (dr.updt_cnt=request->products[i].productevents[j].dispensereturn.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into dispense_return"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (cdf_meaning="13")
      IF ((request->products[i].productevents[j].receipt.change_ind=1))
       UPDATE  FROM receipt r
        SET r.product_event_id = request->products[i].productevents[j].product_event_id, r.product_id
          = request->products[i].product_id, r.active_ind = request->products[i].productevents[j].
         receipt.active_ind,
         r.ship_cond_cd = request->products[i].productevents[j].receipt.ship_cond_cd, r.vis_insp_cd
          = request->products[i].productevents[j].receipt.vis_insp_cd, r.orig_rcvd_qty = request->
         products[i].productevents[j].receipt.orig_rcvd_qty,
         r.orig_intl_units = request->products[i].productevents[j].receipt.orig_intl_units, r
         .updt_cnt = (r.updt_cnt+ 1), r.bb_supplier_id = request->products[i].productevents[j].
         receipt.bb_supplier_id,
         r.alpha_translation_id = request->products[i].productevents[j].receipt.alpha_translation_id,
         r.temperature_value = request->products[i].productevents[j].receipt.temperature_value, r
         .temperature_degree_cd = request->products[i].productevents[j].receipt.temperature_degree_cd,
         r.electronic_receipt_ind = request->products[i].productevents[j].receipt.
         electronic_receipt_ind, r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id,
         r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.active_status_cd
          =
         IF ((request->products[i].productevents[j].receipt.active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         r.active_status_dt_tm =
         IF ((request->products[i].productevents[j].receipt.active_status_chg_ind=1)) cnvtdatetime(
           sysdate)
         ELSE r.active_status_dt_tm
         ENDIF
         , r.active_status_prsnl_id =
         IF ((request->products[i].productevents[j].receipt.active_status_chg_ind=1)) reqinfo->
          updt_id
         ELSE r.active_status_prsnl_id
         ENDIF
        WHERE (r.product_event_id=request->products[i].productevents[j].product_event_id)
         AND (r.updt_cnt=request->products[i].productevents[j].receipt.updt_cnt)
        WITH nocounter
       ;end update
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "update into receipt"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 IF ((((request->add_exists_ind=1)
  AND (request->pe_add_cnt > 0)) OR ((request->chg_exists_ind=1)
  AND (request->pe_chg_cnt > 0))) )
  FOR (i = 1 TO size(request->products,5))
    FOR (j = 1 TO size(request->products[i].productevents,5))
      IF (size(request->products[i].productevents[j].bbexceptions,5) > 0)
       FOR (k = 1 TO size(request->products[i].productevents[j].bbexceptions,5))
         SET bb_exception_id = 0.0
         SELECT INTO "nl:"
          seqn = seq(pathnet_seq,nextval)
          FROM dual
          DETAIL
           bb_exception_id = seqn
          WITH format, nocounter
         ;end select
         INSERT  FROM bb_exception b
          SET b.exception_id = bb_exception_id, b.product_event_id = request->products[i].
           productevents[j].product_event_id, b.exception_type_cd = request->products[i].
           productevents[j].bbexceptions[k].exception_type_cd,
           b.event_type_cd = request->products[i].productevents[j].event_type_cd, b.from_abo_cd = 0.0,
           b.from_rh_cd = 0.0,
           b.to_abo_cd = 0.0, b.to_rh_cd = 0.0, b.override_reason_cd = request->products[i].
           productevents[j].bbexceptions[k].override_reason_cd,
           b.result_id = 0.0, b.perform_result_id = 0.0, b.updt_cnt = 0,
           b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
           ->updt_task,
           b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1, b.active_status_cd = reqdata->
           active_status_cd,
           b.active_status_dt_tm = cnvtdatetime(sysdate), b.active_status_prsnl_id = reqinfo->updt_id,
           b.donor_contact_id = 0.0,
           b.donor_contact_type_cd = 0.0, b.order_id = 0.0, b.exception_prsnl_id = reqinfo->updt_id,
           b.exception_dt_tm = cnvtdatetime(sysdate), b.person_id = 0.0, b.default_expire_dt_tm =
           cnvtdatetime(request->products[i].productevents[j].bbexceptions[k].default_expire_dt_tm)
          WITH counter
         ;end insert
         SET serror_check = error(serrormsg,0)
         IF (serror_check != 0)
          SET reply->status_data.status = "F"
          SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
          SET reply->status_data.subeventstatus[1].operationstatus = "F"
          SET reply->status_data.subeventstatus[1].targetobjectname = "insert into bb_exception"
          SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
          GO TO exit_script
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 FOR (i = 1 TO size(request->products,5))
   IF (validate(request->products[i].bb_edn_id,0.0) > 0.0)
    IF (updateedncomplete(request->products[i].bb_edn_id,request->products[i].bb_edn_product_id,
     request->products[i].product_id,request->products[i].edn_complete_ind)=1)
     SET serror_check = error(serrormsg,0)
     IF (serror_check != 0)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
     ELSE
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "UpdateEDNComplete function returned failed status."
     ENDIF
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "bb_act_acd_product.prg"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "UpdateEDNComplete"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET stat = alterlist(reply->dup_product,dup_cnt)
 SET stat = alterlist(reply->conflicting_aborh,con_cnt)
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSEIF (failures="Z")
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Duplicates Exist"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
