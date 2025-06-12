CREATE PROGRAM ap_upd_report_hold:dba
 DECLARE true_all = i4 WITH protect, constant(1)
 DECLARE false_hashold = i4 WITH protect, constant(2)
 DECLARE fail_link = i4 WITH protect, constant(3)
 DECLARE fail_cclerr = i4 WITH protect, constant(4)
 DECLARE true_change = i4 WITH protect, constant(5)
 DECLARE true_removed = i4 WITH protect, constant(6)
 DECLARE false_noreason = i4 WITH protect, constant(7)
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE encntrid = f8 WITH protect, noconstant(0.0)
 DECLARE orderid = f8 WITH protect, noconstant(0.0)
 DECLARE accessionid = f8 WITH protect, noconstant(0.0)
 DECLARE llink_index = i4 WITH protect, noconstant(0)
 DECLARE dlink_accessionid = f8 WITH protect, noconstant(0.0)
 DECLARE dlink_orderid = f8 WITH protect, noconstant(0.0)
 DECLARE dhold_code = f8 WITH protect, noconstant(0.0)
 DECLARE dreport_id = f8 WITH protect, noconstant(0.0)
 DECLARE lnum_logic_temps = i4 WITH protect, noconstant(0)
 DECLARE stailstr = c25 WITH protect, noconstant("")
 DECLARE sremovestr = c25 WITH protect, noconstant("")
 DECLARE lupdt_cnt = i4 WITH protect, noconstant(0)
 DECLARE lltupdt_cnt = i4 WITH protect, noconstant(0)
 DECLARE sfullname = vc WITH protect, noconstant("")
 DECLARE bisaddtemp = i2 WITH protect, noconstant(0)
 DECLARE bwasonhold = i2 WITH protect, noconstant(0)
 DECLARE breasonblank = i2 WITH protect, noconstant(0)
 DECLARE dcommentltid = f8 WITH protect, noconstant(0.0)
 DECLARE sholdcomment = vc WITH protect, noconstant("")
 FREE RECORD shellrequest
 RECORD shellrequest(
   1 hold_cd = f8
   1 updt_cnt = i4
   1 report_id = f8
   1 hold_comment = vc
   1 hold_comment_long_text_id = f8
   1 lt_updt_cnt = i4
 ) WITH protect
 FREE RECORD shellreply
 RECORD shellreply(
   1 long_text_id = f8
   1 hold_cd = f8
   1 hold_disp = vc
   1 updt_cnt = i4
   1 lt_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD hold_reasonlist
 RECORD hold_reasonlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 ) WITH protect
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim(eks_common->cur_module_name)
 SET eksmodule = trim(ttemp)
 FREE SET ttemp
 SET ttemp = trim(eks_common->event_name)
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF ( NOT (validate(eksdata->tqual,"Y")="Y"
  AND validate(eksdata->tqual,"Z")="Z"))
  FREE SET templatetype
  IF (conclude > 0)
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt+ evokecnt)
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo(concat("****  ",format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "     Module:  ",
   trim(eksmodule),"  ****"),1,0)
 IF (validate(tname,"Y")="Y"
  AND validate(tname,"Z")="Z")
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),
     ")           Event:  ",
     trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning an Evoke Template","           Event:  ",trim(eksevent),
     "         Request number:  ",cnvtstring(eksrequest)),1,10)
  ENDIF
 ELSE
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),"):  ",
     trim(tname),"       Event:  ",trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)
     ),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning Evoke Template:  ",trim(tname),"       Event:  ",trim(
      eksevent),"         Request number:  ",
     cnvtstring(eksrequest)),1,10)
  ENDIF
 ENDIF
 IF ( NOT (validate(gsapeksmonitormsg)))
  DECLARE gsapeksmonitormsg = vc WITH protect, noconstant("")
  DECLARE gsapeksaccformatted = vc WITH protect, noconstant("")
  SUBROUTINE (apeksvalidateparam(sparamname=vc,nnumericind=i2) =i2 WITH protect)
    DECLARE sparserstring = vc WITH protect, noconstant("")
    DECLARE nparamexistsind = i2 WITH protect, noconstant(0)
    DECLARE sparamvalue = vc WITH protect, noconstant("")
    DECLARE nvalueexistsind = i2 WITH protect, noconstant(0)
    SET sparserstring = concat("set nParamExistsInd = validate(",sparamname,") go")
    CALL parser(sparserstring,1)
    IF (nparamexistsind)
     SET sparserstring = concat("set sParamValue = trim(",sparamname,") go")
     CALL parser(sparserstring,1)
     CALL echo(build(sparamname,":",sparamvalue))
     IF (nnumericind)
      IF (isnumeric(sparamvalue))
       SET nvalueexistsind = 1
      ENDIF
     ELSE
      IF (((size(sparamvalue)=0) OR (sparamvalue="<undefined>")) )
       SET nvalueexistsind = 0
      ELSE
       SET nvalueexistsind = 1
      ENDIF
     ENDIF
    ELSE
     SET gsapeksmonitormsg = concat("Parameter ",sparamname," does not exist!")
     SET retval = - (1)
     RETURN(0)
    ENDIF
    IF ( NOT (nvalueexistsind))
     CALL echo(concat("Parameter ",sparamname," has no value."))
     RETURN(0)
    ENDIF
    RETURN(1)
  END ;Subroutine
  SUBROUTINE (apeksgetactionorderid(sprocedure=vc,nlink=i2) =f8 WITH protect)
    DECLARE dlnkordid = f8 WITH protect, noconstant(0.0)
    DECLARE dlnkaccid = f8 WITH protect, noconstant(0.0)
    DECLARE dactordid = f8 WITH protect, noconstant(0.0)
    DECLARE nordmatchcnt = i2 WITH protect, noconstant(0)
    SET dlnkordid = eksdata->tqual[tinx].qual[nlink].order_id
    SET dlnkaccid = eksdata->tqual[tinx].qual[nlink].accession_id
    IF (dlnkordid > 0.0)
     SELECT INTO "nl:"
      FROM orders o,
       order_catalog oc,
       accession_order_r aor
      PLAN (o
       WHERE o.order_id=dlnkordid)
       JOIN (oc
       WHERE oc.catalog_cd=o.catalog_cd)
       JOIN (aor
       WHERE aor.order_id=o.order_id
        AND aor.primary_flag=0)
      DETAIL
       IF (dlnkaccid <= 0.0)
        dlnkaccid = aor.accession_id
       ENDIF
       IF (oc.primary_mnemonic=trim(sprocedure))
        nordmatchcnt += 1, dactordid = o.order_id, gsapeksaccformatted = cnvtacc(aor.accession)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (dlnkaccid <= 0.0)
     SET gsapeksmonitormsg = "Invalid ACCESSION_ID from linked logic template."
     RETURN(0.0)
    ENDIF
    IF (dlnkaccid > 0.0
     AND nordmatchcnt=0)
     SELECT INTO "nl:"
      FROM accession_order_r aor,
       orders o,
       order_catalog oc
      PLAN (aor
       WHERE aor.accession_id=dlnkaccid
        AND aor.primary_flag=0)
       JOIN (o
       WHERE o.order_id=aor.order_id)
       JOIN (oc
       WHERE oc.catalog_cd=o.catalog_cd)
      DETAIL
       IF (oc.primary_mnemonic=trim(sprocedure))
        nordmatchcnt += 1, dactordid = o.order_id, gsapeksaccformatted = cnvtacc(aor.accession)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (size(trim(gsapeksaccformatted))=0)
     SELECT INTO "nl:"
      FROM accession_order_r aor
      WHERE aor.accession_id=dlnkaccid
       AND aor.primary_flag=0
      DETAIL
       gsapeksaccformatted = cnvtacc(aor.accession)
      WITH nocounter
     ;end select
    ENDIF
    IF (nordmatchcnt=1)
     RETURN(dactordid)
    ELSEIF (nordmatchcnt > 1)
     SET gsapeksmonitormsg = concat("Multiple ",trim(sprocedure)," found on accession ",trim(
       gsapeksaccformatted),".")
    ELSE
     SET gsapeksmonitormsg = concat(trim(sprocedure)," not found on accession ",trim(
       gsapeksaccformatted),".")
    ENDIF
    RETURN(0.0)
  END ;Subroutine
 ENDIF
 DECLARE getcclerrormsg() = vc WITH protect
 DECLARE buildshellrequest() = i4 WITH protect
 DECLARE setmsgstrings() = null WITH protect
 CALL echo("Entering AP_HOLD Action Templates ")
 IF (apeksvalidateparam("LINK",1)
  AND apeksvalidateparam("PROCEDURE1",0))
  SET llink_index = cnvtint(trim(link))
  SET lnum_logic_temps = size(eksdata->tqual[tinx].qual,5)
  IF (llink_index <= lnum_logic_temps
   AND llink_index > 0)
   SET dlink_accessionid = eksdata->tqual[tinx].qual[llink_index].accession_id
   SET dlink_orderid = apeksgetactionorderid(trim(procedure1),llink_index)
   IF (dlink_orderid=0.0)
    SET retval = 0
    GO TO endofscript
   ELSE
    SET retval = buildshellrequest(null)
    IF (retval > 0)
     CALL echo("AP_HOLD: executing core script")
     EXECUTE aps_chg_hold_reports  WITH replace("REQUEST","SHELLREQUEST"), replace("REPLY",
      "SHELLREPLY")
     IF ((shellreply->status_data.status="F"))
      CALL echo("AP_HOLD: Failed ")
      SET scclerrmsg1 = getcclerrormsg(null)
      SET gsapeksmonitormsg = buildlogmsg(fail_cclerr,scclerrmsg1)
      SET retval = - (1)
     ELSE
      CALL echo("AP_HOLD: Execution Succeeded ")
      CALL echo(gsapeksmonitormsg)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SET gsapeksmonitormsg = buildlogmsg(fail_link,"")
   SET retval = - (1)
   GO TO endofscript
  ENDIF
 ELSE
  GO TO endofscript
 ENDIF
 GO TO endofscript
 SUBROUTINE buildshellrequest(null)
   CALL echo("AP_HOLD: Building ShellReq Method")
   SELECT INTO "nl:"
    FROM report_task rt,
     orders o,
     accession_order_r aor
    WHERE rt.order_id=dlink_orderid
     AND o.order_id=dlink_orderid
     AND aor.order_id=dlink_orderid
    DETAIL
     dhold_code = rt.hold_cd, dreport_id = rt.report_id, lupdt_cnt = rt.updt_cnt,
     dcommentltid = rt.hold_comment_long_text_id, personid = o.person_id, encntrid = o.encntr_id,
     orderid = o.order_id, accessionid = aor.accession_id
    WITH nocounter
   ;end select
   IF (apeksvalidateparam("HOLD_COMMENT",0))
    SET sholdcomment = trim(hold_comment)
   ELSEIF ((retval=- (1)))
    RETURN(- (1))
   ENDIF
   CALL setmsgstrings(null)
   IF (apeksvalidateparam("HOLD_REASON",0))
    SET orig_param = hold_reason
    EXECUTE eks_t_parse_list  WITH replace(reply,hold_reasonlist)
    FREE SET orig_param
    SET breasonblank = false
   ELSEIF ((retval=- (1)))
    RETURN(- (1))
   ELSE
    IF (cnvtupper(tname)="AP_CHANGE_REPORT_HOLD_A")
     SET breasonblank = true
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (bisaddtemp)
    IF ( NOT (bwasonhold))
     SET gsapeksmonitormsg = buildlogmsg(true_all,stailstr)
     CALL popreq(trim(sholdcomment),dreport_id,lupdt_cnt,0.0,0,
      cnvtreal(hold_reasonlist->qual[1].value))
    ELSE
     SET gsapeksmonitormsg = buildlogmsg(false_hashold,"")
     RETURN(0)
    ENDIF
   ELSE
    IF ( NOT (breasonblank))
     SET lltupdt_cnt = getltupdcnt(dcommentltid)
     CALL popreq(trim(sholdcomment),dreport_id,lupdt_cnt,dcommentltid,lltupdt_cnt,
      cnvtreal(hold_reasonlist->qual[1].value))
     IF (bwasonhold)
      SET gsapeksmonitormsg = buildlogmsg(true_change,stailstr)
     ELSE
      SET gsapeksmonitormsg = buildlogmsg(true_all,stailstr)
     ENDIF
    ELSE
     IF (bwasonhold)
      SET gsapeksmonitormsg = buildlogmsg(true_removed,sremovestr)
      SET lltupdt_cnt = getltupdcnt(dcommentltid)
      CALL popreq("",dreport_id,lupdt_cnt,dcommentltid,lltupdt_cnt,
       0.0)
     ELSE
      SET gsapeksmonitormsg = buildlogmsg(false_noreason,"")
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(100)
 END ;Subroutine
 SUBROUTINE (buildlogmsg(enumvar=i2,placeholder=vc) =vc WITH protect)
   CALL echo("AP_HOLD: Entering BuildLogMsg")
   DECLARE strmsg = vc WITH protect, noconstant("")
   IF (enumvar=true_all)
    SET strmsg = concat(trim(procedure1)," on accession ",gsapeksaccformatted,
     " assigned a hold reason of ",hold_reasonlist->qual[1].display,
     trim(placeholder))
   ELSEIF (enumvar=false_hashold)
    SET strmsg = concat("Report has hold reason of ",trim(uar_get_code_display(dhold_code)))
   ELSEIF (enumvar=fail_link)
    SET strmsg = "Invalid accession id from linked logic template."
   ELSEIF (enumvar=fail_cclerr)
    SET strmsg = concat("The following unexpected error occurred ",trim(placeholder))
   ELSEIF (enumvar=true_change)
    SET strmsg = concat(trim(procedure1)," on accession ",gsapeksaccformatted,
     " changed hold reason from ",trim(uar_get_code_display(dhold_code)),
     " to ",hold_reasonlist->qual[1].display,trim(placeholder))
   ELSEIF (enumvar=true_removed)
    SET strmsg = concat(trim(procedure1)," on accession ",gsapeksaccformatted,
     " removed hold reason of ",trim(uar_get_code_display(dhold_code)),
     trim(placeholder))
   ELSEIF (enumvar=false_noreason)
    SET strmsg = "Report has no hold reason to remove."
   ENDIF
   RETURN(strmsg)
 END ;Subroutine
 SUBROUTINE (popreq(scomment=vc,drptid=f8,lupdtcnt=i4,dcommentltid=f8,lltupdtcnt=i4,dholdreason=f8) =
  null WITH protect)
   CALL echo("AP_HOLD Populating ShellReq ")
   SET shellrequest->hold_comment = scomment
   SET shellrequest->report_id = drptid
   SET shellrequest->updt_cnt = lupdtcnt
   SET shellrequest->hold_comment_long_text_id = dcommentltid
   SET shellrequest->lt_updt_cnt = lltupdtcnt
   SET shellrequest->hold_cd = dholdreason
 END ;Subroutine
 SUBROUTINE getcclerrormsg(null)
   CALL echo("AP_HOLD: Entering GetCCLErrorMsg")
   DECLARE serror = vc WITH protect, noconstant("")
   IF (error(serror,0) > 0)
    RETURN(serror)
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE (getfullname(personid=f8) =vc WITH protect)
   CALL echo("AP_HOLD: Entering GetFullName")
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=personid
    DETAIL
     sfullname = p.name_full_formatted
    WITH nocounter
   ;end select
   RETURN(sfullname)
 END ;Subroutine
 SUBROUTINE (getltupdcnt(dltid=f8) =i4 WITH protect)
   CALL echo("AP_HOLD: Entering GetLTUpdCnt")
   SELECT INTO "nl:"
    FROM long_text lt
    WHERE lt.long_text_id=dltid
    DETAIL
     lltupdt_cnt = lt.updt_cnt
    WITH nocounter
   ;end select
   RETURN(lltupdt_cnt)
 END ;Subroutine
 SUBROUTINE setmsgstrings(null)
   CALL echo("AP_HOLD: Entering SetMsgStrings")
   IF (dhold_code > 0.0)
    SET bwasonhold = true
   ELSE
    SET bwasonhold = false
   ENDIF
   IF (cnvtupper(tname)="AP_ADD_REPORT_HOLD_A")
    SET bisaddtemp = true
   ELSE
    SET bisaddtemp = false
   ENDIF
   IF (textlen(trim(sholdcomment)) > 0)
    SET stailstr = " with hold comment"
   ELSE
    SET stailstr = "."
   ENDIF
   IF (dcommentltid > 0.0)
    SET sremovestr = " and removed hold comment."
   ELSE
    SET sremovestr = "."
   ENDIF
 END ;Subroutine
#endofscript
 SET eksdata->tqual[tcurindex].qual[curindex].logging = gsapeksmonitormsg
 SET rev_inc = "708"
 SET ininc = "eks_set_eksdata"
 IF (accessionid=0)
  IF (orderid != 0)
   SELECT INTO "NL:"
    a.accession_id
    FROM accession_order_r a
    WHERE a.order_id=orderid
     AND a.primary_flag=0
    DETAIL
     accessionid = a.accession_id
    WITH nocounter
   ;end select
  ELSEIF ( NOT (validate(accession,"Y")="Y"
   AND validate(accession,"Z")="Z"))
   IF (textlen(trim(accession)) > 0)
    SELECT INTO "NL:"
     a.accession_id
     FROM accession_order_r a
     WHERE a.accession=accession
     DETAIL
      accessionid = a.accession_id
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF (personid=0)
  FREE SET temp
  IF (orderid > 0)
   SELECT
    *
    FROM orders o
    WHERE o.order_id=orderid
    DETAIL
     personid = o.person_id
    WITH nocounter
   ;end select
  ELSEIF (encntrid > 0)
   SELECT
    *
    FROM encounter en
    WHERE en.encntr_id=encntrid
    DETAIL
     personid = en.person_id
    WITH nocounter
   ;end select
  ENDIF
  IF ( NOT (validate(temp,"Y")="Y"
   AND validate(temp,"Z")="Z"))
   SELECT INTO "nl:"
    o.person_id
    FROM orders o
    WHERE parser(temp)
    DETAIL
     personid = o.person_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET eksdata->tqual[tcurindex].qual[curindex].accession_id = accessionid
 SET eksdata->tqual[tcurindex].qual[curindex].order_id = orderid
 SET eksdata->tqual[tcurindex].qual[curindex].encntr_id = encntrid
 SET eksdata->tqual[tcurindex].qual[curindex].person_id = personid
 IF ( NOT (validate(ekstaskassaycd,0)=0
  AND validate(ekstaskassaycd,1)=1))
  SET eksdata->tqual[tcurindex].qual[curindex].task_assay_cd = ekstaskassaycd
 ELSE
  SET eksdata->tqual[tcurindex].qual[curindex].task_assay_cd = 0
 ENDIF
 IF ( NOT (validate(eksdata->tqual[tcurindex].qual[curindex].template_name,"Y")="Y"
  AND validate(eksdata->tqual[tcurindex].qual[curindex].template_name,"Z")="Z"))
  IF (trim(eksdata->tqual[tcurindex].qual[curindex].template_name)=""
   AND  NOT (validate(tname,"Y")="Y"
   AND validate(tname,"Z")="Z"))
   SET eksdata->tqual[tcurindex].qual[curindex].template_name = tname
  ENDIF
 ENDIF
 IF ( NOT (validate(eksce_id,0)=0
  AND validate(eksce_id,1)=1))
  IF ( NOT (validate(eksdata->tqual[tcurindex].qual[curindex].clinical_event_id,0)=0
   AND validate(eksdata->tqual[tcurindex].qual[curindex].clinical_event_id,1)=1))
   SET eksdata->tqual[tcurindex].qual[curindex].clinical_event_id = eksce_id
  ENDIF
 ENDIF
 FREE RECORD shellrequest
END GO
