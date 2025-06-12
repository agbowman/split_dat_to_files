CREATE PROGRAM dcp_pw_rslt_rpt:dba
 SET event_id = 0.0
 SET yyy = fillstring(40," ")
 SET footer = fillstring(15," ")
 SET mrn_foot = fillstring(15," ")
 SET encounter_id = 0.0
 SET person_id = 0.0
 SET formnum = 3
 SET cur_date = cnvtdatetime(curdate,curtime)
 SET u_line = fillstring(107,"_")
 SET page_cnt = 0
 SET cur_y = 0
 SET head_y = 0
 SET xcol = 0
 SET ycol = 0
 SET y = 0
 SET ty = 0
 SET stat_flag = 0
 SET ins_flag = 1
 SET x_break = 0
 SET cur_head = fillstring(40," ")
 SET string1 = "Primary learner shows evidence of comprehension "
 SET string2 = "following instruction by verbalizing an understanding of"
 SET long_line = concat(string1,string2)
 SET t_len = 0
 SET t_len1 = 0
 SET temp = 0
 RECORD care_code(
   1 cnt = i2
   1 list_qual[23]
     2 subhead = vc
     2 cd_val = f8
 )
 SET care_code->cnt = 23
 SET care_code->list_qual[1].subhead = "Sedation Order Current"
 SET care_code->list_qual[1].cd_val = 1467519
 SET care_code->list_qual[2].subhead = "Weight for CPR Card"
 SET care_code->list_qual[2].cd_val = 1467534
 SET care_code->list_qual[3].subhead = "Antidotes Available"
 SET care_code->list_qual[3].cd_val = 1467395
 SET care_code->list_qual[4].subhead = "Emergency Equipment"
 SET care_code->list_qual[4].cd_val = 1467398
 SET care_code->list_qual[5].subhead = "Emergency Medications"
 SET care_code->list_qual[5].cd_val = 1467401
 SET care_code->list_qual[6].subhead = "Suction and O2"
 SET care_code->list_qual[6].cd_val = 1467404
 SET care_code->list_qual[7].subhead = "Airway Equipment"
 SET care_code->list_qual[7].cd_val = 1467407
 SET care_code->list_qual[8].subhead = "Medical History Reviewed"
 SET care_code->list_qual[8].cd_val = 1467410
 SET care_code->list_qual[9].subhead = "Sedation History Reviewed"
 SET care_code->list_qual[9].cd_val = 1467413
 SET care_code->list_qual[10].subhead = "Allergies/Current Meds Noted"
 SET care_code->list_qual[10].cd_val = 1467416
 SET care_code->list_qual[11].subhead = "Unexplained Illness"
 SET care_code->list_qual[11].cd_val = 1467425
 SET care_code->list_qual[12].subhead = "Functional IV"
 SET care_code->list_qual[12].cd_val = 1467419
 SET care_code->list_qual[13].subhead = "IV Location"
 SET care_code->list_qual[13].cd_val = 1468219
 SET care_code->list_qual[14].subhead = "NPO Solids-6 hrs/Clears-2 hrs"
 SET care_code->list_qual[14].cd_val = 1467422
 SET care_code->list_qual[15].subhead = "Date/Time of Last Intake"
 SET care_code->list_qual[15].cd_val = 1468216
 SET care_code->list_qual[16].subhead = "Type of Last Intake"
 SET care_code->list_qual[16].cd_val = 1468213
 SET care_code->list_qual[17].subhead = "Transporter Designated"
 SET care_code->list_qual[17].cd_val = 1467392
 SET care_code->list_qual[18].subhead = "Providing Transportation"
 SET care_code->list_qual[18].cd_val = 1480172
 SET care_code->list_qual[19].subhead = "Destination after D/C"
 SET care_code->list_qual[19].cd_val = 1468559
 SET care_code->list_qual[20].subhead = "Other Destination"
 SET care_code->list_qual[20].cd_val = 1480178
 SET care_code->list_qual[21].subhead = "Phone Number Post Discharge"
 SET care_code->list_qual[21].cd_val = 1480168
 SET care_code->list_qual[22].subhead = "Home Phone Number"
 SET care_code->list_qual[22].cd_val = 1480165
 SET care_code->list_qual[23].subhead = "Con Sed Requirements Add Info"
 SET care_code->list_qual[23].cd_val = 1480162
 RECORD ins_code(
   1 cnt = i2
   1 list_qual[10]
     2 subhead = vc
     2 cd_val = f8
 )
 SET ins_code->cnt = 10
 SET ins_code->list_qual[1].subhead = "Primary Learner"
 SET ins_code->list_qual[1].cd_val = 1479217
 SET ins_code->list_qual[2].subhead = "Barriers to Learning"
 SET ins_code->list_qual[2].cd_val = 1479220
 SET ins_code->list_qual[3].subhead = "Sedation Purpose"
 SET ins_code->list_qual[3].cd_val = 1467493
 SET ins_code->list_qual[4].subhead = "Possible Pharmacologic Reactions"
 SET ins_code->list_qual[4].cd_val = 1467496
 SET ins_code->list_qual[5].subhead = "Staff's Monitoring of Patient"
 SET ins_code->list_qual[5].cd_val = 1467499
 SET ins_code->list_qual[6].subhead = "Signs and Symptoms to Report"
 SET ins_code->list_qual[6].cd_val = 1467502
 SET ins_code->list_qual[7].subhead = "Whom to Call with Problems"
 SET ins_code->list_qual[7].cd_val = 1467505
 SET ins_code->list_qual[8].subhead = "Patient Education Materials"
 SET ins_code->list_qual[8].cd_val = 1467513
 SET ins_code->list_qual[9].subhead = "Response to Education"
 SET ins_code->list_qual[9].cd_val = 1467516
 SET ins_code->list_qual[10].subhead = "Pre Consc Sedation Add Info"
 SET ins_code->list_qual[10].cd_val = 1473042
 RECORD dc_code(
   1 cnt = i2
   1 list_qual[7]
     2 subhead = vc
     2 cd_val = f8
 )
 SET dc_code->cnt = 7
 SET dc_code->list_qual[1].subhead = "Discontinued Date and Time"
 SET dc_code->list_qual[1].cd_val = 1464129
 SET dc_code->list_qual[2].subhead = "Protective Reflexes Intact"
 SET dc_code->list_qual[2].cd_val = 1467672
 SET dc_code->list_qual[3].subhead = "Can Sit Unaided"
 SET dc_code->list_qual[3].cd_val = 1467675
 SET dc_code->list_qual[4].subhead = "Evidence of Dehydration Noted"
 SET dc_code->list_qual[4].cd_val = 1468635
 SET dc_code->list_qual[5].subhead = "Aware of Signs to Report"
 SET dc_code->list_qual[5].cd_val = 1467685
 SET dc_code->list_qual[6].subhead = "D/C with Desgnated Transporter"
 SET dc_code->list_qual[6].cd_val = 1467688
 SET dc_code->list_qual[7].subhead = "D/C Consc Sed Add Info"
 SET dc_code->list_qual[7].cd_val = 1473047
 RECORD mp_code(
   1 cnt = i2
   1 list_qual[1]
     2 subhead = vc
     2 cd_val = f8
 )
 SET mp_code->cnt = 1
 SET mp_code->list_qual[1].subhead = "Protocol Modification"
 SET mp_code->list_qual[1].cd_val = 1467668
 RECORD as_code(
   1 cnt = i2
   1 list_qual[6]
     2 subhead1 = vc
     2 subhead2 = vc
     2 cd_val = f8
     2 col_num = i2
 )
 SET as_code->cnt = 6
 SET as_code->list_qual[1].subhead1 = "Patent"
 SET as_code->list_qual[1].subhead2 = "Airway"
 SET as_code->list_qual[1].cd_val = 1467383
 SET as_code->list_qual[1].col_num = 1
 SET as_code->list_qual[2].subhead1 = "Mental"
 SET as_code->list_qual[2].subhead2 = "Status"
 SET as_code->list_qual[2].cd_val = 1467631
 SET as_code->list_qual[2].col_num = 2
 SET as_code->list_qual[3].subhead1 = "Responds"
 SET as_code->list_qual[3].subhead2 = "Commands"
 SET as_code->list_qual[3].cd_val = 1467379
 SET as_code->list_qual[3].col_num = 3
 SET as_code->list_qual[4].subhead1 = "Sedation"
 SET as_code->list_qual[4].subhead2 = "Score"
 SET as_code->list_qual[4].cd_val = 1468452
 SET as_code->list_qual[4].col_num = 4
 SET as_code->list_qual[5].subhead1 = "Anesthesia"
 SET as_code->list_qual[5].subhead2 = "Scale"
 SET as_code->list_qual[5].cd_val = 1480189
 SET as_code->list_qual[5].col_num = 5
 SET as_code->list_qual[6].subhead1 = "Nausea"
 SET as_code->list_qual[6].subhead2 = "Scale"
 SET as_code->list_qual[6].cd_val = 1480192
 SET as_code->list_qual[6].col_num = 6
 RECORD rs_code(
   1 cnt = i2
   1 list_qual[3]
     2 subhead1 = vc
     2 subhead2 = vc
     2 cd_val = f8
     2 col_num = i2
 )
 SET rs_code->cnt = 3
 SET rs_code->list_qual[1].subhead1 = ""
 SET rs_code->list_qual[1].subhead2 = "Pulse Ox"
 SET rs_code->list_qual[1].cd_val = 1467359
 SET rs_code->list_qual[1].col_num = 1
 SET rs_code->list_qual[2].subhead1 = ""
 SET rs_code->list_qual[2].subhead2 = "O2 Ipm"
 SET rs_code->list_qual[2].cd_val = 1468138
 SET rs_code->list_qual[2].col_num = 2
 SET rs_code->list_qual[3].subhead1 = ""
 SET rs_code->list_qual[3].subhead2 = "O2 %"
 SET rs_code->list_qual[3].cd_val = 1468141
 SET rs_code->list_qual[3].col_num = 3
 RECORD vs_code(
   1 cnt = i2
   1 list_qual[6]
     2 subhead1 = vc
     2 subhead2 = vc
     2 cd_val = f8
     2 col_num = i2
 )
 SET vs_code->cnt = 6
 SET vs_code->list_qual[1].subhead1 = ""
 SET vs_code->list_qual[1].subhead2 = "Temp"
 SET vs_code->list_qual[1].cd_val = 1464094
 SET vs_code->list_qual[1].col_num = 1
 SET vs_code->list_qual[2].subhead1 = ""
 SET vs_code->list_qual[2].subhead2 = "SBP"
 SET vs_code->list_qual[2].cd_val = 1464103
 SET vs_code->list_qual[2].col_num = 2
 SET vs_code->list_qual[3].subhead1 = ""
 SET vs_code->list_qual[3].subhead2 = "DBP"
 SET vs_code->list_qual[3].cd_val = 1464106
 SET vs_code->list_qual[3].col_num = 3
 SET vs_code->list_qual[4].subhead1 = ""
 SET vs_code->list_qual[4].subhead2 = "Pulse"
 SET vs_code->list_qual[4].cd_val = 1464097
 SET vs_code->list_qual[4].col_num = 4
 SET vs_code->list_qual[5].subhead1 = "Pain"
 SET vs_code->list_qual[5].subhead2 = "Score"
 SET vs_code->list_qual[5].cd_val = 1464109
 SET vs_code->list_qual[5].col_num = 5
 SET vs_code->list_qual[6].subhead1 = ""
 SET vs_code->list_qual[6].subhead2 = "Resp"
 SET vs_code->list_qual[6].cd_val = 1464100
 SET vs_code->list_qual[6].col_num = 6
 RECORD cs_code(
   1 cnt = i2
   1 list_qual[5]
     2 subhead1 = vc
     2 subhead2 = vc
     2 cd_val = f8
     2 col_num = i2
 )
 SET cs_code->cnt = 5
 SET cs_code->list_qual[1].subhead1 = ""
 SET cs_code->list_qual[1].subhead2 = "IV Fluids"
 SET cs_code->list_qual[1].cd_val = 1480330
 SET cs_code->list_qual[1].col_num = 1
 SET cs_code->list_qual[2].subhead1 = ""
 SET cs_code->list_qual[2].subhead2 = "IV Rate"
 SET cs_code->list_qual[2].cd_val = 1480333
 SET cs_code->list_qual[2].col_num = 2
 SET cs_code->list_qual[3].subhead1 = ""
 SET cs_code->list_qual[3].subhead2 = "Medications"
 SET cs_code->list_qual[3].cd_val = 1480195
 SET cs_code->list_qual[3].col_num = 3
 SET cs_code->list_qual[4].subhead1 = ""
 SET cs_code->list_qual[4].subhead2 = "Dosage"
 SET cs_code->list_qual[4].cd_val = 1480198
 SET cs_code->list_qual[4].col_num = 4
 SET cs_code->list_qual[5].subhead1 = "Route of"
 SET cs_code->list_qual[5].subhead2 = "Administration"
 SET cs_code->list_qual[5].cd_val = 1480201
 SET cs_code->list_qual[5].col_num = 5
 RECORD pn_code(
   1 cnt = i2
   1 list_qual[3]
     2 subhead1 = vc
     2 subhead2 = vc
     2 cd_val = f8
     2 col_num = i2
 )
 SET pn_code->cnt = 3
 SET pn_code->list_qual[1].subhead1 = "Provider"
 SET pn_code->list_qual[1].subhead2 = "Notified"
 SET pn_code->list_qual[1].cd_val = 1467658
 SET pn_code->list_qual[1].col_num = 1
 SET pn_code->list_qual[2].subhead1 = "Reason"
 SET pn_code->list_qual[2].subhead2 = "Notified"
 SET pn_code->list_qual[2].cd_val = 1464126
 SET pn_code->list_qual[2].col_num = 2
 SET pn_code->list_qual[3].subhead1 = "Provider"
 SET pn_code->list_qual[3].subhead2 = "Response"
 SET pn_code->list_qual[3].cd_val = 1467661
 SET pn_code->list_qual[3].col_num = 3
 SET unit = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET service = fillstring(40," ")
 SET admitdoc = fillstring(30," ")
 SET attenddoc = fillstring(30," ")
 SET mrn = fillstring(20," ")
 SET name = fillstring(30," ")
 SET age = fillstring(20," ")
 SET dob = fillstring(20," ")
 SET sex = fillstring(10," ")
 SET visit = fillstring(2," ")
 SET adm_date = fillstring(20," ")
 RECORD care(
   1 cnt = i2
   1 care_qual[*]
     2 subhead = vc
     2 result = vc
     2 res_ln_cnt = i2
     2 res_qual[*]
       3 res_line = vc
     2 res_date = vc
     2 res_doc = vc
     2 res_id = f8
     2 note_ind = i2
     2 res_note = vc
     2 note_ln_cnt = i2
     2 note_qual[*]
       3 note_line = vc
 )
 RECORD ins(
   1 cnt = i2
   1 ins_qual[*]
     2 subhead = vc
     2 result = vc
     2 res_ln_cnt = i2
     2 res_qual[*]
       3 res_line = vc
     2 res_date = vc
     2 res_doc = vc
     2 res_id = f8
     2 note_ind = i2
     2 res_note = vc
     2 note_ln_cnt = i2
     2 note_qual[*]
       3 note_line = vc
 )
 RECORD mp(
   1 cnt = i2
   1 mp_qual[*]
     2 subhead = vc
     2 result = vc
     2 res_ln_cnt = i2
     2 res_qual[*]
       3 res_line = vc
     2 res_date = vc
     2 res_doc = vc
     2 res_id = f8
     2 note_ind = i2
     2 res_note = vc
     2 note_ln_cnt = i2
     2 note_qual[*]
       3 note_line = vc
 )
 RECORD as(
   1 cnt = i2
   1 qual_line[*]
     2 date = vc
     2 doc = vc
     2 cell_cnt = i4
     2 qual_cell[*]
       3 res = c10
       3 res_col = i2
       3 res_id = f8
       3 nt_ind = i2
       3 res_nt = vc
       3 nt_cnt = i2
       3 qual_nt[*]
         4 note_ln = vc
       3 res_status = vc
 )
 RECORD rs(
   1 cnt = i2
   1 qual_line[*]
     2 date = vc
     2 doc = vc
     2 cell_cnt = i4
     2 qual_cell[*]
       3 res = c10
       3 res_col = i2
       3 res_id = f8
       3 nt_ind = i2
       3 res_nt = vc
       3 nt_cnt = i2
       3 qual_nt[*]
         4 note_ln = vc
       3 res_status = vc
 )
 RECORD cs(
   1 cnt = i2
   1 qual_line[*]
     2 date = vc
     2 doc = vc
     2 cell_cnt = i4
     2 qual_cell[*]
       3 res = c10
       3 res_col = i2
       3 res_id = f8
       3 nt_ind = i2
       3 res_nt = vc
       3 nt_cnt = i2
       3 qual_nt[*]
         4 note_ln = vc
       3 res_status = vc
 )
 RECORD vs(
   1 cnt = i2
   1 qual_line[*]
     2 date = vc
     2 doc = vc
     2 cell_cnt = i4
     2 qual_cell[*]
       3 res = c10
       3 res_col = i2
       3 res_id = f8
       3 nt_ind = i2
       3 res_nt = vc
       3 nt_cnt = i2
       3 qual_nt[*]
         4 note_ln = vc
       3 res_status = vc
 )
 RECORD dc(
   1 cnt = i2
   1 dc_qual[*]
     2 subhead = vc
     2 result = vc
     2 res_ln_cnt = i2
     2 res_qual[*]
       3 res_line = vc
     2 res_date = vc
     2 res_doc = vc
     2 res_id = f8
     2 note_ind = i2
     2 res_note = vc
     2 note_ln_cnt = i2
     2 note_qual[*]
       3 note_line = vc
 )
 RECORD pn(
   1 cnt = i2
   1 qual_line[*]
     2 date = vc
     2 doc = vc
     2 cell_cnt = i4
     2 qual_cell[*]
       3 res = c10
       3 res_col = i2
       3 res_id = f8
       3 nt_ind = i2
       3 res_nt = vc
       3 nt_cnt = i2
       3 qual_nt[*]
         4 note_ln = vc
       3 res_status = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET error_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "MODIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET modify_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_prsnl_reltn epr1,
   encntr_prsnl_reltn epr2,
   prsnl pl1,
   prsnl pl2,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
   JOIN (d2)
   JOIN (epr1
   WHERE epr1.encntr_id=e.encntr_id
    AND epr1.encntr_prsnl_r_cd=attend_doc_cd
    AND epr1.active_ind=1
    AND ((epr1.expiration_ind != 1) OR (epr1.expiration_ind = null)) )
   JOIN (pl1
   WHERE pl1.person_id=epr1.prsnl_person_id)
   JOIN (d3)
   JOIN (epr2
   WHERE epr2.encntr_id=e.encntr_id
    AND epr2.encntr_prsnl_r_cd=admit_doc_cd
    AND epr2.active_ind=1
    AND ((epr2.expiration_ind != 1) OR (epr2.expiration_ind = null)) )
   JOIN (pl2
   WHERE pl2.person_id=epr2.prsnl_person_id)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),
    3), dob = trim(format(p.birth_dt_tm,"@SHORTDATE")),
   mrn = substring(1,20,pa.alias), attenddoc = substring(1,30,pl1.name_full_formatted), admitdoc =
   substring(1,30,pl2.name_full_formatted),
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,10,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)),
   sex = substring(1,20,uar_get_code_display(p.sex_cd)), service = substring(1,40,
    uar_get_code_display(e.med_service_cd)), adm_date = trim(format(e.reg_dt_tm,"@SHORTDATE")),
   person_id = e.person_id, encounter_id = e.encntr_id
  WITH nocounter, outerjoin = d1, dontcare = pa,
   dontcare = epr, outerjoin = d2, outerjoin = d3
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(care_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=care_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != error_cd
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.verified_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   care->cnt = 0
  HEAD c.event_cd
   care->cnt = (care->cnt+ 1), stat = alterlist(care->care_qual,care->cnt), care->care_qual[care->cnt
   ].subhead = concat(care_code->list_qual[d.seq].subhead,":")
   IF (c.result_status_cd=error_cd)
    care->care_qual[care->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), care
    ->care_qual[care->cnt].result = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    care->care_qual[care->cnt].res_date = trim(format(c.valid_from_dt_tm,"@SHORTDATETIMENOSEC")),
    care->care_qual[care->cnt].result = concat(trim(c.result_val)," (Modified)")
   ELSE
    care->care_qual[care->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), care
    ->care_qual[care->cnt].result = trim(c.result_val)
   ENDIF
   care->care_qual[care->cnt].res_doc = trim(pl.name_full_formatted), care->care_qual[care->cnt].
   res_id = c.event_id, care->care_qual[care->cnt].note_ind = btest(c.subtable_bit_map,1)
  WITH nocounter
 ;end select
 SET max_length = 40
 FOR (i = 1 TO care->cnt)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text value(care->care_qual[i].result), value(max_length)
   SET stat = alterlist(care->care_qual[i].res_qual,pt->line_cnt)
   SET care->care_qual[i].res_ln_cnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET care->care_qual[i].res_qual[j].res_line = pt->lns[j].line
   ENDFOR
 ENDFOR
 SET max_note_length = 100
 FOR (i = 1 TO care->cnt)
   IF ((care->care_qual[i].note_ind=1))
    SET event_id = care->care_qual[i].res_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET care->care_qual[i].res_note = concat("Comment: ",trim(blob_out,3))
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(care->care_qual[i].res_note), value(max_note_length)
    SET stat = alterlist(care->care_qual[i].note_qual,pt->line_cnt)
    SET care->care_qual[i].note_ln_cnt = pt->line_cnt
    FOR (j = 1 TO pt->line_cnt)
      SET care->care_qual[i].note_qual[j].note_line = pt->lns[j].line
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(ins_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=ins_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != error_cd
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.verified_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   ins->cnt = 0
  HEAD c.event_cd
   IF (d.seq=1)
    ins_flag = (ins_flag+ 1)
   ELSEIF (d.seq=2)
    ins_flag = (ins_flag+ 1)
   ENDIF
   ins->cnt = (ins->cnt+ 1), stat = alterlist(ins->ins_qual,ins->cnt), ins->ins_qual[ins->cnt].
   subhead = concat(ins_code->list_qual[d.seq].subhead,":")
   IF (c.result_status_cd=error_cd)
    ins->ins_qual[ins->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), ins->
    ins_qual[ins->cnt].result = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    ins->ins_qual[ins->cnt].res_date = trim(format(c.valid_from_dt_tm,"@SHORTDATETIMENOSEC")), ins->
    ins_qual[ins->cnt].result = concat(trim(c.result_val)," (Modified)")
   ELSE
    ins->ins_qual[ins->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), ins->
    ins_qual[ins->cnt].result = trim(c.result_val)
   ENDIF
   ins->ins_qual[ins->cnt].res_doc = trim(pl.name_full_formatted), ins->ins_qual[ins->cnt].res_id = c
   .event_id, ins->ins_qual[ins->cnt].note_ind = btest(c.subtable_bit_map,1)
  WITH nocounter
 ;end select
 SET max_length = 40
 FOR (i = 1 TO ins->cnt)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text value(ins->ins_qual[i].result), value(max_length)
   SET stat = alterlist(ins->ins_qual[i].res_qual,pt->line_cnt)
   SET ins->ins_qual[i].res_ln_cnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET ins->ins_qual[i].res_qual[j].res_line = pt->lns[j].line
   ENDFOR
 ENDFOR
 SET max_note_length = 100
 FOR (i = 1 TO ins->cnt)
   IF ((ins->ins_qual[i].note_ind=1))
    SET event_id = ins->ins_qual[i].res_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET ins->ins_qual[i].res_note = concat("Comment: ",trim(blob_out,3))
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(ins->ins_qual[i].res_note), value(max_note_length)
    SET stat = alterlist(ins->ins_qual[i].note_qual,pt->line_cnt)
    SET ins->ins_qual[i].note_ln_cnt = pt->line_cnt
    FOR (j = 1 TO pt->line_cnt)
      SET ins->ins_qual[i].note_qual[j].note_line = pt->lns[j].line
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(as_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=as_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   as->cnt = 0
  HEAD c.event_end_dt_tm
   as->cnt = (as->cnt+ 1), stat = alterlist(as->qual_line,as->cnt), as->qual_line[as->cnt].date =
   trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")),
   as->qual_line[as->cnt].doc = trim(pl.name_full_formatted,3), temp = 0
  HEAD c.event_cd
   temp = (temp+ 1), stat = alterlist(as->qual_line[as->cnt].qual_cell,temp), as->qual_line[as->cnt].
   qual_cell[temp].res = substring(1,10,c.result_val),
   as->qual_line[as->cnt].qual_cell[temp].res_col = as_code->list_qual[d.seq].col_num, as->qual_line[
   as->cnt].qual_cell[temp].res_id = c.event_id, as->qual_line[as->cnt].qual_cell[temp].nt_ind =
   btest(c.subtable_bit_map,1)
   IF (c.result_status_cd=error_cd)
    as->qual_line[as->cnt].qual_cell[temp].res = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    as->qual_line[as->cnt].qual_cell[temp].res_status = "(Modified)"
   ENDIF
  FOOT  c.event_end_dt_tm
   as->qual_line[as->cnt].cell_cnt = temp
  WITH nocounter
 ;end select
 SET strg1 = fillstring(20," ")
 SET strg2 = fillstring(20," ")
 SET max_length = 100
 FOR (ii = 1 TO as->cnt)
   FOR (jj = 1 TO as->qual_line[ii].cell_cnt)
     IF ((as->qual_line[ii].qual_cell[jj].nt_ind=1))
      SET event_id = as->qual_line[ii].qual_cell[jj].res_id
      EXECUTE FROM get_note_begin TO get_note_end
      SET xx = as->qual_line[ii].qual_cell[jj].res_col
      SET strg1 = trim(as_code->list_qual[xx].subhead1)
      SET strg2 = trim(as_code->list_qual[xx].subhead2)
      SET as->qual_line[ii].qual_cell[jj].res_nt = concat(trim(strg1)," ",trim(strg2)," Comment: ",
       trim(blob_out,3))
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(as->qual_line[ii].qual_cell[jj].res_nt), value(max_length)
      SET stat = alterlist(as->qual_line[ii].qual_cell[jj].qual_nt,pt->line_cnt)
      SET as->qual_line[ii].qual_cell[jj].nt_cnt = pt->line_cnt
      FOR (y = 1 TO pt->line_cnt)
        SET as->qual_line[ii].qual_cell[jj].qual_nt[y].note_ln = pt->lns[y].line
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(rs_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=rs_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   rs->cnt = 0
  HEAD c.event_end_dt_tm
   rs->cnt = (rs->cnt+ 1), stat = alterlist(rs->qual_line,rs->cnt), rs->qual_line[rs->cnt].date =
   trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")),
   rs->qual_line[rs->cnt].doc = trim(pl.name_full_formatted,3), temp = 0
  HEAD c.event_cd
   temp = (temp+ 1), stat = alterlist(rs->qual_line[rs->cnt].qual_cell,temp), rs->qual_line[rs->cnt].
   qual_cell[temp].res = substring(1,10,c.result_val),
   rs->qual_line[rs->cnt].qual_cell[temp].res_col = rs_code->list_qual[d.seq].col_num, rs->qual_line[
   rs->cnt].qual_cell[temp].res_id = c.event_id, rs->qual_line[rs->cnt].qual_cell[temp].nt_ind =
   btest(c.subtable_bit_map,1)
   IF (c.result_status_cd=error_cd)
    rs->qual_line[rs->cnt].qual_cell[temp].res = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    rs->qual_line[rs->cnt].qual_cell[temp].res_status = "(Modified)"
   ENDIF
  FOOT  c.event_end_dt_tm
   rs->qual_line[rs->cnt].cell_cnt = temp
  WITH nocounter
 ;end select
 SET strg1 = fillstring(20," ")
 SET strg2 = fillstring(20," ")
 SET max_length = 100
 FOR (ii = 1 TO rs->cnt)
   FOR (jj = 1 TO rs->qual_line[ii].cell_cnt)
     IF ((rs->qual_line[ii].qual_cell[jj].nt_ind=1))
      SET event_id = rs->qual_line[ii].qual_cell[jj].res_id
      EXECUTE FROM get_note_begin TO get_note_end
      SET xx = rs->qual_line[ii].qual_cell[jj].res_col
      SET strg1 = trim(rs_code->list_qual[xx].subhead1)
      SET strg2 = trim(rs_code->list_qual[xx].subhead2)
      SET rs->qual_line[ii].qual_cell[jj].res_nt = concat(trim(strg1)," ",trim(strg2)," Comment: ",
       trim(blob_out,3))
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(rs->qual_line[ii].qual_cell[jj].res_nt), value(max_length)
      SET stat = alterlist(rs->qual_line[ii].qual_cell[jj].qual_nt,pt->line_cnt)
      SET rs->qual_line[ii].qual_cell[jj].nt_cnt = pt->line_cnt
      FOR (y = 1 TO pt->line_cnt)
        SET rs->qual_line[ii].qual_cell[jj].qual_nt[y].note_ln = pt->lns[y].line
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(vs_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=vs_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   vs->cnt = 0
  HEAD c.event_end_dt_tm
   vs->cnt = (vs->cnt+ 1), stat = alterlist(vs->qual_line,vs->cnt), vs->qual_line[vs->cnt].date =
   trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")),
   vs->qual_line[vs->cnt].doc = trim(pl.name_full_formatted,3), temp = 0
  HEAD c.event_cd
   temp = (temp+ 1), stat = alterlist(vs->qual_line[vs->cnt].qual_cell,temp), vs->qual_line[vs->cnt].
   qual_cell[temp].res = substring(1,10,c.result_val),
   vs->qual_line[vs->cnt].qual_cell[temp].res_col = vs_code->list_qual[d.seq].col_num, vs->qual_line[
   vs->cnt].qual_cell[temp].res_id = c.event_id, vs->qual_line[vs->cnt].qual_cell[temp].nt_ind =
   btest(c.subtable_bit_map,1)
   IF (c.result_status_cd=error_cd)
    vs->qual_line[vs->cnt].qual_cell[temp].res = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    vs->qual_line[vs->cnt].qual_cell[temp].res_status = "(Modified)"
   ENDIF
  FOOT  c.event_end_dt_tm
   vs->qual_line[vs->cnt].cell_cnt = temp
  WITH nocounter
 ;end select
 SET strg1 = fillstring(20," ")
 SET strg2 = fillstring(20," ")
 SET max_length = 100
 FOR (ii = 1 TO vs->cnt)
   FOR (jj = 1 TO vs->qual_line[ii].cell_cnt)
     IF ((vs->qual_line[ii].qual_cell[jj].nt_ind=1))
      SET event_id = vs->qual_line[ii].qual_cell[jj].res_id
      EXECUTE FROM get_note_begin TO get_note_end
      SET xx = vs->qual_line[ii].qual_cell[jj].res_col
      SET strg1 = trim(vs_code->list_qual[xx].subhead1)
      SET strg2 = trim(vs_code->list_qual[xx].subhead2)
      SET vs->qual_line[ii].qual_cell[jj].res_nt = concat(trim(strg1)," ",trim(strg2)," Comment: ",
       trim(blob_out,3))
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(vs->qual_line[ii].qual_cell[jj].res_nt), value(max_length)
      SET stat = alterlist(vs->qual_line[ii].qual_cell[jj].qual_nt,pt->line_cnt)
      SET vs->qual_line[ii].qual_cell[jj].nt_cnt = pt->line_cnt
      FOR (y = 1 TO pt->line_cnt)
        SET vs->qual_line[ii].qual_cell[jj].qual_nt[y].note_ln = pt->lns[y].line
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(cs_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=cs_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   cs->cnt = 0
  HEAD c.event_end_dt_tm
   cs->cnt = (cs->cnt+ 1), stat = alterlist(cs->qual_line,cs->cnt), cs->qual_line[cs->cnt].date =
   trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")),
   cs->qual_line[cs->cnt].doc = trim(pl.name_full_formatted,3), temp = 0
  HEAD c.event_cd
   temp = (temp+ 1), stat = alterlist(cs->qual_line[cs->cnt].qual_cell,temp), cs->qual_line[cs->cnt].
   qual_cell[temp].res = substring(1,10,c.result_val),
   cs->qual_line[cs->cnt].qual_cell[temp].res_col = cs_code->list_qual[d.seq].col_num, cs->qual_line[
   cs->cnt].qual_cell[temp].res_id = c.event_id, cs->qual_line[cs->cnt].qual_cell[temp].nt_ind =
   btest(c.subtable_bit_map,1)
   IF (c.result_status_cd=error_cd)
    cs->qual_line[cs->cnt].qual_cell[temp].res = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    cs->qual_line[cs->cnt].qual_cell[temp].res_status = "(Modified)"
   ENDIF
  FOOT  c.event_end_dt_tm
   cs->qual_line[cs->cnt].cell_cnt = temp
  WITH nocounter
 ;end select
 SET strg1 = fillstring(20," ")
 SET strg2 = fillstring(20," ")
 SET max_length = 100
 FOR (ii = 1 TO cs->cnt)
   FOR (jj = 1 TO cs->qual_line[ii].cell_cnt)
     IF ((cs->qual_line[ii].qual_cell[jj].nt_ind=1))
      SET event_id = cs->qual_line[ii].qual_cell[jj].res_id
      EXECUTE FROM get_note_begin TO get_note_end
      SET xx = cs->qual_line[ii].qual_cell[jj].res_col
      SET strg1 = trim(cs_code->list_qual[xx].subhead1)
      SET strg2 = trim(cs_code->list_qual[xx].subhead2)
      SET cs->qual_line[ii].qual_cell[jj].res_nt = concat(trim(strg1)," ",trim(strg2)," Comment: ",
       trim(blob_out,3))
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(cs->qual_line[ii].qual_cell[jj].res_nt), value(max_length)
      SET stat = alterlist(cs->qual_line[ii].qual_cell[jj].qual_nt,pt->line_cnt)
      SET cs->qual_line[ii].qual_cell[jj].nt_cnt = pt->line_cnt
      FOR (y = 1 TO pt->line_cnt)
        SET cs->qual_line[ii].qual_cell[jj].qual_nt[y].note_ln = pt->lns[y].line
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(dc_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=dc_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != error_cd
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.verified_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   dc->cnt = 0
  HEAD c.event_cd
   dc->cnt = (dc->cnt+ 1), stat = alterlist(dc->dc_qual,dc->cnt), dc->dc_qual[dc->cnt].subhead =
   concat(dc_code->list_qual[d.seq].subhead,":")
   IF (c.result_status_cd=error_cd)
    dc->dc_qual[dc->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), dc->
    dc_qual[dc->cnt].result = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    dc->dc_qual[dc->cnt].res_date = trim(format(c.valid_from_dt_tm,"@SHORTDATETIMENOSEC")), dc->
    dc_qual[dc->cnt].result = concat(trim(c.result_val)," (Modified)")
   ELSE
    dc->dc_qual[dc->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), dc->
    dc_qual[dc->cnt].result = trim(c.result_val)
   ENDIF
   dc->dc_qual[dc->cnt].res_doc = trim(pl.name_full_formatted), dc->dc_qual[dc->cnt].res_id = c
   .event_id, dc->dc_qual[dc->cnt].note_ind = btest(c.subtable_bit_map,1)
  WITH nocounter
 ;end select
 SET max_length = 40
 FOR (i = 1 TO dc->cnt)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text value(dc->dc_qual[i].result), value(max_length)
   SET stat = alterlist(dc->dc_qual[i].res_qual,pt->line_cnt)
   SET dc->dc_qual[i].res_ln_cnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET dc->dc_qual[i].res_qual[j].res_line = pt->lns[j].line
   ENDFOR
 ENDFOR
 SET max_note_length = 100
 FOR (i = 1 TO dc->cnt)
   IF ((dc->dc_qual[i].note_ind=1))
    SET event_id = dc->dc_qual[i].res_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET dc->dc_qual[i].res_note = concat("Comment: ",trim(blob_out,3))
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(dc->dc_qual[i].res_note), value(max_note_length)
    SET stat = alterlist(dc->dc_qual[i].note_qual,pt->line_cnt)
    SET dc->dc_qual[i].note_ln_cnt = pt->line_cnt
    FOR (j = 1 TO pt->line_cnt)
      SET dc->dc_qual[i].note_qual[j].note_line = pt->lns[j].line
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(pn_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=pn_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   pn->cnt = 0
  HEAD c.event_end_dt_tm
   pn->cnt = (pn->cnt+ 1), stat = alterlist(pn->qual_line,pn->cnt), pn->qual_line[pn->cnt].date =
   trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")),
   pn->qual_line[pn->cnt].doc = trim(pl.name_full_formatted,3), temp = 0
  HEAD c.event_cd
   temp = (temp+ 1), stat = alterlist(pn->qual_line[pn->cnt].qual_cell,temp), pn->qual_line[pn->cnt].
   qual_cell[temp].res = substring(1,10,c.result_val),
   pn->qual_line[pn->cnt].qual_cell[temp].res_col = pn_code->list_qual[d.seq].col_num, pn->qual_line[
   pn->cnt].qual_cell[temp].res_id = c.event_id, pn->qual_line[pn->cnt].qual_cell[temp].nt_ind =
   btest(c.subtable_bit_map,1)
   IF (c.result_status_cd=error_cd)
    pn->qual_line[pn->cnt].qual_cell[temp].res = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    pn->qual_line[pn->cnt].qual_cell[temp].res_status = "(Modified)"
   ENDIF
  FOOT  c.event_end_dt_tm
   pn->qual_line[pn->cnt].cell_cnt = temp
  WITH nocounter
 ;end select
 SET strg1 = fillstring(20," ")
 SET strg2 = fillstring(20," ")
 SET max_length = 100
 FOR (ii = 1 TO pn->cnt)
   FOR (jj = 1 TO pn->qual_line[ii].cell_cnt)
     IF ((pn->qual_line[ii].qual_cell[jj].nt_ind=1))
      SET event_id = pn->qual_line[ii].qual_cell[jj].res_id
      EXECUTE FROM get_note_begin TO get_note_end
      SET xx = pn->qual_line[ii].qual_cell[jj].res_col
      SET strg1 = trim(pn_code->list_qual[xx].subhead1)
      SET strg2 = trim(pn_code->list_qual[xx].subhead2)
      SET pn->qual_line[ii].qual_cell[jj].res_nt = concat(trim(strg1)," ",trim(strg2)," Comment: ",
       trim(blob_out,3))
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(pn->qual_line[ii].qual_cell[jj].res_nt), value(max_length)
      SET stat = alterlist(pn->qual_line[ii].qual_cell[jj].qual_nt,pt->line_cnt)
      SET pn->qual_line[ii].qual_cell[jj].nt_cnt = pt->line_cnt
      FOR (y = 1 TO pt->line_cnt)
        SET pn->qual_line[ii].qual_cell[jj].qual_nt[y].note_ln = pt->lns[y].line
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl,
   (dummyt d  WITH seq = value(mp_code->cnt))
  PLAN (d)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND (c.event_cd=mp_code->list_qual[d.seq].cd_val)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != error_cd
    AND c.event_end_dt_tm >= cnvtdatetime(eh1805_beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(eh1805_end_dt_tm))
   JOIN (pl
   WHERE pl.person_id=c.verified_prsnl_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm), c.event_cd
  HEAD REPORT
   mp->cnt = 0
  HEAD c.event_cd
   mp->cnt = (mp->cnt+ 1), stat = alterlist(mp->mp_qual,mp->cnt), mp->mp_qual[mp->cnt].subhead =
   concat(mp_code->list_qual[d.seq].subhead,":")
   IF (c.result_status_cd=error_cd)
    mp->mp_qual[mp->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), mp->
    mp_qual[mp->cnt].result = "(In Error)"
   ELSEIF (c.result_status_cd=modify_cd)
    mp->mp_qual[mp->cnt].res_date = trim(format(c.valid_from_dt_tm,"@SHORTDATETIMENOSEC")), mp->
    mp_qual[mp->cnt].result = concat(trim(c.result_val)," (Modified)")
   ELSE
    mp->mp_qual[mp->cnt].res_date = trim(format(c.event_end_dt_tm,"@SHORTDATETIMENOSEC")), mp->
    mp_qual[mp->cnt].result = trim(c.result_val)
   ENDIF
   mp->mp_qual[mp->cnt].res_doc = trim(pl.name_full_formatted), mp->mp_qual[mp->cnt].res_id = c
   .event_id, mp->mp_qual[mp->cnt].note_ind = btest(c.subtable_bit_map,1)
  WITH nocounter
 ;end select
 SET max_length = 40
 FOR (i = 1 TO mp->cnt)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text value(mp->mp_qual[i].result), value(max_length)
   SET stat = alterlist(mp->mp_qual[i].res_qual,pt->line_cnt)
   SET mp->mp_qual[i].res_ln_cnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET mp->mp_qual[i].res_qual[j].res_line = pt->lns[j].line
   ENDFOR
 ENDFOR
 SET max_note_length = 100
 FOR (i = 1 TO mp->cnt)
   IF ((mp->mp_qual[i].note_ind=1))
    SET event_id = mp->mp_qual[i].res_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET mp->mp_qual[i].res_note = concat("Comment: ",trim(blob_out,3))
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(mp->mp_qual[i].res_note), value(max_note_length)
    SET stat = alterlist(mp->mp_qual[i].note_qual,pt->line_cnt)
    SET mp->mp_qual[i].note_ln_cnt = pt->line_cnt
    FOR (j = 1 TO pt->line_cnt)
      SET mp->mp_qual[i].note_qual[j].note_line = pt->lns[j].line
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO value(request->output_device)
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   "{f/8}", "{cpi/13}", "{ipc}"
  HEAD PAGE
   "{b}{pos/250/38}Plan of Care Database{endb}", row + 1, "{b}{pos/30/62}",
   u_line, row + 1, "{pos/30/74}Location{pos/139/74}:  ",
   unit, "{pos/320/74}MRN{pos/397/74}:  ", mrn,
   row + 1
   IF (trim(bed) != " "
    AND trim(room) != " ")
    yyy = concat(trim(room)," ; ",trim(bed)), "{pos/30/86}Room & Bed{pos/139/86}:  ", yyy,
    row + 1
   ELSE
    "{pos/30/86}Room & Bed{pos/139/86}:  ", row + 1
   ENDIF
   "{pos/320/86}Patient Name{pos/397/86}:  ", name, row + 1,
   "{pos/30/98}Service{pos/139/98}:  ", service, "{pos/320/98}DOB{pos/397/98}:  ",
   dob, row + 1, "{pos/30/110}Admitting Physician{pos/139/110}:  ",
   admitdoc, "{pos/320/110}Gender{pos/397/110}:  ", sex,
   row + 1, "{pos/30/122}Attending Physician{pos/139/122}:  ", attenddoc,
   "{pos/320/122}Visit Number{pos/397/122}:  ", visit, row + 1,
   "{pos/320/134}Admission Date{pos/397/134}:  ", adm_date, row + 1,
   "{b}{pos/30/137}", u_line, row + 1
  HEAD d.seq
   xcol = 30, ycol = 160, head_y = ycol
  DETAIL
   IF ((care->cnt > 0))
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Plan of Care Requirements",
    row + 1, cur_head = concat("Plan of Care Requirements"," (cont'd)"), ycol = (ycol+ 12)
    FOR (i = 1 TO care->cnt)
      IF ((((ycol+ (care->care_qual[i].res_ln_cnt * 12))+ (care->care_qual[i].note_ln_cnt * 12)) >
      716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), care->care_qual[i].subhead,
      row + 1, xcol = 400,
      CALL print(calcpos(xcol,ycol)),
      care->care_qual[i].res_date, row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)), care->care_qual[i].res_doc, row + 1,
      xcol = 200
      FOR (j = 1 TO care->care_qual[i].res_ln_cnt)
        CALL print(calcpos(xcol,ycol)), care->care_qual[i].res_qual[j].res_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
      xcol = 50
      FOR (j = 1 TO care->care_qual[i].note_ln_cnt)
        CALL print(calcpos(xcol,ycol)), care->care_qual[i].note_qual[j].note_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
    ENDFOR
    ycol = (ycol+ 12)
   ENDIF
   IF ((ins->cnt > 0))
    cur_head = fillstring(40," "), xcol = 30
    IF ((care->cnt > 0))
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    IF (((ycol+ 36) > 716))
     BREAK, ycol = head_y
    ENDIF
    CALL print(calcpos(xcol,ycol)), "{b}{u}Instructions", row + 1,
    cur_head = concat("Instructions"," (cont'd)"), ycol = (ycol+ 12)
    FOR (i = 1 TO ins->cnt)
      IF ((((ycol+ (ins->ins_qual[i].res_ln_cnt * 12))+ (ins->ins_qual[i].note_ln_cnt * 12)) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 12)
      ENDIF
      IF (i=ins_flag)
       IF (ins_flag=1)
        xcol = 30,
        CALL print(calcpos(xcol,ycol)), long_line,
        row + 1, ycol = (ycol+ 12)
       ELSEIF (ins_flag=2
        AND (ins->cnt > 1))
        xcol = 30, ycol = (ycol+ 12),
        CALL print(calcpos(xcol,ycol)),
        long_line, row + 1, ycol = (ycol+ 12)
       ELSEIF (ins_flag=3
        AND (ins->cnt > 2))
        xcol = 30, ycol = (ycol+ 12),
        CALL print(calcpos(xcol,ycol)),
        long_line, row + 1, ycol = (ycol+ 12)
       ENDIF
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), ins->ins_qual[i].subhead,
      row + 1, xcol = 400,
      CALL print(calcpos(xcol,ycol)),
      ins->ins_qual[i].res_date, row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)), ins->ins_qual[i].res_doc, row + 1,
      xcol = 200
      FOR (j = 1 TO ins->ins_qual[i].res_ln_cnt)
        CALL print(calcpos(xcol,ycol)), ins->ins_qual[i].res_qual[j].res_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
      xcol = 50
      FOR (j = 1 TO ins->ins_qual[i].note_ln_cnt)
        CALL print(calcpos(xcol,ycol)), ins->ins_qual[i].note_qual[j].note_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
    ENDFOR
    ycol = (ycol+ 12)
   ENDIF
   IF ((as->cnt > 0))
    cur_head = fillstring(40," "), xcol = 30
    IF ((((care->cnt > 0)) OR ((ins->cnt > 0))) )
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    IF (((ycol+ 72) > 716))
     BREAK, ycol = head_y
    ENDIF
    CALL print(calcpos(xcol,ycol)), "{b}{u}Assessment Scales", row + 1,
    cur_head = concat("Assessment Scales"," (cont'd)"), ycol = (ycol+ 24), xcol = 100
    FOR (i = 1 TO as_code->cnt)
      CALL print(calcpos(xcol,ycol)), "{b}", as_code->list_qual[i].subhead1,
      row + 1, ty = (ycol+ 12),
      CALL print(calcpos(xcol,ty)),
      "{b}{u}", as_code->list_qual[i].subhead2, row + 1,
      xcol = (xcol+ 60)
    ENDFOR
    ycol = (ycol+ 12), xcol = 460,
    CALL print(calcpos(xcol,ycol)),
    "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
    FOR (x = 1 TO as->cnt)
      stat_flag = 0
      IF (((ycol+ 24) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 24), xcol = 100
       FOR (i = 1 TO as_code->cnt)
         CALL print(calcpos(xcol,ycol)), "{b}", as_code->list_qual[i].subhead1,
         row + 1, ty = (ycol+ 12),
         CALL print(calcpos(xcol,ty)),
         "{b}{u}", as_code->list_qual[i].subhead2, row + 1,
         xcol = (xcol+ 60)
       ENDFOR
       ycol = (ycol+ 12), xcol = 460,
       CALL print(calcpos(xcol,ycol)),
       "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), as->qual_line[x].date,
      row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)),
      as->qual_line[x].doc, row + 1, xcol = 100
      FOR (xx = 1 TO as->qual_line[x].cell_cnt)
        xcol = (100+ (60 * (as->qual_line[x].qual_cell[xx].res_col - 1))),
        CALL print(calcpos(xcol,ycol)), as->qual_line[x].qual_cell[xx].res,
        row + 1
        IF ((as->qual_line[x].qual_cell[xx].res_status > " "))
         stat_flag = 1, ycol = (ycol+ 12),
         CALL print(calcpos(xcol,ycol)),
         as->qual_line[x].qual_cell[xx].res_status, row + 1, ycol = (ycol - 12)
        ENDIF
      ENDFOR
      IF (stat_flag=1)
       ycol = (ycol+ 24)
      ELSE
       ycol = (ycol+ 12)
      ENDIF
      FOR (xx = 1 TO as->qual_line[x].cell_cnt)
        IF ((as->qual_line[x].qual_cell[xx].nt_ind=1))
         FOR (xxx = 1 TO as->qual_line[x].qual_cell[xx].nt_cnt)
           xcol = 50,
           CALL print(calcpos(xcol,ycol)), as->qual_line[x].qual_cell[xx].qual_nt[xxx].note_ln,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((rs->cnt > 0))
    cur_head = fillstring(40," "), xcol = 30
    IF ((((care->cnt > 0)) OR ((((ins->cnt > 0)) OR ((as->cnt > 0))) )) )
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    IF (((ycol+ 72) > 716))
     BREAK, ycol = head_y
    ENDIF
    CALL print(calcpos(xcol,ycol)), "{b}{u}Respiratory Status", row + 1,
    cur_head = concat("Respiratory Status"," (cont'd)"), ycol = (ycol+ 24), xcol = 100
    FOR (i = 1 TO rs_code->cnt)
      CALL print(calcpos(xcol,ycol)), "{b}{u}", rs_code->list_qual[i].subhead2,
      row + 1, xcol = (xcol+ 60)
    ENDFOR
    xcol = 460,
    CALL print(calcpos(xcol,ycol)), "{u}{b}Performed By",
    row + 1, ycol = (ycol+ 12)
    FOR (x = 1 TO rs->cnt)
      stat_flag = 0
      IF (((ycol+ 24) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 24), xcol = 100
       FOR (i = 1 TO rs_code->cnt)
         CALL print(calcpos(xcol,ty)), "{b}{u}", rs_code->list_qual[i].subhead2,
         row + 1, xcol = (xcol+ 60)
       ENDFOR
       ycol = (ycol+ 12), xcol = 460,
       CALL print(calcpos(xcol,ycol)),
       "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), rs->qual_line[x].date,
      row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)),
      rs->qual_line[x].doc, row + 1, xcol = 100
      FOR (xx = 1 TO rs->qual_line[x].cell_cnt)
        xcol = (100+ (60 * (rs->qual_line[x].qual_cell[xx].res_col - 1))),
        CALL print(calcpos(xcol,ycol)), rs->qual_line[x].qual_cell[xx].res,
        row + 1
        IF ((rs->qual_line[x].qual_cell[xx].res_status > " "))
         stat_flag = 1, ycol = (ycol+ 12),
         CALL print(calcpos(xcol,ycol)),
         rs->qual_line[x].qual_cell[xx].res_status, row + 1, ycol = (ycol - 12)
        ENDIF
      ENDFOR
      IF (stat_flag=1)
       ycol = (ycol+ 24)
      ELSE
       ycol = (ycol+ 12)
      ENDIF
      FOR (xx = 1 TO rs->qual_line[x].cell_cnt)
        IF ((rs->qual_line[x].qual_cell[xx].nt_ind=1))
         FOR (xxx = 1 TO rs->qual_line[x].qual_cell[xx].nt_cnt)
           xcol = 50,
           CALL print(calcpos(xcol,ycol)), rs->qual_line[x].qual_cell[xx].qual_nt[xxx].note_ln,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((vs->cnt > 0))
    cur_head = fillstring(40," "), xcol = 30
    IF ((((care->cnt > 0)) OR ((((ins->cnt > 0)) OR ((((as->cnt > 0)) OR ((rs->cnt > 0))) )) )) )
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    IF (((ycol+ 72) > 716))
     BREAK, ycol = head_y
    ENDIF
    CALL print(calcpos(xcol,ycol)), "{b}{u}Vital Sign Record", row + 1,
    cur_head = concat("Vital Sign Record"," (cont'd)"), ycol = (ycol+ 24), xcol = 100
    FOR (i = 1 TO vs_code->cnt)
      CALL print(calcpos(xcol,ycol)), "{b}", vs_code->list_qual[i].subhead1,
      row + 1, ty = (ycol+ 12),
      CALL print(calcpos(xcol,ty)),
      "{b}{u}", vs_code->list_qual[i].subhead2, row + 1,
      xcol = (xcol+ 60)
    ENDFOR
    ycol = (ycol+ 12), xcol = 460,
    CALL print(calcpos(xcol,ycol)),
    "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
    FOR (x = 1 TO vs->cnt)
      stat_flag = 0
      IF (((ycol+ 24) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 24), xcol = 100
       FOR (i = 1 TO vs_code->cnt)
         CALL print(calcpos(xcol,ycol)), "{b}", vs_code->list_qual[i].subhead1,
         row + 1, ty = (ycol+ 12),
         CALL print(calcpos(xcol,ty)),
         "{b}{u}", vs_code->list_qual[i].subhead2, row + 1,
         xcol = (xcol+ 60)
       ENDFOR
       ycol = (ycol+ 12), xcol = 460,
       CALL print(calcpos(xcol,ycol)),
       "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), vs->qual_line[x].date,
      row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)),
      vs->qual_line[x].doc, row + 1, xcol = 100
      FOR (xx = 1 TO vs->qual_line[x].cell_cnt)
        xcol = (100+ (60 * (vs->qual_line[x].qual_cell[xx].res_col - 1))),
        CALL print(calcpos(xcol,ycol)), vs->qual_line[x].qual_cell[xx].res,
        row + 1
        IF ((vs->qual_line[x].qual_cell[xx].res_status > " "))
         stat_flag = 1, ycol = (ycol+ 12),
         CALL print(calcpos(xcol,ycol)),
         vs->qual_line[x].qual_cell[xx].res_status, row + 1, ycol = (ycol - 12)
        ENDIF
      ENDFOR
      IF (stat_flag=1)
       ycol = (ycol+ 24)
      ELSE
       ycol = (ycol+ 12)
      ENDIF
      FOR (xx = 1 TO vs->qual_line[x].cell_cnt)
        IF ((vs->qual_line[x].qual_cell[xx].nt_ind=1))
         FOR (xxx = 1 TO vs->qual_line[x].qual_cell[xx].nt_cnt)
           xcol = 50,
           CALL print(calcpos(xcol,ycol)), vs->qual_line[x].qual_cell[xx].qual_nt[xxx].note_ln,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((cs->cnt > 0))
    cur_head = fillstring(40," "), xcol = 30
    IF ((((care->cnt > 0)) OR ((((ins->cnt > 0)) OR ((((as->cnt > 0)) OR ((((rs->cnt > 0)) OR ((vs->
    cnt > 0))) )) )) )) )
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    IF (((ycol+ 72) > 716))
     BREAK, ycol = head_y
    ENDIF
    CALL print(calcpos(xcol,ycol)), "{b}{u}Conscious Sedation Medications", row + 1,
    cur_head = concat("Conscious Sedation Medications"," (cont'd)"), ycol = (ycol+ 24), xcol = 100
    FOR (i = 1 TO cs_code->cnt)
      CALL print(calcpos(xcol,ycol)), "{b}", cs_code->list_qual[i].subhead1,
      row + 1, ty = (ycol+ 12),
      CALL print(calcpos(xcol,ty)),
      "{b}{u}", cs_code->list_qual[i].subhead2, row + 1,
      xcol = (xcol+ 60)
    ENDFOR
    ycol = (ycol+ 12), xcol = 460,
    CALL print(calcpos(xcol,ycol)),
    "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
    FOR (x = 1 TO cs->cnt)
      stat_flag = 0
      IF (((ycol+ 24) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 24), xcol = 100
       FOR (i = 1 TO cs_code->cnt)
         CALL print(calcpos(xcol,ycol)), "{b}", cs_code->list_qual[i].subhead1,
         row + 1, ty = (ycol+ 12),
         CALL print(calcpos(xcol,ty)),
         "{b}{u}", cs_code->list_qual[i].subhead2, row + 1,
         xcol = (xcol+ 60)
       ENDFOR
       ycol = (ycol+ 12), xcol = 460,
       CALL print(calcpos(xcol,ycol)),
       "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), cs->qual_line[x].date,
      row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)),
      cs->qual_line[x].doc, row + 1, xcol = 100
      FOR (xx = 1 TO cs->qual_line[x].cell_cnt)
        xcol = (100+ (60 * (cs->qual_line[x].qual_cell[xx].res_col - 1))),
        CALL print(calcpos(xcol,ycol)), cs->qual_line[x].qual_cell[xx].res,
        row + 1
        IF ((cs->qual_line[x].qual_cell[xx].res_status > " "))
         stat_flag = 1, ycol = (ycol+ 12),
         CALL print(calcpos(xcol,ycol)),
         cs->qual_line[x].qual_cell[xx].res_status, row + 1, ycol = (ycol - 12)
        ENDIF
      ENDFOR
      IF (stat_flag=1)
       ycol = (ycol+ 24)
      ELSE
       ycol = (ycol+ 12)
      ENDIF
      FOR (xx = 1 TO cs->qual_line[x].cell_cnt)
        IF ((cs->qual_line[x].qual_cell[xx].nt_ind=1))
         FOR (xxx = 1 TO cs->qual_line[x].qual_cell[xx].nt_cnt)
           xcol = 50,
           CALL print(calcpos(xcol,ycol)), cs->qual_line[x].qual_cell[xx].qual_nt[xxx].note_ln,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((dc->cnt > 0))
    IF ((((care->cnt > 0)) OR ((((ins->cnt > 0)) OR ((((as->cnt > 0)) OR ((((rs->cnt > 0)) OR ((((vs
    ->cnt > 0)) OR ((cs->cnt > 0))) )) )) )) )) )
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    cur_head = fillstring(40," ")
    IF (((ycol+ 36) > 716))
     BREAK, ycol = head_y
    ENDIF
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{b}{u}D/C Information",
    row + 1, cur_head = concat("D/C Information"," (cont'd)"), ycol = (ycol+ 12)
    FOR (i = 1 TO dc->cnt)
      IF ((((ycol+ (dc->dc_qual[i].res_ln_cnt * 12))+ (dc->dc_qual[i].note_ln_cnt * 12)) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), dc->dc_qual[i].subhead,
      row + 1, xcol = 400,
      CALL print(calcpos(xcol,ycol)),
      dc->dc_qual[i].res_date, row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)), dc->dc_qual[i].res_doc, row + 1,
      xcol = 200
      FOR (j = 1 TO dc->dc_qual[i].res_ln_cnt)
        CALL print(calcpos(xcol,ycol)), dc->dc_qual[i].res_qual[j].res_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
      xcol = 50
      FOR (j = 1 TO dc->dc_qual[i].note_ln_cnt)
        CALL print(calcpos(xcol,ycol)), dc->dc_qual[i].note_qual[j].note_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
    ENDFOR
    ycol = (ycol+ 12)
   ENDIF
   IF ((pn->cnt > 0))
    cur_head = fillstring(40," "), xcol = 30
    IF ((((care->cnt > 0)) OR ((((ins->cnt > 0)) OR ((((as->cnt > 0)) OR ((((rs->cnt > 0)) OR ((((vs
    ->cnt > 0)) OR ((((cs->cnt > 0)) OR ((dc->cnt > 0))) )) )) )) )) )) )
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    IF (((ycol+ 72) > 716))
     BREAK, ycol = head_y
    ENDIF
    CALL print(calcpos(xcol,ycol)), "{b}{u}Provider Notification", row + 1,
    cur_head = concat("Provider Notification"," (cont'd)"), ycol = (ycol+ 24), xcol = 100
    FOR (i = 1 TO pn_code->cnt)
      CALL print(calcpos(xcol,ycol)), "{b}", pn_code->list_qual[i].subhead1,
      row + 1, ty = (ycol+ 12),
      CALL print(calcpos(xcol,ty)),
      "{b}{u}", pn_code->list_qual[i].subhead2, row + 1,
      xcol = (xcol+ 60)
    ENDFOR
    ycol = (ycol+ 12), xcol = 460,
    CALL print(calcpos(xcol,ycol)),
    "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
    FOR (x = 1 TO pn->cnt)
      stat_flag = 0
      IF (((ycol+ 24) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 24), xcol = 100
       FOR (i = 1 TO pn_code->cnt)
         CALL print(calcpos(xcol,ycol)), "{b}", pn_code->list_qual[i].subhead1,
         row + 1, ty = (ycol+ 12),
         CALL print(calcpos(xcol,ty)),
         "{b}{u}", pn_code->list_qual[i].subhead2, row + 1,
         xcol = (xcol+ 60)
       ENDFOR
       ycol = (ycol+ 12), xcol = 460,
       CALL print(calcpos(xcol,ycol)),
       "{u}{b}Performed By", row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), pn->qual_line[x].date,
      row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)),
      pn->qual_line[x].doc, row + 1, xcol = 100
      FOR (xx = 1 TO pn->qual_line[x].cell_cnt)
        xcol = (100+ (60 * (pn->qual_line[x].qual_cell[xx].res_col - 1))),
        CALL print(calcpos(xcol,ycol)), pn->qual_line[x].qual_cell[xx].res,
        row + 1
        IF ((pn->qual_line[x].qual_cell[xx].res_status > " "))
         stat_flag = 1, ycol = (ycol+ 12),
         CALL print(calcpos(xcol,ycol)),
         pn->qual_line[x].qual_cell[xx].res_status, row + 1, ycol = (ycol - 12)
        ENDIF
      ENDFOR
      IF (stat_flag=1)
       ycol = (ycol+ 24)
      ELSE
       ycol = (ycol+ 12)
      ENDIF
      FOR (xx = 1 TO pn->qual_line[x].cell_cnt)
        IF ((pn->qual_line[x].qual_cell[xx].nt_ind=1))
         FOR (xxx = 1 TO pn->qual_line[x].qual_cell[xx].nt_cnt)
           xcol = 50,
           CALL print(calcpos(xcol,ycol)), pn->qual_line[x].qual_cell[xx].qual_nt[xxx].note_ln,
           row + 1, ycol = (ycol+ 12)
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((mp->cnt > 0))
    IF ((((care->cnt > 0)) OR ((((ins->cnt > 0)) OR ((((as->cnt > 0)) OR ((((rs->cnt > 0)) OR ((((dc
    ->cnt > 0)) OR ((((vs->cnt > 0)) OR ((((cs->cnt > 0)) OR ((pn->cnt > 0))) )) )) )) )) )) )) )
     ycol = (ycol+ 12)
    ELSE
     ycol = ycol
    ENDIF
    cur_head = fillstring(40," ")
    IF (((ycol+ 36) > 716))
     BREAK, ycol = head_y
    ENDIF
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Modified Protocol",
    row + 1, cur_head = concat("Modified Protocol"," (cont'd)"), ycol = (ycol+ 12)
    FOR (i = 1 TO mp->cnt)
      IF ((((ycol+ (mp->mp_qual[i].res_ln_cnt * 12))+ (mp->mp_qual[i].note_ln_cnt * 12)) > 716))
       BREAK, x_break = 30, ycol = head_y,
       CALL print(calcpos(x_break,ycol)), "{b}{u}", cur_head,
       row + 1, ycol = (ycol+ 12)
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), mp->mp_qual[i].subhead,
      row + 1, xcol = 400,
      CALL print(calcpos(xcol,ycol)),
      mp->mp_qual[i].res_date, row + 1, xcol = 470,
      CALL print(calcpos(xcol,ycol)), mp->mp_qual[i].res_doc, row + 1,
      xcol = 200
      FOR (j = 1 TO mp->mp_qual[i].res_ln_cnt)
        CALL print(calcpos(xcol,ycol)), mp->mp_qual[i].res_qual[j].res_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
      xcol = 50
      FOR (j = 1 TO mp->mp_qual[i].note_ln_cnt)
        CALL print(calcpos(xcol,ycol)), mp->mp_qual[i].note_qual[j].note_line, row + 1,
        ycol = (ycol+ 12)
      ENDFOR
    ENDFOR
    ycol = (ycol+ 12)
   ENDIF
  FOOT PAGE
   mrn_foot = concat("MR Form # ",cnvtstring(formnum)), footer = concat("Page ",cnvtstring(curpage)),
   "{pos/30/740}",
   mrn_foot, "{pos/293/740}", footer,
   "{pos/511/740}", cur_date"@SHORTDATETIMENOSEC", row + 1
  WITH nocounter, dio = postscript, maxcol = 792,
   maxrow = 6000
 ;end select
#get_note_begin
 SET blob_out = fillstring(32000," ")
 SELECT INTO "nl:"
  cen.seq, lb.long_blob
  FROM ce_event_note cen,
   long_blob lb
  PLAN (cen
   WHERE cen.event_id=event_id)
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id
    AND lb.parent_entity_name="CE_EVENT_NOTE")
  DETAIL
   IF (cen.compression_cd=ocfcomp_cd)
    blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000,
     " "),
    blob_ret_len = 0, t_len = textlen(lb.long_blob),
    CALL uar_ocf_uncompress(lb.long_blob,t_len,blob_out,32000,blob_ret_len)
   ELSE
    blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),
     lb.long_blob)
   ENDIF
   t_len1 = textlen(blob_out),
   CALL uar_rtf(blob_out,t_len1,blob_out2,32000,32000,0), blob_out = blob_out2
  WITH nocounter
 ;end select
#get_note_end
#exit_script
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "002 10/01/13 ST020427"
END GO
