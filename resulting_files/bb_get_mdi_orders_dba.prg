CREATE PROGRAM bb_get_mdi_orders:dba
 RECORD reply(
   1 order_list[*]
     2 order_type_flag = i4
     2 order_id = f8
     2 bb_processing_cd = f8
     2 accession = c20
     2 assay_list[*]
       3 task_assay_cd = f8
     2 product_list[*]
       3 product_number = vc
       3 product_id = f8
       3 assay_list[*]
         4 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD alpha_translations(
   1 alpha_trans_list[*]
     2 alpha_barcode = vc
     2 alpha_trans = vc
 )
 DECLARE lpatient_order_type = i4 WITH protected, constant(0)
 DECLARE lproduct_order_type = i4 WITH protected, constant(1)
 DECLARE lpatient_product_order_type = i4 WITH protected, constant(2)
 DECLARE estatusok = i2 WITH protected, constant(0)
 DECLARE escripterror = i2 WITH protected, constant(1)
 DECLARE enoordersfound = i2 WITH protected, constant(2)
 DECLARE eduplicateorderserror = i2 WITH protected, constant(3)
 DECLARE eduplicateproductserror = i2 WITH protected, constant(4)
 DECLARE enoreturn = i2 WITH protected, constant(5)
 DECLARE lorder_status_cs = i4 WITH protected, constant(6004)
 DECLARE scancelled_status_cdf = c12 WITH protected, constant("CANCELED")
 DECLARE sdeleted_status_cdf = c12 WITH protected, constant("DELETED")
 DECLARE sdiscontinued_status_cdf = c12 WITH protected, constant("DISCONTINUED")
 DECLARE scompleted_status_cdf = c9 WITH protected, constant("COMPLETED")
 DECLARE lresult_status_cs = i4 WITH protected, constant(1901)
 DECLARE spending_status_cdf = c12 WITH protected, constant("PENDING")
 DECLARE lresource_grp_type_cs = i4 WITH protected, constant(223)
 DECLARE ssubsection_grp_type = c12 WITH protected, constant("SUBSECTION")
 DECLARE sinstrument_grp_type = c12 WITH protected, constant("INSTRUMENT")
 DECLARE lbb_processing_type_cs = i4 WITH protected, constant(1635)
 DECLARE scrossmatch_ord_type = c12 WITH protected, constant("XM")
 DECLARE sabid_ord_type = c12 WITH protected, constant("ANTIBODY ID")
 DECLARE sagtype_ord_type = c12 WITH protected, constant("ANTIGEN")
 DECLARE dcancelstatuscd = f8 WITH protected, noconstant(0.0)
 DECLARE ddeletedstatuscd = f8 WITH protected, noconstant(0.0)
 DECLARE ddiscontinuedstatuscd = f8 WITH protected, noconstant(0.0)
 DECLARE dpendingstatuscd = f8 WITH protected, noconstant(0.0)
 DECLARE dcompletedstatuscd = f8 WITH protected, noconstant(0.0)
 DECLARE dsubsectiontypecd = f8 WITH protected, noconstant(0.0)
 DECLARE dcrossmatchordertypecd = f8 WITH protected, noconstant(0.0)
 DECLARE dabidordertypecd = f8 WITH protected, noconstant(0.0)
 DECLARE dagtypeordertypecd = f8 WITH protected, noconstant(0.0)
 DECLARE saccession = vc WITH protected, noconstant("")
 DECLARE nscriptstatus = i2 WITH protected, noconstant(estatusok)
 DECLARE nstat = i2 WITH protected, noconstant(0)
 DECLARE findaccession() = i2 WITH protected
 DECLARE findproduct() = i2 WITH protected
 DECLARE handlemultipleorders() = i2 WITH protected
 DECLARE findnonuniqueorders() = i2 WITH protected
 DECLARE findpendingorders() = i2 WITH protected
 DECLARE getproductinfo() = i2 WITH protected
 DECLARE populatereply() = i2 WITH protected
 DECLARE populatealphatrans() = i2 WITH protected
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
 SET log_program_name = curprog
 CALL log_message("Starting Script",log_level_debug)
 SET reply->status_data.status = "F"
#begin_script
 RECORD orders(
   1 orders[*]
     2 order_type_flag = i4
     2 order_id = f8
     2 order_status_cd = f8
     2 bb_processing_cd = f8
     2 accession = c20
     2 catalog_cd = f8
     2 product_id = f8
     2 product_number = vc
     2 pending_ind = i2
     2 non_unique_seq = i2
     2 assays[*]
       3 task_assay_cd = f8
     2 products[*]
       3 product_id = f8
       3 product_number = vc
       3 untranslated_ind = i2
 )
 SET dcancelstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(scancelled_status_cdf))
 SET ddeletedstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(sdeleted_status_cdf))
 SET ddiscontinuedstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
   sdiscontinued_status_cdf))
 SET dpendingstatuscd = uar_get_code_by("MEANING",lresult_status_cs,nullterm(spending_status_cdf))
 SET dcompletedstatuscd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(scompleted_status_cdf))
 SET dsubsectiontypecd = uar_get_code_by("MEANING",lresource_grp_type_cs,nullterm(
   ssubsection_grp_type))
 SET dcrossmatchordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(
   scrossmatch_ord_type))
 SET dabidordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(sabid_ord_type))
 SET dagtypeordertypecd = uar_get_code_by("MEANING",lbb_processing_type_cs,nullterm(sagtype_ord_type)
  )
 IF (((dsubsectiontypecd <= 0.0) OR (((dcancelstatuscd <= 0.0) OR (((ddeletedstatuscd <= 0.0) OR (((
 ddiscontinuedstatuscd <= 0.0) OR (((dpendingstatuscd <= 0.0) OR (((dcrossmatchordertypecd <= 0.0)
  OR (dcompletedstatuscd <= 0.0)) )) )) )) )) )) )
  SET nscriptstatus = escripterror
  CALL populate_subeventstatus_msg("VALIDATE","F","UAR",build(
    "At least one required code value not found : ",dsubsectiontypecd,",",dcrossmatchordertypecd,",",
    dcancelstatuscd,",",ddeletedstatuscd,",",ddiscontinuedstatuscd,
    ",",dpendingstatuscd,",",dcompletedstatuscd),log_level_audit)
  GO TO exit_script
 ENDIF
 SET nscriptstatus = populatealphatrans(null)
 IF (nscriptstatus=escripterror)
  GO TO exit_script
 ENDIF
 SET nscriptstatus = findproduct(null)
 IF (nscriptstatus != estatusok)
  IF (((nscriptstatus=escripterror) OR (nscriptstatus=eduplicateproductserror)) )
   GO TO exit_script
  ELSEIF (nscriptstatus=enoordersfound)
   EXECUTE accrtl
   SET saccession = uar_accrebuildtruncated(nullterm(trim(request->identifier)),0)
   SET nscriptstatus = findaccession(null)
   IF (nscriptstatus != estatusok)
    IF (nscriptstatus=escripterror)
     GO TO exit_script
    ELSEIF (nscriptstatus=enoordersfound)
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (size(orders->orders,5) > 1)
  SET nscriptstatus = handlemultipleorders(null)
  IF (nscriptstatus != estatusok)
   GO TO exit_script
  ENDIF
 ENDIF
 SET nscriptstatus = getproductinfo(null)
 IF (nscriptstatus != estatusok)
  GO TO exit_script
 ENDIF
 SET nscriptstatus = populatereply(null)
 SUBROUTINE findaccession(null)
   CALL log_message("Begin FindAccession",log_level_debug)
   SELECT INTO "nl:"
    sserviceresourcemean = uar_get_code_meaning(orl.service_resource_cd), table_ind = decode(ptr.seq,
     "ptr",op.seq,"op","xxx"), dtaskassaycd = decode(ptr.seq,ptr.task_assay_cd,pg.seq,pg
     .task_assay_cd,0.0)
    FROM accession_order_r aor,
     orders o,
     orc_resource_list orl,
     order_serv_res_container osrc,
     resource_group rgp,
     resource_group rgc,
     service_directory sd,
     profile_task_r ptr,
     bb_order_phase op,
     phase_group pg,
     dummyt d1,
     dummyt d2
    PLAN (aor
     WHERE aor.accession=trim(saccession)
      AND aor.primary_flag=0)
     JOIN (o
     WHERE o.order_id=aor.order_id
      AND  NOT (((o.order_status_cd+ 0) IN (dcancelstatuscd, ddeletedstatuscd, ddiscontinuedstatuscd)
     )))
     JOIN (orl
     WHERE orl.catalog_cd=o.catalog_cd
      AND (orl.service_resource_cd=request->service_resource_cd)
      AND orl.active_ind=1)
     JOIN (osrc
     WHERE osrc.order_id=o.order_id
      AND ((osrc.status_flag+ 0) IN (1, 2)))
     JOIN (rgp
     WHERE (rgp.child_service_resource_cd=request->service_resource_cd)
      AND rgp.resource_group_type_cd=dsubsectiontypecd
      AND rgp.active_ind=1)
     JOIN (rgc
     WHERE rgc.parent_service_resource_cd=rgp.parent_service_resource_cd
      AND rgc.child_service_resource_cd=osrc.service_resource_cd
      AND rgc.resource_group_type_cd=dsubsectiontypecd
      AND rgc.active_ind=1)
     JOIN (sd
     WHERE sd.catalog_cd=o.catalog_cd)
     JOIN (((d1)
     JOIN (ptr
     WHERE ptr.catalog_cd=sd.catalog_cd
      AND ptr.active_ind=1)
     ) ORJOIN ((d2)
     JOIN (op
     WHERE op.order_id=o.order_id)
     JOIN (pg
     WHERE pg.phase_group_cd=op.phase_grp_cd
      AND pg.active_ind=1)
     ))
    ORDER BY o.order_id, table_ind, dtaskassaycd
    HEAD REPORT
     nordercnt = 0, nassaycnt = 0
    HEAD o.order_id
     IF (sserviceresourcemean=sinstrument_grp_type)
      nordercnt += 1
      IF (nordercnt > size(orders->orders,5))
       nstat = alterlist(orders->orders,(nordercnt+ 5))
      ENDIF
      orders->orders[nordercnt].order_id = o.order_id, orders->orders[nordercnt].order_status_cd = o
      .order_status_cd, orders->orders[nordercnt].bb_processing_cd = sd.bb_processing_cd,
      orders->orders[nordercnt].accession = aor.accession
      IF (sd.bb_processing_cd=dcrossmatchordertypecd)
       orders->orders[nordercnt].order_type_flag = lpatient_product_order_type
      ELSE
       orders->orders[nordercnt].order_type_flag = lpatient_order_type
      ENDIF
      orders->orders[nordercnt].pending_ind = 1, orders->orders[nordercnt].catalog_cd = o.catalog_cd,
      nassaycnt = 0
     ENDIF
    HEAD table_ind
     row + 0
    HEAD dtaskassaycd
     IF (table_ind="ptr")
      IF (sserviceresourcemean=sinstrument_grp_type)
       nassaycnt += 1
       IF (nassaycnt > size(orders->orders[nordercnt].assays,5))
        nstat = alterlist(orders->orders[nordercnt].assays,(nassaycnt+ 5))
       ENDIF
       orders->orders[nordercnt].assays[nassaycnt].task_assay_cd = ptr.task_assay_cd
      ENDIF
     ELSEIF (table_ind="op")
      IF (sserviceresourcemean=sinstrument_grp_type)
       nassaycnt += 1
       IF (nassaycnt > size(orders->orders[nordercnt].assays,5))
        nstat = alterlist(orders->orders[nordercnt].assays,(nassaycnt+ 5))
       ENDIF
       orders->orders[nordercnt].assays[nassaycnt].task_assay_cd = pg.task_assay_cd
      ENDIF
     ENDIF
    FOOT  table_ind
     row + 0
    FOOT  dtaskassaycd
     row + 0
    FOOT  o.order_id
     IF (sserviceresourcemean=sinstrument_grp_type)
      nstat = alterlist(orders->orders[nordercnt].assays,nassaycnt)
     ENDIF
    FOOT REPORT
     nstat = alterlist(orders->orders,nordercnt)
    WITH nocounter
   ;end select
   SET nstat = error_message(1)
   IF (nstat != estatusok)
    CALL log_message("End FindAccession - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ENDIF
   IF (curqual=0)
    CALL populate_subeventstatus_msg("LOAD","F","ORDERS",build("No orders found for accession : ",
      saccession,", Service Resource : ",request->service_resource_cd),log_level_audit)
    RETURN(enoordersfound)
   ELSE
    CALL log_message("End FindAccession - Return eStatusOK",log_level_debug)
    RETURN(estatusok)
   ENDIF
 END ;Subroutine
 SUBROUTINE findproduct(null)
   CALL log_message("Begin FindProduct",log_level_debug)
   DECLARE nalphacnt = i2 WITH protect, constant(size(alpha_translations->alpha_trans_list,5))
   DECLARE nprodnbrsize = i2 WITH protect, noconstant(0)
   DECLARE stranslation = vc WITH protect, noconstant("")
   DECLARE sbarcode = vc WITH protect, noconstant("")
   DECLARE stranslatednbr = vc WITH protect, noconstant("")
   DECLARE nfound = i2 WITH protect, noconstant(0)
   DECLARE i = i2 WITH protect, noconstant(0)
   DECLARE nprodcnt = i2 WITH protect, noconstant(0)
   SET stranslatedproductnbr = ""
   SET nprodnbrsize = size(trim(request->identifier))
   IF (nprodnbrsize < 13)
    SET i = 1
    WHILE (nfound=0
     AND i <= nalphacnt)
      SET stranslation = alpha_translations->alpha_trans_list[i].alpha_trans
      SET sbarcode = alpha_translations->alpha_trans_list[i].alpha_barcode
      IF (findstring(sbarcode,request->identifier,1,0)=1)
       SET nfound = 1
       SET stranslatednbr = build(stranslation,substring(3,nprodnbrsize,request->identifier))
      ENDIF
      SET i += 1
    ENDWHILE
   ENDIF
   SELECT INTO "nl:"
    FROM product p,
     orders o,
     service_directory sd,
     profile_task_r ptr
    PLAN (p
     WHERE p.product_nbr IN (trim(request->identifier), trim(stranslatednbr))
      AND p.product_nbr != "")
     JOIN (o
     WHERE o.product_id=p.product_id
      AND  NOT (((o.order_status_cd+ 0) IN (dcancelstatuscd, ddeletedstatuscd, ddiscontinuedstatuscd,
     dcompletedstatuscd))))
     JOIN (sd
     WHERE sd.catalog_cd=o.catalog_cd)
     JOIN (ptr
     WHERE ptr.catalog_cd=o.catalog_cd
      AND ptr.active_ind=1)
    ORDER BY p.product_id, o.order_id, ptr.task_assay_cd
    HEAD REPORT
     nordercnt = 0, nassaycnt = 0, nprodcnt = 0
    HEAD p.product_id
     nprodcnt += 1
    HEAD o.order_id
     nordercnt += 1
     IF (nordercnt > size(orders->orders,5))
      nstat = alterlist(orders->orders,(nordercnt+ 5))
     ENDIF
     orders->orders[nordercnt].order_id = o.order_id, orders->orders[nordercnt].order_status_cd = o
     .order_status_cd, orders->orders[nordercnt].bb_processing_cd = sd.bb_processing_cd,
     orders->orders[nordercnt].product_id = p.product_id, orders->orders[nordercnt].product_number =
     request->identifier, orders->orders[nordercnt].order_type_flag = lproduct_order_type,
     orders->orders[nordercnt].catalog_cd = o.catalog_cd, orders->orders[nordercnt].pending_ind = 1,
     nassaycnt = 0
    HEAD ptr.task_assay_cd
     nassaycnt += 1
     IF (nassaycnt > size(orders->orders[nordercnt].assays,5))
      nstat = alterlist(orders->orders[nordercnt].assays,(nassaycnt+ 5))
     ENDIF
     orders->orders[nordercnt].assays[nassaycnt].task_assay_cd = ptr.task_assay_cd
    FOOT  ptr.task_assay_cd
     row + 0
    FOOT  o.order_id
     nstat = alterlist(orders->orders[nordercnt].assays,nassaycnt)
    FOOT  p.product_id
     row + 0
    FOOT REPORT
     nstat = alterlist(orders->orders,nordercnt)
    WITH nocounter
   ;end select
   SET nstat = error_message(1)
   IF (nstat != estatusok)
    CALL log_message("End FindProduct - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ENDIF
   IF (curqual=0)
    CALL log_message("End FindProduct - Return eNoOrdersFound",log_level_debug)
    RETURN(enoordersfound)
   ELSEIF (nprodcnt > 1)
    CALL log_message("End FindProduct - Return eDuplicateProductsError",log_level_debug)
    RETURN(eduplicateproductserror)
   ELSE
    CALL log_message("End FindProduct - Return eStatusOK",log_level_debug)
    RETURN(estatusok)
   ENDIF
 END ;Subroutine
 SUBROUTINE handlemultipleorders(null)
   CALL log_message("Begin HandleMultipleOrders",log_level_debug)
   DECLARE nnonuniqueordersfound = i2 WITH private, noconstant(0)
   DECLARE nstatus = i2 WITH private, noconstant(estatusok)
   SET nstatus = findnonuniquephasedcellorders(null)
   IF (nstatus=escripterror)
    CALL log_message("End HandleMultipleOrders - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ENDIF
   SET nstatus = findnonuniqueorders(null)
   IF (nstatus=enoordersfound)
    CALL log_message("End HandleMultipleOrders - Return eStatusOK",log_level_debug)
    RETURN(estatusok)
   ELSE
    IF (nstatus=escripterror)
     CALL log_message("End HandleMultipleOrders - Return eScriptError",log_level_debug)
     RETURN(escripterror)
    ELSE
     SET nstatus = findpendingorders(null)
     IF (nstatus=eduplicateorderserror)
      CALL log_message("End HandleMultipleOrders - Return eDuplicateOrdersError",log_level_debug)
      RETURN(eduplicateorderserror)
     ELSE
      CALL log_message("End HandleMultipleOrders - Return eStatusOK",log_level_debug)
      RETURN(estatusok)
     ENDIF
    ENDIF
   ENDIF
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE findnonuniqueorders(null)
   CALL log_message("Begin FindNonUniqueOrders",log_level_debug)
   DECLARE lorderidx = i4 WITH private, noconstant(0)
   DECLARE lorderidx2 = i4 WITH private, noconstant(0)
   DECLARE lassayidx = i4 WITH private, noconstant(0)
   DECLARE lordercnt = i4 WITH private, noconstant(size(orders->orders,5))
   DECLARE lnonuniquecnt = i4 WITH private, noconstant(0)
   DECLARE lfoundcnt = i4 WITH private, noconstant(0)
   DECLARE lassaycnt1 = i4 WITH private, noconstant(0)
   DECLARE lassaycnt2 = i4 WITH private, noconstant(0)
   DECLARE lindex = i4 WITH private, noconstant(0)
   FOR (lorderidx = 1 TO lordercnt)
     IF ((orders->orders[lorderidx].pending_ind=1)
      AND (orders->orders[lorderidx].non_unique_seq=0)
      AND  NOT ((orders->orders[lorderidx].bb_processing_cd IN (dabidordertypecd, dagtypeordertypecd)
     )))
      FOR (lorderidx2 = 1 TO lordercnt)
        IF ((orders->orders[lorderidx2].pending_ind=1)
         AND (orders->orders[lorderidx2].order_id != orders->orders[lorderidx].order_id)
         AND (orders->orders[lorderidx2].non_unique_seq=0)
         AND  NOT ((orders->orders[lorderidx2].bb_processing_cd IN (dabidordertypecd,
        dagtypeordertypecd))))
         IF (size(orders->orders[lorderidx].assays,5)=size(orders->orders[lorderidx2].assays,5))
          SET lfoundcnt = 0
          SET lassaycnt1 = size(orders->orders[lorderidx].assays,5)
          SET lassaycnt2 = size(orders->orders[lorderidx2].assays,5)
          FOR (lassayidx = 1 TO lassaycnt1)
            IF (locateval(lindex,1,lassaycnt2,orders->orders[lorderidx].assays[lassayidx].
             task_assay_cd,orders->orders[lorderidx2].assays[lindex].task_assay_cd) > 0)
             SET lfoundcnt += 1
            ENDIF
          ENDFOR
          IF (lfoundcnt=size(orders->orders[lorderidx].assays,5))
           SET lnonuniquecnt += 1
           SET orders->orders[lorderidx].non_unique_seq = lorderidx
           SET orders->orders[lorderidx2].non_unique_seq = lorderidx
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (lnonuniquecnt > 0)
    CALL log_message("End FindNonUniqueOrders - Return eStatusOK",log_level_debug)
    RETURN(estatusok)
   ELSE
    CALL log_message("End FindNonUniqueOrders - Return eNoOrdersFound",log_level_debug)
    RETURN(enoordersfound)
   ENDIF
 END ;Subroutine
 SUBROUTINE findpendingorders(null)
   CALL log_message("Begin FindPendingOrders",log_level_debug)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(orders->orders,5))),
     result r,
     profile_task_r ptr
    PLAN (d
     WHERE (orders->orders[d.seq].non_unique_seq > 0)
      AND (orders->orders[d.seq].pending_ind=1)
      AND  NOT ((orders->orders[d.seq].bb_processing_cd IN (dabidordertypecd, dagtypeordertypecd))))
     JOIN (r
     WHERE (r.order_id=orders->orders[d.seq].order_id))
     JOIN (ptr
     WHERE ptr.task_assay_cd=r.task_assay_cd
      AND (ptr.catalog_cd=orders->orders[d.seq].catalog_cd))
    DETAIL
     IF (r.result_status_cd != dpendingstatuscd
      AND ptr.item_type_flag != 1)
      orders->orders[d.seq].pending_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   SET nstat = error_message(1)
   IF (nstat != estatusok)
    CALL log_message("End FindPendingOrders - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ENDIF
   SELECT INTO "nl:"
    non_unique_seq = orders->orders[d.seq].non_unique_seq
    FROM (dummyt d  WITH seq = value(size(orders->orders,5)))
    PLAN (d
     WHERE (orders->orders[d.seq].pending_ind=1)
      AND (orders->orders[d.seq].non_unique_seq > 0)
      AND  NOT ((orders->orders[d.seq].bb_processing_cd IN (dabidordertypecd, dagtypeordertypecd))))
    ORDER BY non_unique_seq
    HEAD non_unique_seq
     nfirstorderind = 1
    DETAIL
     IF (nfirstorderind=0)
      orders->orders[d.seq].pending_ind = 0
     ELSE
      nfirstorderind = 0
     ENDIF
    WITH nocounter
   ;end select
   SET nstat = error_message(1)
   IF (nstat != estatusok)
    CALL log_message("End FindPendingOrders - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ENDIF
   IF (curqual=0)
    CALL log_message("End FindPendingOrders - Return eDuplicateOrdersError",log_level_debug)
    RETURN(eduplicateorderserror)
   ELSE
    CALL log_message("End FindPendingOrders - Return eStatusOK",log_level_debug)
    RETURN(estatusok)
   ENDIF
 END ;Subroutine
 SUBROUTINE getproductinfo(null)
   CALL log_message("Begin GetProductInfo",log_level_debug)
   DECLARE suntranslatedproduct = vc WITH protect, noconstant("")
   DECLARE nalphacnt = i2 WITH protect, constant(size(alpha_translations->alpha_trans_list,5))
   DECLARE nprodnbrsize = i2 WITH protect, noconstant(0)
   DECLARE stranslation = vc WITH protect, noconstant("")
   DECLARE sbarcode = vc WITH protect, noconstant("")
   DECLARE ntranssize = i2 WITH protect, noconstant(0)
   DECLARE nprodcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    pe.product_id, order_id = orders->orders[d.seq].order_id
    FROM (dummyt d  WITH seq = value(size(orders->orders,5))),
     product_event pe,
     product p,
     bb_supplier bbs
    PLAN (d
     WHERE (orders->orders[d.seq].order_type_flag=lpatient_product_order_type)
      AND (orders->orders[d.seq].pending_ind=1))
     JOIN (pe
     WHERE (pe.order_id=orders->orders[d.seq].order_id)
      AND pe.active_ind=1)
     JOIN (p
     WHERE p.product_id=pe.product_id)
     JOIN (bbs
     WHERE (bbs.organization_id= Outerjoin(p.cur_supplier_id))
      AND (bbs.active_ind= Outerjoin(1)) )
    ORDER BY order_id
    HEAD REPORT
     nproductcnt = 0
    HEAD order_id
     nproductcnt = 0
    DETAIL
     nproductcnt += 1
     IF (nproductcnt > size(orders->orders[d.seq].products,5))
      nstat = alterlist(orders->orders[d.seq].products,(nproductcnt+ 5))
     ENDIF
     orders->orders[d.seq].products[nproductcnt].product_id = p.product_id, orders->orders[d.seq].
     products[nproductcnt].product_number = p.product_nbr, orders->orders[d.seq].products[nproductcnt
     ].untranslated_ind = 0,
     suntranslatedproduct = trim(p.product_nbr), nprodnbrsize = size(suntranslatedproduct)
     IF (bbs.alpha_translation_ind=1
      AND nprodnbrsize < 13)
      FOR (i = 1 TO nalphacnt)
        stranslation = alpha_translations->alpha_trans_list[i].alpha_trans, sbarcode =
        alpha_translations->alpha_trans_list[i].alpha_barcode, ntranssize = size(trim(stranslation))
        IF (findstring(stranslation,suntranslatedproduct,1,0)=1)
         suntranslatedproduct = build(sbarcode,substring((ntranssize+ 1),nprodnbrsize,
           suntranslatedproduct)), nproductcnt += 1
         IF (nproductcnt > size(orders->orders[d.seq].products,5))
          nstat = alterlist(orders->orders[d.seq].products,(nproductcnt+ 5))
         ENDIF
         orders->orders[d.seq].products[nproductcnt].product_id = p.product_id, orders->orders[d.seq]
         .products[nproductcnt].product_number = suntranslatedproduct, orders->orders[d.seq].
         products[nproductcnt].untranslated_ind = 1,
         suntranslatedproduct = trim(p.product_nbr)
        ENDIF
      ENDFOR
     ENDIF
    FOOT  order_id
     nstat = alterlist(orders->orders[d.seq].products,nproductcnt)
    WITH nocounter
   ;end select
   SET nstat = error_message(1)
   IF (nstat != estatusok)
    CALL log_message("End GetProductInfo - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ENDIF
   FOR (i = 1 TO size(orders->orders,5))
     IF ((orders->orders[i].order_type_flag=lpatient_product_order_type)
      AND (orders->orders[i].pending_ind=1))
      SELECT INTO "nl:"
       p.product_nbr
       FROM (dummyt d  WITH seq = value(size(orders->orders[i].products,5))),
        product p
       PLAN (d
        WHERE (orders->orders[i].products[d.seq].untranslated_ind=1))
        JOIN (p
        WHERE (p.product_nbr=orders->orders[i].products[d.seq].product_number))
       DETAIL
        nprodcnt += 1
       WITH nocounter
      ;end select
      IF (nprodcnt > 0)
       CALL log_message("End GetProductInfo - Return eDuplicateProductsError",log_level_debug)
       RETURN(eduplicateproductserror)
      ENDIF
     ENDIF
   ENDFOR
   CALL log_message("End GetProductInfo - Return eStatusOK",log_level_debug)
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE populatereply(null)
   CALL log_message("Begin PopulateReply",log_level_debug)
   DECLARE lorderidx = i4 WITH private, noconstant(0)
   DECLARE lassayidx = i4 WITH private, noconstant(0)
   DECLARE lproductidx = i4 WITH private, noconstant(0)
   DECLARE nordercount = i2 WITH private, noconstant(0)
   FOR (lorderidx = 1 TO size(orders->orders,5))
     IF ((orders->orders[lorderidx].pending_ind=1)
      AND (((orders->orders[lorderidx].order_type_flag != lpatient_product_order_type)) OR ((orders->
     orders[lorderidx].order_type_flag=lpatient_product_order_type)
      AND size(orders->orders[lorderidx].products,5) > 0)) )
      SET nordercount += 1
      IF (nordercount > size(reply->order_list,5))
       SET nstat = alterlist(reply->order_list,(nordercount+ 5))
      ENDIF
      SET reply->order_list[nordercount].order_id = orders->orders[lorderidx].order_id
      SET reply->order_list[nordercount].bb_processing_cd = orders->orders[lorderidx].
      bb_processing_cd
      SET reply->order_list[nordercount].accession = orders->orders[lorderidx].accession
      SET reply->order_list[nordercount].order_type_flag = orders->orders[lorderidx].order_type_flag
      IF ((reply->order_list[nordercount].order_type_flag=lpatient_order_type))
       SET nstat = alterlist(reply->order_list[nordercount].assay_list,size(orders->orders[lorderidx]
         .assays,5))
       FOR (lassayidx = 1 TO size(orders->orders[lorderidx].assays,5))
         SET reply->order_list[nordercount].assay_list[lassayidx].task_assay_cd = orders->orders[
         lorderidx].assays[lassayidx].task_assay_cd
       ENDFOR
      ELSEIF ((reply->order_list[nordercount].order_type_flag=lproduct_order_type))
       SET nstat = alterlist(reply->order_list[nordercount].product_list,1)
       SET nstat = alterlist(reply->order_list[nordercount].product_list[1].assay_list,size(orders->
         orders[lorderidx].assays,5))
       SET reply->order_list[nordercount].product_list[1].product_id = orders->orders[lorderidx].
       product_id
       SET reply->order_list[nordercount].product_list[1].product_number = orders->orders[lorderidx].
       product_number
       FOR (lassayidx = 1 TO size(orders->orders[lorderidx].assays,5))
         SET reply->order_list[nordercount].product_list[1].assay_list[lassayidx].task_assay_cd =
         orders->orders[lorderidx].assays[lassayidx].task_assay_cd
       ENDFOR
      ELSEIF ((reply->order_list[nordercount].order_type_flag=lpatient_product_order_type))
       SET nstat = alterlist(reply->order_list[nordercount].product_list,size(orders->orders[
         lorderidx].products,5))
       FOR (lproductidx = 1 TO size(orders->orders[lorderidx].products,5))
         SET reply->order_list[nordercount].product_list[lproductidx].product_id = orders->orders[
         lorderidx].products[lproductidx].product_id
         SET reply->order_list[nordercount].product_list[lproductidx].product_number = orders->
         orders[lorderidx].products[lproductidx].product_number
         SET nstat = alterlist(reply->order_list[nordercount].product_list[lproductidx].assay_list,
          size(orders->orders[lorderidx].assays,5))
         FOR (lassayidx = 1 TO size(orders->orders[lorderidx].assays,5))
           SET reply->order_list[nordercount].product_list[lproductidx].assay_list[lassayidx].
           task_assay_cd = orders->orders[lorderidx].assays[lassayidx].task_assay_cd
         ENDFOR
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   SET nstat = alterlist(reply->order_list,nordercount)
   IF (nordercount=0)
    CALL log_message("End PopulateReply - Return eNoOrdersFound",log_level_debug)
    RETURN(enoordersfound)
   ELSE
    CALL log_message("End PopulateReply - Return eStatusOK",log_level_debug)
    RETURN(estatusok)
   ENDIF
 END ;Subroutine
 SUBROUTINE populatealphatrans(null)
   CALL log_message("Begin PopulateAlphaTrans",log_level_debug)
   DECLARE ntranscnt = i2 WITH private, noconstant(0)
   SELECT INTO "nl:"
    bat.alpha_barcode_value, bat.alpha_translation_value
    FROM bb_alpha_translation bat
    PLAN (bat
     WHERE bat.alpha_translation_id > 0
      AND bat.active_ind=1)
    HEAD REPORT
     ntranscnt = 0, nstat = alterlist(alpha_translations->alpha_trans_list,(ntranscnt+ 10))
    DETAIL
     ntranscnt += 1
     IF (ntranscnt > size(reply->order_list,5))
      nstat = alterlist(alpha_translations->alpha_trans_list,(ntranscnt+ 10))
     ENDIF
     alpha_translations->alpha_trans_list[ntranscnt].alpha_barcode = bat.alpha_barcode_value,
     alpha_translations->alpha_trans_list[ntranscnt].alpha_trans = cnvtupper(trim(bat
       .alpha_translation_value))
    FOOT REPORT
     nstat = alterlist(alpha_translations->alpha_trans_list,ntranscnt)
    WITH nocounter
   ;end select
   SET nstat = error_message(1)
   IF (nstat != estatusok)
    CALL log_message("End PopulateAlphaTrans - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ENDIF
   CALL log_message("End PopulateAlphaTrans - Return eStatusOK",log_level_debug)
   RETURN(estatusok)
 END ;Subroutine
 SUBROUTINE findnonuniquephasedcellorders(null)
   CALL log_message("Begin FindNonUniquePhasedCellOrders",log_level_debug)
   SELECT INTO "nl:"
    bb_processing_cd = orders->orders[d.seq].bb_processing_cd, order_id = orders->orders[d.seq].
    order_id, r.result_id
    FROM (dummyt d  WITH seq = value(size(orders->orders,5))),
     result r
    PLAN (d
     WHERE (orders->orders[d.seq].bb_processing_cd IN (dabidordertypecd, dagtypeordertypecd))
      AND (orders->orders[d.seq].pending_ind=1))
     JOIN (r
     WHERE (r.order_id=orders->orders[d.seq].order_id))
    ORDER BY bb_processing_cd, orders->orders[d.seq].order_id, r.result_id
    HEAD bb_processing_cd
     nresultassociated = 0, nfirstidx = 0
    HEAD order_id
     IF (nfirstidx=0
      AND (orders->orders[d.seq].order_status_cd != dcompletedstatuscd))
      nfirstidx = d.seq
     ENDIF
     orders->orders[d.seq].pending_ind = 0
    HEAD r.result_id
     IF ((orders->orders[d.seq].order_status_cd != dcompletedstatuscd)
      AND r.result_id > 0
      AND nresultassociated=0)
      orders->orders[d.seq].pending_ind = 1, nresultassociated = 1
     ENDIF
    FOOT  bb_processing_cd
     IF (nresultassociated=0)
      orders->orders[nfirstidx].pending_ind = 1
     ENDIF
    WITH nocounter, outerjoin = d
   ;end select
   SET nstat = error_message(1)
   IF (nstat != estatusok)
    CALL log_message("End FindNonUniquePhasedCellOrders - Return eScriptError",log_level_debug)
    RETURN(escripterror)
   ELSE
    CALL log_message("End FindNonUniquePhasedCellOrders - Return eStatusOK",log_level_debug)
    RETURN(estatusok)
   ENDIF
 END ;Subroutine
#exit_script
 IF (nscriptstatus=estatusok)
  SET reply->status_data.status = "S"
 ELSEIF (nscriptstatus=escripterror)
  SET reply->status_data.status = "F"
 ELSEIF (nscriptstatus=enoordersfound)
  SET reply->status_data.status = "Z"
 ELSEIF (nscriptstatus=eduplicateorderserror)
  SET reply->status_data.status = "O"
 ELSEIF (nscriptstatus=eduplicateproductserror)
  SET reply->status_data.status = "D"
 ENDIF
 FREE SET orders
 CALL uar_sysdestroyhandle(hsys)
 CALL log_message("Ending Script",log_level_debug)
END GO
