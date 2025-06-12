CREATE PROGRAM dc_mp_get_stroke
 IF ( NOT (validate(stkeval)))
  RECORD stkeval(
    1 listcnt = i4
    1 colmncnt = i4
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 birthdt = dq8
      2 eidtype = f8
      2 admitdt = dq8
      2 ptqual = i2
      2 cnt = i4
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 hidecnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 hidestat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 tmind = i2
        3 status = i4
        3 event_dt = dq8
        3 eventdtdisp = vc
        3 event_cd = f8
        3 event_disp = vc
        3 event_result = vc
        3 event_cki = vc
        3 event_goal = vc
        3 event_status = i4
        3 eventtype = f8
        3 compenddt = dq8
        3 compstatus = f8
        3 outcomestatus = f8
        3 outcometype = f8
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
        3 resultcnt = i4
        3 results[*]
          4 nomid = f8
          4 nomenflag = i4
          4 numeric = i4
          4 resultunitscd = f8
          4 operand = vc
          4 operator = f8
          4 rslttype = f8
          4 rsltval = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(stkreply)))
  RECORD stkreply(
    1 tabname = vc
    1 listcnt = i4
    1 colmncnt = i4
    1 edind = i2
    1 ipind = i2
    1 dischind = i2
    1 preopind = i2
    1 postopind = i2
    1 rmvcd = f8
    1 rmvdisp = vc
    1 rmvnmcnt = i4
    1 nomenlist[*]
      2 nomenid = f8
      2 nomendisp = vc
    1 qmversion = i2
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 orgid = f8
      2 facilitycd = f8
      2 mostrecentassess = dq8
      2 ptqual = i2
      2 assessdttm = dq8
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
      2 edcnt = i4
      2 ipcnt = i4
      2 dischcnt = i4
      2 preopcnt = i4
      2 postopcnt = i4
      2 edstat = i4
      2 ipstat = i4
      2 dischstat = i4
      2 preopstat = i4
      2 postopstat = i4
      2 events[*]
        3 type = vc
        3 name = vc
        3 mean = vc
        3 tmind = i2
        3 event_status = i4
        3 statusdisp = vc
        3 outcomecatid = f8
        3 outcometskid = f8
        3 outcomefrmid = f8
    1 status = c1
    1 subeventstatus[*]
      2 operationname = c25
      2 operationstatus = c1
      2 targetobjectname = c25
      2 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(ptassess)))
  RECORD ptassess(
    1 listcnt = i4
    1 list[*]
      2 pid = f8
      2 eid = f8
      2 name = vc
      2 birthdt = dq8
      2 eidtype = f8
      2 ptqual = i2
      2 cnt = i4
      2 pwstatus = vc
      2 pwname = vc
      2 pwid = f8
      2 eventcnt = i4
  ) WITH protect
 ENDIF
 DECLARE errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) = null
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2,
  recorddata=vc(ref)) = i2
 SUBROUTINE error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,recorddata)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2) = i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logmsg,errorforceexit,zeroforceexit)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 DECLARE populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) = i2
 SUBROUTINE populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,
  targetobjectvalue,recorddata)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(filter)))
  RECORD filter(
    1 maincatid = f8
    1 filterscnt = i4
    1 filters[*]
      2 fileventid = f8
      2 fileventcatmean = vc
      2 fileventmean = vc
      2 fileventdisp = vc
      2 fileventseq = i4
      2 fileventcatid = f8
      2 values[*]
        3 valeventid = f8
        3 valeventseq = i4
        3 valeventgrpseq = i4
        3 valeventcd = f8
        3 valeventcddisp = vc
        3 valeventtblnm = vc
        3 valeventcd2 = f8
        3 valeventcddisp2 = vc
        3 valeventtblnm2 = vc
        3 valqualflag = i4
        3 valeventoper = vc
        3 valeventtype = i4
        3 valeventftx = vc
        3 valeventnomdisp = vc
        3 valeventdcind = i2
        3 valeventmpmean = vc
        3 valeventmpval = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(events)))
  RECORD events(
    1 cnt = i4
    1 elist[*]
      2 cv = f8
      2 disp = c40
      2 emean = vc
      2 seq = i4
  ) WITH protect
 ENDIF
 DECLARE logicaldomain = i2 WITH constant(checkdic("BR_DATAMART_VALUE.LOGICAL_DOMAIN_ID","A",0)),
 protect
 DECLARE getfilters(catnm=vc,allind=i2,logdom=i2) = vc
 SUBROUTINE getfilters(catnm,allind,logdom)
   IF (logdom=2)
    IF (allind=1)
     SELECT INTO "NL:"
      b.br_datamart_category_id, b.category_topic_mean, bd.filter_mean,
      bd.br_datamart_filter_id, bd.filter_seq, bd.filter_category_mean,
      bd.filter_display, bdv.parent_entity_id, bdv.parent_entity_name,
      bdv.value_seq, bdv.value_type_flag, bdv.qualifier_flag,
      bdv.mpage_param_mean, bdv.mpage_param_value, bdv.group_seq,
      n.source_string
      FROM br_datamart_category b,
       br_datamart_filter bd,
       br_datamart_value bdv,
       nomenclature n
      PLAN (b
       WHERE b.category_name=catnm)
       JOIN (bd
       WHERE bd.br_datamart_category_id=b.br_datamart_category_id)
       JOIN (bdv
       WHERE outerjoin(bd.br_datamart_category_id)=bdv.br_datamart_category_id
        AND outerjoin(bd.br_datamart_filter_id)=bdv.br_datamart_filter_id
        AND bdv.end_effective_dt_tm > outerjoin(sysdate)
        AND bdv.logical_domain_id=outerjoin(qmreq->domainid))
       JOIN (n
       WHERE n.nomenclature_id=outerjoin(bdv.parent_entity_id)
        AND n.end_effective_dt_tm > outerjoin(sysdate)
        AND n.active_ind=outerjoin(1))
      ORDER BY bd.br_datamart_filter_id
      HEAD REPORT
       cntr = 0, filter->maincatid = b.br_datamart_category_id
      HEAD bd.br_datamart_filter_id
       cntr = (cntr+ 1)
       IF (mod(cntr,10)=1)
        now = alterlist(filter->filters,(cntr+ 9))
       ENDIF
       filter->filters[cntr].fileventid = bd.br_datamart_filter_id, filter->filters[cntr].
       fileventcatmean = bd.filter_category_mean, filter->filters[cntr].fileventmean = bd.filter_mean,
       filter->filters[cntr].fileventdisp = bd.filter_display, filter->filters[cntr].fileventseq = bd
       .filter_seq, filter->filters[cntr].fileventcatid = bd.br_datamart_category_id,
       cntx = 0
      DETAIL
       IF (bdv.br_datamart_filter_id > 0)
        cntx = (cntx+ 1)
        IF (mod(cntx,10)=1)
         now = alterlist(filter->filters[cntr].values,(cntx+ 9))
        ENDIF
        filter->filters[cntr].values[cntx].valeventid = bdv.br_datamart_value_id, filter->filters[
        cntr].values[cntx].valeventcd = bdv.parent_entity_id, filter->filters[cntr].values[cntx].
        valeventtblnm = bdv.parent_entity_name,
        filter->filters[cntr].values[cntx].valeventcddisp = uar_get_code_display(bdv.parent_entity_id
         ), filter->filters[cntr].values[cntx].valeventcd2 = bdv.parent_entity_id2, filter->filters[
        cntr].values[cntx].valeventtblnm2 = bdv.parent_entity_name2,
        filter->filters[cntr].values[cntx].valqualflag = bdv.qualifier_flag, filter->filters[cntr].
        values[cntx].valeventtype = bdv.value_type_flag, filter->filters[cntr].values[cntx].
        valeventmpmean = bdv.mpage_param_mean,
        filter->filters[cntr].values[cntx].valeventmpval = bdv.mpage_param_value
        IF (bdv.value_seq > 0)
         filter->filters[cntr].values[cntx].valeventseq = bdv.value_seq
        ELSEIF (bdv.group_seq > 0)
         filter->filters[cntr].values[cntx].valeventseq = bdv.group_seq
        ENDIF
        IF (bdv.qualifier_flag=1)
         filter->filters[cntr].values[cntx].valeventoper = "="
        ELSEIF (bdv.qualifier_flag=2)
         filter->filters[cntr].values[cntx].valeventoper = "!="
        ELSEIF (bdv.qualifier_flag=3)
         filter->filters[cntr].values[cntx].valeventoper = ">"
        ELSEIF (bdv.qualifier_flag=4)
         filter->filters[cntr].values[cntx].valeventoper = "<"
        ELSEIF (bdv.qualifier_flag=5)
         filter->filters[cntr].values[cntx].valeventoper = ">="
        ELSEIF (bdv.qualifier_flag=6)
         filter->filters[cntr].values[cntx].valeventoper = "<="
        ENDIF
        IF (bdv.parent_entity_id > 0
         AND bdv.parent_entity_name="NOMENCLATURE")
         filter->filters[cntr].values[cntx].valeventnomdisp = trim(substring(1,230,n.source_string))
        ELSEIF (bdv.freetext_desc > " ")
         filter->filters[cntr].values[cntx].valeventftx = trim(bdv.freetext_desc)
        ENDIF
       ENDIF
      FOOT  bd.br_datamart_filter_id
       now = alterlist(filter->filters[cntr].values,cntx)
      FOOT REPORT
       now = alterlist(filter->filters,cntr), filter->filterscnt = cntr
      WITH nocounter, separator = " ", format
     ;end select
    ELSE
     IF ( NOT (validate(num3)))
      DECLARE num3 = i4 WITH protect
     ENDIF
     SELECT INTO "NL:"
      b.br_datamart_category_id, bd.filter_mean, bd.br_datamart_filter_id,
      bd.filter_seq, bd.filter_category_mean, bd.filter_display,
      bdv.parent_entity_id, bdv.parent_entity_name, bdv.value_seq,
      bdv.value_type_flag, bdv.qualifier_flag, bdv.mpage_param_mean,
      bdv.mpage_param_value, bdv.group_seq, n.source_string
      FROM br_datamart_category b,
       br_datamart_filter bd,
       br_datamart_value bdv,
       nomenclature n,
       (dummyt d1  WITH seq = value(filter->filterscnt))
      PLAN (b
       WHERE b.category_name=catnm)
       JOIN (bd
       WHERE bd.br_datamart_category_id=b.br_datamart_category_id)
       JOIN (bdv
       WHERE outerjoin(bd.br_datamart_category_id)=bdv.br_datamart_category_id
        AND outerjoin(bd.br_datamart_filter_id)=bdv.br_datamart_filter_id
        AND bdv.end_effective_dt_tm > outerjoin(sysdate)
        AND bdv.logical_domain_id=outerjoin(qmreq->domainid))
       JOIN (n
       WHERE n.nomenclature_id=outerjoin(bdv.parent_entity_id)
        AND n.end_effective_dt_tm > outerjoin(sysdate)
        AND n.active_ind=outerjoin(1))
       JOIN (d1
       WHERE (bd.filter_mean=filter->filters[d1.seq].fileventmean))
      ORDER BY bd.br_datamart_filter_id
      HEAD REPORT
       cntr = 0, filter->maincatid = b.br_datamart_category_id
      HEAD bd.br_datamart_filter_id
       filter->filters[d1.seq].fileventid = bd.br_datamart_filter_id, filter->filters[d1.seq].
       fileventcatmean = bd.filter_category_mean, filter->filters[d1.seq].fileventmean = bd
       .filter_mean,
       filter->filters[d1.seq].fileventdisp = bd.filter_display, filter->filters[d1.seq].fileventseq
        = bd.filter_seq, filter->filters[d1.seq].fileventcatid = bd.br_datamart_category_id,
       cntx = 0
      DETAIL
       IF (bdv.br_datamart_filter_id > 0)
        cntx = (cntx+ 1)
        IF (mod(cntx,10)=1)
         now = alterlist(filter->filters[d1.seq].values,(cntx+ 9))
        ENDIF
        filter->filters[d1.seq].values[cntx].valeventid = bdv.br_datamart_value_id, filter->filters[
        d1.seq].values[cntx].valeventcddisp = uar_get_code_display(bdv.parent_entity_id), filter->
        filters[d1.seq].values[cntx].valeventcd = bdv.parent_entity_id,
        filter->filters[d1.seq].values[cntx].valeventtblnm = bdv.parent_entity_name, filter->filters[
        d1.seq].values[cntx].valeventcd2 = bdv.parent_entity_id2, filter->filters[d1.seq].values[cntx
        ].valeventtblnm2 = bdv.parent_entity_name2,
        filter->filters[d1.seq].values[cntx].valqualflag = bdv.qualifier_flag, filter->filters[d1.seq
        ].values[cntx].valeventtype = bdv.value_type_flag, filter->filters[d1.seq].values[cntx].
        valeventmpmean = bdv.mpage_param_mean,
        filter->filters[d1.seq].values[cntx].valeventmpval = bdv.mpage_param_value
        IF (bdv.value_seq > 0)
         filter->filters[d1.seq].values[cntx].valeventseq = bdv.value_seq
        ELSEIF (bdv.group_seq > 0)
         filter->filters[d1.seq].values[cntx].valeventseq = bdv.group_seq
        ENDIF
        IF (bdv.qualifier_flag=1)
         filter->filters[d1.seq].values[cntx].valeventoper = "="
        ELSEIF (bdv.qualifier_flag=2)
         filter->filters[d1.seq].values[cntx].valeventoper = "!="
        ELSEIF (bdv.qualifier_flag=3)
         filter->filters[d1.seq].values[cntx].valeventoper = ">"
        ELSEIF (bdv.qualifier_flag=4)
         filter->filters[d1.seq].values[cntx].valeventoper = "<"
        ELSEIF (bdv.qualifier_flag=5)
         filter->filters[d1.seq].values[cntx].valeventoper = ">="
        ELSEIF (bdv.qualifier_flag=6)
         filter->filters[d1.seq].values[cntx].valeventoper = "<="
        ENDIF
        IF (bdv.parent_entity_id > 0
         AND bdv.parent_entity_name="NOMENCLATURE")
         filter->filters[d1.seq].values[cntx].valeventnomdisp = trim(substring(1,230,n.source_string)
          )
        ELSEIF (bdv.freetext_desc > " ")
         filter->filters[d1.seq].values[cntx].valeventftx = trim(bdv.freetext_desc)
        ENDIF
       ENDIF
      FOOT  bd.br_datamart_filter_id
       now = alterlist(filter->filters[d1.seq].values,cntx)
      FOOT REPORT
       row + 0
      WITH nocounter, separator = " ", format
     ;end select
    ENDIF
   ELSE
    IF (allind=1)
     SELECT INTO "NL:"
      b.br_datamart_category_id, b.category_topic_mean, bd.filter_mean,
      bd.br_datamart_filter_id, bd.filter_seq, bd.filter_category_mean,
      bd.filter_display, bdv.parent_entity_id, bdv.parent_entity_name,
      bdv.value_seq, bdv.value_type_flag, bdv.qualifier_flag,
      bdv.mpage_param_mean, bdv.mpage_param_value, bdv.group_seq,
      n.source_string
      FROM br_datamart_category b,
       br_datamart_filter bd,
       br_datamart_value bdv,
       nomenclature n
      PLAN (b
       WHERE b.category_name=catnm)
       JOIN (bd
       WHERE bd.br_datamart_category_id=b.br_datamart_category_id)
       JOIN (bdv
       WHERE outerjoin(bd.br_datamart_category_id)=bdv.br_datamart_category_id
        AND outerjoin(bd.br_datamart_filter_id)=bdv.br_datamart_filter_id
        AND bdv.end_effective_dt_tm > outerjoin(sysdate))
       JOIN (n
       WHERE n.nomenclature_id=outerjoin(bdv.parent_entity_id)
        AND n.end_effective_dt_tm > outerjoin(sysdate)
        AND n.active_ind=outerjoin(1))
      ORDER BY bd.br_datamart_filter_id
      HEAD REPORT
       cntr = 0, filter->maincatid = b.br_datamart_category_id
      HEAD bd.br_datamart_filter_id
       cntr = (cntr+ 1)
       IF (mod(cntr,10)=1)
        now = alterlist(filter->filters,(cntr+ 9))
       ENDIF
       filter->filters[cntr].fileventid = bd.br_datamart_filter_id, filter->filters[cntr].
       fileventcatmean = bd.filter_category_mean, filter->filters[cntr].fileventmean = bd.filter_mean,
       filter->filters[cntr].fileventdisp = bd.filter_display, filter->filters[cntr].fileventseq = bd
       .filter_seq, filter->filters[cntr].fileventcatid = bd.br_datamart_category_id,
       cntx = 0
      DETAIL
       IF (bdv.br_datamart_filter_id > 0)
        cntx = (cntx+ 1)
        IF (mod(cntx,10)=1)
         now = alterlist(filter->filters[cntr].values,(cntx+ 9))
        ENDIF
        filter->filters[cntr].values[cntx].valeventid = bdv.br_datamart_value_id, filter->filters[
        cntr].values[cntx].valeventcd = bdv.parent_entity_id, filter->filters[cntr].values[cntx].
        valeventtblnm = bdv.parent_entity_name,
        filter->filters[cntr].values[cntx].valeventcddisp = uar_get_code_display(bdv.parent_entity_id
         ), filter->filters[cntr].values[cntx].valeventcd2 = bdv.parent_entity_id2, filter->filters[
        cntr].values[cntx].valeventtblnm2 = bdv.parent_entity_name2,
        filter->filters[cntr].values[cntx].valqualflag = bdv.qualifier_flag, filter->filters[cntr].
        values[cntx].valeventtype = bdv.value_type_flag, filter->filters[cntr].values[cntx].
        valeventmpmean = bdv.mpage_param_mean,
        filter->filters[cntr].values[cntx].valeventmpval = bdv.mpage_param_value
        IF (bdv.value_seq > 0)
         filter->filters[cntr].values[cntx].valeventseq = bdv.value_seq
        ELSEIF (bdv.group_seq > 0)
         filter->filters[cntr].values[cntx].valeventseq = bdv.group_seq
        ENDIF
        IF (bdv.qualifier_flag=1)
         filter->filters[cntr].values[cntx].valeventoper = "="
        ELSEIF (bdv.qualifier_flag=2)
         filter->filters[cntr].values[cntx].valeventoper = "!="
        ELSEIF (bdv.qualifier_flag=3)
         filter->filters[cntr].values[cntx].valeventoper = ">"
        ELSEIF (bdv.qualifier_flag=4)
         filter->filters[cntr].values[cntx].valeventoper = "<"
        ELSEIF (bdv.qualifier_flag=5)
         filter->filters[cntr].values[cntx].valeventoper = ">="
        ELSEIF (bdv.qualifier_flag=6)
         filter->filters[cntr].values[cntx].valeventoper = "<="
        ENDIF
        IF (bdv.parent_entity_id > 0
         AND bdv.parent_entity_name="NOMENCLATURE")
         filter->filters[cntr].values[cntx].valeventnomdisp = trim(substring(1,230,n.source_string))
        ELSEIF (bdv.freetext_desc > " ")
         filter->filters[cntr].values[cntx].valeventftx = trim(bdv.freetext_desc)
        ENDIF
       ENDIF
      FOOT  bd.br_datamart_filter_id
       now = alterlist(filter->filters[cntr].values,cntx)
      FOOT REPORT
       now = alterlist(filter->filters,cntr), filter->filterscnt = cntr
      WITH nocounter, separator = " ", format
     ;end select
    ELSE
     IF ( NOT (validate(num3)))
      DECLARE num3 = i4 WITH protect
     ENDIF
     SELECT INTO "NL:"
      b.br_datamart_category_id, bd.filter_mean, bd.br_datamart_filter_id,
      bd.filter_seq, bd.filter_category_mean, bd.filter_display,
      bdv.parent_entity_id, bdv.parent_entity_name, bdv.value_seq,
      bdv.value_type_flag, bdv.qualifier_flag, bdv.mpage_param_mean,
      bdv.mpage_param_value, bdv.group_seq, n.source_string
      FROM br_datamart_category b,
       br_datamart_filter bd,
       br_datamart_value bdv,
       nomenclature n,
       (dummyt d1  WITH seq = value(filter->filterscnt))
      PLAN (b
       WHERE b.category_name=catnm)
       JOIN (bd
       WHERE bd.br_datamart_category_id=b.br_datamart_category_id)
       JOIN (bdv
       WHERE outerjoin(bd.br_datamart_category_id)=bdv.br_datamart_category_id
        AND outerjoin(bd.br_datamart_filter_id)=bdv.br_datamart_filter_id
        AND bdv.end_effective_dt_tm > outerjoin(sysdate))
       JOIN (n
       WHERE n.nomenclature_id=outerjoin(bdv.parent_entity_id)
        AND n.end_effective_dt_tm > outerjoin(sysdate)
        AND n.active_ind=outerjoin(1))
       JOIN (d1
       WHERE (bd.filter_mean=filter->filters[d1.seq].fileventmean))
      ORDER BY bd.br_datamart_filter_id
      HEAD REPORT
       cntr = 0, filter->maincatid = b.br_datamart_category_id
      HEAD bd.br_datamart_filter_id
       filter->filters[d1.seq].fileventid = bd.br_datamart_filter_id, filter->filters[d1.seq].
       fileventcatmean = bd.filter_category_mean, filter->filters[d1.seq].fileventmean = bd
       .filter_mean,
       filter->filters[d1.seq].fileventdisp = bd.filter_display, filter->filters[d1.seq].fileventseq
        = bd.filter_seq, filter->filters[d1.seq].fileventcatid = bd.br_datamart_category_id,
       cntx = 0
      DETAIL
       IF (bdv.br_datamart_filter_id > 0)
        cntx = (cntx+ 1)
        IF (mod(cntx,10)=1)
         now = alterlist(filter->filters[d1.seq].values,(cntx+ 9))
        ENDIF
        filter->filters[d1.seq].values[cntx].valeventid = bdv.br_datamart_value_id, filter->filters[
        d1.seq].values[cntx].valeventcddisp = uar_get_code_display(bdv.parent_entity_id), filter->
        filters[d1.seq].values[cntx].valeventcd = bdv.parent_entity_id,
        filter->filters[d1.seq].values[cntx].valeventtblnm = bdv.parent_entity_name, filter->filters[
        d1.seq].values[cntx].valeventcd2 = bdv.parent_entity_id2, filter->filters[d1.seq].values[cntx
        ].valeventtblnm2 = bdv.parent_entity_name2,
        filter->filters[d1.seq].values[cntx].valqualflag = bdv.qualifier_flag, filter->filters[d1.seq
        ].values[cntx].valeventtype = bdv.value_type_flag, filter->filters[d1.seq].values[cntx].
        valeventmpmean = bdv.mpage_param_mean,
        filter->filters[d1.seq].values[cntx].valeventmpval = bdv.mpage_param_value
        IF (bdv.value_seq > 0)
         filter->filters[d1.seq].values[cntx].valeventseq = bdv.value_seq
        ELSEIF (bdv.group_seq > 0)
         filter->filters[d1.seq].values[cntx].valeventseq = bdv.group_seq
        ENDIF
        IF (bdv.qualifier_flag=1)
         filter->filters[d1.seq].values[cntx].valeventoper = "="
        ELSEIF (bdv.qualifier_flag=2)
         filter->filters[d1.seq].values[cntx].valeventoper = "!="
        ELSEIF (bdv.qualifier_flag=3)
         filter->filters[d1.seq].values[cntx].valeventoper = ">"
        ELSEIF (bdv.qualifier_flag=4)
         filter->filters[d1.seq].values[cntx].valeventoper = "<"
        ELSEIF (bdv.qualifier_flag=5)
         filter->filters[d1.seq].values[cntx].valeventoper = ">="
        ELSEIF (bdv.qualifier_flag=6)
         filter->filters[d1.seq].values[cntx].valeventoper = "<="
        ENDIF
        IF (bdv.parent_entity_id > 0
         AND bdv.parent_entity_name="NOMENCLATURE")
         filter->filters[d1.seq].values[cntx].valeventnomdisp = trim(substring(1,230,n.source_string)
          )
        ELSEIF (bdv.freetext_desc > " ")
         filter->filters[d1.seq].values[cntx].valeventftx = trim(bdv.freetext_desc)
        ENDIF
       ENDIF
      FOOT  bd.br_datamart_filter_id
       now = alterlist(filter->filters[d1.seq].values,cntx)
      FOOT REPORT
       row + 0
      WITH nocounter, separator = " ", format
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE evalresults(valloc=i4,rslt=vc,nomid=f8,filseq=i4) = i2
 DECLARE retval = i2 WITH protect
 DECLARE pcnt = i4 WITH protect
 DECLARE nomcnt = i4 WITH protect
 DECLARE nomloc = i4 WITH protect
 DECLARE x = i4 WITH protect
 SUBROUTINE evalresults(valloc,rslt,nomid,filseq)
   SET retval = 0
   SET pcnt = 0
   SET nomcnt = size(filter->filters[valloc].values,5)
   SET nomloc = locateval(pcnt,1,nomcnt,filseq,filter->filters[valloc].values[pcnt].valeventseq)
   IF (nomloc=0)
    SET retval = 1
   ELSE
    FOR (x = 1 TO size(filter->filters[valloc].values,5))
      IF ((filter->filters[valloc].values[x].valeventoper > " "))
       IF ((filter->filters[valloc].values[x].valeventseq=filseq))
        IF ((filter->filters[valloc].values[x].valeventtype=1))
         IF ((filter->filters[valloc].values[x].valeventcd > 0))
          IF (operator(cnvtreal(rslt),filter->filters[valloc].values[x].valeventoper,cnvtreal(filter
            ->filters[valloc].values[x].valeventnomdisp)))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ELSEIF ((filter->filters[valloc].values[x].valeventftx > " "))
          IF (operator(cnvtreal(rslt),filter->filters[valloc].values[x].valeventoper,cnvtreal(filter
            ->filters[valloc].values[x].valeventftx)))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ENDIF
        ELSEIF ((filter->filters[valloc].values[x].valeventtype=2))
         IF (cnvtreal(filter->filters[valloc].values[x].valeventftx) > 0)
          IF (operator(cnvtreal(rslt),filter->filters[valloc].values[x].valeventoper,cnvtreal(filter
            ->filters[valloc].values[x].valeventftx)))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ELSEIF ((filter->filters[valloc].values[x].valeventftx > " "))
          IF (operator(rslt,filter->filters[valloc].values[x].valeventoper,filter->filters[valloc].
           values[x].valeventftx))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ENDIF
        ELSEIF ((filter->filters[valloc].values[x].valeventtype=0))
         IF (nomid > 0
          AND (filter->filters[valloc].values[x].valeventcd > 0))
          IF (operator(nomid,filter->filters[valloc].values[x].valeventoper,filter->filters[valloc].
           values[x].valeventcd))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ELSEIF (nomid > 0
          AND (filter->filters[valloc].values[x].valeventftx > " "))
          IF (operator(rslt,filter->filters[valloc].values[x].valeventoper,filter->filters[valloc].
           values[x].valeventftx))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ELSEIF (rslt > " "
          AND (filter->filters[valloc].values[x].valeventftx > " "))
          IF (operator(rslt,filter->filters[valloc].values[x].valeventoper,filter->filters[valloc].
           values[x].valeventftx))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ELSEIF (rslt > " "
          AND (filter->filters[valloc].values[x].valeventcd > 0))
          IF (operator(rslt,filter->filters[valloc].values[x].valeventoper,filter->filters[valloc].
           values[x].valeventnomdisp))
           SET retval = x
           SET x = size(filter->filters[valloc].values,5)
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ELSE
       SET retval = 1
       SET x = size(filter->filters[valloc].values,5)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE iqrversioncontrol(category_topic_mean=vc,beg_time=dq8) = f8 WITH protect
 DECLARE emeasversioncontrol(category_mean=vc,beg_time=dq8) = i4 WITH protect
 DECLARE getcombinedviewtype(iqrversion=f8,emeasversion=i4,iqrvenuecatmean=vc,emeasvenuecatmean=vc,
  cvflexid=f8,
  cvdomainid=f8) = i2 WITH protect
 DECLARE getcombinedviewtypestring(iqrversion=vc,emeasversion=i4,iqrvenuecatmean=vc,emeasvenuecatmean
  =vc,cvflexid=f8,
  cvdomainid=f8) = i2 WITH protect
 DECLARE getflexid(positioncd=f8) = f8 WITH protect
 DECLARE getdomainid(prsnlid=f8) = f8 WITH protect
 DECLARE getpositioncd(prsnlid=f8) = f8 WITH protect
 DECLARE checkemeasureenabled(flexid=f8,logicaldomainid=f8,categorymean=vc,filtermean=vc(value,
   "QM_COMP_CONTROL"),freetextdesc=vc(value,"1")) = i2 WITH protect
 DECLARE lhprint(text=vc) = null WITH protect
 DECLARE lhelapsedtime(name=vc,beg_time=dq8) = null WITH protect
 DECLARE lhstartscript(name=vc) = null WITH protect
 DECLARE checkfilterexisted(category_topic_mean=vc,filter_mean=vc) = i2 WITH protect
 DECLARE checkvenuedefined(flexid=f8,logicaldomainid=f8,categorymean=vc) = i2 WITH protect
 DECLARE versioncheck(version=vc,minversion=vc) = i2 WITH protect
 DECLARE iqrversioncontrolstring(category_topic_mean=vc,beg_time=dq8) = vc WITH protect
 SUBROUTINE iqrversioncontrol(category_topic_mean,beg_time)
   CALL lhprint("*** Start IQRVersionControl subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE nhiqm_category_mean = vc WITH protect, noconstant("")
   DECLARE version_number = f8 WITH protect, noconstant(0.0)
   DECLARE start_loc = i4 WITH protect, noconstant(0)
   DECLARE len = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    FROM br_datamart_category cat
    WHERE cnvtupper(trim(cat.category_topic_mean,3))=cnvtupper(trim(category_topic_mean,3))
     AND cnvtdatetime(beg_time) BETWEEN cat.beg_effective_dt_tm AND cat.end_effective_dt_tm
    DETAIL
     nhiqm_category_mean = cnvtupper(trim(cat.category_mean,3)), start_loc = (findstring("_V",
      nhiqm_category_mean,1,1)+ 2), len = (size(nhiqm_category_mean,1) - start_loc)
     IF (start_loc > 2)
      version_number = cnvtreal(concat(substring(start_loc,len,nhiqm_category_mean),".",substring((
         start_loc+ len),1,nhiqm_category_mean)))
     ENDIF
    WITH nocounter
   ;end select
   CALL lhelapsedtime("IQRVersionControl",begin_dt_tm)
   RETURN(version_number)
 END ;Subroutine
 SUBROUTINE emeasversioncontrol(category_mean,beg_time)
   CALL lhprint("*** Start EMEASVersionControl subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE exe_string = vc WITH protect, constant(concat("cat.category_mean = '",category_mean,"*'"))
   DECLARE version_number = i4 WITH protect, noconstant(0)
   DECLARE len = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category cat
    WHERE cnvtdatetime(beg_time) >= cat.beg_effective_dt_tm
     AND parser(exe_string)
    ORDER BY cat.beg_effective_dt_tm DESC
    HEAD REPORT
     len = size(trim(cat.category_mean,3),1), version_number = cnvtint(substring((len - 3),len,trim(
        cat.category_mean,3)))
    WITH nocounter
   ;end select
   CALL lhelapsedtime("EMEASVersionControl",begin_dt_tm)
   RETURN(version_number)
 END ;Subroutine
 SUBROUTINE getcombinedviewtype(iqrversion,emeasversion,iqrvenuecatmean,emeasvenuecatmean,cvflexid,
  cvdomainid)
   DECLARE cvtype = i2 WITH noconstant(0), protect
   DECLARE emeashascontrol = i2 WITH constant(checkfilterexisted(emeasvenuecatmean,"QM_COMP_CONTROL")
    ), protect
   DECLARE emeasenabled = i2 WITH constant(checkemeasureenabled(cvflexid,cvdomainid,emeasvenuecatmean
     )), protect
   DECLARE iqrvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,iqrvenuecatmean)),
   protect
   DECLARE emeasvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,
     emeasvenuecatmean)), protect
   IF (emeasversion >= 2016)
    IF (iqrversion >= 4.4)
     IF (iqrvenuedefined=1
      AND emeasvenuedefined=1)
      SET cvtype = 3
     ELSEIF (iqrvenuedefined=0
      AND emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ELSE
     IF (emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ENDIF
   ELSE
    IF (((emeashascontrol=1
     AND emeasenabled=0) OR (emeashascontrol=0)) )
     SET cvtype = 2
    ELSEIF (emeasenabled=1)
     SET cvtype = 1
    ENDIF
   ENDIF
   RETURN(cvtype)
 END ;Subroutine
 SUBROUTINE getcombinedviewtypestring(iqrversionstring,emeasversion,iqrvenuecatmean,emeasvenuecatmean,
  cvflexid,cvdomainid)
   DECLARE cvtype = i2 WITH noconstant(0), protect
   DECLARE emeashascontrol = i2 WITH constant(checkfilterexisted(emeasvenuecatmean,"QM_COMP_CONTROL")
    ), protect
   DECLARE emeasenabled = i2 WITH constant(checkemeasureenabled(cvflexid,cvdomainid,emeasvenuecatmean
     )), protect
   DECLARE iqrvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,iqrvenuecatmean)),
   protect
   DECLARE emeasvenuedefined = i2 WITH constant(checkvenuedefined(cvflexid,cvdomainid,
     emeasvenuecatmean)), protect
   SET min_version = cnvtstring(4.4,3,1)
   SET version_check = versioncheck(iqrversionstring,min_version)
   IF (emeasversion >= 2016)
    IF (version_check=1)
     IF (iqrvenuedefined=1
      AND emeasvenuedefined=1)
      SET cvtype = 3
     ELSEIF (iqrvenuedefined=0
      AND emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ELSE
     IF (emeasvenuedefined=1)
      SET cvtype = 1
     ELSEIF (iqrvenuedefined=1
      AND emeasvenuedefined=0)
      SET cvtype = 2
     ENDIF
    ENDIF
   ELSE
    IF (((emeashascontrol=1
     AND emeasenabled=0) OR (emeashascontrol=0)) )
     SET cvtype = 2
    ELSEIF (emeasenabled=1)
     SET cvtype = 1
    ENDIF
   ENDIF
   RETURN(cvtype)
 END ;Subroutine
 SUBROUTINE getflexid(positioncd)
   CALL lhprint("*** Start getFlexId subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE flexid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM br_datamart_flex b
    PLAN (b
     WHERE b.parent_entity_id=positioncd
      AND b.grouper_ind=0)
    DETAIL
     flexid = b.br_datamart_flex_id
    WITH nocounter
   ;end select
   CALL lhelapsedtime("getFlexId",begin_dt_tm)
   RETURN(flexid)
 END ;Subroutine
 SUBROUTINE getdomainid(prsnlid)
   CALL lhprint("*** Start getDomainId subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE logicaldomainid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=prsnlid
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     logicaldomainid = p.logical_domain_id
    WITH nocounter
   ;end select
   CALL lhelapsedtime("getDomainId",begin_dt_tm)
   RETURN(logicaldomainid)
 END ;Subroutine
 SUBROUTINE getpositioncd(prsnlid)
   CALL lhprint("*** Start getPositionCD subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE positioncd = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=prsnlid
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     positioncd = p.position_cd
    WITH nocounter
   ;end select
   CALL lhelapsedtime("getPositionCD",begin_dt_tm)
   RETURN(positioncd)
 END ;Subroutine
 SUBROUTINE checkemeasureenabled(flexid,logicaldomainid,categorymean,filtermean,freetextdesc)
   CALL lhprint("*** Start checkEMeasureEnabled subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE measureenabled = i2 WITH noconstant(0)
   DECLARE i = i2 WITH noconstant(0)
   FOR (i = 1 TO 2)
    SELECT INTO "nl:"
     FROM br_datamart_category b,
      br_datamart_filter bf,
      br_datamart_value bv
     PLAN (b
      WHERE b.category_mean=categorymean)
      JOIN (bf
      WHERE bf.br_datamart_category_id=b.br_datamart_category_id)
      JOIN (bv
      WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
       AND bv.br_datamart_flex_id=flexid
       AND bv.logical_domain_id=logicaldomainid)
     DETAIL
      IF (bv.freetext_desc=freetextdesc
       AND bf.filter_mean=filtermean)
       measureenabled = 1
      ENDIF
     WITH nocounter, orahintcbo("LEADING(B BF BV) USE_NL(BF BV) INDEX(BV XIE4BR_DATAMART_VALUE)")
    ;end select
    IF (curqual > 0)
     SET i = 3
    ELSE
     SET flexid = 0.0
    ENDIF
   ENDFOR
   CALL lhelapsedtime("checkEMeasureEnabled",begin_dt_tm)
   RETURN(measureenabled)
 END ;Subroutine
 SUBROUTINE lhprint(text)
   IF (validate(debug_lh_mp_audit_file_ind,0)=1)
    IF (validate(audit_filename))
     SELECT INTO value(audit_filename)
      FROM dummyt
      DETAIL
       IF (size(text,1) < 35000)
        CALL print(text)
       ENDIF
      WITH noheading, nocounter, format = lfstream,
       maxcol = 35000, maxrow = 1, append
     ;end select
    ELSE
     CALL echo(text)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE lhelapsedtime(name,beg_time)
   CALL lhprint(concat("*** Summary : ",name," ***"))
   CALL lhprint(concat(";Start time: ",format(beg_time,"MM/DD/YYYY HH:MM:SS;;D")))
   CALL lhprint(concat(";End time: ",format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM:SS;;D"))
    )
   CALL lhprint(build(";Elapsed Time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),
      beg_time,5)))
   DECLARE errcode = i4 WITH noconstant(0), protect
   DECLARE errmsg = vc WITH noconstant(""), protect
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    CALL lhprint(concat("Error while running query for <",name,">"))
    CALL lhprint("The last error on the top of stack: ")
    CALL lhprint(errmsg)
   ENDIF
   SET errcode = error(errmsg,1)
   CALL lhprint(" ")
   CALL lhprint("================================================= ")
 END ;Subroutine
 SUBROUTINE lhstartscript(name)
   CALL lhprint("")
   CALL lhprint("***************************************** ")
   CALL lhprint(concat("; Start Script: ",name))
   CALL lhprint("***************************************** ")
   CALL lhprint("")
 END ;Subroutine
 SUBROUTINE checkfilterexisted(category_topic_mean,filter_mean)
   CALL lhprint("*** Start checkFilterExisted subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE filterexisted = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM br_datamart_category b,
     br_datamart_filter bf
    PLAN (b
     WHERE b.category_mean=category_topic_mean)
     JOIN (bf
     WHERE bf.br_datamart_category_id=b.br_datamart_category_id
      AND bf.filter_mean=filter_mean)
    DETAIL
     filterexisted = 1
    WITH nocounter
   ;end select
   CALL lhelapsedtime("checkFilterExisted",begin_dt_tm)
   RETURN(filterexisted)
 END ;Subroutine
 SUBROUTINE checkvenuedefined(flexid,logicaldomainid,categorymean)
   CALL lhprint("*** Start checkVenueDefined subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE venuedefined = i2 WITH noconstant(0), protect
   DECLARE positionind = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category b,
     br_datamart_filter bf,
     br_datamart_value bv
    PLAN (b
     WHERE b.category_mean=categorymean)
     JOIN (bf
     WHERE bf.br_datamart_category_id=b.br_datamart_category_id)
     JOIN (bv
     WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.br_datamart_flex_id=flexid
      AND bv.logical_domain_id=logicaldomainid)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET flexid = 0.0
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_category b,
     br_datamart_filter bf,
     br_datamart_value bv
    PLAN (b
     WHERE b.category_mean=categorymean)
     JOIN (bf
     WHERE bf.br_datamart_category_id=b.br_datamart_category_id
      AND ((bf.filter_mean="*_VENUE*") OR (bf.filter_mean IN ("MP_PC_BMF_MOM", "MP_PC_BMF_INF",
     "MP_PC_UCN_MOM", "MP_PC_UCN_INF"))) )
     JOIN (bv
     WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.br_datamart_flex_id=flexid
      AND bv.logical_domain_id=logicaldomainid)
    DETAIL
     venuedefined = 1
    WITH nocounter, orahintcbo("LEADING(B BF BV) USE_NL(BF BV) INDEX(BV XIE4BR_DATAMART_VALUE)")
   ;end select
   CALL lhelapsedtime("checkVenueDefined",begin_dt_tm)
   RETURN(venuedefined)
 END ;Subroutine
 SUBROUTINE versioncheck(version,minversion)
   DECLARE versioncheckind = i2 WITH noconstant(0)
   IF (((cnvtint(version) > cnvtint(minversion)) OR (((cnvtint(version) >= cnvtint(minversion)
    AND size(version,1) > size(minversion)) OR (cnvtreal(version) >= cnvtreal(minversion)
    AND size(version,1) >= size(minversion))) )) )
    SET versioncheckind = 1
   ENDIF
   RETURN(versioncheckind)
 END ;Subroutine
 SUBROUTINE iqrversioncontrolstring(category_topic_mean,beg_time)
   CALL lhprint("*** Start IQRVersionControl subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE nhiqm_category_mean = vc WITH protect, noconstant("")
   DECLARE version_number = vc WITH protect, noconstant("")
   DECLARE start_loc = i4 WITH protect, noconstant(0)
   DECLARE len = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    FROM br_datamart_category cat
    WHERE cnvtupper(trim(cat.category_topic_mean,3))=cnvtupper(trim(category_topic_mean,3))
     AND cnvtdatetime(beg_time) BETWEEN cat.beg_effective_dt_tm AND cat.end_effective_dt_tm
    DETAIL
     nhiqm_category_mean = cnvtupper(trim(cat.category_mean,3)), start_loc = (findstring("_V",
      nhiqm_category_mean,1,1)+ 2), len = (size(nhiqm_category_mean,1) - start_loc)
     IF (start_loc > 2)
      version_number = concat(substring(start_loc,1,nhiqm_category_mean),".",substring((start_loc+ 1),
        len,nhiqm_category_mean))
     ENDIF
    WITH nocounter
   ;end select
   CALL lhelapsedtime("IQRVersionControlString",begin_dt_tm)
   RETURN(version_number)
 END ;Subroutine
 FREE RECORD br_setting
 RECORD br_setting(
   1 filters[*]
     2 filter_mean = vc
     2 filter_display = vc
     2 items[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 value_seq = i4
       3 group_seq = i4
       3 free_text_desc = vc
       3 value_type_flag = i2
       3 qualifier_flag = i2
       3 logical_domain_id = f8
 )
 FREE RECORD emeas_setting
 RECORD emeas_setting(
   1 filters[*]
     2 filter_mean = vc
     2 filter_display = vc
     2 items[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 value_seq = i4
       3 group_seq = i4
       3 free_text_desc = vc
       3 value_type_flag = i2
       3 qualifier_flag = i2
       3 logical_domain_id = f8
 )
 FREE RECORD iqr_setting
 RECORD iqr_setting(
   1 filters[*]
     2 filter_mean = vc
     2 filter_display = vc
     2 items[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 value_seq = i4
       3 group_seq = i4
       3 free_text_desc = vc
       3 value_type_flag = i2
       3 qualifier_flag = i2
       3 logical_domain_id = f8
 )
 FREE RECORD tmp_outcomes
 RECORD tmp_outcomes(
   1 outcomes[*]
     2 condition_id = f8
     2 outcome_desc = vc
     2 meas_mean = vc
     2 complete_ind = i2
     2 hoverdisplay = vc
     2 showiconind = i2
     2 measures[*]
       3 delayditherind = i2
       3 oralfactordither = i2
       3 vancopresind = i2
       3 ditherpresamiind = i2
       3 dithermeasureind = i2
       3 name = vc
       3 measuremetind = i2
       3 contraind = i2
       3 ordersetind = i4
       3 orderpresentind = i4
       3 ordercd = f8
       3 ordercompletedisplay = vc
       3 orderincompletedisplay = vc
       3 ordertaskind = i2
       3 adminsetind = i4
       3 adminpresentind = i4
       3 admincompletedisplay = vc
       3 adminincompletedisplay = vc
       3 admintaskind = i2
       3 adminformid = f8
       3 admintabname = vc
       3 pressetind = i4
       3 prespresentind = i4
       3 prescompletedisplay = vc
       3 presincompletedisplay = vc
       3 prestaskind = i2
       3 docsetind = i2
       3 docpresentind = i2
       3 doccompletedisplay = vc
       3 docincompletedisplay = vc
       3 doctaskind = i2
       3 docformid = f8
       3 doctabname = vc
       3 colsetind = i2
       3 colpresentind = i2
       3 colcompletedisplay = vc
       3 colincompletedisplay = vc
       3 coltaskind = i2
       3 colformid = f8
       3 coltabname = vc
       3 orderdetailidx = i4
       3 admindetailidx = i4
       3 presdetailidx = i4
       3 docdetailidx = i4
       3 coldetailidx = i4
       3 contrataskidx = i4
       3 notactionablelabel = vc
     2 iview[*]
       3 measure_name = vc
       3 doc_iview_band = vc
       3 doc_iview_section = vc
       3 doc_iview_item = vc
 )
 DECLARE organizesequence(rec=vc(ref),cond_seq=vc(ref),cond_id=f8) = null WITH protect
 DECLARE getmpagesetting(flex_id=f8,logical_domain_id=f8,category_mean=vc,rec=vc(ref)) = null WITH
 protect
 SUBROUTINE getmpagesetting(flex_id,logical_domain_id,category_mean,rec)
   CALL lhprint("*** Start getMPageSetting subroutine ***")
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE catstr = vc WITH constant(nullterm(concat("b.category_mean IN (",category_mean," )"))),
   protect
   DECLARE i = i2 WITH noconstant(0), protect
   FOR (i = 1 TO 2)
    SELECT INTO "nl:"
     FROM br_datamart_category b,
      br_datamart_filter bf,
      br_datamart_value bv
     PLAN (b
      WHERE parser(catstr)
       AND b.br_datamart_category_id > 0)
      JOIN (bf
      WHERE bf.br_datamart_category_id=b.br_datamart_category_id)
      JOIN (bv
      WHERE bv.br_datamart_filter_id=bf.br_datamart_filter_id
       AND bv.br_datamart_flex_id=flex_id
       AND bv.logical_domain_id=logical_domain_id)
     ORDER BY b.br_datamart_category_id, bf.br_datamart_filter_id, bv.br_datamart_value_id
     HEAD b.br_datamart_category_id
      filter_cnt = size(rec->filters,5)
     HEAD bf.br_datamart_filter_id
      filter_cnt = (filter_cnt+ 1)
      IF (size(rec->filters,5) < filter_cnt)
       stat = alterlist(rec->filters,(filter_cnt+ 49))
      ENDIF
      rec->filters[filter_cnt].filter_mean = bf.filter_mean, rec->filters[filter_cnt].filter_display
       = bf.filter_display, item_cnt = 0
     DETAIL
      item_cnt = (item_cnt+ 1)
      IF (mod(item_cnt,100)=1)
       stat = alterlist(rec->filters[filter_cnt].items,(item_cnt+ 99))
      ENDIF
      rec->filters[filter_cnt].items[item_cnt].parent_entity_id = bv.parent_entity_id, rec->filters[
      filter_cnt].items[item_cnt].parent_entity_name = bv.parent_entity_name, rec->filters[filter_cnt
      ].items[item_cnt].value_seq = bv.value_seq,
      rec->filters[filter_cnt].items[item_cnt].group_seq = bv.group_seq, rec->filters[filter_cnt].
      items[item_cnt].value_type_flag = bv.value_type_flag, rec->filters[filter_cnt].items[item_cnt].
      qualifier_flag = bv.qualifier_flag,
      rec->filters[filter_cnt].items[item_cnt].logical_domain_id = bv.logical_domain_id, rec->
      filters[filter_cnt].items[item_cnt].free_text_desc = bv.freetext_desc
     FOOT  bf.br_datamart_filter_id
      stat = alterlist(rec->filters[filter_cnt].items,item_cnt)
     FOOT  b.br_datamart_category_id
      stat = alterlist(rec->filters,filter_cnt)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET i = 3
    ELSE
     SET flex_id = 0.0
    ENDIF
   ENDFOR
   CALL lhelapsedtime("getMPageSetting",begin_dt_tm)
 END ;Subroutine
 SUBROUTINE organizesequence(rec,cond_seq,cond_id)
   DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE seq_cnt = i4 WITH noconstant(0), protect
   DECLARE copyfrompos = i4 WITH noconstant(0), protect
   DECLARE copybackpos = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   FOR (cnt = 1 TO size(rec->patients,5))
     SET stat = initrec(tmp_outcomes)
     SET stat = alterlist(tmp_outcomes->outcomes,size(cond_seq->seq,5))
     FOR (seq_cnt = 1 TO size(cond_seq->seq,5))
      SET copyfrompos = locateval(idx,1,size(rec->patients[cnt].outcomes,5),cond_seq->seq[seq_cnt].
       meas_mean,rec->patients[cnt].outcomes[idx].meas_mean,
       cond_id,rec->patients[cnt].outcomes[idx].condition_id)
      IF (copyfrompos > 0)
       SET tmp_outcomes->outcomes[seq_cnt].condition_id = rec->patients[cnt].outcomes[copyfrompos].
       condition_id
       SET tmp_outcomes->outcomes[seq_cnt].outcome_desc = rec->patients[cnt].outcomes[copyfrompos].
       outcome_desc
       SET tmp_outcomes->outcomes[seq_cnt].meas_mean = rec->patients[cnt].outcomes[copyfrompos].
       meas_mean
       SET tmp_outcomes->outcomes[seq_cnt].complete_ind = rec->patients[cnt].outcomes[copyfrompos].
       complete_ind
       SET tmp_outcomes->outcomes[seq_cnt].hoverdisplay = rec->patients[cnt].outcomes[copyfrompos].
       hoverdisplay
       SET tmp_outcomes->outcomes[seq_cnt].showiconind = rec->patients[cnt].outcomes[copyfrompos].
       showiconind
       SET stat = moverec(rec->patients[cnt].outcomes[copyfrompos].measures,tmp_outcomes->outcomes[
        seq_cnt].measures)
       IF (validate(rec->patients[cnt].outcomes[copyfrompos].iview) > 0
        AND validate(tmp_outcomes->outcomes[seq_cnt].iview) > 0)
        SET stat = moverec(rec->patients[cnt].outcomes[copyfrompos].iview,tmp_outcomes->outcomes[
         seq_cnt].iview)
       ENDIF
      ENDIF
     ENDFOR
     SET start_idx = 1
     FOR (seq_cnt = 1 TO size(tmp_outcomes->outcomes,5))
      IF ((tmp_outcomes->outcomes[seq_cnt].condition_id != 0.0))
       SET copybackpos = locateval(idx,start_idx,size(rec->patients[cnt].outcomes,5),tmp_outcomes->
        outcomes[seq_cnt].condition_id,rec->patients[cnt].outcomes[idx].condition_id)
       IF (copybackpos > 0)
        SET rec->patients[cnt].outcomes[copybackpos].condition_id = tmp_outcomes->outcomes[seq_cnt].
        condition_id
        SET rec->patients[cnt].outcomes[copybackpos].outcome_desc = tmp_outcomes->outcomes[seq_cnt].
        outcome_desc
        SET rec->patients[cnt].outcomes[copybackpos].meas_mean = tmp_outcomes->outcomes[seq_cnt].
        meas_mean
        SET rec->patients[cnt].outcomes[copybackpos].complete_ind = tmp_outcomes->outcomes[seq_cnt].
        complete_ind
        SET rec->patients[cnt].outcomes[copybackpos].hoverdisplay = tmp_outcomes->outcomes[seq_cnt].
        hoverdisplay
        SET rec->patients[cnt].outcomes[copybackpos].showiconind = tmp_outcomes->outcomes[seq_cnt].
        showiconind
        SET stat = moverec(tmp_outcomes->outcomes[seq_cnt].measures,rec->patients[cnt].outcomes[
         copybackpos].measures)
        IF (validate(rec->patients[cnt].outcomes[copybackpos].iview) > 0
         AND validate(tmp_outcomes->outcomes[seq_cnt].iview) > 0)
         SET stat = moverec(tmp_outcomes->outcomes[seq_cnt].iview,rec->patients[cnt].outcomes[
          copybackpos].iview)
        ENDIF
       ENDIF
      ENDIF
      SET start_idx = (copybackpos+ 1)
     ENDFOR
   ENDFOR
   CALL lhprint(build(";organizeSequence Process time: ",datetimediff(cnvtdatetime(curdate,curtime3),
      begin_dt_tm,5)))
 END ;Subroutine
 DECLARE current_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE ver_num = vc WITH protect, constant(iqrversioncontrolstring("STROKE_NHIQM",current_dt_tm))
 DECLARE emeas_ver_num = i4 WITH constant(emeasversioncontrol("MU_CQM_EH_STK",current_dt_tm)),
 protect
 IF (( $2 != null))
  SET jrec = cnvtjsontorec( $2)
  IF (validate(debug_dc_mp_get_stroke_ind,0)=1)
   CALL echo("This is the converted json string to record")
   CALL echorecord(qmreq)
  ENDIF
 ENDIF
 DECLARE _positioncd = f8 WITH constant(getpositioncd(cnvtreal(qmreq->prsnlid))), protect
 DECLARE _logicaldomainid = f8 WITH constant(getdomainid(cnvtreal(qmreq->prsnlid))), protect
 DECLARE _flexid = f8 WITH constant(getflexid(_positioncd)), protect
 DECLARE iqr_current_version = vc WITH constant(iqrversioncontrolstring("STROKE_NHIQM",current_dt_tm)
  ), protect
 DECLARE combinedviewtype = i2 WITH constant(getcombinedviewtypestring(iqr_current_version,
   emeas_ver_num,"MP_QM_STK_2","MP_QM_ESTK_2",_flexid,
   _logicaldomainid)), protect
 DECLARE iqrvenuedefined = i2 WITH constant(checkvenuedefined(_flexid,_logicaldomainid,"MP_QM_STK_2")
  ), protect
 DECLARE emeasvenuedefined = i2 WITH constant(checkvenuedefined(_flexid,_logicaldomainid,
   "MP_QM_ESTK_2")), protect
 SET min_version = cnvtstring(5.0,3,1)
 SET version_check = versioncheck(iqr_current_version,min_version)
 IF (validate(debug_dc_mp_get_stroke_ind,0)=1)
  CALL echo(build("prsnl ID --->",qmreq->prsnlid))
  CALL echo(build("position CD --->",_positioncd))
  CALL echo(build("logical domain ID --->",_logicaldomainid))
  CALL echo(build("flex ID --->",_flexid))
 ENDIF
 IF (checkemeasureenabled(_flexid,_logicaldomainid,"MP_QM_ESTK_2")=1
  AND emeas_ver_num=2015)
  IF (checkdic("LH_MP_ORG_E_STK","P",0) > 0)
   EXECUTE lh_mp_org_e_stk  WITH replace("REQUEST",qmreq), replace("REPLY",stkreply), replace(
    "FLEXID",_flexid),
   replace("DOMAINID",_logicaldomainid)
   GO TO exit_script
  ENDIF
 ELSEIF (emeas_ver_num >= 2016)
  IF (checkdic("LH_MP_COMBINE_ORG_STK","P",0) > 0)
   EXECUTE lh_mp_combine_org_stk  WITH replace("REQUEST",qmreq), replace("REPLY",stkreply), replace(
    "FLEXID",_flexid),
   replace("DOMAINID",_logicaldomainid), replace("STK_IQR_IND",iqrvenuedefined), replace(
    "STK_EMEAS_IND",emeasvenuedefined)
   GO TO exit_script
  ENDIF
 ELSE
  IF (version_check=1
   AND checkdic("LH_MP_COMBINE_ORG_STK","P",0) > 0)
   EXECUTE lh_mp_combine_org_stk  WITH replace("REQUEST",qmreq), replace("REPLY",stkreply), replace(
    "FLEXID",_flexid),
   replace("DOMAINID",_logicaldomainid), replace("STK_IQR_IND",iqrvenuedefined), replace(
    "STK_EMEAS_IND",emeasvenuedefined)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (validate(debug_dc_mp_get_stroke_ind,0)=1)
  CALL echorecord(filter)
  CALL echorecord(stkeval)
  CALL echorecord(stkreply)
 ENDIF
 IF (validate(_memory_reply_string)=1)
  SET _memory_reply_string = cnvtrectojson(stkreply)
 ELSE
  CALL echojson(stkreply, $1)
 ENDIF
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH nocounter
 ;end select
END GO
