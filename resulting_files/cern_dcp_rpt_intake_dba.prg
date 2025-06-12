CREATE PROGRAM cern_dcp_rpt_intake:dba
 RECORD temp(
   1 shift[3]
     2 ns = i4
     2 ns_note_ind = i2
     2 ns_event_id = f8
     2 ns_text = vc
     2 d5w = i4
     2 d5w_note_ind = i2
     2 d5w_event_id = f8
     2 d5w_text = vc
     2 norm = i4
     2 norm_note_ind = i2
     2 norm_event_id = f8
     2 norm_text = vc
     2 iv = i4
     2 iv_note_ind = i2
     2 iv_event_id = f8
     2 iv_text = vc
     2 lr = i4
     2 lr_note_ind = i2
     2 lr_event_id = f8
     2 lr_text = vc
     2 kcl = i4
     2 kcl_note_ind = i2
     2 kcl_event_id = f8
     2 kcl_text = vc
     2 d10w = i4
     2 d10w_note_ind = i2
     2 d10w_event_id = f8
     2 d10w_text = vc
     2 d5ns = i4
     2 d5ns_note_ind = i2
     2 d5ns_event_id = f8
     2 d5ns_text = vc
     2 d52ns = i4
     2 d52ns_note_ind = i2
     2 d52ns_event_id = f8
     2 d52ns_text = vc
     2 bolus = i4
     2 bolus_note_ind = i2
     2 bolus_event_id = f8
     2 bolus_text = vc
     2 flush = i4
     2 flush_note_ind = i2
     2 flush_event_id = f8
     2 flush_text = vc
     2 md5 = i4
     2 md5_note_ind = i2
     2 md5_event_id = f8
     2 md5_text = vc
     2 ns20 = i4
     2 ns20_note_ind = i2
     2 ns20_event_id = f8
     2 ns20_text = vc
     2 lrd5 = i4
     2 lrd5_note_ind = i2
     2 lrd5_event_id = f8
     2 lrd5_text = vc
     2 d5wns = i4
     2 d5wns_note_ind = i2
     2 d5wns_event_id = f8
     2 d5wns_text = vc
     2 45ns = i4
     2 45ns_note_ind = i2
     2 45ns_event_id = f8
     2 45ns_text = vc
     2 las = i4
     2 las_note_ind = i2
     2 las_event_id = f8
     2 las_text = vc
     2 nit = i4
     2 nit_note_ind = i2
     2 nit_event_id = f8
     2 nit_text = vc
     2 dop = i4
     2 dop_note_ind = i2
     2 dop_event_id = f8
     2 dop_text = vc
     2 dob = i4
     2 dob_note_ind = i2
     2 dob_event_id = f8
     2 dob_text = vc
     2 lid = i4
     2 lid_note_ind = i2
     2 lid_event_id = f8
     2 lid_text = vc
     2 theo = i4
     2 theo_note_ind = i2
     2 theo_event_id = f8
     2 theo_text = vc
     2 ins = i4
     2 ins_note_ind = i2
     2 ins_event_id = f8
     2 ins_text = vc
     2 med = i4
     2 med_note_ind = i2
     2 med_event_id = f8
     2 med_text = vc
     2 tube = i4
     2 tube_note_ind = i2
     2 tube_event_id = f8
     2 tube_text = vc
     2 oral = i4
     2 oral_note_ind = i2
     2 oral_event_id = f8
     2 oral_text = vc
     2 packed = i4
     2 packed_note_ind = i2
     2 packed_event_id = f8
     2 packed_text = vc
     2 plate = i4
     2 plate_note_ind = i2
     2 plate_event_id = f8
     2 plate_text = vc
     2 plasma = i4
     2 plasma_note_ind = i2
     2 plasma_event_id = f8
     2 plasma_text = vc
     2 blood = i4
     2 blood_note_ind = i2
     2 blood_event_id = f8
     2 blood_text = vc
     2 misc = i4
     2 misc_note_ind = i2
     2 misc_event_id = f8
     2 misc_text = vc
     2 cbi = i4
     2 cbi_note_ind = i2
     2 cbi_event_id = f8
     2 cbi_text = vc
     2 gasflush = i4
     2 gasflush_note_ind = i2
     2 gasflush_event_id = f8
     2 gasflush_text = vc
     2 tpn = i4
     2 tpn_note_ind = i2
     2 tpn_event_id = f8
     2 tpn_text = vc
     2 lipid = i4
     2 lipid_note_ind = i2
     2 lipid_event_id = f8
     2 lipid_text = vc
     2 intotal = i4
     2 intotal_note_ind = i2
     2 intotal_event_id = f8
     2 intotal_text = vc
     2 urinef = i4
     2 urinef_note_ind = i2
     2 urinef_event_id = f8
     2 urinef_text = vc
     2 urinev = i4
     2 urinev_note_ind = i2
     2 urinev_event_id = f8
     2 urinev_text = vc
     2 urine = i4
     2 urine_note_ind = i2
     2 urine_event_id = f8
     2 urine_text = vc
     2 drainage = i4
     2 drainage_note_ind = i2
     2 drainage_event_id = f8
     2 drainage_text = vc
     2 emesis = i4
     2 emesis_note_ind = i2
     2 emesis_event_id = f8
     2 emesis_text = vc
     2 gasresid = i4
     2 gasresid_note_ind = i2
     2 gasresid_event_id = f8
     2 gasresid_text = vc
     2 liqstool = i4
     2 liqstool_note_ind = i2
     2 liqstool_event_id = f8
     2 liqstool_text = vc
     2 stoolcnt = i4
     2 stoolcnt_note_ind = i2
     2 stoolcnt_event_id = f8
     2 stoolcnt_text = vc
     2 ostomy = i4
     2 ostomy_note_ind = i2
     2 ostomy_event_id = f8
     2 ostomy_text = vc
     2 diaperct = i4
     2 diaperct_note_ind = i2
     2 diaperct_event_id = f8
     2 diaperct_text = vc
     2 diaperwt = i4
     2 diaperwt_note_ind = i2
     2 diaperwt_event_id = f8
     2 diaperwt_text = vc
     2 pad = i4
     2 pad_note_ind = i2
     2 pad_event_id = f8
     2 pad_text = vc
     2 loss = i4
     2 loss_note_ind = i2
     2 loss_event_id = f8
     2 loss_text = vc
     2 cbiout = i4
     2 cbiout_note_ind = i2
     2 cbiout_event_id = f8
     2 cbiout_text = vc
     2 out = i4
     2 out_note_ind = i2
     2 out_event_id = f8
     2 out_text = vc
     2 wdrain = i4
     2 wdrain_note_ind = i2
     2 wdrain_event_id = f8
     2 wdrain_text = vc
     2 cdrain = i4
     2 cdrain_note_ind = i2
     2 cdrain_event_id = f8
     2 cdrain_text = vc
     2 outtotal = i4
     2 outtotal_note_ind = i2
     2 outtotal_event_id = f8
     2 outtotal_text = vc
     2 void = i4
     2 void_note_ind = i2
     2 void_event_id = f8
     2 void_text = vc
 )
 SET modify = predeclare
 DECLARE 45ns_cd = i4 WITH constant(0)
 DECLARE blood_cd = i4 WITH constant(0)
 DECLARE bolus_cd = i4 WITH constant(0)
 DECLARE cbi_cd = i4 WITH constant(0)
 DECLARE cbiout_cd = i4 WITH constant(0)
 DECLARE cdrain_cd = i4 WITH constant(0)
 DECLARE d10w_cd = i4 WITH constant(0)
 DECLARE d52ns_cd = i4 WITH constant(0)
 DECLARE d5ns_cd = i4 WITH constant(0)
 DECLARE d5w_cd = i4 WITH constant(0)
 DECLARE d5wns_cd = i4 WITH constant(0)
 DECLARE diaperct_cd = i4 WITH constant(0)
 DECLARE diaperwt_cd = i4 WITH constant(0)
 DECLARE dob_cd = i4 WITH constant(0)
 DECLARE dop_cd = i4 WITH constant(0)
 DECLARE drainage_cd = i4 WITH constant(0)
 DECLARE emesis_cd = i4 WITH constant(0)
 DECLARE flush_cd = i4 WITH constant(0)
 DECLARE gasflush_cd = i4 WITH constant(0)
 DECLARE gasresid_cd = i4 WITH constant(0)
 DECLARE ins_cd = i4 WITH constant(0)
 DECLARE iv_cd = i4 WITH constant(0)
 DECLARE kcl_cd = i4 WITH constant(0)
 DECLARE las_cd = i4 WITH constant(0)
 DECLARE lid_cd = i4 WITH constant(0)
 DECLARE lipid_cd = i4 WITH constant(0)
 DECLARE liqstool_cd = i4 WITH constant(0)
 DECLARE loss_cd = i4 WITH constant(0)
 DECLARE lr_cd = i4 WITH constant(0)
 DECLARE lrd5_cd = i4 WITH constant(0)
 DECLARE md5_cd = i4 WITH constant(0)
 DECLARE med_cd = i4 WITH constant(0)
 DECLARE misc_cd = i4 WITH constant(0)
 DECLARE nit_cd = i4 WITH constant(0)
 DECLARE norm_cd = i4 WITH constant(0)
 DECLARE ns20_cd = i4 WITH constant(0)
 DECLARE ns_cd = i4 WITH constant(0)
 DECLARE oral_cd = i4 WITH constant(0)
 DECLARE ostomy_cd = i4 WITH constant(0)
 DECLARE out_cd = i4 WITH constant(0)
 DECLARE packed_cd = i4 WITH constant(0)
 DECLARE pad_cd = i4 WITH constant(0)
 DECLARE plasma_cd = i4 WITH constant(0)
 DECLARE plate_cd = i4 WITH constant(0)
 DECLARE stoolcnt_cd = i4 WITH constant(0)
 DECLARE theo_cd = i4 WITH constant(0)
 DECLARE tpn_cd = i4 WITH constant(0)
 DECLARE tube_cd = i4 WITH constant(0)
 DECLARE urine_cd = i4 WITH constant(0)
 DECLARE urinef_cd = i4 WITH constant(0)
 DECLARE urinev_cd = i4 WITH constant(0)
 DECLARE void_cd = i4 WITH constant(0)
 DECLARE wdrain_cd = i4 WITH constant(0)
 DECLARE iv_ind = i2 WITH noconstant(0)
 DECLARE tube_ind = i2 WITH noconstant(0)
 DECLARE oral_ind = i2 WITH noconstant(0)
 DECLARE blood_ind = i2 WITH noconstant(0)
 DECLARE misc_ind = i2 WITH noconstant(0)
 DECLARE parent_ind = i2 WITH noconstant(0)
 DECLARE urine_ind = i2 WITH noconstant(0)
 DECLARE drain_ind = i2 WITH noconstant(0)
 DECLARE stool_ind = i2 WITH noconstant(0)
 DECLARE gastric_ind = i2 WITH noconstant(0)
 DECLARE out_ind = i2 WITH noconstant(0)
 DECLARE a = i4 WITH noconstant(0)
 DECLARE b = i4 WITH noconstant(0)
 DECLARE c = i4 WITH noconstant(0)
 DECLARE z = i4 WITH noconstant(0)
 DECLARE q = i4 WITH noconstant(0)
 DECLARE name = vc WITH noconstant(fillstring(50," "))
 DECLARE age = vc WITH noconstant(fillstring(50," "))
 DECLARE dob = vc WITH noconstant(fillstring(50," "))
 DECLARE mrn = vc WITH noconstant(fillstring(50," "))
 DECLARE finnbr = vc WITH noconstant(fillstring(50," "))
 DECLARE admitdoc = vc WITH noconstant(fillstring(50," "))
 DECLARE unit = vc WITH noconstant(fillstring(20," "))
 DECLARE room = vc WITH noconstant(fillstring(20," "))
 DECLARE bed = vc WITH noconstant(fillstring(20," "))
 DECLARE xxx = vc WITH noconstant(fillstring(60," "))
 DECLARE xcol = i4 WITH noconstant(0)
 DECLARE ycol = i4 WITH noconstant(0)
 DECLARE p = vc WITH noconstant(fillstring(27,"_"))
 DECLARE k = vc WITH noconstant(fillstring(34,"_"))
 DECLARE ops_ind = c1 WITH noconstant("N")
 DECLARE beg_ind = i2 WITH noconstant(0)
 DECLARE end_ind = i2 WITH noconstant(0)
 DECLARE beg_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE end_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE x2 = c2 WITH noconstant("  ")
 DECLARE x3 = c3 WITH noconstant("   ")
 DECLARE abc = vc WITH noconstant(fillstring(25," "))
 DECLARE xyz = c21 WITH noconstant("  -   -       :  :  ")
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE diff = f8 WITH noconstant(0.0)
 DECLARE ocfcomp_cd = f8 WITH noconstant(0.0)
 DECLARE person_mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE encntr_mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE finnbr_cd = f8 WITH noconstant(0.0)
 DECLARE attend_doc_cd = f8 WITH noconstant(0.0)
 SET ocfcomp_cd = uar_get_code_by("MEANING",120,"OCFCOMP")
 SET person_mrn_alias_cd = uar_get_code_by("MEANING",4,"MRN")
 SET encntr_mrn_alias_cd = uar_get_code_by("MEANING",319,"MRN")
 SET finnbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET attend_doc_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 IF ((request->visit[1].encntr_id <= 0))
  GO TO report_failed
 ENDIF
 FOR (x = 1 TO 3)
   SET temp->shift[x].ns = 0
   SET temp->shift[x].d5w = 0
   SET temp->shift[x].norm = 0
   SET temp->shift[x].iv = 0
   SET temp->shift[x].lr = 0
   SET temp->shift[x].kcl = 0
   SET temp->shift[x].d10w = 0
   SET temp->shift[x].d5ns = 0
   SET temp->shift[x].d52ns = 0
   SET temp->shift[x].bolus = 0
   SET temp->shift[x].flush = 0
   SET temp->shift[x].md5 = 0
   SET temp->shift[x].ns20 = 0
   SET temp->shift[x].lrd5 = 0
   SET temp->shift[x].d5wns = 0
   SET temp->shift[x].45ns = 0
   SET temp->shift[x].las = 0
   SET temp->shift[x].nit = 0
   SET temp->shift[x].dop = 0
   SET temp->shift[x].dob = 0
   SET temp->shift[x].lid = 0
   SET temp->shift[x].theo = 0
   SET temp->shift[x].ins = 0
   SET temp->shift[x].med = 0
   SET temp->shift[x].oral = 0
   SET temp->shift[x].tube = 0
   SET temp->shift[x].packed = 0
   SET temp->shift[x].plate = 0
   SET temp->shift[x].plasma = 0
   SET temp->shift[x].blood = 0
   SET temp->shift[x].lipid = 0
   SET temp->shift[x].tpn = 0
   SET temp->shift[x].gasflush = 0
   SET temp->shift[x].cbi = 0
   SET temp->shift[x].misc = 0
   SET temp->shift[x].intotal = 0
   SET temp->shift[x].urine = 0
   SET temp->shift[x].urinev = 0
   SET temp->shift[x].urinef = 0
   SET temp->shift[x].drainage = 0
   SET temp->shift[x].gasresid = 0
   SET temp->shift[x].emesis = 0
   SET temp->shift[x].diaperwt = 0
   SET temp->shift[x].diaperct = 0
   SET temp->shift[x].ostomy = 0
   SET temp->shift[x].liqstool = 0
   SET temp->shift[x].stoolcnt = 0
   SET temp->shift[x].cbiout = 0
   SET temp->shift[x].loss = 0
   SET temp->shift[x].pad = 0
   SET temp->shift[x].out = 0
   SET temp->shift[x].wdrain = 0
   SET temp->shift[x].cdrain = 0
   SET temp->shift[x].outtotal = 0
   SET temp->shift[x].void = 0
 ENDFOR
 IF ((request->batch_selection > " "))
  SET ops_ind = "Y"
 ENDIF
 CALL echo(build("xyz:",xyz))
 FOR (x = 1 TO request->nv_cnt)
   IF ((request->nv[x].pvc_name="BEG_DT_TM"))
    SET beg_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET beg_dt_tm = cnvtdatetime(xyz)
    CALL echo(build("xyz:",xyz))
   ELSEIF ((request->nv[x].pvc_name="END_DT_TM"))
    SET end_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET end_dt_tm = cnvtdatetime(xyz)
   ENDIF
 ENDFOR
 CALL echo(build("beg ind:",beg_ind))
 CALL echo(build("end ind:",end_ind))
 IF (((end_ind=0) OR (beg_ind=0)) )
  IF (ops_ind="Y")
   SET beg_dt_tm = cnvtdatetime((curdate - 1),0)
   SET end_dt_tm = cnvtdatetime(curdate,0)
  ELSE
   SET beg_dt_tm = cnvtdatetime(curdate,0)
   SET end_dt_tm = cnvtdatetime(curdate,curtime)
  ENDIF
 ENDIF
 SET diff = datetimediff(cnvtdatetime(end_dt_tm),cnvtdatetime(beg_dt_tm))
 CALL echo(build("diff:",diff))
 CALL echo(build("enddttm:",end_dt_tm))
 IF (diff > 1)
  SET end_dt_tm = datetimeadd(cnvtdatetime(beg_dt_tm),1)
 ENDIF
 CALL echo(build("begdttm:",beg_dt_tm))
 CALL echo(build("enddttm:",end_dt_tm))
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
   cbi_cd, misc_cd, gasflush_cd, tpn_cd, lipid_cd,
   urinef_cd, urinev_cd, urine_cd, drainage_cd, emesis_cd,
   gasresid_cd, liqstool_cd, diaperct_cd, diaperwt_cd, ostomy_cd,
   stoolcnt_cd, out_cd, loss_cd, pad_cd, cbiout_cd,
   wdrain_cd, cdrain_cd, void_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(end_dt_tm))
  ORDER BY c.event_cd, c.event_end_dt_tm
  DETAIL
   diff = datetimediff(cnvtdatetime(c.event_end_dt_tm),cnvtdatetime(beg_dt_tm)), diff = (diff * 1440),
   CALL echo(build("diff:",diff))
   IF (diff < 480)
    x = 1
    IF (c.event_cd=ns_cd)
     temp->shift[x].ns = (temp->shift[x].ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5w_cd)
     temp->shift[x].d5w = (temp->shift[x].d5w+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5w_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5w_event_id = c
     .event_id
    ELSEIF (c.event_cd=norm_cd)
     temp->shift[x].norm = (temp->shift[x].norm+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].norm_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].norm_event_id = c
     .event_id
    ELSEIF (c.event_cd=iv_cd)
     temp->shift[x].iv = (temp->shift[x].iv+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].iv_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].iv_event_id = c
     .event_id
    ELSEIF (c.event_cd=lr_cd)
     temp->shift[x].lr = (temp->shift[x].lr+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lr_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lr_event_id = c
     .event_id
    ELSEIF (c.event_cd=kcl_cd)
     temp->shift[x].kcl = (temp->shift[x].kcl+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].kcl_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].kcl_event_id = c
     .event_id
    ELSEIF (c.event_cd=d10w_cd)
     temp->shift[x].d10w = (temp->shift[x].d10w+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d10w_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d10w_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5ns_cd)
     temp->shift[x].d5ns = (temp->shift[x].d5ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=d52ns_cd)
     temp->shift[x].d52ns = (temp->shift[x].d52ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d52ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d52ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=bolus_cd)
     temp->shift[x].bolus = (temp->shift[x].bolus+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].bolus_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].bolus_event_id = c
     .event_id
    ELSEIF (c.event_cd=flush_cd)
     temp->shift[x].flush = (temp->shift[x].flush+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].flush_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].flush_event_id = c
     .event_id
    ELSEIF (c.event_cd=md5_cd)
     temp->shift[x].md5 = (temp->shift[x].md5+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].md5_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].md5_event_id = c
     .event_id
    ELSEIF (c.event_cd=ns20_cd)
     temp->shift[x].ns20 = (temp->shift[x].ns20+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ns20_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ns20_event_id = c
     .event_id
    ELSEIF (c.event_cd=lrd5_cd)
     temp->shift[x].lrd5 = (temp->shift[x].lrd5+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lrd5_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lrd5_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5wns_cd)
     temp->shift[x].d5wns = (temp->shift[x].d5wns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5wns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5wns_event_id = c
     .event_id
    ELSEIF (c.event_cd=45ns_cd)
     temp->shift[x].45ns = (temp->shift[x].45ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].45ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].45ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=las_cd)
     temp->shift[x].las = (temp->shift[x].las+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].las_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].las_event_id = c
     .event_id
    ELSEIF (c.event_cd=nit_cd)
     temp->shift[x].nit = (temp->shift[x].nit+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].nit_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].nit_event_id = c
     .event_id
    ELSEIF (c.event_cd=dop_cd)
     temp->shift[x].dop = (temp->shift[x].dop+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].dop_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].dop_event_id = c
     .event_id
    ELSEIF (c.event_cd=dob_cd)
     temp->shift[x].dob = (temp->shift[x].dob+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].dob_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].dob_event_id = c
     .event_id
    ELSEIF (c.event_cd=lid_cd)
     temp->shift[x].lid = (temp->shift[x].lid+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lid_event_id = c
     .event_id
    ELSEIF (c.event_cd=theo_cd)
     temp->shift[x].theo = (temp->shift[x].theo+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].theo_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].theo_event_id = c
     .event_id
    ELSEIF (c.event_cd=ins_cd)
     temp->shift[x].ins = (temp->shift[x].ins+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ins_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ins_event_id = c
     .event_id
    ELSEIF (c.event_cd=med_cd)
     temp->shift[x].med = (temp->shift[x].med+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].med_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].med_event_id = c
     .event_id
    ELSEIF (c.event_cd=oral_cd)
     temp->shift[x].oral = (temp->shift[x].oral+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), oral_ind = 1,
     temp->shift[x].oral_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].oral_event_id = c
     .event_id
    ELSEIF (c.event_cd=tube_cd)
     temp->shift[x].tube = (temp->shift[x].tube+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), tube_ind = 1,
     temp->shift[x].tube_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].tube_event_id = c
     .event_id
    ELSEIF (c.event_cd=packed_cd)
     temp->shift[x].packed = (temp->shift[x].packed+ cnvtreal(c.event_tag)), temp->shift[x].intotal
      = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].packed_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].packed_event_id = c
     .event_id
    ELSEIF (c.event_cd=plasma_cd)
     temp->shift[x].plasma = (temp->shift[x].plasma+ cnvtreal(c.event_tag)), temp->shift[x].intotal
      = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].plasma_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].plasma_event_id = c
     .event_id
    ELSEIF (c.event_cd=plate_cd)
     temp->shift[x].plate = (temp->shift[x].plate+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].plate_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].plate_event_id = c
     .event_id
    ELSEIF (c.event_cd=blood_cd)
     temp->shift[x].blood = (temp->shift[x].blood+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].blood_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].blood_event_id = c
     .event_id
    ELSEIF (c.event_cd=cbi_cd)
     temp->shift[x].cbi = (temp->shift[x].cbi+ cnvtreal(c.event_tag)), misc_ind = 1, temp->shift[x].
     cbi_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].cbi_event_id = c.event_id
    ELSEIF (c.event_cd=misc_cd)
     temp->shift[x].misc = (temp->shift[x].misc+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), misc_ind = 1,
     temp->shift[x].misc_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].misc_event_id = c
     .event_id
    ELSEIF (c.event_cd=gasflush_cd)
     temp->shift[x].gasflush = (temp->shift[x].gasflush+ cnvtreal(c.event_tag)), temp->shift[x].
     intotal = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), misc_ind = 1,
     temp->shift[x].gasflush_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].gasflush_event_id
      = c.event_id
    ELSEIF (c.event_cd=tpn_cd)
     temp->shift[x].tpn = (temp->shift[x].tpn+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), parent_ind = 1,
     temp->shift[x].tpn_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].tpn_event_id = c
     .event_id
    ELSEIF (c.event_cd=lipid_cd)
     temp->shift[x].lipid = (temp->shift[x].lipid+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), parent_ind = 1,
     temp->shift[x].lipid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lipid_event_id = c
     .event_id
    ELSEIF (c.event_cd=urinef_cd)
     temp->shift[x].urinef = (temp->shift[x].urinef+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urinef_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urinef_event_id = c
     .event_id
    ELSEIF (c.event_cd=urinev_cd)
     temp->shift[x].urinev = (temp->shift[x].urinev+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urinev_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urinev_event_id = c
     .event_id
    ELSEIF (c.event_cd=urine_cd)
     temp->shift[x].urine = (temp->shift[x].urine+ cnvtreal(c.event_tag)), temp->shift[x].outtotal =
     (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urine_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urine_event_id = c
     .event_id
    ELSEIF (c.event_cd=void_cd)
     temp->shift[x].void = (temp->shift[x].void+ cnvtreal(c.event_tag)), urine_ind = 1, temp->shift[x
     ].void_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].void_event_id = c.event_id
    ELSEIF (c.event_cd=drainage_cd)
     temp->shift[x].drainage = (temp->shift[x].drainage+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].drainage_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].drainage_event_id
      = c.event_id
    ELSEIF (c.event_cd=emesis_cd)
     temp->shift[x].emesis = (temp->shift[x].emesis+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].emesis_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].emesis_event_id = c
     .event_id
    ELSEIF (c.event_cd=gasresid_cd)
     temp->shift[x].gasresid = (temp->shift[x].gasresid+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].gasresid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].gasresid_event_id
      = c.event_id
    ELSEIF (c.event_cd=liqstool_cd)
     temp->shift[x].liqstool = (temp->shift[x].liqstool+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), stool_ind = 1,
     temp->shift[x].liqstool_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].liqstool_event_id
      = c.event_id
    ELSEIF (c.event_cd=diaperct_cd)
     temp->shift[x].diaperct = (temp->shift[x].diaperct+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].diaperct_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].diaperct_event_id = c.event_id
    ELSEIF (c.event_cd=diaperwt_cd)
     temp->shift[x].diaperwt = (temp->shift[x].diaperwt+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].diaperwt_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].diaperwt_event_id = c.event_id
    ELSEIF (c.event_cd=ostomy_cd)
     temp->shift[x].ostomy = (temp->shift[x].ostomy+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), stool_ind = 1,
     temp->shift[x].ostomy_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ostomy_event_id = c
     .event_id
    ELSEIF (c.event_cd=stoolcnt_cd)
     temp->shift[x].stoolcnt = (temp->shift[x].stoolcnt+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].stoolcnt_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].stoolcnt_event_id = c.event_id
    ELSEIF (c.event_cd=out_cd)
     temp->shift[x].out = (temp->shift[x].out+ cnvtreal(c.event_tag)), temp->shift[x].outtotal = (
     temp->shift[x].outtotal+ cnvtreal(c.event_tag)), out_ind = 1,
     temp->shift[x].out_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].out_event_id = c
     .event_id
    ELSEIF (c.event_cd=loss_cd)
     temp->shift[x].loss = (temp->shift[x].loss+ cnvtreal(c.event_tag)), temp->shift[x].outtotal = (
     temp->shift[x].outtotal+ cnvtreal(c.event_tag)), out_ind = 1,
     temp->shift[x].loss_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].loss_event_id = c
     .event_id
    ELSEIF (c.event_cd=pad_cd)
     temp->shift[x].pad = (temp->shift[x].pad+ cnvtreal(c.event_tag)), out_ind = 1, temp->shift[x].
     pad_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].pad_event_id = c.event_id
    ELSEIF (c.event_cd=cbiout_cd)
     temp->shift[x].cbiout = (temp->shift[x].cbiout+ cnvtreal(c.event_tag)), out_ind = 1, temp->
     shift[x].cbiout_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].cbiout_event_id = c.event_id
    ELSEIF (c.event_cd=wdrain_cd)
     temp->shift[x].wdrain = (temp->shift[x].wdrain+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), drain_ind = 1,
     temp->shift[x].wdrain_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].wdrain_event_id = c
     .event_id
    ELSEIF (c.event_cd=cdrain_cd)
     temp->shift[x].cdrain = (temp->shift[x].cdrain+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), drain_ind = 1,
     temp->shift[x].cdrain_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].cdrain_event_id = c
     .event_id
    ENDIF
   ENDIF
   IF (diff > 479
    AND diff < 960)
    x = 2
    IF (c.event_cd=ns_cd)
     temp->shift[x].ns = (temp->shift[x].ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5w_cd)
     temp->shift[x].d5w = (temp->shift[x].d5w+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5w_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5w_event_id = c
     .event_id
    ELSEIF (c.event_cd=norm_cd)
     temp->shift[x].norm = (temp->shift[x].norm+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].norm_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].norm_event_id = c
     .event_id
    ELSEIF (c.event_cd=iv_cd)
     temp->shift[x].iv = (temp->shift[x].iv+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].iv_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].iv_event_id = c
     .event_id
    ELSEIF (c.event_cd=lr_cd)
     temp->shift[x].lr = (temp->shift[x].lr+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lr_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lr_event_id = c
     .event_id
    ELSEIF (c.event_cd=kcl_cd)
     temp->shift[x].kcl = (temp->shift[x].kcl+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].kcl_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].kcl_event_id = c
     .event_id
    ELSEIF (c.event_cd=d10w_cd)
     temp->shift[x].d10w = (temp->shift[x].d10w+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d10w_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d10w_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5ns_cd)
     temp->shift[x].d5ns = (temp->shift[x].d5ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=d52ns_cd)
     temp->shift[x].d52ns = (temp->shift[x].d52ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d52ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d52ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=bolus_cd)
     temp->shift[x].bolus = (temp->shift[x].bolus+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].bolus_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].bolus_event_id = c
     .event_id
    ELSEIF (c.event_cd=flush_cd)
     temp->shift[x].flush = (temp->shift[x].flush+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].flush_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].flush_event_id = c
     .event_id
    ELSEIF (c.event_cd=md5_cd)
     temp->shift[x].md5 = (temp->shift[x].md5+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].md5_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].md5_event_id = c
     .event_id
    ELSEIF (c.event_cd=ns20_cd)
     temp->shift[x].ns20 = (temp->shift[x].ns20+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ns20_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ns20_event_id = c
     .event_id
    ELSEIF (c.event_cd=lrd5_cd)
     temp->shift[x].lrd5 = (temp->shift[x].lrd5+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lrd5_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lrd5_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5wns_cd)
     temp->shift[x].d5wns = (temp->shift[x].d5wns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5wns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5wns_event_id = c
     .event_id
    ELSEIF (c.event_cd=45ns_cd)
     temp->shift[x].45ns = (temp->shift[x].45ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].45ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].45ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=las_cd)
     temp->shift[x].las = (temp->shift[x].las+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].las_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].las_event_id = c
     .event_id
    ELSEIF (c.event_cd=nit_cd)
     temp->shift[x].nit = (temp->shift[x].nit+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].nit_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].nit_event_id = c
     .event_id
    ELSEIF (c.event_cd=dop_cd)
     temp->shift[x].dop = (temp->shift[x].dop+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].dop_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].dop_event_id = c
     .event_id
    ELSEIF (c.event_cd=dob_cd)
     temp->shift[x].dob = (temp->shift[x].dob+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].dob_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].dob_event_id = c
     .event_id
    ELSEIF (c.event_cd=lid_cd)
     temp->shift[x].lid = (temp->shift[x].lid+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lid_event_id = c
     .event_id
    ELSEIF (c.event_cd=theo_cd)
     temp->shift[x].theo = (temp->shift[x].theo+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].theo_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].theo_event_id = c
     .event_id
    ELSEIF (c.event_cd=ins_cd)
     temp->shift[x].ins = (temp->shift[x].ins+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ins_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ins_event_id = c
     .event_id
    ELSEIF (c.event_cd=med_cd)
     temp->shift[x].med = (temp->shift[x].med+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].med_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].med_event_id = c
     .event_id
    ELSEIF (c.event_cd=oral_cd)
     temp->shift[x].oral = (temp->shift[x].oral+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), oral_ind = 1,
     temp->shift[x].oral_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].oral_event_id = c
     .event_id
    ELSEIF (c.event_cd=tube_cd)
     temp->shift[x].tube = (temp->shift[x].tube+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), tube_ind = 1,
     temp->shift[x].tube_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].tube_event_id = c
     .event_id
    ELSEIF (c.event_cd=packed_cd)
     temp->shift[x].packed = (temp->shift[x].packed+ cnvtreal(c.event_tag)), temp->shift[x].intotal
      = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].packed_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].packed_event_id = c
     .event_id
    ELSEIF (c.event_cd=plasma_cd)
     temp->shift[x].plasma = (temp->shift[x].plasma+ cnvtreal(c.event_tag)), temp->shift[x].intotal
      = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].plasma_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].plasma_event_id = c
     .event_id
    ELSEIF (c.event_cd=plate_cd)
     temp->shift[x].plate = (temp->shift[x].plate+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].plate_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].plate_event_id = c
     .event_id
    ELSEIF (c.event_cd=blood_cd)
     temp->shift[x].blood = (temp->shift[x].blood+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].blood_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].blood_event_id = c
     .event_id
    ELSEIF (c.event_cd=cbi_cd)
     temp->shift[x].cbi = (temp->shift[x].cbi+ cnvtreal(c.event_tag)), misc_ind = 1, temp->shift[x].
     cbi_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].cbi_event_id = c.event_id
    ELSEIF (c.event_cd=misc_cd)
     temp->shift[x].misc = (temp->shift[x].misc+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), misc_ind = 1,
     temp->shift[x].misc_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].misc_event_id = c
     .event_id
    ELSEIF (c.event_cd=gasflush_cd)
     temp->shift[x].gasflush = (temp->shift[x].gasflush+ cnvtreal(c.event_tag)), temp->shift[x].
     intotal = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), misc_ind = 1,
     temp->shift[x].gasflush_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].gasflush_event_id
      = c.event_id
    ELSEIF (c.event_cd=tpn_cd)
     temp->shift[x].tpn = (temp->shift[x].tpn+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), parent_ind = 1,
     temp->shift[x].tpn_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].tpn_event_id = c
     .event_id
    ELSEIF (c.event_cd=lipid_cd)
     temp->shift[x].lipid = (temp->shift[x].lipid+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), parent_ind = 1,
     temp->shift[x].lipid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lipid_event_id = c
     .event_id
    ELSEIF (c.event_cd=urinef_cd)
     temp->shift[x].urinef = (temp->shift[x].urinef+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urinef_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urinef_event_id = c
     .event_id
    ELSEIF (c.event_cd=urinev_cd)
     temp->shift[x].urinev = (temp->shift[x].urinev+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urinev_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urinev_event_id = c
     .event_id
    ELSEIF (c.event_cd=urine_cd)
     temp->shift[x].urine = (temp->shift[x].urine+ cnvtreal(c.event_tag)), temp->shift[x].outtotal =
     (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urine_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urine_event_id = c
     .event_id
    ELSEIF (c.event_cd=void_cd)
     temp->shift[x].void = (temp->shift[x].void+ cnvtreal(c.event_tag)), urine_ind = 1, temp->shift[x
     ].void_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].void_event_id = c.event_id
    ELSEIF (c.event_cd=drainage_cd)
     temp->shift[x].drainage = (temp->shift[x].drainage+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].drainage_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].drainage_event_id
      = c.event_id
    ELSEIF (c.event_cd=emesis_cd)
     temp->shift[x].emesis = (temp->shift[x].emesis+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].emesis_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].emesis_event_id = c
     .event_id
    ELSEIF (c.event_cd=gasresid_cd)
     temp->shift[x].gasresid = (temp->shift[x].gasresid+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].gasresid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].gasresid_event_id
      = c.event_id
    ELSEIF (c.event_cd=liqstool_cd)
     temp->shift[x].liqstool = (temp->shift[x].liqstool+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), stool_ind = 1,
     temp->shift[x].liqstool_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].liqstool_event_id
      = c.event_id
    ELSEIF (c.event_cd=diaperct_cd)
     temp->shift[x].diaperct = (temp->shift[x].diaperct+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].diaperct_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].diaperct_event_id = c.event_id
    ELSEIF (c.event_cd=diaperwt_cd)
     temp->shift[x].diaperwt = (temp->shift[x].diaperwt+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].diaperwt_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].diaperwt_event_id = c.event_id
    ELSEIF (c.event_cd=ostomy_cd)
     temp->shift[x].ostomy = (temp->shift[x].ostomy+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), stool_ind = 1,
     temp->shift[x].ostomy_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ostomy_event_id = c
     .event_id
    ELSEIF (c.event_cd=stoolcnt_cd)
     temp->shift[x].stoolcnt = (temp->shift[x].stoolcnt+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].stoolcnt_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].stoolcnt_event_id = c.event_id
    ELSEIF (c.event_cd=out_cd)
     temp->shift[x].out = (temp->shift[x].out+ cnvtreal(c.event_tag)), temp->shift[x].outtotal = (
     temp->shift[x].outtotal+ cnvtreal(c.event_tag)), out_ind = 1,
     temp->shift[x].out_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].out_event_id = c
     .event_id
    ELSEIF (c.event_cd=loss_cd)
     temp->shift[x].loss = (temp->shift[x].loss+ cnvtreal(c.event_tag)), temp->shift[x].outtotal = (
     temp->shift[x].outtotal+ cnvtreal(c.event_tag)), out_ind = 1,
     temp->shift[x].loss_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].loss_event_id = c
     .event_id
    ELSEIF (c.event_cd=pad_cd)
     temp->shift[x].pad = (temp->shift[x].pad+ cnvtreal(c.event_tag)), out_ind = 1, temp->shift[x].
     pad_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].pad_event_id = c.event_id
    ELSEIF (c.event_cd=cbiout_cd)
     temp->shift[x].cbiout = (temp->shift[x].cbiout+ cnvtreal(c.event_tag)), out_ind = 1, temp->
     shift[x].cbiout_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].cbiout_event_id = c.event_id
    ELSEIF (c.event_cd=wdrain_cd)
     temp->shift[x].wdrain = (temp->shift[x].wdrain+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), drain_ind = 1,
     temp->shift[x].wdrain_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].wdrain_event_id = c
     .event_id
    ELSEIF (c.event_cd=cdrain_cd)
     temp->shift[x].cdrain = (temp->shift[x].cdrain+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), drain_ind = 1,
     temp->shift[x].cdrain_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].cdrain_event_id = c
     .event_id
    ENDIF
   ENDIF
   IF (diff > 959)
    x = 3
    IF (c.event_cd=ns_cd)
     temp->shift[x].ns = (temp->shift[x].ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5w_cd)
     temp->shift[x].d5w = (temp->shift[x].d5w+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5w_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5w_event_id = c
     .event_id
    ELSEIF (c.event_cd=norm_cd)
     temp->shift[x].norm = (temp->shift[x].norm+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].norm_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].norm_event_id = c
     .event_id
    ELSEIF (c.event_cd=iv_cd)
     temp->shift[x].iv = (temp->shift[x].iv+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].iv_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].iv_event_id = c
     .event_id
    ELSEIF (c.event_cd=lr_cd)
     temp->shift[x].lr = (temp->shift[x].lr+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp->
     shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lr_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lr_event_id = c
     .event_id
    ELSEIF (c.event_cd=kcl_cd)
     temp->shift[x].kcl = (temp->shift[x].kcl+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].kcl_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].kcl_event_id = c
     .event_id
    ELSEIF (c.event_cd=d10w_cd)
     temp->shift[x].d10w = (temp->shift[x].d10w+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d10w_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d10w_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5ns_cd)
     temp->shift[x].d5ns = (temp->shift[x].d5ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=d52ns_cd)
     temp->shift[x].d52ns = (temp->shift[x].d52ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d52ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d52ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=bolus_cd)
     temp->shift[x].bolus = (temp->shift[x].bolus+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].bolus_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].bolus_event_id = c
     .event_id
    ELSEIF (c.event_cd=flush_cd)
     temp->shift[x].flush = (temp->shift[x].flush+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].flush_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].flush_event_id = c
     .event_id
    ELSEIF (c.event_cd=md5_cd)
     temp->shift[x].md5 = (temp->shift[x].md5+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].md5_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].md5_event_id = c
     .event_id
    ELSEIF (c.event_cd=ns20_cd)
     temp->shift[x].ns20 = (temp->shift[x].ns20+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ns20_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ns20_event_id = c
     .event_id
    ELSEIF (c.event_cd=lrd5_cd)
     temp->shift[x].lrd5 = (temp->shift[x].lrd5+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lrd5_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lrd5_event_id = c
     .event_id
    ELSEIF (c.event_cd=d5wns_cd)
     temp->shift[x].d5wns = (temp->shift[x].d5wns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].d5wns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].d5wns_event_id = c
     .event_id
    ELSEIF (c.event_cd=45ns_cd)
     temp->shift[x].45ns = (temp->shift[x].45ns+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].45ns_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].45ns_event_id = c
     .event_id
    ELSEIF (c.event_cd=las_cd)
     temp->shift[x].las = (temp->shift[x].las+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].las_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].las_event_id = c
     .event_id
    ELSEIF (c.event_cd=nit_cd)
     temp->shift[x].nit = (temp->shift[x].nit+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].nit_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].nit_event_id = c
     .event_id
    ELSEIF (c.event_cd=dop_cd)
     temp->shift[x].dop = (temp->shift[x].dop+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].dop_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].dop_event_id = c
     .event_id
    ELSEIF (c.event_cd=dob_cd)
     temp->shift[x].dob = (temp->shift[x].dob+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].dob_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].dob_event_id = c
     .event_id
    ELSEIF (c.event_cd=lid_cd)
     temp->shift[x].lid = (temp->shift[x].lid+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].lid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lid_event_id = c
     .event_id
    ELSEIF (c.event_cd=theo_cd)
     temp->shift[x].theo = (temp->shift[x].theo+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].theo_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].theo_event_id = c
     .event_id
    ELSEIF (c.event_cd=ins_cd)
     temp->shift[x].ins = (temp->shift[x].ins+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].ins_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ins_event_id = c
     .event_id
    ELSEIF (c.event_cd=med_cd)
     temp->shift[x].med = (temp->shift[x].med+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), iv_ind = 1,
     temp->shift[x].med_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].med_event_id = c
     .event_id
    ELSEIF (c.event_cd=oral_cd)
     temp->shift[x].oral = (temp->shift[x].oral+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), oral_ind = 1,
     temp->shift[x].oral_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].oral_event_id = c
     .event_id
    ELSEIF (c.event_cd=tube_cd)
     temp->shift[x].tube = (temp->shift[x].tube+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), tube_ind = 1,
     temp->shift[x].tube_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].tube_event_id = c
     .event_id
    ELSEIF (c.event_cd=packed_cd)
     temp->shift[x].packed = (temp->shift[x].packed+ cnvtreal(c.event_tag)), temp->shift[x].intotal
      = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].packed_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].packed_event_id = c
     .event_id
    ELSEIF (c.event_cd=plasma_cd)
     temp->shift[x].plasma = (temp->shift[x].plasma+ cnvtreal(c.event_tag)), temp->shift[x].intotal
      = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].plasma_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].plasma_event_id = c
     .event_id
    ELSEIF (c.event_cd=plate_cd)
     temp->shift[x].plate = (temp->shift[x].plate+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].plate_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].plate_event_id = c
     .event_id
    ELSEIF (c.event_cd=blood_cd)
     temp->shift[x].blood = (temp->shift[x].blood+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), blood_ind = 1,
     temp->shift[x].blood_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].blood_event_id = c
     .event_id
    ELSEIF (c.event_cd=cbi_cd)
     temp->shift[x].cbi = (temp->shift[x].cbi+ cnvtreal(c.event_tag)), misc_ind = 1, temp->shift[x].
     cbi_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].cbi_event_id = c.event_id
    ELSEIF (c.event_cd=misc_cd)
     temp->shift[x].misc = (temp->shift[x].misc+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), misc_ind = 1,
     temp->shift[x].misc_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].misc_event_id = c
     .event_id
    ELSEIF (c.event_cd=gasflush_cd)
     temp->shift[x].gasflush = (temp->shift[x].gasflush+ cnvtreal(c.event_tag)), temp->shift[x].
     intotal = (temp->shift[x].intotal+ cnvtreal(c.event_tag)), misc_ind = 1,
     temp->shift[x].gasflush_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].gasflush_event_id
      = c.event_id
    ELSEIF (c.event_cd=tpn_cd)
     temp->shift[x].tpn = (temp->shift[x].tpn+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (temp
     ->shift[x].intotal+ cnvtreal(c.event_tag)), parent_ind = 1,
     temp->shift[x].tpn_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].tpn_event_id = c
     .event_id
    ELSEIF (c.event_cd=lipid_cd)
     temp->shift[x].lipid = (temp->shift[x].lipid+ cnvtreal(c.event_tag)), temp->shift[x].intotal = (
     temp->shift[x].intotal+ cnvtreal(c.event_tag)), parent_ind = 1,
     temp->shift[x].lipid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].lipid_event_id = c
     .event_id
    ELSEIF (c.event_cd=urinef_cd)
     temp->shift[x].urinef = (temp->shift[x].urinef+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urinef_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urinef_event_id = c
     .event_id
    ELSEIF (c.event_cd=urinev_cd)
     temp->shift[x].urinev = (temp->shift[x].urinev+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urinev_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urinev_event_id = c
     .event_id
    ELSEIF (c.event_cd=urine_cd)
     temp->shift[x].urine = (temp->shift[x].urine+ cnvtreal(c.event_tag)), temp->shift[x].outtotal =
     (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), urine_ind = 1,
     temp->shift[x].urine_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].urine_event_id = c
     .event_id
    ELSEIF (c.event_cd=void_cd)
     temp->shift[x].void = (temp->shift[x].void+ cnvtreal(c.event_tag)), urine_ind = 1, temp->shift[x
     ].void_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].void_event_id = c.event_id
    ELSEIF (c.event_cd=drainage_cd)
     temp->shift[x].drainage = (temp->shift[x].drainage+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].drainage_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].drainage_event_id
      = c.event_id
    ELSEIF (c.event_cd=emesis_cd)
     temp->shift[x].emesis = (temp->shift[x].emesis+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].emesis_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].emesis_event_id = c
     .event_id
    ELSEIF (c.event_cd=gasresid_cd)
     temp->shift[x].gasresid = (temp->shift[x].gasresid+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), gastric_ind = 1,
     temp->shift[x].gasresid_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].gasresid_event_id
      = c.event_id
    ELSEIF (c.event_cd=liqstool_cd)
     temp->shift[x].liqstool = (temp->shift[x].liqstool+ cnvtreal(c.event_tag)), temp->shift[x].
     outtotal = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), stool_ind = 1,
     temp->shift[x].liqstool_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].liqstool_event_id
      = c.event_id
    ELSEIF (c.event_cd=diaperct_cd)
     temp->shift[x].diaperct = (temp->shift[x].diaperct+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].diaperct_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].diaperct_event_id = c.event_id
    ELSEIF (c.event_cd=diaperwt_cd)
     temp->shift[x].diaperwt = (temp->shift[x].diaperwt+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].diaperwt_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].diaperwt_event_id = c.event_id
    ELSEIF (c.event_cd=ostomy_cd)
     temp->shift[x].ostomy = (temp->shift[x].ostomy+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), stool_ind = 1,
     temp->shift[x].ostomy_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].ostomy_event_id = c
     .event_id
    ELSEIF (c.event_cd=stoolcnt_cd)
     temp->shift[x].stoolcnt = (temp->shift[x].stoolcnt+ cnvtreal(c.event_tag)), stool_ind = 1, temp
     ->shift[x].stoolcnt_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].stoolcnt_event_id = c.event_id
    ELSEIF (c.event_cd=out_cd)
     temp->shift[x].out = (temp->shift[x].out+ cnvtreal(c.event_tag)), temp->shift[x].outtotal = (
     temp->shift[x].outtotal+ cnvtreal(c.event_tag)), out_ind = 1,
     temp->shift[x].out_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].out_event_id = c
     .event_id
    ELSEIF (c.event_cd=loss_cd)
     temp->shift[x].loss = (temp->shift[x].loss+ cnvtreal(c.event_tag)), temp->shift[x].outtotal = (
     temp->shift[x].outtotal+ cnvtreal(c.event_tag)), out_ind = 1,
     temp->shift[x].loss_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].loss_event_id = c
     .event_id
    ELSEIF (c.event_cd=pad_cd)
     temp->shift[x].pad = (temp->shift[x].pad+ cnvtreal(c.event_tag)), out_ind = 1, temp->shift[x].
     pad_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].pad_event_id = c.event_id
    ELSEIF (c.event_cd=cbiout_cd)
     temp->shift[x].cbiout = (temp->shift[x].cbiout+ cnvtreal(c.event_tag)), out_ind = 1, temp->
     shift[x].cbiout_note_ind = btest(c.subtable_bit_map,1),
     temp->shift[x].cbiout_event_id = c.event_id
    ELSEIF (c.event_cd=wdrain_cd)
     temp->shift[x].wdrain = (temp->shift[x].wdrain+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), drain_ind = 1,
     temp->shift[x].wdrain_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].wdrain_event_id = c
     .event_id
    ELSEIF (c.event_cd=cdrain_cd)
     temp->shift[x].cdrain = (temp->shift[x].cdrain+ cnvtreal(c.event_tag)), temp->shift[x].outtotal
      = (temp->shift[x].outtotal+ cnvtreal(c.event_tag)), drain_ind = 1,
     temp->shift[x].cdrain_note_ind = btest(c.subtable_bit_map,1), temp->shift[x].cdrain_event_id = c
     .event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.encntr_id, e.reg_dt_tm, p.name_full_formatted,
  p.birth_dt_tm, pl.name_full_formatted, e.loc_nurse_unit_cd,
  e.loc_room_cd, e.loc_bed_cd, epr.seq
  FROM person p,
   encounter e,
   encntr_prsnl_reltn epr,
   prsnl pl,
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (d3)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (finnbr_cd, encntr_mrn_alias_cd))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), age = cnvtage(cnvtdate(p.birth_dt_tm),curdate), dob
    = datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@SHORTDATE"),
   admitdoc = substring(1,30,pl.name_full_formatted), unit = substring(1,20,uar_get_code_display(e
     .loc_nurse_unit_cd)), room = substring(1,10,uar_get_code_display(e.loc_room_cd)),
   bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)), person_id = e.person_id
  DETAIL
   IF (ea.encntr_alias_type_cd=finnbr_cd)
    finnbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSEIF (ea.encntr_alias_type_cd=encntr_mrn_alias_cd)
    mrn = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
   reg_dt_tm = cnvtdatetime(e.reg_dt_tm)
  WITH nocounter, dontcare = epr, outerjoin = d2,
   outerjoin = d3, dontcare = ea
 ;end select
 IF (mrn <= " ")
  SELECT INTO "nl"
   FROM person_alias pa
   WHERE pa.person_id=person_id
    AND pa.person_alias_type_cd=person_mrn_alias_cd
    AND pa.active_ind=1
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
   WITH nocounter
  ;end select
 ENDIF
 SET modify = nopredeclare
 FOR (y = 1 TO 3)
   IF ((temp->shift[y].ns_note_ind=1))
    SET event_id = temp->shift[y].ns_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].ns_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].d5w_note_ind=1))
    SET event_id = temp->shift[y].d5w_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].d5w_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].norm_note_ind=1))
    SET event_id = temp->shift[y].norm_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].norm_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].iv_note_ind=1))
    SET event_id = temp->shift[y].iv_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].iv_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].lr_note_ind=1))
    SET event_id = temp->shift[y].lr_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].lr_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].kcl_note_ind=1))
    SET event_id = temp->shift[y].kcl_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].kcl_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].d10w_note_ind=1))
    SET event_id = temp->shift[y].d10w_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].d10w_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].d5ns_note_ind=1))
    SET event_id = temp->shift[y].d5ns_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].d5ns_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].d52ns_note_ind=1))
    SET event_id = temp->shift[y].d52ns_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].d52ns_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].bolus_note_ind=1))
    SET event_id = temp->shift[y].bolus_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].bolus_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].flush_note_ind=1))
    SET event_id = temp->shift[y].flush_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].flush_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].md5_note_ind=1))
    SET event_id = temp->shift[y].md5_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].md5_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].ns20_note_ind=1))
    SET event_id = temp->shift[y].ns20_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].ns20_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].lrd5_note_ind=1))
    SET event_id = temp->shift[y].lrd5_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].lrd5_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].d5wns_note_ind=1))
    SET event_id = temp->shift[y].d5wns_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].d5wns_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].45ns_note_ind=1))
    SET event_id = temp->shift[y].45ns_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].45ns_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].las_note_ind=1))
    SET event_id = temp->shift[y].las_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].las_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].nit_note_ind=1))
    SET event_id = temp->shift[y].nit_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].nit_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].dop_note_ind=1))
    SET event_id = temp->shift[y].dop_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].dop_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].dob_note_ind=1))
    SET event_id = temp->shift[y].dob_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].dob_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].lid_note_ind=1))
    SET event_id = temp->shift[y].lid_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].lid_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].theo_note_ind=1))
    SET event_id = temp->shift[y].theo_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].theo_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].ins_note_ind=1))
    SET event_id = temp->shift[y].ins_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].ins_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].med_note_ind=1))
    SET event_id = temp->shift[y].med_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].med_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].oral_note_ind=1))
    SET event_id = temp->shift[y].oral_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].oral_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].tube_note_ind=1))
    SET event_id = temp->shift[y].tube_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].tube_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].packed_note_ind=1))
    SET event_id = temp->shift[y].packed_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].packed_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].plasma_note_ind=1))
    SET event_id = temp->shift[y].plasma_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].plasma_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].plate_note_ind=1))
    SET event_id = temp->shift[y].plate_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].plate_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].blood_note_ind=1))
    SET event_id = temp->shift[y].blood_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].blood_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].cbi_note_ind=1))
    SET event_id = temp->shift[y].cbi_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].cbi_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].misc_note_ind=1))
    SET event_id = temp->shift[y].misc_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].misc_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].gasflush_note_ind=1))
    SET event_id = temp->shift[y].gasflush_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].gasflush_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].tpn_note_ind=1))
    SET event_id = temp->shift[y].tpn_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].tpn_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].lipid_note_ind=1))
    SET event_id = temp->shift[y].lipid_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].lipid_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].urinef_note_ind=1))
    SET event_id = temp->shift[y].urinef_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].urinef_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].urinev_note_ind=1))
    SET event_id = temp->shift[y].urinev_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].urinev_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].urine_note_ind=1))
    SET event_id = temp->shift[y].urine_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].urine_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].void_note_ind=1))
    SET event_id = temp->shift[y].void_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].void_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].drainage_note_ind=1))
    SET event_id = temp->shift[y].drainage_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].drainage_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].emesis_note_ind=1))
    SET event_id = temp->shift[y].emesis_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].emesis_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].gasresid_note_ind=1))
    SET event_id = temp->shift[y].gasresid_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].gasresid_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].liqstool_note_ind=1))
    SET event_id = temp->shift[y].liqstool_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].liqstool_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].diaperct_note_ind=1))
    SET event_id = temp->shift[y].diaperct_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].diaperct_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].diaperwt_note_ind=1))
    SET event_id = temp->shift[y].diaperwt_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].diaperwt_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].ostomy_note_ind=1))
    SET event_id = temp->shift[y].ostomy_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].ostomy_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].stoolcnt_note_ind=1))
    SET event_id = temp->shift[y].stoolcnt_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].stoolcnt_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].out_note_ind=1))
    SET event_id = temp->shift[y].out_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].out_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].loss_note_ind=1))
    SET event_id = temp->shift[y].loss_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].loss_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].pad_note_ind=1))
    SET event_id = temp->shift[y].pad_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].pad_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].cbiout_note_ind=1))
    SET event_id = temp->shift[y].cbiout_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].cbiout_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].wdrain_note_ind=1))
    SET event_id = temp->shift[y].wdrain_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].wdrain_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->shift[y].cdrain_note_ind=1))
    SET event_id = temp->shift[y].cdrain_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->shift[y].cdrain_text = concat(trim(blob_out,3))
   ENDIF
 ENDFOR
 SET modify = predeclare
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{pos/60/55}{f/12}Patient Name:  ", name, row + 1,
   "{pos/60/67}Date of Birth:  ", dob, row + 1,
   "{pos/60/79}Admitting Physician:  ", admitdoc, row + 1,
   xxx = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)), "{pos/320/55}Med Rec Num:  ", mrn,
   row + 1, "{pos/320/67}Age:  ", age,
   row + 1, "{pos/320/79}Location:  ", xxx,
   row + 1, "{pos/320/91}Financial Num: ", finnbr,
   row + 1, "{pos/215/115}{f/13}Intake and Output Summary", row + 1,
   "{pos/215/127}For  ", f = cnvtdatetime(end_dt_tm), u = cnvtdatetime(beg_dt_tm),
   u"mm/dd/yy hh:mm;;d", " - ", f"mm/dd/yy hh:mm;;d",
   row + 1, "{pos/215/129}", p,
   row + 1, "{pos/230/150}{u}0000 - 0759", row + 1,
   "{pos/310/150}{u}0800 - 1559", row + 1, "{pos/390/150}{u}1600 - 2359",
   row + 1, "{pos/470/150}{u}Type Total{f/12}", row + 1
  DETAIL
   xcol = 65, ycol = 165,
   CALL print(calcpos(xcol,ycol)),
   "INTAKE", row + 1, ycol = (ycol+ 12)
   IF (iv_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "IV Fluids",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].d5w) OR (((temp->shift[2].d5w) OR ((temp->shift[3].d5w > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "D5W",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].d5w, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].d5w, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].d5w,
     row + 1, xcol = 450, a = ((temp->shift[1].d5w+ temp->shift[2].d5w)+ temp->shift[3].d5w),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].ns) OR (((temp->shift[2].ns) OR ((temp->shift[3].ns > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "NS",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].ns, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].ns, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].ns,
     row + 1, xcol = 450, a = ((temp->shift[1].ns+ temp->shift[2].ns)+ temp->shift[3].ns),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].norm) OR (((temp->shift[2].norm) OR ((temp->shift[3].norm > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Normal Saline with KCl",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].norm, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].norm, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].norm,
     row + 1, xcol = 450, a = ((temp->shift[1].norm+ temp->shift[2].norm)+ temp->shift[3].norm),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].iv) OR (((temp->shift[2].iv) OR ((temp->shift[3].iv > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "IV Intake",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].iv, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].iv, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].iv,
     row + 1, xcol = 450, a = ((temp->shift[1].iv+ temp->shift[2].iv)+ temp->shift[3].iv),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].lr) OR (((temp->shift[2].lr) OR ((temp->shift[3].lr > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "LR",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].lr, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].lr, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].lr,
     row + 1, xcol = 450, a = ((temp->shift[1].lr+ temp->shift[2].lr)+ temp->shift[3].lr),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].kcl) OR (((temp->shift[2].kcl) OR ((temp->shift[3].kcl > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "D5W with KCl",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].kcl, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].kcl, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].kcl,
     row + 1, xcol = 450, a = ((temp->shift[1].kcl+ temp->shift[2].kcl)+ temp->shift[3].kcl),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].d10w) OR (((temp->shift[2].d10w) OR ((temp->shift[3].d10w > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "D10W",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].d10w, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].d10w, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].d10w,
     row + 1, xcol = 450, a = ((temp->shift[1].d10w+ temp->shift[2].d10w)+ temp->shift[3].d10w),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].d5ns) OR (((temp->shift[2].d5ns) OR ((temp->shift[3].d5ns > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "D5 .45% NS",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].d5ns, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].d5ns, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].d5ns,
     row + 1, xcol = 450, a = ((temp->shift[1].d5ns+ temp->shift[2].d5ns)+ temp->shift[3].d5ns),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].d52ns) OR (((temp->shift[2].d52ns) OR ((temp->shift[3].d52ns > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "D5 .2% NS",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].d52ns, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].d52ns, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].d52ns,
     row + 1, xcol = 450, a = ((temp->shift[1].d52ns+ temp->shift[2].d52ns)+ temp->shift[3].d52ns),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].bolus) OR (((temp->shift[2].bolus) OR ((temp->shift[3].bolus > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "IV Bolus",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].bolus, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].bolus, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].bolus,
     row + 1, xcol = 450, a = ((temp->shift[1].bolus+ temp->shift[2].bolus)+ temp->shift[3].bolus),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].flush) OR (((temp->shift[2].flush) OR ((temp->shift[3].flush > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "IV Flush",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].flush, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].flush, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].flush,
     row + 1, xcol = 450, a = ((temp->shift[1].flush+ temp->shift[2].flush)+ temp->shift[3].flush),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].md5) OR (((temp->shift[2].md5) OR ((temp->shift[3].md5 > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Plasmalyte M D5",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].md5, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].md5, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].md5,
     row + 1, xcol = 450, a = ((temp->shift[1].md5+ temp->shift[2].md5)+ temp->shift[3].md5),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].ns20) OR (((temp->shift[2].ns20) OR ((temp->shift[3].ns20 > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "D5 .45% NS 20 KCl",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].ns20, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].ns20, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].ns20,
     row + 1, xcol = 450, a = ((temp->shift[1].ns20+ temp->shift[2].ns20)+ temp->shift[3].ns20),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].lrd5) OR (((temp->shift[2].lrd5) OR ((temp->shift[3].lrd5 > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "LR D5",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].lrd5, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].lrd5, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].lrd5,
     row + 1, xcol = 450, a = ((temp->shift[1].lrd5+ temp->shift[2].lrd5)+ temp->shift[3].lrd5),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].d5wns) OR (((temp->shift[2].d5wns) OR ((temp->shift[3].d5wns > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "D5WNS",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].d5wns, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].d5wns, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].d5wns,
     row + 1, xcol = 450, a = ((temp->shift[1].d5wns+ temp->shift[2].d5wns)+ temp->shift[3].d5wns),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].45ns) OR (((temp->shift[2].45ns) OR ((temp->shift[3].45ns > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), ".45% NS",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].45ns, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].45ns, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].45ns,
     row + 1, xcol = 450, a = ((temp->shift[1].45ns+ temp->shift[2].45ns)+ temp->shift[3].45ns),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].las) OR (((temp->shift[2].las) OR ((temp->shift[3].las > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Lasix",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].las, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].las, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].las,
     row + 1, xcol = 450, a = ((temp->shift[1].las+ temp->shift[2].las)+ temp->shift[3].las),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].nit) OR (((temp->shift[2].nit) OR ((temp->shift[3].nit > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Nitroglycerine",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].nit, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].nit, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].nit,
     row + 1, xcol = 450, a = ((temp->shift[1].nit+ temp->shift[2].nit)+ temp->shift[3].nit),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].dop) OR (((temp->shift[2].dop) OR ((temp->shift[3].dop > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Dopamine",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].dop, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].dop, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].dop,
     row + 1, xcol = 450, a = ((temp->shift[1].dop+ temp->shift[2].dop)+ temp->shift[3].dop),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].dob) OR (((temp->shift[2].dob) OR ((temp->shift[3].dob > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Dobutamine",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].dob, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].dob, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].dob,
     row + 1, xcol = 450, a = ((temp->shift[1].dob+ temp->shift[2].dob)+ temp->shift[3].dob),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].lid) OR (((temp->shift[2].lid) OR ((temp->shift[3].lid > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Lidocaine",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].lid, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].lid, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].lid,
     row + 1, xcol = 450, a = ((temp->shift[1].lid+ temp->shift[2].lid)+ temp->shift[3].lid),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].theo) OR (((temp->shift[2].theo) OR ((temp->shift[3].theo > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Theophylline",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].theo, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].theo, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].theo,
     row + 1, xcol = 450, a = ((temp->shift[1].theo+ temp->shift[2].theo)+ temp->shift[3].theo),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].ins) OR (((temp->shift[2].ins) OR ((temp->shift[3].ins > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Insulin",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].ins, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].ins, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].ins,
     row + 1, xcol = 450, a = ((temp->shift[1].ins+ temp->shift[2].ins)+ temp->shift[3].ins),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].med) OR (((temp->shift[2].med) OR ((temp->shift[3].med > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Other Medication",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].med, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].med, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].med,
     row + 1, xcol = 450, a = ((temp->shift[1].med+ temp->shift[2].med)+ temp->shift[3].med),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   IF (oral_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Oral Fluids",
    row + 1, ycol = (ycol+ 12), xcol = 95,
    CALL print(calcpos(xcol,ycol)), "Oral Intake", row + 1,
    xcol = 210,
    CALL print(calcpos(xcol,ycol)), temp->shift[1].oral,
    row + 1, xcol = 290,
    CALL print(calcpos(xcol,ycol)),
    temp->shift[2].oral, row + 1, xcol = 370,
    CALL print(calcpos(xcol,ycol)), temp->shift[3].oral, row + 1,
    xcol = 450, a = ((temp->shift[1].oral+ temp->shift[2].oral)+ temp->shift[3].oral),
    CALL print(calcpos(xcol,ycol)),
    a, row + 1, ycol = (ycol+ 12)
   ENDIF
   IF (tube_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Tube Feeding",
    row + 1, ycol = (ycol+ 12), xcol = 95,
    CALL print(calcpos(xcol,ycol)), "Tube Feedings", row + 1,
    xcol = 210,
    CALL print(calcpos(xcol,ycol)), temp->shift[1].tube,
    row + 1, xcol = 290,
    CALL print(calcpos(xcol,ycol)),
    temp->shift[2].tube, row + 1, xcol = 370,
    CALL print(calcpos(xcol,ycol)), temp->shift[3].tube, row + 1,
    xcol = 450, a = ((temp->shift[1].tube+ temp->shift[2].tube)+ temp->shift[3].tube),
    CALL print(calcpos(xcol,ycol)),
    a, row + 1, ycol = (ycol+ 12)
   ENDIF
   IF (blood_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Blood Products",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].packed) OR (((temp->shift[2].packed) OR ((temp->shift[3].packed > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Packed Red Blood Cells",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].packed, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].packed, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].packed,
     row + 1, xcol = 450, a = ((temp->shift[1].packed+ temp->shift[2].packed)+ temp->shift[3].packed),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].plate) OR (((temp->shift[2].plate) OR ((temp->shift[3].plate > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Platelets",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].plate, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].plate, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].plate,
     row + 1, xcol = 450, a = ((temp->shift[1].plate+ temp->shift[2].plate)+ temp->shift[3].plate),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].plasma) OR (((temp->shift[2].plasma) OR ((temp->shift[3].plasma > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Fresh Frozen Plasma",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].plasma, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].plasma, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].plasma,
     row + 1, xcol = 450, a = ((temp->shift[1].plasma+ temp->shift[2].plasma)+ temp->shift[3].plasma),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].blood) OR (((temp->shift[2].blood) OR ((temp->shift[3].blood > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Whole Blood",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].blood, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].blood, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].blood,
     row + 1, xcol = 450, a = ((temp->shift[1].blood+ temp->shift[2].blood)+ temp->shift[3].blood),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   IF (misc_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Miscellaneous Intake",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].misc) OR (((temp->shift[2].misc) OR ((temp->shift[3].misc > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Other Intake",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].misc, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].misc, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].misc,
     row + 1, xcol = 450, a = ((temp->shift[1].misc+ temp->shift[2].misc)+ temp->shift[3].misc),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].gasflush) OR (((temp->shift[2].gasflush) OR ((temp->shift[3].gasflush > 0)
    )) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Gastric Flush",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].gasflush, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].gasflush, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].gasflush,
     row + 1, xcol = 450, a = ((temp->shift[1].gasflush+ temp->shift[2].gasflush)+ temp->shift[3].
     gasflush),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].cbi) OR (((temp->shift[2].cbi) OR ((temp->shift[3].cbi > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "CBI In",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].cbi, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].cbi, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].cbi,
     row + 1, xcol = 450, a = ((temp->shift[1].cbi+ temp->shift[2].cbi)+ temp->shift[3].cbi),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   IF (parent_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Parenteral Nutrition",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].tpn) OR (((temp->shift[2].tpn) OR ((temp->shift[3].tpn > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "TPN",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].tpn, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].tpn, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].tpn,
     row + 1, xcol = 450, a = ((temp->shift[1].tpn+ temp->shift[2].tpn)+ temp->shift[3].tpn),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].lipid) OR (((temp->shift[2].lipid) OR ((temp->shift[3].lipid > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Lipids",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].lipid, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].lipid, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].lipid,
     row + 1, xcol = 450, a = ((temp->shift[1].lipid+ temp->shift[2].lipid)+ temp->shift[3].lipid),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   xcol = 65,
   CALL print(calcpos(xcol,ycol)), "{f/13}TOTAL INTAKE",
   row + 1, xcol = 210,
   CALL print(calcpos(xcol,ycol)),
   temp->shift[1].intotal, row + 1, xcol = 290,
   CALL print(calcpos(xcol,ycol)), temp->shift[2].intotal, row + 1,
   xcol = 370,
   CALL print(calcpos(xcol,ycol)), temp->shift[3].intotal,
   row + 1, b = ((temp->shift[1].intotal+ temp->shift[2].intotal)+ temp->shift[3].intotal), xcol =
   450,
   CALL print(calcpos(xcol,ycol)), b, row + 1,
   ycol = (ycol+ 12), xcol = 65, "{f/12}",
   row + 1,
   CALL print(calcpos(xcol,ycol)), "OUTPUT",
   row + 1, ycol = (ycol+ 12)
   IF (urine_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Urine",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].urinef) OR (((temp->shift[2].urinef) OR ((temp->shift[3].urinef > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Urine Foley",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].urinef, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].urinef, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].urinef,
     row + 1, xcol = 450, a = ((temp->shift[1].urinef+ temp->shift[2].urinef)+ temp->shift[3].urinef),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].urinev) OR (((temp->shift[2].urinev) OR ((temp->shift[3].urinev > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Urine Voided",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].urinev, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].urinev, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].urinev,
     row + 1, xcol = 450, a = ((temp->shift[1].urinev+ temp->shift[2].urinev)+ temp->shift[3].urinev),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].urine) OR (((temp->shift[2].urine) OR ((temp->shift[3].urine > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Urine",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].urine, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].urine, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].urine,
     row + 1, xcol = 450, a = ((temp->shift[1].urine+ temp->shift[2].urine)+ temp->shift[3].urine),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].void) OR (((temp->shift[2].void) OR ((temp->shift[3].void > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "# of Voids",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].void, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].void, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].void,
     row + 1, xcol = 450, a = ((temp->shift[1].void+ temp->shift[2].void)+ temp->shift[3].void),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   IF (drain_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Drains",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].wdrain) OR (((temp->shift[2].wdrain) OR ((temp->shift[3].wdrain > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Wound Drainage",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].wdrain, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].wdrain, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].wdrain,
     row + 1, xcol = 450, a = ((temp->shift[1].wdrain+ temp->shift[2].wdrain)+ temp->shift[3].wdrain),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].cdrain) OR (((temp->shift[2].cdrain) OR ((temp->shift[3].cdrain > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Chest Tube Drainage",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].cdrain, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].cdrain, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].cdrain,
     row + 1, xcol = 450, a = ((temp->shift[1].cdrain+ temp->shift[2].cdrain)+ temp->shift[3].cdrain),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   IF (gastric_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Gastric Output",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].emesis) OR (((temp->shift[2].emesis) OR ((temp->shift[3].emesis > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Emesis",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].emesis, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].emesis, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].emesis,
     row + 1, xcol = 450, a = ((temp->shift[1].emesis+ temp->shift[2].emesis)+ temp->shift[3].emesis),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].drainage) OR (((temp->shift[2].drainage) OR ((temp->shift[3].drainage > 0)
    )) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "NG Drainage",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].drainage, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].drainage, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].drainage,
     row + 1, xcol = 450, a = ((temp->shift[1].drainage+ temp->shift[2].drainage)+ temp->shift[3].
     drainage),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].gasresid) OR (((temp->shift[2].gasresid) OR ((temp->shift[3].gasresid > 0)
    )) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Gastric Residual",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].gasresid, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].gasresid, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].gasresid,
     row + 1, xcol = 450, a = ((temp->shift[1].gasresid+ temp->shift[2].gasresid)+ temp->shift[3].
     gasresid),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   IF (stool_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Stool Output",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].stoolcnt) OR (((temp->shift[2].stoolcnt) OR ((temp->shift[3].stoolcnt > 0)
    )) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Stool Count",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].stoolcnt, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].stoolcnt, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].stoolcnt,
     row + 1, xcol = 450, a = ((temp->shift[1].stoolcnt+ temp->shift[2].stoolcnt)+ temp->shift[3].
     stoolcnt),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].ostomy) OR (((temp->shift[2].ostomy) OR ((temp->shift[3].ostomy > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Ostomy Output",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].ostomy, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].ostomy, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].ostomy,
     row + 1, xcol = 450, a = ((temp->shift[1].ostomy+ temp->shift[2].ostomy)+ temp->shift[3].ostomy),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].liqstool) OR (((temp->shift[2].liqstool) OR ((temp->shift[3].liqstool > 0)
    )) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Liquid Stool",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].liqstool, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].liqstool, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].liqstool,
     row + 1, xcol = 450, a = ((temp->shift[1].liqstool+ temp->shift[2].liqstool)+ temp->shift[3].
     liqstool),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].diaperct) OR (((temp->shift[2].diaperct) OR ((temp->shift[3].diaperct > 0)
    )) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Diaper Count",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].diaperct, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].diaperct, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].diaperct,
     row + 1, xcol = 450, a = ((temp->shift[1].diaperct+ temp->shift[2].diaperct)+ temp->shift[3].
     diaperct),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].diaperwt) OR (((temp->shift[2].diaperwt) OR ((temp->shift[3].diaperwt > 0)
    )) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Diaper Weight",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].diaperwt, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].diaperwt, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].diaperwt,
     row + 1, xcol = 450, a = ((temp->shift[1].diaperwt+ temp->shift[2].diaperwt)+ temp->shift[3].
     diaperwt),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   IF (out_ind=1)
    xcol = 80,
    CALL print(calcpos(xcol,ycol)), "Miscellaneous Output",
    row + 1, ycol = (ycol+ 12)
    IF (((temp->shift[1].out) OR (((temp->shift[2].out) OR ((temp->shift[3].out > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Other Output",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].out, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].out, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].out,
     row + 1, xcol = 450, a = ((temp->shift[1].out+ temp->shift[2].out)+ temp->shift[3].out),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].pad) OR (((temp->shift[2].pad) OR ((temp->shift[3].pad > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Pad Count",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].pad, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].pad, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].pad,
     row + 1, xcol = 450, a = ((temp->shift[1].pad+ temp->shift[2].pad)+ temp->shift[3].pad),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].loss) OR (((temp->shift[2].loss) OR ((temp->shift[3].loss > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "Blood Loss",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].loss, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].loss, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].loss,
     row + 1, xcol = 450, a = ((temp->shift[1].loss+ temp->shift[2].loss)+ temp->shift[3].loss),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
    IF (((temp->shift[1].cbiout) OR (((temp->shift[2].cbiout) OR ((temp->shift[3].cbiout > 0))) )) )
     xcol = 95,
     CALL print(calcpos(xcol,ycol)), "CBI Out",
     row + 1, xcol = 210,
     CALL print(calcpos(xcol,ycol)),
     temp->shift[1].cbiout, row + 1, xcol = 290,
     CALL print(calcpos(xcol,ycol)), temp->shift[2].cbiout, row + 1,
     xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->shift[3].cbiout,
     row + 1, xcol = 450, a = ((temp->shift[1].cbiout+ temp->shift[2].cbiout)+ temp->shift[3].cbiout),
     CALL print(calcpos(xcol,ycol)), a, row + 1,
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   xcol = 65,
   CALL print(calcpos(xcol,ycol)), "{f/13}TOTAL OUTPUT",
   row + 1, xcol = 210,
   CALL print(calcpos(xcol,ycol)),
   temp->shift[1].outtotal, row + 1, xcol = 290,
   CALL print(calcpos(xcol,ycol)), temp->shift[2].outtotal, row + 1,
   xcol = 370,
   CALL print(calcpos(xcol,ycol)), temp->shift[3].outtotal,
   row + 1, c = ((temp->shift[1].outtotal+ temp->shift[2].outtotal)+ temp->shift[3].outtotal), xcol
    = 450,
   CALL print(calcpos(xcol,ycol)), c, row + 1,
   ycol = (ycol+ 12), xcol = 65,
   CALL print(calcpos(xcol,ycol)),
   "BALANCE", row + 1, xcol = 210,
   z = (temp->shift[1].intotal - temp->shift[1].outtotal),
   CALL print(calcpos(xcol,ycol)), z,
   row + 1, xcol = 290, z = (temp->shift[2].intotal - temp->shift[2].outtotal),
   CALL print(calcpos(xcol,ycol)), z, row + 1,
   xcol = 370, z = (temp->shift[3].intotal - temp->shift[3].outtotal),
   CALL print(calcpos(xcol,ycol)),
   z, row + 1, xcol = 450,
   z = (b - c),
   CALL print(calcpos(xcol,ycol)), z,
   row + 1, ycol = (ycol+ 24), xcol = 65,
   CALL print(calcpos(xcol,ycol)), "TOTAL FLUID BALANCE", row + 1,
   xcol = 180,
   CALL print(calcpos(xcol,ycol)), z,
   row + 1, ycol = (ycol+ 24)
   FOR (y = 1 TO 3)
     "{cpi/16}{f/8}", row + 1
     IF ((temp->shift[y].d5w_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "D5W comment: ",
      temp->shift[y].d5w_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].ns_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "NS comment: ",
      temp->shift[y].ns_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].norm_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Normal Saline with KCl comment: ",
      temp->shift[y].norm_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].iv_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "IV Intake comment: ",
      temp->shift[y].iv_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].lr_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "LR comment: ",
      temp->shift[y].lr_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].kcl_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "D5W with KCl comment: ",
      temp->shift[y].kcl_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].d10w_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "D10W comment: ",
      temp->shift[y].d10w_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].d5ns_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "D5 .45% NS comment: ",
      temp->shift[y].d5ns_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].d52ns_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "D5 .2% NS comment: ",
      temp->shift[y].d52ns_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].bolus_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "IV Bolus comment: ",
      temp->shift[y].bolus_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].flush_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "IV Flush comment: ",
      temp->shift[y].flush_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].md5_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Plasmalyte M D5 comment: ",
      temp->shift[y].md5_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].ns20_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "D5 .45% NS 20 KCl comment: ",
      temp->shift[y].ns20_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].lrd5_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "LR D5 comment: ",
      temp->shift[y].lrd5_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].d5wns_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "D5WNS comment: ",
      temp->shift[y].d5wns_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].45ns_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), ".45% NS comment: ",
      temp->shift[y].45ns_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].las_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Lasix comment: ",
      temp->shift[y].las_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].nit_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Nitroglycerine comment: ",
      temp->shift[y].nit_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].dop_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Dopamine comment: ",
      temp->shift[y].dop_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].dob_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Dobutamine comment: ",
      temp->shift[y].dob_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].lid_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Lidocaine comment: ",
      temp->shift[y].lid_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].theo_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Theophylline comment: ",
      temp->shift[y].theo_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].ins_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Insulin comment: ",
      temp->shift[y].ins_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].med_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Other Medication comment: ",
      temp->shift[y].med_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].oral_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Oral Intake comment: ",
      temp->shift[y].oral_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].tube_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Tube Feedings comment: ",
      temp->shift[y].tube_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].packed_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Packed Red Blood Cells comment: ",
      temp->shift[y].packed_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].plate_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Platelets comment: ",
      temp->shift[y].plate_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].plasma_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Fresh Frozen Plasma comment: ",
      temp->shift[y].plasma_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].blood_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Whole Blood comment: ",
      temp->shift[y].blood_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].misc_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Other Intake comment: ",
      temp->shift[y].misc_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].gasflush_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Gastric Flush comment: ",
      temp->shift[y].gasflush_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].cbi_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "CBI In comment: ",
      temp->shift[y].cbi_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].tpn_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "TPN comment: ",
      temp->shift[y].tpn_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].lipid_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Lipids comment: ",
      temp->shift[y].lipid_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].urinef_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Urine Foley comment: ",
      temp->shift[y].urinef_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].urinev_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Urine Voided comment: ",
      temp->shift[y].urinev_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].urine_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Urine comment: ",
      temp->shift[y].urine_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].void_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "# of Voids comment: ",
      temp->shift[y].void_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].wdrain_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Wound Drainage comment: ",
      temp->shift[y].wdrain_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].cdrain_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Chest Tube Drainage comment: ",
      temp->shift[y].cdrain_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].emesis_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Emesis comment: ",
      temp->shift[y].emesis_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].drainage_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "NG Drainage comment: ",
      temp->shift[y].drainage_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].gasresid_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Gastric Residual comment: ",
      temp->shift[y].gasresid_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].stoolcnt_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Stool Count comment: ",
      temp->shift[y].stoolcnt_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].ostomy_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Ostomy Output comment: ",
      temp->shift[y].ostomy_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].liqstool_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Liquid Stool comment: ",
      temp->shift[y].liqstool_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].diaperct_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Diaper Count comment: ",
      temp->shift[y].diaperct_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].diaperwt_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Diaper Weight comment: ",
      temp->shift[y].diaperwt_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].out_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Other Output comment: ",
      temp->shift[y].out_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].pad_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Pad Count comment: ",
      temp->shift[y].pad_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].loss_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Blood Loss comment: ",
      temp->shift[y].loss_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->shift[y].cbiout_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "CBI Out comment: ",
      temp->shift[y].cbiout_text, row + 1, ycol = (ycol+ 12)
     ENDIF
   ENDFOR
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}{cpi/16}Page", curpage, row + 1,
   xcol = 310,
   CALL print(calcpos(xcol,ycol)), curdate,
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 750
 ;end select
 GO TO exit_program
#report_failed
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{pos/215/115}{f/13}Intake and Output Summary", row + 3,
   "{pos/60/55}{f/12}Report Failed: Invalid encounter Id used(",
   request->visit[1].encntr_id, ").", row + 1
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}{cpi/16}Page", curpage, row + 1,
   xcol = 310,
   CALL print(calcpos(xcol,ycol)), curdate,
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 750
 ;end select
 GO TO exit_program
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
    blob_ret_len = 0,
    CALL uar_ocf_uncompress(lb.long_blob,textlen(lb.long_blob),blob_out,32000,blob_ret_len)
   ELSE
    blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),
     lb.long_blob)
   ENDIF
   CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2
  WITH nocounter
 ;end select
#get_note_end
#exit_program
END GO
