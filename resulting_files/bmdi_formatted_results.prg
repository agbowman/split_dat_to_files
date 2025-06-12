CREATE PROGRAM bmdi_formatted_results
 DECLARE startdate = vc
 DECLARE enddate = vc
 DECLARE monid = vc
 DECLARE personid = f8
 SET startdate = ""
 SET enddate = ""
 SET monid = ""
 SET personid = 0.0
#main_menu
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,20,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"VIEW FORMATTED RESULTS")
 CALL box(6,9,18,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," MAIN MENU")
 CALL text(9,11," 1. View all results")
 CALL text(11,11," 2. View results by clinical date and time range")
 CALL text(13,11," 3. View results by monitor")
 CALL text(15,11," 4. View result by patient")
 CALL text(17,11," 5. Back to main menu")
 CALL text(22,2,"Select an item number:  ")
 CALL accept(22,25,"99",0
  WHERE curaccept >= 0
   AND curaccept <= 6)
 CASE (curaccept)
  OF 1:
   GO TO view_all
  OF 2:
   GO TO view_by_date_time
  OF 3:
   GO TO view_by_monitor
  OF 4:
   GO TO view_by_patient
  ELSE
   GO TO exit_script
 ENDCASE
#view_all
 CALL clear(1,1)
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT INTO mine
  clinical_dt_tm = substring(1,25,format(bar.clinical_dt_tm,";;Q")), event_cd = uar_get_code_display(
   bdp.event_cd), result = substring(1,10,bar.result_val),
  device_alias = substring(1,15,bmd.device_alias), service_resource = uar_get_code_display(bmd
   .device_cd), acquired_dt_tm = substring(1,25,format(bar.acquired_dt_tm,";;Q")),
  updt_dt_tm = substring(1,25,format(bar.updt_dt_tm,";;Q")), bar.person_id, person_name = substring(1,
   20,p.name_full_formatted)
  FROM bmdi_acquired_results bar,
   bmdi_monitored_device bmd,
   bmdi_device_parameter bdp,
   person p
  PLAN (bar)
   JOIN (bdp
   WHERE bar.device_parameter_id=bdp.device_parameter_id)
   JOIN (bmd
   WHERE bar.monitored_device_id=bmd.monitored_device_id)
   JOIN (p
   WHERE bar.person_id=p.person_id)
  ORDER BY bar.result_id DESC
  WITH nocounter
 ;end select
 GO TO main_menu
#view_by_date_time
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,19,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"VIEW FORMATTED RESULTS")
 CALL box(6,9,17,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," BY DATE AND TIME")
 CALL text(9,11," Enter all dates in the format of DD-MMM-YYYY HH:MM:SS")
 CALL text(10,11," For example: 06-JUL-2005 13:35:00")
 CALL text(12,11," Enter a start date: ")
 CALL accept(12,35,"P(20);CU)","")
 SET startdate = curaccept
 CALL text(14,11," Enter a end date: ")
 CALL accept(14,35,"P(20);CU","")
 SET enddate = curaccept
 IF (((startdate="") OR (enddate="")) )
  CALL text(22,2," Invalid date entered. Press any key to continue")
  CALL accept(22,51,"P(1)")
  GO TO view_by_date_time
 ENDIF
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT INTO mine
  clinical_dt_tm = substring(1,25,format(bar.clinical_dt_tm,";;Q")), event_cd = uar_get_code_display(
   bdp.event_cd), result = substring(1,10,bar.result_val),
  device_alias = substring(1,15,bmd.device_alias), service_resource = uar_get_code_display(bmd
   .device_cd), acquired_dt_tm = substring(1,25,format(bar.acquired_dt_tm,";;Q")),
  updt_dt_tm = substring(1,25,format(bar.updt_dt_tm,";;Q")), bar.person_id, person_name = substring(1,
   20,p.name_full_formatted)
  FROM bmdi_acquired_results bar,
   bmdi_monitored_device bmd,
   bmdi_device_parameter bdp,
   person p
  PLAN (bar
   WHERE bar.clinical_dt_tm >= cnvtdatetime(startdate)
    AND bar.clinical_dt_tm <= cnvtdatetime(enddate))
   JOIN (bdp
   WHERE bar.device_parameter_id=bdp.device_parameter_id)
   JOIN (bmd
   WHERE bar.monitored_device_id=bmd.monitored_device_id)
   JOIN (p
   WHERE bar.person_id=p.person_id)
  ORDER BY bar.result_id DESC
  WITH nocounter
 ;end select
 GO TO main_menu
#view_by_monitor
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,12,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"VIEW FORMATTED RESULTS")
 CALL box(6,9,10,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," BY MONITOR")
 CALL text(9,11," Enter a valid monitor ID to search by: ")
 CALL accept(9,55,"P(15);C","")
 SET monid = curaccept
 IF (monid="")
  CALL text(14,2," Invalid monitor entered. Press any key to continue")
  CALL accept(14,56,"P(1)")
  GO TO view_by_monitor
 ENDIF
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT INTO mine
  clinical_dt_tm = substring(1,25,format(bar.clinical_dt_tm,";;Q")), event_cd = uar_get_code_display(
   bdp.event_cd), result = substring(1,10,bar.result_val),
  device_alias = substring(1,15,bmd.device_alias), service_resource = uar_get_code_display(bmd
   .device_cd), acquired_dt_tm = substring(1,25,format(bar.acquired_dt_tm,";;Q")),
  updt_dt_tm = substring(1,25,format(bar.updt_dt_tm,";;Q")), bar.person_id, person_name = substring(1,
   20,p.name_full_formatted)
  FROM bmdi_acquired_results bar,
   bmdi_monitored_device bmd,
   bmdi_device_parameter bdp,
   person p
  PLAN (bar)
   JOIN (bdp
   WHERE bar.device_parameter_id=bdp.device_parameter_id)
   JOIN (bmd
   WHERE bar.monitored_device_id=bmd.monitored_device_id
    AND bmd.device_alias=patstring(monid))
   JOIN (p
   WHERE bar.person_id=p.person_id)
  ORDER BY bmd.device_alias, bar.result_id DESC
  WITH nocounter
 ;end select
 GO TO main_menu
#view_by_patient
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,12,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"VIEW FORMATTED RESULTS")
 CALL box(6,9,10,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," BY PATIENT")
 CALL text(9,11," Enter a valid person ID to search by: ")
 CALL accept(9,55,"P(10);C","")
 IF (curaccept="")
  CALL text(14,2," Invalid person entered. Press any key to continue")
  CALL accept(14,56,"P(1)")
  GO TO view_by_monitor
 ENDIF
 SET personid = cnvtint(curaccept)
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT INTO mine
  clinical_dt_tm = substring(1,25,format(bar.clinical_dt_tm,";;Q")), event_cd = uar_get_code_display(
   bdp.event_cd), result = substring(1,10,bar.result_val),
  device_alias = substring(1,15,bmd.device_alias), service_resource = uar_get_code_display(bmd
   .device_cd), acquired_dt_tm = substring(1,25,format(bar.acquired_dt_tm,";;Q")),
  updt_dt_tm = substring(1,25,format(bar.updt_dt_tm,";;Q")), bar.person_id, person_name = substring(1,
   20,p.name_full_formatted)
  FROM bmdi_acquired_results bar,
   bmdi_monitored_device bmd,
   bmdi_device_parameter bdp,
   person p
  PLAN (bar
   WHERE bar.person_id=personid)
   JOIN (bdp
   WHERE bar.device_parameter_id=bdp.device_parameter_id)
   JOIN (bmd
   WHERE bar.monitored_device_id=bmd.monitored_device_id)
   JOIN (p
   WHERE bar.person_id=p.person_id)
  ORDER BY bar.result_id DESC
  WITH nocounter
 ;end select
 GO TO main_menu
#exit_script
END GO
