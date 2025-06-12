CREATE PROGRAM dcp_get_pat:dba
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
   1 sheader = vc
   1 sname = vc
   1 sadmdisch = vc
   1 snodisch = vc
   1 sdobsex = vc
   1 spttype = vc
   1 smrn = vc
   1 sacct = vc
   1 slocation = vc
   1 sattendmd = vc
   1 sadmitdx = vc
   1 sstartdt = vc
   1 sorderable = vc
   1 sdetailscomments = vc
   1 sstatus = vc
   1 spage = vc
   1 sprintdttm = vc
 )
 SET captions->sheader = trim(uar_i18ngetmessage(i18nhandle,"Header","ACTIVE ORDER PROFILE"))
 SET captions->sname = trim(uar_i18ngetmessage(i18nhandle,"Name","Name"))
 SET captions->sadmdisch = trim(uar_i18ngetmessage(i18nhandle,"AdmDisch","Adm-Disch"))
 SET captions->snodisch = trim(uar_i18ngetmessage(i18nhandle,"NoDisch","No Discharge Date"))
 SET captions->sdobsex = trim(uar_i18ngetmessage(i18nhandle,"DOBSex","DOB/Sex"))
 SET captions->spttype = trim(uar_i18ngetmessage(i18nhandle,"PtType","Pt Type"))
 SET captions->smrn = trim(uar_i18ngetmessage(i18nhandle,"MRN","MRN"))
 SET captions->sacct = trim(uar_i18ngetmessage(i18nhandle,"Accnt","Acct #"))
 SET captions->slocation = trim(uar_i18ngetmessage(i18nhandle,"Location","Location"))
 SET captions->sattendmd = trim(uar_i18ngetmessage(i18nhandle,"AttendMD","Attend MD"))
 SET captions->sadmitdx = trim(uar_i18ngetmessage(i18nhandle,"AdmitDx","Admit Dx"))
 SET captions->sstartdt = trim(uar_i18ngetmessage(i18nhandle,"StartDt","Start Date"))
 SET captions->sorderable = trim(uar_i18ngetmessage(i18nhandle,"Orderable","Orderable"))
 SET captions->sdetailscomments = trim(uar_i18ngetmessage(i18nhandle,"Details","Details/Comments"))
 SET captions->sstatus = trim(uar_i18ngetmessage(i18nhandle,"Status","Status"))
 SET captions->spage = trim(uar_i18ngetmessage(i18nhandle,"Page","Page"))
 SET captions->sprintdttm = trim(uar_i18ngetmessage(i18nhandle,"Print","Print Date/Time"))
 RECORD temp(
   1 name = vc
   1 mrn = vc
   1 fnbr = vc
   1 unit = vc
   1 room = vc
   1 bed = vc
   1 age = vc
   1 dob = vc
   1 sex = vc
   1 adm_date = vc
   1 disch_date = vc
   1 pt_type = vc
   1 attend_md = vc
   1 admit_dx = vc
   1 dx_cnt = i2
   1 dx_qual[*]
     2 dx_line = vc
   1 cat_cnt = i2
   1 cat_qual[*]
     2 catalog_type = vc
     2 ord_cnt = i2
     2 ord_qual[*]
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
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE code_set = f8
 DECLARE code_value = f8
 DECLARE cdf_meaning = c12
 DECLARE ordered_cd = f8
 DECLARE inprocess_cd = f8
 DECLARE future_cd = f8
 DECLARE pending_cd = f8
 DECLARE mnem_disp_level = c1
 DECLARE iv_disp_level = c1
 DECLARE begin_dt_tm = vc
 DECLARE end_dt_tm = vc
 DECLARE cnt = i2
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_md_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "FUTURE"
 EXECUTE cpm_get_cd_for_cdf
 SET future_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "PENDING"
 EXECUTE cpm_get_cd_for_cdf
 SET future_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_set = 16389
 SET cdf_meaning = "IVSOLUTIONS"
 EXECUTE cpm_get_cd_for_cdf
 SET iv_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET ord_comm_cd = code_value
 SET begin_dt_tm = format(request->begin_dt_tm,"@SHORTDATETIME")
 SET end_dt_tm = format(request->end_dt_tm,"@SHORTDATETIME")
 SELECT INTO "NL:"
  FROM encounter e,
   person p,
   person_alias pa,
   encntr_alias ea,
   (dummyt d  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE outerjoin(p.person_id)=pa.person_id
    AND outerjoin(mrn_alias_cd)=pa.person_alias_type_cd
    AND outerjoin(1)=pa.active_ind
    AND outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))=pa.end_effective_dt_tm)
   JOIN (ea
   WHERE outerjoin(e.encntr_id)=ea.encntr_id
    AND outerjoin(finnbr_cd)=ea.encntr_alias_type_cd
    AND outerjoin(1)=ea.active_ind)
   JOIN (d)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_md_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   temp->name = substring(1,30,p.name_full_formatted)
   IF (pa.alias_pool_cd > 0)
    temp->mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ELSE
    temp->mrn = pa.alias
   ENDIF
   IF (ea.alias_pool_cd > 0)
    temp->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSE
    temp->fnbr = ea.alias
   ENDIF
   temp->unit = uar_get_code_display(e.loc_nurse_unit_cd), temp->room = uar_get_code_display(e
    .loc_room_cd), temp->bed = uar_get_code_display(e.loc_bed_cd),
   temp->age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),3), temp->dob = format(p.birth_dt_tm,
    "@SHORTDATE"), temp->sex = uar_get_code_display(p.sex_cd),
   temp->adm_date = format(datetimezone(e.reg_dt_tm,e.reg_tz),"@SHORTDATE"), temp->disch_date =
   format(datetimezone(e.disch_dt_tm,e.reg_tz),"@SHORTDATE"), temp->pt_type = uar_get_code_display(e
    .encntr_type_cd),
   temp->attend_md = pl.name_full_formatted, temp->admit_dx = e.reason_for_visit
  WITH nocounter, outerjoin = d
 ;end select
 CALL echorecord(temp)
 SET pt->line_cnt = 0
 SET max_length = 90
 EXECUTE dcp_parse_text value(temp->admit_dx), value(max_length)
 SET stat = alterlist(temp->dx_qual,pt->line_cnt)
 SET temp->dx_cnt = pt->line_cnt
 FOR (w = 1 TO pt->line_cnt)
   SET temp->dx_qual[w].dx_line = pt->lns[w].line
 ENDFOR
 SET mnem_disp_level = "1"
 SET iv_disp_level = "0"
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
 CALL echo(build("mnem_disp_level:",mnem_disp_level," iv_disp_level:",iv_disp_level))
 SELECT INTO "nl:"
  o.*
  FROM orders o
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND (o.encntr_id=request->encntr_id)
    AND ((o.hide_flag != 1) OR (o.hide_flag = null))
    AND o.order_status_cd IN (ordered_cd, inprocess_cd, future_cd, pending_cd)
    AND o.template_order_flag IN (0, 1))
  ORDER BY o.catalog_type_cd, cnvtdatetime(o.current_start_dt_tm)
  HEAD REPORT
   temp->cat_cnt = 0
  HEAD o.catalog_type_cd
   cnt = 0, temp->cat_cnt = (temp->cat_cnt+ 1), stat = alterlist(temp->cat_qual,temp->cat_cnt),
   temp->cat_qual[temp->cat_cnt].catalog_type = uar_get_code_display(o.catalog_type_cd)
  DETAIL
   cnt = (cnt+ 1), temp->cat_qual[temp->cat_cnt].ord_cnt = cnt, stat = alterlist(temp->cat_qual[temp
    ->cat_cnt].ord_qual,cnt),
   temp->cat_qual[temp->cat_cnt].ord_qual[cnt].date = format(datetimezone(o.current_start_dt_tm,o
     .current_start_tz),"@SHORTDATETIME"), temp->cat_qual[temp->cat_cnt].ord_qual[cnt].status =
   uar_get_code_display(o.order_status_cd), temp->cat_qual[temp->cat_cnt].ord_qual[cnt].display_line
    = o.clinical_display_line,
   temp->cat_qual[temp->cat_cnt].ord_qual[cnt].oe_format_id = o.oe_format_id
   IF (substring(245,10,o.clinical_display_line) > "  ")
    temp->cat_qual[temp->cat_cnt].ord_qual[cnt].clin_line_ind = 1
   ELSE
    temp->cat_qual[temp->cat_cnt].ord_qual[cnt].clin_line_ind = 0
   ENDIF
   temp->cat_qual[temp->cat_cnt].ord_qual[cnt].order_id = o.order_id, temp->cat_qual[temp->cat_cnt].
   ord_qual[cnt].iv_ind = o.iv_ind
   IF (o.dcp_clin_cat_cd=iv_cd)
    temp->cat_qual[temp->cat_cnt].ord_qual[cnt].iv_ind = 1
   ENDIF
   temp->cat_qual[temp->cat_cnt].ord_qual[cnt].mnemonic = o.hna_order_mnemonic
   IF (o.catalog_type_cd=pharmacy_cd)
    IF (mnem_disp_level="0")
     temp->cat_qual[temp->cat_cnt].ord_qual[cnt].mnemonic = trim(o.hna_order_mnemonic)
    ENDIF
    IF (mnem_disp_level="1")
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (((o.ordered_as_mnemonic=" ") OR (size(o
      .ordered_as_mnemonic,1) <= 0)) )) )
      temp->cat_qual[temp->cat_cnt].ord_qual[cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      temp->cat_qual[temp->cat_cnt].ord_qual[cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",
       trim(o.ordered_as_mnemonic),")")
     ENDIF
    ENDIF
    IF (mnem_disp_level="2"
     AND o.iv_ind != 1)
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (((o.ordered_as_mnemonic=" ") OR (size(o
      .ordered_as_mnemonic,1) <= 0)) )) )
      temp->cat_qual[temp->cat_cnt].ord_qual[cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      temp->cat_qual[temp->cat_cnt].ord_qual[cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",
       trim(o.ordered_as_mnemonic),")")
     ENDIF
     IF (o.order_mnemonic != o.ordered_as_mnemonic
      AND size(o.order_mnemonic,1) > 0)
      temp->cat_qual[temp->cat_cnt].ord_qual[cnt].mnemonic = concat(trim(temp->cat_qual[temp->cat_cnt
        ].ord_qual[cnt].mnemonic),"(",trim(o.order_mnemonic),")")
     ENDIF
    ENDIF
   ENDIF
   temp->cat_qual[temp->cat_cnt].ord_qual[cnt].comment_ind = o.order_comment_ind
  WITH nocounter
 ;end select
 FOR (y = 1 TO temp->cat_cnt)
   FOR (z = 1 TO temp->cat_qual[y].ord_cnt)
     IF ((temp->cat_qual[y].ord_qual[z].iv_ind=1))
      SELECT INTO "nl:"
       FROM order_ingredient oi
       PLAN (oi
        WHERE (oi.order_id=temp->cat_qual[y].ord_qual[z].order_id))
       ORDER BY oi.action_sequence, oi.comp_sequence
       HEAD oi.action_sequence
        mnemonic_line = fillstring(1000," "), first_time = "Y"
       DETAIL
        IF (first_time="Y")
         IF (size(oi.ordered_as_mnemonic,1) > 0)
          mnemonic_line = concat(trim(oi.ordered_as_mnemonic),", ",trim(oi.order_detail_display_line)
           )
         ELSE
          mnemonic_line = concat(trim(oi.order_mnemonic),", ",trim(oi.order_detail_display_line))
         ENDIF
         first_time = "N"
        ELSE
         IF (size(oi.ordered_as_mnemonic,1) > 0)
          mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),", ",trim(oi
            .order_detail_display_line))
         ELSE
          mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),", ",trim(oi
            .order_detail_display_line))
         ENDIF
        ENDIF
       FOOT REPORT
        temp->cat_qual[y].ord_qual[z].mnemonic = mnemonic_line
       WITH nocounter
      ;end select
     ENDIF
     IF ((temp->cat_qual[y].ord_qual[z].clin_line_ind=1))
      SELECT INTO "nl:"
       FROM order_detail od,
        order_entry_fields of1,
        oe_format_fields oef
       PLAN (od
        WHERE (temp->cat_qual[y].ord_qual[z].order_id=od.order_id))
        JOIN (oef
        WHERE (oef.oe_format_id=temp->cat_qual[y].ord_qual[z].oe_format_id)
         AND oef.oe_field_id=od.oe_field_id)
        JOIN (of1
        WHERE of1.oe_field_id=oef.oe_field_id)
       ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
       HEAD REPORT
        temp->cat_qual[y].ord_qual[z].d_cnt = 0
       HEAD od.order_id
        stat = alterlist(temp->cat_qual[y].ord_qual[z].d_qual,5), temp->cat_qual[y].ord_qual[z].
        stat_ind = 0
       HEAD od.oe_field_id
        act_seq = od.action_sequence, odflag = 1
       HEAD od.action_sequence
        IF (act_seq != od.action_sequence)
         odflag = 0
        ENDIF
       DETAIL
        IF (odflag=1)
         temp->cat_qual[y].ord_qual[z].d_cnt = (temp->cat_qual[y].ord_qual[z].d_cnt+ 1), dc = temp->
         cat_qual[y].ord_qual[z].d_cnt
         IF (dc > size(temp->cat_qual[y].ord_qual[z].d_qual,5))
          stat = alterlist(temp->cat_qual[y].ord_qual[z].d_qual,(dc+ 5))
         ENDIF
         temp->cat_qual[y].ord_qual[z].d_qual[dc].label_text = trim(oef.label_text), temp->cat_qual[y
         ].ord_qual[z].d_qual[dc].field_value = od.oe_field_value, temp->cat_qual[y].ord_qual[z].
         d_qual[dc].group_seq = oef.group_seq,
         temp->cat_qual[y].ord_qual[z].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, temp
         ->cat_qual[y].ord_qual[z].d_qual[dc].value = trim(od.oe_field_display_value,3), temp->
         cat_qual[y].ord_qual[z].d_qual[dc].clin_line_ind = oef.clin_line_ind,
         temp->cat_qual[y].ord_qual[z].d_qual[dc].label = trim(oef.clin_line_label), temp->cat_qual[y
         ].ord_qual[z].d_qual[dc].suffix = oef.clin_suffix_ind
         IF (size(od.oe_field_display_value,1) > 0)
          temp->cat_qual[y].ord_qual[z].d_qual[dc].print_ind = 0
         ELSE
          temp->cat_qual[y].ord_qual[z].d_qual[dc].print_ind = 1
         ENDIF
         IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od
         .oe_field_meaning_id=127) OR (od.oe_field_meaning_id=43)) )) ))
          AND trim(cnvtupper(od.oe_field_display_value),3)="STAT")
          temp->cat_qual[y].ord_qual[z].stat_ind = 1
         ENDIF
         IF (of1.field_type_flag=7)
          IF (od.oe_field_value=1)
           IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=1)) )
            temp->cat_qual[y].ord_qual[z].d_qual[dc].value = trim(oef.label_text)
           ELSE
            temp->cat_qual[y].ord_qual[z].d_qual[dc].clin_line_ind = 0
           ENDIF
          ELSE
           IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=2)) )
            temp->cat_qual[y].ord_qual[z].d_qual[dc].value = trim(oef.clin_line_label)
           ELSE
            temp->cat_qual[y].ord_qual[z].d_qual[dc].clin_line_ind = 0
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       FOOT  od.order_id
        stat = alterlist(temp->cat_qual[y].ord_qual[z].d_qual,dc)
       WITH nocounter
      ;end select
      SET started_build_ind = 0
      FOR (fsub = 1 TO 31)
        FOR (xx = 1 TO temp->cat_qual[y].ord_qual[z].d_cnt)
          IF ((((temp->cat_qual[y].ord_qual[z].d_qual[xx].group_seq=fsub)) OR (fsub=31))
           AND (temp->cat_qual[y].ord_qual[z].d_qual[xx].print_ind=0))
           SET temp->cat_qual[y].ord_qual[z].d_qual[xx].print_ind = 1
           IF ((temp->cat_qual[y].ord_qual[z].d_qual[xx].clin_line_ind=1))
            IF (started_build_ind=0)
             SET started_build_ind = 1
             IF ((temp->cat_qual[y].ord_qual[z].d_qual[xx].suffix=0)
              AND (temp->cat_qual[y].ord_qual[z].d_qual[xx].label > "  "))
              SET temp->cat_qual[y].ord_qual[z].display_line = concat(trim(temp->cat_qual[y].
                ord_qual[z].d_qual[xx].label)," ",trim(temp->cat_qual[y].ord_qual[z].d_qual[xx].value
                ))
             ELSEIF ((temp->cat_qual[y].ord_qual[z].d_qual[xx].suffix=1)
              AND size(temp->cat_qual[y].ord_qual[z].d_qual[xx].label,1) > 0)
              SET temp->cat_qual[y].ord_qual[z].display_line = concat(trim(temp->cat_qual[y].
                ord_qual[z].d_qual[xx].value)," ",trim(temp->cat_qual[y].ord_qual[z].d_qual[xx].label
                ))
             ELSE
              SET temp->cat_qual[y].ord_qual[z].display_line = concat(trim(temp->cat_qual[y].
                ord_qual[z].d_qual[xx].value)," ")
             ENDIF
            ELSE
             IF ((temp->cat_qual[y].ord_qual[z].d_qual[xx].suffix=0)
              AND (temp->cat_qual[y].ord_qual[z].d_qual[xx].label > "  "))
              SET temp->cat_qual[y].ord_qual[z].display_line = concat(trim(temp->cat_qual[y].
                ord_qual[z].display_line),",",trim(temp->cat_qual[y].ord_qual[z].d_qual[xx].label),
               " ",trim(temp->cat_qual[y].ord_qual[z].d_qual[xx].value))
             ELSEIF ((temp->cat_qual[y].ord_qual[z].d_qual[xx].suffix=1)
              AND size(temp->cat_qual[y].ord_qual[z].d_qual[xx].label,1) > 0)
              SET temp->cat_qual[y].ord_qual[z].display_line = concat(trim(temp->cat_qual[y].
                ord_qual[z].display_line),",",trim(temp->cat_qual[y].ord_qual[z].d_qual[xx].value),
               " ",trim(temp->cat_qual[y].ord_qual[z].d_qual[xx].label))
             ELSE
              SET temp->cat_qual[y].ord_qual[z].display_line = concat(trim(temp->cat_qual[y].
                ord_qual[z].display_line),",",trim(temp->cat_qual[y].ord_qual[z].d_qual[xx].value),
               " ")
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->cat_qual[y].ord_qual[z].comment_ind=1))
      SELECT INTO "nl:"
       FROM order_comment oc,
        long_text lt
       PLAN (oc
        WHERE (oc.order_id=temp->cat_qual[y].ord_qual[z].order_id)
         AND oc.comment_type_cd=ord_comm_cd)
        JOIN (lt
        WHERE lt.long_text_id=oc.long_text_id)
       HEAD REPORT
        blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," ")
       DETAIL
        blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), y1 = size(trim(lt
          .long_text)),
        blob_out = substring(1,y1,lt.long_text),
        CALL uar_rtf(blob_out,y1,blob_out2,32000,32000,0), temp->cat_qual[y].ord_qual[z].comment =
        blob_out2
       WITH nocounter
      ;end select
      SET pt->line_cnt = 0
      SET max_length = 55
      EXECUTE dcp_parse_text value(temp->cat_qual[y].ord_qual[z].comment), value(max_length)
      SET stat = alterlist(temp->cat_qual[y].ord_qual[z].c_qual,pt->line_cnt)
      SET temp->cat_qual[y].ord_qual[z].c_cnt = pt->line_cnt
      FOR (w = 1 TO pt->line_cnt)
        SET temp->cat_qual[y].ord_qual[z].c_qual[w].c_line = pt->lns[w].line
      ENDFOR
     ENDIF
     SET pt->line_cnt = 0
     SET max_length = 25
     EXECUTE dcp_parse_text value(temp->cat_qual[y].ord_qual[z].mnemonic), value(max_length)
     SET stat = alterlist(temp->cat_qual[y].ord_qual[z].m_qual,pt->line_cnt)
     SET temp->cat_qual[y].ord_qual[z].m_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->cat_qual[y].ord_qual[z].m_qual[w].m_line = pt->lns[w].line
     ENDFOR
     SET pt->line_cnt = 0
     SET max_length = 55
     EXECUTE dcp_parse_text value(temp->cat_qual[y].ord_qual[z].display_line), value(max_length)
     SET stat = alterlist(temp->cat_qual[y].ord_qual[z].disp_qual,pt->line_cnt)
     SET temp->cat_qual[y].ord_qual[z].disp_cnt = pt->line_cnt
     FOR (w = 1 TO pt->line_cnt)
       SET temp->cat_qual[y].ord_qual[z].disp_qual[w].disp_line = pt->lns[w].line
     ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO request->printer_name
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0, ast =
   "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *",
   cat_line = fillstring(150," ")
  HEAD PAGE
   "{cpi/10}{f/12}", row + 1, "{pos/215/30}{b}",
   captions->sheader, row + 1, "{cpi/14}{f/8}",
   row + 1, "{cpi/13}", row + 1,
   "{pos/30/54}{b}", captions->sname, ": {endb}",
   temp->name, row + 1, "{pos/320/54}{b}",
   captions->sadmdisch, ": {endb}", temp->adm_date,
   "-"
   IF (size(temp->disch_date,1) > 0)
    temp->disch_date, row + 1
   ELSE
    captions->snodisch, row + 1
   ENDIF
   "{pos/30/66}{b}", captions->sdobsex, ": {endb}",
   temp->dob, " / ", temp->sex,
   row + 1, "{pos/320/66}{b}", captions->spttype,
   ": {endb}", temp->pt_type, row + 1,
   "{pos/30/78}{b}", captions->smrn, ": {endb}",
   temp->mrn, row + 1, "{pos/320/78}{b}",
   captions->sacct, ": {endb}", temp->fnbr,
   row + 1, "{pos/30/90}{b}", captions->slocation,
   ": {endb}",
   CALL print(concat(temp->unit," ",temp->room,"-",temp->bed)), row + 1,
   "{pos/320/90}{b}", captions->sattendmd, ": {endb}",
   temp->attend_md, row + 1, ycol = 102
   FOR (w = 1 TO temp->dx_cnt)
     IF (w=1)
      xcol = 30, ycol = (ycol+ 12),
      CALL print(calcpos(xcol,ycol)),
      "{b}", captions->sadmitdx, ": {endb}",
      temp->dx_qual[w].dx_line, row + 1
     ELSE
      xcol = 75, ycol = (ycol+ 12),
      CALL print(calcpos(xcol,ycol)),
      temp->dx_qual[w].dx_line, row + 1
     ENDIF
   ENDFOR
   ycol = (ycol+ 20),
   CALL print(calcpos(30,ycol)), "{b}{u}",
   captions->sstartdt, row + 1,
   CALL print(calcpos(110,ycol)),
   "{b}{u}", captions->sorderable, row + 1,
   CALL print(calcpos(225,ycol)), "{b}{u}", captions->sdetailscomments,
   row + 1,
   CALL print(calcpos(510,ycol)), "{b}{u}",
   captions->sstatus, row + 1, "{cpi/14}",
   row + 1, ycol = (ycol+ 15)
  DETAIL
   FOR (x = 1 TO temp->cat_cnt)
     cat_line = concat(ast," ",trim(temp->cat_qual[x].catalog_type)," ",ast), xcol = 30, "{cpi/12}",
     row + 1,
     CALL print(calcpos(xcol,ycol)), "{b}",
     cat_line, row + 1, "{cpi/14}",
     row + 1, ycol = (ycol+ 15)
     FOR (y = 1 TO temp->cat_qual[x].ord_cnt)
       line_cnt = (temp->cat_qual[x].ord_qual[y].disp_cnt+ temp->cat_qual[x].ord_qual[y].c_cnt),
       add_line_ind = 0
       IF ((temp->cat_qual[x].ord_qual[y].m_cnt > line_cnt))
        line_cnt = temp->cat_qual[x].ord_qual[y].m_cnt, add_line_ind = 1
       ENDIF
       IF ((((line_cnt * 10)+ ycol) > 710))
        BREAK
       ENDIF
       xcol = 30,
       CALL print(calcpos(xcol,ycol)), temp->cat_qual[x].ord_qual[y].date,
       row + 1, xcol = 510,
       CALL print(calcpos(xcol,ycol)),
       temp->cat_qual[x].ord_qual[y].status, row + 1, xcol = 110,
       scol = ycol
       FOR (z = 1 TO temp->cat_qual[x].ord_qual[y].m_cnt)
         CALL print(calcpos(xcol,ycol)), temp->cat_qual[x].ord_qual[y].m_qual[z].m_line, row + 1,
         ycol = (ycol+ 10), zcol = ycol
       ENDFOR
       ycol = scol, xcol = 225
       FOR (z = 1 TO temp->cat_qual[x].ord_qual[y].disp_cnt)
         CALL print(calcpos(xcol,ycol)), temp->cat_qual[x].ord_qual[y].disp_qual[z].disp_line, row +
         1,
         ycol = (ycol+ 10)
       ENDFOR
       FOR (z = 1 TO temp->cat_qual[x].ord_qual[y].c_cnt)
         CALL print(calcpos(xcol,ycol)), temp->cat_qual[x].ord_qual[y].c_qual[z].c_line, row + 1,
         ycol = (ycol+ 10)
       ENDFOR
       IF (add_line_ind=1)
        ycol = zcol, ycol = (ycol+ 5)
       ELSE
        ycol = (ycol+ 5)
       ENDIF
     ENDFOR
   ENDFOR
  FOOT PAGE
   "{pos/200/750}", captions->spage, ": ",
   curpage"##", row + 1, "{pos/275/750}",
   captions->sprintdttm, ": ", curdate,
   " ", curtime, row + 1
  WITH nocounter, maxrow = 800, maxcol = 800,
   dio = postscript
 ;end select
#exit_script
END GO
