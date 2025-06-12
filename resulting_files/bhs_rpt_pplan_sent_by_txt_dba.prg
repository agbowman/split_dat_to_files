CREATE PROGRAM bhs_rpt_pplan_sent_by_txt:dba
 PROMPT
  "Output to File/Printer/MINE/E-Mail" = "MINE",
  "Catalog Type:" = 0,
  "Mnemonic (wildcard * accepted):" = ""
  WITH outdev, f_cat_type_cd, s_mnemonic
 FREE RECORD m_powerplans
 RECORD m_powerplans(
   1 powerplans[*]
     2 s_powerplan_name = vc
     2 f_powerplan_catalog_id = f8
     2 orders[*]
       3 s_order_mnumonic = vc
       3 f_order_synonym_id = f8
       3 ord_sent[*]
         4 f_ord_sent_id = f8
         4 s_ord_sent_disp = vc
     2 phase[*]
       3 s_phase_name = vc
       3 f_phase_id = f8
       3 l_phase_cnt = i4
       3 orders[*]
         4 s_order_mnumonic = vc
         4 f_order_synonym_id = f8
         4 l_order_cnt = i4
         4 ord_sent[*]
           5 f_ord_sent_id = f8
           5 s_ord_sent_disp = vc
 ) WITH protect
 DECLARE mf_cat_typ_cd = f8 WITH protect, constant(cnvtreal( $F_CAT_TYPE_CD))
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_sent_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_pp_desc = vc WITH protect, noconstant(" ")
 SUBROUTINE (emailcheck(mn_email_ind=i2) =null WITH protect)
   IF (mn_email_ind=1)
    SET ms_filename_in = trim(concat(ms_output_dest,".dat"))
    SET ms_filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
    EXECUTE bhs_ma_email_file
    CALL emailfile(ms_filename_in,ms_filename_out, $S_MNEMONIC,concat(curprog,
      "- Baystate Medical Center Powerplan Order Sentence Detail"),1)
   ENDIF
 END ;Subroutine
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 CALL echo("select 1")
 SELECT INTO "nl:"
  FROM pathway_catalog pcg,
   pw_cat_reltn pcr,
   pathway_catalog pcg1,
   pathway_comp pwc,
   pw_comp_os_reltn pc,
   order_sentence os,
   order_catalog_synonym ocs
  PLAN (pcg
   WHERE pcg.type_mean IN ("PATHWAY", "CAREPLAN")
    AND pcg.active_ind=1)
   JOIN (pcr
   WHERE (pcr.pw_cat_s_id= Outerjoin(pcg.pathway_catalog_id)) )
   JOIN (pcg1
   WHERE (pcg1.pathway_catalog_id= Outerjoin(pcr.pw_cat_t_id))
    AND (pcg1.active_ind= Outerjoin(1)) )
   JOIN (pwc
   WHERE (pwc.pathway_catalog_id= Outerjoin(pcg1.pathway_catalog_id))
    AND (pwc.parent_entity_name= Outerjoin("ORDER_CATALOG_SYNONYM"))
    AND (pwc.active_ind= Outerjoin(1)) )
   JOIN (ocs
   WHERE ocs.synonym_id=pwc.parent_entity_id
    AND ocs.catalog_type_cd=mf_cat_typ_cd
    AND ocs.active_ind=1)
   JOIN (pc
   WHERE (pc.pathway_comp_id= Outerjoin(pwc.pathway_comp_id)) )
   JOIN (os
   WHERE (os.order_sentence_id= Outerjoin(pc.order_sentence_id)) )
  ORDER BY pcg.description, pcg1.description, ocs.mnemonic
  HEAD REPORT
   ml_pp_cnt = 0
  HEAD pcg.pathway_catalog_id
   CALL echo(build2("head 1 ",pcg.description)), ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->
     powerplans,5),pcg.pathway_catalog_id,m_powerplans->powerplans[ml_cnt].f_powerplan_catalog_id)
   IF (ml_pp_pos=0)
    CALL echo("add"), ml_pp_cnt += 1
    IF (ml_pp_cnt > size(m_powerplans->powerplans,5))
     CALL alterlist(m_powerplans->powerplans,(ml_pp_cnt+ 49))
    ENDIF
    m_powerplans->powerplans[ml_pp_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
    powerplans[ml_pp_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, ml_phase_cnt = 0,
    ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pcg.pathway_catalog_id,
     m_powerplans->powerplans[ml_cnt].f_powerplan_catalog_id)
   ENDIF
  HEAD pcg1.pathway_catalog_id
   CALL echo(build2("head 2 ",pcg1.description))
   IF (pcg1.pathway_catalog_id > 0)
    ml_phase_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].phase,5),pcg1
     .pathway_catalog_id,m_powerplans->powerplans[ml_pp_pos].phase[ml_cnt].f_phase_id)
    IF (ml_phase_pos=0)
     CALL echo("add"), ml_phase_cnt += 1
     IF (ml_phase_cnt > size(m_powerplans->powerplans[ml_pp_pos].phase,5))
      CALL alterlist(m_powerplans->powerplans[ml_pp_pos].phase,(ml_phase_cnt+ 19))
     ENDIF
     m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_cnt].s_phase_name = pcg1.description_key,
     m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_cnt].f_phase_id = pcg1.pathway_catalog_id,
     ml_ord_cnt = 0,
     ml_phase_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].phase,5),pcg1
      .pathway_catalog_id,m_powerplans->powerplans[ml_pp_pos].phase[ml_cnt].f_phase_id)
    ENDIF
   ENDIF
  HEAD pwc.parent_entity_id
   CALL echo("head 3")
   IF (pcg1.pathway_catalog_id > 0)
    ml_ord_cnt += 1,
    CALL echo(build2(mod(ml_ord_cnt,20)," ",ml_ord_cnt))
    IF (ml_ord_cnt > size(m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders,5))
     CALL echo("alter"),
     CALL alterlist(m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders,(ml_ord_cnt+ 19))
    ENDIF
    CALL echo(build2("ml_pp_pos: ",ml_pp_pos," ",size(m_powerplans->powerplans,5))),
    CALL echo(build2("ml_phase_pos: ",ml_phase_pos," ",size(m_powerplans->powerplans[ml_pp_pos].phase,
      5))),
    CALL echo(build2("ml_ord_cnt: ",ml_ord_cnt," ",size(m_powerplans->powerplans[ml_pp_pos].phase[
      ml_phase_pos].orders,5))),
    m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[ml_ord_cnt].s_order_mnumonic = ocs
    .mnemonic, m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[ml_ord_cnt].
    f_order_synonym_id = ocs.synonym_id, ml_ord_sent_cnt = 0
   ENDIF
  HEAD pc.order_sentence_id
   CALL echo("head 4"), ml_ord_sent_cnt += 1
   IF (ml_ord_sent_cnt > size(m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[
    ml_ord_cnt].ord_sent,5))
    CALL alterlist(m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[ml_ord_cnt].
    ord_sent,(ml_ord_sent_cnt+ 19))
   ENDIF
   m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[ml_ord_cnt].ord_sent[
   ml_ord_sent_cnt].f_ord_sent_id = os.order_sentence_id, m_powerplans->powerplans[ml_pp_pos].phase[
   ml_phase_pos].orders[ml_ord_cnt].ord_sent[ml_ord_sent_cnt].s_ord_sent_disp = os
   .order_sentence_display_line
  FOOT  pcg.pathway_catalog_id
   CALL alterlist(m_powerplans->powerplans[ml_pp_pos].phase,ml_phase_cnt)
  FOOT  pcg1.pathway_catalog_id
   CALL alterlist(m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders,ml_ord_cnt)
  FOOT  pwc.parent_entity_id
   CALL alterlist(m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[ml_ord_cnt].ord_sent,
   ml_ord_sent_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway_catalog pcg,
   pathway_comp pwc,
   pw_comp_os_reltn pc,
   order_sentence os,
   order_catalog_synonym ocs
  PLAN (pcg
   WHERE pcg.type_mean IN ("PATHWAY", "CAREPLAN")
    AND pcg.active_ind=1)
   JOIN (pwc
   WHERE pwc.pathway_catalog_id=pcg.pathway_catalog_id
    AND pwc.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND pwc.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=pwc.parent_entity_id
    AND ocs.catalog_type_cd=mf_cat_typ_cd
    AND ocs.active_ind=1)
   JOIN (pc
   WHERE (pc.pathway_comp_id= Outerjoin(pwc.pathway_comp_id)) )
   JOIN (os
   WHERE (os.order_sentence_id= Outerjoin(pc.order_sentence_id)) )
  ORDER BY pcg.description, ocs.mnemonic
  HEAD pwc.pathway_catalog_id
   ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pwc.pathway_catalog_id,
    m_powerplans->powerplans[ml_cnt].f_powerplan_catalog_id)
   IF (ml_pp_pos=0)
    ml_pp_cnt += 1
    IF (ml_pp_cnt > size(m_powerplans->powerplans,5))
     CALL alterlist(m_powerplans->powerplans,(ml_pp_cnt+ 49))
    ENDIF
    m_powerplans->powerplans[ml_pp_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
    powerplans[ml_pp_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, ml_pp_pos = locateval(
     ml_cnt,1,size(m_powerplans->powerplans,5),pwc.pathway_catalog_id,m_powerplans->powerplans[ml_cnt
     ].f_powerplan_catalog_id)
   ENDIF
   ml_ord_cnt = 0
  HEAD pwc.parent_entity_id
   ml_ord_cnt += 1
   IF (ml_ord_cnt > size(m_powerplans->powerplans[ml_pp_pos].orders,5))
    CALL alterlist(m_powerplans->powerplans[ml_pp_pos].orders,(ml_ord_cnt+ 19))
   ENDIF
   m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_cnt].s_order_mnumonic = ocs.mnemonic,
   m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_cnt].f_order_synonym_id = ocs.synonym_id,
   ml_ord_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].orders,5),ocs.synonym_id,
    m_powerplans->powerplans[ml_pp_pos].orders[ml_cnt].f_order_synonym_id),
   ml_ord_sent_cnt = 0
  HEAD pc.order_sentence_id
   ml_ord_sent_cnt += 1
   IF (ml_ord_sent_cnt > size(m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_pos].ord_sent,5))
    CALL alterlist(m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_pos].ord_sent,(ml_ord_sent_cnt+
    19))
   ENDIF
   m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_pos].ord_sent[ml_ord_sent_cnt].f_ord_sent_id =
   os.order_sentence_id, m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_pos].ord_sent[
   ml_ord_sent_cnt].s_ord_sent_disp = os.order_sentence_display_line
  FOOT  pwc.pathway_catalog_id
   CALL alterlist(m_powerplans->powerplans[ml_pp_pos].orders,ml_ord_cnt)
  FOOT  pwc.parent_entity_id
   CALL alterlist(m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_pos].ord_sent,ml_ord_sent_cnt)
  FOOT REPORT
   CALL alterlist(m_powerplans->powerplans,ml_pp_cnt)
  WITH nocounter
 ;end select
 IF (mn_email_ind=1)
  SELECT INTO value(ms_output_dest)
   ms_pp_desc = m_powerplans->powerplans[d1.seq].s_powerplan_name, pp_id = m_powerplans->powerplans[
   d1.seq].f_powerplan_catalog_id
   FROM (dummyt d1  WITH seq = size(m_powerplans->powerplans,5))
   ORDER BY ms_pp_desc
   HEAD REPORT
    ms_outstring = ',"BHS Order Sent Detail"', col 1, ms_outstring,
    row + 1, ms_outstring = build('"Powerplan Name","Phase Name","Order Name","Order Sentence"'), col
     1,
    ms_outstring, row + 1
   HEAD pp_id
    FOR (ml_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].orders,5))
      FOR (ml_ord_sent_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].orders[ml_cnt].ord_sent,5))
        ms_outstring = build('"',m_powerplans->powerplans[d1.seq].s_powerplan_name,'",','"",','"',
         m_powerplans->powerplans[d1.seq].orders[ml_cnt].s_order_mnumonic,'",','"',m_powerplans->
         powerplans[d1.seq].orders[ml_cnt].ord_sent[ml_ord_sent_cnt].s_ord_sent_disp,'"'), col 1,
        ms_outstring,
        row + 1
      ENDFOR
    ENDFOR
    IF (size(m_powerplans->powerplans[d1.seq].phase,5) > 0)
     FOR (ml_phase_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].phase,5))
       FOR (ml_ord_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].orders,5))
         FOR (ml_ord_sent_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].
          orders[ml_ord_cnt].ord_sent,5))
           ms_outstring = build('"',m_powerplans->powerplans[d1.seq].s_powerplan_name,'",','"',
            m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].s_phase_name,
            '",','"',m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].orders[ml_ord_cnt].
            s_order_mnumonic,'","',m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].orders[
            ml_ord_cnt].ord_sent[ml_ord_sent_cnt].s_ord_sent_disp,
            '"'), col 1, ms_outstring,
           row + 1
         ENDFOR
       ENDFOR
     ENDFOR
    ENDIF
   WITH nocounter, maxrow = 1, maxcol = 400
  ;end select
  CALL emailcheck(mn_email_ind)
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 pplan[*]
     2 s_plan_name = vc
     2 s_phase_name = vc
     2 s_order_name = vc
     2 s_order_sentence = vc
 )
 DECLARE ml_loop1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop3 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop4 = i4 WITH protect, noconstant(0)
 SET ml_cnt = 0
 FOR (ml_loop1 = 1 TO size(m_powerplans->powerplans,5))
   FOR (ml_loop2 = 1 TO size(m_powerplans->powerplans[ml_loop1].orders,5))
     FOR (ml_loop3 = 1 TO size(m_powerplans->powerplans[ml_loop1].orders[ml_loop2].ord_sent,5))
       SET ml_cnt += 1
       CALL alterlist(m_rec->pplan,ml_cnt)
       SET m_rec->pplan[ml_cnt].s_plan_name = m_powerplans->powerplans[ml_loop1].s_powerplan_name
       SET m_rec->pplan[ml_cnt].s_order_name = m_powerplans->powerplans[ml_loop1].orders[ml_loop2].
       s_order_mnumonic
       SET m_rec->pplan[ml_cnt].s_order_sentence = m_powerplans->powerplans[ml_loop1].orders[ml_loop2
       ].ord_sent[ml_loop3].s_ord_sent_disp
     ENDFOR
   ENDFOR
 ENDFOR
 SET ml_cnt = size(m_rec->pplan,5)
 FOR (ml_loop1 = 1 TO size(m_powerplans->powerplans,5))
   FOR (ml_loop2 = 1 TO size(m_powerplans->powerplans[ml_loop1].phase,5))
     FOR (ml_loop3 = 1 TO size(m_powerplans->powerplans[ml_loop1].phase[ml_loop2].orders,5))
       FOR (ml_loop4 = 1 TO size(m_powerplans->powerplans[ml_loop1].phase[ml_loop2].orders[ml_loop3].
        ord_sent,5))
         SET ml_cnt += 1
         CALL alterlist(m_rec->pplan,ml_cnt)
         SET m_rec->pplan[ml_cnt].s_plan_name = m_powerplans->powerplans[ml_loop1].s_powerplan_name
         SET m_rec->pplan[ml_cnt].s_phase_name = m_powerplans->powerplans[ml_loop1].phase[ml_loop2].
         s_phase_name
         SET m_rec->pplan[ml_cnt].s_order_name = m_powerplans->powerplans[ml_loop1].phase[ml_loop2].
         orders[ml_loop3].s_order_mnumonic
         SET m_rec->pplan[ml_cnt].s_order_sentence = m_powerplans->powerplans[ml_loop1].phase[
         ml_loop2].orders[ml_loop3].ord_sent[ml_loop4].s_ord_sent_disp
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO value( $OUTDEV)
  powerplan_name = substring(1,100,m_rec->pplan[d1.seq].s_plan_name), phase_name = substring(1,100,
   m_rec->pplan[d1.seq].s_phase_name), order_name = substring(1,100,m_rec->pplan[d1.seq].s_order_name
   ),
  order_sentence = substring(1,250,m_rec->pplan[d1.seq].s_order_sentence)
  FROM (dummyt d1  WITH seq = value(size(m_rec->pplan,5)))
  PLAN (d1)
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
 CALL echorecord(m_rec)
END GO
