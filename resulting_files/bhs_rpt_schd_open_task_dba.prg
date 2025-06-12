CREATE PROGRAM bhs_rpt_schd_open_task:dba
 PROMPT
  "Output to File/Printer/MINE " = mine
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 DECLARE intervention_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6026,
   "SCHEDULINGREQUESTS"))
 DECLARE inprocess_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",79,"INPROCESS"))
 DECLARE opened_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",79,"OPENED"))
 DECLARE overdue_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",79,"OVERDUE"))
 DECLARE pending_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE bmc_acct_num_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BMCACCTNBR"))
 SELECT DISTINCT INTO  $1
  p.name_full_formatted, ea.alias, elh_loc_fac = uar_get_code_display(elh.loc_facility_cd),
  elh_nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd), elh_room = uar_get_code_display(elh
   .loc_room_cd), elh_bed = uar_get_code_display(elh.loc_bed_cd),
  t_task_status_disp = uar_get_code_display(t.task_status_cd), o.task_description, t
  .task_create_dt_tm
  FROM task_activity t,
   person p,
   order_task o,
   encounter e,
   encntr_loc_hist elh,
   encntr_alias ea
  PLAN (t
   WHERE t.task_status_cd IN (inprocess_cd, opened_cd, overdue_cd, pending_cd)
    AND t.task_type_cd=intervention_cd)
   JOIN (o
   WHERE o.reference_task_id=t.reference_task_id)
   JOIN (e
   WHERE e.encntr_id=t.encntr_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.location_cd=t.location_cd
    AND elh.active_ind=1
    AND elh.loc_facility_cd != 2583987)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.alias_pool_cd=bmc_acct_num_cd
    AND ea.encntr_id=e.encntr_id)
  ORDER BY p.name_full_formatted, elh_nurse_unit, elh_room
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , row + 1,
   "{F/5}{CPI/7}",
   CALL print(calcpos(198,(y_pos+ 11))), "BMC Surgical Booking",
   row + 1,
   CALL print(calcpos(189,(y_pos+ 30))), "Open Scheduling Requests",
   row + 1, y_pos = (y_pos+ 53)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   row + 1, "{F/0}{CPI/14}", row + 1,
   CALL print(calcpos(20,(y_pos+ 11))), curdate, row + 1,
   "{CPI/12}", row + 1,
   CALL print(calcpos(20,(y_pos+ 47))),
   "Patient Name", row + 1, y_val = ((792 - y_pos) - 69),
   "{PS/newpath 2 setlinewidth 27 ", y_val, " moveto 563 ",
   y_val, " lineto stroke 27 ", y_val,
   " moveto/}",
   CALL print(calcpos(140,(y_pos+ 47))), "FIN",
   CALL print(calcpos(210,(y_pos+ 47))), "Location",
   CALL print(calcpos(292,(y_pos+ 47))),
   "Intervention Type",
   CALL print(calcpos(470,(y_pos+ 47))), "Status",
   CALL print(calcpos(518,(y_pos+ 47))), "Open Date", row + 1,
   y_pos = (y_pos+ 62)
  DETAIL
   IF (((y_pos+ 115) >= 792))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,20,p.name_full_formatted), fin = substring(1,10,ea.alias),
   ed_loc_nurse_unit_disp1 = substring(1,15,elh_nurse_unit),
   ed_loc_room_disp1 = substring(1,5,elh_room), ed_loc_bed_disp1 = substring(1,4,elh_bed),
   task_description1 = substring(1,35,o.task_description),
   t_task_status_disp1 = substring(1,10,t_task_status_disp), row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))), name_full_formatted1,
   CALL print(calcpos(125,(y_pos+ 11))),
   fin,
   CALL print(calcpos(198,(y_pos+ 11))), ed_loc_nurse_unit_disp1,
   CALL print(calcpos(232,(y_pos+ 11))), ed_loc_room_disp1,
   CALL print(calcpos(258,(y_pos+ 11))),
   ed_loc_bed_disp1,
   CALL print(calcpos(281,(y_pos+ 11))), task_description1,
   CALL print(calcpos(465,(y_pos+ 11))), t_task_status_disp1,
   CALL print(calcpos(522,(y_pos+ 11))),
   t.task_create_dt_tm, y_pos = (y_pos+ 13)
  FOOT PAGE
   y_pos = 708, row + 1, "{F/0}{CPI/12}",
   row + 1,
   CALL print(calcpos(288,(y_pos+ 11))), curpage,
   row + 1, row + 1, "{CPI/14}",
   row + 1,
   CALL print(calcpos(20,(y_pos+ 29))), curprog
  WITH maxcol = 300, maxrow = 500, time = value(maxsecs),
   dio = 08, noheading, format = variable
 ;end select
END GO
