CREATE PROGRAM cr_get_ap_cpt_codes
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
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
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
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
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
 SET log_program_name = "CR_GET_AP_CPT_CODES"
 FREE RECORD reply
 RECORD reply(
   1 tier_qual[*]
     2 tier_group_label = vc
     2 cpt_qual[*]
       3 cpt_code = vc
       3 cpt_desc = vc
       3 tag_disp = c7
       3 specimen_desc = vc
       3 charge_item_id = f8
       3 modifier_qual[*]
         4 modifier_code = vc
     2 unattached_cpt_qual[*]
       3 cpt_code = vc
       3 cpt_desc = vc
       3 charge_item_id = f8
       3 modifier_qual[*]
         4 modifier_code = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE no_error = i2 WITH protect, constant(1)
 DECLARE ccl_error = i2 WITH protect, constant(2)
 DECLARE no_qual = i2 WITH protect, constant(3)
 DECLARE tier_cnt = i4 WITH protect, constant(size(request->tier_qual,5))
 DECLARE lselectresult = i4 WITH protect, noconstant(1)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE debit_type_cd = f8 WITH constant(uar_get_code_by("MEANING",13028,"DR")), protect
 FREE RECORD modifier
 RECORD modifier(
   1 mod_qual[*]
     2 charge_item_id = f8
     2 modifier_code = vc
 )
 SELECT INTO "nl:"
  tier_order = request->tier_qual[d1.seq].tier_order
  FROM charge_event ce,
   charge c,
   charge_mod cm,
   code_value cv,
   processing_task pt,
   case_specimen cs,
   ap_tag at,
   (dummyt d1  WITH seq = value(tier_cnt))
  PLAN (ce
   WHERE (ce.accession=request->accession_nbr)
    AND ce.active_ind=1)
   JOIN (c
   WHERE c.charge_event_id=ce.charge_event_id
    AND  NOT (((c.process_flg+ 0) IN (6, 10)))
    AND c.active_ind=1
    AND c.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100")
    AND c.charge_type_cd=debit_type_cd
    AND c.offset_charge_item_id=0)
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.active_ind=1
    AND cm.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND cm.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100"))
   JOIN (cv
   WHERE cv.code_value=cm.field1_id
    AND cv.code_set=14002
    AND ((cv.cdf_meaning="CPT4") OR (cv.cdf_meaning="MODIFIER"
    AND cv.active_ind=1)) )
   JOIN (pt
   WHERE (pt.order_id= Outerjoin(c.order_id)) )
   JOIN (cs
   WHERE (cs.case_specimen_id= Outerjoin(pt.case_specimen_id)) )
   JOIN (at
   WHERE (at.tag_id= Outerjoin(cs.specimen_tag_id)) )
   JOIN (d1
   WHERE (request->tier_qual[d1.seq].tier_group_cd=c.tier_group_cd))
  ORDER BY tier_order, at.tag_sequence, cm.field6
  HEAD REPORT
   tier_qual_cnt = 0
  HEAD tier_order
   tier_qual_cnt += 1
   IF (mod(tier_qual_cnt,5)=1)
    stat = alterlist(reply->tier_qual,(tier_qual_cnt+ 4))
   ENDIF
   reply->tier_qual[tier_qual_cnt].tier_group_label = request->tier_qual[d1.seq].tier_group_label,
   cpt_cnt = 0, modifier_cnt = 0,
   unattached_cpt_cnt = 0, tag_cnt = 0, last_tag_cnt = 0
  HEAD at.tag_sequence
   tag_cnt += 1
  HEAD cm.field6
   donothing = 0
  DETAIL
   IF (cv.cdf_meaning="CPT4")
    IF (size(trim(at.tag_disp)) > 0)
     cpt_cnt += 1
     IF (mod(cpt_cnt,10)=1)
      stat = alterlist(reply->tier_qual[tier_qual_cnt].cpt_qual,(cpt_cnt+ 9))
     ENDIF
     reply->tier_qual[tier_qual_cnt].cpt_qual[cpt_cnt].cpt_code = cm.field6, reply->tier_qual[
     tier_qual_cnt].cpt_qual[cpt_cnt].cpt_desc = cm.field7, reply->tier_qual[tier_qual_cnt].cpt_qual[
     cpt_cnt].charge_item_id = cm.charge_item_id
     IF (tag_cnt != last_tag_cnt)
      last_tag_cnt = tag_cnt, reply->tier_qual[tier_qual_cnt].cpt_qual[cpt_cnt].specimen_desc = cs
      .specimen_description, reply->tier_qual[tier_qual_cnt].cpt_qual[cpt_cnt].tag_disp = at.tag_disp
     ENDIF
    ELSE
     unattached_cpt_cnt += 1
     IF (mod(unattached_cpt_cnt,10)=1)
      stat = alterlist(reply->tier_qual[tier_qual_cnt].unattached_cpt_qual,(unattached_cpt_cnt+ 9))
     ENDIF
     reply->tier_qual[tier_qual_cnt].unattached_cpt_qual[unattached_cpt_cnt].cpt_code = cm.field6,
     reply->tier_qual[tier_qual_cnt].unattached_cpt_qual[unattached_cpt_cnt].cpt_desc = cm.field7,
     reply->tier_qual[tier_qual_cnt].unattached_cpt_qual[unattached_cpt_cnt].charge_item_id = cm
     .charge_item_id
    ENDIF
   ELSE
    modifier_cnt += 1
    IF (mod(modifier_cnt,10)=1)
     stat = alterlist(modifier->mod_qual,(modifier_cnt+ 9))
    ENDIF
    modifier->mod_qual[modifier_cnt].charge_item_id = cm.charge_item_id, modifier->mod_qual[
    modifier_cnt].modifier_code = cm.field6
   ENDIF
  FOOT  cm.field6
   donothing = 0
  FOOT  at.tag_sequence
   donothing = 0
  FOOT  tier_order
   stat = alterlist(reply->tier_qual[tier_qual_cnt].cpt_qual,cpt_cnt), stat = alterlist(reply->
    tier_qual[tier_qual_cnt].unattached_cpt_qual,unattached_cpt_cnt), stat = alterlist(modifier->
    mod_qual,modifier_cnt)
  FOOT REPORT
   stat = alterlist(reply->tier_qual,tier_qual_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET lselectresult = no_qual
 ENDIF
 IF (error_message(1) > 0)
  SET lselectresult = ccl_error
  GO TO exit_script
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
  CALL echorecord(modifier)
 ENDIF
 IF (size(reply->tier_qual,5) > 0
  AND size(modifier->mod_qual,5) > 0)
  SELECT INTO "nl:"
   charge_item_id = modifier->mod_qual[d1.seq].charge_item_id, modifier_code = modifier->mod_qual[d1
   .seq].modifier_code, cpt_code = reply->tier_qual[d2.seq].cpt_qual[d3.seq].cpt_code
   FROM (dummyt d1  WITH seq = value(size(modifier->mod_qual,5))),
    (dummyt d2  WITH seq = value(size(reply->tier_qual,5))),
    (dummyt d3  WITH seq = 1)
   PLAN (d1)
    JOIN (d2
    WHERE maxrec(d3,size(reply->tier_qual[d2.seq].cpt_qual,5)))
    JOIN (d3
    WHERE (reply->tier_qual[d2.seq].cpt_qual[d3.seq].charge_item_id=modifier->mod_qual[d1.seq].
    charge_item_id))
   ORDER BY charge_item_id, cpt_code, modifier_code
   HEAD REPORT
    mod_cnt = 0
   HEAD charge_item_id
    donothing = 0
   HEAD cpt_code
    donothing = 0
   HEAD modifier_code
    donothing = 0
   DETAIL
    mod_cnt += 1
    IF (mod(mod_cnt,10)=1)
     stat = alterlist(reply->tier_qual[d2.seq].cpt_qual[d3.seq].modifier_qual,(mod_cnt+ 9))
    ENDIF
    reply->tier_qual[d2.seq].cpt_qual[d3.seq].modifier_qual[mod_cnt].modifier_code = modifier->
    mod_qual[d1.seq].modifier_code
   FOOT  modifier_code
    donothing = 0
   FOOT  cpt_code
    stat = alterlist(reply->tier_qual[d2.seq].cpt_qual[d3.seq].modifier_qual,mod_cnt), mod_cnt = 0
   FOOT  charge_item_id
    donothing = 0
   FOOT REPORT
    donothing = 0
   WITH nocounter
  ;end select
  IF (error_message(1) > 0)
   SET lselectresult = ccl_error
   GO TO exit_script
  ENDIF
  IF ((request->debug_ind=1))
   CALL echo("Just finished with attached cpt codes now moving on to unattached cpt codes.")
  ENDIF
  SELECT INTO "nl:"
   charge_item_id = modifier->mod_qual[d1.seq].charge_item_id, modifier_code = modifier->mod_qual[d1
   .seq].modifier_code, cpt_code = reply->tier_qual[d2.seq].unattached_cpt_qual[d3.seq].cpt_code
   FROM (dummyt d1  WITH seq = value(size(modifier->mod_qual,5))),
    (dummyt d2  WITH seq = value(size(reply->tier_qual,5))),
    (dummyt d3  WITH seq = 1)
   PLAN (d1)
    JOIN (d2
    WHERE maxrec(d3,size(reply->tier_qual[d2.seq].unattached_cpt_qual,5)))
    JOIN (d3
    WHERE (reply->tier_qual[d2.seq].unattached_cpt_qual[d3.seq].charge_item_id=modifier->mod_qual[d1
    .seq].charge_item_id))
   ORDER BY charge_item_id, cpt_code, modifier_code
   HEAD REPORT
    mod_cnt = 0
   HEAD charge_item_id
    donothing = 0
   HEAD cpt_code
    donothing = 0
   HEAD modifier_code
    donothing = 0
   DETAIL
    mod_cnt += 1
    IF (mod(mod_cnt,10)=1)
     stat = alterlist(reply->tier_qual[d2.seq].unattached_cpt_qual[d3.seq].modifier_qual,(mod_cnt+ 9)
      )
    ENDIF
    reply->tier_qual[d2.seq].unattached_cpt_qual[d3.seq].modifier_qual[mod_cnt].modifier_code =
    modifier->mod_qual[d1.seq].modifier_code
   FOOT  modifier_code
    donothing = 0
   FOOT  cpt_code
    stat = alterlist(reply->tier_qual[d2.seq].unattached_cpt_qual[d3.seq].modifier_qual,mod_cnt),
    mod_cnt = 0
   FOOT  charge_item_id
    donothing = 0
   FOOT REPORT
    donothing = 0
   WITH nocounter
  ;end select
  IF (error_message(1) > 0)
   SET lselectresult = ccl_error
   GO TO exit_script
  ENDIF
  IF ((request->debug_ind=1))
   CALL echorecord(reply)
  ENDIF
 ENDIF
#exit_script
 CASE (lselectresult)
  OF no_error:
   CALL log_message("cr_get_ap_cpt_codes completed successfuly with out errors.",log_level_debug)
   SET reply->status_data.status = "S"
  OF ccl_error:
   CALL log_message("CCL error message was logged.",log_level_debug)
   SET reply->status_data.status = "F"
  OF no_qual:
   CALL log_message("cr_get_ap_cpt_codes completed with out errors.",log_level_debug)
   SET reply->status_data.status = "Z"
  ELSE
   CALL log_message("Unknown error.",log_level_debug)
   SET reply->status_data.status = "Z"
 ENDCASE
 FREE RECORD modifier
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
END GO
