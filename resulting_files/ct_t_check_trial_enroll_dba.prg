CREATE PROGRAM ct_t_check_trial_enroll:dba
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE encounterid = f8 WITH protect, noconstant(0.0)
 DECLARE protocolmsg = vc WITH protect
 DECLARE enrollprotcnt = i2 WITH protect, noconstant(0)
 DECLARE protlist = vc WITH protect
 DECLARE loggingmsg = vc WITH protect
 DECLARE prot_amd_list_cnt = i2 WITH protect, noconstant(0)
 DECLARE protocol_cnt = i2 WITH protect, noconstant(0)
 DECLARE amendment_cnt = i2 WITH protect, noconstant(0)
 DECLARE argsize = i2 WITH protect, noconstant(0)
 DECLARE nposition = i2 WITH protect, noconstant(0)
 DECLARE amdlength = i2 WITH protect, noconstant(0)
 DECLARE protlength = i2 WITH protect, noconstant(0)
 DECLARE nsecondpos = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE cnt2 = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE nanyprotocolposition = i2 WITH protect, noconstant(0)
 RECORD enroll_list(
   1 any_prot_ind = i2
   1 protocols[*]
     2 prot_master_id = f8
     2 prot_name = vc
   1 amendments[*]
     2 prot_amendment_id = f8
     2 amendment_name = vc
     2 prot_name = vc
 )
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
 CALL echo(build("tcurindex is:",tcurindex))
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of Program ct_t_check_trial_enroll  *********"))
 IF (validate(protocol_amd)=0)
  SET protocolmsg = "Required variable, PROTOCOL_AMD, does not exist"
  SET retval = - (1)
  GO TO end_of_program
 ENDIF
 IF (validate(opt_link)=0)
  CALL echo("OPT_LINK variable does not exist.  It will be ignored")
 ELSEIF ( NOT (isnumeric(opt_link)))
  CALL echo(concat("OPT_LINK value of ",opt_link," is not numeric.  It will be ignored"))
 ELSEIF (((cnvtint(opt_link) <= 0) OR (cnvtint(opt_link) >= curindex)) )
  SET protocolmsg = concat(opt_link," is not a valid OPT_LINK value for CT_CHK_TRIAL_ENROLL_L")
  SET retval = - (1)
  GO TO end_of_program
 ELSE
  SET personid = eksdata->tqual[tcurindex].qual[cnvtint(opt_link)].person_id
  SET encounterid = eksdata->tqual[tcurindex].qual[cnvtint(opt_link)].encntr_id
  IF (personid <= 0)
   SET protocolmsg = concat("Logic Template ",opt_link," did not set a valid personId")
   SET retval = 0
   GO TO end_of_program
  ENDIF
  CALL echo(concat("Link personId is ",build(personid)))
 ENDIF
 IF (personid <= 0)
  IF (validate(event->qual)=0)
   SET protocolmsg = concat("OPT_LINK must be used for the ",eksevent," event")
   SET retval = - (1)
   GO TO end_of_program
  ELSEIF ((event->qual[eks_common->event_repeat_index].person_id > 0))
   SET personid = event->qual[eks_common->event_repeat_index].person_id
   SET encounterid = event->qual[eks_common->event_repeat_index].encntr_id
  ELSE
   SET protocolmsg = "Invalid personId found in the event structure"
   SET retval = 0
   GO TO end_of_program
  ENDIF
 ENDIF
 FREE RECORD protocol_amdlist
 RECORD protocol_amdlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 SET orig_param = protocol_amd
 EXECUTE eks_t_parse_list  WITH replace(reply,protocol_amdlist)
 FREE SET orig_param
 SET prot_amd_list_cnt = cnvtint(size(protocol_amdlist->qual,5))
 SET protocol_cnt = 0
 SET amendment_cnt = 0
 FOR (i = 1 TO prot_amd_list_cnt)
   SET argsize = size(trim(protocol_amdlist->qual[i].value),1)
   SET nposition = findstring("|",protocol_amdlist->qual[i].value,1)
   SET nanyprotocolposition = findstring("*|",protocol_amdlist->qual[i].value,1)
   IF (nanyprotocolposition > 0)
    SET amendment_cnt = 0
    SET protocol_cnt = 0
    SET enroll_list->any_prot_ind = 1
   ELSEIF (nposition > 0)
    SET amendment_cnt += 1
    SET nsecondpos = findstring("|",protocol_amdlist->qual[i].value,(nposition+ 1))
    SET amdlength = (nsecondpos - (nposition+ 1))
    SET stat = alterlist(enroll_list->amendments,amendment_cnt)
    SET enroll_list->amendments[amendment_cnt].prot_amendment_id = cnvtreal(substring((nposition+ 1),
      amdlength,protocol_amdlist->qual[i].value))
    SET enroll_list->amendments[amendment_cnt].amendment_name = protocol_amdlist->qual[i].display
    SET protlength = (argsize - nposition)
    SET nposition = (nsecondpos+ 1)
    SET enroll_list->amendments[amendment_cnt].prot_name = substring(nposition,protlength,
     protocol_amdlist->qual[i].value)
   ELSE
    SET protocol_cnt += 1
    SET stat = alterlist(enroll_list->protocols,protocol_cnt)
    SET enroll_list->protocols[protocol_cnt].prot_master_id = cnvtreal(substring(1,argsize,
      protocol_amdlist->qual[i].value))
    SET enroll_list->protocols[protocol_cnt].prot_name = substring(2,size(trim(protocol_amdlist->
       qual[i].display),1),protocol_amdlist->qual[i].display)
   ENDIF
 ENDFOR
 IF (((protocol_cnt > 0) OR ((enroll_list->any_prot_ind=1))) )
  SET cnt = 1
  SELECT INTO "nl:"
   pt.reg_id
   FROM pt_prot_reg pt,
    prot_master pm
   PLAN (pt
    WHERE pt.person_id=personid
     AND ((expand(cnt,1,protocol_cnt,pt.prot_master_id,enroll_list->protocols[cnt].prot_master_id))
     OR ((enroll_list->any_prot_ind=1)))
     AND pt.off_study_dt_tm > cnvtdatetime(sysdate)
     AND pt.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pm
    WHERE pm.prot_master_id=pt.prot_master_id
     AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    cnt2 = 1, idx = 0, idx = locateval(cnt2,1,protocol_cnt,pt.prot_master_id,enroll_list->protocols[
     cnt2].prot_master_id)
    IF (idx > 0)
     IF (enrollprotcnt > 0)
      protlist = concat(protlist,", ",enroll_list->protocols[cnt2].prot_name)
     ELSE
      protlist = build(enroll_list->protocols[cnt2].prot_name)
     ENDIF
     enrollprotcnt += 1
    ENDIF
    IF ((enroll_list->any_prot_ind=1))
     IF (enrollprotcnt > 0)
      protlist = concat(protlist,", ",pm.primary_mnemonic)
     ELSE
      protlist = build(pm.primary_mnemonic)
     ENDIF
     enrollprotcnt += 1
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(concat("ProtList is : ",build(protlist)))
 ENDIF
 IF (amendment_cnt > 0)
  SET cnt = 1
  SELECT INTO "nl:"
   ct.reg_id
   FROM ct_pt_amd_assignment ct,
    pt_prot_reg pt
   PLAN (pt
    WHERE pt.person_id=personid
     AND pt.off_study_dt_tm > cnvtdatetime(sysdate)
     AND pt.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (ct
    WHERE ct.reg_id=pt.reg_id
     AND expand(cnt,1,amendment_cnt,ct.prot_amendment_id,enroll_list->amendments[cnt].
     prot_amendment_id)
     AND ct.assign_end_dt_tm > cnvtdatetime(sysdate)
     AND ct.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    cnt2 = 1, idx = 0, idx = locateval(cnt2,1,amendment_cnt,ct.prot_amendment_id,enroll_list->
     amendments[cnt2].prot_amendment_id)
    IF (idx > 0)
     IF (enrollprotcnt > 0)
      protlist = concat(protlist,", ",enroll_list->amendments[idx].prot_name," (",enroll_list->
       amendments[idx].amendment_name,
       ")")
     ELSE
      protlist = concat(enroll_list->amendments[idx].prot_name," (",enroll_list->amendments[idx].
       amendment_name,")")
     ENDIF
     enrollprotcnt += 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(concat("ProtList is : ",build(protlist)))
 IF (enrollprotcnt > 0)
  SET retval = 100
  SET stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,1)
  SET eksdata->tqual[tcurindex].qual[curindex].cnt = 1
  SET eksdata->tqual[tcurindex].qual[curindex].data[1].misc = protlist
  CALL echo(concat("Misc is: ",eksdata->tqual[tcurindex].qual[curindex].data[1].misc))
  CALL echo(build("enrollProtCnt is: ",enrollprotcnt))
  IF (enrollprotcnt > 5)
   SET loggingmsg = concat("Enrolled on ",trim(cnvtstring(enrollprotcnt))," protocol(s)")
  ELSE
   SET loggingmsg = protlist
  ENDIF
  SET protocolmsg = concat("An enrollment exists for this person. (",loggingmsg,")")
 ELSE
  SET protocolmsg = "No enrollment exists for this person."
 ENDIF
#end_of_program
 FREE RECORD enroll_list
 SET eksdata->tqual[tcurindex].qual[curindex].person_id = personid
 SET eksdata->tqual[tcurindex].qual[curindex].encntr_id = encounterid
 SET eksdata->tqual[tcurindex].qual[curindex].logging = trim(protocolmsg)
 CALL echo(concat("Logging is: ",eksdata->tqual[tcurindex].qual[curindex].logging))
 CALL echo(concat("retval = ",build(retval)))
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  End of Program ct_t_check_trial_enroll  *********"))
END GO
