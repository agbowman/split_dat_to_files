CREATE PROGRAM ap_orders_find:dba
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of Program AP_ORDERS_FIND.  *********"))
 FREE RECORD opt_order_statuslist
 RECORD opt_order_statuslist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 ) WITH protect
 FREE RECORD opt_hold_reasonlist
 RECORD opt_hold_reasonlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 ) WITH protect
 FREE RECORD scope_flags
 RECORD scope_flags(
   1 qual[4]
     2 name = vc
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
 DECLARE nscope_patient = i2 WITH protect, constant(0)
 DECLARE nscope_accession = i2 WITH protect, constant(1)
 DECLARE nscope_encounter = i2 WITH protect, constant(2)
 DECLARE nscope_order_order = i2 WITH protect, constant(3)
 DECLARE nscope_request_id = i2 WITH protect, constant(4)
 SET scope_flags->qual[nscope_accession].name = "the same accession as"
 SET scope_flags->qual[nscope_encounter].name = "the same encounter as"
 SET scope_flags->qual[nscope_order_order].name = "the same order-order relation as"
 SET scope_flags->qual[nscope_request_id].name = "the same request id as"
 DECLARE scs_mean = vc WITH protect, constant("MEANING")
 DECLARE lcatalog_type_cs = i4 WITH protect, constant(6000)
 DECLARE dcat_type_glb = f8 WITH protect, constant(uar_get_code_by(nullterm(scs_mean),
   lcatalog_type_cs,nullterm("GENERAL LAB")))
 DECLARE lact_type_cs = i4 WITH protect, constant(106)
 DECLARE dact_type_ap = f8 WITH protect, constant(uar_get_code_by(nullterm(scs_mean),lact_type_cs,
   nullterm("AP")))
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE encntrid = f8 WITH protect, noconstant(0.0)
 DECLARE orderid = f8 WITH protect, noconstant(0.0)
 DECLARE accessionid = f8 WITH protect, noconstant(0.0)
 DECLARE link_encntrid = f8 WITH protect, noconstant(0.0)
 DECLARE link_orderid = f8 WITH protect, noconstant(0.0)
 DECLARE link_accessionid = f8 WITH protect, noconstant(0.0)
 DECLARE dstarttime = f8 WITH protect, noconstant(0.0)
 DECLARE seksmonitormsg = vc WITH protect, noconstant("")
 DECLARE sowhere = vc WITH protect, noconstant("")
 DECLARE socwhere = vc WITH protect, noconstant("")
 DECLARE saorwhere = vc WITH protect, noconstant("")
 DECLARE leidx = i4 WITH protect, noconstant(0)
 DECLARE lndx1 = i4 WITH protect, noconstant(0)
 DECLARE nlink = i2 WITH protect, noconstant(0)
 DECLARE nscopeflag = i2 WITH protect, noconstant(0)
 DECLARE ldatacnt = i4 WITH protect, noconstant(0)
 SET dstarttime = curtime3
 SET sowhere =
 "o.person_id = personid and o.catalog_type_cd = dCAT_TYPE_GLB and o.activity_type_cd+0 = dACT_TYPE_AP"
 SET socwhere = "oc.catalog_cd = o.catalog_cd"
 SET saorwhere = "aor.order_id = o.order_id and aor.primary_flag = 0"
 IF (apeksvalidateparam("OPT_PROCEDURE",0))
  SET socwhere = concat(socwhere," and oc.primary_mnemonic = OPT_PROCEDURE")
 ELSEIF ((retval=- (1)))
  GO TO endprogram
 ENDIF
 IF (apeksvalidateparam("OPT_ORDER_STATUS",0))
  SET orig_param = opt_order_status
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_order_statuslist)
  FREE SET orig_param
  CALL echorecord(opt_order_statuslist)
  IF ((opt_order_statuslist->cnt > 0))
   SET sowhere = build(sowhere," and o.order_status_cd+0 in (",opt_order_statuslist->qual[1].value)
   FOR (lndx1 = 2 TO opt_order_statuslist->cnt)
     SET sowhere = build(sowhere,",",opt_order_statuslist->qual[lndx1].value)
   ENDFOR
   SET sowhere = build(sowhere,")")
  ENDIF
 ELSEIF ((retval=- (1)))
  GO TO endprogram
 ENDIF
 IF (apeksvalidateparam("OPT_SCOPE",0))
  FOR (lndx1 = 1 TO size(scope_flags->qual,5))
    IF ((cnvtlower(trim(opt_scope))=scope_flags->qual[lndx1].name))
     SET nscopeflag = lndx1
    ENDIF
  ENDFOR
 ELSEIF ((retval=- (1)))
  GO TO endprogram
 ENDIF
 IF (apeksvalidateparam("OPT_LINK",1))
  SET nlink = cnvtint(trim(opt_link))
  IF (((nlink=curindex) OR (nlink > size(eksdata->tqual[tinx].qual,5))) )
   SET seksmonitormsg = unexpectederr(concat("OPT_LINK value of ",trim(opt_link)," is invalid."))
   SET retval = - (1)
   GO TO endprogram
  ELSEIF (nlink > 0)
   SET personid = eksdata->tqual[tcurindex].qual[nlink].person_id
   SET link_encntrid = eksdata->tqual[tcurindex].qual[nlink].encntr_id
   SET link_accessionid = eksdata->tqual[tcurindex].qual[nlink].accession_id
   SET link_orderid = eksdata->tqual[tcurindex].qual[nlink].order_id
   CASE (nscopeflag)
    OF nscope_encounter:
     IF (link_encntrid <= 0)
      SET seksmonitormsg = "Invalid ENCOUNTER_ID from the linked logic template."
      SET retval = - (1)
      GO TO endprogram
     ENDIF
     SET sowhere = build(sowhere," and o.encntr_id+0 = link_encntrid")
    OF nscope_accession:
     IF (link_accessionid <= 0)
      SET seksmonitormsg = "Invalid ACCESSION_ID from the linked logic template."
      SET retval = - (1)
      GO TO endprogram
     ENDIF
     SET saorwhere = concat(saorwhere," and aor.accession_id = link_accessionid")
    OF nscope_order_order:
     IF (link_orderid <= 0)
      SET seksmonitormsg = "Invalid ORDER_ID from the linked logic template."
      SET retval = - (1)
      GO TO endprogram
     ENDIF
     SET sowhere = build(sowhere," and ((exists (",
      "select oor.order_order_reltn_id from order_order_reltn oor",
      " where oor.related_from_order_id = o.order_id"," and oor.related_to_order_id = link_orderid))"
      )
     SET sowhere = build(sowhere," or (exists (",
      "select oor.order_order_reltn_id from order_order_reltn oor",
      " where oor.related_from_order_id = link_orderid",
      " and oor.related_to_order_id = o.order_id)))")
    OF nscope_request_id:
     IF (link_orderid <= 0)
      SET seksmonitormsg = "Invalid ORDER_ID from the linked logic template."
      SET retval = - (1)
      GO TO endprogram
     ENDIF
     SET sowhere = build(sowhere," and (exists (",
      "select oror.ord_rqstn_ord_r_id from ord_rqstn_ord_r oror, ord_rqstn_ord_r oror2",
      " where oror.order_id = o.order_id"," and oror2.order_id = link_orderid",
      " and oror2.ord_rqstn_id = oror.ord_rqstn_id))")
   ENDCASE
  ENDIF
 ELSEIF ((retval=- (1)))
  GO TO endprogram
 ENDIF
 IF (personid=0.0)
  SET personid = event->qual[eks_common->event_repeat_index].person_id
 ENDIF
 IF (nscopeflag > 0
  AND nlink=0)
  SET seksmonitormsg = unexpectederr("OPT_LINK should not be empty since OPT_SCOPE is present.")
  SET retval = - (1)
  GO TO endprogram
 ENDIF
 IF (apeksvalidateparam("OPT_REPORT_QUEUE",0))
  SET sowhere = build(sowhere," and (exists (",
   "select rt.report_id from report_task rt, report_queue_r rqr, code_value cv",
   " where rt.order_id = o.order_id"," and rqr.report_id = rt.report_id",
   " and cv.code_set = 1319 and cv.code_value = rqr.report_queue_cd",
   " and cnvtupper(cv.display) = cnvtupper(OPT_REPORT_QUEUE)))")
 ELSEIF ((retval=- (1)))
  GO TO endprogram
 ENDIF
 IF (apeksvalidateparam("OPT_HOLD_REASON",0))
  SET orig_param = opt_hold_reason
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_hold_reasonlist)
  FREE SET orig_param
  CALL echorecord(opt_hold_reasonlist)
  IF ((opt_hold_reasonlist->cnt > 0))
   SET sowhere = build(sowhere," and (exists (","select rt.report_id from report_task rt",
    " where rt.order_id = o.order_id")
   SET sowhere = build(sowhere," and rt.hold_cd+0 in (",opt_hold_reasonlist->qual[1].value)
   FOR (lndx1 = 2 TO opt_hold_reasonlist->cnt)
     SET sowhere = build(sowhere,",",opt_hold_reasonlist->qual[lndx1].value)
   ENDFOR
   SET sowhere = build(sowhere,")))")
  ENDIF
 ELSEIF ((retval=- (1)))
  GO TO endprogram
 ENDIF
 IF (personid <= 0.0)
  SET retval = - (1)
  SET seksmonitormsg = "Invalid PERSON_ID from the linked logic template."
  GO TO endprogram
 ENDIF
 CALL echo(build("sOWhere:",sowhere))
 CALL echo(build("sOCWhere:",socwhere))
 CALL echo(build("sAORWhere:",saorwhere))
 SET ldatacnt = 1
 SET stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,ldatacnt)
 SET eksdata->tqual[tcurindex].qual[curindex].data[ldatacnt].misc = "<ORDER_ID>"
 SELECT INTO "nl:"
  FROM orders o,
   order_catalog oc,
   accession_order_r aor
  PLAN (o
   WHERE parser(sowhere))
   JOIN (oc
   WHERE parser(socwhere))
   JOIN (aor
   WHERE parser(saorwhere))
  ORDER BY o.orig_order_dt_tm DESC
  DETAIL
   IF (ldatacnt=1)
    orderid = o.order_id, accessionid = aor.accession_id, encntrid = o.encntr_id
   ENDIF
   ldatacnt += 1, stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,ldatacnt), eksdata->
   tqual[tcurindex].qual[curindex].data[ldatacnt].misc = trim(cnvtstring(o.order_id,25,1))
  WITH nocounter
 ;end select
 IF (ldatacnt > 1)
  SET eksdata->tqual[tcurindex].qual[curindex].cnt = (ldatacnt - 1)
  SET seksmonitormsg = build2(trim(cnvtstring((ldatacnt - 1),7))," orders were found.")
  SET retval = 100
 ELSE
  SET seksmonitormsg = "No orders were found."
  SET retval = 0
 ENDIF
 SUBROUTINE (unexpectederr(serrmsg=vc) =vc WITH protect)
   DECLARE sunexpectederr = vc WITH protect, noconstant("")
   SET sunexpectederr = concat("Unexpected error occurred: ",trim(serrmsg,3))
   RETURN(sunexpectederr)
 END ;Subroutine
#endprogram
 IF (size(trim(seksmonitormsg))=0
  AND size(trim(gsapeksmonitormsg)) > 0)
  SET seksmonitormsg = gsapeksmonitormsg
 ENDIF
 SET seksmonitormsg = concat(seksmonitormsg," (",trim(format(((curtime3 - dstarttime)/ 100.0),
    "######.##"),3),"s)")
 CALL echo(seksmonitormsg)
 SET eksdata->tqual[tcurindex].qual[curindex].logging = seksmonitormsg
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
 CALL echorecord(eksdata)
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  End of Program AP_ORDERS_FIND.  *********"))
 FREE RECORD opt_order_statuslist
 FREE RECORD opt_hold_reasonlist
 FREE RECORD scope_flags
END GO
