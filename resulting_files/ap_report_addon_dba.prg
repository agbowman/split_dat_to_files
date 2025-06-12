CREATE PROGRAM ap_report_addon:dba
 DECLARE laps_add_pathology_report_req = i4 WITH constant(200019), protect
 DECLARE happ = i4 WITH noconstant(0), protect
 DECLARE htask = i4 WITH noconstant(0), protect
 DECLARE hstep = i4 WITH noconstant(0), protect
 DECLARE hrequest = i4 WITH noconstant(0), protect
 DECLARE hreply = i4 WITH noconstant(0), protect
 DECLARE hstatus = i4 WITH noconstant(0), protect
 DECLARE sstatus = c1 WITH noconstant(" "), protect
 DECLARE horder = i4 WITH noconstant(0), protect
 DECLARE gistat = i2 WITH protect, noconstant(0)
 DECLARE nfound = i2 WITH protect, noconstant(0)
 DECLARE nprimary = i2 WITH protect, noconstant(0)
 DECLARE nmultiples = i2 WITH protect, noconstant(1)
 DECLARE nexitscript = i2 WITH protect, noconstant(0)
 DECLARE saccession = vc WITH protect, noconstant(" ")
 DECLARE dprimarycatalogcd = f8 WITH protect, noconstant(0.0)
 DECLARE sprocedure = vc WITH protect, noconstant(" ")
 DECLARE nendappind = i2 WITH noconstant(0), protect
 DECLARE ncommentexists = i2 WITH noconstant(0), protect
 DECLARE script_fail = c1 WITH protect, constant("F")
 DECLARE script_zero = c1 WITH protect, constant("Z")
 SET dprioritycd = uar_get_code_by("MEANING",1905,"2")
 SET retval = 0
 SET rev_prg = "7.8"
 IF (validate(tname))
  SET tname = "UNKNOWN"
 ENDIF
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
 RECORD req(
   1 case_id = f8
   1 report_catalog_cd = f8
   1 processing_location_cd = f8
 ) WITH protect
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF ( NOT (apeksvalidateparam("PROCEDURE1",0)))
  GO TO exit_script
 ENDIF
 IF ( NOT (apeksvalidateparam("LINK",1)))
  GO TO exit_script
 ENDIF
 IF (apeksvalidateparam("COMMENT",0))
  SET ncommentexists = 1
 ENDIF
 CALL echo(concat(format(cnvtdatetime(sysdate),";;Q"),"  Beginning program ",cnvtlower(curprog),
   " at rev level ",rev_prg),1,10)
 CALL echo(concat("Add procedure *",procedure1,"* to template number ",trim(link),
   "'s accession with no change to the original order parameters "),1,0)
 IF (ncommentexists)
  CALL echo(concat("and include the following order comment: '",trim(comment),"'"),1,0)
 ENDIF
 SET reccnt = size(eksdata->tqual[tinx].qual,5)
 SET link_indx = cnvtint(link)
 IF ( NOT (link_indx BETWEEN 1 AND reccnt))
  SET msg = "Invalid accession id from linked logic template."
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 IF ((eksdata->tqual[tinx].qual[link_indx].accession_id <= 0))
  SET msg = "No accession id specified in linked logic template "
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 SET rev_inc = "708"
 FREE SET ininc
 SET ininc = "eks_comvariables"
 DECLARE accessionid = f8
 DECLARE orderid = f8
 DECLARE encntrid = f8
 DECLARE personid = f8
 DECLARE ekstaskassaycd = f8
 DECLARE eksce_id = f8
 SET accessionid = 0
 SET orderid = 0
 SET encntrid = 0
 SET personid = 0
 SET ekstaskassaycd = 0
 SET eksce_id = 0
 DECLARE accession = c20
 SET accession = ""
 DECLARE inx = i4
 SET inx = 0
 DECLARE cbinx = i4
 SET cbinx = 0
 DECLARE msg = c200
 SET msg = ""
 SET okreturn = 1
 SET retval = 0
 SET errormsg = fillstring(255," ")
 IF (validate(ekmlog_ind,0)=0
  AND validate(ekmlog_ind,1)=1)
  SET ekmlog_ind = 1
 ENDIF
 SET eksmsgwrite = 1
 IF ( NOT (validate(inprogram,1)=1
  AND validate(inprogram,0)=0))
  IF (inprogram)
   SET eksmsgwrite = 0
  ENDIF
 ENDIF
 SET orderid = eksdata->tqual[tinx].qual[link_indx].order_id
 SET accessionid = eksdata->tqual[tinx].qual[link_indx].accession_id
 SET personid = eksdata->tqual[tinx].qual[link_indx].person_id
 SET encntrid = eksdata->tqual[tinx].qual[link_indx].encntr_id
 CALL echo("",1,0)
 CALL echo("Values available from linked template are set as:",1,0)
 CALL echo(concat("Order_id set as (variable: orderid): ",build(orderid)),1,0)
 CALL echo(concat("Accession_id set as (variable: accessionid): ",build(accessionid)),1,0)
 SET sprocedure = trim(procedure1)
 SELECT INTO "nl:"
  FROM order_catalog oc,
   orc_resource_list orl
  PLAN (oc
   WHERE oc.primary_mnemonic=sprocedure)
   JOIN (orl
   WHERE orl.catalog_cd=oc.catalog_cd
    AND orl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND orl.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND orl.primary_ind=1
    AND orl.active_ind=1)
  ORDER BY oc.primary_mnemonic
  HEAD oc.primary_mnemonic
   req->report_catalog_cd = oc.catalog_cd, req->processing_location_cd = orl.service_resource_cd
  WITH nocounter
 ;end select
 SET nfound = 0
 SELECT INTO "nl:"
  FROM pathology_case pc
  WHERE pc.case_id=accessionid
  DETAIL
   nfound = 1
  WITH nocounter
 ;end select
 IF (nfound=0)
  SET msg = concat("No pathology case found on accession ",trim(cnvtacc(saccession)),".")
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  GO TO exit_script
 ENDIF
 SET nfound = 0
 SET nprimary = 0
 SELECT INTO "nl:"
  FROM pathology_case pc,
   prefix_report_r pr
  PLAN (pc
   WHERE pc.case_id=accessionid)
   JOIN (pr
   WHERE pr.prefix_id=pc.prefix_id)
  ORDER BY pr.catalog_cd
  HEAD pr.catalog_cd
   saccession = pc.accession_nbr
   IF (pr.primary_ind=1
    AND (pr.catalog_cd=req->report_catalog_cd))
    nprimary = 1
   ELSEIF (pr.primary_ind=1)
    dprimarycatalogcd = pr.catalog_cd
   ELSEIF ((pr.catalog_cd=req->report_catalog_cd))
    nfound = 1
   ENDIF
   IF ((pr.catalog_cd=req->report_catalog_cd))
    nmultiples = pr.mult_allowed_ind
   ENDIF
  WITH nocounter
 ;end select
 IF (nprimary=1)
  SET msg = concat(procedure1," is a primary report and already exists on ",trim(cnvtacc(saccession)),
   ".")
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  GO TO exit_script
 ENDIF
 IF (nfound=0)
  SET msg = concat(procedure1," not valid for ",trim(cnvtacc(saccession)),
   " in Prefix Report Association Tool.")
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  GO TO exit_script
 ENDIF
 IF (nmultiples=0)
  SET nexitscript = 0
  SELECT INTO "nl:"
   FROM case_report cr
   WHERE cr.case_id=accessionid
    AND (cr.catalog_cd=req->report_catalog_cd)
   DETAIL
    nexitscript = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (nexitscript=1)
  SET msg = concat(procedure1," does not allow multiples and it already exists on ",trim(cnvtacc(
     saccession)),".")
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  GO TO exit_script
 ENDIF
 CALL echo("get app")
 SET happ = uar_crmgetapphandle()
 IF (happ=0)
  SET msg = concat("StartRequest: ",build("Unable to get the app handle",gistat))
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  SET gistat = uar_crmbeginapp(200055,happ)
  IF (gistat > 0)
   SET msg = concat("Starting Request: ",build("Unable to begin app : ",gistat))
   SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
   CALL echo(msg,1,0)
   SET retval = - (1)
   GO TO exit_script
  ENDIF
  SET nendappind = 1
 ENDIF
 SET gistat = uar_crmbegintask(happ,200358,htask)
 IF (gistat > 0)
  SET msg = concat("Starting Request: ",build("Error beginning task: ",gistat))
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 SET gistat = uar_crmbeginreq(htask,"",laps_add_pathology_report_req,hstep)
 IF (gistat > 0)
  SET msg = concat("Starting Request",build("Error beginning step: ",gistat))
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  IF (htask > 0)
   CALL uar_crmendtask(htask)
  ENDIF
 ENDIF
 SET hrequest = uar_crmgetrequest(hstep)
 SET nfound = 0
 SELECT INTO "nl:"
  FROM case_report cr,
   report_task rt
  PLAN (cr
   WHERE cr.case_id=accessionid)
   JOIN (rt
   WHERE rt.report_id=cr.report_id)
  ORDER BY cr.request_dt_tm DESC
  DETAIL
   IF (((cr.catalog_cd=dprimarycatalogcd) OR (nfound=0)) )
    nfound = 1, dprioritycd = rt.priority_cd
   ENDIF
  WITH nocounter
 ;end select
 SET gistat = uar_srvsetdouble(hrequest,"case_id",accessionid)
 SET horder = uar_srvadditem(hrequest,"report_qual")
 SET gistat = uar_srvsetdouble(horder,"report_catalog_cd",req->report_catalog_cd)
 SET gistat = uar_srvsetdouble(horder,"processing_location_cd",req->processing_location_cd)
 SET gistat = uar_srvsetdouble(horder,"responsible_pathologist_id",0.0)
 SET gistat = uar_srvsetdouble(horder,"responsible_resident_id",0.0)
 SET gistat = uar_srvsetdouble(horder,"request_priority_cd",dprioritycd)
 SET gistat = uar_srvsetstring(horder,"request_priority_disp",nullterm(uar_get_code_display(
    dprioritycd)))
 SET gistat = uar_srvsetdate(horder,"request_dt_tm",cnvtdatetime(sysdate))
 SET gistat = uar_srvsetdouble(horder,"comments_long_text_id",0.0)
 IF (ncommentexists)
  SET gistat = uar_srvsetstring(horder,"comments",nullterm(trim(comment)))
 ENDIF
 SET gistat = uar_srvsetlong(horder,"lt_updt_cnt",0)
 IF (validate(ucm_debug_ind,0))
  CALL uar_crmlogmessage(hrequest,"req200019.dat")
 ENDIF
 CALL echo("Performing call")
 SET gistat = uar_crmperform(hstep)
 IF (gistat > 0)
  SET msg = concat("Placing Orders: ",build("Error performing request: ",gistat))
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  GO TO exit_script
 ENDIF
 SET hreply = uar_crmgetreply(hstep)
 IF (validate(ucm_debug_ind,0))
  CALL uar_crmlogmessage(hreply,"rep200019.dat")
 ENDIF
 SET hstatus = uar_srvgetstruct(hreply,"status_data")
 SET sstatus = uar_srvgetstringptr(hstatus,"status")
 IF (((sstatus=script_fail) OR (sstatus=script_zero)) )
  SET reply->status_data.status = sstatus
  SET msg = concat("APS_ADD_PATHOLOGY REPORT: ",build("Error performing request: ",sstatus))
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
  CALL echo(msg,1,0)
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 IF (ncommentexists)
  SET msg = concat("Submitted ",procedure1," add on to ",trim(cnvtacc(saccession)),
   " with report comment.")
 ELSE
  SET msg = concat("Submitted ",procedure1," add on to ",trim(cnvtacc(saccession)),".")
 ENDIF
 CALL echo(concat(format(cnvtdatetime(sysdate),";;Q"),"  ",msg),1,0)
 SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
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
 SET retval = 100
 SET modify = hipaa
 EXECUTE cclaudit 1, "Anatomic Pathology Modify", "Maintain Case",
 "Person", "Patient", "Patient",
 "Access/Use", personid, ""
 EXECUTE cclaudit 3, "Anatomic Pathology Modify", "Maintain Case",
 "Person", "Patient", "PathCase",
 "Access/Use", accessionid, cnvtacc(saccession)
#exit_script
 IF (size(trim(msg))=0
  AND size(trim(gsapeksmonitormsg)) > 0)
  SET msg = concat("APEKSValidateParam Msg: ",gsapeksmonitormsg)
  CALL echo(msg)
  SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
 ENDIF
 FREE RECORD req
 IF (hstep > 0)
  CALL uar_crmendreq(hstep)
 ENDIF
 IF (htask > 0)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (nendappind=1)
  CALL uar_crmendapp(happ)
 ENDIF
END GO
