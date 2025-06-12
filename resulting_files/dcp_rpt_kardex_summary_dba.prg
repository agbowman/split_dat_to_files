CREATE PROGRAM dcp_rpt_kardex_summary:dba
 SET temp_cd = 5645091
 SET pulse_cd = 5645092
 SET resp_cd = 0
 SET sbp_cd = 5645093
 SET dbp_cd = 5645094
 SET ox_cd = 227503
 SET note_cd = 227461
 SET daily_lab_cd = 227357
 SET cont_ord_cd = 227348
 SET limit_ord_cd = 227469
 SET code_cd = 227342
 SET emergcon_cd = 227385
 SET hmphone_cd = 227345
 SET wkphone_cd = 227347
 SET pager_cd = 227346
 SET cell_cd = 227344
 SET diag_cd = 227366
 SET activity_cd = 227276
 SET diet_cd = 227368
 SET iv_cd = 227455
 SET o2_cd = 227520
 SET mode_cd = 227634
 SET iando_cd = 227453
 SET elim_cd = 227418
 SET restrict_cd = 227580
 SET prec_cd = 227540
 SET need_cd = 227619
 SET lang_cd = 227463
 SET relig_cd = 227573
 SET will_cd = 227472
 SET direct_cd = 227291
 SET loc_cd = 227474
 SET ord_catalog_cd = 131841
 SET ord_status1_cd = 1069
 SET ord_status2_cd = 1070
 SET ord_status3_cd = 121925
 RECORD temp(
   1 code = vc
   1 contact = vc
   1 chp = vc
   1 cwp = vc
   1 cp = vc
   1 cc = vc
   1 diag = vc
   1 act = vc
   1 diet = vc
   1 ivther = vc
   1 o2 = vc
   1 mode = vc
   1 iando = vc
   1 elim = vc
   1 fluidrx = vc
   1 prec = vc
   1 prec_list_ln_cnt = i2
   1 prec_list_tag[*]
     2 prec_list_line = vc
   1 special = vc
   1 spec_list_ln_cnt = i2
   1 spec_list_tag[*]
     2 spec_list_line = vc
   1 lang = vc
   1 relig = vc
   1 livwil = vc
   1 advdir = vc
   1 advdirloc = vc
   1 allergy_cnt = i2
   1 allergy[*]
     2 string = vc
     2 onset = vc
     2 reaction = vc
   1 order_mnemonic = vc
   1 order_details = vc
   1 v[5]
     2 dt = vc
     2 t = vc
     2 p = vc
     2 r = vc
     2 s = vc
     2 d = vc
     2 ox = vc
   1 note = vc
   1 note_list_ln_cnt = i2
   1 note_list_tag[*]
     2 note_list_line = vc
   1 dailylabs = vc
   1 lab_list_ln_cnt = i2
   1 lab_list_tag[*]
     2 lab_list_line = vc
   1 contords = vc
   1 cont_list_ln_cnt = i2
   1 cont_list_tag[*]
     2 cont_list_line = vc
   1 lmtdords = vc
   1 lmt_list_ln_cnt = i2
   1 lmt_list_tag[*]
     2 lmt_list_line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET xcol = 0
 SET ycol = 0
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
 SET yyy = fillstring(60," ")
 SET lf = concat(char(13),char(10))
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET ocfcomp_cd = 0.0
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SET canceled_cd = 0.0
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET inerror_cd = 0.0
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET person_id = 0.0
 SET visit_cnt = 1
 SET blob_out = fillstring(255," ")
 FOR (x = 1 TO visit_cnt)
   SELECT INTO "nl:"
    e.seq
    FROM encounter e
    WHERE (e.encntr_id=request->visit[x].encntr_id)
    DETAIL
     person_id = e.person_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    c.clinical_event_id, c.event_cd, c.event_end_dt_tm
    FROM clinical_event c
    PLAN (c
     WHERE (c.encntr_id=request->visit[x].encntr_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd IN (code_cd, emergcon_cd, hmphone_cd, wkphone_cd, pager_cd,
     cell_cd, diag_cd, activity_cd, diet_cd, iv_cd,
     o2_cd, mode_cd, iando_cd, elim_cd, restrict_cd,
     prec_cd, need_cd, lang_cd, relig_cd, will_cd,
     direct_cd, loc_cd)
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    ORDER BY c.event_cd, c.event_end_dt_tm DESC
    HEAD REPORT
     blob_out = fillstring(255," ")
    HEAD c.event_cd
     IF (c.event_cd=code_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->code = blob_out
     ELSEIF (c.event_cd=mode_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->mode = blob_out
     ELSEIF (c.event_cd=o2_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->o2 = blob_out
     ELSEIF (c.event_cd=iv_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->ivther = blob_out
     ELSEIF (c.event_cd=activity_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->act = blob_out
     ELSEIF (c.event_cd=elim_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->elim = blob_out
     ELSEIF (c.event_cd=diet_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->diet = blob_out
     ELSEIF (c.event_cd=iando_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->iando = blob_out
     ELSEIF (c.event_cd=restrict_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->fluidrx = blob_out
     ELSEIF (c.event_cd=need_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->special = blob_out
     ELSEIF (c.event_cd=emergcon_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->contact = blob_out
     ELSEIF (c.event_cd=hmphone_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->chp = blob_out
     ELSEIF (c.event_cd=wkphone_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->cwp = blob_out
     ELSEIF (c.event_cd=diag_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->diag = blob_out
     ELSEIF (c.event_cd=prec_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->prec = blob_out
     ELSEIF (c.event_cd=lang_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->lang = blob_out
     ELSEIF (c.event_cd=will_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->livwil = blob_out
     ELSEIF (c.event_cd=relig_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->relig = blob_out
     ELSEIF (c.event_cd=direct_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->advdir = blob_out
     ELSEIF (c.event_cd=pager_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->cp = blob_out
     ELSEIF (c.event_cd=cell_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->cc = blob_out
     ELSEIF (c.event_cd=loc_cd)
      blob_out = c.event_tag, a = findstring(lf,blob_out)
      WHILE (a > 0)
       stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
      ENDWHILE
      temp->advdirloc = blob_out
     ENDIF
    WITH nocounter
   ;end select
   SET pt->line_cnt = 0
   SET max_length = 110
   EXECUTE dcp_parse_text value(temp->special), value(max_length)
   SET stat = alterlist(temp->spec_list_tag,pt->line_cnt)
   SET temp->spec_list_ln_cnt = pt->line_cnt
   FOR (e = 1 TO pt->line_cnt)
     SET temp->spec_list_tag[e].spec_list_line = pt->lns[e].line
   ENDFOR
   SET pt->line_cnt = 0
   SET max_length = 110
   EXECUTE dcp_parse_text value(temp->prec), value(max_length)
   SET stat = alterlist(temp->prec_list_tag,pt->line_cnt)
   SET temp->prec_list_ln_cnt = pt->line_cnt
   FOR (e = 1 TO pt->line_cnt)
     SET temp->prec_list_tag[e].prec_list_line = pt->lns[e].line
   ENDFOR
   SELECT INTO "nl"
    a.allergy_id
    FROM allergy a,
     (dummyt d1  WITH seq = 1),
     nomenclature n,
     (dummyt d2  WITH seq = 1),
     reaction r,
     (dummyt d3  WITH seq = 1),
     nomenclature n2
    PLAN (a
     WHERE a.person_id=person_id
      AND a.active_ind=1
      AND a.reaction_status_cd != canceled_cd
      AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null
     )) )
     JOIN (d1)
     JOIN (n
     WHERE n.nomenclature_id=a.substance_nom_id)
     JOIN (d2)
     JOIN (r
     WHERE a.allergy_instance_id=r.allergy_instance_id
      AND r.active_ind=1)
     JOIN (d3)
     JOIN (n2
     WHERE n2.nomenclature_id=r.reaction_nom_id)
    ORDER BY a.onset_dt_tm
    HEAD REPORT
     count = 0
    DETAIL
     IF (((n.source_string > " ") OR (a.substance_ftdesc > " "))
      AND a.onset_dt_tm != null)
      count = (count+ 1), temp->allergy_cnt = count, stat = alterlist(temp->allergy,count),
      temp->allergy[count].string = a.substance_ftdesc
      IF (n.source_string > " ")
       temp->allergy[count].string = n.source_string
      ENDIF
      temp->allergy[count].onset = format(a.onset_dt_tm,"mm/dd/yyyy;;d")
      IF (((r.reaction_ftdesc > " ") OR (n2.source_string > " ")) )
       temp->allergy[count].reaction = r.reaction_ftdesc
       IF (n2.source_string > " ")
        temp->allergy[count].reaction = n2.source_string
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d1, dontcare = n,
     dontcare = r, outerjoin = d2, dontcare = n2
   ;end select
   SET temp->order_mnemonic = "Vital Signs"
   SET temp->order_details = "No active order found."
   SELECT INTO "nl:"
    o.orig_order_dt_tm
    FROM orders o
    PLAN (o
     WHERE (o.encntr_id=request->visit[x].encntr_id)
      AND o.catalog_cd=ord_catalog_cd
      AND o.order_status_cd IN (ord_status1_cd, ord_status2_cd, ord_status3_cd))
    ORDER BY cnvtdatetime(o.orig_order_dt_tm) DESC
    HEAD REPORT
     cnt = 0
    HEAD o.orig_order_dt_tm
     IF (cnt=0)
      temp->order_mnemonic = o.order_mnemonic, temp->order_details = o.order_detail_display_line, cnt
       = 1
     ENDIF
    DETAIL
     row + 0
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    c.event_cd, c.event_end_dt_tm
    FROM clinical_event c
    PLAN (c
     WHERE (c.encntr_id=request->visit[x].encntr_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd IN (temp_cd, resp_cd, pulse_cd, dbp_cd, sbp_cd,
     ox_cd)
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
      AND c.result_status_cd != inerror_cd)
    ORDER BY c.event_end_dt_tm DESC
    HEAD REPORT
     vidx = 0, holdd1 = 0.0, holdd2 = 0.0,
     holdd3 = 0.0
    DETAIL
     holdd1 = cnvtdatetime(c.event_end_dt_tm), holdd3 = abs((holdd1 - holdd2))
     IF (((holdd3/ 10000000) > 60))
      vidx = (vidx+ 1)
     ENDIF
     holdd2 = holdd1
     IF (vidx < 6)
      temp->v[vidx].dt = format(c.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
      IF (c.event_cd=temp_cd)
       temp->v[vidx].t = trim(c.event_tag)
      ELSEIF (c.event_cd=pulse_cd)
       temp->v[vidx].p = trim(c.event_tag)
      ELSEIF (c.event_cd=resp_cd)
       temp->v[vidx].r = trim(c.event_tag)
      ELSEIF (c.event_cd=sbp_cd)
       temp->v[vidx].s = trim(c.event_tag)
      ELSEIF (c.event_cd=dbp_cd)
       temp->v[vidx].d = trim(c.event_tag)
      ELSEIF (c.event_cd=ox_cd)
       temp->v[vidx].ox = trim(c.event_tag)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    c.event_cd, c.event_end_dt_tm
    FROM clinical_event c,
     ce_blob_result cbr,
     ce_blob cb
    PLAN (c
     WHERE (c.encntr_id=request->visit[x].encntr_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd=note_cd
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
     JOIN (cbr
     WHERE cbr.event_id=c.event_id
      AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
     JOIN (cb
     WHERE cb.event_id=cbr.event_id
      AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    ORDER BY c.event_cd, c.event_end_dt_tm DESC
    HEAD c.event_cd
     blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_out2 = fillstring(32000," "), blob_ret_len = 0, sze = textlen(cb.blob_contents),
      CALL uar_ocf_uncompress(cb.blob_contents,textlen(cb.blob_contents),blob_out2,32000,blob_ret_len
      )
     ELSE
      blob_out2 = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out2 = substring(1,(
       y1 - 8),cb.blob_contents)
     ENDIF
     CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0), a = findstring(lf,blob_out3)
     WHILE (a > 0)
      stat = movestring("--",1,blob_out3,a,2),a = findstring(lf,blob_out3)
     ENDWHILE
     temp->note = blob_out3
    WITH nocounter
   ;end select
   SET pt->line_cnt = 0
   SET max_length = 150
   EXECUTE dcp_parse_text value(temp->note), value(max_length)
   SET stat = alterlist(temp->note_list_tag,pt->line_cnt)
   SET temp->note_list_ln_cnt = pt->line_cnt
   FOR (e = 1 TO pt->line_cnt)
     SET temp->note_list_tag[e].note_list_line = pt->lns[e].line
   ENDFOR
   SELECT INTO "nl:"
    c.clinical_event_id, c.event_cd, c.event_end_dt_tm
    FROM clinical_event c
    PLAN (c
     WHERE (c.encntr_id=request->visit[x].encntr_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd=daily_lab_cd
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    ORDER BY c.event_end_dt_tm DESC
    HEAD REPORT
     blob_out = fillstring(255," ")
    HEAD c.event_cd
     blob_out = c.event_tag, a = findstring(lf,blob_out)
     WHILE (a > 0)
      stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
     ENDWHILE
     temp->dailylabs = blob_out
    WITH nocounter
   ;end select
   SET pt->line_cnt = 0
   SET max_length = 150
   EXECUTE dcp_parse_text value(temp->dailylabs), value(max_length)
   SET stat = alterlist(temp->lab_list_tag,pt->line_cnt)
   SET temp->lab_list_ln_cnt = pt->line_cnt
   FOR (e = 1 TO pt->line_cnt)
     SET temp->lab_list_tag[e].lab_list_line = pt->lns[e].line
   ENDFOR
   SELECT INTO "nl:"
    c.clinical_event_id, c.event_cd, c.event_end_dt_tm
    FROM clinical_event c
    PLAN (c
     WHERE (c.encntr_id=request->visit[x].encntr_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd=cont_ord_cd
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    ORDER BY c.event_end_dt_tm DESC
    HEAD c.event_cd
     blob_out = c.event_tag, a = findstring(lf,blob_out)
     WHILE (a > 0)
      stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
     ENDWHILE
     temp->contords = blob_out
    WITH nocounter
   ;end select
   SET pt->line_cnt = 0
   SET max_length = 150
   EXECUTE dcp_parse_text value(temp->contords), value(max_length)
   SET stat = alterlist(temp->cont_list_tag,pt->line_cnt)
   SET temp->cont_list_ln_cnt = pt->line_cnt
   FOR (e = 1 TO pt->line_cnt)
     SET temp->cont_list_tag[e].cont_list_line = pt->lns[e].line
   ENDFOR
   SELECT INTO "nl:"
    c.clinical_event_id, c.event_cd, c.event_end_dt_tm
    FROM clinical_event c
    PLAN (c
     WHERE (c.encntr_id=request->visit[x].encntr_id)
      AND c.view_level=1
      AND c.publish_flag=1
      AND c.event_cd=limit_ord_cd
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
    ORDER BY c.event_end_dt_tm DESC
    HEAD c.event_cd
     blob_out = c.event_tag, a = findstring(lf,blob_out)
     WHILE (a > 0)
      stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
     ENDWHILE
     temp->lmtdords = blob_out
    WITH nocounter
   ;end select
   SET pt->line_cnt = 0
   SET max_length = 150
   EXECUTE dcp_parse_text value(temp->lmtdords), value(max_length)
   SET stat = alterlist(temp->lmt_list_tag,pt->line_cnt)
   SET temp->lmt_list_ln_cnt = pt->line_cnt
   FOR (e = 1 TO pt->line_cnt)
     SET temp->lmt_list_tag[e].lmt_list_line = pt->lns[e].line
   ENDFOR
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
      AND epr.encntr_prsnl_r_cd=attend_doc_cd
      AND epr.active_ind=1
      AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
     JOIN (d3)
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.encntr_alias_type_cd=finnbr_cd)
     JOIN (pl
     WHERE pl.person_id=epr.prsnl_person_id)
    HEAD REPORT
     name = substring(1,30,p.name_full_formatted), age = cnvtage(cnvtdate(p.birth_dt_tm),curdate),
     dob = format(p.birth_dt_tm,"mm/dd/yy;;d"),
     mrn = substring(1,20,pa.alias), finnbr = substring(1,20,ea.alias), admitdoc = substring(1,30,pl
      .name_full_formatted),
     unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,10,
      uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,uar_get_code_display(e.loc_bed_cd))
    DETAIL
     reg_dt_tm = cnvtdatetime(e.reg_dt_tm)
    WITH nocounter, outerjoin = d1, dontcare = pa,
     dontcare = epr, outerjoin = d2, outerjoin = d3,
     dontcare = ea
   ;end select
   SELECT INTO request->output_device
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     thead = "                                                  "
    HEAD PAGE
     "{pos/60/55}{f/12}Patient Name:  ", name, row + 1,
     "{pos/60/67}Date of Birth:  ", dob, row + 1,
     "{pos/60/79}Admitting Physician:  ", admitdoc, row + 1,
     xxx = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)), "{pos/320/55}Med Rec Num:  ", mrn,
     row + 1, "{pos/320/67}Age:  ", age,
     row + 1, "{pos/320/79}Location:  ", xxx,
     row + 1, "{pos/320/91}Financial Num: ", finnbr,
     row + 1, "{pos/260/120}{f/13}{u}KARDEX SUMMARY", row + 1
     IF (thead > " ")
      "{pos/65/140}{f/9}{u}", thead, row + 1
     ENDIF
     xcol = 65, ycol = 140
    DETAIL
     xcol = 65, ycol = 140,
     CALL print(calcpos(xcol,ycol)),
     "{f/9}{cpi/16}PATIENT INFORMATION", row + 1, ycol = (ycol+ 12),
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/16}Code Status:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->code,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Allergies:"
     IF ((temp->allergy_cnt > 0))
      FOR (z = 1 TO temp->allergy_cnt)
        xcol = 190,
        CALL print(calcpos(xcol,ycol)), temp->allergy[z].string
        IF ((temp->allergy[z].reaction > " "))
         xcol = 350,
         CALL print(calcpos(xcol,ycol)), "Reaction: ",
         temp->allergy[z].reaction
        ENDIF
        row + 1, ycol = (ycol+ 12)
      ENDFOR
     ELSE
      xcol = 190,
      CALL print(calcpos(xcol,ycol)), "No Known Allergies",
      row + 1, ycol = (ycol+ 12)
     ENDIF
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Emegency Contact:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->contact,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Contact Home Phone:", xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->chp, row + 1,
     ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)),
     "Contact Work Phone:", xcol = 190,
     CALL print(calcpos(xcol,ycol)),
     temp->cwp, row + 1, ycol = (ycol+ 12),
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Contact Pager:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->cp,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Contact Cellular:", xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->cc, row + 1,
     ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)),
     "Diagnoses:", xcol = 190,
     CALL print(calcpos(xcol,ycol)),
     temp->diag, row + 1, ycol = (ycol+ 12),
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Activity:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->act,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Diet:", xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->diet, row + 1,
     ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)),
     "IV Therapy:", xcol = 190,
     CALL print(calcpos(xcol,ycol)),
     temp->ivther, row + 1, ycol = (ycol+ 12),
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "O2:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->o2,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Mode of Transport:", xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->mode, row + 1,
     ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)),
     "I&O:", xcol = 190,
     CALL print(calcpos(xcol,ycol)),
     temp->iando, row + 1, ycol = (ycol+ 12),
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Elimination:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->elim,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Restrictions:", xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->fluidrx, row + 1,
     ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)),
     "Precautions:", xcol = 190
     FOR (z = 1 TO temp->prec_list_ln_cnt)
       CALL print(calcpos(xcol,ycol)), temp->prec_list_tag[z].prec_list_line, row + 1,
       ycol = (ycol+ 12)
     ENDFOR
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Special Needs:",
     xcol = 190
     FOR (z = 1 TO temp->spec_list_ln_cnt)
       CALL print(calcpos(xcol,ycol)), temp->spec_list_tag[z].spec_list_line, row + 1,
       ycol = (ycol+ 12)
     ENDFOR
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Language Spoken:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->lang,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Religion:", xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->relig, row + 1,
     ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)),
     "Living Will:", xcol = 190,
     CALL print(calcpos(xcol,ycol)),
     temp->livwil, row + 1, ycol = (ycol+ 12),
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Advance Directive:",
     xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->advdir,
     row + 1, ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "Advance Directive Location:", xcol = 190,
     CALL print(calcpos(xcol,ycol)), temp->advdirloc, row + 1,
     ycol = (ycol+ 12), ycol = (ycol+ 12), xcol = 65,
     CALL print(calcpos(xcol,ycol)), "{f/9}{cpi/16}VITAL SIGNS", row + 1,
     xcol = 65, ycol = (ycol+ 12)
     FOR (z = 1 TO 5)
       IF ((temp->v[z].dt > " "))
        xcol = 65,
        CALL print(calcpos(xcol,ycol)), temp->v[z].dt,
        xcol = 150,
        CALL print(calcpos(xcol,ycol)), "  T: ",
        temp->v[z].t, xcol = 200,
        CALL print(calcpos(xcol,ycol)),
        "  P: ", temp->v[z].p, xcol = 250,
        CALL print(calcpos(xcol,ycol)), "  R: ", temp->v[z].r,
        xcol = 300,
        CALL print(calcpos(xcol,ycol)), "  BP: ",
        temp->v[z].s, "/", temp->v[z].d,
        xcol = 350,
        CALL print(calcpos(xcol,ycol)), "  Pulse Ox: ",
        temp->v[z].ox, row + 1, ycol = (ycol+ 12)
       ENDIF
     ENDFOR
     IF (ycol > 700)
      BREAK
     ENDIF
     thead = " ", ycol = (ycol+ 12)
     IF (ycol > 680)
      BREAK
     ENDIF
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "{f/9}{cpi/16}KARDEX NOTE{f/8}{cpi/16}",
     row + 1, thead = "KARDEX NOTE(cont.)"
     FOR (z = 1 TO temp->note_list_ln_cnt)
       ycol = (ycol+ 12), xcol = 65,
       CALL print(calcpos(xcol,ycol)),
       temp->note_list_tag[z].note_list_line, row + 1
       IF (ycol > 700)
        BREAK
       ENDIF
     ENDFOR
     thead = " ", ycol = (ycol+ 24)
     IF (ycol > 680)
      BREAK
     ENDIF
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "{f/9}{cpi/16}DAILY LABS{f/8}{cpi/16}",
     row + 1, thead = "DAILY LABS(cont.)"
     FOR (z = 1 TO temp->lab_list_ln_cnt)
       ycol = (ycol+ 12), xcol = 65,
       CALL print(calcpos(xcol,ycol)),
       temp->lab_list_tag[z].lab_list_line, row + 1
       IF (ycol > 700)
        BREAK
       ENDIF
     ENDFOR
     ycol = (ycol+ 24), thead = " "
     IF (ycol > 680)
      BREAK
     ENDIF
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "{f/9}{cpi/16}CONTINUOUS ORDERS{f/8}{cpi/16}",
     row + 1, thead = "CONTINUOUS ORDERS(cont.)"
     FOR (z = 1 TO temp->cont_list_ln_cnt)
       ycol = (ycol+ 12), xcol = 65,
       CALL print(calcpos(xcol,ycol)),
       temp->cont_list_tag[z].cont_list_line, row + 1
       IF (ycol > 700)
        BREAK
       ENDIF
     ENDFOR
     ycol = (ycol+ 24), thead = " "
     IF (ycol > 680)
      BREAK
     ENDIF
     xcol = 65,
     CALL print(calcpos(xcol,ycol)), "{f/9}{cpi/16}LIMITED ORDERS{f/8}{cpi/16}",
     row + 1, thead = "LIMITED ORDERS(cont.)"
     FOR (z = 1 TO temp->lmt_list_ln_cnt)
       ycol = (ycol+ 12), xcol = 65,
       CALL print(calcpos(xcol,ycol)),
       temp->lmt_list_tag[z].lmt_list_line, row + 1
       IF (ycol > 700)
        BREAK
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
 ENDFOR
 GO TO exit_program
#exit_program
END GO
