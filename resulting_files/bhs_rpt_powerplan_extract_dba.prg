CREATE PROGRAM bhs_rpt_powerplan_extract:dba
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Run type:" = "UPDATE",
  "Number of days to look back for updates(if user selected update):" = "0",
  "Synonym Report" = 0
  WITH outdev, s_runtype, l_days,
  l_synrpt
 EXECUTE bhs_sys_stand_subroutine
 RECORD m_powerplans(
   1 powerplans[*]
     2 s_powerplan_name = vc
     2 f_powerplan_catalog_id = f8
     2 s_long_text = vc
     2 s_locations = vc
     2 s_last_updt = vc
 ) WITH protect
 RECORD m_phases(
   1 phases[*]
     2 s_phase_name = vc
     2 f_phase_catalog_id = f8
     2 s_long_text = vc
     2 f_parent_id = f8
     2 f_seq = i4
     2 f_inc_ind = f8
     2 s_cat = vc
 ) WITH protect
 RECORD m_pp_orders(
   1 parent[*]
     2 f_parent_id = f8
     2 orders[*]
       3 s_cat = vc
       3 s_sub_cat = vc
       3 s_ord_type = vc
       3 f_cat_seq = f8
       3 f_seq = i4
       3 f_disp_id = f8
       3 s_disp = vc
       3 f_inc_ind = f8
       3 f_req_ind = f8
       3 ord_sent[*]
         4 f_ord_sent_id = f8
         4 s_ord_sent_disp = vc
         4 s_long_text = vc
         4 f_ord_sent_seq = f8
 ) WITH protect
 RECORD m_pp_syn(
   1 synonym[*]
     2 f_powerplan_catalog_id = f8
     2 f_powerplan_synonym_id = f8
     2 s_synonym_name = vc
 ) WITH protect
 DECLARE mf_primary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,"PRIMARY"))
 DECLARE mf_mock_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,"MOCK"))
 DECLARE ml_lookbackdays = i4 WITH protect, constant(cnvtint( $L_DAYS))
 DECLARE mf_sequenced_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30720,"SEQUENCED"))
 DECLARE mf_outdev = vc WITH protect, constant( $OUTDEV)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_facility_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_sent_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_cat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cat_pos = i4 WITH protect, noconstant(0)
 DECLARE mf_pp_cat_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_seq = f8 WITH protect, noconstant(0.0)
 DECLARE mf_inc_ind = f8 WITH protect, noconstant(0.0)
 DECLARE mf_req_ind = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cat_seq = f8 WITH protect, noconstant(0.0)
 DECLARE mf_ord_sent_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_disp_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_phase_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_synonym_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tline = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_s_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_cat = vc WITH protect, noconstant(" ")
 DECLARE ms_sub_cat = vc WITH protect, noconstant(" ")
 DECLARE ms_ord_sent_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_long_text = vc WITH protect, noconstant(" ")
 DECLARE ms_pp_output = vc WITH protect, noconstant(" ")
 DECLARE ms_phase_output = vc WITH protect, noconstant(" ")
 DECLARE ms_ord_output = vc WITH protect, noconstant(" ")
 DECLARE ms_syn_output = vc WITH protect, noconstant(" ")
 DECLARE ms_type = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name_in = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name_out = vc WITH protect, noconstant(" ")
 DECLARE ms_user_name = vc WITH protect, noconstant(" ")
 DECLARE ms_server_name = vc WITH protect, noconstant(" ")
 DECLARE ms_local_dir = vc WITH protect, noconstant(" ")
 DECLARE ms_back_dir = vc WITH protect, noconstant(" ")
 DECLARE ms_phase_name = vc WITH protect, noconstant(" ")
 DECLARE ms_powerplan_name = vc WITH protect, noconstant(" ")
 DECLARE ms_locations = vc WITH protect, noconstant(" ")
 DECLARE ms_last_updt = vc WITH protect, noconstant(" ")
 DECLARE ms_synonym_name = vc WITH protect, noconstant(" ")
 DECLARE ms_search = vc WITH protect, noconstant(" ")
 DECLARE ms_ord_type = vc WITH protect, noconstant(" ")
 SET ms_pp_output = concat(trim("pp"),format(cnvtdatetime(sysdate),"MMDDYYYY;;d"))
 SET ms_phase_output = concat(trim("phase"),format(cnvtdatetime(sysdate),"MMDDYYYY;;d"))
 SET ms_ord_output = concat(trim("ord"),format(cnvtdatetime(sysdate),"MMDDYYYY;;d"))
 IF (findstring("@",mf_outdev) > 0)
  SET mn_email_ind = 1
 ELSEIF (cnvtupper(mf_outdev)="OPSJOB")
  SET mn_email_ind = 0
 ELSE
  SELECT INTO mf_outdev
   FROM dummyt d
   DETAIL
    col 0,
    CALL print("Error: Please type in your e-mail address")
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (( $S_RUNTYPE="ALL"))
  SET ms_search = build2("pcg.pathway_catalog_id = pcg.pathway_catalog_id")
 ELSE
  SET ms_search = build2("pcg.updt_dt_tm >= cnvtdatetime(curdate-ml_LOOKBACKDAYS, 000000)")
 ENDIF
 SELECT INTO "nl:"
  FROM pathway_catalog pcg,
   pw_cat_reltn pcr,
   pathway_catalog pcg1,
   pw_cat_reltn pcr1,
   pathway_catalog pcg2,
   long_text lt,
   long_text lt1
  PLAN (pcg
   WHERE pcg.type_mean IN ("PATHWAY", "CAREPLAN")
    AND pcg.active_ind=1
    AND pcg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND parser(ms_search))
   JOIN (pcr
   WHERE (pcr.pw_cat_s_id= Outerjoin(pcg.pathway_catalog_id)) )
   JOIN (pcg1
   WHERE (pcg1.pathway_catalog_id= Outerjoin(pcr.pw_cat_t_id))
    AND (pcg1.active_ind= Outerjoin(1))
    AND (pcg1.pathway_catalog_id> Outerjoin(0))
    AND (pcg1.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (pcr1
   WHERE (pcr1.pw_cat_s_id= Outerjoin(pcg1.pathway_catalog_id)) )
   JOIN (pcg2
   WHERE (pcg2.pathway_catalog_id= Outerjoin(pcr1.pw_cat_t_id))
    AND (pcg2.active_ind= Outerjoin(1))
    AND (pcg2.sub_phase_ind= Outerjoin(1))
    AND (pcg2.pathway_catalog_id> Outerjoin(0))
    AND (pcg2.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(pcg.long_text_id))
    AND (lt.active_ind= Outerjoin(1)) )
   JOIN (lt1
   WHERE (lt1.long_text_id= Outerjoin(pcg1.long_text_id))
    AND (lt1.active_ind= Outerjoin(1)) )
  ORDER BY pcg.pathway_catalog_id, pcr.rowid, pcr.rowid
  HEAD REPORT
   ml_pp_cnt = 0, ml_phase_cnt = 0
  HEAD pcg.pathway_catalog_id
   ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pcg.pathway_catalog_id,
    m_powerplans->powerplans[ml_cnt].f_powerplan_catalog_id)
   IF (ml_pp_pos=0)
    ml_pp_cnt += 1
    IF (((mod(ml_pp_cnt,50)=1) OR (ml_pp_cnt=1)) )
     CALL alterlist(m_powerplans->powerplans,(ml_pp_cnt+ 49))
    ENDIF
    m_powerplans->powerplans[ml_pp_cnt].s_powerplan_name = pcg.description, m_powerplans->powerplans[
    ml_pp_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, m_powerplans->powerplans[ml_pp_cnt].
    s_long_text = lt.long_text,
    m_powerplans->powerplans[ml_pp_cnt].s_last_updt = format(pcg.updt_dt_tm,"MM/DD/YYYY"), ml_pp_pos
     = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pcg.pathway_catalog_id,m_powerplans->
     powerplans[ml_cnt].f_powerplan_catalog_id), ml_facility_cnt = 0
   ENDIF
  HEAD pcr.rowid
   IF (pcg1.pathway_catalog_id > 0)
    ml_phase_cnt += 1
    IF (((mod(ml_phase_cnt,50)=1) OR (ml_phase_cnt=1)) )
     CALL alterlist(m_phases->phases,(ml_phase_cnt+ 49))
    ENDIF
    m_phases->phases[ml_phase_cnt].s_phase_name = pcg1.description, m_phases->phases[ml_phase_cnt].
    f_phase_catalog_id = pcg1.pathway_catalog_id, m_phases->phases[ml_phase_cnt].s_long_text = lt1
    .long_text,
    m_phases->phases[ml_phase_cnt].f_parent_id = pcg.pathway_catalog_id
   ENDIF
  HEAD pcr1.rowid
   IF (pcg2.pathway_catalog_id > 0)
    ml_phase_cnt += 1
    IF (((mod(ml_phase_cnt,50)=1) OR (ml_phase_cnt=1)) )
     CALL alterlist(m_phases->phases,(ml_phase_cnt+ 49))
    ENDIF
    m_phases->phases[ml_phase_cnt].s_phase_name = pcg2.description, m_phases->phases[ml_phase_cnt].
    f_phase_catalog_id = pcg2.pathway_catalog_id, m_phases->phases[ml_phase_cnt].f_parent_id = pcg1
    .pathway_catalog_id
   ENDIF
  FOOT REPORT
   CALL alterlist(m_powerplans->powerplans,ml_pp_cnt),
   CALL alterlist(m_phases->phases,ml_phase_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_cat_flex pcf
  WHERE pcf.parent_entity_name="CODE_VALUE"
   AND expand(ml_pp_cnt,1,size(m_powerplans->powerplans,5),pcf.pathway_catalog_id,m_powerplans->
   powerplans[ml_pp_cnt].f_powerplan_catalog_id)
  ORDER BY pcf.pathway_catalog_id, pcf.parent_entity_id
  HEAD pcf.pathway_catalog_id
   ml_facility_cnt = 0, ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pcf
    .pathway_catalog_id,m_powerplans->powerplans[ml_cnt].f_powerplan_catalog_id)
  HEAD pcf.parent_entity_id
   IF (pcf.pathway_catalog_id > 0)
    ml_facility_cnt += 1
    IF (pcf.parent_entity_id=0)
     m_powerplans->powerplans[ml_pp_pos].s_locations = "All"
    ELSE
     IF (ml_facility_cnt=1)
      m_powerplans->powerplans[ml_pp_pos].s_locations = uar_get_code_display(pcf.parent_entity_id)
     ELSE
      m_powerplans->powerplans[ml_pp_pos].s_locations = concat(m_powerplans->powerplans[ml_pp_pos].
       s_locations,", ",uar_get_code_display(pcf.parent_entity_id))
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM pathway_catalog pcg,
   pathway_comp pc,
   pathway_catalog pcg1
  PLAN (pcg
   WHERE expand(ml_pp_cnt,1,size(m_phases->phases,5),pcg.pathway_catalog_id,m_phases->phases[
    ml_pp_cnt].f_parent_id))
   JOIN (pc
   WHERE pc.parent_entity_name="PATHWAY_CATALOG"
    AND pcg.pathway_catalog_id=pc.pathway_catalog_id
    AND pc.active_ind=1)
   JOIN (pcg1
   WHERE expand(ml_phase_cnt,1,size(m_phases->phases,5),pcg1.pathway_catalog_id,m_phases->phases[
    ml_phase_cnt].f_phase_catalog_id)
    AND pcg1.pathway_catalog_id=pc.parent_entity_id)
  ORDER BY pc.pathway_comp_id
  HEAD pc.pathway_comp_id
   ml_phase_pos = locateval(ml_cnt,1,size(m_phases->phases,5),pcg.pathway_catalog_id,m_phases->
    phases[ml_cnt].f_parent_id,
    pcg1.pathway_catalog_id,m_phases->phases[ml_cnt].f_phase_catalog_id), m_phases->phases[
   ml_phase_pos].f_seq = pc.sequence, m_phases->phases[ml_phase_pos].f_inc_ind = pc.include_ind,
   m_phases->phases[ml_phase_pos].s_cat = uar_get_code_display(pc.dcp_clin_cat_cd)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM pathway_catalog pcg,
   pathway_comp pwc,
   code_value cv,
   long_text lt,
   outcome_catalog ocg,
   order_catalog_synonym ocs,
   order_catalog oc,
   pw_comp_os_reltn pc,
   order_sentence os,
   long_text lt1
  PLAN (pcg
   WHERE ((expand(ml_pp_cnt,1,size(m_powerplans->powerplans,5),pcg.pathway_catalog_id,m_powerplans->
    powerplans[ml_pp_cnt].f_powerplan_catalog_id)) OR (expand(ml_phase_cnt,1,size(m_phases->phases,5),
    pcg.pathway_catalog_id,m_phases->phases[ml_phase_cnt].f_phase_catalog_id))) )
   JOIN (pwc
   WHERE (pwc.pathway_catalog_id= Outerjoin(pcg.pathway_catalog_id))
    AND (pwc.active_ind= Outerjoin(1)) )
   JOIN (cv
   WHERE (cv.code_set= Outerjoin(16389))
    AND (cv.code_value= Outerjoin(pwc.dcp_clin_cat_cd)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(pwc.parent_entity_id))
    AND (lt.active_ind= Outerjoin(1)) )
   JOIN (ocg
   WHERE (ocg.outcome_catalog_id= Outerjoin(pwc.parent_entity_id))
    AND (ocg.active_ind= Outerjoin(1)) )
   JOIN (ocs
   WHERE (ocs.synonym_id= Outerjoin(pwc.parent_entity_id))
    AND (ocs.active_ind= Outerjoin(1)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(ocs.catalog_cd))
    AND (oc.active_ind= Outerjoin(1)) )
   JOIN (pc
   WHERE (pc.pathway_comp_id= Outerjoin(pwc.pathway_comp_id)) )
   JOIN (os
   WHERE (os.order_sentence_id= Outerjoin(pc.order_sentence_id)) )
   JOIN (lt1
   WHERE (lt1.long_text_id= Outerjoin(os.ord_comment_long_text_id))
    AND (lt1.active_ind= Outerjoin(1)) )
  ORDER BY pwc.pathway_catalog_id, pwc.sequence, lt.long_text_id,
   ocg.outcome_catalog_id, ocs.synonym_id, pc.order_sentence_seq,
   os.order_sentence_id
  HEAD REPORT
   ml_pp_cnt = 0
  HEAD pwc.pathway_catalog_id
   ml_pp_cnt += 1
   IF (((mod(ml_pp_cnt,50)=1) OR (ml_pp_cnt=1)) )
    CALL alterlist(m_pp_orders->parent,(ml_pp_cnt+ 49))
   ENDIF
   m_pp_orders->parent[ml_pp_cnt].f_parent_id = pcg.pathway_catalog_id, ml_pp_pos = locateval(ml_cnt,
    1,size(m_pp_orders->parent,5),pcg.pathway_catalog_id,m_pp_orders->parent[ml_cnt].f_parent_id),
   ml_ord_cnt = 0
  HEAD lt.long_text_id
   IF (ocs.catalog_cd=0
    AND ocg.outcome_catalog_id=0
    AND lt.long_text_id != 0)
    ml_ord_cnt += 1
    IF (((mod(ml_ord_cnt,50)=1) OR (ml_ord_cnt=1)) )
     CALL alterlist(m_pp_orders->parent[ml_pp_pos].orders,(ml_ord_cnt+ 49))
    ENDIF
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_disp = lt.long_text, m_pp_orders->parent[
    ml_pp_pos].orders[ml_ord_cnt].f_disp_id = lt.long_text_id, m_pp_orders->parent[ml_pp_pos].orders[
    ml_ord_cnt].f_seq = pwc.sequence,
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].f_inc_ind = pwc.include_ind, m_pp_orders->
    parent[ml_pp_pos].orders[ml_ord_cnt].f_req_ind = pwc.required_ind
    IF (pwc.comp_label="OUT")
     m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_cat = "Outcome", m_pp_orders->parent[
     ml_pp_pos].orders[ml_ord_cnt].f_cat_seq = 1.00, m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt
     ].s_ord_type = "OUT"
    ELSE
     m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_ord_type = "LT"
     IF (pwc.comp_label != "INT")
      IF (pcg.display_method_cd != mf_sequenced_cd)
       m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_cat = uar_get_code_display(pwc
        .dcp_clin_cat_cd), m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_sub_cat =
       uar_get_code_display(pwc.dcp_clin_sub_cat_cd), m_pp_orders->parent[ml_pp_pos].orders[
       ml_ord_cnt].f_cat_seq = cv.collation_seq
      ENDIF
     ELSE
      m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_cat = "Intervention", m_pp_orders->parent[
      ml_pp_pos].orders[ml_ord_cnt].f_cat_seq = 2.00
     ENDIF
    ENDIF
   ENDIF
  HEAD ocg.outcome_catalog_id
   IF (ocs.catalog_cd=0
    AND lt.long_text_id=0
    AND ocg.outcome_catalog_id != 0)
    ml_ord_cnt += 1
    IF (((mod(ml_ord_cnt,50)=1) OR (ml_ord_cnt=1)) )
     CALL alterlist(m_pp_orders->parent[ml_pp_pos].orders,(ml_ord_cnt+ 49))
    ENDIF
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].f_disp_id = ocg.outcome_catalog_id, m_pp_orders
    ->parent[ml_pp_pos].orders[ml_ord_cnt].s_disp = ocg.description, m_pp_orders->parent[ml_pp_pos].
    orders[ml_ord_cnt].f_seq = pwc.sequence,
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].f_inc_ind = pwc.include_ind, m_pp_orders->
    parent[ml_pp_pos].orders[ml_ord_cnt].f_req_ind = pwc.required_ind, m_pp_orders->parent[ml_pp_pos]
    .orders[ml_ord_cnt].s_cat = "Outcome",
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].f_cat_seq = 1.00, m_pp_orders->parent[ml_pp_pos
    ].orders[ml_ord_cnt].s_ord_type = "OUT",
    CALL alterlist(m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].ord_sent,1),
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].ord_sent[1].s_ord_sent_disp = ocg.expectation
   ENDIF
  HEAD ocs.synonym_id
   IF (ocg.outcome_catalog_id=0
    AND ocs.synonym_id != 0)
    ml_ord_cnt += 1
    IF (((mod(ml_ord_cnt,50)=1) OR (ml_ord_cnt=1)) )
     CALL alterlist(m_pp_orders->parent[ml_pp_pos].orders,(ml_ord_cnt+ 49))
    ENDIF
    IF (oc.primary_mnemonic != ocs.mnemonic)
     m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_disp = build(oc.primary_mnemonic,"(",ocs
      .mnemonic,")")
    ELSE
     m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_disp = ocs.mnemonic
    ENDIF
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].f_disp_id = ocs.synonym_id, m_pp_orders->
    parent[ml_pp_pos].orders[ml_ord_cnt].f_seq = pwc.sequence, m_pp_orders->parent[ml_pp_pos].orders[
    ml_ord_cnt].f_inc_ind = pwc.include_ind,
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].f_req_ind = pwc.required_ind, m_pp_orders->
    parent[ml_pp_pos].orders[ml_ord_cnt].s_ord_type = "ORD"
    IF (pwc.comp_label != "INT")
     IF (pcg.display_method_cd != mf_sequenced_cd)
      m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_cat = uar_get_code_display(pwc
       .dcp_clin_cat_cd), m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_sub_cat =
      uar_get_code_display(pwc.dcp_clin_sub_cat_cd), m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt
      ].f_cat_seq = cv.collation_seq
     ENDIF
    ELSE
     m_pp_orders->parent[ml_pp_pos].orders[ml_ord_cnt].s_cat = "Intervention", m_pp_orders->parent[
     ml_pp_pos].orders[ml_ord_cnt].f_cat_seq = 2.00
    ENDIF
    ml_ord_pos = locateval(ml_cnt,1,size(m_pp_orders->parent[ml_pp_pos].orders,5),ocs.synonym_id,
     m_pp_orders->parent[ml_pp_pos].orders[ml_cnt].f_disp_id,
     pwc.sequence,m_pp_orders->parent[ml_pp_pos].orders[ml_cnt].f_seq), ml_ord_sent_cnt = 0
   ENDIF
  HEAD os.order_sentence_id
   IF (ocg.outcome_catalog_id=0
    AND ocs.synonym_id != 0)
    ml_ord_sent_cnt += 1
    IF (((mod(ml_ord_sent_cnt,50)=1) OR (ml_ord_sent_cnt=1)) )
     CALL alterlist(m_pp_orders->parent[ml_pp_pos].orders[ml_ord_pos].ord_sent,(ml_ord_sent_cnt+ 49))
    ENDIF
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_pos].ord_sent[ml_ord_sent_cnt].f_ord_sent_id = os
    .order_sentence_id, m_pp_orders->parent[ml_pp_pos].orders[ml_ord_pos].ord_sent[ml_ord_sent_cnt].
    f_ord_sent_seq = pc.order_sentence_seq, m_pp_orders->parent[ml_pp_pos].orders[ml_ord_pos].
    ord_sent[ml_ord_sent_cnt].s_ord_sent_disp = os.order_sentence_display_line,
    m_pp_orders->parent[ml_pp_pos].orders[ml_ord_pos].ord_sent[ml_ord_sent_cnt].s_long_text = lt1
    .long_text
   ENDIF
  FOOT  ocs.synonym_id
   IF (ocg.outcome_catalog_id=0
    AND ocs.synonym_id != 0)
    CALL alterlist(m_pp_orders->parent[ml_pp_pos].orders[ml_ord_pos].ord_sent,ml_ord_sent_cnt)
   ENDIF
  FOOT  pwc.pathway_catalog_id
   CALL alterlist(m_pp_orders->parent[ml_pp_pos].orders,ml_ord_cnt)
  FOOT REPORT
   CALL alterlist(m_pp_orders->parent,ml_pp_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO concat(ms_pp_output,".csv")
  FROM (dummyt d1  WITH seq = value(size(m_powerplans->powerplans,5)))
  PLAN (d1)
  HEAD REPORT
   ms_tline = build(char(34),"PowerplanName",char(34),char(44),char(34),
    "PowerplanID",char(34),char(44),char(34),"LongText",
    char(34),char(44),char(34),"Locations",char(34),
    char(44),char(34),"LastUpdt",char(34),char(44)), col 0, ms_tline,
   row + 1
  DETAIL
   ms_powerplan_name = substring(1,50,m_powerplans->powerplans[d1.seq].s_powerplan_name),
   mf_pp_cat_id = m_powerplans->powerplans[d1.seq].f_powerplan_catalog_id, ms_long_text = substring(1,
    50,m_powerplans->powerplans[d1.seq].s_long_text),
   ms_locations = substring(1,200,m_powerplans->powerplans[d1.seq].s_locations), ms_last_updt =
   m_powerplans->powerplans[d1.seq].s_last_updt, ms_tline = build(char(34),ms_powerplan_name,char(34),
    char(44),mf_pp_cat_id,
    char(44),char(34),ms_long_text,char(34),char(44),
    char(34),ms_locations,char(34),char(44),char(34),
    ms_last_updt,char(34),char(44)),
   col 0, ms_tline, row + 1
  WITH maxcol = 32000, format = variable, formfeed = none,
   check
 ;end select
 SELECT INTO concat(ms_phase_output,".csv")
  FROM (dummyt d1  WITH seq = value(size(m_phases->phases,5)))
  PLAN (d1)
  HEAD REPORT
   ms_tline = build(char(34),"PhaseName",char(34),char(44),char(34),
    "PhaseID",char(34),char(44),char(34),"LongText",
    char(34),char(44),char(34),"ParentID",char(34),
    char(44),char(34),"Sequence",char(34),char(44),
    char(34),"Include Indicator",char(34),char(44),char(34),
    "Category",char(34),char(44)), col 0, ms_tline,
   row + 1
  DETAIL
   ms_phase_name = substring(1,50,m_phases->phases[d1.seq].s_phase_name), mf_phase_id = m_phases->
   phases[d1.seq].f_phase_catalog_id, ms_long_text = substring(1,50,m_phases->phases[d1.seq].
    s_long_text),
   mf_parent_id = m_phases->phases[d1.seq].f_parent_id, mf_seq = m_phases->phases[d1.seq].f_seq,
   mf_inc_ind = m_phases->phases[d1.seq].f_inc_ind,
   ms_cat = m_phases->phases[d1.seq].s_cat, ms_tline = build(char(34),ms_phase_name,char(34),char(44),
    mf_phase_id,
    char(44),char(34),ms_long_text,char(34),char(44),
    mf_parent_id,char(44),mf_seq,char(44),mf_inc_ind,
    char(44),char(34),ms_cat,char(34),char(44)), col 0,
   ms_tline, row + 1
  WITH maxcol = 32000, format = variable, formfeed = none,
   check
 ;end select
 SELECT INTO concat(ms_ord_output,".csv")
  FROM (dummyt d1  WITH seq = value(size(m_pp_orders->parent,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(m_pp_orders->parent[d1.seq].orders,5)))
   JOIN (d2
   WHERE maxrec(d3,size(m_pp_orders->parent[d1.seq].orders[d2.seq].ord_sent,5)))
   JOIN (d3)
  ORDER BY m_pp_orders->parent[d1.seq].orders[d2.seq].ord_sent[d3.seq].f_ord_sent_seq
  HEAD REPORT
   ms_tline = build(char(34),"Sequence",char(34),char(44),char(34),
    "Category Sequence",char(34),char(44),char(34),"ParentID",
    char(34),char(44),char(34),"Category",char(34),
    char(44),char(34),"Sub_Category",char(34),char(44),
    char(34),"Order Type",char(34),char(44),char(34),
    "Include Indicator",char(34),char(44),char(34),"Required Indicator",
    char(34),char(44),char(34),"Display",char(34),
    char(44),char(34),"DisplayID",char(34),char(44),
    char(34),"OrderSentID",char(34),char(44),char(34),
    "OrderSentDisp",char(34),char(44),char(34),"LongText",
    char(34),char(44)), col 0, ms_tline,
   row + 1
  DETAIL
   mf_parent_id = m_pp_orders->parent[d1.seq].f_parent_id, ms_s_disp = substring(1,1995,m_pp_orders->
    parent[d1.seq].orders[d2.seq].s_disp), mf_disp_id = m_pp_orders->parent[d1.seq].orders[d2.seq].
   f_disp_id,
   ms_cat = substring(1,50,m_pp_orders->parent[d1.seq].orders[d2.seq].s_cat), ms_sub_cat = substring(
    1,50,m_pp_orders->parent[d1.seq].orders[d2.seq].s_sub_cat), ms_ord_type = substring(1,3,
    m_pp_orders->parent[d1.seq].orders[d2.seq].s_ord_type),
   mf_seq = m_pp_orders->parent[d1.seq].orders[d2.seq].f_seq, mf_cat_seq = m_pp_orders->parent[d1.seq
   ].orders[d2.seq].f_cat_seq, mf_inc_ind = m_pp_orders->parent[d1.seq].orders[d2.seq].f_inc_ind,
   mf_req_ind = m_pp_orders->parent[d1.seq].orders[d2.seq].f_req_ind
   IF (size(m_pp_orders->parent[d1.seq].orders[d2.seq].ord_sent,5) > 0)
    mf_ord_sent_id = m_pp_orders->parent[d1.seq].orders[d2.seq].ord_sent[d3.seq].f_ord_sent_id,
    ms_ord_sent_disp = substring(1,1000,m_pp_orders->parent[d1.seq].orders[d2.seq].ord_sent[d3.seq].
     s_ord_sent_disp), ms_long_text = replace(substring(1,2000,m_pp_orders->parent[d1.seq].orders[d2
      .seq].ord_sent[d3.seq].s_long_text),"  ","")
   ENDIF
   IF (size(m_pp_orders->parent[d1.seq].orders[d2.seq].ord_sent,5) > 0)
    ms_tline = build(mf_seq,char(44),mf_cat_seq,char(44),mf_parent_id,
     char(44),char(34),ms_cat,char(34),char(44),
     char(34),ms_sub_cat,char(34),char(44),char(34),
     ms_ord_type,char(34),char(44),char(34),mf_inc_ind,
     char(34),char(44),char(34),mf_req_ind,char(34),
     char(44),char(34),trim(check(replace(replace(ms_s_disp,char(34),""),char(177),"")),3),char(34),
     char(44),
     mf_disp_id,char(44),mf_ord_sent_id,char(44),char(34),
     trim(check(replace(ms_ord_sent_disp,char(34),"")),3),char(34),char(44),char(34),trim(check(
       replace(ms_long_text,char(34),"")),3),
     char(34),char(44)), col 0, ms_tline,
    row + 1
   ELSE
    ms_tline = build(mf_seq,char(44),mf_cat_seq,char(44),mf_parent_id,
     char(44),char(34),ms_cat,char(34),char(44),
     char(34),ms_sub_cat,char(34),char(44),char(34),
     ms_ord_type,char(34),char(44),char(34),mf_inc_ind,
     char(34),char(44),char(34),mf_req_ind,char(34),
     char(44),char(34),trim(check(replace(ms_s_disp,char(34),"")),3),char(34),char(44),
     mf_disp_id,char(44),0,char(44),char(34),
     char(34),char(44),char(34),char(34),char(44)), col 0, ms_tline,
    row + 1
   ENDIF
  WITH maxcol = 32000, format = variable, formfeed = none,
   check, outerjoin = d2, outerjoin = d3
 ;end select
 IF (mn_email_ind=0)
  SET ms_type = "SENT FILE"
  SET ms_user_name = "transport"
  SET ms_server_name = "zxslorshdbpr03"
  SET ms_local_dir = "$CCLUSERDIR"
  SET ms_back_dir = "/u01/home/extracts/knowmgmtpp"
  SET ms_file_name_in = concat(ms_pp_output,".csv")
  SET ms_file_name_out = "ppn.txt"
  CALL sftpfile(ms_type,ms_file_name_in,ms_file_name_out,ms_user_name,ms_server_name,
   ms_local_dir,ms_back_dir)
  SET ms_file_name_in = concat(ms_phase_output,".csv")
  SET ms_file_name_out = "ppp.txt"
  CALL sftpfile(ms_type,ms_file_name_in,ms_file_name_out,ms_user_name,ms_server_name,
   ms_local_dir,ms_back_dir)
  SET ms_file_name_in = concat(ms_ord_output,".csv")
  SET ms_file_name_out = "ppo.txt"
  CALL sftpfile(ms_type,ms_file_name_in,ms_file_name_out,ms_user_name,ms_server_name,
   ms_local_dir,ms_back_dir)
 ELSE
  SET ms_file_name_in = concat(ms_pp_output,".csv")
  SET ms_file_name_out = "ppn.txt"
  CALL emailfile(ms_file_name_in,ms_file_name_out,mf_outdev,
   "Powerplan Extract Report Powerplan Names",1)
  SET ms_file_name_in = concat(ms_phase_output,".csv")
  SET ms_file_name_out = "ppp.txt"
  CALL emailfile(ms_file_name_in,ms_file_name_out,mf_outdev,
   "Powerplan Extract Report Powerplan Phases",1)
  SET ms_file_name_in = concat(ms_ord_output,".csv")
  SET ms_file_name_out = "ppo.txt"
  CALL emailfile(ms_file_name_in,ms_file_name_out,mf_outdev,
   "Powerplan Extract Report Powerplan Orders",1)
 ENDIF
 IF (( $L_SYNRPT=1))
  SET ms_syn_output = concat(trim("syn"),format(cnvtdatetime(sysdate),"MMDDYYYY;;d"))
  SELECT INTO "nl:"
   FROM pathway_catalog pcg,
    pw_cat_synonym pcs
   PLAN (pcg
    WHERE pcg.active_ind=1
     AND pcg.beg_effective_dt_tm <= cnvtdatetime(sysdate))
    JOIN (pcs
    WHERE pcs.primary_ind=0
     AND pcs.pathway_catalog_id=pcg.pathway_catalog_id)
   HEAD REPORT
    ml_pp_cnt = 0
   HEAD pcs.pw_cat_synonym_id
    ml_pp_cnt += 1
    IF (((mod(ml_pp_cnt,50)=1) OR (ml_pp_cnt=1)) )
     CALL alterlist(m_pp_syn->synonym,(ml_pp_cnt+ 49))
    ENDIF
    m_pp_syn->synonym[ml_pp_cnt].f_powerplan_catalog_id = pcs.pathway_catalog_id, m_pp_syn->synonym[
    ml_pp_cnt].f_powerplan_synonym_id = pcs.pw_cat_synonym_id, m_pp_syn->synonym[ml_pp_cnt].
    s_synonym_name = pcs.synonym_name
   FOOT REPORT
    CALL alterlist(m_pp_syn->synonym,ml_pp_cnt)
   WITH nocounter
  ;end select
  SELECT INTO concat(ms_syn_output,".csv")
   FROM (dummyt d1  WITH seq = value(size(m_pp_syn->synonym,5)))
   HEAD REPORT
    ms_tline = build(char(34),"PowerplanID",char(34),char(44),char(34),
     "SynonymID",char(34),char(44),char(34),"Synonym",
     char(34),char(44)), col 0, ms_tline,
    row + 1
   DETAIL
    mf_pp_cat_id = m_pp_syn->synonym[d1.seq].f_powerplan_catalog_id, mf_synonym_id = m_pp_syn->
    synonym[d1.seq].f_powerplan_synonym_id, ms_synonym_name = substring(1,30,m_pp_syn->synonym[d1.seq
     ].s_synonym_name),
    ms_tline = build(mf_pp_cat_id,char(44),mf_synonym_id,char(44),char(34),
     ms_synonym_name,char(34),char(44)), col 0, ms_tline,
    row + 1
   WITH maxcol = 32000, format = variable, formfeed = none,
    check
  ;end select
  IF (mn_email_ind=0)
   SET ms_type = "SENT FILE"
   SET ms_user_name = "transport"
   SET ms_server_name = "zxslorshdbpr03"
   SET ms_local_dir = "$CCLUSERDIR"
   SET ms_back_dir = "/u01/home/extracts/knowmgmtpp"
   SET ms_file_name_in = concat(ms_syn_output,".csv")
   SET ms_file_name_out = "pps.txt"
   CALL sftpfile(ms_type,ms_file_name_in,ms_file_name_out,ms_user_name,ms_server_name,
    ms_local_dir,ms_back_dir)
  ELSE
   SET ms_file_name_in = concat(ms_syn_output,".csv")
   SET ms_file_name_out = "pps.txt"
   CALL emailfile(ms_file_name_in,ms_file_name_out,mf_outdev,
    "Powerplan Extract Report Powerplan Synonym",1)
  ENDIF
 ENDIF
#exit_script
END GO
