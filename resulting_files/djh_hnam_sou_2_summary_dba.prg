CREATE PROGRAM djh_hnam_sou_2_summary:dba
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Enter Start Date" = "CURDATE",
  "Enter End Date" = "CURDATE"
  WITH ouput_dest, st_dt, en_dt
 EXECUTE bhs_sys_stand_subroutine
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 SET cnt = 0
 RECORD usage(
   1 named_prsnl_total = f8
   1 powerchart_users = f8
   1 pwc_qual[12]
     2 monthly_cnt = f8
   1 pco_users = f8
   1 pco_qual[12]
     2 monthly_cnt = f8
   1 powervision_users = f8
   1 pv_qual[12]
     2 monthly_cnt = f8
   1 profile_users = f8
   1 profile_qual[12]
     2 monthly_cnt = f8
   1 rad_total_ord_cnt = f8
   1 rad_total_can_cnt = f8
   1 rad_qual_cnt = i4
   1 rad_qual[*]
     2 activity_type_cd = f8
     2 ord_cnt = f8
     2 can_cnt = f8
     2 activity_type_disp = vc
     2 activity_type_cdf = vc
   1 lab_total_ord_cnt = f8
   1 lab_total_can_cnt = f8
   1 lab_qual_cnt = i4
   1 lab_qual[*]
     2 activity_type_cd = f8
     2 ord_cnt = f8
     2 can_cnt = f8
     2 activity_type_disp = vc
     2 activity_type_cdf = vc
   1 inp_total_ord_cnt = f8
   1 inp_total_can_cnt = f8
   1 inp_total_pyxis_ord_cnt = f8
   1 inp_total_pyxis_can_cnt = f8
   1 ret_total_ord_cnt = f8
   1 ret_total_can_cnt = f8
   1 emergency_dept_visit_cnt = i4
   1 tracking_group_qual_cnt = i4
   1 tracking_group_qual[*]
     2 tracking_group_cd = f8
     2 tracking_group_display = vc
     2 tracking_group_cdf = vc
     2 tracking_group_cnt = i4
 )
 DECLARE snode = vc
 IF (cursys="AXP")
  SET snode = curnode
 ELSEIF (cursys="AIX")
  SET snode = curnode
 ENDIF
 SET usage->named_prsnl_total = 0
 SET starttime = 0000
 SET endtime = 2400
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE ((p.username IN ("EN*", "TN*", "VT*")) OR (p.username="PN*"
   AND p.physician_ind=1))
   AND p.person_id > 0
   AND p.active_ind=1
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND p.position_cd != 457
   AND p.position_cd != 686743
   AND p.position_cd != 1447374
   AND p.position_cd != 777650
   AND p.position_cd != 441
   AND p.position_cd != 786870
   AND p.position_cd != 905956
   AND p.position_cd != 35742713
   AND p.position_cd != 35742679
   AND p.position_cd != 35742669
   AND p.position_cd != 69178474
   AND p.position_cd != 69178498
   AND p.position_cd != 65699687
   AND p.position_cd != 922119
   AND p.position_cd != 1447376
   AND p.position_cd != 1447377
   AND p.position_cd != 0.0
   AND p.position_cd != null
  DETAIL
   usage->named_prsnl_total = (usage->named_prsnl_total+ 1)
  WITH nocounter
 ;end select
 SET search_date =  $2
 SET end_date =  $3
 SET usage->powerchart_users = 0
 SET usage->pco_users = 0
 SET usage->powervision_users = 0
 SET usage->profile_users = 0
 SET ac = 0
 SELECT INTO "nl:"
  oac.application_number, oac.person_id
  FROM omf_app_ctx_day_st oac,
   prsnl p
  PLAN (oac
   WHERE oac.person_id > 0
    AND oac.application_number IN (600005, 950001, 1120000, 1120014, 1120016,
   1120033, 961000, 1120039)
    AND oac.start_day >= cnvtdate(search_date)
    AND oac.start_day <= cnvtdate(end_date))
   JOIN (p
   WHERE p.person_id=oac.person_id)
  ORDER BY oac.person_id, oac.application_number, oac.start_day
  HEAD REPORT
   profile_app_used = 0
  HEAD oac.person_id
   profile_app_used = 0
  HEAD oac.application_number
   IF (oac.application_number=600005
    AND ((p.username IN ("EN*", "TN*", "VT*")) OR (p.username="PN*"
    AND p.physician_ind=1))
    AND p.position_cd != 457
    AND p.position_cd != 686743
    AND p.position_cd != 1447374
    AND p.position_cd != 777650
    AND p.position_cd != 441
    AND p.position_cd != 786870
    AND p.position_cd != 905956
    AND p.position_cd != 35742713
    AND p.position_cd != 35742679
    AND p.position_cd != 35742669
    AND p.position_cd != 69178474
    AND p.position_cd != 69178498
    AND p.position_cd != 65699687
    AND p.position_cd != 922119
    AND p.position_cd != 1447376
    AND p.position_cd != 1447377
    AND p.position_cd != 0.00
    AND p.position_cd != null)
    usage->powerchart_users = (usage->powerchart_users+ 1)
   ENDIF
   IF (oac.application_number IN (1120000, 1120014, 1120016, 1120033, 1120039))
    IF (profile_app_used=1)
     x = 0
    ELSE
     usage->profile_users = (usage->profile_users+ 1)
    ENDIF
    profile_app_used = 1
   ENDIF
   IF (oac.application_number=950001)
    usage->powervision_users = (usage->powervision_users+ 1)
   ENDIF
   IF (oac.application_number=961000)
    usage->pco_users = (usage->pco_users+ 1)
   ENDIF
  DETAIL
   x = 0
  WITH nocounter
 ;end select
 SET startdate =  $2
 SET enddate =  $3
 SET can_cd = 0.0
 SET del_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6004
  DETAIL
   CASE (c.cdf_meaning)
    OF "CANCELED":
     can_cd = c.code_value
    OF "DELETED":
     del_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET usage->rad_total_ord_cnt = 0
 SET usage->rad_total_can_cnt = 0
 SET usage->rad_qual_cnt = 0
 SELECT INTO "nl:"
  ord_rad.request_dt_tm, o.order_id, o.activity_type_cd
  FROM order_radiology ord_rad,
   orders o
  PLAN (ord_rad
   WHERE ord_rad.request_dt_tm >= cnvtdatetime(cnvtdate(startdate),starttime)
    AND ord_rad.request_dt_tm <= cnvtdatetime(cnvtdate(enddate),endtime))
   JOIN (o
   WHERE o.order_id=ord_rad.order_id)
  ORDER BY o.activity_type_cd
  HEAD o.activity_type_cd
   usage->rad_qual_cnt = (usage->rad_qual_cnt+ 1), atc = usage->rad_qual_cnt, stat = alterlist(usage
    ->rad_qual,usage->rad_qual_cnt),
   usage->rad_qual[atc].activity_type_cd = o.activity_type_cd, usage->rad_qual[atc].ord_cnt = 0,
   usage->rad_qual[atc].can_cnt = 0
  DETAIL
   usage->rad_total_ord_cnt = (usage->rad_total_ord_cnt+ 1), usage->rad_qual[atc].ord_cnt = (usage->
   rad_qual[atc].ord_cnt+ 1)
   IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
    usage->rad_total_can_cnt = (usage->rad_total_can_cnt+ 1), usage->rad_qual[atc].can_cnt = (usage->
    rad_qual[atc].can_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 FOR (xx = 1 TO usage->rad_qual_cnt)
   SELECT INTO "NL:"
    c.code_value
    FROM code_value c
    WHERE (c.code_value=usage->rad_qual[xx].activity_type_cd)
    DETAIL
     usage->rad_qual[xx].activity_type_disp = trim(c.display), usage->rad_qual[xx].activity_type_cdf
      = trim(c.cdf_meaning)
    WITH nocounter
   ;end select
 ENDFOR
 SET usage->lab_total_ord_cnt = 0
 SET usage->lab_total_can_cnt = 0
 SET usage->lab_qual_cnt = 0
 SELECT INTO "nl:"
  ord_lab.updt_dt_tm, o.order_id, o.activity_type_cd
  FROM order_laboratory ord_lab,
   orders o
  PLAN (ord_lab
   WHERE ord_lab.updt_dt_tm >= cnvtdatetime(cnvtdate(startdate),starttime)
    AND ord_lab.updt_dt_tm <= cnvtdatetime(cnvtdate(enddate),endtime))
   JOIN (o
   WHERE o.order_id=ord_lab.order_id)
  ORDER BY o.activity_type_cd
  HEAD o.activity_type_cd
   usage->lab_qual_cnt = (usage->lab_qual_cnt+ 1), atc = usage->lab_qual_cnt, stat = alterlist(usage
    ->lab_qual,usage->lab_qual_cnt),
   usage->lab_qual[atc].activity_type_cd = o.activity_type_cd, usage->lab_qual[atc].ord_cnt = 0,
   usage->lab_qual[atc].can_cnt = 0
  DETAIL
   usage->lab_total_ord_cnt = (usage->lab_total_ord_cnt+ 1), usage->lab_qual[atc].ord_cnt = (usage->
   lab_qual[atc].ord_cnt+ 1)
   IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
    usage->lab_total_can_cnt = (usage->lab_total_can_cnt+ 1), usage->lab_qual[atc].can_cnt = (usage->
    lab_qual[atc].can_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 FOR (xx = 1 TO usage->lab_qual_cnt)
   SELECT INTO "NL:"
    c.code_value
    FROM code_value c
    WHERE (c.code_value=usage->lab_qual[xx].activity_type_cd)
    DETAIL
     usage->lab_qual[xx].activity_type_disp = trim(c.display), usage->lab_qual[xx].activity_type_cdf
      = trim(c.cdf_meaning)
    WITH nocounter
   ;end select
 ENDFOR
 SET usage->inp_total_ord_cnt = 0
 SET usage->inp_total_can_cnt = 0
 SET usage->inp_total_pyxis_ord_cnt = 0
 SET usage->inp_total_pyxis_can_cnt = 0
 SET usage->ret_total_ord_cnt = 0
 SET usage->ret_total_can_cnt = 0
 SELECT INTO "nl:"
  ord_disp.updt_dt_tm, o.order_id, o.orig_order_dt
  FROM order_dispense ord_disp,
   orders o
  PLAN (ord_disp
   WHERE ord_disp.updt_dt_tm >= cnvtdatetime(cnvtdate(startdate),starttime))
   JOIN (o
   WHERE o.order_id=ord_disp.order_id
    AND o.orig_order_dt_tm >= cnvtdatetime(cnvtdate(startdate),starttime)
    AND o.orig_order_dt_tm <= cnvtdatetime(cnvtdate(enddate),endtime))
  ORDER BY o.order_id
  DETAIL
   IF (o.orig_ord_as_flag=0)
    usage->inp_total_ord_cnt = (usage->inp_total_ord_cnt+ 1)
    IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
     usage->inp_total_can_cnt = (usage->inp_total_can_cnt+ 1)
    ENDIF
   ENDIF
   IF (o.orig_ord_as_flag=4)
    usage->inp_total_ord_cnt = (usage->inp_total_ord_cnt+ 1), usage->inp_total_pyxis_ord_cnt = (usage
    ->inp_total_pyxis_ord_cnt+ 1)
    IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
     usage->inp_total_can_cnt = (usage->inp_total_can_cnt+ 1), usage->inp_total_pyxis_can_cnt = (
     usage->inp_total_pyxis_can_cnt+ 1)
    ENDIF
   ENDIF
   IF (o.orig_ord_as_flag=1)
    usage->ret_total_ord_cnt = (usage->ret_total_ord_cnt+ 1)
    IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
     usage->ret_total_can_cnt = (usage->ret_total_can_cnt+ 1)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET usage->emergency_dept_visit_cnt = 0
 SET emergcnt = 0
 SELECT INTO "nl:"
  FROM tracking_checkin tc
  WHERE tc.checkin_dt_tm >= cnvtdate(startdate)
   AND tc.checkin_dt_tm <= cnvtdate(enddate)
  ORDER BY tc.tracking_group_cd
  HEAD tc.tracking_group_cd
   emergcnt = (emergcnt+ 1), stat = alterlist(usage->tracking_group_qual,emergcnt), usage->
   tracking_group_qual_cnt = (usage->tracking_group_qual_cnt+ 1)
  DETAIL
   usage->tracking_group_qual[emergcnt].tracking_group_cnt = (usage->tracking_group_qual[emergcnt].
   tracking_group_cnt+ 1), usage->emergency_dept_visit_cnt = (usage->emergency_dept_visit_cnt+ 1),
   usage->tracking_group_qual[emergcnt].tracking_group_cd = tc.tracking_group_cd
  WITH nocunter
 ;end select
 FOR (yy = 1 TO usage->tracking_group_qual_cnt)
  CALL echo(usage->tracking_group_qual[yy].tracking_group_display)
  SELECT INTO "NL:"
   c.code_value
   FROM code_value c
   WHERE (c.code_value=usage->tracking_group_qual[yy].tracking_group_cd)
   DETAIL
    usage->tracking_group_qual[yy].tracking_group_display = trim(c.display), usage->
    tracking_group_qual[yy].tracking_group_cdf = trim(c.cdf_meaning)
   WITH nocounter
  ;end select
 ENDFOR
 SET stitle = build("HNAM SCOPE OF USE STATS FROM",notrim(" ["),search_date,notrim("] "),notrim(
   " THRU "),
  notrim(" ["),end_date,notrim("]"))
 SELECT INTO value(output_dest)
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  DETAIL
   row + 1, col 1, "No DBAs or Stdents. Including all PN* Physicians - (hnam_sou_2_Summary_djh)",
   row + 1, col 1, stitle,
   row + 1, col 1, "Node: ",
   snode, row + 2, col 1,
   "ACCESS MANAGEMENT", ",", "NUMBER OF PERSONNEL WITH ACTIVE HNAM SIGNONS",
   ",", usage->named_prsnl_total"########", row + 1,
   col 1, "CAPSTONE", ",",
   "NUMBER OF PERSONNEL WITH ACTIVE HNAM SIGNONS", ",", usage->named_prsnl_total"########",
   row + 1, col 1, "OMF",
   ",", "NUMBER OF PERSONNEL WITH ACTIVE HNAM SIGNONS", ",",
   usage->named_prsnl_total"########", row + 1, col 1,
   "OPEN ENGINE", ",", "NUMBER OF PERSONNEL WITH ACTIVE HNAM SIGNONS",
   ",", usage->named_prsnl_total"########", row + 1,
   col 1, "PROFIT", ",",
   "NUMBER OF PERSONNEL WITH ACTIVE HNAM SIGNONS", ",", usage->named_prsnl_total"########",
   row + 1, col 1, "POWERINSIGHT",
   ",", "NUMBER OF PERSONNEL WITH ACTIVE HNAM SIGNONS", ",",
   usage->named_prsnl_total"########", row + 1, col 1,
   "POWERCHART", ",", "NUMBER OF UNIQUE USERS WHO SIGNED INTO POWERCHART",
   ",", usage->powerchart_users"########", row + 1,
   col 1, "CARENET", ",",
   "NUMBER OF UNIQUE USERS WHO SIGNED INTO CARENET", ",", usage->powerchart_users"########",
   row + 1, col 1, "POWERCHARTOFFICE",
   ",", "NUMBER OF UNIQUE USERS WHO SIGNED INTO POWERCHARTOFFICE", ",",
   usage->pco_users"########", row + 1, col 1,
   "POWERVISION", ",", "NUMBER OF UNIQUE USERS WHO SIGNED INTO POWERVISION",
   ",", usage->powervision_users"########", row + 1,
   col 1, "PROFILE", ",",
   "NUMBER OF UNIQUE USERS WHO SIGNED INTO PROFILE", ",", usage->profile_users"########",
   row + 1, col 1, "RADNET",
   ",", "TOTAL RADNET NEW ORDERS", ",",
   usage->rad_total_ord_cnt"########", row + 1, col 1,
   "RADNET", ",", "TOTAL RADNET CANCELED ORDERS",
   ",", usage->rad_total_can_cnt"########"
   FOR (zz = 1 TO usage->rad_qual_cnt)
     row + 1, col 1, "RADNET",
     ",", usage->rad_qual[zz].activity_type_disp, ",",
     usage->rad_qual[zz].activity_type_cdf, ",", "NEW ORDERS",
     ",", usage->rad_qual[zz].ord_cnt"########", row + 1,
     col 1, "RADNET", ",",
     usage->rad_qual[zz].activity_type_disp, ",", usage->rad_qual[zz].activity_type_cdf,
     ",", "CANCELED ORDERS", ",",
     usage->rad_qual[zz].can_cnt"########"
   ENDFOR
   row + 1, col 1, "PATHNET",
   ",", "TOTAL PATHNET NEW ORDERS", ",",
   usage->lab_total_ord_cnt"########", row + 1, col 1,
   "PATHNET", ",", "TOTAL PATHNET CANCELED ORDERS",
   ",", usage->lab_total_can_cnt"#######"
   FOR (zz = 1 TO usage->lab_qual_cnt)
     row + 1, col 1, "PATHNET",
     ",", usage->lab_qual[zz].activity_type_disp, ",",
     usage->lab_qual[zz].activity_type_cdf, ",", "NEW ORDERS",
     ",", usage->lab_qual[zz].ord_cnt"########", row + 1,
     col 1, "PATHNET", ",",
     usage->lab_qual[zz].activity_type_disp, ",", usage->lab_qual[zz].activity_type_cdf,
     ",", "CANCELED ORDERS", ",",
     usage->lab_qual[zz].can_cnt"########"
   ENDFOR
   row + 1, col 1, "PHARMNET",
   ",", "TOTAL INPATIENT NEW ORDERS", ",",
   usage->inp_total_ord_cnt"########", row + 1, col 1,
   "PHARMNET", ",", "TOTAL INPATIENT CANCELLED ORDERS",
   ",", usage->inp_total_can_cnt"#######", row + 1,
   col 1, "PHARMNET", ",",
   "PYXIS PORTION OF TOTAL INPATIENT NEW ORDERS", ",", usage->inp_total_pyxis_ord_cnt"########",
   row + 1, col 1, "PHARMNET",
   ",", "PYXIS TOTAL INPATIENT CANCELLED ORDERS", ",",
   usage->inp_total_pyxis_can_cnt"#######", row + 1, col 1,
   "PHARMNET", ",", "TOTAL RETAIL NEW ORDERS",
   ",", usage->ret_total_ord_cnt"########", row + 1,
   col 1, "PHARMNET", ",",
   "TOTAL RETAIL CANCELLED ORDERS", ",", usage->ret_total_can_cnt"#######",
   row + 1, col 1, "FIRSTNET",
   ",", "TOTAL ANNUAL EMERGENCY DEPARTMENT VISITS", ",",
   usage->emergency_dept_visit_cnt"#######"
   FOR (zz = 1 TO usage->tracking_group_qual_cnt)
     row + 1, col 1, "FIRSTNET",
     ",", usage->tracking_group_qual[zz].tracking_group_display, ",",
     usage->tracking_group_qual[zz].tracking_group_cdf, ",", "ANNUAL EMERGENCY DEPARTMENT VISITS",
     ",", usage->tracking_group_qual[zz].tracking_group_cnt"########"
   ENDFOR
  WITH nocounter, maxcol = 132
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),"-Summary.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Baystate Health hnam_sou")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
