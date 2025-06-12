CREATE PROGRAM cern_dcp_rpt_kardex:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 activity_type = vc
     2 cnt = i2
     2 qual[*]
       3 order_id = f8
       3 iv_ind = i2
       3 date = vc
       3 status = vc
       3 mnemonic = vc
       3 m_cnt = i2
       3 m_qual[*]
         4 m_line = vc
       3 display_line = vc
       3 disp_cnt = i2
       3 disp_qual[*]
         4 disp_line = vc
       3 comment_ind = i2
       3 comment = vc
       3 c_cnt = i2
       3 c_qual[*]
         4 c_line = vc
       3 oe_format_id = f8
       3 clin_line_ind = i2
       3 stat_ind = i2
       3 d_cnt = i2
       3 d_qual[*]
         4 field_description = vc
         4 label_text = vc
         4 value = vc
         4 field_value = f8
         4 oe_field_meaning_id = f8
         4 group_seq = i4
         4 print_ind = i2
         4 clin_line_ind = i2
         4 label = vc
         4 suffix = i2
 )
 RECORD allergy(
   1 cnt = i2
   1 qual[*]
     2 list = vc
   1 line = vc
   1 line_cnt = i2
   1 line_qual[*]
     2 line = vc
 )
 RECORD diag(
   1 cnt = i2
   1 qual[*]
     2 list = vc
   1 line = vc
   1 line_cnt = i2
   1 line_qual[*]
     2 line = vc
   1 reason = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET modify = predeclare
 DECLARE age = vc WITH noconstant(fillstring(15," "))
 DECLARE dob = vc WITH noconstant(fillstring(15," "))
 DECLARE sex = vc WITH noconstant(fillstring(40," "))
 DECLARE mrn = vc WITH noconstant(fillstring(20," "))
 DECLARE fnbr = vc WITH noconstant(fillstring(20," "))
 DECLARE admit_dt = vc WITH noconstant(fillstring(20," "))
 DECLARE date = vc WITH noconstant(fillstring(30," "))
 DECLARE attenddoc = vc WITH noconstant(fillstring(30," "))
 DECLARE name = vc WITH noconstant(fillstring(30," "))
 DECLARE unit = vc WITH noconstant(fillstring(20," "))
 DECLARE room = vc WITH noconstant(fillstring(20," "))
 DECLARE bed = vc WITH noconstant(fillstring(20," "))
 DECLARE location = vc WITH noconstant(fillstring(50," "))
 DECLARE person_id = f8 WITH noconstant(0.0)
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE lf = c2 WITH private, constant(concat(char(13),char(10)))
 DECLARE beg_ind = i2 WITH noconstant(0)
 DECLARE end_ind = i2 WITH noconstant(0)
 DECLARE beg_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE end_dt_tm = q8 WITH noconstant(cnvtdatetime(curdate,curtime))
 DECLARE x2 = c2 WITH noconstant("  ")
 DECLARE x3 = c3 WITH noconstant("   ")
 DECLARE abc = vc WITH noconstant(fillstring(25," "))
 DECLARE xyz = c20 WITH noconstant("  -   -       :  :  ")
 DECLARE ops_ind = c1 WITH noconstant("N")
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE encntr_mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE person_mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE finnbr_cd = f8 WITH noconstant(0.0)
 DECLARE attend_doc_cd = f8 WITH noconstant(0.0)
 DECLARE canceled_cd = f8 WITH noconstant(0.0)
 DECLARE ordered_cd = f8 WITH noconstant(0.0)
 DECLARE inprocess_cd = f8 WITH noconstant(0.0)
 DECLARE future_cd = f8 WITH noconstant(0.0)
 DECLARE pharmacy_cd = f8 WITH noconstant(0.0)
 DECLARE iv_cd = f8 WITH noconstant(0.0)
 DECLARE ord_cd = f8 WITH noconstant(0.0)
 DECLARE max_length = i4 WITH noconstant(0)
 DECLARE mnem_disp_level = c1 WITH noconstant("1")
 DECLARE iv_disp_level = c1 WITH noconstant("0")
 DECLARE a = i2 WITH noconstant(0)
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 DECLARE started_build_ind = i2 WITH protect, noconstant(0)
 IF ((request->visit[1].encntr_id <= 0))
  GO TO report_failed
 ENDIF
 IF ((request->batch_selection > " "))
  SET ops_ind = "Y"
 ENDIF
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
 IF (((end_ind=0) OR (beg_ind=0)) )
  IF (ops_ind="Y")
   SET beg_dt_tm = cnvtdatetime((curdate - 1),0)
   SET end_dt_tm = cnvtdatetime(curdate,0)
  ELSE
   SET beg_dt_tm = cnvtdatetime(curdate,0)
   SET end_dt_tm = cnvtdatetime(curdate,curtime)
  ENDIF
 ENDIF
 SET person_mrn_alias_cd = uar_get_code_by("MEANING",4,"MRN")
 SET encntr_mrn_alias_cd = uar_get_code_by("MEANING",319,"MRN")
 SET finnbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET attend_doc_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 SET canceled_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 SET ordered_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET inprocess_cd = uar_get_code_by("MEANING",6004,"INPROCESS")
 SET future_cd = uar_get_code_by("MEANING",6004,"FUTURE")
 SET pharmacy_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET iv_cd = uar_get_code_by("MEANING",16389,"IVSOLUTIONS")
 SET ord_cd = uar_get_code_by("MEANING",14,"ORD COMMENT")
 SELECT INTO "NL:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl,
   encntr_loc_hist elh,
   time_zone_r t
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (t
   WHERE t.parent_entity_id=outerjoin(elh.loc_facility_cd)
    AND t.parent_entity_name=outerjoin("LOCATION"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (finnbr_cd, encntr_mrn_alias_cd)
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),3), dob = concat(format(datetimezone(p
      .birth_dt_tm,p.birth_tz),"mm/dd/yyyy;;d")," ",datetimezonebyindex(p.birth_tz,offset,daylight,7,
     p.birth_dt_tm)), tz_index = datetimezonebyname(trim(t.time_zone)),
   admit_dt = trim(concat(format(datetimezone(e.reg_dt_tm,tz_index),"mm-dd-yyyy;3;q")," ",
     datetimezonebyindex(tz_index,offset,daylight,7,e.reg_dt_tm))), name = substring(1,30,p
    .name_full_formatted), sex = substring(1,40,uar_get_code_display(p.sex_cd)),
   attenddoc = substring(1,30,pl.name_full_formatted), unit = substring(1,20,uar_get_code_display(e
     .loc_nurse_unit_cd)), room = substring(1,10,uar_get_code_display(e.loc_room_cd)),
   bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)), location = concat(trim(unit),"/",trim(
     room),"/",trim(bed)), date = trim(concat(format(datetimezone(e.reg_dt_tm,tz_index),
      "mm-dd-yyyy;3;q")," ",datetimezonebyindex(tz_index,offset,daylight,7,e.reg_dt_tm))),
   person_id = e.person_id, encntr_id = e.encntr_id, diag->reason = e.reason_for_visit
  DETAIL
   IF (ea.encntr_alias_type_cd=finnbr_cd)
    fnbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSEIF (ea.encntr_alias_type_cd=encntr_mrn_alias_cd)
    mrn = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
 ;end select
 IF (mrn <= " ")
  SELECT INTO "nl:"
   FROM person_alias pa
   WHERE pa.person_id=person_id
    AND pa.person_alias_type_cd=person_mrn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM allergy a,
   (dummyt d  WITH seq = 1),
   nomenclature n
  PLAN (a
   WHERE a.person_id=person_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    allergy->cnt = (allergy->cnt+ 1), stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[
    allergy->cnt].list = a.substance_ftdesc
    IF (n.source_string > " ")
     allergy->qual[allergy->cnt].list = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = n
 ;end select
 FOR (x = 1 TO allergy->cnt)
   IF (x=1)
    SET allergy->line = allergy->qual[x].list
   ELSE
    SET allergy->line = concat(trim(allergy->line),", ",trim(allergy->qual[x].list))
   ENDIF
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 100
 SET modify = nopredeclare
 EXECUTE dcp_parse_text value(allergy->line), value(max_length)
 SET modify = predeclare
 SET stat = alterlist(allergy->line_qual,pt->line_cnt)
 SET allergy->line_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET allergy->line_qual[x].line = pt->lns[x].line
 ENDFOR
 SELECT INTO "nl:"
  FROM diagnosis d,
   (dummyt d1  WITH seq = 1),
   nomenclature n
  PLAN (d
   WHERE d.encntr_id=encntr_id
    AND d.active_ind=1)
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  HEAD REPORT
   diag->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (d.diag_ftdesc > " ")) )
    diag->cnt = (diag->cnt+ 1), stat = alterlist(diag->qual,diag->cnt), diag->qual[diag->cnt].list =
    d.diag_ftdesc
    IF (n.source_string > " ")
     diag->qual[diag->cnt].list = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = n
 ;end select
 FOR (x = 1 TO diag->cnt)
   IF (x=1)
    SET diag->line = diag->qual[x].list
   ELSE
    SET diag->line = concat(trim(diag->line),", ",trim(diag->qual[x].list))
   ENDIF
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 100
 SET modify = nopredeclare
 EXECUTE dcp_parse_text value(diag->line), value(max_length)
 SET modify = predeclare
 SET stat = alterlist(diag->line_qual,pt->line_cnt)
 SET diag->line_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET diag->line_qual[x].line = pt->lns[x].line
 ENDFOR
 SELECT INTO "nl:"
  FROM name_value_prefs n,
   app_prefs a
  PLAN (n
   WHERE n.pvc_name IN ("MNEM_DISP_LEVEL", "IV_DISP_LEVEL"))
   JOIN (a
   WHERE a.app_prefs_id=n.parent_entity_id
    AND a.prsnl_id=0
    AND a.position_cd=0)
  DETAIL
   IF (n.pvc_name="MNEM_DISP_LEVEL"
    AND n.pvc_value IN ("0", "1", "2"))
    mnem_disp_level = n.pvc_value
   ELSEIF (n.pvc_name="IV_DISP_LEVEL"
    AND n.pvc_value IN ("0", "1"))
    iv_disp_level = n.pvc_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.order_status_cd IN (ordered_cd, inprocess_cd, future_cd)
    AND o.template_order_flag IN (0, 1))
  ORDER BY o.activity_type_cd, cnvtdatetime(o.orig_order_dt_tm)
  HEAD REPORT
   temp->cnt = 0, cnt = 0
  HEAD o.activity_type_cd
   cnt = 0, temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt),
   temp->qual[temp->cnt].activity_type = uar_get_code_display(o.activity_type_cd)
  DETAIL
   cnt = (cnt+ 1), temp->qual[temp->cnt].cnt = cnt, stat = alterlist(temp->qual[temp->cnt].qual,cnt),
   temp->qual[temp->cnt].qual[cnt].date = concat(format(datetimezone(o.orig_order_dt_tm,o
      .orig_order_tz),"mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(o.orig_order_tz,offset,daylight,7,
     o.orig_order_dt_tm)), temp->qual[temp->cnt].qual[cnt].status = uar_get_code_display(o
    .order_status_cd), temp->qual[temp->cnt].qual[cnt].display_line = o.clinical_display_line,
   temp->qual[temp->cnt].qual[cnt].oe_format_id = o.oe_format_id
   IF (substring(245,10,o.clinical_display_line) > "  ")
    temp->qual[temp->cnt].qual[cnt].clin_line_ind = 1
   ELSE
    temp->qual[temp->cnt].qual[cnt].clin_line_ind = 0
   ENDIF
   temp->qual[temp->cnt].qual[cnt].order_id = o.order_id, temp->qual[temp->cnt].qual[cnt].iv_ind = o
   .iv_ind
   IF (o.dcp_clin_cat_cd=iv_cd)
    temp->qual[temp->cnt].qual[cnt].iv_ind = 1
   ENDIF
   temp->qual[temp->cnt].qual[cnt].mnemonic = o.hna_order_mnemonic
   IF (o.catalog_type_cd=pharmacy_cd)
    IF (mnem_disp_level="0")
     temp->qual[temp->cnt].qual[cnt].mnemonic = trim(o.hna_order_mnemonic)
    ENDIF
    IF (mnem_disp_level="1")
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
      temp->qual[temp->cnt].qual[cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      temp->qual[temp->cnt].qual[cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
        .ordered_as_mnemonic),")")
     ENDIF
    ENDIF
    IF (mnem_disp_level="2"
     AND o.iv_ind != 1)
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
      temp->qual[temp->cnt].qual[cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      temp->qual[temp->cnt].qual[cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
        .ordered_as_mnemonic),")")
     ENDIF
     IF (o.order_mnemonic != o.ordered_as_mnemonic
      AND o.order_mnemonic > " ")
      temp->qual[temp->cnt].qual[cnt].mnemonic = concat(trim(temp->qual[temp->cnt].qual[cnt].mnemonic
        ),"(",trim(o.order_mnemonic),")")
     ENDIF
    ENDIF
   ENDIF
   temp->qual[temp->cnt].qual[cnt].comment_ind = o.order_comment_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO print_report
 ENDIF
 FOR (y = 1 TO temp->cnt)
   FOR (z = 1 TO temp->qual[y].cnt)
     IF ((temp->qual[y].qual[z].iv_ind=1))
      SELECT INTO "nl:"
       FROM order_ingredient oi
       PLAN (oi
        WHERE (oi.order_id=temp->qual[y].qual[z].order_id))
       ORDER BY oi.action_sequence, oi.comp_sequence
       HEAD oi.action_sequence
        mnemonic_line = fillstring(1000," "), first_time = "Y"
       DETAIL
        IF (first_time="Y")
         IF (oi.ordered_as_mnemonic > " ")
          mnemonic_line = concat(trim(oi.ordered_as_mnemonic),", ",trim(oi.order_detail_display_line)
           )
         ELSE
          mnemonic_line = concat(trim(oi.order_mnemonic),", ",trim(oi.order_detail_display_line))
         ENDIF
         first_time = "N"
        ELSE
         IF (oi.ordered_as_mnemonic > " ")
          mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),", ",trim(oi
            .order_detail_display_line))
         ELSE
          mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),", ",trim(oi
            .order_detail_display_line))
         ENDIF
        ENDIF
       FOOT REPORT
        temp->qual[y].qual[z].mnemonic = mnemonic_line
       WITH nocounter
      ;end select
     ENDIF
     IF ((temp->qual[y].qual[z].clin_line_ind=1))
      SELECT INTO "nl:"
       FROM order_detail od,
        order_entry_fields of1,
        oe_format_fields oef
       PLAN (od
        WHERE (temp->qual[y].qual[z].order_id=od.order_id))
        JOIN (oef
        WHERE (oef.oe_format_id=temp->qual[y].qual[z].oe_format_id)
         AND oef.oe_field_id=od.oe_field_id)
        JOIN (of1
        WHERE of1.oe_field_id=oef.oe_field_id)
       ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
       HEAD REPORT
        temp->qual[y].qual[z].d_cnt = 0
       HEAD od.order_id
        stat = alterlist(temp->qual[y].qual[z].d_qual,5), temp->qual[y].qual[z].stat_ind = 0
       HEAD od.oe_field_id
        act_seq = od.action_sequence, odflag = 1
       HEAD od.action_sequence
        IF (act_seq != od.action_sequence)
         odflag = 0
        ENDIF
       DETAIL
        IF (odflag=1)
         temp->qual[y].qual[z].d_cnt = (temp->qual[y].qual[z].d_cnt+ 1), dc = temp->qual[y].qual[z].
         d_cnt
         IF (dc > size(temp->qual[y].qual[z].d_qual,5))
          stat = alterlist(temp->qual[y].qual[z].d_qual,(dc+ 5))
         ENDIF
         temp->qual[y].qual[z].d_qual[dc].label_text = trim(oef.label_text), temp->qual[y].qual[z].
         d_qual[dc].field_value = od.oe_field_value, temp->qual[y].qual[z].d_qual[dc].group_seq = oef
         .group_seq,
         temp->qual[y].qual[z].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, temp->qual[y]
         .qual[z].d_qual[dc].value = trim(od.oe_field_display_value), temp->qual[y].qual[z].d_qual[dc
         ].clin_line_ind = oef.clin_line_ind,
         temp->qual[y].qual[z].d_qual[dc].label = trim(oef.clin_line_label), temp->qual[y].qual[z].
         d_qual[dc].suffix = oef.clin_suffix_ind
         IF (od.oe_field_display_value > " ")
          temp->qual[y].qual[z].d_qual[dc].print_ind = 0
         ELSE
          temp->qual[y].qual[z].d_qual[dc].print_ind = 1
         ENDIF
         IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od
         .oe_field_meaning_id=127) OR (od.oe_field_meaning_id=43)) )) ))
          AND trim(cnvtupper(od.oe_field_display_value))="STAT")
          temp->qual[y].qual[z].stat_ind = 1
         ENDIF
         IF (of1.field_type_flag=7)
          IF (od.oe_field_value=1)
           IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=1)) )
            temp->qual[y].qual[z].d_qual[dc].value = trim(oef.label_text)
           ELSE
            temp->qual[y].qual[z].d_qual[dc].clin_line_ind = 0
           ENDIF
          ELSE
           IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=2)) )
            temp->qual[y].qual[z].d_qual[dc].value = trim(oef.clin_line_label)
           ELSE
            temp->qual[y].qual[z].d_qual[dc].clin_line_ind = 0
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       FOOT  od.order_id
        stat = alterlist(temp->qual[y].qual[z].d_qual,dc)
       WITH nocounter
      ;end select
      SET started_build_ind = 0
      FOR (fsub = 1 TO 31)
        FOR (xx = 1 TO temp->qual[y].qual[z].d_cnt)
          IF ((((temp->qual[y].qual[z].d_qual[xx].group_seq=fsub)) OR (fsub=31))
           AND (temp->qual[y].qual[z].d_qual[xx].print_ind=0))
           SET temp->qual[y].qual[z].d_qual[xx].print_ind = 1
           IF ((temp->qual[y].qual[z].d_qual[xx].clin_line_ind=1))
            IF (started_build_ind=0)
             SET started_build_ind = 1
             IF ((temp->qual[y].qual[z].d_qual[xx].suffix=0)
              AND (temp->qual[y].qual[z].d_qual[xx].label > "  "))
              SET temp->qual[y].qual[z].display_line = concat(trim(temp->qual[y].qual[z].d_qual[xx].
                label)," ",trim(temp->qual[y].qual[z].d_qual[xx].value))
             ELSEIF ((temp->qual[y].qual[z].d_qual[xx].suffix=1)
              AND (temp->qual[y].qual[z].d_qual[xx].label > " "))
              SET temp->qual[y].qual[z].display_line = concat(trim(temp->qual[y].qual[z].d_qual[xx].
                value)," ",trim(temp->qual[y].qual[z].d_qual[xx].label))
             ELSE
              SET temp->qual[y].qual[z].display_line = concat(trim(temp->qual[y].qual[z].d_qual[xx].
                value)," ")
             ENDIF
            ELSE
             IF ((temp->qual[y].qual[z].d_qual[xx].suffix=0)
              AND (temp->qual[y].qual[z].d_qual[xx].label > "  "))
              SET temp->qual[y].qual[z].display_line = concat(trim(temp->qual[y].qual[z].display_line
                ),",",trim(temp->qual[y].qual[z].d_qual[xx].label)," ",trim(temp->qual[y].qual[z].
                d_qual[xx].value))
             ELSEIF ((temp->qual[y].qual[z].d_qual[xx].suffix=1)
              AND (temp->qual[y].qual[z].d_qual[xx].label > " "))
              SET temp->qual[y].qual[z].display_line = concat(trim(temp->qual[y].qual[z].display_line
                ),",",trim(temp->qual[y].qual[z].d_qual[xx].value)," ",trim(temp->qual[y].qual[z].
                d_qual[xx].label))
             ELSE
              SET temp->qual[y].qual[z].display_line = concat(trim(temp->qual[y].qual[z].display_line
                ),",",trim(temp->qual[y].qual[z].d_qual[xx].value)," ")
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->qual[y].qual[z].comment_ind=1))
      SELECT INTO "nl:"
       FROM order_comment oc,
        long_text lt
       PLAN (oc
        WHERE (oc.order_id=temp->qual[y].qual[z].order_id)
         AND oc.comment_type_cd=ord_cd)
        JOIN (lt
        WHERE lt.long_text_id=oc.long_text_id)
       HEAD REPORT
        blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," ")
       DETAIL
        blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), y1 = size(trim(lt
          .long_text)),
        blob_out = substring(1,y1,lt.long_text),
        CALL uar_rtf(blob_out,y1,blob_out2,32000,32000,0), temp->qual[y].qual[z].comment = blob_out2
       WITH nocounter
      ;end select
      SET a = findstring(lf,temp->qual[y].qual[z].comment)
      WHILE (a > 0)
       SET stat = movestring("  ",1,temp->qual[y].qual[z].comment,a,2)
       SET a = findstring(lf,temp->qual[y].qual[z].comment)
      ENDWHILE
      SET pt->line_cnt = 0
      SET max_length = 55
      SET modify = nopredeclare
      EXECUTE dcp_parse_text value(temp->qual[y].qual[z].comment), value(max_length)
      SET modify = predeclare
      SET stat = alterlist(temp->qual[y].qual[z].c_qual,pt->line_cnt)
      SET temp->qual[y].qual[z].c_cnt = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET temp->qual[y].qual[z].c_qual[w].c_line = pt->lns[w].line
      ENDFOR
     ENDIF
     SET pt->line_cnt = 0
     SET max_length = 20
     SET modify = nopredeclare
     EXECUTE dcp_parse_text value(temp->qual[y].qual[z].mnemonic), value(max_length)
     SET modify = predeclare
     SET stat = alterlist(temp->qual[y].qual[z].m_qual,pt->line_cnt)
     SET temp->qual[y].qual[z].m_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->qual[y].qual[z].m_qual[w].m_line = pt->lns[w].line
     ENDFOR
     SET pt->line_cnt = 0
     SET max_length = 70
     SET modify = nopredeclare
     EXECUTE dcp_parse_text value(temp->qual[y].qual[z].display_line), value(max_length)
     SET modify = predeclare
     SET stat = alterlist(temp->qual[y].qual[z].disp_qual,pt->line_cnt)
     SET temp->qual[y].qual[z].disp_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->qual[y].qual[z].disp_qual[w].disp_line = pt->lns[w].line
     ENDFOR
   ENDFOR
 ENDFOR
#print_report
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0, first_page = "Y",
   line = fillstring(105,"_")
  HEAD PAGE
   CALL echo("Head statement"), "{cpi/10}{f/12}", row + 1,
   "{pos/240/40}{b}KARDEX", row + 1, "{cpi/13}{f/8}",
   row + 1, "{pos/30/48}", line,
   row + 1, "{pos/30/60}{b}Name: {endb}", name,
   row + 1, "{pos/360/60}{b}DOB: {endb}", dob,
   row + 1, "{pos/30/70}{b}MRN: {endb}", mrn,
   row + 1, "{pos/360/70}{b}Admit Date: {endb}", admit_dt,
   row + 1, "{pos/30/80}{b}Location: {endb}", location,
   row + 1, "{pos/360/80}{b}Attending Dr: {endb}", attenddoc,
   row + 1, "{pos/30/83}", line,
   row + 1, ycol = 105
   IF (first_page="Y")
    first_page = "N", xcol = 30,
    CALL print(calcpos(xcol,ycol)),
    "{b}Allergies:", row + 1, xcol = 78
    FOR (x = 1 TO allergy->line_cnt)
      CALL print(calcpos(xcol,ycol)), allergy->line_qual[x].line, row + 1,
      ycol = (ycol+ 10)
    ENDFOR
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{b}Diagnosis:",
    row + 1, xcol = 83
    FOR (x = 1 TO diag->line_cnt)
      CALL print(calcpos(xcol,ycol)), diag->line_qual[x].line, row + 1,
      ycol = (ycol+ 10)
    ENDFOR
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{b}Reason For Visit: ",
    diag->reason, row + 1, ycol = (ycol+ 20)
   ENDIF
   "{cpi/13}", row + 1
  DETAIL
   IF ((temp->cnt=0))
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{b}",
    "No Active Orders Found", row + 1
   ELSE
    FOR (x = 1 TO temp->cnt)
      xcol = 30, "{cpi/12}", row + 1,
      CALL print(calcpos(xcol,ycol)), "{b}{u}", temp->qual[x].activity_type,
      row + 1, "{cpi/13}", row + 1,
      ycol = (ycol+ 10)
      FOR (y = 1 TO temp->qual[x].cnt)
        line_cnt = (temp->qual[x].qual[y].disp_cnt+ temp->qual[x].qual[y].c_cnt)
        IF ((temp->qual[x].qual[y].m_cnt > line_cnt))
         line_cnt = temp->qual[x].qual[y].m_cnt
        ENDIF
        IF ((((line_cnt * 10)+ ycol) > 710))
         BREAK
        ENDIF
        xcol = 30,
        CALL print(calcpos(xcol,ycol)), temp->qual[x].qual[y].date,
        row + 1, xcol = 120, scol = ycol
        FOR (z = 1 TO temp->qual[x].qual[y].m_cnt)
          CALL print(calcpos(xcol,ycol)), "{b}", temp->qual[x].qual[y].m_qual[z].m_line,
          row + 1, ycol = (ycol+ 10), zcol = ycol
        ENDFOR
        ycol = scol, xcol = 240
        FOR (z = 1 TO temp->qual[x].qual[y].disp_cnt)
          CALL print(calcpos(xcol,ycol)), temp->qual[x].qual[y].disp_qual[z].disp_line, row + 1,
          ycol = (ycol+ 10)
        ENDFOR
        FOR (z = 1 TO temp->qual[x].qual[y].c_cnt)
          IF (z=1)
           xcol = 240,
           CALL print(calcpos(xcol,ycol)), "{b}Order Comment:",
           row + 1
          ENDIF
          xcol = 317,
          CALL print(calcpos(xcol,ycol)), temp->qual[x].qual[y].c_qual[z].c_line,
          row + 1, ycol = (ycol+ 10)
        ENDFOR
        IF (zcol > ycol)
         ycol = zcol
        ENDIF
        ycol = (ycol+ 5)
      ENDFOR
    ENDFOR
   ENDIF
   ycol = (ycol+ 20), xcol = 200,
   CALL print(calcpos(xcol,ycol)),
   "{b}* * * * * End of Report * * * * *", row + 1
  FOOT PAGE
   "{pos/200/750}Page: ", curpage"##", row + 1,
   print_time = concat(format(datetimezone(cnvtdatetime(curdate,curtime),curtimezoneapp),
     "mm/dd/yy  hh:mm;4;q")," ",datetimezonebyindex(curtimezoneapp,offset,daylight,7,sysdate)),
   "{pos/275/750}Print Date/Time: ", print_time,
   row + 1
  WITH nocounter, maxrow = 800, maxcol = 800,
   dio = postscript
 ;end select
 GO TO exit_script
#report_failed
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0, first_page = "Y",
   line = fillstring(105,"_")
  HEAD PAGE
   "{cpi/10}{f/12}", row + 1, "{pos/240/40}{b}KARDEX",
   row + 1, "{cpi/13}{f/8}", row + 1,
   "{pos/30/48}", line, row + 1,
   "{pos/30/60}Report Failed: Invalid encounter Id used (", request->visit[1].encntr_id, ")",
   row + 1, "{pos/30/83}", line,
   row + 1, ycol = 105
  FOOT PAGE
   "{pos/200/750}Page: ", curpage"##", row + 1,
   "{pos/275/750}Print Date/Time: ", curdate, " ",
   curtime, row + 1
  WITH nocounter, maxrow = 800, maxcol = 800,
   dio = postscript
 ;end select
#exit_script
END GO
