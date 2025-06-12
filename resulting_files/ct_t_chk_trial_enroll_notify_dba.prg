CREATE PROGRAM ct_t_chk_trial_enroll_notify:dba
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 CALL echo(concat(format(cnvtdatetime(sysdate),";;q")," STARTING CT_T_CHK_TRIAL_ENROLL_NOTIFY"))
 FREE RECORD enrollmentlist
 RECORD enrollmentlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 FREE RECORD protocollist
 RECORD protocollist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 FREE RECORD protamdlist
 RECORD protamdlist(
   1 all_prots_ind = i2
   1 protocols[*]
     2 prot_master_id = f8
     2 prot_name = vc
   1 amendments[*]
     2 prot_amendment_id = f8
     2 amendment_name = vc
     2 prot_name = vc
 )
 FREE RECORD enrolllist
 RECORD enrolllist(
   1 enrolls[*]
     2 prot_master_id = f8
     2 prot_name = vc
     2 display_ind = i2
 )
 FREE RECORD contact_request
 RECORD contact_request(
   1 protocols[*]
     2 prot_master_id = f8
     2 prot_amendment_id = f8
   1 person_id = f8
 )
 FREE RECORD contact_reply
 RECORD contact_reply(
   1 contact_info[*]
     2 prot_amendment_id = f8
     2 prot_master_id = f8
     2 person_id = f8
     2 prot_role_id = f8
     2 person_name = vc
     2 role_name = vc
     2 organization_name = vc
     2 phone_num = vc
     2 pager_num = vc
     2 email_addr = vc
     2 alphapager = vc
   1 primary_contacts[*]
     2 primary_contact_info[*]
       3 prot_amendment_id = f8
       3 prot_master_id = f8
       3 person_id = f8
       3 prot_role_id = f8
       3 person_name = vc
       3 role_name = vc
       3 organization_name = vc
       3 phone_num = vc
       3 pager_num = vc
       3 email_addr = vc
       3 alphapager = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD contactlist
 RECORD contactlist(
   1 contacts[*]
     2 person_id = f8
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE action_alphapager = i2 WITH protect, constant(0)
 DECLARE action_email = i2 WITH protect, constant(1)
 DECLARE action_inbox = i2 WITH protect, constant(2)
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE encounterid = f8 WITH protect, noconstant(0.0)
 DECLARE smsg = vc WITH protect, noconstant("")
 DECLARE will_not_display_ind = i2 WITH protect, noconstant(0)
 DECLARE has_ever_been_ind = i2 WITH protect, noconstant(0)
 DECLARE enrollment_ind = i2 WITH protect, noconstant(0)
 DECLARE act_temp_type_flag = i2 WITH protect, noconstant(- (1))
 DECLARE act_temp_nbr = i2 WITH protect, noconstant(0)
 DECLARE protlist = vc WITH protect, noconstant("")
 DECLARE data = vc WITH protect, noconstant("")
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE protlist_cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE eidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE notfound = vc WITH protect, constant("<not_found>")
 DECLARE prot_name = vc WITH protect, noconstant("")
 DECLARE amd_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE amd_cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE enroll_cnt = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
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
 DECLARE validateparms(null) = i2
 IF (validate(enrollment,"Z")="Z"
  AND validate(enrollment,"Y")="Y")
  SET smsg = "Required variable, ENROLLMENT, does not exist"
  SET retval = - (1)
  GO TO end_of_program
 ENDIF
 CALL echo(concat("ENROLLMENT: ",enrollment))
 SET orig_param = enrollment
 EXECUTE eks_t_parse_list  WITH replace(reply,enrollmentlist)
 FREE SET orig_param
 IF (validate(enrollment,"Z")="Z"
  AND validate(enrollment,"Y")="Y")
  SET smsg = "The external variable ENROLLMENT wasn't defined by the template"
  SET retval = - (1)
  GO TO end_of_program
 ELSE
  IF (((trim(enrollment)=" ") OR (trim(enrollment)="<undefined>")) )
   SET smsg = "ENROLLMENT must be filled out."
   SET retval = - (1)
   GO TO end_of_program
  ELSE
   IF (cnvtupper(trim(enrollment))="HAS EVER BEEN ENROLLED")
    SET has_ever_been_ind = 1
   ELSEIF (cnvtupper(trim(enrollment))="IS CURRENTLY ENROLLED")
    SET has_ever_been_ind = 0
   ELSE
    SET smsg = concat("ENROLLMENT value of ",trim(enrollment),
     " IS CURRENTLY ENROLLED or HAS EVER BEEN ENROLLED")
    SET retval = - (1)
    GO TO end_of_program
   ENDIF
  ENDIF
 ENDIF
 IF (validate(protocol,"Z")="Z"
  AND validate(protocol,"Y")="Y")
  SET smsg = "Required variable, PROTOCOL, does not exist"
  SET retval = - (1)
  GO TO end_of_program
 ENDIF
 SET tempstr = protocol
 SET tempstr = replace(tempstr,char(6),"<6>",0)
 SET tempstr = replace(tempstr,char(7),"<7>",0)
 CALL echo(concat("PROTOCOL:",tempstr))
 SET orig_param = protocol
 EXECUTE eks_t_parse_list  WITH replace(reply,protocollist)
 FREE SET orig_param
 SET protlist_cnt = cnvtint(size(protocollist->qual,5))
 SET amd_cnt = 0
 SET prot_cnt = 0
 CALL echo(concat("protlist_cnt:",build(protlist_cnt)))
 FOR (idx = 1 TO protlist_cnt)
   SET data = trim(protocollist->qual[idx].value)
   SET num = 1
   SET tempstr = ""
   CALL echo(concat("data = ",data))
   WHILE (tempstr != notfound
    AND num < 10
    AND (protamdlist->all_prots_ind=0))
     SET tempstr = piece(data,"|",num,notfound)
     CALL echo(concat("piece",build(num),"=",tempstr))
     CASE (num)
      OF 1:
       CALL echo(build("findstring('*', tempstr) = ",findstring("*",tempstr)))
       SET pos = findstring("*",tempstr)
       IF (pos > 0)
        CALL echo("All Protocols")
        SET protamdlist->all_prots_ind = 1
       ELSE
        CALL echo(concat("Not All Protocols: ",tempstr))
        SET prot_id = cnvtreal(tempstr)
       ENDIF
      OF 2:
       SET prot_name = tempstr
      OF 3:
       SET amd_id = cnvtreal(tempstr)
     ENDCASE
     SET num += 1
   ENDWHILE
   IF ((protamdlist->all_prots_ind=0))
    IF (amd_id > 0)
     SET amd_cnt += 1
     IF (mod(amd_cnt,10)=1)
      SET stat = alterlist(protamdlist->amendments,(amd_cnt+ 9))
     ENDIF
     SET protamdlist->amendments[amd_cnt].prot_name = prot_name
     SET protamdlist->amendments[amd_cnt].prot_amendment_id = amd_id
    ELSE
     SET prot_cnt += 1
     IF (mod(prot_cnt,10)=1)
      SET stat = alterlist(protamdlist->protocols,(prot_cnt+ 9))
     ENDIF
     SET protamdlist->protocols[prot_cnt].prot_master_id = prot_id
     SET protamdlist->protocols[prot_cnt].prot_name = prot_name
    ENDIF
   ELSE
    SET prot_cnt = 0
    SET amd_cnt = 0
   ENDIF
 ENDFOR
 SET stat = alterlist(protamdlist->protocols,prot_cnt)
 SET stat = alterlist(protamdlist->amendments,amd_cnt)
 CALL echorecord(protamdlist)
 CALL echo(concat("DISPLAY_IND:",display_ind))
 IF (validate(display_ind,"Z")="Z"
  AND validate(display_ind,"Y")="Y")
  SET smsg = "The external variable DISPLAY_IND wasn't defined by the template"
  SET retval = - (1)
  GO TO end_of_program
 ELSE
  IF (((trim(display_ind)=" ") OR (trim(display_ind)="<undefined>")) )
   SET smsg = "DISPLAY_IND must be filled out."
   SET retval = - (1)
   GO TO end_of_program
  ELSE
   IF (cnvtupper(trim(display_ind))="WILL")
    SET will_not_display_ind = 0
   ELSEIF (cnvtupper(trim(display_ind))="WILL NOT")
    SET will_not_display_ind = 1
   ELSE
    SET smsg = concat("DISPLAY_IND value of ",trim(display_ind)," is not WILL or WILL NOT")
    SET retval = - (1)
    GO TO end_of_program
   ENDIF
  ENDIF
 ENDIF
 SET act_temp_type_flag = - (1)
 IF (validate(opt_act_template_type,"Z")="Z"
  AND validate(opt_act_template_type,"Y")="Y")
  CALL echo("OPT_ACT_TEMPLATE_TYPE variable does not exist.  It will be ignored")
 ELSE
  IF (((trim(opt_act_template_type)=" ") OR (trim(opt_act_template_type)="<undefined>")) )
   CALL echo("OPT_ACT_TEMPLATE_TYPE is empty. It will be ignored")
  ELSE
   IF (cnvtupper(trim(opt_act_template_type))="EMAIL")
    SET act_temp_type_flag = action_email
   ELSEIF (cnvtupper(trim(opt_act_template_type))="ALPHAPAGER")
    SET act_temp_type_flag = action_alphapager
   ELSEIF (cnvtupper(trim(opt_act_template_type))="INBOX")
    SET act_temp_type_flag = action_inbox
   ELSE
    SET smsg = concat("OPT_ACT_TEMPLATE_TYPE value of ",trim(display_opt_act_template_typeind),
     " is not email, alphapager or inbox")
    SET retval = - (1)
    GO TO end_of_program
   ENDIF
  ENDIF
 ENDIF
 CALL echo(concat("OPT_ACT_TEMPLATE_TYPE:",opt_act_template_type))
 SET act_temp_nbr = 0
 IF (validate(opt_act_template_nbr,"Z")="Z"
  AND validate(opt_act_template_nbr,"Y")="Y")
  CALL echo("OPT_ACT_TEMPLATE_NBR variable does not exist.  It will be ignored")
 ELSEIF ( NOT (isnumeric(opt_act_template_nbr)))
  CALL echo(concat("OPT_ACT_TEMPLATE_NBR value of ",opt_act_template_nbr,
    " is not numeric.  It will be ignored"))
 ELSEIF (cnvtint(opt_act_template_nbr) <= 0)
  SET smsg = concat(opt_act_template_nbr," is not a valid OPT_LINK value")
  SET retval = - (1)
  GO TO end_of_program
 ELSE
  SET act_temp_nbr = cnvtint(opt_act_template_nbr)
 ENDIF
 CALL echo(concat("OPT_ACT_TEMPLATE_NBR:",opt_act_template_nbr))
 IF (validate(opt_link,"Z")="Z"
  AND validate(opt_link,"Y")="Y")
  CALL echo("OPT_LINK variable does not exist.  It will be ignored")
 ELSEIF ( NOT (isnumeric(opt_link)))
  CALL echo(concat("OPT_LINK value of ",opt_link," is not numeric.  It will be ignored"))
 ELSEIF (((cnvtint(opt_link) <= 0) OR (cnvtint(opt_link) >= curindex)) )
  SET smsg = concat(opt_link," is not a valid OPT_LINK value")
  SET retval = - (1)
  GO TO end_of_program
 ELSE
  SET personid = eksdata->tqual[tcurindex].qual[cnvtint(opt_link)].person_id
  SET encounterid = eksdata->tqual[tcurindex].qual[cnvtint(opt_link)].encntr_id
  IF (personid <= 0)
   SET smsg = concat("Logic Template ",opt_link," did not set a valid personId")
   SET retval = - (1)
   GO TO end_of_program
  ENDIF
  CALL echo(concat("Link personId is ",build(personid)))
 ENDIF
 IF (personid <= 0)
  IF (validate(event->qual)=0)
   SET smsg = concat("OPT_LINK must be used for the ",eksevent," event")
   SET retval = - (1)
   GO TO end_of_program
  ELSEIF ((event->qual[eks_common->event_repeat_index].person_id > 0))
   SET personid = event->qual[eks_common->event_repeat_index].person_id
   SET encounterid = event->qual[eks_common->event_repeat_index].encntr_id
  ELSE
   SET smsg = "Invalid personId found in the event structure"
   SET retval = 0
   GO TO end_of_program
  ENDIF
 ENDIF
 CALL echo(concat("CT_T_CHK_TRIAL_ENROLL_NOTIFY personId is ",build(personid)))
 CALL echo(concat("encounterId = ",build(encounterid)))
 SET prot_cnt = size(protamdlist->protocols,5)
 CALL echo(concat("prot_cnt = ",build(prot_cnt)))
 CALL echo(concat("ProtAmdList->all_prots_ind = ",build(protamdlist->all_prots_ind)))
 IF (((prot_cnt > 0) OR ((protamdlist->all_prots_ind=1))) )
  SET cnt = 1
  SELECT INTO "nl:"
   pt.reg_id
   FROM pt_prot_reg pt,
    prot_master pm
   PLAN (pt
    WHERE pt.person_id=personid
     AND ((expand(cnt,1,prot_cnt,pt.prot_master_id,protamdlist->protocols[cnt].prot_master_id)) OR ((
    protamdlist->all_prots_ind=1)))
     AND ((pt.off_study_dt_tm >= cnvtdatetime(sysdate)) OR (has_ever_been_ind=1))
     AND pt.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (pm
    WHERE pm.prot_master_id=pt.prot_master_id
     AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    CALL echo(concat("In the detail, pt.prot_master_id = ",build(pt.prot_master_id))), enroll_cnt +=
    1
    IF (mod(enroll_cnt,10)=1)
     stat = alterlist(enrolllist->enrolls,(enroll_cnt+ 9))
    ENDIF
    CALL echo(concat("Prot::adding protocol: ",build(pt.prot_master_id))), enrolllist->enrolls[
    enroll_cnt].prot_master_id = pt.prot_master_id, enrolllist->enrolls[enroll_cnt].prot_name = pm
    .primary_mnemonic,
    enrolllist->enrolls[enroll_cnt].display_ind = pm.display_ind
   WITH nocounter
  ;end select
 ENDIF
 SET amd_cnt = size(protamdlist->amendments,5)
 CALL echo(concat("amd_cnt = ",build(amd_cnt)))
 IF (amd_cnt > 0)
  SET cnt = 1
  SELECT INTO "nl:"
   ct.reg_id
   FROM ct_pt_amd_assignment ct,
    pt_prot_reg pt,
    prot_master pm
   PLAN (pt
    WHERE pt.person_id=personid
     AND ((pt.off_study_dt_tm >= cnvtdatetime(sysdate)) OR (has_ever_been_ind=1))
     AND pt.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (ct
    WHERE ct.reg_id=pt.reg_id
     AND expand(cnt,1,amd_cnt,ct.prot_amendment_id,protamdlist->amendments[cnt].prot_amendment_id)
     AND ct.assign_end_dt_tm >= cnvtdatetime(sysdate))
    JOIN (pm
    WHERE pm.prot_master_id=pt.prot_master_id
     AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    num = 1, idx = 0, eidx = 0,
    eidx = locateval(num,1,enroll_cnt,pt.prot_master_id,enrolllist->enrolls[num].prot_master_id),
    CALL echo(concat("EnrollList index = ",build(eidx)))
    IF (eidx <= 0)
     idx = locateval(num,1,amd_cnt,ct.prot_amendment_id,protamdlist->amendments[num].
      prot_amendment_id),
     CALL echo(concat("ProtAmdList->Amendments index = ",build(idx)))
     IF (idx > 0)
      enroll_cnt += 1
      IF (mod(enroll_cnt,10)=1)
       stat = alterlist(enrolllist->enrolls,(enroll_cnt+ 9))
      ENDIF
      CALL echo(concat("Amd::adding protocol: ",build(pt.prot_master_id))), enrolllist->enrolls[
      enroll_cnt].prot_master_id = pt.prot_master_id, enrolllist->enrolls[enroll_cnt].prot_name = pm
      .primary_mnemonic,
      enrolllist->enrolls[enroll_cnt].display_ind = pm.display_ind
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(enrolllist->enrolls,enroll_cnt)
 IF (enroll_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(enrolllist->enrolls,5)))
   ORDER BY enrolllist->enrolls[d.seq].prot_name
   HEAD REPORT
    prot_cnt = 0, cnt = 0
   DETAIL
    IF ((enrolllist->enrolls[d.seq].display_ind=0)
     AND will_not_display_ind=1)
     cnt += 1
    ELSE
     IF (prot_cnt > 0)
      protlist = concat(protlist,", ",enrolllist->enrolls[d.seq].prot_name)
     ELSE
      protlist = enrolllist->enrolls[d.seq].prot_name
     ENDIF
     prot_cnt += 1
    ENDIF
   FOOT REPORT
    IF (cnt > 0)
     tempstr = uar_i18nbuildmessage(i18nhandle,"PRIVATE_PROTS",
      "This person belongs to [%1] protocols that are not listed for privacy reasons.","i",cnt)
     IF (prot_cnt > 0)
      protlist = concat(protlist,", ",tempstr)
     ELSE
      protlist = tempstr
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET retval = 100
  SET stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,1)
  SET eksdata->tqual[tcurindex].qual[curindex].cnt = 1
  SET eksdata->tqual[tcurindex].qual[curindex].data[1].misc = protlist
  CALL echo(concat("Misc is: ",eksdata->tqual[tcurindex].qual[curindex].data[1].misc))
  CALL echo(build("enroll_cnt is: ",enroll_cnt))
  SET smsg = concat("An enrollment exists for this person. (",protlist,")")
  CALL echo("before the flag check")
  IF (act_temp_type_flag >= 0
   AND act_temp_nbr > 0)
   SET cnt = 0
   SET eidx = 0
   SET tempstr = ""
   CALL echo("before prot role lookup")
   SELECT INTO "nl:"
    p.name_full_formatted, fmted = format(pr.person_id,"F")
    FROM prot_role pr,
     person p,
     prot_master pm,
     prot_amendment pa
    PLAN (pm
     WHERE expand(num,1,enroll_cnt,pm.prot_master_id,enrolllist->enrolls[num].prot_master_id)
      AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_status_cd=pm.prot_status_cd)
     JOIN (pr
     WHERE pr.prot_amendment_id=pa.prot_amendment_id
      AND pr.primary_contact_ind=1
      AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=pr.person_id)
    HEAD REPORT
     pcnt = 0
    HEAD pr.person_id
     cnt += 1
     IF (((act_temp_type_flag=action_alphapager) OR (act_temp_type_flag=action_email)) )
      pcnt += 1
      IF (mod(pcnt,10)=1)
       stat = alterlist(contactlist->contacts,(pcnt+ 9))
      ENDIF
      contactlist->contacts[pcnt].person_id = pr.person_id
     ELSE
      IF (cnt > 1)
       tempstr = concat(tempstr,char(7),char(6),trim(cnvtstring(pr.person_id)),".0|0",
        char(6),trim(p.name_full_formatted))
      ELSE
       tempstr = concat(trim(cnvtstring(pr.person_id)),".0|0",char(6),trim(p.name_full_formatted))
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(contactlist->contacts,pcnt)
    WITH nocounter
   ;end select
   IF (((act_temp_type_flag=action_alphapager) OR (act_temp_type_flag=action_email)) )
    SET pcnt = size(contactlist->contacts,5)
    CALL echo(concat("pcnt=",build(pcnt)))
    SET pos = 0
    FOR (eidx = 1 TO pcnt)
      SET stat = initrec(contact_request)
      SET stat = initrec(contact_reply)
      SET contact_request->person_id = contactlist->contacts[eidx].person_id
      CALL echo(concat("contact_request->person_id:",build(contact_request->person_id)))
      EXECUTE ct_get_contact_info  WITH replace("REQUEST","CONTACT_REQUEST"), replace("REPLY",
       "CONTACT_REPLY")
      IF ((contact_reply->status_data.status="S"))
       SET cnt = size(contact_reply->contact_info,5)
       CALL echo(concat("size(contact_reply->contact_info, 5) = ",build(cnt)))
       FOR (idx = 1 TO cnt)
         SET data = ""
         IF (act_temp_type_flag=action_alphapager)
          SET data = contact_reply->contact_info[idx].alphapager
         ELSE
          SET data = contact_reply->contact_info[idx].email_addr
         ENDIF
         IF (size(data,1) > 0)
          SET pos += 1
          IF (pos > 1)
           SET tempstr = concat(tempstr,char(7),char(6),"@EMAIL:[",trim(data),
            "]")
          ELSE
           SET tempstr = concat(char(6),"@EMAIL:[",trim(data),"]")
          ENDIF
          CALL echo(concat("contact id:",build(contact_reply->contact_info[idx].person_id)))
          CALL echo(concat("contact name:",contact_reply->contact_info[idx].person_name))
         ELSE
          CALL echo(concat("email address is blank for person:",build(contact_reply->contact_info[idx
             ].person_id)))
         ENDIF
       ENDFOR
      ELSE
       CALL echo(concat("contact_reply->status_data.status = ",contact_reply->status_data.status))
      ENDIF
    ENDFOR
   ENDIF
   IF (size(tempstr,1) > 0)
    SET eksdata->bldmsg_cnt += 1
    SET eksdata->bldmsg_paramind = 1
    SET eidx = eksdata->bldmsg_cnt
    SET stat = alterlist(eksdata->bldmsg,eidx)
    SET eksdata->bldmsg[eidx].name = concat("RECIPIENT_A",build(act_temp_nbr))
    SET eksdata->bldmsg[eidx].text = tempstr
    CALL echo(concat("eksdata->bldMsg[eidx].Name = ",eksdata->bldmsg[eidx].name))
    SET tempstr = replace(tempstr,char(6),"<6>",0)
    SET tempstr = replace(tempstr,char(7),"<7>",0)
    CALL echo(concat("delimited eksdata->bldMsg[",build(eidx),"].Text = ",tempstr))
    CALL echo(concat("size(eksdata->bldMsg[eidx].Text, 1) = ",build(size(eksdata->bldmsg[eidx].text,1
        ))))
   ELSE
    SET smsg = concat(smsg,"  There are no primary contacts configured for the listed protocols.",
     "  No message will be sent.")
   ENDIF
  ENDIF
 ELSE
  SET smsg = "No enrollment exists for this person."
 ENDIF
 CALL echo(concat("ProtList is : ",protlist))
#end_of_program
 CALL echo(concat("personId = ",build(personid)))
 CALL echo(concat("encounterId = ",build(encounterid)))
 SET eksdata->tqual[tcurindex].qual[curindex].person_id = personid
 SET eksdata->tqual[tcurindex].qual[curindex].encntr_id = encounterid
 SET eksdata->tqual[tcurindex].qual[curindex].logging = trim(smsg)
 CALL echo(concat("Logging is: ",eksdata->tqual[tcurindex].qual[curindex].logging))
 CALL echo(concat("retval = ",build(retval)))
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  End of Program ct_t_chk_trial_enroll_notify  *********"))
 CALL echo("END OF PROGRAM CT_T_CHK_TRIAL_ENROLL_NOTIFY")
 FREE RECORD enrollmentlist
 FREE RECORD protocollist
 FREE RECORD protamdlist
 FREE RECORD enrolllist
 FREE RECORD contact_request
 FREE RECORD contact_reply
 FREE RECORD contactlist
 SET last_mod = "000"
 SET mod_date = "June 1, 2009"
END GO
