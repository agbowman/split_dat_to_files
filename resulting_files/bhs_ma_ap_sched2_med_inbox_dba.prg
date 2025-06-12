CREATE PROGRAM bhs_ma_ap_sched2_med_inbox:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Select Facility" = 0,
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, bdate, edate,
  fname, email
 IF (( $FNAME < 1))
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "You must select a facility", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSE
  SET loc_where = build2(" ec.loc_facility_cd + 0 = ", $FNAME)
 ENDIF
 SET end_date_qual = cnvtdatetime( $EDATE)
 SET beg_date_qual = cnvtdatetime( $BDATE)
 IF (datetimediff(end_date_qual,beg_date_qual) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhspasched2orders"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 SET attdoc = uar_get_code_by("MEANING",333,"ATTENDDOC")
 SET ordered = uar_get_code_by("DISPLAYKEY",6003,"ORDER")
 SET bhsap = uar_get_code_by("DISPLAYKEY",88,"BHSASSOCIATEPROFESSIONAL")
 SET fin = uar_get_code_by("MEANING",319,"FIN NBR")
 SET qualcnt = 0
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 oid = f8
     2 eid = f8
     2 patacctid = f8
     2 apname = c320
     2 apid = f8
     2 patname = c320
     2 drugmnemonic = vc
     2 orddate = c24
     2 catalogcd = f8
     2 orderstatus = vc
     2 finalordnotifstatus = vc
     2 ordforwarded = i2
     2 fordnotid = f8
     2 forwarddt = c24
     2 receiveddt = c24
     2 attdphys = c320
     2 ftoattd = i2
     2 ftoname = c48
     2 reviewedtype = c48
 )
 SELECT INTO "NL:"
  o.order_id, apname = pr.name_full_formatted, ord.order_notification_id,
  ord.action_sequence, ord.from_prsnl_id, ord.to_prsnl_id,
  ord.order_notification_id, ord.notification_status_flag
  FROM orders o,
   order_action oa,
   prsnl pr,
   person p,
   order_notification ord,
   encntr_alias ea,
   encounter e
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
    AND o.catalog_cd IN (772218, 772254, 772322, 772368, 772558,
   772560, 772744, 772780, 772906, 773076,
   773094, 773114, 773154, 773244, 773260,
   773292, 773496, 906172, 1346326, 1346348,
   1355735, 1357760, 1358297, 1360466, 1361270,
   1361283, 1361670, 1361741, 1362436, 1363355,
   1363557, 2342977, 24430197, 24431927, 24432294,
   95371335))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=value( $FNAME))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1
    AND ((oa.action_type_cd+ 0)=ordered))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(o.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(fin))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ord
   WHERE ord.order_id=o.order_id)
   JOIN (pr
   WHERE pr.person_id=ord.to_prsnl_id
    AND ((pr.position_cd+ 0)=bhsap)
    AND ((pr.active_ind+ 0)=1)
    AND pr.username > "")
  ORDER BY o.order_id, ord.to_prsnl_id, ord.action_sequence DESC,
   ord.notification_status_flag DESC
  HEAD REPORT
   qualcnt = 0
  HEAD o.order_id
   CALL echo(build("order_id:_",o.order_id))
  HEAD ord.to_prsnl_id
   qualcnt = (qualcnt+ 1), stat = alterlist(temp->qual,qualcnt), temp->qual[qualcnt].oid = o.order_id,
   temp->qual[qualcnt].eid = o.encntr_id, temp->qual[qualcnt].drugmnemonic = o.order_mnemonic, temp->
   qual[qualcnt].apname = trim(pr.name_full_formatted),
   temp->qual[qualcnt].apid = pr.person_id, temp->qual[qualcnt].catalogcd = o.catalog_cd, temp->qual[
   qualcnt].orddate = format(o.orig_order_dt_tm,"MM-DD-YYYY HH:MM"),
   temp->qual[qualcnt].orderstatus = uar_get_code_display(o.order_status_cd), temp->qual[qualcnt].
   patacctid = cnvtreal(ea.alias), temp->qual[qualcnt].patname = trim(p.name_full_formatted),
   temp->qual[qualcnt].fordnotid = ord.order_notification_id
  HEAD ord.order_notification_id
   IF (ord.notification_status_flag=4)
    temp->qual[qualcnt].ordforwarded = 1, temp->qual[qualcnt].ftoattd = 1, temp->qual[qualcnt].
    forwarddt = format(ord.notification_dt_tm,"MM-DD-YYYY HH:MM")
   ENDIF
   temp->qual[qualcnt].receiveddt = format(ord.notification_dt_tm,"MM-DD-YYYY HH:MM")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ord.parent_order_notification_id
  FROM order_notification ord,
   encntr_prsnl_reltn epr,
   prsnl pr,
   (dummyt d1  WITH seq = value(qualcnt)),
   dummyt d3
  PLAN (d1)
   JOIN (ord
   WHERE (ord.order_id=temp->qual[d1.seq].oid)
    AND (ord.parent_order_notification_id=temp->qual[d1.seq].fordnotid)
    AND ord.parent_order_notification_id > 0)
   JOIN (pr
   WHERE pr.person_id=ord.to_prsnl_id)
   JOIN (d3)
   JOIN (epr
   WHERE (epr.encntr_id=temp->qual[d1.seq].eid)
    AND epr.prsnl_person_id=ord.to_prsnl_id
    AND epr.encntr_prsnl_r_cd=attdoc)
  HEAD ord.parent_order_notification_id
   IF (epr.encntr_id < 1)
    temp->qual[d1.seq].ftoattd = 0
   ENDIF
   temp->qual[d1.seq].ftoname = trim(pr.name_full_formatted)
  WITH nocounter, outerjoin = d3
 ;end select
 CALL echorecord(temp)
 SELECT INTO "nl:"
  ord.parent_order_notification_id
  FROM encntr_prsnl_reltn epr,
   prsnl pr,
   (dummyt d4  WITH seq = value(size(temp->qual,5)))
  PLAN (d4)
   JOIN (epr
   WHERE (epr.encntr_id=temp->qual[d4.seq].eid)
    AND epr.encntr_prsnl_r_cd=attdoc)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  HEAD d4.seq
   phycnt = 0
  HEAD epr.encntr_prsnl_reltn_id
   phycnt = (phycnt+ 1)
   IF (phycnt=1)
    temp->qual[d4.seq].attdphys = trim(pr.name_full_formatted)
   ELSE
    temp->qual[d4.seq].attdphys = concat(trim(temp->qual[d4.seq].attdphys),"; ",trim(pr
      .name_full_formatted))
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 SELECT INTO "nl:"
  FROM order_review ordr,
   orders o,
   (dummyt d5  WITH seq = value(size(temp->qual,5)))
  PLAN (d5)
   JOIN (o
   WHERE (o.order_id=temp->qual[d5.seq].oid))
   JOIN (ordr
   WHERE ordr.order_id=outerjoin(o.order_id)
    AND ordr.review_personnel_id=outerjoin(temp->qual[d5.seq].apid)
    AND ordr.reviewed_status_flag > outerjoin(0))
  DETAIL
   IF (ordr.reviewed_status_flag > 0)
    temp->qual[d5.seq].reviewedtype =
    IF (ordr.reviewed_status_flag=1) "Signed"
    ELSEIF (ordr.reviewed_status_flag=2) "Rejected"
    ELSEIF (ordr.reviewed_status_flag=3) "No Longer Needing Review"
    ELSEIF (ordr.reviewed_status_flag=4) "Superceded"
    ELSEIF (ordr.reviewed_status_flag=5) "Reviewed"
    ENDIF
   ELSEIF ((temp->qual[d5.seq].ordforwarded > 0))
    temp->qual[d5.seq].reviewedtype = "Forwarded"
   ELSE
    temp->qual[d5.seq].reviewedtype = "None"
   ENDIF
  WITH nocounter
 ;end select
 IF (qualcnt > 0)
  IF (email_ind=0)
   SELECT INTO  $OUTDEV
    order_id = temp->qual[d2.seq].oid, received_date = temp->qual[d2.seq].receiveddt, apname = trim(
     temp->qual[d2.seq].apname),
    attending = trim(temp->qual[d2.seq].attdphys), reviewtype = temp->qual[d2.seq].reviewedtype,
    forwarded_to = temp->qual[d2.seq].ftoname,
    forward_date = temp->qual[d2.seq].forwarddt, order_status = temp->qual[d2.seq].orderstatus,
    orignal_orde_date = temp->qual[d2.seq].orddate,
    patient_acct_num = temp->qual[d2.seq].patacctid, patient_name = temp->qual[d2.seq].patname,
    drug_mnemonic = temp->qual[d2.seq].drugmnemonic,
    encntr_id = temp->qual[d2.seq].eid, catalog_cd = temp->qual[d2.seq].catalogcd,
    order_notification_id = temp->qual[d2.seq].fordnotid
    FROM (dummyt d2  WITH seq = value(qualcnt))
    PLAN (d2)
    ORDER BY order_id, forward_date, apname
    WITH nocounter, separator = " ", format,
     time = 15
   ;end select
  ELSE
   SELECT INTO value(var_output)
    order_id = temp->qual[d2.seq].oid, received_date = temp->qual[d2.seq].receiveddt, apname = trim(
     temp->qual[d2.seq].apname),
    attending = trim(temp->qual[d2.seq].attdphys), reviewtype = temp->qual[d2.seq].reviewedtype,
    forwarded_to = temp->qual[d2.seq].ftoname,
    forward_date = temp->qual[d2.seq].forwarddt, order_status = temp->qual[d2.seq].orderstatus,
    orignal_orde_date = temp->qual[d2.seq].orddate,
    patient_acct_num = temp->qual[d2.seq].patacctid, patient_name = temp->qual[d2.seq].patname,
    drug_mnemonic = temp->qual[d2.seq].drugmnemonic,
    encntr_id = temp->qual[d2.seq].eid, catalog_cd = temp->qual[d2.seq].catalogcd,
    order_notification_id = temp->qual[d2.seq].fordnotid
    FROM (dummyt d2  WITH seq = value(qualcnt))
    PLAN (d2)
    ORDER BY apname
    WITH nocounter, format, pcformat('"',",")
   ;end select
   SET filename_in = trim(var_output)
   SET email_address = trim( $EMAIL)
   SET filename_out = "bhs_pa_sched2.csv"
   SET subject = concat(curprog," - AP Sched2 Meds - inbox")
   EXECUTE bhs_ma_email_file
   CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,subject,0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = concat(trim("bhs_pa_sched2_"),format(curdate,"MMDDYYYY;;D"),".csv will be sent to -"),
     msg2 = concat("   ", $EMAIL), col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
     "{F/1}{CPI/9}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "No rows found", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
#exit_prg
END GO
