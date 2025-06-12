CREATE PROGRAM aps_prt_db_followup_types:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 y = vc
   1 rptaps = vc
   1 date = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbfollowuptracking = vc
   1 ppage = vc
   1 followuptype = vc
   1 status = vc
   1 active = vc
   1 inactive = vc
   1 generalparam = vc
   1 printlettersformember = vc
   1 yes = vc
   1 no = vc
   1 initialnotification = vc
   1 notapplicable = vc
   1 reportparam = vc
   1 noproceduresspecified = vc
   1 terminationprocparam = vc
   1 automatic = vc
   1 procedure = vc
   1 terminationflag = vc
   1 terminationreason = vc
   1 lookbackdays = vc
   1 pathnetap = vc
   1 template = vc
   1 firstoverdue = vc
   1 finaloverdue = vc
   1 prtletterfordoctor = vc
   1 continued = vc
 )
 SET captions->y = uar_i18ngetmessage(i18nhandle,"h1","Y")
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h2","REPORT:  APS_PRT_DB_FOLLOWUP_TYPES.PRG")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TTIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->dbfollowuptracking = uar_i18ngetmessage(i18nhandle,"h8",
  "DB FOLLOW-UP TRACKING TYPES TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->followuptype = uar_i18ngetmessage(i18nhandle,"h10","FOLLOW-UP TYPE:")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"h11","STATUS:")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"h12","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"h13","INACTIVE")
 SET captions->generalparam = uar_i18ngetmessage(i18nhandle,"h14","GENERAL PARAMETERS:")
 SET captions->printlettersformember = uar_i18ngetmessage(i18nhandle,"h15",
  "PRINT LETTERS FOR MEMBER:")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"h16","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"h17","NO")
 SET captions->initialnotification = uar_i18ngetmessage(i18nhandle,"h18","INITIAL NOTIFICATION")
 SET captions->notapplicable = uar_i18ngetmessage(i18nhandle,"h19","NOT APPLICABLE")
 SET captions->reportparam = uar_i18ngetmessage(i18nhandle,"h20","REPORT PARAMETERS:")
 SET captions->noproceduresspecified = uar_i18ngetmessage(i18nhandle,"h21","No procedures specified."
  )
 SET captions->terminationprocparam = uar_i18ngetmessage(i18nhandle,"h22",
  "TERMINATION PROCEDURE PARAMETERS:")
 SET captions->automatic = uar_i18ngetmessage(i18nhandle,"h23","AUTOMATIC")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"h24","PROCEDURE")
 SET captions->terminationflag = uar_i18ngetmessage(i18nhandle,"h25","TERMINATION FLAG")
 SET captions->terminationreason = uar_i18ngetmessage(i18nhandle,"h26","TERMINATION REASON")
 SET captions->lookbackdays = uar_i18ngetmessage(i18nhandle,"h27","LOOK-BACK DAYS")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h28","PATHNET ANATOMIC PATHOLOGY")
 SET captions->template = uar_i18ngetmessage(i18nhandle,"h29","TEMPLATE:")
 SET captions->firstoverdue = uar_i18ngetmessage(i18nhandle,"h30","FIRST OVERDUE:")
 SET captions->finaloverdue = uar_i18ngetmessage(i18nhandle,"h31","FINAL OVERDUE:")
 SET captions->prtletterfordoctor = uar_i18ngetmessage(i18nhandle,"h32","PRINT LETTERS FOR DOCTOR:")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 max_report_params = i4
   1 max_term_procs = i4
   1 qual[*]
     2 ft_type_cd = f8
     2 short_desc = c25
     2 description = vc
     2 active_ind = i2
     2 print_letters_for_member = c1
     2 patient_notification_ind = i2
     2 patient_notif_template_id = f8
     2 patient_notif_template_short_desc = c25
     2 patient_first_overdue_ind = i2
     2 patient_first_template_id = f8
     2 patient_first_template_short_desc = c25
     2 patient_final_overdue_ind = i2
     2 patient_final_template_id = f8
     2 patient_final_template_short_desc = c25
     2 print_letters_for_doctor = c1
     2 doctor_notification_ind = i2
     2 doctor_notif_template_id = f8
     2 doctor_notif_template_short_desc = c25
     2 doctor_first_overdue_ind = i2
     2 doctor_first_template_id = f8
     2 doctor_first_template_short_desc = c25
     2 doctor_final_overdue_ind = i2
     2 doctor_final_template_id = f8
     2 doctor_final_template_short_desc = c25
     2 term_proc_cnt = i2
     2 term_proc_qual[*]
       3 catalog_cd = f8
       3 auto_term_ind = i2
       3 auto_term_reason_cd = f8
       3 auto_term_reason_disp = c40
       3 look_back_days = i4
       3 mnemonic = vc
     2 tracking_rep_cnt = i2
     2 tracking_rep_qual[*]
       3 task_assay_cd = f8
       3 task_assay_disp = c40
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
#script
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ftt.followup_tracking_type_cd, join_path = decode(fttp.seq,"A",ftrp.seq,"B"," "), cv1.display,
  primary_mnemonic = substring(1,40,oc.primary_mnemonic)
  FROM ap_ft_type ftt,
   (dummyt d1  WITH seq = 1),
   ap_ft_term_proc fttp,
   order_catalog oc,
   (dummyt d2  WITH seq = 1),
   ap_ft_report_proc ftrp,
   code_value cv1
  PLAN (ftt
   WHERE ftt.followup_tracking_type_cd != 0.0)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (fttp
   WHERE fttp.followup_tracking_type_cd=ftt.followup_tracking_type_cd)
   JOIN (oc
   WHERE oc.catalog_cd=fttp.catalog_cd
    AND 1=oc.active_ind)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (ftrp
   WHERE ftrp.followup_tracking_type_cd=ftt.followup_tracking_type_cd)
   JOIN (cv1
   WHERE ftrp.task_assay_cd=cv1.code_value)
   ))
  ORDER BY ftt.followup_tracking_type_cd, cv1.display, primary_mnemonic
  HEAD REPORT
   cnt = 0
  HEAD ftt.followup_tracking_type_cd
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].ft_type_cd = ftt
   .followup_tracking_type_cd,
   temp->qual[cnt].patient_notification_ind = ftt.patient_notification_ind, temp->qual[cnt].
   short_desc = ftt.short_desc, temp->qual[cnt].description = ftt.description,
   temp->qual[cnt].active_ind = ftt.active_ind, temp->qual[cnt].patient_notif_template_id = ftt
   .patient_notif_template_id, temp->qual[cnt].patient_first_overdue_ind = ftt
   .patient_first_overdue_ind,
   temp->qual[cnt].patient_first_template_id = ftt.patient_first_template_id, temp->qual[cnt].
   patient_final_overdue_ind = ftt.patient_final_overdue_ind, temp->qual[cnt].
   patient_final_template_id = ftt.patient_final_template_id
   IF (ftt.patient_notification_ind > 0)
    temp->qual[cnt].print_letters_for_member = "Y"
   ENDIF
   IF (ftt.patient_first_overdue_ind > 0)
    temp->qual[cnt].print_letters_for_member = "Y"
   ENDIF
   IF (ftt.patient_final_overdue_ind > 0)
    temp->qual[cnt].print_letters_for_member = "Y"
   ENDIF
   temp->qual[cnt].doctor_notification_ind = ftt.doctor_notification_ind, temp->qual[cnt].
   doctor_notif_template_id = ftt.doctor_notif_template_id, temp->qual[cnt].doctor_first_overdue_ind
    = ftt.doctor_first_overdue_ind,
   temp->qual[cnt].doctor_first_template_id = ftt.doctor_first_template_id, temp->qual[cnt].
   doctor_final_overdue_ind = ftt.doctor_final_overdue_ind, temp->qual[cnt].doctor_final_template_id
    = ftt.doctor_final_template_id
   IF (ftt.doctor_notification_ind > 0)
    temp->qual[cnt].print_letters_for_doctor = captions->y
   ENDIF
   IF (ftt.doctor_first_overdue_ind > 0)
    temp->qual[cnt].print_letters_for_doctor = captions->y
   ENDIF
   IF (ftt.doctor_final_overdue_ind > 0)
    temp->qual[cnt].print_letters_for_doctor = captions->y
   ENDIF
  DETAIL
   CASE (join_path)
    OF "A":
     temp->qual[cnt].term_proc_cnt = (temp->qual[cnt].term_proc_cnt+ 1),stat = alterlist(temp->qual[
      cnt].term_proc_qual,temp->qual[cnt].term_proc_cnt),
     IF ((temp->qual[cnt].term_proc_cnt > temp->max_term_procs))
      temp->max_term_procs = temp->qual[cnt].term_proc_cnt
     ENDIF
     ,temp->qual[cnt].term_proc_qual[temp->qual[cnt].term_proc_cnt].catalog_cd = fttp.catalog_cd,temp
     ->qual[cnt].term_proc_qual[temp->qual[cnt].term_proc_cnt].auto_term_ind = fttp
     .auto_termination_ind,temp->qual[cnt].term_proc_qual[temp->qual[cnt].term_proc_cnt].
     auto_term_reason_cd = fttp.auto_termination_reason_cd,
     temp->qual[cnt].term_proc_qual[temp->qual[cnt].term_proc_cnt].look_back_days = fttp
     .look_back_days,temp->qual[cnt].term_proc_qual[temp->qual[cnt].term_proc_cnt].mnemonic = oc
     .primary_mnemonic
    OF "B":
     temp->qual[cnt].tracking_rep_cnt = (temp->qual[cnt].tracking_rep_cnt+ 1),stat = alterlist(temp->
      qual[cnt].tracking_rep_qual,temp->qual[cnt].tracking_rep_cnt),
     IF ((temp->qual[cnt].tracking_rep_cnt > temp->max_report_params))
      temp->max_report_params = temp->qual[cnt].tracking_rep_cnt
     ENDIF
     ,temp->qual[cnt].tracking_rep_qual[temp->qual[cnt].tracking_rep_cnt].task_assay_cd = ftrp
     .task_assay_cd,temp->qual[cnt].tracking_rep_qual[temp->qual[cnt].tracking_rep_cnt].
     task_assay_disp = cv1.display
   ENDCASE
  WITH outerjoin = d1, dontcare = fttp, outerjoin = d2,
   dontcare = ftrp
 ;end select
 SELECT INTO "nl:"
  wp.template_id, wp.short_desc
  FROM wp_template wp,
   (dummyt d1  WITH seq = value(size(temp->qual,5)))
  PLAN (d1)
   JOIN (wp
   WHERE wp.template_id IN (temp->qual[d1.seq].patient_notif_template_id, temp->qual[d1.seq].
   patient_first_template_id, temp->qual[d1.seq].patient_final_template_id, temp->qual[d1.seq].
   doctor_notif_template_id, temp->qual[d1.seq].doctor_first_template_id,
   temp->qual[d1.seq].doctor_final_template_id))
  DETAIL
   IF (wp.template_id > 0)
    IF ((temp->qual[d1.seq].patient_notif_template_id=wp.template_id))
     temp->qual[d1.seq].patient_notif_template_short_desc = wp.short_desc
    ENDIF
    IF ((temp->qual[d1.seq].patient_first_template_id=wp.template_id))
     temp->qual[d1.seq].patient_first_template_short_desc = wp.short_desc
    ENDIF
    IF ((temp->qual[d1.seq].patient_final_template_id=wp.template_id))
     temp->qual[d1.seq].patient_final_template_short_desc = wp.short_desc
    ENDIF
    IF ((temp->qual[d1.seq].doctor_notif_template_id=wp.template_id))
     temp->qual[d1.seq].doctor_notif_template_short_desc = wp.short_desc
    ENDIF
    IF ((temp->qual[d1.seq].doctor_first_template_id=wp.template_id))
     temp->qual[d1.seq].doctor_first_template_short_desc = wp.short_desc
    ENDIF
    IF ((temp->qual[d1.seq].doctor_final_template_id=wp.template_id))
     temp->qual[d1.seq].doctor_final_template_short_desc = wp.short_desc
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv,
   (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_term_procs))
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= temp->qual[d1.seq].term_proc_cnt)
    AND (temp->qual[d1.seq].term_proc_qual[d2.seq].auto_term_reason_cd > 0))
   JOIN (cv
   WHERE (temp->qual[d1.seq].term_proc_qual[d2.seq].auto_term_reason_cd=cv.code_value))
  DETAIL
   temp->qual[d1.seq].term_proc_qual[d2.seq].auto_term_reason_disp = cv.display
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbFtTypes", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  temp->qual[d1.seq].ft_type_cd, short_desc = temp->qual[d1.seq].short_desc, long_desc = temp->qual[
  d1.seq].description,
  active_ind = temp->qual[d1.seq].active_ind, print_letters_for_member = temp->qual[d1.seq].
  print_letters_for_member, p_notif_ind = temp->qual[d1.seq].patient_notification_ind,
  p_notif_template_short_desc = temp->qual[d1.seq].patient_notif_template_short_desc,
  p_first_overdue_ind = temp->qual[d1.seq].patient_first_overdue_ind, p_first_template_short_desc =
  temp->qual[d1.seq].patient_notif_template_short_desc,
  p_final_overdue_ind = temp->qual[d1.seq].patient_final_overdue_ind, p_final_template_short_desc =
  temp->qual[d1.seq].patient_final_template_short_desc, print_letters_for_doctor = temp->qual[d1.seq]
  .print_letters_for_doctor,
  d_notif_ind = temp->qual[d1.seq].doctor_notification_ind, d_notif_template_short_desc = temp->qual[
  d1.seq].doctor_notif_template_short_desc, d_first_overdue_ind = temp->qual[d1.seq].
  doctor_first_overdue_ind,
  d_first_template_short_desc = temp->qual[d1.seq].doctor_first_template_short_desc,
  d_final_overdue_ind = temp->qual[d1.seq].doctor_final_overdue_ind, d_final_template_short_desc =
  temp->qual[d1.seq].doctor_final_template_short_desc
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5)))
  PLAN (d1)
  ORDER BY short_desc
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathnetap,0,132), col 110, captions->date,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->dbfollowuptracking,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 2
  HEAD short_desc
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->followuptype,
   col 17, short_desc, row + 1,
   col 17, long_desc, row + 1,
   col 17, captions->status, col 26
   IF (active_ind=1)
    captions->active
   ELSE
    captions->inactive
   ENDIF
   row + 2, col 17, captions->generalparam
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 20, captions->prtletterfordoctor,
   col 47
   IF (print_letters_for_doctor="Y")
    captions->yes
   ELSE
    captions->no
   ENDIF
   row + 1, col 23, captions->initialnotification,
   col 47
   IF (print_letters_for_doctor != "Y")
    captions->notapplicable
   ELSEIF (d_notif_ind=1)
    captions->yes
   ELSE
    captions->no
   ENDIF
   col 64, captions->template, col 75
   IF (print_letters_for_doctor != "Y")
    captions->notapplicable
   ELSE
    d_notif_template_short_desc
   ENDIF
   row + 1, col 23, captions->firstoverdue,
   col 47
   IF (print_letters_for_doctor != "Y")
    captions->notapplicable
   ELSEIF (d_first_overdue_ind=1)
    captions->yes
   ELSE
    captions->no
   ENDIF
   col 64, captions->template, col 75
   IF (print_letters_for_doctor != "Y")
    captions->notapplicable
   ELSE
    d_first_template_short_desc
   ENDIF
   row + 1, col 23, captions->finaloverdue,
   col 47
   IF (print_letters_for_doctor != "Y")
    captions->notapplicable
   ELSEIF (d_final_overdue_ind=1)
    captions->yes
   ELSE
    captions->no
   ENDIF
   col 64, captions->template, col 75
   IF (print_letters_for_doctor != "Y")
    captions->notapplicable
   ELSE
    d_final_template_short_desc
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 17, captions->reportparam
   IF ((temp->qual[d1.seq].tracking_rep_cnt > 0))
    FOR (loop = 1 TO temp->qual[d1.seq].tracking_rep_cnt)
      row + 1, col 20, temp->qual[d1.seq].tracking_rep_qual[loop].task_assay_disp
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1, col 20, captions->noproceduresspecified
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 17, captions->terminationprocparam
   IF ((temp->qual[d1.seq].term_proc_cnt > 0))
    row + 2, col 37, captions->automatic,
    col 55, captions->automatic, row + 1,
    col 20, captions->procedure, col 37,
    captions->terminationflag, col 55, captions->terminationreason,
    col 75, captions->lookbackdays, row + 1,
    col 20, "---------------", col 37,
    "----------------", col 55, "------------------",
    col 75, "--------------"
    FOR (loop = 1 TO temp->qual[d1.seq].term_proc_cnt)
      row + 1, col 20, temp->qual[d1.seq].term_proc_qual[loop].mnemonic,
      col 37
      IF ((temp->qual[d1.seq].term_proc_qual[loop].auto_term_ind=1))
       captions->yes
      ELSE
       captions->no
      ENDIF
      col 55
      IF ((temp->qual[d1.seq].term_proc_qual[loop].auto_term_reason_cd > 0))
       temp->qual[d1.seq].term_proc_qual[loop].auto_term_reason_disp
      ELSE
       ""
      ENDIF
      col 75, temp->qual[d1.seq].term_proc_qual[loop].look_back_days
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1, col 20, captions->noproceduresspecified
   ENDIF
   row + 1
  FOOT  short_desc
   row + 2,
   CALL center("* * * * * * * * * *",0,132)
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
