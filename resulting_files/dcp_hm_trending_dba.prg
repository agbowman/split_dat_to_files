CREATE PROGRAM dcp_hm_trending:dba
 SET ns_cd = 227499
 SET d5w_cd = 227356
 SET norm_cd = 227680
 SET iv_cd = 111690
 SET lr_cd = 227679
 SET kcl_cd = 227681
 SET d10w_cd = 227683
 SET d5ns_cd = 227685
 SET d52ns_cd = 227684
 SET bolus_cd = 227691
 SET flush_cd = 227690
 SET md5_cd = 227689
 SET ns20_cd = 227688
 SET lrd5_cd = 227687
 SET d5wns_cd = 227686
 SET 45ns_cd = 227682
 SET las_cd = 227692
 SET nit_cd = 227693
 SET dop_cd = 227694
 SET dob_cd = 227695
 SET lid_cd = 227696
 SET theo_cd = 227697
 SET ins_cd = 227698
 SET med_cd = 227699
 SET oral_cd = 227506
 SET tube_cd = 227700
 SET packed_cd = 227701
 SET plasma_cd = 227703
 SET plate_cd = 227704
 SET blood_cd = 227702
 SET misc_cd = 227667
 SET gasflush_cd = 227668
 SET tpn_cd = 227705
 SET lipid_cd = 227706
 SET urinef_cd = 227647
 SET urinev_cd = 227648
 SET drainage_cd = 227674
 SET emesis_cd = 227197
 SET gasresid_cd = 227675
 SET liqstool_cd = 227470
 SET ostomy_cd = 227673
 SET out_cd = 227676
 SET loss_cd = 227677
 SET wdrain_cd = 227660
 SET cdrain_cd = 227670
 SET temp_cd = 22609
 SET resp_cd = 22585
 SET pulse_cd = 22418
 SET sbp_cd = 22608
 SET dbp_cd = 22369
 SET bm_cd = 227258
 SET weight_cd = 22635
 SET abc = 0
 SET xyz = 0
 RECORD temp(
   1 day[5]
     2 iv = i4
     2 oral = i4
     2 blood = i4
     2 miscin = i4
     2 parent = i4
     2 tubefeed = i4
     2 intotal = i4
     2 urine = i4
     2 gastsuc = i4
     2 drain = i4
     2 miscout = i4
     2 liqstool = i4
     2 outtotal = i4
     2 bmnum = i4
     2 dayofstay = i4
     2 zcol = i4
     2 weight = vc
     2 shift[6]
       3 sbp = i4
       3 dbp = i4
       3 pulse = i4
       3 resp = i4
       3 temp = f8
       3 xcol = i4
       3 xcol3 = i4
       3 xcol6 = i4
       3 ycol = i4
       3 ycol3 = i4
       3 ycol6 = i4
 )
 FOR (x = 1 TO 5)
   SET temp->day[x].iv = 0
   SET temp->day[x].dayofstay = 0
   SET temp->day[x].oral = 0
   SET temp->day[x].tubefeed = 0
   SET temp->day[x].intotal = 0
   SET temp->day[x].parent = 0
   SET temp->day[x].blood = 0
   SET temp->day[x].miscin = 0
   SET temp->day[x].urine = 0
   SET temp->day[x].gastsuc = 0
   SET temp->day[x].drain = 0
   SET temp->day[x].liqstool = 0
   SET temp->day[x].miscout = 0
   SET temp->day[x].outtotal = 0
   SET temp->day[x].bmnum = 0
   SET temp->day[x].weight = "0.0"
   SET temp->day[x].zcol = 0
   FOR (y = 1 TO 6)
     SET temp->day[x].shift[y].sbp = 0
     SET temp->day[x].shift[y].dbp = 0
     SET temp->day[x].shift[y].pulse = 0
     SET temp->day[x].shift[y].resp = 0
     SET temp->day[x].shift[y].temp = 0.0
     SET temp->day[x].shift[y].xcol = 0.0
     SET temp->day[x].shift[y].xcol3 = 0.0
     SET temp->day[x].shift[y].xcol6 = 0.0
     SET temp->day[x].shift[y].ycol = 0.0
     SET temp->day[x].shift[y].ycol3 = 0.0
     SET temp->day[x].shift[y].ycol6 = 0.0
   ENDFOR
 ENDFOR
 SET a = 0
 SET b = 0
 SET xdays = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET name = fillstring(50," ")
 SET age = fillstring(50," ")
 SET dob = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET finnbr = fillstring(50," ")
 SET admitdoc = fillstring(50," ")
 SET unit = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET xxx = fillstring(60," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SELECT INTO "nl:"
  e.encntr_id, e.reg_dt_tm, p.name_full_formatted,
  p.birth_dt_tm, pa.alias, pl.name_full_formatted,
  e.loc_nurse_unit_cd, e.loc_room_cd, e.loc_bed_cd,
  epr.seq
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_prsnl_reltn epr,
   prsnl pl,
   encntr_alias ea,
   (dummyt d1  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
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
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=admit_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (d3)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), age = cnvtage(cnvtdate(p.birth_dt_tm),curdate), dob
    = format(p.birth_dt_tm,"mm/dd/yy;;d"),
   mrn = substring(1,20,pa.alias), finnbr = substring(1,20,ea.alias), admitdoc = substring(1,30,pl
    .name_full_formatted),
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,10,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,uar_get_code_display(e.loc_bed_cd))
  DETAIL
   a = datetimediff(cnvtdatetime((curdate+ 1),0),cnvtdatetime(e.reg_dt_tm)), reg_dt_tm = cnvtdatetime
   (e.reg_dt_tm)
  WITH nocounter, outerjoin = d1, dontcare = pa,
   dontcare = epr, outerjoin = d2, outerjoin = d3,
   dontcare = ea
 ;end select
 SET a = (a+ 1)
 SET b = (a * 1440)
 SET xdays = (b/ 1440)
 SET temp->day[5].dayofstay = xdays
 SET temp->day[4].dayofstay = (xdays - 1)
 SET temp->day[3].dayofstay = (xdays - 2)
 SET temp->day[2].dayofstay = (xdays - 3)
 SET temp->day[1].dayofstay = (xdays - 4)
 IF (xdays > 4)
  SET zcol = 5
 ELSE
  SET zcol = xdays
 ENDIF
 SET temp->day[5].zcol = zcol
 SET temp->day[4].zcol = (zcol - 1)
 SET temp->day[3].zcol = (zcol - 2)
 SET temp->day[2].zcol = (zcol - 3)
 SET temp->day[1].zcol = (zcol - 4)
 SELECT INTO "nl:"
  c.event_cd, c.event_end_dt_tm, c.person_id,
  c.encntr_id, c.valid_until_dt_tm, c.view_level,
  c.publish_flag
  FROM clinical_event c
  PLAN (c
   WHERE (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd IN (ns_cd, d5w_cd, norm_cd, iv_cd, lr_cd,
   kcl_cd, d10w_cd, d5ns_cd, d52ns_cd, bolus_cd,
   flush_cd, md5_cd, ns20_cd, lrd5_cd, d5wns_cd,
   45ns_cd, las_cd, nit_cd, dop_cd, dob_cd,
   lid_cd, theo_cd, ins_cd, med_cd, oral_cd,
   tube_cd, packed_cd, plasma_cd, plate_cd, blood_cd,
   misc_cd, gasflush_cd, tpn_cd, bm_cd, lipid_cd,
   urinef_cd, urinev_cd, drainage_cd, emesis_cd, gasresid_cd,
   weight_cd, liqstool_cd, ostomy_cd, out_cd, loss_cd,
   wdrain_cd, cdrain_cd, temp_cd, resp_cd, pulse_cd,
   sbp_cd, dbp_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.result_status_cd != inerror_cd
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm > cnvtdatetime((curdate - 4),0))
  ORDER BY c.event_cd, c.event_end_dt_tm
  DETAIL
   IF (c.event_end_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime(curdate,2359))
    x = 5
   ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
    2359))
    x = 4
   ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 2),0) AND cnvtdatetime((curdate - 2),
    2359))
    x = 3
   ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 3),0) AND cnvtdatetime((curdate - 3),
    2359))
    x = 2
   ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 4),0) AND cnvtdatetime((curdate - 4),
    2359))
    x = 1
   ENDIF
   IF (c.event_cd IN (temp_cd, resp_cd, pulse_cd, sbp_cd, dbp_cd))
    IF (c.event_end_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime(curdate,0359))
     y = 1
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime(curdate,0400) AND cnvtdatetime(curdate,0759))
     y = 2
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime(curdate,0800) AND cnvtdatetime(curdate,1159))
     y = 3
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime(curdate,1200) AND cnvtdatetime(curdate,1559))
     y = 4
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime(curdate,1600) AND cnvtdatetime(curdate,1959))
     y = 5
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime(curdate,2000) AND cnvtdatetime(curdate,2359))
     y = 6
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
     0359))
     y = 1
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),0400) AND cnvtdatetime((curdate - 1),
     0759))
     y = 2
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),0800) AND cnvtdatetime((curdate - 1),
     1159))
     y = 3
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),1200) AND cnvtdatetime((curdate - 1),
     1559))
     y = 4
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),1600) AND cnvtdatetime((curdate - 1),
     1959))
     y = 5
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),2000) AND cnvtdatetime((curdate - 1),
     2359))
     y = 6
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 2),0) AND cnvtdatetime((curdate - 2),
     0359))
     y = 1
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 2),0400) AND cnvtdatetime((curdate - 2),
     0759))
     y = 2
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 2),0800) AND cnvtdatetime((curdate - 2),
     1159))
     y = 3
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 2),1200) AND cnvtdatetime((curdate - 2),
     1559))
     y = 4
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 2),1600) AND cnvtdatetime((curdate - 2),
     1959))
     y = 5
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 2),2000) AND cnvtdatetime((curdate - 2),
     2359))
     y = 6
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 3),0) AND cnvtdatetime((curdate - 3),
     0359))
     y = 1
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 3),0400) AND cnvtdatetime((curdate - 3),
     0759))
     y = 2
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 3),0800) AND cnvtdatetime((curdate - 3),
     1159))
     y = 3
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 3),1200) AND cnvtdatetime((curdate - 3),
     1559))
     y = 4
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 3),1600) AND cnvtdatetime((curdate - 3),
     1959))
     y = 5
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 3),2000) AND cnvtdatetime((curdate - 3),
     2359))
     y = 6
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 4),0) AND cnvtdatetime((curdate - 4),
     0359))
     y = 1
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 4),0400) AND cnvtdatetime((curdate - 4),
     0759))
     y = 2
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 4),0800) AND cnvtdatetime((curdate - 4),
     1159))
     y = 3
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 4),1200) AND cnvtdatetime((curdate - 4),
     1559))
     y = 4
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 4),1600) AND cnvtdatetime((curdate - 4),
     1959))
     y = 5
    ELSEIF (c.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 4),2000) AND cnvtdatetime((curdate - 4),
     2359))
     y = 6
    ENDIF
   ENDIF
   IF (c.event_cd=temp_cd
    AND (cnvtreal(c.event_tag) > temp->day[x].shift[y].temp))
    temp->day[x].shift[y].temp = cnvtreal(c.event_tag)
   ELSEIF (c.event_cd=sbp_cd)
    temp->day[x].shift[y].sbp = cnvtreal(c.event_tag)
   ELSEIF (c.event_cd=dbp_cd)
    temp->day[x].shift[y].dbp = cnvtreal(c.event_tag)
   ELSEIF (c.event_cd=resp_cd
    AND (cnvtreal(c.event_tag) > temp->day[x].shift[y].resp))
    temp->day[x].shift[y].resp = cnvtreal(c.event_tag)
   ELSEIF (c.event_cd=pulse_cd
    AND (cnvtreal(c.event_tag) > temp->day[x].shift[y].pulse))
    temp->day[x].shift[y].pulse = cnvtreal(c.event_tag)
   ELSEIF (c.event_cd=weight_cd)
    temp->day[x].weight = trim(c.event_tag)
   ELSEIF (c.event_cd=bm_cd)
    temp->day[x].bmnum = (temp->day[x].bmnum+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (ns_cd, d5w_cd, norm_cd, iv_cd, lr_cd,
   kcl_cd, d10w_cd, d5ns_cd, d52ns_cd, bolus_cd,
   flush_cd, md5_cd, ns20_cd, lrd5_cd, d5wns_cd,
   45ns_cd, las_cd, nit_cd, dop_cd, dob_cd,
   lid_cd, theo_cd, ins_cd, med_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].iv = (temp->day[x].iv+ cnvtreal(c.event_tag)), temp->day[x].intotal = (temp->day[x].
    intotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd=oral_cd
    AND c.result_status_cd != inerror_cd)
    temp->day[x].oral = (temp->day[x].oral+ cnvtreal(c.event_tag)), temp->day[x].intotal = (temp->
    day[x].intotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (urinef_cd, urinev_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].urine = (temp->day[x].urine+ cnvtreal(c.event_tag)), temp->day[x].outtotal = (temp->
    day[x].outtotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd=tube_cd
    AND c.result_status_cd != inerror_cd)
    temp->day[x].tubefeed = (temp->day[x].tubefeed+ cnvtreal(c.event_tag)), temp->day[x].intotal = (
    temp->day[x].intotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (misc_cd, gasflush_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].miscin = (temp->day[x].miscin+ cnvtreal(c.event_tag)), temp->day[x].intotal = (temp
    ->day[x].intotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (blood_cd, packed_cd, plasma_cd, plate_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].blood = (temp->day[x].blood+ cnvtreal(c.event_tag)), temp->day[x].intotal = (temp->
    day[x].intotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (tpn_cd, lipid_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].parent = (temp->day[x].parent+ cnvtreal(c.event_tag)), temp->day[x].intotal = (temp
    ->day[x].intotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (out_cd, loss_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].miscout = (temp->day[x].miscout+ cnvtreal(c.event_tag)), temp->day[x].outtotal = (
    temp->day[x].outtotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (drainage_cd, emesis_cd, gasresid_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].gastsuc = (temp->day[x].gastsuc+ cnvtreal(c.event_tag)), temp->day[x].outtotal = (
    temp->day[x].outtotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (wdrain_cd, cdrain_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].drain = (temp->day[x].drain+ cnvtreal(c.event_tag)), temp->day[x].outtotal = (temp->
    day[x].outtotal+ cnvtreal(c.event_tag))
   ELSEIF (c.event_cd IN (liqstool_cd, ostomy_cd)
    AND c.result_status_cd != inerror_cd)
    temp->day[x].liqstool = (temp->day[x].liqstool+ cnvtreal(c.event_tag)), temp->day[x].outtotal = (
    temp->day[x].outtotal+ cnvtreal(c.event_tag))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   l1 = fillstring(85,"_"), l2 = fillstring(41,"_"), l3 = fillstring(131,"_"),
   l4 = fillstring(119,"_"), l5 = fillstring(8,"_"), abc = 0,
   xyz = 0, j = 0, q = 0
  DETAIL
   "{F/4}{cpi/12}", row + 1, "{pos/18/35}{box/95/41}",
   row + 1, "{pos/18/35}{box/10/41}", row + 1,
   "{pos/190/33}{fr/1}", l5, row + 1,
   "{pos/292/33}{fr/1}", l5, row + 1,
   "{pos/394/33}{fr/1}", l5, row + 1,
   "{pos/496/33}{fr/1}", l5, row + 1,
   "{pos/18/35}{fr/0}{box/95/1}", row + 1, "{pos/18/416}{box/95/1}",
   row + 1, "{pos/18/416}{box/95/2}", row + 1,
   "{pos/18/416}{box/95/3}", row + 1, "{pos/18/416}{box/95/4}",
   row + 1, "{pos/23/50}DATE", row + 1,
   "{pos/60/65}TEMP", row + 1, "{pos/70/80}C",
   row + 1, "{pos/23/65}BP", row + 1,
   "{pos/60/105}42  --", row + 1, "{pos/87/101}{b}{cpi/14}",
   l4, row + 1, "{pos/60/150}{cpi/12}41  --",
   row + 1, "{pos/87/147}{b}{cpi/14}", l4,
   row + 1, "{pos/60/195}{cpi/12}40  --", row + 1,
   "{pos/87/191}{b}{cpi/14}", l4, row + 1,
   "{pos/60/240}{cpi/12}39  --", row + 1, "{pos/87/237}{b}{cpi/14}",
   l4, row + 1, "{pos/60/285}{cpi/12}38  --",
   row + 1, "{pos/87/281}{b}{cpi/14}", l4,
   row + 1, "{pos/60/330}{cpi/12}37  --", row + 1,
   "{pos/87/327}{b}{cpi/14}", l4, row + 1,
   "{pos/60/375}{cpi/12}36  --", row + 1, "{pos/87/373}{b}{cpi/14}",
   l4, row + 1, "{pos/23/92}{cpi/12}200",
   row + 1, "{pos/23/132}180", row + 1,
   "{pos/23/172}160", row + 1, "{pos/23/212}140",
   row + 1, "{pos/23/252}120", row + 1,
   "{pos/23/292}100", row + 1, "{pos/23/332}80",
   row + 1, "{pos/23/372}60", row + 1,
   "{pos/23/392}Temp", row + 1, "{pos/44/391}{f/17}{cpi/4}.",
   row + 1, "{pos/55/389}{f/4}{cpi/12}____", row + 1,
   "{pos/23/404}BP", row + 1, "{pos/38/407}{f/17}{cpi/8}*",
   row + 1, "{pos/44/404}{f/4}{cpi/12}- - - - -", row + 1,
   "{cpi/16}", row + 1, "{pos/66/76}o",
   row + 1, "{pos/70/101}o", row + 1,
   "{pos/70/146}o", row + 1, "{pos/70/191}o",
   row + 1, "{pos/70/236}o", row + 1,
   "{pos/70/281}o", row + 1, "{pos/70/326}o",
   row + 1, "{pos/70/371}o", row + 1,
   "{cpi/12}", row + 1, "{pos/23/422}BLOOD",
   row + 1, "{pos/23/432}PRESSURE", row + 1,
   "{pos/23/443}PULSE", row + 1, "{pos/23/453}RESP.",
   row + 1, "{pos/23/463}WEIGHT", row + 1,
   "{cpi/14}", row + 1, "{pos/89/70}HOSP DAY",
   row + 1, "{pos/191/70}HOSP DAY", row + 1,
   "{pos/293/70}HOSP DAY", row + 1, "{pos/395/70}HOSP DAY",
   row + 1, "{pos/497/70}HOSP DAY", row + 1,
   "{pos/105/89}{FR/1}", l1, row + 1,
   "{pos/122/89}", l1, row + 1,
   "{pos/139/89}", l1, row + 1,
   "{pos/156/89}", l1, row + 1,
   "{pos/173/89}", l1, row + 1,
   "{pos/190/89}", l1, row + 1,
   "{FR/0}{pos/100/83}04", row + 1, "{pos/117/83}08",
   row + 1, "{pos/134/83}12", row + 1,
   "{pos/151/83}16", row + 1, "{pos/168/83}20",
   row + 1, "{pos/185/83}24", row + 1,
   "{pos/207/89}{FR/1}", l1, row + 1,
   "{pos/224/89}", l1, row + 1,
   "{pos/241/89}", l1, row + 1,
   "{pos/258/89}", l1, row + 1,
   "{pos/275/89}", l1, row + 1,
   "{pos/292/89}", l1, row + 1,
   "{FR/0}{pos/202/83}04", row + 1, "{pos/219/83}08",
   row + 1, "{pos/236/83}12", row + 1,
   "{pos/253/83}16", row + 1, "{pos/270/83}20",
   row + 1, "{pos/287/83}24", row + 1,
   "{pos/309/89}{FR/1}", l1, row + 1,
   "{pos/326/89}", l1, row + 1,
   "{pos/343/89}", l1, row + 1,
   "{pos/360/89}", l1, row + 1,
   "{pos/377/89}", l1, row + 1,
   "{pos/394/89}", l1, row + 1,
   "{FR/0}{pos/304/83}04", row + 1, "{pos/321/83}08",
   row + 1, "{pos/338/83}12", row + 1,
   "{pos/355/83}16", row + 1, "{pos/372/83}20",
   row + 1, "{pos/389/83}24", row + 1,
   "{pos/411/89}{fr/1}", l1, row + 1,
   "{pos/428/89}", l1, row + 1,
   "{pos/445/89}", l1, row + 1,
   "{pos/462/89}", l1, row + 1,
   "{pos/479/89}", l1, row + 1,
   "{pos/496/89}", l1, row + 1,
   "{FR/0}{pos/406/83}04", row + 1, "{pos/423/83}08",
   row + 1, "{pos/440/83}12", row + 1,
   "{pos/457/83}16", row + 1, "{pos/474/83}20",
   row + 1, "{pos/491/83}24", row + 1,
   "{pos/513/89}{FR/1}", l1, row + 1,
   "{pos/530/89}", l1, row + 1,
   "{pos/547/89}", l1, row + 1,
   "{pos/564/89}", l1, row + 1,
   "{pos/581/89}", l1, row + 1,
   "{FR/0}{pos/508/83}04", row + 1, "{pos/525/83}08",
   row + 1, "{pos/542/83}12", row + 1,
   "{pos/559/83}16", row + 1, "{pos/576/83}20",
   row + 1, "{pos/173/463}KG", row + 1,
   "{pos/275/463}KG", row + 1, "{pos/377/463}KG",
   row + 1, "{pos/479/463}KG", row + 1,
   "{pos/581/463}KG", row + 1, "{f/13}{pos/252/477}24 HOUR I & O TOTALS",
   row + 1, "{cpi/12}", row + 1,
   "{f/4}{pos/18/482}{box/95/19}", row + 1, "{pos/88/480}{FR/1}",
   l2, row + 1, "{pos/190/480}{b}",
   l2, row + 1, "{pos/292/480}{b}",
   l2, row + 1, "{pos/394/480}{b}",
   l2, row + 1, "{pos/496/480}{b}",
   l2, row + 1, "{pos/35/480}",
   l2, row + 1, "{cpi/14}",
   row + 1, "{pos/35/493}{FR/0}", l3,
   row + 1, "{pos/35/507}", l3,
   row + 1, "{pos/35/521}", l3,
   row + 1, "{pos/35/535}", l3,
   row + 1, "{pos/35/549}", l3,
   row + 1, "{pos/35/563}", l3,
   row + 1, "{pos/35/576}", l3,
   row + 1, "{pos/35/590}", l3,
   row + 1, "{pos/35/604}", l3,
   row + 1, "{pos/35/617}", l3,
   row + 1, "{pos/35/630}", l3,
   row + 1, "{pos/35/644}", l3,
   row + 1, "{pos/35/658}", l3,
   row + 1, "{pos/35/671}", l3,
   row + 1, "{pos/21/576}_______", row + 1,
   "{cpi/14}", row + 1, "{pos/26/490}I",
   row + 1, "{pos/25/501}N", row + 1,
   "{pos/25/512}T", row + 1, "{pos/25/523}A",
   row + 1, "{pos/25/534}K", row + 1,
   "{pos/25/545}E", row + 1, "{pos/25/593}O",
   row + 1, "{pos/25/604}U", row + 1,
   "{pos/25/615}T", row + 1, "{pos/26/626}P",
   row + 1, "{pos/25/637}U", row + 1,
   "{pos/25/648}T", row + 1, "{cpi/16}",
   row + 1, "{pos/36/489}{fr/0}IV", row + 1,
   "{pos/36/503}ORAL", row + 1, "{pos/36/514}TUBE",
   row + 1, "{pos/36/521}FEEDING", row + 1,
   "{pos/36/528}BLOOD", row + 1, "{pos/36/535}PRODUCTS",
   row + 1, "{pos/36/542}MISC.", row + 1,
   "{pos/36/548}INTAKE", row + 1, "{pos/36/556}PARENTERAL",
   row + 1, "{pos/36/563}NUTRITION", row + 1,
   "{pos/36/574}{B}TOTAL", row + 1, "{pos/36/588}URINE",
   row + 1, "{pos/36/601}DRAINS", row + 1,
   "{pos/36/611}GASTRIC", row + 1, "{pos/36/617}OUTPUT",
   row + 1, "{pos/36/624}STOOL", row + 1,
   "{pos/36/630}OUTPUT", row + 1, "{pos/36/637}MISC.",
   row + 1, "{pos/36/644}OUTPUT", row + 1,
   "{pos/36/655}{b}TOTAL", row + 1, "{pos/36/668}# OF BM's",
   row + 1, "{pos/36/681}{b}BALANCE", row + 1,
   "{pos/292/620}{fr/1}", l2, row + 1,
   "{cpi/11}{f/12}{FR/0}", row + 1, "{pos/132/703}HEALTH MIDWEST",
   row + 1, "{pos/130/692}_________________", row + 1,
   "{pos/130/704}_________________", row + 1, "{cpi/10}{f/13}",
   row + 1, "{pos/40/730}24 HOUR PATIENT TRENDING RECORD", row + 1,
   "{cpi/16}{f/4}", row + 1, "{cpi/15}{pos/405/760}{B}Patient Identification",
   row + 1, "{pos/296/700}Patient Name:   {cpi/13}{f/8}", name,
   row + 1, "{cpi/15}{f/4}{pos/480/700}Med Rec Num:    ", mrn,
   row + 1, "{pos/480/716}Date of Birth:   ", dob,
   row + 1, "{pos/296/748}Admitting Physician:   ", admitdoc,
   row + 1, xxx = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)), "{pos/296/732}Location:   ",
   xxx, row + 1, "{pos/480/732}Financial Num: ",
   finnbr, row + 1, "{pos/296/716}Age:   ",
   age, row + 1, "{cpi/14}{f/4}",
   row + 1, xcol = 87, ycol = 88
   FOR (x = 1 TO 81)
     CALL print(calcpos(xcol,ycol)), l4, row + 1,
     ycol = (ycol+ 4)
   ENDFOR
   "{pos/87/73}", l4, row + 1,
   xcol = (599 - ((5 - temp->day[5].zcol) * 102)), ycol = 0, x = 6,
   y = 7
   FOR (q = 1 TO 5)
     x = (x - 1), y = 7
     FOR (n = 1 TO 6)
       y = (y - 1), ycol = 0
       IF ((temp->day[x].shift[y].temp >= 42.4))
        ycol = 88
       ELSEIF ((temp->day[x].shift[y].temp >= 42.3))
        ycol = 92
       ELSEIF ((temp->day[x].shift[y].temp >= 42.2))
        ycol = 96
       ELSEIF ((temp->day[x].shift[y].temp >= 42.1))
        ycol = 100
       ELSEIF ((temp->day[x].shift[y].temp >= 42.0))
        ycol = 104
       ELSEIF ((temp->day[x].shift[y].temp >= 41.9))
        ycol = 108
       ELSEIF ((temp->day[x].shift[y].temp >= 41.8))
        ycol = 113
       ELSEIF ((temp->day[x].shift[y].temp >= 41.7))
        ycol = 117
       ELSEIF ((temp->day[x].shift[y].temp >= 41.6))
        ycol = 122
       ELSEIF ((temp->day[x].shift[y].temp >= 41.5))
        ycol = 126
       ELSEIF ((temp->day[x].shift[y].temp >= 41.4))
        ycol = 130
       ELSEIF ((temp->day[x].shift[y].temp >= 41.3))
        ycol = 134
       ELSEIF ((temp->day[x].shift[y].temp >= 41.2))
        ycol = 139
       ELSEIF ((temp->day[x].shift[y].temp >= 41.1))
        ycol = 143
       ELSEIF ((temp->day[x].shift[y].temp >= 41.0))
        ycol = 148
       ELSEIF ((temp->day[x].shift[y].temp >= 40.9))
        ycol = 152
       ELSEIF ((temp->day[x].shift[y].temp >= 40.8))
        ycol = 156
       ELSEIF ((temp->day[x].shift[y].temp >= 40.7))
        ycol = 160
       ELSEIF ((temp->day[x].shift[y].temp >= 40.6))
        ycol = 165
       ELSEIF ((temp->day[x].shift[y].temp >= 40.5))
        ycol = 170
       ELSEIF ((temp->day[x].shift[y].temp >= 40.4))
        ycol = 175
       ELSEIF ((temp->day[x].shift[y].temp >= 40.3))
        ycol = 179
       ELSEIF ((temp->day[x].shift[y].temp >= 40.2))
        ycol = 184
       ELSEIF ((temp->day[x].shift[y].temp >= 40.1))
        ycol = 189
       ELSEIF ((temp->day[x].shift[y].temp >= 40.0))
        ycol = 194
       ELSEIF ((temp->day[x].shift[y].temp >= 39.9))
        ycol = 199
       ELSEIF ((temp->day[x].shift[y].temp >= 39.8))
        ycol = 204
       ELSEIF ((temp->day[x].shift[y].temp >= 39.7))
        ycol = 209
       ELSEIF ((temp->day[x].shift[y].temp >= 39.6))
        ycol = 214
       ELSEIF ((temp->day[x].shift[y].temp >= 39.5))
        ycol = 218
       ELSEIF ((temp->day[x].shift[y].temp >= 39.4))
        ycol = 222
       ELSEIF ((temp->day[x].shift[y].temp >= 39.3))
        ycol = 226
       ELSEIF ((temp->day[x].shift[y].temp >= 39.2))
        ycol = 230
       ELSEIF ((temp->day[x].shift[y].temp >= 39.1))
        ycol = 234
       ELSEIF ((temp->day[x].shift[y].temp >= 39.0))
        ycol = 239
       ELSEIF ((temp->day[x].shift[y].temp >= 38.9))
        ycol = 244
       ELSEIF ((temp->day[x].shift[y].temp >= 38.8))
        ycol = 248
       ELSEIF ((temp->day[x].shift[y].temp >= 38.7))
        ycol = 253
       ELSEIF ((temp->day[x].shift[y].temp >= 38.6))
        ycol = 257
       ELSEIF ((temp->day[x].shift[y].temp >= 38.5))
        ycol = 262
       ELSEIF ((temp->day[x].shift[y].temp >= 38.4))
        ycol = 266
       ELSEIF ((temp->day[x].shift[y].temp >= 38.3))
        ycol = 271
       ELSEIF ((temp->day[x].shift[y].temp >= 38.2))
        ycol = 276
       ELSEIF ((temp->day[x].shift[y].temp >= 38.1))
        ycol = 280
       ELSEIF ((temp->day[x].shift[y].temp >= 38.0))
        ycol = 284
       ELSEIF ((temp->day[x].shift[y].temp >= 37.9))
        ycol = 288
       ELSEIF ((temp->day[x].shift[y].temp >= 37.8))
        ycol = 293
       ELSEIF ((temp->day[x].shift[y].temp >= 37.7))
        ycol = 297
       ELSEIF ((temp->day[x].shift[y].temp >= 37.6))
        ycol = 302
       ELSEIF ((temp->day[x].shift[y].temp >= 37.5))
        ycol = 306
       ELSEIF ((temp->day[x].shift[y].temp >= 37.4))
        ycol = 311
       ELSEIF ((temp->day[x].shift[y].temp >= 37.3))
        ycol = 315
       ELSEIF ((temp->day[x].shift[y].temp >= 37.2))
        ycol = 320
       ELSEIF ((temp->day[x].shift[y].temp >= 37.1))
        ycol = 324
       ELSEIF ((temp->day[x].shift[y].temp >= 37.0))
        ycol = 328
       ELSEIF ((temp->day[x].shift[y].temp >= 36.9))
        ycol = 333
       ELSEIF ((temp->day[x].shift[y].temp >= 36.8))
        ycol = 337
       ELSEIF ((temp->day[x].shift[y].temp >= 36.7))
        ycol = 342
       ELSEIF ((temp->day[x].shift[y].temp >= 36.6))
        ycol = 346
       ELSEIF ((temp->day[x].shift[y].temp >= 36.5))
        ycol = 351
       ELSEIF ((temp->day[x].shift[y].temp >= 36.4))
        ycol = 356
       ELSEIF ((temp->day[x].shift[y].temp >= 36.3))
        ycol = 360
       ELSEIF ((temp->day[x].shift[y].temp >= 36.2))
        ycol = 365
       ELSEIF ((temp->day[x].shift[y].temp >= 36.1))
        ycol = 370
       ELSEIF ((temp->day[x].shift[y].temp >= 36.0))
        ycol = 375
       ELSEIF ((temp->day[x].shift[y].temp >= 35.9))
        ycol = 380
       ELSEIF ((temp->day[x].shift[y].temp >= 35.8))
        ycol = 385
       ELSEIF ((temp->day[x].shift[y].temp >= 35.7))
        ycol = 390
       ELSEIF ((temp->day[x].shift[y].temp >= 35.6))
        ycol = 395
       ELSEIF ((temp->day[x].shift[y].temp >= 35.5))
        ycol = 400
       ELSEIF ((temp->day[x].shift[y].temp >= 35.4))
        ycol = 405
       ELSEIF ((temp->day[x].shift[y].temp >= 35.3))
        ycol = 410
       ENDIF
       xcol = (xcol - 17)
       IF (ycol > 0)
        IF (xcol > 88)
         CALL print(calcpos(xcol,ycol)), "{f/17}{cpi/4}.", row + 1,
         temp->day[x].shift[y].xcol = xcol, temp->day[x].shift[y].ycol = ycol
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   xcol3 = (599 - ((5 - temp->day[5].zcol) * 102)), ycol3 = 0, x = 6,
   y = 7
   FOR (q = 1 TO 5)
     x = (x - 1), y = 7
     FOR (n = 1 TO 6)
       y = (y - 1), ycol3 = 0
       IF ((temp->day[x].shift[y].sbp >= 200))
        ycol3 = 88
       ELSEIF ((temp->day[x].shift[y].sbp >= 198))
        ycol3 = 92
       ELSEIF ((temp->day[x].shift[y].sbp >= 196))
        ycol3 = 96
       ELSEIF ((temp->day[x].shift[y].sbp >= 194))
        ycol3 = 100
       ELSEIF ((temp->day[x].shift[y].sbp >= 192))
        ycol3 = 104
       ELSEIF ((temp->day[x].shift[y].sbp >= 190))
        ycol3 = 108
       ELSEIF ((temp->day[x].shift[y].sbp >= 188))
        ycol3 = 112
       ELSEIF ((temp->day[x].shift[y].sbp >= 186))
        ycol3 = 116
       ELSEIF ((temp->day[x].shift[y].sbp >= 184))
        ycol3 = 120
       ELSEIF ((temp->day[x].shift[y].sbp >= 182))
        ycol3 = 124
       ELSEIF ((temp->day[x].shift[y].sbp >= 180))
        ycol3 = 128
       ELSEIF ((temp->day[x].shift[y].sbp >= 178))
        ycol3 = 132
       ELSEIF ((temp->day[x].shift[y].sbp >= 176))
        ycol3 = 136
       ELSEIF ((temp->day[x].shift[y].sbp >= 174))
        ycol3 = 140
       ELSEIF ((temp->day[x].shift[y].sbp >= 172))
        ycol3 = 144
       ELSEIF ((temp->day[x].shift[y].sbp >= 170))
        ycol3 = 148
       ELSEIF ((temp->day[x].shift[y].sbp >= 168))
        ycol3 = 152
       ELSEIF ((temp->day[x].shift[y].sbp >= 166))
        ycol3 = 156
       ELSEIF ((temp->day[x].shift[y].sbp >= 164))
        ycol3 = 160
       ELSEIF ((temp->day[x].shift[y].sbp >= 162))
        ycol3 = 164
       ELSEIF ((temp->day[x].shift[y].sbp >= 160))
        ycol3 = 168
       ELSEIF ((temp->day[x].shift[y].sbp >= 158))
        ycol3 = 172
       ELSEIF ((temp->day[x].shift[y].sbp >= 156))
        ycol3 = 176
       ELSEIF ((temp->day[x].shift[y].sbp >= 154))
        ycol3 = 180
       ELSEIF ((temp->day[x].shift[y].sbp >= 152))
        ycol3 = 184
       ELSEIF ((temp->day[x].shift[y].sbp >= 150))
        ycol3 = 188
       ELSEIF ((temp->day[x].shift[y].sbp >= 148))
        ycol3 = 192
       ELSEIF ((temp->day[x].shift[y].sbp >= 146))
        ycol3 = 196
       ELSEIF ((temp->day[x].shift[y].sbp >= 144))
        ycol3 = 200
       ELSEIF ((temp->day[x].shift[y].sbp >= 142))
        ycol3 = 204
       ELSEIF ((temp->day[x].shift[y].sbp >= 140))
        ycol3 = 208
       ELSEIF ((temp->day[x].shift[y].sbp >= 138))
        ycol3 = 212
       ELSEIF ((temp->day[x].shift[y].sbp >= 136))
        ycol3 = 216
       ELSEIF ((temp->day[x].shift[y].sbp >= 134))
        ycol3 = 220
       ELSEIF ((temp->day[x].shift[y].sbp >= 132))
        ycol3 = 224
       ELSEIF ((temp->day[x].shift[y].sbp >= 130))
        ycol3 = 228
       ELSEIF ((temp->day[x].shift[y].sbp >= 128))
        ycol3 = 232
       ELSEIF ((temp->day[x].shift[y].sbp >= 126))
        ycol3 = 236
       ELSEIF ((temp->day[x].shift[y].sbp >= 124))
        ycol3 = 240
       ELSEIF ((temp->day[x].shift[y].sbp >= 122))
        ycol3 = 244
       ELSEIF ((temp->day[x].shift[y].sbp >= 120))
        ycol3 = 248
       ELSEIF ((temp->day[x].shift[y].sbp >= 118))
        ycol3 = 252
       ELSEIF ((temp->day[x].shift[y].sbp >= 116))
        ycol3 = 256
       ELSEIF ((temp->day[x].shift[y].sbp >= 114))
        ycol3 = 260
       ELSEIF ((temp->day[x].shift[y].sbp >= 112))
        ycol3 = 264
       ELSEIF ((temp->day[x].shift[y].sbp >= 110))
        ycol3 = 268
       ELSEIF ((temp->day[x].shift[y].sbp >= 108))
        ycol3 = 272
       ELSEIF ((temp->day[x].shift[y].sbp >= 106))
        ycol3 = 276
       ELSEIF ((temp->day[x].shift[y].sbp >= 104))
        ycol3 = 280
       ELSEIF ((temp->day[x].shift[y].sbp >= 102))
        ycol3 = 284
       ELSEIF ((temp->day[x].shift[y].sbp >= 100))
        ycol3 = 288
       ELSEIF ((temp->day[x].shift[y].sbp >= 98))
        ycol3 = 292
       ELSEIF ((temp->day[x].shift[y].sbp >= 96))
        ycol3 = 296
       ELSEIF ((temp->day[x].shift[y].sbp >= 94))
        ycol3 = 300
       ELSEIF ((temp->day[x].shift[y].sbp >= 92))
        ycol3 = 304
       ELSEIF ((temp->day[x].shift[y].sbp >= 90))
        ycol3 = 308
       ELSEIF ((temp->day[x].shift[y].sbp >= 88))
        ycol3 = 312
       ELSEIF ((temp->day[x].shift[y].sbp >= 86))
        ycol3 = 316
       ELSEIF ((temp->day[x].shift[y].sbp >= 84))
        ycol3 = 320
       ELSEIF ((temp->day[x].shift[y].sbp >= 82))
        ycol3 = 324
       ELSEIF ((temp->day[x].shift[y].sbp >= 80))
        ycol3 = 328
       ELSEIF ((temp->day[x].shift[y].sbp >= 78))
        ycol3 = 332
       ELSEIF ((temp->day[x].shift[y].sbp >= 76))
        ycol3 = 336
       ELSEIF ((temp->day[x].shift[y].sbp >= 74))
        ycol3 = 340
       ELSEIF ((temp->day[x].shift[y].sbp >= 72))
        ycol3 = 344
       ELSEIF ((temp->day[x].shift[y].sbp >= 70))
        ycol3 = 348
       ELSEIF ((temp->day[x].shift[y].sbp >= 68))
        ycol3 = 352
       ELSEIF ((temp->day[x].shift[y].sbp >= 66))
        ycol3 = 356
       ELSEIF ((temp->day[x].shift[y].sbp >= 64))
        ycol3 = 360
       ELSEIF ((temp->day[x].shift[y].sbp >= 62))
        ycol3 = 364
       ELSEIF ((temp->day[x].shift[y].sbp >= 60))
        ycol3 = 368
       ELSEIF ((temp->day[x].shift[y].sbp >= 58))
        ycol3 = 372
       ELSEIF ((temp->day[x].shift[y].sbp >= 56))
        ycol3 = 376
       ELSEIF ((temp->day[x].shift[y].sbp >= 54))
        ycol3 = 380
       ELSEIF ((temp->day[x].shift[y].sbp >= 52))
        ycol3 = 384
       ELSEIF ((temp->day[x].shift[y].sbp >= 50))
        ycol3 = 388
       ELSEIF ((temp->day[x].shift[y].sbp >= 48))
        ycol3 = 392
       ELSEIF ((temp->day[x].shift[y].sbp >= 46))
        ycol3 = 396
       ELSEIF ((temp->day[x].shift[y].sbp >= 44))
        ycol3 = 400
       ELSEIF ((temp->day[x].shift[y].sbp >= 42))
        ycol3 = 404
       ELSEIF ((temp->day[x].shift[y].sbp >= 40))
        ycol3 = 408
       ENDIF
       xcol3 = (xcol3 - 17)
       IF (ycol3 > 0)
        IF (xcol3 > 88)
         CALL print(calcpos(xcol3,ycol3)), "{b}{f/17}{cpi/8}*", row + 1,
         temp->day[x].shift[y].xcol3 = xcol3, temp->day[x].shift[y].ycol3 = ycol3
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   xcol6 = (599 - ((5 - temp->day[5].zcol) * 102)), ycol6 = 0, x = 6,
   y = 7
   FOR (q = 1 TO 5)
     x = (x - 1), y = 7
     FOR (n = 1 TO 6)
       y = (y - 1), ycol6 = 0
       IF ((temp->day[x].shift[y].dbp >= 200))
        ycol6 = 88
       ELSEIF ((temp->day[x].shift[y].dbp >= 198))
        ycol6 = 92
       ELSEIF ((temp->day[x].shift[y].dbp >= 196))
        ycol6 = 96
       ELSEIF ((temp->day[x].shift[y].dbp >= 194))
        ycol6 = 100
       ELSEIF ((temp->day[x].shift[y].dbp >= 192))
        ycol6 = 104
       ELSEIF ((temp->day[x].shift[y].dbp >= 190))
        ycol6 = 108
       ELSEIF ((temp->day[x].shift[y].dbp >= 188))
        ycol6 = 112
       ELSEIF ((temp->day[x].shift[y].dbp >= 186))
        ycol6 = 116
       ELSEIF ((temp->day[x].shift[y].dbp >= 184))
        ycol6 = 120
       ELSEIF ((temp->day[x].shift[y].dbp >= 182))
        ycol6 = 124
       ELSEIF ((temp->day[x].shift[y].dbp >= 180))
        ycol6 = 128
       ELSEIF ((temp->day[x].shift[y].dbp >= 178))
        ycol6 = 132
       ELSEIF ((temp->day[x].shift[y].dbp >= 176))
        ycol6 = 136
       ELSEIF ((temp->day[x].shift[y].dbp >= 174))
        ycol6 = 140
       ELSEIF ((temp->day[x].shift[y].dbp >= 172))
        ycol6 = 144
       ELSEIF ((temp->day[x].shift[y].dbp >= 170))
        ycol6 = 148
       ELSEIF ((temp->day[x].shift[y].dbp >= 168))
        ycol6 = 152
       ELSEIF ((temp->day[x].shift[y].dbp >= 166))
        ycol6 = 156
       ELSEIF ((temp->day[x].shift[y].dbp >= 164))
        ycol6 = 160
       ELSEIF ((temp->day[x].shift[y].dbp >= 162))
        ycol6 = 164
       ELSEIF ((temp->day[x].shift[y].dbp >= 160))
        ycol6 = 168
       ELSEIF ((temp->day[x].shift[y].dbp >= 158))
        ycol6 = 172
       ELSEIF ((temp->day[x].shift[y].dbp >= 156))
        ycol6 = 176
       ELSEIF ((temp->day[x].shift[y].dbp >= 154))
        ycol6 = 180
       ELSEIF ((temp->day[x].shift[y].dbp >= 152))
        ycol6 = 184
       ELSEIF ((temp->day[x].shift[y].dbp >= 150))
        ycol6 = 188
       ELSEIF ((temp->day[x].shift[y].dbp >= 148))
        ycol6 = 192
       ELSEIF ((temp->day[x].shift[y].dbp >= 146))
        ycol6 = 196
       ELSEIF ((temp->day[x].shift[y].dbp >= 144))
        ycol6 = 200
       ELSEIF ((temp->day[x].shift[y].dbp >= 142))
        ycol6 = 204
       ELSEIF ((temp->day[x].shift[y].dbp >= 140))
        ycol6 = 208
       ELSEIF ((temp->day[x].shift[y].dbp >= 138))
        ycol6 = 212
       ELSEIF ((temp->day[x].shift[y].dbp >= 136))
        ycol6 = 216
       ELSEIF ((temp->day[x].shift[y].dbp >= 134))
        ycol6 = 220
       ELSEIF ((temp->day[x].shift[y].dbp >= 132))
        ycol6 = 224
       ELSEIF ((temp->day[x].shift[y].dbp >= 130))
        ycol6 = 228
       ELSEIF ((temp->day[x].shift[y].dbp >= 128))
        ycol6 = 232
       ELSEIF ((temp->day[x].shift[y].dbp >= 126))
        ycol6 = 236
       ELSEIF ((temp->day[x].shift[y].dbp >= 124))
        ycol6 = 240
       ELSEIF ((temp->day[x].shift[y].dbp >= 122))
        ycol6 = 244
       ELSEIF ((temp->day[x].shift[y].dbp >= 120))
        ycol6 = 248
       ELSEIF ((temp->day[x].shift[y].dbp >= 118))
        ycol6 = 252
       ELSEIF ((temp->day[x].shift[y].dbp >= 116))
        ycol6 = 256
       ELSEIF ((temp->day[x].shift[y].dbp >= 114))
        ycol6 = 260
       ELSEIF ((temp->day[x].shift[y].dbp >= 112))
        ycol6 = 264
       ELSEIF ((temp->day[x].shift[y].dbp >= 110))
        ycol6 = 268
       ELSEIF ((temp->day[x].shift[y].dbp >= 108))
        ycol6 = 272
       ELSEIF ((temp->day[x].shift[y].dbp >= 106))
        ycol6 = 276
       ELSEIF ((temp->day[x].shift[y].dbp >= 104))
        ycol6 = 280
       ELSEIF ((temp->day[x].shift[y].dbp >= 102))
        ycol6 = 284
       ELSEIF ((temp->day[x].shift[y].dbp >= 100))
        ycol6 = 288
       ELSEIF ((temp->day[x].shift[y].dbp >= 98))
        ycol6 = 292
       ELSEIF ((temp->day[x].shift[y].dbp >= 96))
        ycol6 = 296
       ELSEIF ((temp->day[x].shift[y].dbp >= 94))
        ycol6 = 300
       ELSEIF ((temp->day[x].shift[y].dbp >= 92))
        ycol6 = 304
       ELSEIF ((temp->day[x].shift[y].dbp >= 90))
        ycol6 = 308
       ELSEIF ((temp->day[x].shift[y].dbp >= 88))
        ycol6 = 312
       ELSEIF ((temp->day[x].shift[y].dbp >= 86))
        ycol6 = 316
       ELSEIF ((temp->day[x].shift[y].dbp >= 84))
        ycol6 = 320
       ELSEIF ((temp->day[x].shift[y].dbp >= 82))
        ycol6 = 324
       ELSEIF ((temp->day[x].shift[y].dbp >= 80))
        ycol6 = 328
       ELSEIF ((temp->day[x].shift[y].dbp >= 78))
        ycol6 = 332
       ELSEIF ((temp->day[x].shift[y].dbp >= 76))
        ycol6 = 336
       ELSEIF ((temp->day[x].shift[y].dbp >= 74))
        ycol6 = 340
       ELSEIF ((temp->day[x].shift[y].dbp >= 72))
        ycol6 = 344
       ELSEIF ((temp->day[x].shift[y].dbp >= 70))
        ycol6 = 348
       ELSEIF ((temp->day[x].shift[y].dbp >= 68))
        ycol6 = 352
       ELSEIF ((temp->day[x].shift[y].dbp >= 66))
        ycol6 = 356
       ELSEIF ((temp->day[x].shift[y].dbp >= 64))
        ycol6 = 360
       ELSEIF ((temp->day[x].shift[y].dbp >= 62))
        ycol6 = 364
       ELSEIF ((temp->day[x].shift[y].dbp >= 60))
        ycol6 = 368
       ELSEIF ((temp->day[x].shift[y].dbp >= 58))
        ycol6 = 372
       ELSEIF ((temp->day[x].shift[y].dbp >= 56))
        ycol6 = 376
       ELSEIF ((temp->day[x].shift[y].dbp >= 54))
        ycol6 = 380
       ELSEIF ((temp->day[x].shift[y].dbp >= 52))
        ycol6 = 384
       ELSEIF ((temp->day[x].shift[y].dbp >= 50))
        ycol6 = 388
       ELSEIF ((temp->day[x].shift[y].dbp >= 48))
        ycol6 = 392
       ELSEIF ((temp->day[x].shift[y].dbp >= 46))
        ycol6 = 396
       ELSEIF ((temp->day[x].shift[y].dbp >= 44))
        ycol6 = 400
       ELSEIF ((temp->day[x].shift[y].dbp >= 42))
        ycol6 = 404
       ELSEIF ((temp->day[x].shift[y].dbp >= 40))
        ycol6 = 408
       ENDIF
       xcol6 = (xcol6 - 17)
       IF (ycol6 > 0)
        IF (xcol6 > 88)
         CALL print(calcpos(xcol6,ycol6)), "{b}{f/17}{cpi/8}*", row + 1,
         temp->day[x].shift[y].xcol6 = xcol6, temp->day[x].shift[y].ycol6 = ycol6
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   xcol = (599 - ((5 - temp->day[5].zcol) * 102)), ycol = 0, x = 6,
   y = 7
   FOR (q = 1 TO 5)
     x = (x - 1), y = 7
     FOR (n = 1 TO 6)
       y = (y - 1), ycol = 422, xcol = (xcol - 17)
       IF (xcol > 88)
        "{f/4}{cpi/16}", row + 1
        IF ((temp->day[x].shift[y].sbp > 0))
         CALL print(calcpos(xcol,ycol)), temp->day[x].shift[y].sbp"###", row + 1
        ENDIF
        ycol = 432
        IF ((temp->day[x].shift[y].dbp > 0))
         CALL print(calcpos(xcol,ycol)), temp->day[x].shift[y].dbp"###", row + 1
        ENDIF
        ycol = 443
        IF ((temp->day[x].shift[y].pulse > 0))
         CALL print(calcpos(xcol,ycol)), temp->day[x].shift[y].pulse"###", row + 1
        ENDIF
        ycol = 453
        IF ((temp->day[x].shift[y].resp > 0))
         CALL print(calcpos(xcol,ycol)), temp->day[x].shift[y].resp"###", row + 1
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   xcol = (599 - ((5 - temp->day[5].zcol) * 102)), ycol = 0, x = 6,
   y = 7
   FOR (q = 1 TO 5)
     x = (x - 1), ycol = 463, xcol = (xcol - 102)
     IF (xcol > 88)
      "{f/4}{cpi/16}", row + 1
      IF ((temp->day[x].weight != "0.0"))
       CALL print(calcpos((xcol+ 45),ycol)), temp->day[x].weight, row + 1
      ENDIF
      ycol = 491
      IF ((temp->day[x].iv > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].iv, row + 1
      ENDIF
      ycol = 505
      IF ((temp->day[x].oral > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].oral, row + 1
      ENDIF
      ycol = 519
      IF ((temp->day[x].tubefeed > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].tubefeed, row + 1
      ENDIF
      ycol = 533
      IF ((temp->day[x].blood > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].blood, row + 1
      ENDIF
      ycol = 547
      IF ((temp->day[x].miscin > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].miscin, row + 1
      ENDIF
      ycol = 561
      IF ((temp->day[x].parent > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].parent, row + 1
      ENDIF
      ycol = 574
      IF ((temp->day[x].intotal > 0))
       CALL print(calcpos(xcol,ycol)), "{b}", temp->day[x].intotal,
       row + 1
      ENDIF
      ycol = 588
      IF ((temp->day[x].urine > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].urine, row + 1
      ENDIF
      ycol = 601
      IF ((temp->day[x].drain > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].drain, row + 1
      ENDIF
      ycol = 614
      IF ((temp->day[x].gastsuc > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].gastsuc, row + 1
      ENDIF
      ycol = 627
      IF ((temp->day[x].liqstool > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].liqstool, row + 1
      ENDIF
      ycol = 640
      IF ((temp->day[x].miscout > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].miscout, row + 1
      ENDIF
      ycol = 655
      IF ((temp->day[x].outtotal > 0))
       CALL print(calcpos(xcol,ycol)), "{b}", temp->day[x].outtotal,
       row + 1
      ENDIF
      ycol = 668
      IF ((temp->day[x].bmnum > 0))
       CALL print(calcpos(xcol,ycol)), temp->day[x].bmnum, row + 1
      ENDIF
      ycol = 681, q1 = (temp->day[x].intotal - temp->day[x].outtotal),
      CALL print(calcpos(xcol,ycol)),
      "{b}", q1, row + 1,
      ycol = 50
      IF ((temp->day[x].zcol > 0))
       "{f/12}{cpi/13}", row + 1, j = (curdate - (5 - x)),
       CALL print(calcpos(xcol,ycol)), j"MM/DD/YY;;D", row + 1
      ENDIF
     ENDIF
   ENDFOR
   xcol = (630 - ((5 - temp->day[5].zcol) * 102)), ycol = 0, x = 6,
   y = 7
   FOR (q = 1 TO 5)
     x = (x - 1), ycol = 70, xcol = (xcol - 102)
     IF ((temp->day[x].dayofstay > 0))
      CALL print(calcpos(xcol,ycol)), "{f/12}{cpi/13}"
      IF ((temp->day[x].dayofstay < 1000))
       temp->day[x].dayofstay
      ENDIF
      row + 1
     ENDIF
   ENDFOR
   x = 6, onefound = "N", onefound2 = "N",
   onefound3 = "N", xcol = 0, ycol = 0,
   xcol1 = 0, ycol1 = 0, xcol2 = 0,
   ycol2 = 0, xcol3 = 0, ycol3 = 0,
   xcol4 = 0, ycol4 = 0, xcol5 = 0,
   ycol5 = 0, xcol6 = 0, ycol6 = 0,
   xcol7 = 0, ycol7 = 0, xcol8 = 0,
   ycol8 = 0, psstring = fillstring(155," "), psstring2 = fillstring(155," "),
   psstring3 = fillstring(155," ")
   FOR (q = 1 TO 5)
     x = (x - 1), y = 7
     FOR (n = 1 TO 6)
       y = (y - 1)
       IF ((temp->day[x].shift[y].xcol > 0))
        IF (onefound="N")
         onefound = "Y", xcol1 = (temp->day[x].shift[y].xcol+ 8), ycol1 = (775 - temp->day[x].shift[y
         ].ycol)
        ELSE
         xcol2 = (temp->day[x].shift[y].xcol+ 8), ycol2 = (775 - temp->day[x].shift[y].ycol),
         psstring = concat("{ps/ gsave [] 0 setdash ",cnvtstring(xcol1)," ",cnvtstring(ycol1),
          " moveto ",
          cnvtstring(xcol2)," ",cnvtstring(ycol2)," lineto stroke grestore/}"),
         psstring, row + 1, xcol1 = (temp->day[x].shift[y].xcol+ 8),
         ycol1 = (775 - temp->day[x].shift[y].ycol)
        ENDIF
       ENDIF
       IF ((temp->day[x].shift[y].xcol3 > 0))
        IF (onefound2="N")
         onefound2 = "Y", xcol4 = (temp->day[x].shift[y].xcol3+ 4), ycol4 = (779 - temp->day[x].
         shift[y].ycol3)
        ELSE
         xcol5 = (temp->day[x].shift[y].xcol3+ 4), ycol5 = (779 - temp->day[x].shift[y].ycol3),
         psstring2 = concat("{ps/ gsave 1 setlinewidth [ 4 4 ] 0 setdash ",cnvtstring(xcol4)," ",
          cnvtstring(ycol4)," moveto ",
          cnvtstring(xcol5)," ",cnvtstring(ycol5)," lineto stroke grestore/}"),
         psstring2, row + 1, xcol4 = (temp->day[x].shift[y].xcol3+ 4),
         ycol4 = (779 - temp->day[x].shift[y].ycol3)
        ENDIF
       ENDIF
       IF ((temp->day[x].shift[y].xcol6 > 0))
        IF (onefound3="N")
         onefound3 = "Y", xcol7 = (temp->day[x].shift[y].xcol6+ 4), ycol7 = (779 - temp->day[x].
         shift[y].ycol6)
        ELSE
         xcol8 = (temp->day[x].shift[y].xcol6+ 4), ycol8 = (779 - temp->day[x].shift[y].ycol6),
         psstring3 = concat("{ps/ gsave 1 setlinewidth [ 4 4 ] 0 setdash ",cnvtstring(xcol7)," ",
          cnvtstring(ycol7)," moveto ",
          cnvtstring(xcol8)," ",cnvtstring(ycol8)," lineto stroke grestore/}"),
         psstring3, row + 1, xcol7 = (temp->day[x].shift[y].xcol6+ 4),
         ycol7 = (779 - temp->day[x].shift[y].ycol6)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
  WITH dio = postscript, maxcol = 800, maxrow = 750
 ;end select
END GO
