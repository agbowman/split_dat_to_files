CREATE PROGRAM bhs_rpt_disch_order_stats
 PROMPT
  "Enter output filename" = "MINE",
  "Enter e-mail address(es)" = "",
  "Begin Date/Time" = "SYSDATE",
  "End Date/Time" = "SYSDATE",
  "User Filename" = "",
  "Nurse Units" = 0
  WITH outdev, email, beg_dt_tm,
  end_dt_tm, user_file, nurse_unit
 RECORD work(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 vl_cnt = i4
   1 valid_locations[*]
     2 nurse_unit_cd = f8
     2 desc = vc
   1 u_cnt = i4
   1 users[*]
     2 prsnl_id = f8
     2 username = vc
     2 name_full_formatted = vc
     2 hours[24]
       3 e_cnt = i4
       3 order_to_disch_cnt = i4
       3 order_to_disch_ttl = f8
       3 order_to_disch_mean = f8
       3 order_to_trans_cnt = i4
       3 order_to_trans_ttl = f8
       3 order_to_trans_mean = f8
       3 order_to_event_cnt = i4
       3 order_to_event_ttl = f8
       3 order_to_event_mean = f8
     2 e_cnt = i4
     2 encntrs[*]
       3 encntr_slot = i4
       3 location_slot = i4
       3 location_e_slot = i4
   1 l_cnt = i4
   1 locations[*]
     2 nurse_unit_cd = f8
     2 desc = vc
     2 hours[24]
       3 e_cnt = i4
       3 order_to_disch_cnt = i4
       3 order_to_disch_ttl = f8
       3 order_to_disch_mean = f8
       3 order_to_trans_cnt = i4
       3 order_to_trans_ttl = f8
       3 order_to_trans_mean = f8
     2 e_cnt = i4
     2 encntrs[*]
       3 user_slot = i4
       3 user_e_slot = i4
       3 encntr_slot = i4
   1 e_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 person_id = f8
     2 acct_nbr = vc
     2 nurse_unit_cd = f8
     2 order_id = f8
     2 order_dt_tm = dq8
     2 discontinue_type_cd = f8
     2 disch_ind = i2
     2 disch_dt_tm = dq8
     2 order_to_disch_time = f8
     2 encntr_loc_hist_id = f8
     2 transaction_dt_tm = dq8
     2 order_to_trans_time = f8
     2 event_id = f8
     2 event_dt_tm = dq8
     2 order_to_event_time = f8
     2 performed_prsnl_id = f8
     2 same_phys_ind = i2
     2 hour_slot = i4
     2 user_slot = i4
     2 user_e_slot = i4
     2 location_slot = i4
     2 location_e_slot = i4
   1 su_cnt = i4
   1 sort_users[*]
     2 user_slot = i4
   1 sl_cnt = i4
   1 sort_locations[*]
     2 location_slot = i4
 )
 DECLARE var_email_addresses = vc
 DECLARE var_output_1 = vc
 DECLARE var_output_2 = vc
 DECLARE var_output_3 = vc
 DECLARE all_locations_ind = i2 WITH constant(0)
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cs200_discharge_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"DISCHARGE"))
 DECLARE cs319_fin_nbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cs4038_usermanual_cd = f8 WITH constant(uar_get_code_by("MEANING",4038,"USERMANUAL"))
 SET var_email_addresses = trim(replace(replace( $EMAIL,";"," ",0),"  "," ",0),3)
 SET work->beg_dt_tm = cnvtdatetime( $BEG_DT_TM)
 SET work->end_dt_tm = cnvtdatetime( $END_DT_TM)
 IF (findfile( $FILENAME)=1)
  SET logical tmp_filename value( $FILENAME)
 ELSE
  CALL echo("Invalid filename entered.")
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl
 DEFINE rtl "tmp_filename"
 SELECT INTO "nl:"
  FROM rtlt r
  HEAD REPORT
   tmp_u = 0
  DETAIL
   tmp_u = 0
   IF ((work->u_cnt <= 0))
    work->u_cnt = (work->u_cnt+ 1), stat = alterlist(work->users,work->u_cnt), work->users[work->
    u_cnt].username = trim(cnvtupper(r.line)),
    work->users[work->u_cnt].name_full_formatted = "Unknown Username"
   ELSE
    stat = locateval(tmp_u,1,work->u_cnt,trim(cnvtupper(r.line)),work->users[tmp_u].username)
    IF ((work->users[tmp_u].username != trim(cnvtupper(r.line))))
     work->u_cnt = (work->u_cnt+ 1), stat = alterlist(work->users,work->u_cnt), work->users[work->
     u_cnt].username = trim(cnvtupper(r.line)),
     work->users[work->u_cnt].name_full_formatted = "Unknown Username"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->u_cnt)),
   prsnl pr
  PLAN (d)
   JOIN (pr
   WHERE (work->users[d.seq].username=pr.username))
  DETAIL
   work->users[d.seq].prsnl_id = pr.person_id, work->users[d.seq].name_full_formatted = trim(pr
    .name_full_formatted)
  WITH nocounter
 ;end select
 IF (all_locations_ind != 1)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.display_key IN ("W4", "S1", "S3", "S4", "C5A")
     AND cv.cdf_meaning="NURSEUNIT"
     AND cv.active_ind=1)
   DETAIL
    work->vl_cnt = (work->vl_cnt+ 1), stat = alterlist(work->valid_locations,work->vl_cnt), work->
    valid_locations[work->vl_cnt].nurse_unit_cd = cv.code_value,
    work->valid_locations[work->vl_cnt].desc = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->u_cnt)),
   order_action oa,
   orders o
  PLAN (o
   WHERE o.catalog_cd=cs200_discharge_cd
    AND o.discontinue_type_cd != cs4038_usermanual_cd
    AND o.active_status_dt_tm BETWEEN cnvtdatetime(work->beg_dt_tm) AND cnvtdatetime(work->end_dt_tm)
   )
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_sequence=1)
   JOIN (d
   WHERE (oa.order_provider_id=work->users[d.seq].prsnl_id))
  HEAD REPORT
   e1_cnt = 0, e2_cnt = 0
  DETAIL
   e1_cnt = (work->e_cnt+ 1), stat = alterlist(work->encntrs,e1_cnt), work->e_cnt = e1_cnt,
   work->encntrs[e1_cnt].encntr_id = o.encntr_id, work->encntrs[e1_cnt].person_id = o.person_id, work
   ->encntrs[e1_cnt].order_id = o.order_id,
   work->encntrs[e1_cnt].order_dt_tm = oa.action_dt_tm, work->encntrs[e1_cnt].discontinue_type_cd = o
   .discontinue_type_cd, work->encntrs[e1_cnt].hour_slot = (datetimepart(oa.action_dt_tm,4)+ 1),
   work->encntrs[e1_cnt].user_slot = d.seq
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encounter e,
   encntr_alias ea,
   encntr_loc_hist elh
  PLAN (d)
   JOIN (e
   WHERE (work->encntrs[d.seq].encntr_id=e.encntr_id))
   JOIN (ea
   WHERE outerjoin(e.encntr_id)=ea.encntr_id
    AND ea.encntr_alias_type_cd=outerjoin(cs319_fin_nbr_cd)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (elh
   WHERE outerjoin(e.encntr_id)=elh.encntr_id
    AND elh.active_ind=outerjoin(1)
    AND elh.active_status_cd=outerjoin(cs48_active_cd))
  ORDER BY d.seq, e.encntr_id, elh.transaction_dt_tm DESC
  HEAD REPORT
   l_cnt = 0, e_cnt = 0, tmp_u = 0,
   tmp_h = 0, tmp_vl = 0
  HEAD e.encntr_id
   work->encntrs[d.seq].acct_nbr = trim(ea.alias)
   IF (e.disch_dt_tm != null)
    work->encntrs[d.seq].disch_ind = 1, work->encntrs[d.seq].disch_dt_tm = e.disch_dt_tm, work->
    encntrs[d.seq].order_to_disch_time = datetimediff(work->encntrs[d.seq].disch_dt_tm,work->encntrs[
     d.seq].order_dt_tm,3)
   ENDIF
  DETAIL
   IF (elh.loc_nurse_unit_cd > 0.00
    AND (work->encntrs[d.seq].nurse_unit_cd <= 0.00))
    work->encntrs[d.seq].nurse_unit_cd = elh.loc_nurse_unit_cd
   ENDIF
   IF ((work->encntrs[d.seq].disch_ind=1)
    AND elh.depart_dt_tm=e.depart_dt_tm)
    work->encntrs[d.seq].encntr_loc_hist_id = elh.encntr_loc_hist_id, work->encntrs[d.seq].
    transaction_dt_tm = elh.transaction_dt_tm, work->encntrs[d.seq].order_to_trans_time =
    datetimediff(work->encntrs[d.seq].transaction_dt_tm,work->encntrs[d.seq].order_dt_tm,3)
   ENDIF
  FOOT  e.encntr_id
   tmp_vl = 0
   IF (((all_locations_ind=1) OR (locateval(tmp_vl,1,work->vl_cnt,work->encntrs[d.seq].nurse_unit_cd,
    work->valid_locations[tmp_vl].nurse_unit_cd) > 0)) )
    tmp_h = work->encntrs[d.seq].hour_slot, tmp_u = work->encntrs[d.seq].user_slot, work->users[tmp_u
    ].hours[tmp_h].order_to_disch_cnt = (work->users[tmp_u].hours[tmp_h].order_to_disch_cnt+ 1),
    work->users[tmp_u].hours[tmp_h].order_to_disch_ttl = (work->users[tmp_u].hours[tmp_h].
    order_to_disch_ttl+ work->encntrs[d.seq].order_to_disch_time), work->users[tmp_u].hours[tmp_h].
    order_to_trans_cnt = (work->users[tmp_u].hours[tmp_h].order_to_trans_cnt+ 1), work->users[tmp_u].
    hours[tmp_h].order_to_trans_ttl = (work->users[tmp_u].hours[tmp_h].order_to_trans_ttl+ work->
    encntrs[d.seq].order_to_trans_time)
   ENDIF
   IF ((work->encntrs[d.seq].nurse_unit_cd > 0.00))
    IF ((work->l_cnt <= 0))
     l_cnt = 1, stat = alterlist(work->locations,l_cnt), work->l_cnt = l_cnt,
     work->locations[l_cnt].nurse_unit_cd = work->encntrs[d.seq].nurse_unit_cd, work->locations[l_cnt
     ].desc = trim(uar_get_code_display(work->locations[l_cnt].nurse_unit_cd))
    ELSE
     l_cnt = 0, stat = locateval(l_cnt,1,work->l_cnt,work->encntrs[d.seq].nurse_unit_cd,work->
      locations[l_cnt].nurse_unit_cd)
     IF ((work->locations[l_cnt].nurse_unit_cd != work->encntrs[d.seq].nurse_unit_cd))
      l_cnt = (work->l_cnt+ 1), stat = alterlist(work->locations,l_cnt), work->l_cnt = l_cnt,
      work->locations[l_cnt].nurse_unit_cd = work->encntrs[d.seq].nurse_unit_cd, work->locations[
      l_cnt].desc = trim(uar_get_code_display(work->locations[l_cnt].nurse_unit_cd))
     ENDIF
    ENDIF
    e_cnt = (work->locations[l_cnt].e_cnt+ 1), stat = alterlist(work->locations[l_cnt].encntrs,e_cnt),
    work->locations[l_cnt].e_cnt = e_cnt,
    work->locations[l_cnt].encntrs[e_cnt].user_slot = work->encntrs[d.seq].user_slot, work->
    locations[l_cnt].encntrs[e_cnt].encntr_slot = d.seq, work->encntrs[d.seq].location_slot = l_cnt,
    work->encntrs[d.seq].location_e_slot = e_cnt
    IF ((work->encntrs[d.seq].disch_ind=1))
     IF (((all_locations_ind=1) OR (locateval(tmp_vl,1,work->vl_cnt,work->encntrs[d.seq].
      nurse_unit_cd,work->valid_locations[tmp_vl].nurse_unit_cd) > 0)) )
      tmp_h = work->encntrs[d.seq].hour_slot, work->locations[l_cnt].hours[tmp_h].e_cnt = (work->
      locations[l_cnt].hours[tmp_h].e_cnt+ 1), work->locations[l_cnt].hours[tmp_h].order_to_disch_cnt
       = (work->locations[l_cnt].hours[tmp_h].order_to_disch_cnt+ 1),
      work->locations[l_cnt].hours[tmp_h].order_to_disch_ttl = (work->locations[l_cnt].hours[tmp_h].
      order_to_disch_ttl+ work->encntrs[d.seq].order_to_disch_time), work->locations[l_cnt].hours[
      tmp_h].order_to_trans_cnt = (work->locations[l_cnt].hours[tmp_h].order_to_trans_cnt+ 1), work->
      locations[l_cnt].hours[tmp_h].order_to_trans_ttl = (work->locations[l_cnt].hours[tmp_h].
      order_to_trans_ttl+ work->encntrs[d.seq].order_to_trans_time)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE tmp_vl = i4
 FOR (e = 1 TO work->e_cnt)
  SET tmp_vl = 0
  IF (((all_locations_ind=1) OR (locateval(tmp_vl,1,work->vl_cnt,work->encntrs[e].nurse_unit_cd,work
   ->valid_locations[tmp_vl].nurse_unit_cd) > 0)) )
   SET work->users[work->encntrs[e].user_slot].hours[work->encntrs[e].hour_slot].e_cnt = (work->
   users[work->encntrs[e].user_slot].hours[work->encntrs[e].hour_slot].e_cnt+ 1)
   SET work->users[work->encntrs[e].user_slot].e_cnt = (work->users[work->encntrs[e].user_slot].e_cnt
   + 1)
   SET stat = alterlist(work->users[work->encntrs[e].user_slot].encntrs,work->users[work->encntrs[e].
    user_slot].e_cnt)
   SET work->users[work->encntrs[e].user_slot].encntrs[work->users[work->encntrs[e].user_slot].e_cnt]
   .encntr_slot = e
   SET work->encntrs[e].user_e_slot = work->users[work->encntrs[e].user_slot].e_cnt
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (work->encntrs[d.seq].encntr_id=(ce.encntr_id+ 0))
    AND (work->encntrs[d.seq].person_id=ce.person_id)
    AND ce.event_cd=value(uar_get_code_by("DISPLAYKEY",72,"DISCHARGETRANSFERNOTEHOSPITAL"))
    AND ce.event_end_dt_tm > cnvtdatetime("01-JAN-1800")
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.event_class_cd IN (value(uar_get_code_by("MEANING",53,"MDOC")), value(uar_get_code_by(
     "MEANING",53,"DOC")))
    AND ((ce.result_status_cd+ 0) IN (value(uar_get_code_by("MEANING",8,"AUTH")), value(
    uar_get_code_by("MEANING",8,"MODIFIED")), value(uar_get_code_by("MEANING",8,"ALTERED")))))
  ORDER BY d.seq, ce.event_end_dt_tm DESC
  HEAD REPORT
   tmp_vl = 0
  DETAIL
   IF ((work->encntrs[d.seq].event_id <= 0.00))
    work->encntrs[d.seq].event_id = ce.event_id, work->encntrs[d.seq].event_dt_tm = ce
    .event_end_dt_tm, work->encntrs[d.seq].performed_prsnl_id = ce.performed_prsnl_id,
    work->encntrs[d.seq].order_to_event_time = datetimediff(work->encntrs[d.seq].order_dt_tm,work->
     encntrs[d.seq].event_dt_tm,3)
    IF ((work->users[work->encntrs[d.seq].user_slot].prsnl_id=ce.performed_prsnl_id))
     tmp_vl = 0
     IF (((all_locations_ind=1) OR (locateval(tmp_vl,1,work->vl_cnt,work->encntrs[d.seq].
      nurse_unit_cd,work->valid_locations[tmp_vl].nurse_unit_cd) > 0)) )
      tmp_h = work->encntrs[d.seq].hour_slot, tmp_u = work->encntrs[d.seq].user_slot, work->users[
      tmp_u].hours[tmp_h].order_to_event_cnt = (work->users[tmp_u].hours[tmp_h].order_to_event_cnt+ 1
      ),
      work->users[tmp_u].hours[tmp_h].order_to_event_ttl = (work->users[tmp_u].hours[tmp_h].
      order_to_event_ttl+ work->encntrs[d.seq].order_to_event_time)
     ENDIF
     work->encntrs[d.seq].same_phys_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE tmp_su = i4
 DECLARE tmp_sl = i4
 SET work->su_cnt = work->u_cnt
 SET stat = alterlist(work->sort_users,work->su_cnt)
 FOR (u = 1 TO work->u_cnt)
   FOR (h = 1 TO size(work->users[u].hours,5))
     IF ((work->users[u].hours[h].order_to_disch_cnt > 0))
      SET work->users[u].hours[h].order_to_disch_mean = (work->users[u].hours[h].order_to_disch_ttl/
      work->users[u].hours[h].order_to_disch_cnt)
     ENDIF
     IF ((work->users[u].hours[h].order_to_trans_cnt > 0))
      SET work->users[u].hours[h].order_to_trans_mean = (work->users[u].hours[h].order_to_trans_ttl/
      work->users[u].hours[h].order_to_trans_cnt)
     ENDIF
     IF ((work->users[u].hours[h].order_to_event_cnt > 0))
      SET work->users[u].hours[h].order_to_event_mean = (work->users[u].hours[h].order_to_event_ttl/
      work->users[u].hours[h].order_to_event_cnt)
     ENDIF
   ENDFOR
   SET work->sort_users[u].user_slot = u
   SET tmp_su = (u - 1)
   WHILE (tmp_su > 0)
     IF ((work->users[work->sort_users[tmp_su].user_slot].name_full_formatted > work->users[u].
     name_full_formatted))
      SET work->sort_users[(tmp_su+ 1)].user_slot = work->sort_users[tmp_su].user_slot
      SET work->sort_users[tmp_su].user_slot = u
      SET tmp_su = (tmp_su - 1)
     ELSE
      SET tmp_su = 0
     ENDIF
   ENDWHILE
 ENDFOR
 SET work->sl_cnt = work->l_cnt
 SET stat = alterlist(work->sort_locations,work->sl_cnt)
 FOR (l = 1 TO work->l_cnt)
   FOR (h = 1 TO size(work->locations[l].hours,5))
    IF ((work->locations[l].hours[h].order_to_disch_cnt > 0))
     SET work->locations[l].hours[h].order_to_disch_mean = (work->locations[l].hours[h].
     order_to_disch_ttl/ work->locations[l].hours[h].order_to_disch_cnt)
    ENDIF
    IF ((work->locations[l].hours[h].order_to_trans_cnt > 0))
     SET work->locations[l].hours[h].order_to_trans_mean = (work->locations[l].hours[h].
     order_to_trans_ttl/ work->locations[l].hours[h].order_to_trans_cnt)
    ENDIF
   ENDFOR
   SET work->sort_locations[l].location_slot = l
   SET tmp_sl = (l - 1)
   WHILE (tmp_sl > 0)
     IF ((work->locations[work->sort_locations[tmp_sl].location_slot].desc > work->locations[l].desc)
     )
      SET work->sort_locations[(tmp_sl+ 1)].location_slot = work->sort_locations[tmp_sl].
      location_slot
      SET work->sort_locations[tmp_sl].location_slot = l
      SET tmp_sl = (tmp_sl - 1)
     ELSE
      SET tmp_sl = 0
     ENDIF
   ENDWHILE
 ENDFOR
 FREE SET tmp_su
 FREE SET tmp_sl
 IF (findstring(".", $OUTDEV) > 0)
  SET var_output_1 = trim(build(substring(1,(findstring(".", $OUTDEV) - 1), $OUTDEV),"1",substring(
     findstring(".", $OUTDEV),size( $OUTDEV), $OUTDEV)),4)
  SET var_output_2 = trim(build(substring(1,(findstring(".", $OUTDEV) - 1), $OUTDEV),"2",substring(
     findstring(".", $OUTDEV),size( $OUTDEV), $OUTDEV)),4)
  SET var_output_3 = trim(build(substring(1,(findstring(".", $OUTDEV) - 1), $OUTDEV),"3",substring(
     findstring(".", $OUTDEV),size( $OUTDEV), $OUTDEV)),4)
 ELSE
  SET var_output_1 = build(trim( $OUTDEV,4),"1.xls")
  SET var_output_2 = build(trim( $OUTDEV,4),"2.xls")
  SET var_output_3 = build(trim( $OUTDEV,4),"3.xls")
 ENDIF
 SELECT INTO value(var_output_1)
  FROM dummyt d
  HEAD REPORT
   col 0,
   CALL print(build2("Username",char(09),"Provider_Name",char(09),"Patient_Nurse_Unit",
    char(09),"Acct_Nbr",char(09),"Order_ID",char(09),
    "Order_Dt_Tm",char(09),"Order_Dt",char(09),"Order_Tm",
    char(09),"Disch_Dt_Tm",char(09),"Disch_Dt",char(09),
    "Disch_Tm",char(09),"Order_To_Disch_Hours",char(09),"ADT_Trans_Dt_Tm",
    char(09),"ADT_Trans_Dt",char(09),"ADT_Trans_Tm",char(09),
    "Order_To_Trans_Hours",char(09),"Disch_Note_Sign_Dt_Tm",char(09),"Disch_Note_Sign_Dt",
    char(09),"Disch_Note_Sign_Tm",char(09),"Order_To_Note_Hours",char(09),
    "Same_User_Ind"))
  DETAIL
   FOR (su = 1 TO work->su_cnt)
    tmp_u = work->sort_users[su].user_slot,
    FOR (sl = 1 TO work->sl_cnt)
     tmp_l = work->sort_locations[sl].location_slot,
     FOR (e = 1 TO work->locations[tmp_l].e_cnt)
       IF ((work->locations[tmp_l].encntrs[e].user_slot=tmp_u))
        tmp_e = work->locations[tmp_l].encntrs[e].encntr_slot, row + 1, col 0,
        CALL print(build2(trim(work->users[tmp_u].username),char(09),trim(work->users[tmp_u].
          name_full_formatted),char(09),trim(work->locations[tmp_l].desc),
         char(09),trim(work->encntrs[tmp_e].acct_nbr),char(09),trim(build2(work->encntrs[tmp_e].
           order_id)),char(09),
         trim(format(work->encntrs[tmp_e].order_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),char(09),trim(format(
           work->encntrs[tmp_e].order_dt_tm,"mm/dd/yyyy;;d"),3),char(09),trim(format(work->encntrs[
           tmp_e].order_dt_tm,"hh:mm;;d"),3),
         char(09),trim(format(work->encntrs[tmp_e].disch_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),char(09),
         trim(format(work->encntrs[tmp_e].disch_dt_tm,"mm/dd/yyyy;;d"),3),char(09),
         trim(format(work->encntrs[tmp_e].disch_dt_tm,"hh:mm;;d"),3),char(09),work->encntrs[tmp_e].
         order_to_disch_time,char(09),trim(format(work->encntrs[tmp_e].transaction_dt_tm,
           "mm/dd/yyyy hh:mm;;d"),3),
         char(09),trim(format(work->encntrs[tmp_e].transaction_dt_tm,"mm/dd/yyyy;;d"),3),char(09),
         trim(format(work->encntrs[tmp_e].transaction_dt_tm,"hh:mm;;d"),3),char(09),
         work->encntrs[tmp_e].order_to_trans_time,char(09),trim(format(work->encntrs[tmp_e].
           event_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),char(09),trim(format(work->encntrs[tmp_e].
           event_dt_tm,"mm/dd/yyyy;;d"),3),
         char(09),trim(format(work->encntrs[tmp_e].event_dt_tm,"hh:mm;;d"),3),char(09),work->encntrs[
         tmp_e].order_to_event_time,char(09),
         work->encntrs[tmp_e].same_phys_ind))
       ENDIF
     ENDFOR
    ENDFOR
   ENDFOR
  WITH nocounter, maxcol = 32000, maxrow = 1,
   formfeed = none, format = variable
 ;end select
 SELECT INTO value(var_output_2)
  FROM dummyt d
  HEAD REPORT
   col 0, "User"
   FOR (h = 0 TO 23)
    col + 0,
    CALL print(build2(char(09),trim(build2(h),3)))
   ENDFOR
  DETAIL
   FOR (su = 1 TO work->su_cnt)
     tmp_u = work->sort_users[su].user_slot, row + 1, col + 0,
     CALL print(trim(work->users[tmp_u].name_full_formatted,3))
     IF ((work->users[tmp_u].e_cnt <= 0))
      row + 1, col + 0, "  No orders found"
     ELSE
      FOR (loop_cnt = 1 TO 6)
        row + 1
        CASE (loop_cnt)
         OF 1:
          col + 0,"  Nbr of Orders"
         OF 2:
          col + 0,"  Nbr of Discharged Pts"
         OF 3:
          col + 0,"  Nbr of Discharge Notes"
         OF 4:
          col + 0,"  Order to Discharge"
         OF 5:
          col + 0,"  Order to Transaction"
         OF 6:
          col + 0,"  Order to Note"
        ENDCASE
        FOR (h = 1 TO size(work->users[tmp_u].hours,5))
          CASE (loop_cnt)
           OF 1:
            col + 0,
            CALL print(build2(char(09),trim(build2(work->users[tmp_u].hours[h].e_cnt),3)))
           OF 2:
            col + 0,
            CALL print(build2(char(09),trim(build2(work->users[tmp_u].hours[h].order_to_disch_cnt),3)
             ))
           OF 3:
            col + 0,
            CALL print(build2(char(09),trim(build2(work->users[tmp_u].hours[h].order_to_event_cnt),3)
             ))
           OF 4:
            col + 0,
            CALL print(build2(char(09),trim(build2(work->users[tmp_u].hours[h].order_to_disch_mean),3
              )))
           OF 5:
            col + 0,
            CALL print(build2(char(09),trim(build2(work->users[tmp_u].hours[h].order_to_trans_mean),3
              )))
           OF 6:
            col + 0,
            CALL print(build2(char(09),trim(build2(work->users[tmp_u].hours[h].order_to_event_mean),3
              )))
          ENDCASE
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter, maxcol = 32000, maxrow = 1,
   formfeed = none, format = variable
 ;end select
 SELECT INTO value(var_output_3)
  FROM dummyt d
  HEAD REPORT
   col 0, "Location"
   FOR (h = 0 TO 23)
    col + 0,
    CALL print(build2(char(09),trim(build2(h),3)))
   ENDFOR
  DETAIL
   FOR (sl = 1 TO work->sl_cnt)
     tmp_l = work->sort_locations[sl].location_slot, row + 1, col + 0,
     CALL print(trim(work->locations[tmp_l].desc,3))
     FOR (loop_cnt = 1 TO 4)
       row + 1
       CASE (loop_cnt)
        OF 1:
         col + 0,"  Nbr of Orders"
        OF 2:
         col + 0,"  Nbr of Discharged Pts"
        OF 3:
         col + 0,"  Order to Discharge"
        OF 4:
         col + 0,"  Order to Transaction"
       ENDCASE
       FOR (h = 1 TO size(work->locations[tmp_l].hours,5))
         CASE (loop_cnt)
          OF 1:
           col + 0,
           CALL print(build2(char(09),trim(build2(work->locations[tmp_l].hours[h].e_cnt),3)))
          OF 2:
           col + 0,
           CALL print(build2(char(09),trim(build2(work->locations[tmp_l].hours[h].order_to_disch_cnt),
             3)))
          OF 3:
           col + 0,
           CALL print(build2(char(09),trim(build2(work->locations[tmp_l].hours[h].order_to_disch_mean
              ),3)))
          OF 4:
           col + 0,
           CALL print(build2(char(09),trim(build2(work->locations[tmp_l].hours[h].order_to_trans_mean
              ),3)))
         ENDCASE
       ENDFOR
     ENDFOR
   ENDFOR
  WITH nocounter, maxcol = 32000, maxrow = 1,
   formfeed = none, format = variable
 ;end select
 DECLARE dcl_cmd = vc
 DECLARE dcl_len = i4
 SET dcl_cmd = build2("(uuencode ",var_output_1," ",var_output_1,"; ",
  "uuencode ",var_output_2," ",var_output_2,"; ",
  "uuencode ",var_output_3," ",var_output_3,") ",
  " | mailx -s 'Discharge Order Statistics from ",format(work->beg_dt_tm,"mm/dd/yyyy;;d")," to ",
  format(work->end_dt_tm,"mm/dd/yyyy;;d"),"' ",
  var_email_addresses)
 SET dcl_len = size(dcl_cmd)
 CALL dcl(dcl_cmd,dcl_len,stat)
#exit_script
END GO
