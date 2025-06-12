CREATE PROGRAM bhs_rpt_misc_lab_orders:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order Date Start:" = "CURDATE",
  "Order Date End:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs200_miscreferrallabtest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MISCREFERRALLABTEST"))
 DECLARE mf_cs16449_perfloc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PERFORMINGLOCATIONAMBULATORY"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_order_id = f8
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_order_mnemonic = vc
     2 s_order_detail_display_line = vc
     2 s_order_dt = vc
     2 f_order_dt = f8
     2 s_order_status = vc
     2 s_catalog_type = vc
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_location = vc
     2 s_order_id = vc
     2 s_special_instructions = vc
     2 s_test_code = vc
     2 s_test_name = vc
     2 s_ordering_provider = vc
     2 s_order_entered_by = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM orders o,
   person p,
   encounter e,
   encntr_alias ea,
   order_detail od,
   order_detail od2,
   order_detail od3
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND o.catalog_cd=mf_cs200_miscreferrallabtest_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (e
   WHERE e.encntr_id=o.originating_encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_meaning= Outerjoin("SPECINX")) )
   JOIN (od2
   WHERE (od2.order_id= Outerjoin(o.order_id))
    AND (od2.oe_field_id= Outerjoin(2016197591.00)) )
   JOIN (od3
   WHERE (od3.order_id= Outerjoin(o.order_id))
    AND (od3.oe_field_id= Outerjoin(2016197901.00)) )
  ORDER BY o.order_id
  HEAD o.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = o.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_order_id = o.order_id, m_rec->qual[m_rec->l_cnt].f_person_id = o
   .person_id, m_rec->qual[m_rec->l_cnt].s_order_mnemonic = trim(o.order_mnemonic,3),
   m_rec->qual[m_rec->l_cnt].s_order_detail_display_line = trim(replace(replace(o
      .order_detail_display_line,char(10)," "),char(13)," "),3), m_rec->qual[m_rec->l_cnt].s_order_dt
    = trim(format(o.orig_order_dt_tm,"MM/DD/YYYY HH:mm;;q"),3), m_rec->qual[m_rec->l_cnt].f_order_dt
    = o.orig_order_dt_tm,
   m_rec->qual[m_rec->l_cnt].s_order_status = trim(uar_get_code_display(o.order_status_cd),3), m_rec
   ->qual[m_rec->l_cnt].s_catalog_type = trim(uar_get_code_display(o.catalog_type_cd),3), m_rec->
   qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_location = trim(
    uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->qual[m_rec->l_cnt].s_order_id = trim(
    cnvtstring(o.order_id,20,0),3),
   m_rec->qual[m_rec->l_cnt].s_special_instructions = trim(replace(replace(od.oe_field_display_value,
      char(10)," "),char(13)," "),3), m_rec->qual[m_rec->l_cnt].s_test_code = trim(replace(replace(
      od2.oe_field_display_value,char(10)," "),char(13)," "),3), m_rec->qual[m_rec->l_cnt].
   s_test_name = trim(replace(replace(od3.oe_field_display_value,char(10)," "),char(13)," "),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_action oa,
   prsnl p1,
   prsnl p2
  PLAN (oa
   WHERE expand(ml_idx1,1,m_rec->l_cnt,oa.order_id,m_rec->qual[ml_idx1].f_order_id)
    AND oa.action_sequence=1)
   JOIN (p1
   WHERE p1.person_id=oa.order_provider_id)
   JOIN (p2
   WHERE p2.person_id=oa.action_personnel_id)
  ORDER BY oa.order_id
  HEAD oa.order_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,oa.order_id,m_rec->qual[ml_idx1].f_order_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_ordering_provider = trim(p1.name_full_formatted,3), m_rec->qual[ml_idx2].
    s_order_entered_by = trim(p2.name_full_formatted,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (trim(value( $OUTDEV),3)="OPS")
  FREE RECORD frec
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
  SET frec->file_name = concat("bhs_rpt_misc_lab_orders_",format(cnvtdatetime(mf_start_dt),
    "MMDDYYYY;;q"),"_",format(cnvtdatetime(mf_stop_dt),"MMDDYYYY;;q"),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"',"ORDER_MNEMONIC",'","',"ORDER_DETAIL_DISPLAY_LINE",'","',
   "ORDER_DT",'","',"ORDER_STATUS",'","',"CATALOG_TYPE",
   '","',"PAT_NAME",'","',"FIN",'","',
   "LOCATION",'","',"ORDER_ID",'","',"ORDERING_PROVIDER",
   '","',"ORDER_ENTERED_BY",'","',"SPECIAL_INSTRUCTIONS",'","',
   "TEST_CODE",'","',"TEST_NAME",'"',char(13),
   char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_order_mnemonic,3),'","',trim(m_rec->
     qual[ml_idx1].s_order_detail_display_line,3),'","',
    trim(m_rec->qual[ml_idx1].s_order_dt,3),'","',trim(m_rec->qual[ml_idx1].s_order_status,3),'","',
    trim(m_rec->qual[ml_idx1].s_catalog_type,3),
    '","',trim(m_rec->qual[ml_idx1].s_pat_name,3),'","',trim(m_rec->qual[ml_idx1].s_fin,3),'","',
    trim(m_rec->qual[ml_idx1].s_location,3),'","',trim(m_rec->qual[ml_idx1].s_order_id,3),'","',trim(
     m_rec->qual[ml_idx1].s_ordering_provider,3),
    '","',trim(m_rec->qual[ml_idx1].s_order_entered_by,3),'","',trim(m_rec->qual[ml_idx1].
     s_special_instructions,3),'","',
    trim(m_rec->qual[ml_idx1].s_test_code,3),'","',trim(m_rec->qual[ml_idx1].s_test_name,3),'"',char(
     13),
    char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  DECLARE ms_tmp = vc WITH protect, noconstant("")
  DECLARE ms_email = vc WITH protect, constant(
   "angelce.lazovski@bhs.org, labcoreinternaldistribution@bhs.org")
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat(trim(curdomain,3)," Misc Lab Orders Report: ",format(cnvtdatetime(sysdate),
    "YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
 ELSE
  SELECT INTO  $OUTDEV
   order_mnemonic = trim(substring(1,250,m_rec->qual[d1.seq].s_order_mnemonic),3),
   order_detail_display_line = trim(substring(1,250,m_rec->qual[d1.seq].s_order_detail_display_line),
    3), order_dt = trim(substring(1,15,m_rec->qual[d1.seq].s_order_dt),3),
   order_status = trim(substring(1,50,m_rec->qual[d1.seq].s_order_status),3), catalog_type = trim(
    substring(1,50,m_rec->qual[d1.seq].s_catalog_type),3), pat_name = trim(substring(1,250,m_rec->
     qual[d1.seq].s_pat_name),3),
   fin = trim(substring(1,50,m_rec->qual[d1.seq].s_fin),3), location = trim(substring(1,100,m_rec->
     qual[d1.seq].s_location),3), order_id = trim(substring(1,25,m_rec->qual[d1.seq].s_order_id),3),
   ordering_provider = trim(substring(1,150,m_rec->qual[d1.seq].s_ordering_provider),3),
   order_entered_by = trim(substring(1,150,m_rec->qual[d1.seq].s_order_entered_by),3),
   special_instructions = trim(substring(1,250,m_rec->qual[d1.seq].s_special_instructions),3),
   test_code = trim(substring(1,250,m_rec->qual[d1.seq].s_test_code),3), test_name = trim(substring(1,
     250,m_rec->qual[d1.seq].s_test_name),3)
   FROM (dummyt d1  WITH seq = value(m_rec->l_cnt))
   PLAN (d1)
   ORDER BY cnvtdatetime(m_rec->qual[d1.seq].f_order_dt)
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ENDIF
#exit_script
END GO
