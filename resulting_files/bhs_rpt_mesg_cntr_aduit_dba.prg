CREATE PROGRAM bhs_rpt_mesg_cntr_aduit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician Sign-On" = ""
  WITH outdev, prompt1
 SET  $2 = "EN12448"
 FREE RECORD temp
 RECORD temp(
   1 msg[*]
     2 date = vc
     2 title = vc
     2 status = vc
     2 patinet = vc
     2 acct# = vc
   1 doc[*]
   1 ord[*]
 )
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta,
   prsnl pr,
   person p
  PLAN (pr
   WHERE (pr.username= $2))
   JOIN (taa
   WHERE taa.assign_prsnl_id=pr.person_id
    AND taa.task_status_cd=429)
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.task_type_cd=2678)
   JOIN (p
   WHERE p.person_id=ta.person_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->msg,cnt), temp->msg[cnt].date = format(taa.beg_eff_dt_tm,
    "mm/dd/yyyy hh:mm;;q"),
   temp->msg[cnt].patinet = trim(p.name_full_formatted,3), temp->msg[cnt].status = trim(
    uar_get_code_display(taa.task_status_cd)), temp->msg[cnt].title = trim(ta.msg_subject,3)
  WITH nocounter
 ;end select
 CALL echorecord(temp)
END GO
