CREATE PROGRAM bhs_prax_get_message_details
 DECLARE phonemsg = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"PHONEMSG"))
 DECLARE reminder = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"REMINDER"))
 DECLARE consult = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"CONSULT"))
 DECLARE notification = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"NOTIFICATION"))
 DECLARE pending = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",79,"PENDING"))
 DECLARE opened = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",79,"OPENED"))
 DECLARE vcnt = i4
 DECLARE acnt = i4
 DECLARE rcnt = i4
 DECLARE pcnt = i4
 DECLARE json = vc WITH protect, noconstant("")
 SET where_params = build("ta.task_type_cd in"," ", $3)
 FREE RECORD msg_list
 RECORD msg_list(
   1 msgs[*]
     2 taskid = f8
     2 eventid = vc
     2 personid = vc
     2 encounterid = i4
     2 assigned = vc
     2 createddate = vc
     2 senderprsnlid = f8
     2 fromuser = vc
     2 patientname = vc
     2 taskprioritydisplay = vc
     2 reminddatetime = vc
     2 taskstatusdisplay = vc
     2 subject = vc
     2 touser = vc
     2 tasktypecd = f8
     2 tasktypedisplay = vc
     2 duedatetime = vc
     2 updatedatetime = vc
     2 updatecount = i4
     2 confidentialindicator = i2
     2 deliveryindicator = i2
     2 statind = c3
     2 copymessageindicator = c5
     2 replyallowedindicator = c5
     2 eventclassmeaning = vc
     2 callername = vc
     2 callerphones = vc
     2 actionrequests[*]
       3 taskid = f8
       3 tasksubactivityid = i4
       3 actionrequestcd = i4
       3 actionrequestdisplay = vc
       3 actionrequestmeaning = vc
     2 receivers[*]
       3 taskid = f8
       3 assignedprsnlid = f8
       3 receiver = vc
       3 copytype = c2
 )
 SELECT INTO "nl:"
  assigned = trim(replace(replace(replace(replace(replace(pr1.name_full_formatted,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), create_date = format(ta
   .task_create_dt_tm,"DD MMM YYYY HH:MM:SS;;d"), from_user = trim(replace(replace(replace(replace(
       replace(prsnl.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3),
  patient_name = trim(replace(replace(replace(replace(replace(p.name_full_formatted,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), task_priority_disp = trim(
   replace(replace(replace(replace(replace(uar_get_code_display(ta.task_priority_cd),"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), remind_dt_tm = format(ta
   .remind_dt_tm,"DD MMM YYYY HH:MM:SS;;d"),
  task_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(taa
         .task_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), subject = trim(replace(replace(replace(replace(replace(ta.msg_subject,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), to_user = trim(replace(replace(
     replace(replace(replace(pr2.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  task_id = ta.task_id, task_type_disp = trim(replace(replace(replace(replace(replace(
        uar_get_code_display(ta.task_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
     0),'"',"&quot;",0),3), due_dt_tm = format(ta.scheduled_dt_tm,"DD MMM YYYY HH:MM:SS;;d"),
  update_dt_tm = format(ta.updt_dt_tm,"DD MMM YYYY HH:MM:SS;;d"), tsa_task_id = cnvtint(tsa.task_id),
  task_subact_id = cnvtint(tsa.task_subactivity_id),
  action_req_cd = cnvtint(tsa.action_request_cd), action_req_disp = trim(replace(replace(replace(
      replace(replace(uar_get_code_display(tsa.action_request_cd),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), action_req_mean = trim(replace(replace(replace(
      replace(replace(uar_get_code_meaning(tsa.action_request_cd),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  event_id = trim(replace(cnvtstring(ta.event_id),".0*","",0),3), person_id = trim(replace(cnvtstring
    (ta.person_id),".0*","",0),3), encounter_id = trim(replace(cnvtstring(ta.encntr_id),".0*","",0),3
   ),
  copy_message =
  IF (cnvtint(taa.copy_type_flag)=1) "TRUE"
  ELSE "FALSE"
  ENDIF
  , stat_ind =
  IF (ta.stat_ind=1) "Yes"
  ELSE "No"
  ENDIF
  , event_class_mean = uar_get_code_meaning(ta.event_class_cd),
  reply_allowed =
  IF (cnvtint(taa.reply_allowed_ind)=1) "TRUE"
  ELSE "FALSE"
  ENDIF
  FROM task_activity ta,
   task_activity_assignment taa,
   prsnl prsnl,
   prsnl pr1,
   prsnl pr2,
   person p,
   task_subactivity tsa
  PLAN (ta
   WHERE parser(where_params)
    AND ta.active_ind=1)
   JOIN (p
   WHERE p.person_id=ta.person_id)
   JOIN (taa
   WHERE ta.task_id=taa.task_id
    AND taa.task_status_cd IN (pending, opened)
    AND taa.assign_prsnl_id=cnvtint( $2)
    AND (ta.updt_dt_tm > (sysdate - 30))
    AND taa.beg_eff_dt_tm < sysdate
    AND taa.end_eff_dt_tm > sysdate)
   JOIN (prsnl
   WHERE ta.msg_sender_id=prsnl.person_id)
   JOIN (pr1
   WHERE pr1.person_id=taa.assign_person_id)
   JOIN (pr2
   WHERE pr2.person_id=taa.assign_prsnl_id)
   JOIN (tsa
   WHERE tsa.task_id=outerjoin(ta.task_id))
  ORDER BY taa.updt_dt_tm DESC, ta.task_id
  HEAD ta.task_id
   vcnt = (vcnt+ 1), stat = alterlist(msg_list->msgs,vcnt), msg_list->msgs[vcnt].taskid = ta.task_id,
   msg_list->msgs[vcnt].personid = person_id, msg_list->msgs[vcnt].encounterid = ta.encntr_id,
   msg_list->msgs[vcnt].eventid = event_id,
   msg_list->msgs[vcnt].assigned = assigned, msg_list->msgs[vcnt].createddate = create_date, msg_list
   ->msgs[vcnt].senderprsnlid = cnvtint(ta.msg_sender_id),
   msg_list->msgs[vcnt].fromuser = from_user, msg_list->msgs[vcnt].patientname = patient_name,
   msg_list->msgs[vcnt].taskprioritydisplay = task_priority_disp,
   msg_list->msgs[vcnt].reminddatetime = remind_dt_tm, msg_list->msgs[vcnt].taskstatusdisplay =
   task_status_disp, msg_list->msgs[vcnt].subject = subject,
   msg_list->msgs[vcnt].touser = to_user, msg_list->msgs[vcnt].tasktypedisplay = task_type_disp,
   msg_list->msgs[vcnt].tasktypecd = ta.task_type_cd,
   msg_list->msgs[vcnt].duedatetime = due_dt_tm, msg_list->msgs[vcnt].updatedatetime = update_dt_tm,
   msg_list->msgs[vcnt].updatecount = ta.updt_cnt,
   msg_list->msgs[vcnt].confidentialindicator = cnvtint(ta.confidential_ind), msg_list->msgs[vcnt].
   deliveryindicator = cnvtint(ta.delivery_ind), msg_list->msgs[vcnt].statind = stat_ind,
   msg_list->msgs[vcnt].copymessageindicator = copy_message, msg_list->msgs[vcnt].eventclassmeaning
    = event_class_mean, msg_list->msgs[vcnt].replyallowedindicator = reply_allowed,
   acnt = 0
  HEAD task_subact_id
   acnt = (acnt+ 1), stat = alterlist(msg_list->msgs[vcnt].actionrequests,acnt), msg_list->msgs[vcnt]
   .actionrequests[acnt].taskid = tsa_task_id,
   msg_list->msgs[vcnt].actionrequests[acnt].tasksubactivityid = task_subact_id, msg_list->msgs[vcnt]
   .actionrequests[acnt].actionrequestcd = action_req_cd, msg_list->msgs[vcnt].actionrequests[acnt].
   actionrequestdisplay = action_req_disp,
   msg_list->msgs[vcnt].actionrequests[acnt].actionrequestmeaning = action_req_mean
  WITH time = 20
 ;end select
 IF (vcnt > 0)
  SELECT INTO "nl:"
   d1_task_id = msg_list->msgs[d1.seq].taskid, receiver = trim(replace(replace(replace(replace(
        replace(pr_rec.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
     '"',"&quot;",0),3), copy_type =
   IF (taa_rec.copy_type_flag=0) "TO"
   ELSEIF (taa_rec.copy_type_flag=1) "CC"
   ELSE " "
   ENDIF
   FROM (dummyt d1  WITH seq = value(size(msg_list->msgs,5))),
    task_activity_assignment taa_rec,
    prsnl pr_rec
   PLAN (d1)
    JOIN (taa_rec
    WHERE (taa_rec.task_id=msg_list->msgs[d1.seq].taskid))
    JOIN (pr_rec
    WHERE pr_rec.person_id=taa_rec.assign_prsnl_id)
   HEAD taa_rec.task_id
    rcnt = 0
   HEAD taa_rec.assign_prsnl_id
    rcnt = (rcnt+ 1), stat = alterlist(msg_list->msgs[d1.seq].receivers,rcnt), msg_list->msgs[d1.seq]
    .receivers[rcnt].taskid = taa_rec.task_id,
    msg_list->msgs[d1.seq].receivers[rcnt].assignedprsnlid = taa_rec.assign_prsnl_id, msg_list->msgs[
    d1.seq].receivers[rcnt].receiver = receiver, msg_list->msgs[d1.seq].receivers[rcnt].copytype =
    copy_type
   WITH time = 10
  ;end select
  SELECT INTO "nl:"
   d2_task_id = msg_list->msgs[d2.seq].taskid, long_text_id = cnvtint(lt.long_text_id), caller = trim
   (replace(replace(replace(replace(replace(replace(lt.long_text,", C (000)000-0000","",0),"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
   FROM (dummyt d2  WITH seq = value(size(msg_list->msgs,5))),
    long_text lt
   PLAN (d2
    WHERE (msg_list->msgs[d2.seq].tasktypecd=phonemsg))
    JOIN (lt
    WHERE (lt.parent_entity_id=msg_list->msgs[d2.seq].taskid)
     AND lt.parent_entity_name="TASK_ACTIVITY"
     AND lt.active_ind=1)
   HEAD d2_task_id
    IF (caller != " ")
     msg_list->msgs[d2.seq].callername =
     IF (piece(caller,":",1,"N/A") != "-") piece(caller,":",1,"N/A")
     ELSE " "
     ENDIF
     , msg_list->msgs[d2.seq].callerphones =
     IF (piece(caller,":",2,"N/A") != "-") piece(caller,":",2,"N/A")
     ELSE " "
     ENDIF
    ENDIF
   WITH time = 20
  ;end select
 ENDIF
 DECLARE v1 = vc WITH protect, noconstant(" ")
 DECLARE v2 = vc WITH protect, noconstant(" ")
 DECLARE v3 = vc WITH protect, noconstant(" ")
 DECLARE v4 = vc WITH protect, noconstant(" ")
 DECLARE v5 = vc WITH protect, noconstant(" ")
 DECLARE v6 = vc WITH protect, noconstant(" ")
 DECLARE v7 = vc WITH protect, noconstant(" ")
 DECLARE v8 = vc WITH protect, noconstant(" ")
 DECLARE v9 = vc WITH protect, noconstant(" ")
 DECLARE v10 = vc WITH protect, noconstant(" ")
 DECLARE v11 = vc WITH protect, noconstant(" ")
 DECLARE v12 = vc WITH protect, noconstant(" ")
 DECLARE v13 = vc WITH protect, noconstant(" ")
 DECLARE v14 = vc WITH protect, noconstant(" ")
 DECLARE v15 = vc WITH protect, noconstant(" ")
 DECLARE v16 = vc WITH protect, noconstant(" ")
 DECLARE v17 = vc WITH protect, noconstant(" ")
 DECLARE v18 = vc WITH protect, noconstant(" ")
 DECLARE v19 = vc WITH protect, noconstant(" ")
 DECLARE v20 = vc WITH protect, noconstant(" ")
 DECLARE v21 = vc WITH protect, noconstant(" ")
 DECLARE v22 = vc WITH protect, noconstant(" ")
 DECLARE v23 = vc WITH protect, noconstant(" ")
 DECLARE v24 = vc WITH protect, noconstant(" ")
 DECLARE v241 = vc WITH protect, noconstant(" ")
 DECLARE v25 = vc WITH protect, noconstant(" ")
 DECLARE v26 = vc WITH protect, noconstant(" ")
 DECLARE v27 = vc WITH protect, noconstant(" ")
 DECLARE v28 = vc WITH protect, noconstant(" ")
 DECLARE v29 = vc WITH protect, noconstant(" ")
 DECLARE v30 = vc WITH protect, noconstant(" ")
 DECLARE v31 = vc WITH protect, noconstant(" ")
 DECLARE v32 = vc WITH protect, noconstant(" ")
 DECLARE va1 = vc WITH protect, noconstant(" ")
 DECLARE va2 = vc WITH protect, noconstant(" ")
 DECLARE va3 = vc WITH protect, noconstant(" ")
 DECLARE va4 = vc WITH protect, noconstant(" ")
 DECLARE vlt1 = vc WITH protect, noconstant(" ")
 DECLARE vlt2 = vc WITH protect, noconstant(" ")
 DECLARE vr1 = vc WITH protect, noconstant(" ")
 DECLARE vr2 = vc WITH protect, noconstant(" ")
 DECLARE vr3 = vc WITH protect, noconstant(" ")
 CALL echo(msg_list)
 SELECT INTO value( $1)
  FROM (dummyt d  WITH seq = value(1))
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   xml_tag = build('<?xml version="1.0" encoding="UTF-8"?>'), col 0, xml_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, col + 1, "<messages>",
   row + 1
   FOR (i = 1 TO size(msg_list->msgs,5))
     col + 1, "<message>", row + 1,
     v1 = build("<taskTypeDisplay>",msg_list->msgs[i].tasktypedisplay,"</taskTypeDisplay>"), col + 1,
     v1,
     row + 1, v2 = build("<taskId>",cnvtint(msg_list->msgs[i].taskid),"</taskId>"), col + 1,
     v2, row + 1, v3 = build("<assigned>",msg_list->msgs[i].assigned,"</assigned>"),
     col + 1, v3, row + 1,
     v4 = build("<createDateTime>",msg_list->msgs[i].createddate,"</createDateTime>"), col + 1, v4,
     row + 1, v5 = build("<senderName>",msg_list->msgs[i].fromuser,"</senderName>"), col + 1,
     v5, row + 1, v6 = build("<senderPrsnlId>",msg_list->msgs[i].senderprsnlid,"</senderPrsnlId>"),
     col + 1, v6, row + 1,
     v7 = build("<patientName>",msg_list->msgs[i].patientname,"</patientName>"), col + 1, v7,
     row + 1, v8 = build("<taskPriorityDisplay>",msg_list->msgs[i].taskprioritydisplay,
      "</taskPriorityDisplay>"), col + 1,
     v8, row + 1, v9 = build("<remindDateTime>",msg_list->msgs[i].reminddatetime,"</remindDateTime>"),
     col + 1, v9, row + 1,
     v10 = build("<taskStatusDisplay>",msg_list->msgs[i].taskstatusdisplay,"</taskStatusDisplay>"),
     col + 1, v10,
     row + 1, v11 = build("<subject>",msg_list->msgs[i].subject,"</subject>"), col + 1,
     v11, row + 1, v12 = build("<receiverName>",msg_list->msgs[i].touser,"</receiverName>"),
     col + 1, v12, row + 1,
     v14 = build("<dueDateTime>",msg_list->msgs[i].duedatetime,"</dueDateTime>"), col + 1, v14,
     row + 1, v15 = build("<statIndicator>",msg_list->msgs[i].statind,"</statIndicator>"), col + 1,
     v15, row + 1, v16 = build("<updateDateTime>",msg_list->msgs[i].updatedatetime,
      "</updateDateTime>"),
     col + 1, v16, row + 1,
     v17 = build("<eventId>",msg_list->msgs[i].eventid,"</eventId>"), col + 1, v17,
     row + 1, v18 = build("<personId>",msg_list->msgs[i].personid,"</personId>"), col + 1,
     v18, row + 1, v19 = build("<encounterId>",msg_list->msgs[i].encounterid,"</encounterId>"),
     col + 1, v19, row + 1,
     v20 = build("<confidentialIndicator>",cnvtint(msg_list->msgs[i].confidentialindicator),
      "</confidentialIndicator>"), col + 1, v20,
     row + 1, v21 = build("<updateCount>",cnvtint(msg_list->msgs[i].updatecount),"</updateCount>"),
     col + 1,
     v21, row + 1, v22 = build("<deliveryIndicator>",cnvtint(msg_list->msgs[i].deliveryindicator),
      "</deliveryIndicator>"),
     col + 1, v22, row + 1,
     v23 = build("<copyMessageIndicator>",msg_list->msgs[i].copymessageindicator,
      "</copyMessageIndicator>"), col + 1, v23,
     row + 1, v24 = build("<eventClassMeaning>",msg_list->msgs[i].eventclassmeaning,
      "</eventClassMeaning>"), col + 1,
     v24, row + 1, v241 = build("<replyAllowedIndicator>",msg_list->msgs[i].replyallowedindicator,
      "</replyAllowedIndicator>"),
     col + 1, v241, row + 1,
     vlt1 = build("<callerName>",msg_list->msgs[i].callername,"</callerName>"), col + 1, vlt1,
     row + 1, vlt2 = build("<callerPhones>",msg_list->msgs[i].callerphones,"</callerPhones>"), col +
     1,
     vlt2, row + 1, col + 1,
     "<actionRequests>", row + 1
     FOR (j = 1 TO size(msg_list->msgs[i].actionrequests,5))
       IF ((msg_list->msgs[i].actionrequests[j].tasksubactivityid > 0))
        col + 1, "<actionRequest>", row + 1,
        va1 = build("<taskSubactivityId>",cnvtint(msg_list->msgs[i].actionrequests[j].
          tasksubactivityid),"</taskSubactivityId>"), col + 1, va1,
        row + 1, va2 = build("<actionRequestCode>",cnvtint(msg_list->msgs[i].actionrequests[j].
          actionrequestcd),"</actionRequestCode>"), col + 1,
        va2, row + 1, va3 = build("<actionRequestDisplay>",msg_list->msgs[i].actionrequests[j].
         actionrequestdisplay,"</actionRequestDisplay>"),
        col + 1, va3, row + 1,
        col + 1, "</actionRequest>", row + 1
       ENDIF
     ENDFOR
     col + 1, "</actionRequests>", row + 1,
     col + 1, "<receivers>", row + 1
     FOR (l = 1 TO size(msg_list->msgs[i].receivers,5))
       IF ((msg_list->msgs[i].receivers[l].assignedprsnlid > 0))
        col + 1, "<receiver>", row + 1,
        vr1 = build("<assignedPrsnlId>",cnvtint(msg_list->msgs[i].receivers[l].assignedprsnlid),
         "</assignedPrsnlId>"), col + 1, vr1,
        row + 1, vr2 = build("<assignedPrsnlName>",msg_list->msgs[i].receivers[l].receiver,
         "</assignedPrsnlName>"), col + 1,
        vr2, row + 1, vr3 = build("<copyType>",msg_list->msgs[i].receivers[l].copytype,"</copyType>"),
        col + 1, vr3, row + 1,
        col + 1, "</receiver>", row + 1
       ENDIF
     ENDFOR
     col + 1, "</receivers>", row + 1,
     col + 1, "</message>", row + 1
   ENDFOR
   col + 1, "</messages>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 32000, format = variable, maxrow = 0,
   time = 10
 ;end select
 FREE RECORD msg_list
END GO
