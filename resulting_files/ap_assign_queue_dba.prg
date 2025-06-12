CREATE PROGRAM ap_assign_queue:dba
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
 DECLARE assign_to_new_queue() = null WITH protect
 DECLARE assign_to_existing_queue(queue_cd=f8) = null WITH protect
 DECLARE unassign_from_existing_queue(queue_cd=i4) = null WITH protect
 DECLARE exe_core_script() = null WITH protect
 DECLARE main() = null WITH protect
 DECLARE echo_result_info() = null WITH protect
 DECLARE write_to_eks_monitor() = null WITH protect
 DECLARE unexpected_error_msg = vc WITH protect, constant("The following unexpected error occurred: "
  )
 FREE RECORD core_script_req
 RECORD core_script_req(
   1 qual[1]
     2 report_queue_cd = f8
     2 report_queue_name = vc
     2 updt_cnt = i4
     2 action = c1
     2 add_cnt = i4
     2 add_qual[1]
       3 report_id = f8
       3 report_sequence = i4
     2 chg_cnt = i4
     2 chg_qual[1]
       3 report_id = f8
       3 report_sequence = i4
       3 updt_cnt = i4
     2 del_cnt = i4
     2 del_qual[1]
       3 report_id = f8
 ) WITH protect
 FREE RECORD core_script_rep
 RECORD core_script_rep(
   1 code_value = f8
   1 exception_data[1]
     2 report_queue_cd = f8
     2 report_queue_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL main(null)
 CALL write_to_eks_monitor(null)
 SUBROUTINE main(null)
   SET retval = 0
   IF ( NOT (apeksvalidateparam("PROCEDURE",0)))
    SET retval = - (1)
    RETURN
   ENDIF
   IF ( NOT (apeksvalidateparam("LINK",1)))
    SET retval = - (1)
    RETURN
   ENDIF
   IF ( NOT (apeksvalidateparam("REPORT_QUEUE",0)))
    SET retval = - (1)
    RETURN
   ENDIF
   DECLARE queue_match_cnt = i4 WITH private
   DECLARE queue_cd = f8 WITH protect
   DECLARE queue_updt_cnt = i4 WITH protect
   DECLARE queue_display_key = vc WITH private, constant(trim(cnvtupper(cnvtalphanum(report_queue))))
   DECLARE report_id = f8 WITH protect
   DECLARE report_sequence = i4 WITH protect
   SET queue_match_cnt = get_queue(queue_display_key,queue_cd,queue_updt_cnt)
   IF (queue_match_cnt > 1)
    SET gsapeksmonitormsg = build2(unexpected_error_msg,"Multiple queues found matching the name ",
     report_queue)
    RETURN
   ENDIF
   IF (build_core_script_req(report_id,report_sequence))
    CASE (tname)
     OF "AP_ASSIGN_QUEUE_A":
      SET core_script_req->qual[1].add_cnt = 1
      SET core_script_req->qual[1].add_qual.report_id = report_id
      SET core_script_req->qual[1].add_qual.report_sequence = report_sequence
      CASE (queue_match_cnt)
       OF 0:
        SET core_script_req->qual[1].action = "A"
        CALL exe_core_script(null)
       OF 1:
        IF ( NOT (report_is_on_queue(report_id,queue_cd)))
         SET core_script_req->qual[1].report_queue_cd = queue_cd
         CALL exe_core_script(null)
        ELSE
         SET gsapeksmonitormsg = build2("Report is already on queue ",report_queue)
        ENDIF
      ENDCASE
     OF "AP_UNASSIGN_QUEUE_A":
      CASE (queue_match_cnt)
       OF 0:
        SET gsapeksmonitormsg = build2(unexpected_error_msg," No queue matching ",report_queue)
       OF 1:
        IF (report_is_on_queue(report_id,queue_cd))
         SET core_script_req->qual[1].report_queue_cd = queue_cd
         SET core_script_req->qual[1].del_cnt = 1
         SET core_script_req->qual[1].del_qual.report_id = report_id
         CALL exe_core_script(null)
        ELSE
         SET gsapeksmonitormsg = build2("Report is not assigned to ",report_queue)
        ENDIF
      ENDCASE
     ELSE
      SET gsapeksmonitormsg = build2(unexpected_error_msg," Invalid parameter value for tname ",tname
       )
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_queue(queue_display_key=vc,queue_cd=f8(ref),queue_updt_cnt=i4(ref)) =i4 WITH protect
  )
   DECLARE match_cnt = i4 WITH protect
   SELECT
    FROM code_value cv
    WHERE cv.code_set=1319
     AND cv.display_key=queue_display_key
     AND cv.code_value > 0.0
    HEAD REPORT
     match_cnt = 0
    DETAIL
     match_cnt += 1, queue_cd = cv.code_value, queue_updt_cnt = cv.updt_cnt
    WITH nocounter
   ;end select
   RETURN(match_cnt)
 END ;Subroutine
 SUBROUTINE (report_is_on_queue(report_id=f8,queue_cd=f8) =i4 WITH protect)
   DECLARE return_val = i4 WITH protect
   SELECT
    FROM report_queue_r rqr
    WHERE rqr.report_id=report_id
     AND rqr.report_queue_cd=queue_cd
    HEAD REPORT
     return_val = 0
    DETAIL
     return_val = 1
    WITH nocounter
   ;end select
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE exe_core_script(null)
   DECLARE sccl_error_msg = vc WITH protect
   EXECUTE aps_chg_report_queue  WITH replace("REQUEST","CORE_SCRIPT_REQ"), replace("REPLY",
    "CORE_SCRIPT_REP")
   CASE (core_script_rep->status_data.status)
    OF "S":
     SET retval = 100
     CASE (tname)
      OF "AP_ASSIGN_QUEUE_A":
       SET gsapeksmonitormsg = build2(procedure," on ",gsapeksaccformatted," assigned to ",
        report_queue)
      ELSE
       SET gsapeksmonitormsg = build2(procedure," on ",gsapeksaccformatted," removed from ",
        report_queue)
     ENDCASE
    ELSE
     SET retval = - (1)
     CALL error(sccl_error_msg,0)
     SET gsapeksmonitormsg = build2(unexpected_error_msg,sccl_error_msg)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (build_core_script_req(report_id=f8(ref),report_sequence=i4(ref)) =i4 WITH protect)
   DECLARE report_cnt = i4 WITH protect
   DECLARE report_order_status_cd = f8 WITH protect
   SET report_order_id = apeksgetactionorderid(procedure,cnvtint(link))
   IF (report_order_id <= 0.0)
    RETURN(0)
   ENDIF
   SELECT
    FROM report_task rt,
     case_report cr,
     orders o
    PLAN (rt
     WHERE rt.order_id=report_order_id)
     JOIN (cr
     WHERE cr.report_id=rt.report_id)
     JOIN (o
     WHERE o.order_id=rt.order_id)
    HEAD REPORT
     report_cnt = 0
    DETAIL
     report_cnt += 1, report_order_status_cd = cr.status_cd, report_id = rt.report_id,
     report_sequence = cr.report_sequence, report_order_status_cd = cr.status_cd, personid = o
     .person_id,
     orderid = o.order_id, accessionid = cr.case_id, encntrid = o.encntr_id
    WITH nocounter
   ;end select
   IF (report_cnt != 1)
    SET gsapeksmonitormsg = build2(unexpected_error_msg," Could not find report")
    RETURN(0)
   ENDIF
   IF (report_in_final_status(report_order_status_cd))
    SET gsapeksmonitormsg = build2("Report is in an end state status of ",trim(uar_get_code_display(
       report_order_status_cd)))
    RETURN(0)
   ENDIF
   SET core_script_req->qual[1].report_queue_name = report_queue
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (report_in_final_status(report_order_status_cd=f8) =i4 WITH protect)
   DECLARE verified_cd = f8 WITH private, constant(uar_get_code_by("MEANING",1305,"VERIFIED"))
   DECLARE canceled_cd = f8 WITH private, constant(uar_get_code_by("MEANING",1305,"CANCEL"))
   DECLARE corrected_cd = f8 WITH private, constant(uar_get_code_by("MEANING",1305,"CORRECTED"))
   DECLARE signinproc_cd = f8 WITH private, constant(uar_get_code_by("MEANING",1305,"SIGNINPROC"))
   DECLARE csigninproc_cd = f8 WITH private, constant(uar_get_code_by("MEANING",1305,"CSIGNINPROC"))
   IF (report_order_status_cd=verified_cd)
    RETURN(1)
   ENDIF
   IF (report_order_status_cd=canceled_cd)
    RETURN(1)
   ENDIF
   IF (report_order_status_cd=corrected_cd)
    RETURN(1)
   ENDIF
   IF (report_order_status_cd=signinproc_cd)
    RETURN(1)
   ENDIF
   IF (report_order_status_cd=csigninproc_cd)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE write_to_eks_monitor(null)
   IF (size(trim(eksdata->tqual[tcurindex].qual[curindex].logging))=0
    AND size(trim(gsapeksmonitormsg)) > 0)
    SET eksdata->tqual[tcurindex].qual[curindex].logging = gsapeksmonitormsg
   ENDIF
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
 END ;Subroutine
 SUBROUTINE echo_result_info(null)
   CALL echorecord(eksdata)
   CALL echorecord(core_script_req)
   CALL echorecord(core_script_rep)
   CALL echo(build2("retval: ",retval))
 END ;Subroutine
END GO
