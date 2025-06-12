CREATE PROGRAM djh_l_phone_file
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 300
 ENDIF
 SELECT INTO  $OUTDEV
  ph.active_ind, ph.active_status_cd, ph_active_status_disp = uar_get_code_display(ph
   .active_status_cd),
  ph.active_status_dt_tm, ph.active_status_prsnl_id, ph.beg_effective_dt_tm,
  ph.beg_effective_mm_dd, ph.call_instruction, ph.contact,
  ph.contributor_system_cd, ph_contributor_system_disp = uar_get_code_display(ph
   .contributor_system_cd), ph.data_status_cd,
  ph_data_status_disp = uar_get_code_display(ph.data_status_cd), ph.data_status_dt_tm, ph
  .data_status_prsnl_id,
  ph.description, ph.end_effective_dt_tm, ph.end_effective_mm_dd,
  ph.extension, ph.long_text_id, ph.modem_capability_cd,
  ph_modem_capability_disp = uar_get_code_display(ph.modem_capability_cd), ph.operation_hours, ph
  .paging_code,
  ph.parent_entity_id, ph.parent_entity_name, ph.phone_format_cd,
  ph_phone_format_disp = uar_get_code_display(ph.phone_format_cd), ph.phone_id, ph.phone_num,
  ph.phone_type_cd, ph_phone_type_disp = uar_get_code_display(ph.phone_type_cd), ph.phone_type_seq,
  ph.rowid, ph.updt_applctx, ph.updt_cnt,
  ph.updt_dt_tm, ph.updt_id, ph.updt_task
  FROM phone ph
  WHERE ph.active_ind > 0
   AND ph.active_status_cd=188
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(26,(y_pos+ 0))), curdate,
   row + 1, "{CPI/13}", row + 1,
   CALL print(calcpos(240,(y_pos+ 0))), "Active PON Physician List", row + 1,
   row + 1, y_val = ((792 - y_pos) - 57), "{PS/newpath 2 setlinewidth   20 ",
   y_val, " moveto  522 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   CALL print(calcpos(36,(y_pos+ 23))), "Log In", row + 1,
   "{CPI/13}",
   CALL print(calcpos(42,(y_pos+ 33))), "ID",
   row + 1, "{CPI/13}",
   CALL print(calcpos(126,(y_pos+ 34))),
   "Name", row + 1, "{CPI/14}",
   CALL print(calcpos(281,(y_pos+ 33))), "CIS Position", row + 1,
   "{CPI/14}",
   CALL print(calcpos(434,(y_pos+ 24))), "Create/Change",
   CALL print(calcpos(456,(y_pos+ 33))), "Date", row + 1,
   y_pos = (y_pos+ 60)
  DETAIL
   IF (((y_pos+ 99) >= 792))
    y_pos = 0, BREAK
   ENDIF
   username1 = substring(1,9,p.username), p_position_disp1 = substring(1,32,p_position_disp),
   name_full_formatted1 = substring(1,35,p.name_full_formatted),
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(37,(y_pos+ 0))),
   username1,
   CALL print(calcpos(89,(y_pos+ 1))), name_full_formatted1,
   CALL print(calcpos(270,(y_pos+ 0))), p_position_disp1,
   CALL print(calcpos(448,(y_pos+ 1))),
   p.updt_dt_tm, y_pos = (y_pos+ 14)
  FOOT PAGE
   y_pos = 725, row + 1,
   CALL print(calcpos(20,(y_pos+ 1))),
   "PROG:", row + 1,
   CALL print(calcpos(51,(y_pos+ 1))),
   curprog, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(367,(y_pos+ 0))), "Page:", row + 1,
   CALL print(calcpos(383,(y_pos+ 0))), curpage
  FOOT REPORT
   IF (((y_pos+ 76) >= 792))
    y_pos = 0, BREAK
   ELSE
    y_pos = (y_pos+ 36)
   ENDIF
   row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 0))),
   "Physician Count:", cntmd = format(count(p.name_full_formatted),"####"), row + 1,
   CALL print(calcpos(107,(y_pos+ 1))), cntmd, row + 1,
   CALL print(calcpos(271,(y_pos+ 14))), "End of Report"
  WITH maxrec = 10, maxcol = 300, maxrow = 500,
   dio = 08, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
