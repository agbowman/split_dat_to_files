CREATE PROGRAM bhs_prax_get_message_count
 DECLARE prsnl_id = f8 WITH constant( $2)
 DECLARE phonemsg = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"PHONEMSG"))
 DECLARE reminder = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"REMINDER"))
 DECLARE consult = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"CONSULT"))
 DECLARE notification = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6026,"NOTIFICATION"))
 DECLARE pending = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",79,"PENDING"))
 DECLARE opened = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",79,"OPENED"))
 DECLARE total_count = i4 WITH noconstant(0)
 DECLARE doc_count = i4 WITH noconstant(0)
 DECLARE ord_count = i4 WITH noconstant(0)
 DECLARE res_count = i4 WITH noconstant(0)
 DECLARE reminder_count = i4 WITH noconstant(0)
 DECLARE phone_msg_count = i4 WITH noconstant(0)
 DECLARE consult_count = i4 WITH noconstant(0)
 DECLARE notification_count = i4 WITH noconstant(0)
 DECLARE inbox_ord_count = i4 WITH noconstant(0)
 DECLARE proxy_ord_count = i4 WITH noconstant(0)
 DECLARE group_ord_count = i4 WITH noconstant(0)
 SELECT INTO "NL:"
  t.task_id, t_event_class_mean = trim(cnvtlower(uar_get_code_meaning(t.event_class_cd)),3)
  FROM task_activity t,
   task_activity_assignment ta
  PLAN (t
   WHERE t.active_ind=1
    AND t.event_class_cd != 0)
   JOIN (ta
   WHERE ta.task_id=t.task_id
    AND ta.assign_prsnl_id=prsnl_id
    AND ta.task_status_cd IN (pending, opened)
    AND ta.beg_eff_dt_tm < sysdate
    AND ta.end_eff_dt_tm > sysdate)
  ORDER BY t.task_id
  HEAD t.task_id
   IF (((t_event_class_mean="mdoc") OR (((t_event_class_mean="doc") OR (((t_event_class_mean=
   "clindoc") OR (((t_event_class_mean="document") OR (((t_event_class_mean="grpdoc") OR (((
   t_event_class_mean="scdocument") OR (t_event_class_mean="attachment")) )) )) )) )) )) )
    total_count = (total_count+ 1), doc_count = (doc_count+ 1)
   ENDIF
  WITH time = 20
 ;end select
 SELECT INTO "NL:"
  t.task_id, t_event_class_mean = trim(cnvtlower(uar_get_code_meaning(t.event_class_cd)),3)
  FROM task_activity t,
   task_activity_assignment ta,
   clinical_event ce
  PLAN (t
   WHERE t.active_ind=1
    AND t.task_activity_cd IN (2704, 2705)
    AND t.event_class_cd != 0)
   JOIN (ta
   WHERE ta.task_id=t.task_id
    AND ta.assign_prsnl_id=prsnl_id
    AND ta.task_status_cd IN (pending, opened)
    AND ta.beg_eff_dt_tm < sysdate
    AND ta.end_eff_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.event_id=t.event_id
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY t.task_id
  HEAD t.task_id
   IF (((t_event_class_mean="num") OR (((t_event_class_mean="txt") OR (((t_event_class_mean="grp")
    OR (((t_event_class_mean="hlatyping") OR (((t_event_class_mean="trans") OR (((t_event_class_mean=
   "io") OR (((t_event_class_mean="mbo") OR (((t_event_class_mean="interp") OR (((t_event_class_mean=
   "count") OR (t_event_class_mean="rad")) )) )) )) )) )) )) )) )) )
    total_count = (total_count+ 1), res_count = (res_count+ 1)
   ENDIF
  WITH time = 20
 ;end select
 SELECT INTO "NL:"
  ta.task_type_cd, type = trim(replace(replace(replace(replace(replace(uar_get_code_display(ta
         .task_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE ta.task_type_cd IN (phonemsg, reminder, consult, notification)
    AND ta.active_ind=1)
   JOIN (taa
   WHERE ta.task_id=taa.task_id
    AND taa.task_status_cd IN (pending, opened)
    AND taa.assign_prsnl_id=prsnl_id
    AND (taa.updt_dt_tm > (sysdate - 30))
    AND taa.beg_eff_dt_tm < sysdate
    AND taa.end_eff_dt_tm > sysdate)
  ORDER BY ta.task_id
  HEAD ta.task_id
   total_count = (total_count+ 1)
   IF (ta.task_type_cd=phonemsg)
    phone_msg_count = (phone_msg_count+ 1)
   ELSEIF (ta.task_type_cd=reminder)
    reminder_count = (reminder_count+ 1)
   ELSEIF (ta.task_type_cd=consult)
    consult_count = (consult_count+ 1)
   ELSEIF (ta.task_type_cd=notification)
    notification_count = (notification_count+ 1)
   ENDIF
  WITH time = 20
 ;end select
 SELECT DISTINCT INTO "NL:"
  o.order_notification_id
  FROM order_notification o,
   order_action oa,
   dm_flags dm1
  PLAN (o
   WHERE o.to_prsnl_id=prsnl_id
    AND o.notification_status_flag=1
    AND o.notification_type_flag IN (1, 2)
    AND o.notification_display_dt_tm BETWEEN (sysdate - 30) AND sysdate)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.inactive_flag=0
    AND oa.action_personnel_id != 1)
   JOIN (dm1
   WHERE dm1.table_name="ORDER_NOTIFICATION"
    AND dm1.column_name="NOTIFICATION_TYPE_FLAG"
    AND dm1.flag_value=o.notification_type_flag)
  ORDER BY o.order_id
  HEAD o.order_notification_id
   total_count = (total_count+ 1), ord_count = (ord_count+ 1), inbox_ord_count = (inbox_ord_count+ 1)
  WITH time = 30
 ;end select
 SELECT DISTINCT INTO "NL:"
  o.order_notification_id
  FROM proxy px,
   order_notification o,
   order_action oa,
   dm_flags dm1
  PLAN (px
   WHERE px.person_id=prsnl_id
    AND px.end_effective_dt_tm > sysdate
    AND px.beg_effective_dt_tm < sysdate
    AND px.active_ind=1)
   JOIN (o
   WHERE o.to_prsnl_id=px.proxy_person_id
    AND o.notification_status_flag=1
    AND o.notification_type_flag IN (1, 2)
    AND o.notification_display_dt_tm BETWEEN (sysdate - 30) AND sysdate)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.inactive_flag=0
    AND oa.action_personnel_id != 1)
   JOIN (dm1
   WHERE dm1.table_name="ORDER_NOTIFICATION"
    AND dm1.column_name="NOTIFICATION_TYPE_FLAG"
    AND dm1.flag_value=o.notification_type_flag)
  ORDER BY o.order_id
  HEAD o.order_notification_id
   total_count = (total_count+ 1), ord_count = (ord_count+ 1), proxy_ord_count = (proxy_ord_count+ 1)
  WITH time = 30
 ;end select
 SELECT DISTINCT
  o.order_notification_id
  FROM prsnl_group_reltn pg,
   order_notification o,
   order_action oa,
   dm_flags dm1
  PLAN (pg
   WHERE pg.person_id=prsnl_id
    AND pg.active_ind=1)
   JOIN (o
   WHERE o.to_prsnl_group_id=pg.prsnl_group_id
    AND o.notification_status_flag=1
    AND o.notification_type_flag IN (1, 2)
    AND o.notification_display_dt_tm BETWEEN (sysdate - 30) AND sysdate)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.inactive_flag=0
    AND oa.action_personnel_id != 1)
   JOIN (dm1
   WHERE dm1.table_name="ORDER_NOTIFICATION"
    AND dm1.column_name="NOTIFICATION_TYPE_FLAG"
    AND dm1.flag_value=o.notification_type_flag)
  ORDER BY o.order_id
  HEAD o.order_notification_id
   total_count = (total_count+ 1), ord_count = (ord_count+ 1), group_ord_count = (group_ord_count+ 1)
  WITH time = 30
 ;end select
 SELECT INTO  $1
  FROM dummyt d1
  PLAN (d1)
  HEAD REPORT
   html_tag = build("<?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, totl_cnt = build("<TotalCount>",total_count,"</TotalCount>"), col + 1,
   totl_cnt, row + 1, doc_cnt = build("<DocumentCount>",doc_count,"</DocumentCount>"),
   col + 1, doc_cnt, row + 1,
   ord_cnt = build("<OrderCount>",ord_count,"</OrderCount>"), col + 1, ord_cnt,
   row + 1, res_cnt = build("<ResultCount>",res_count,"</ResultCount>"), col + 1,
   res_cnt, row + 1, rem_cnt = build("<ReminderCount>",reminder_count,"</ReminderCount>"),
   col + 1, rem_cnt, row + 1,
   phn_msg_cnt = build("<PhoneMsgCount>",phone_msg_count,"</PhoneMsgCount>"), col + 1, phn_msg_cnt,
   row + 1, consult_cnt = build("<ConsultCount>",consult_count,"</ConsultCount>"), col + 1,
   consult_cnt, row + 1, not_cnt = build("<NotificationCount>",notification_count,
    "</NotificationCount>"),
   col + 1, not_cnt, row + 1,
   inbox_ord_cnt = build("<InboxOrderCount>",inbox_ord_count,"</InboxOrderCount>"), col + 1,
   inbox_ord_cnt,
   row + 1, proxy_ord_cnt = build("<ProxyOrderCount>",proxy_ord_count,"</ProxyOrderCount>"), col + 1,
   proxy_ord_cnt, row + 1, group_ord_cnt = build("<GroupOrderCount>",group_ord_count,
    "</GroupOrderCount>"),
   col + 1, group_ord_cnt, row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
