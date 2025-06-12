CREATE PROGRAM bhs_ma_message_center_ops:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Type" = ""
  WITH outdev, type
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ms_subject = vc WITH protect, noconstant("")
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD rpt_data
 RECORD rpt_data(
   1 qual[*]
     2 pool_name = vc
     2 prsnl_group_id = f8
     2 clinical = i4
     2 l_clinical_general_cnt = i4
     2 clinical_sick = i4
     2 clinical_priority = i4
     2 clinical_priority_sick = i4
     2 clinical_ind = i4
     2 rx = i4
     2 l_rx_general_cnt = i4
     2 rx_priority = i4
     2 rx_ind = i4
     2 l_admin_cnt = i4
     2 l_admin_general_cnt = i4
     2 l_admin_priority_cnt = i4
     2 l_admin_ind = i4
 )
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE opened = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"OPENED"))
 DECLARE pending = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE phonemsg = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG"))
 EXECUTE bhs_check_domain:dba
 SELECT INTO "nl:"
  FROM prsnl_group pg
  PLAN (pg
   WHERE pg.active_ind=1
    AND pg.prsnl_group_type_cd=0)
  ORDER BY pg.prsnl_group_name
  HEAD REPORT
   cnt = 0
  HEAD pg.prsnl_group_name
   IF (((findstring("CLINICAL",cnvtupper(pg.prsnl_group_name))) OR (((findstring("PRESCRIPTION",
    cnvtupper(pg.prsnl_group_name))) OR (((findstring("Greenfield Gastroenterology - Clinic",pg
    .prsnl_group_name)) OR (findstring("ADMIN",cnvtupper(pg.prsnl_group_name)))) )) )) )
    IF (mod(cnt,10)=0)
     stat = alterlist(rpt_data->qual,(cnt+ 10))
    ENDIF
    cnt += 1, rpt_data->qual[cnt].pool_name = pg.prsnl_group_name, rpt_data->qual[cnt].prsnl_group_id
     = pg.prsnl_group_id
    IF (((findstring("CLINICAL",cnvtupper(pg.prsnl_group_name))) OR (findstring(
     "Greenfield Gastroenterology - Clinic",pg.prsnl_group_name))) )
     rpt_data->qual[cnt].clinical_ind = 1
    ENDIF
    IF (findstring("PRESCRIPTION",cnvtupper(pg.prsnl_group_name)))
     rpt_data->qual[cnt].rx_ind = 1
    ENDIF
    IF (findstring("ADMIN",cnvtupper(pg.prsnl_group_name)))
     rpt_data->qual[cnt].l_admin_ind = 1
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(rpt_data->qual,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta,
   (dummyt d  WITH seq = size(rpt_data->qual,5))
  PLAN (d)
   JOIN (taa
   WHERE (taa.assign_prsnl_group_id=rpt_data->qual[d.seq].prsnl_group_id)
    AND taa.task_status_cd IN (opened, pending)
    AND taa.assign_prsnl_group_id > 0
    AND taa.active_ind=1
    AND taa.end_eff_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.task_type_cd=phonemsg)
  ORDER BY d.seq, ta.task_id
  HEAD d.seq
   null
  HEAD ta.task_id
   IF (findstring("Clinical",rpt_data->qual[d.seq].pool_name) > 0)
    rpt_data->qual[d.seq].clinical += 1
    IF (findstring("SICK",cnvtupper(ta.msg_subject)) > 0)
     IF (ta.stat_ind=1)
      rpt_data->qual[d.seq].clinical_priority_sick += 1
     ELSE
      rpt_data->qual[d.seq].clinical_sick += 1
     ENDIF
    ELSE
     IF (ta.stat_ind=1)
      rpt_data->qual[d.seq].clinical_priority += 1
     ELSE
      rpt_data->qual[d.seq].l_clinical_general_cnt += 1
     ENDIF
    ENDIF
   ELSEIF (findstring("Prescription",rpt_data->qual[d.seq].pool_name) > 0)
    rpt_data->qual[d.seq].rx += 1
    IF (ta.stat_ind=1)
     rpt_data->qual[d.seq].rx_priority += 1
    ELSE
     rpt_data->qual[d.seq].l_rx_general_cnt += 1
    ENDIF
   ELSEIF (findstring("ADMIN",cnvtupper(rpt_data->qual[d.seq].pool_name)) > 0)
    rpt_data->qual[d.seq].l_admin_cnt += 1
    IF (ta.stat_ind=1)
     rpt_data->qual[d.seq].l_admin_priority_cnt += 1
    ELSE
     rpt_data->qual[d.seq].l_admin_general_cnt += 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (( $TYPE="Clinical"))
  SET ms_subject = concat("Message Center Report - Clinical ",trim(format(cnvtdatetime(sysdate),
     "MM/DD/YYYY;;q"),3))
  SET frec->file_name = concat("bhs_ma_message_center_clinical_",trim(format(cnvtdatetime(sysdate),
     "YYYYMMDD;;q"),3),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"',"POOL_NAME",'","',"TOTAL_MESSAGES",'","',
   "TOTAL_GENERAL",'","',"TOTAL_GENERAL_SICK",'","',"TOTAL_PRIORITY_GENERAL",
   '","',"TOTAL_PRIORITY_SICK",'"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO size(rpt_data->qual,5))
    IF ((rpt_data->qual[ml_idx1].clinical_ind=1))
     SET frec->file_buf = concat('"',rpt_data->qual[ml_idx1].pool_name,'","',trim(cnvtstring(rpt_data
        ->qual[ml_idx1].clinical,20,0),3),'","',
      trim(cnvtstring(rpt_data->qual[ml_idx1].l_clinical_general_cnt,20,0),3),'","',trim(cnvtstring(
        rpt_data->qual[ml_idx1].clinical_sick,20,0),3),'","',trim(cnvtstring(rpt_data->qual[ml_idx1].
        clinical_priority,20,0),3),
      '","',trim(cnvtstring(rpt_data->qual[ml_idx1].clinical_priority_sick,20,0),3),'"',char(13),char
      (10))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ELSEIF (( $TYPE="Prescription"))
  SET ms_subject = concat("Message Center Report - Prescription ",trim(format(cnvtdatetime(sysdate),
     "MM/DD/YYYY;;q"),3))
  SET frec->file_name = concat("bhs_ma_message_center_prescription_",trim(format(cnvtdatetime(sysdate
      ),"YYYYMMDD;;q"),3),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"',"POOL_NAME",'","',"TOTAL_MESSAGES",'","',
   "TOTAL_GENERAL",'","',"TOTAL_PRIORITY",'"',char(13),
   char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO size(rpt_data->qual,5))
    IF ((rpt_data->qual[ml_idx1].rx_ind=1))
     SET frec->file_buf = concat('"',rpt_data->qual[ml_idx1].pool_name,'","',trim(cnvtstring(rpt_data
        ->qual[ml_idx1].rx,20,0),3),'","',
      trim(cnvtstring(rpt_data->qual[ml_idx1].l_rx_general_cnt,20,0),3),'","',trim(cnvtstring(
        rpt_data->qual[ml_idx1].rx_priority,20,0),3),'"',char(13),
      char(10))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ELSEIF (( $TYPE="Admin"))
  SET ms_subject = concat("Message Center Report - Admin ",trim(format(cnvtdatetime(sysdate),
     "MM/DD/YYYY;;q"),3))
  SET frec->file_name = concat("bhs_ma_message_center_admin_",trim(format(cnvtdatetime(sysdate),
     "YYYYMMDD;;q"),3),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"',"POOL_NAME",'","',"TOTAL_MESSAGES",'","',
   "TOTAL_GENERAL",'","',"TOTAL_PRIORITY",'"',char(13),
   char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO size(rpt_data->qual,5))
    IF ((rpt_data->qual[ml_idx1].l_admin_ind=1))
     SET frec->file_buf = concat('"',rpt_data->qual[ml_idx1].pool_name,'","',trim(cnvtstring(rpt_data
        ->qual[ml_idx1].l_admin_cnt,20,0),3),'","',
      trim(cnvtstring(rpt_data->qual[ml_idx1].l_admin_general_cnt,20,0),3),'","',trim(cnvtstring(
        rpt_data->qual[ml_idx1].l_admin_priority_cnt,20,0),3),'"',char(13),
      char(10))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 IF (gl_bhs_prod_flag=1)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,"CISMessageCenterReport@bhs.org",ms_subject,1)
 ENDIF
#exit_script
END GO
