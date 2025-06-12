CREATE PROGRAM bhs_prax_get_msg_details
 DECLARE phonemsg = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"PHONEMSG"))
 DECLARE reminder = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"REMINDER"))
 DECLARE consult = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"CONSULT"))
 DECLARE notification = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"NOTIFICATION"))
 DECLARE pending = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",79,"PENDING"))
 DECLARE opened = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",79,"OPENED"))
 SET where_params = build("ta.task_type_cd in"," ", $3)
 SELECT INTO  $1
  assigned = trim(replace(replace(replace(replace(replace(pr1.name_full_formatted,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), create_date = format(ta
   .task_create_dt_tm,"DD MMM YYYY HH:MM;;d"), from_user = trim(replace(replace(replace(replace(
       replace(prsnl.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3),
  patient_name = trim(replace(replace(replace(replace(replace(p.name_full_formatted,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), priority = trim(replace(
    replace(replace(replace(replace(uar_get_code_display(ta.task_priority_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), show_up_date = format(ta
   .remind_dt_tm,"DD MMM YYYY HH:MM;;d"),
  status = trim(replace(replace(replace(replace(replace(uar_get_code_display(taa.task_status_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), subject = trim(
   replace(replace(replace(replace(replace(ta.msg_subject,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
     "'","&apos;",0),'"',"&quot;",0),3), to_user = trim(replace(replace(replace(replace(replace(pr2
        .name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3),
  task_id = ta.task_id, type = trim(replace(replace(replace(replace(replace(uar_get_code_display(ta
         .task_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  due_dt_tm = format(ta.scheduled_dt_tm,"DD MMM YYYY HH:MM;;d"),
  update_dt_tm = format(ta.updt_dt_tm,"DD MMM YYYY HH:MM;;d"), task_subact_id = cnvtint(tsa
   .task_subactivity_id), action_req_cd = cnvtint(tsa.action_request_cd),
  action_req_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(tsa
         .action_request_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), action_req_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(tsa
         .action_request_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), event_id = trim(replace(cnvtstring(ta.event_id),".0*","",0),3),
  person_id = trim(replace(cnvtstring(ta.person_id),".0*","",0),3), encounter_id = trim(replace(
    cnvtstring(ta.encntr_id),".0*","",0),3), copy_message =
  IF (cnvtint(taa.copy_type_flag)=1) "TRUE"
  ELSE "FALSE"
  ENDIF
  ,
  event_class = uar_get_code_meaning(ta.event_class_cd)
  FROM task_activity ta,
   task_activity_assignment taa,
   prsnl prsnl,
   prsnl pr1,
   prsnl pr2,
   person p,
   task_subactivity tsa
  PLAN (ta
   WHERE parser(where_params))
   JOIN (p
   WHERE p.person_id=ta.person_id)
   JOIN (taa
   WHERE ta.task_id=taa.task_id
    AND taa.task_status_cd IN (pending, opened)
    AND taa.assign_prsnl_id=cnvtint( $2)
    AND (taa.updt_dt_tm > (sysdate - 30)))
   JOIN (prsnl
   WHERE ta.msg_sender_id=prsnl.person_id)
   JOIN (pr1
   WHERE pr1.person_id=taa.assign_person_id)
   JOIN (pr2
   WHERE pr2.person_id=taa.assign_prsnl_id)
   JOIN (tsa
   WHERE tsa.task_id=outerjoin(ta.task_id))
  ORDER BY taa.updt_dt_tm DESC, ta.task_id
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD ta.task_id
   header_grp = build("<","Message",">"), col + 1, header_grp,
   row + 1, val11 = build("<Type>",type,"</Type>"), col + 1,
   val11, row + 1, val10 = build("<TaskID>",cnvtint(task_id),"</TaskID>"),
   col + 1, val10, row + 1,
   val1 = build("<Assigned>",assigned,"</Assigned>"), col + 1, val1,
   row + 1, val2 = build("<CreateDateTime>",create_date,"</CreateDateTime>"), col + 1,
   val2, row + 1, val3 = build("<SenderName>",from_user,"</SenderName>"),
   col + 1, val3, row + 1,
   val31 = build("<SenderPrsnlId>",ta.msg_sender_id,"</SenderPrsnlId>"), col + 1, val31,
   row + 1, val4 = build("<PatientName>",patient_name,"</PatientName>"), col + 1,
   val4, row + 1, val5 = build("<Priority>",priority,"</Priority>"),
   col + 1, val5, row + 1,
   val6 = build("<ShowUpDate>",show_up_date,"</ShowUpDate>"), col + 1, val6,
   row + 1, val7 = build("<Status>",status,"</Status>"), col + 1,
   val7, row + 1, val8 = build("<Subject>",subject,"</Subject>"),
   col + 1, val8, row + 1,
   val9 = build("<Receiver>",to_user,"</Receiver>"), col + 1, val9,
   row + 1, val13 = build("<DueDateTime>",due_dt_tm,"</DueDateTime>"), col + 1,
   val13, row + 1, val14 = build("<Stat>",
    IF (ta.stat_ind=1) "Yes"
    ELSE "No"
    ENDIF
    ,"</Stat>"),
   col + 1, val14, row + 1,
   val15 = build("<UpdateDateTime>",update_dt_tm,"</UpdateDateTime>"), col + 1, val15,
   row + 1, val16 = build("<EventId>",event_id,"</EventId>"), col + 1,
   val16, row + 1, val17 = build("<PersonId>",person_id,"</PersonId>"),
   col + 1, val17, row + 1,
   val18 = build("<EncounterId>",encounter_id,"</EncounterId>"), col + 1, val18,
   row + 1, val19 = build("<ConfidentialIndicator>",cnvtint(ta.confidential_ind),
    "</ConfidentialIndicator>"), col + 1,
   val19, row + 1, val20 = build("<UpdateCount>",cnvtint(ta.updt_cnt),"</UpdateCount>"),
   col + 1, val20, row + 1,
   val21 = build("<DeliveryIndicator>",cnvtint(ta.delivery_ind),"</DeliveryIndicator>"), col + 1,
   val21,
   row + 1, val22 = build("<CopyMessageIndicator>",copy_message,"</CopyMessageIndicator>"), col + 1,
   val22, row + 1, val23 = build("<EventClass>",event_class,"</EventClass>"),
   col + 1, val23, row + 1
  HEAD tsa.task_subactivity_id
   IF (tsa.task_subactivity_id != 0)
    col + 1, "<ActionRequest>", row + 1,
    vtsa1 = build("<TaskSubactivityId>",task_subact_id,"</TaskSubactivityId>"), col + 1, vtsa1,
    row + 1, vtsa2 = build("<ActionRequestCD>",action_req_cd,"</ActionRequestCD>"), col + 1,
    vtsa2, row + 1, vtsa3 = build("<ActionRequestDisplay>",action_req_disp,"</ActionRequestDisplay>"),
    col + 1, vtsa3, row + 1,
    vtsa4 = build("<ActionRequestMeaning>",action_req_mean,"</ActionRequestMeaning>"), col + 1, vtsa4,
    row + 1, col + 1, "</ActionRequest>",
    row + 1
   ENDIF
  FOOT  ta.task_id
   foot_grp = build("</","Message",">"), col + 1, foot_grp,
   row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 50000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
