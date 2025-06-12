CREATE PROGRAM bhs_eco_queue_fix_v2
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
 EXECUTE bhs_sys_stand_subroutine
 DECLARE output_dest = vc
 IF (findstring("@", $1) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $1
 ENDIF
 FREE RECORD ordstatus
 RECORD ordstatus(
   1 list[11]
     2 order_status_cd = f8
 )
 SET ordstatus->list[1].order_status_cd = uar_get_code_by("MEANING",6004,"CANCELED")
 SET ordstatus->list[2].order_status_cd = uar_get_code_by("MEANING",6004,"COMPLETED")
 SET ordstatus->list[3].order_status_cd = uar_get_code_by("MEANING",6004,"DELETED")
 SET ordstatus->list[4].order_status_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
 SET ordstatus->list[5].order_status_cd = uar_get_code_by("MEANING",6004,"FUTURE")
 SET ordstatus->list[6].order_status_cd = uar_get_code_by("MEANING",6004,"INCOMPLETE")
 SET ordstatus->list[7].order_status_cd = uar_get_code_by("MEANING",6004,"INPROCESS")
 SET ordstatus->list[8].order_status_cd = uar_get_code_by("MEANING",6004,"MEDSTUDENT")
 SET ordstatus->list[9].order_status_cd = uar_get_code_by("MEANING",6004,"UNSCHEDULED")
 SET ordstatus->list[10].order_status_cd = uar_get_code_by("MEANING",6004,"TRANS/CANCEL")
 SET ordstatus->list[11].order_status_cd = uar_get_code_by("MEANING",6004,"VOIDEDWRSLT")
 FREE RECORD ecoreq
 RECORD ecoreq(
   1 list[*]
     2 pat_name = vc
     2 fin = vc
     2 facility = vc
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 order_id = f8
     2 hna_order_mnemonic = vc
     2 clinical_display_line = vc
     2 order_status = vc
     2 last_order_action = vc
     2 orig_order_dt_tm = dq8
     2 current_start_dt_tm = dq8
     2 projected_stop_dt_tm = dq8
     2 discontinue_effective_dt_tm = dq8
     2 last_instance_dt_tm = dq8
     2 next_instance_dt_tm = dq8
 )
 DECLARE cnt = i4
 DECLARE idx = i4
 SELECT INTO "nl:"
  pat_name = trim(p.name_full_formatted), fin = trim(ea.alias), facility = trim(uar_get_code_display(
    e.loc_facility_cd)),
  e.reg_dt_tm, e.disch_dt_tm, o.order_id,
  o.hna_order_mnemonic, o.clinical_display_line, ord_stts = trim(uar_get_code_display(o
    .order_status_cd)),
  last_order_action = trim(uar_get_code_display(oa.action_type_cd)), o.orig_order_dt_tm, o
  .current_start_dt_tm,
  o.projected_stop_dt_tm, o.discontinue_effective_dt_tm, eq.last_instance_dt_tm,
  eq.next_instance_dt_tm
  FROM eco_queue eq,
   eco_action_queue eaq,
   orders o,
   person p,
   encounter e,
   encntr_alias ea,
   order_action oa
  PLAN (eq)
   JOIN (o
   WHERE eq.order_id=o.order_id
    AND expand(idx,1,11,o.order_status_cd,ordstatus->list[idx].order_status_cd)
    AND ((o.projected_stop_dt_tm <= cnvtdatetime((curdate - 1),curtime3)) OR (o.projected_stop_dt_tm=
   null)) )
   JOIN (eaq
   WHERE eaq.order_id=o.order_id
    AND eaq.effective_dt_tm < cnvtdatetime((curdate - 1),curtime))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND  NOT ( EXISTS (
   (SELECT
    oa2.order_action_id
    FROM order_action oa2
    WHERE oa2.order_id=oa.order_id
     AND oa2.action_sequence > oa.action_sequence))))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.active_ind=outerjoin(1)
    AND ea.encntr_alias_type_cd=outerjoin(1077))
  ORDER BY last_order_action, ord_stts
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ecoreq->list,(cnt+ 9))
   ENDIF
   ecoreq->list[cnt].order_id = o.order_id, ecoreq->list[cnt].hna_order_mnemonic = o
   .hna_order_mnemonic, ecoreq->list[cnt].clinical_display_line = o.clinical_display_line,
   ecoreq->list[cnt].order_status = ord_stts, ecoreq->list[cnt].last_order_action = last_order_action,
   ecoreq->list[cnt].orig_order_dt_tm = o.orig_order_dt_tm,
   ecoreq->list[cnt].current_start_dt_tm = o.current_start_dt_tm, ecoreq->list[cnt].
   projected_stop_dt_tm = o.projected_stop_dt_tm, ecoreq->list[cnt].discontinue_effective_dt_tm = o
   .discontinue_effective_dt_tm,
   ecoreq->list[cnt].last_instance_dt_tm = eq.last_instance_dt_tm, ecoreq->list[cnt].
   next_instance_dt_tm = eq.next_instance_dt_tm, ecoreq->list[cnt].pat_name = pat_name,
   ecoreq->list[cnt].fin = fin, ecoreq->list[cnt].facility = facility, ecoreq->list[cnt].reg_dt_tm =
   e.reg_dt_tm,
   ecoreq->list[cnt].disch_dt_tm = e.disch_dt_tm
  FOOT REPORT
   stat = alterlist(ecoreq->list,cnt)
  WITH nocounter
 ;end select
 DELETE  FROM eco_queue eq,
   (dummyt d  WITH seq = value(cnt))
  SET eq.seq = 1
  PLAN (d
   WHERE (ecoreq->list[d.seq].last_order_action="Reschedule"))
   JOIN (eq
   WHERE (eq.order_id=ecoreq->list[d.seq].order_id))
  WITH counter
 ;end delete
 COMMIT
 DELETE  FROM eco_action_queue eq,
   (dummyt d  WITH seq = value(cnt))
  SET eq.seq = 1
  PLAN (d
   WHERE (ecoreq->list[d.seq].last_order_action="Reschedule"))
   JOIN (eq
   WHERE (eq.order_id=ecoreq->list[d.seq].order_id))
  WITH counter
 ;end delete
 COMMIT
 DECLARE output_line = vc
 SELECT INTO value(output_dest)
  FROM (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (ecoreq->list[d.seq].last_order_action != "Reschedule"))
  HEAD REPORT
   output_line = concat(',"Patient Name","Fin","Facility","Reg Date","Discharge Date","Order Id"',
    ',"Order Mnemonic","Order Details","Order Status","Last Order Action"',
    ',"Originial Order Date","Current Start Date","Project Stop Date"',
    ',"Discontinue Date","Last Instance Date","Next Instance Date",'), col 1, output_line,
   row + 1
  DETAIL
   orig_order_dt_disp = format(ecoreq->list[d.seq].orig_order_dt_tm,"MM/DD/YYYY;;D"),
   current_start_dt_disp = format(ecoreq->list[d.seq].current_start_dt_tm,"MM/DD/YYYY;;D"),
   projected_stop_dt_disp = format(ecoreq->list[d.seq].projected_stop_dt_tm,"MM/DD/YYYY;;D"),
   discontinue_dt_disp = format(ecoreq->list[d.seq].discontinue_effective_dt_tm,"MM/DD/YYYY;;D"),
   last_instance_dt_disp = format(ecoreq->list[d.seq].last_instance_dt_tm,"MM/DD/YYYY;;D"),
   next_instance_dt_disp = format(ecoreq->list[d.seq].next_instance_dt_tm,"MM/DD/YYYY;;D"),
   reg_dt_disp = format(ecoreq->list[d.seq].reg_dt_tm,"MM/DD/YYYY;;D"), disch_dt_disp = format(ecoreq
    ->list[d.seq].disch_dt_tm,"MM/DD/YYYY;;D"), output_line = build(',"',ecoreq->list[d.seq].pat_name,
    '","',ecoreq->list[d.seq].fin,'","',
    ecoreq->list[d.seq].facility,'",',reg_dt_disp,",",disch_dt_disp,
    ",",ecoreq->list[d.seq].order_id,',"',ecoreq->list[d.seq].hna_order_mnemonic,'","',
    ecoreq->list[d.seq].clinical_display_line,'","',ecoreq->list[d.seq].order_status,'","',ecoreq->
    list[d.seq].last_order_action,
    '",',orig_order_dt_disp,",",current_start_dt_disp,",",
    projected_stop_dt_disp,",",discontinue_dt_disp,",",last_instance_dt_disp,
    ",",next_instance_dt_disp,","),
   col 1, output_line, row + 1
  WITH counter, maxcol = 1000, nullreport
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,concat(trim(curprog)," - BMC Extra ECO Queue entries"),
   1)
 ENDIF
#exit_prog
END GO
