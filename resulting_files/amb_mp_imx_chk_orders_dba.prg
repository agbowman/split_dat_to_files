CREATE PROGRAM amb_mp_imx_chk_orders:dba
 PROMPT
  "person_id" = 0,
  "Facility CD" = 0.0
  WITH person_id, facility_cd
 DECLARE PUBLIC::gatherorders(null) = null WITH protect, copy
 DECLARE PUBLIC::removehiddenbedrockorders(null) = null WITH protect, copy
 DECLARE PUBLIC::removenonvirtualviewedbedrockorders(null) = null WITH protect, copy
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "AMB_MP_IMX_CHK_ORDERS"
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE cancel_order_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE delete_order_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE canceled_order_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE 6000_charge = f8 WITH constant(uar_get_code_by("MEANING",6000,"CHARGES"))
 DECLARE 6011_primary = f8 WITH constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE 13019_billcode = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3516"))
 DECLARE gseq = i2 WITH noconstant(0)
 DECLARE ocnt = i2 WITH noconstant(0)
 DECLARE grppos = i2 WITH noconstant(0)
 DECLARE foundpos = i2 WITH noconstant(0)
 DECLARE grpcnt = i2 WITH noconstant(0)
 DECLARE fcnt = i2 WITH noconstant(0)
 DECLARE pr_pos = f8
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 EXECUTE cclaudit 0, "PreventiveServices", "QueryInterMedx",
 "Person", "Patient", "Patient",
 "Access / Use",  $PERSON_ID, ""
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id=reqinfo->updt_id))
  DETAIL
   pr_pos = pr.position_cd
  WITH nocounter
 ;end select
 IF (validate(request->blob_in))
  IF ((request->blob_in > " "))
   CALL log_message("Begin CnvtJSONRec",log_level_debug)
   DECLARE cnvtbeg_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SET request->blob_in = replace(request->blob_in,'"CATALOG_CD":0,','"CATALOG_CD":0.0,')
   DECLARE jrec = i4
   SET jrec = cnvtjsontorec(trim(request->blob_in))
   IF (validate(brec))
    IF (validate(brec->edata))
     SET brec->status = "S"
     IF (validate(brec->grp)
      AND validate(brec->grp_cnt))
      SET grpcnt = brec->grp_cnt
      SET stat = alterlist(brec->grp,grpcnt)
      SET stat = alterlist(brec->grp,(grpcnt - 1),0)
     ENDIF
     CALL removehiddenbedrockorders(null)
     CALL removenonvirtualviewedbedrockorders(null)
     CALL gatherorders(null)
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE PUBLIC::removehiddenbedrockorders(null)
  CALL log_message("In removeHiddenBedrockOrders()",log_level_debug)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = size(brec->grp,5)),
    (dummyt d2  WITH seq = 1),
    order_catalog_synonym ocs
   PLAN (d1
    WHERE maxrec(d2,size(brec->grp[d1.seq].orderlist,5)))
    JOIN (d2)
    JOIN (ocs
    WHERE (ocs.catalog_cd=brec->grp[d1.seq].orderlist[d2.seq].catalog_cd)
     AND ocs.mnemonic_type_cd=6011_primary
     AND ocs.hide_flag=1)
   DETAIL
    brec->grp[d1.seq].orderlist[d2.seq].catalog_cd = 0
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::removenonvirtualviewedbedrockorders(null)
  CALL log_message("In removeNonVirtualViewedBedrockOrders()",log_level_debug)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = size(brec->grp,5)),
    (dummyt d2  WITH seq = 1),
    order_catalog_synonym ocs,
    (left JOIN ocs_facility_r ofr ON ofr.synonym_id=ocs.synonym_id
     AND ofr.facility_cd IN ( $FACILITY_CD, 0.0))
   PLAN (d1
    WHERE maxrec(d2,size(brec->grp[d1.seq].orderlist,5)))
    JOIN (d2)
    JOIN (ocs
    WHERE (ocs.catalog_cd=brec->grp[d1.seq].orderlist[d2.seq].catalog_cd)
     AND ocs.mnemonic_type_cd=6011_primary)
    JOIN (ofr)
   DETAIL
    IF (ofr.synonym_id=0)
     brec->grp[d1.seq].orderlist[d2.seq].catalog_cd = 0
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::gatherorders(null)
   CALL log_message("In gatherOrderDetails()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    ord_date =
    IF (o.order_id=0
     AND c.charge_item_id > 0) c.service_dt_tm
    ELSE o.orig_order_dt_tm
    ENDIF
    FROM (dummyt d1  WITH seq = size(brec->edata,5)),
     (dummyt d2  WITH seq = 1),
     bill_item_modifier bim,
     bill_item bi,
     (left JOIN charge c ON (c.person_id= $PERSON_ID)
      AND bi.bill_item_id=c.bill_item_id
      AND c.offset_charge_item_id=0
      AND c.beg_effective_dt_tm BETWEEN cnvtlookbehind("6,M") AND cnvtdatetime(sysdate)
      AND c.active_ind=1),
     (left JOIN prsnl pr2 ON pr2.person_id=c.verify_phys_id),
     (left JOIN order_catalog oc ON oc.catalog_cd=bi.ext_parent_reference_id
      AND oc.active_ind=1),
     (left JOIN order_catalog_synonym ocs ON ocs.catalog_cd=oc.catalog_cd
      AND ocs.mnemonic_type_cd=6011_primary
      AND ocs.active_ind=1
      AND ocs.hide_flag != 1),
     (left JOIN ocs_facility_r ofr ON ofr.synonym_id=ocs.synonym_id
      AND ofr.facility_cd IN ( $FACILITY_CD, 0.0)),
     (left JOIN orders o ON (o.person_id= $PERSON_ID)
      AND o.catalog_cd=oc.catalog_cd
      AND o.orig_order_dt_tm BETWEEN cnvtlookbehind("6,M") AND cnvtdatetime(sysdate)
      AND o.active_ind=1
      AND  NOT (o.order_status_cd IN (cancel_order_cd, delete_order_cd, canceled_order_cd))),
     (left JOIN order_action oa ON oa.order_id=o.order_id
      AND oa.action_sequence=1),
     (left JOIN prsnl pr ON pr.person_id=oa.order_provider_id)
    PLAN (d1
     WHERE maxrec(d2,size(brec->edata[d1.seq].groupcodes,5)))
     JOIN (d2
     WHERE d2.seq > 0)
     JOIN (bim
     WHERE bim.key1_id IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=14002
       AND cdf_meaning IN ("HCPCS", "CPT4")))
      AND bim.key6=trim(brec->edata[d1.seq].groupcodes[d2.seq].code)
      AND bim.bill_item_type_cd=13019_billcode
      AND ((bim.active_ind=1) OR (bim.active_status_dt_tm > cnvtlookbehind("6,M"))) )
     JOIN (bi
     WHERE bi.bill_item_id=bim.bill_item_id
      AND ((bi.active_ind=1) OR (bi.active_status_dt_tm > cnvtlookbehind("6,M")))
      AND bi.ext_child_reference_id=0)
     JOIN (c)
     JOIN (pr2)
     JOIN (oc)
     JOIN (ocs)
     JOIN (ofr)
     JOIN (o)
     JOIN (oa)
     JOIN (pr)
    ORDER BY d1.seq, d2.seq, oc.catalog_cd,
     ord_date, o.order_id, c.charge_item_id DESC
    HEAD oc.catalog_cd
     IF (oc.catalog_cd > 0
      AND ofr.synonym_id > 0)
      foundpos = 0, ocnt = 0, grppos = brec->edata[d1.seq].grouperid,
      ocnt = size(brec->grp[grppos].orderlist,5)
      IF (ocnt != 0)
       foundpos = locateval(gseq,1,ocnt,oc.catalog_cd,cnvtreal(brec->grp[grppos].orderlist[gseq].
         catalog_cd))
      ENDIF
      IF (foundpos=0)
       ocnt += 1, stat = alterlist(brec->grp[grppos].orderlist,ocnt), brec->grp[grppos].orderlist[
       ocnt].catalog_cd = oc.catalog_cd
      ENDIF
     ENDIF
    HEAD o.order_id
     IF (o.order_id > 0)
      fcnt = size(brec->grp[grppos].foundlist,5), fcnt += 1, stat = alterlist(brec->grp[grppos].
       foundlist,fcnt),
      brec->grp[grppos].foundlist[fcnt].catalog_cd = o.catalog_cd, brec->grp[grppos].foundlist[fcnt].
      display = trim(o.ordered_as_mnemonic), brec->grp[grppos].foundlist[fcnt].ord_date_utc = build(
       replace(datetimezoneformat(cnvtdatetime(o.orig_order_dt_tm),datetimezonebyname("UTC"),
         "yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
      IF (pr.person_id > 0)
       brec->grp[grppos].foundlist[fcnt].order_prov = trim(pr.name_full_formatted)
      ELSE
       brec->grp[grppos].foundlist[fcnt].order_prov = "--"
      ENDIF
     ENDIF
    HEAD c.charge_item_id
     IF (o.order_id=0
      AND c.charge_item_id > 0)
      fcnt = size(brec->grp[grppos].foundlist,5), fcnt += 1, stat = alterlist(brec->grp[grppos].
       foundlist,fcnt),
      brec->grp[grppos].foundlist[fcnt].catalog_cd = c.charge_item_id, brec->grp[grppos].foundlist[
      fcnt].display = trim(c.charge_description,3), brec->grp[grppos].foundlist[fcnt].ord_date_utc =
      build(replace(datetimezoneformat(cnvtdatetime(c.service_dt_tm),datetimezonebyname("UTC"),
         "yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
      IF (pr2.person_id > 0)
       brec->grp[grppos].foundlist[fcnt].order_prov = trim(pr2.name_full_formatted)
      ELSE
       brec->grp[grppos].foundlist[fcnt].order_prov = "--"
      ENDIF
     ENDIF
    DETAIL
     IF (((o.order_id > 0) OR (c.charge_item_id > 0)) )
      elig_date = cnvtdatetime(cnvtdate2(brec->edata[d1.seq].groupcodes[d2.seq].eligibilitydate,
        "YYYYMMDD"),0)
      IF (elig_date < current_date_time)
       brec->edata[d1.seq].millfoundind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message(build("Exit  gatherOrderDetails(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 SET _memory_reply_string = cnvtrectojson(brec)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
