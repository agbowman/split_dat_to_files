CREATE PROGRAM bhs_ma_remove_dyndoc_temp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Action Type" = 2,
  "Template:" = 0
  WITH outdev, l_act_type, f_template_id
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_ref_template_id = f8
     2 s_title_text = vc
     2 f_long_blob_id = f8
 ) WITH protect
 FREE RECORD m_del
 RECORD m_del(
   1 l_cnt = i4
   1 qual[*]
     2 f_ref_template_id = f8
     2 s_title_text = vc
 ) WITH protect
 IF (( $L_ACT_TYPE=1))
  SELECT INTO "nl:"
   FROM dd_ref_template d
   PLAN (d
    WHERE (d.dd_ref_template_id= $F_TEMPLATE_ID)
     AND d.dd_ref_template_id > 0)
   ORDER BY d.dd_ref_template_id
   HEAD d.dd_ref_template_id
    m_del->l_cnt += 1, stat = alterlist(m_del->qual,m_del->l_cnt), m_del->qual[m_del->l_cnt].
    f_ref_template_id = d.dd_ref_template_id,
    m_del->qual[m_del->l_cnt].s_title_text = trim(d.title_txt,3)
   DETAIL
    m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
    f_ref_template_id = d.dd_ref_template_id,
    m_rec->qual[m_rec->l_cnt].f_long_blob_id = d.long_blob_ref_id, m_rec->qual[m_rec->l_cnt].
    s_title_text = trim(d.title_txt,3)
   WITH nocounter
  ;end select
  IF ((m_rec->l_cnt > 0))
   DELETE  FROM dd_ref_template_content_r d
    WHERE expand(ml_idx1,1,m_rec->l_cnt,d.dd_ref_template_id,m_rec->qual[ml_idx1].f_ref_template_id)
     AND d.dd_ref_template_id > 0
   ;end delete
   DELETE  FROM dd_ref_tmplt_cn_tmplt_r d
    WHERE expand(ml_idx1,1,m_rec->l_cnt,d.dd_ref_template_id,m_rec->qual[ml_idx1].f_ref_template_id)
     AND d.dd_ref_template_id > 0
   ;end delete
   DELETE  FROM long_blob_reference d
    WHERE expand(ml_idx1,1,m_rec->l_cnt,d.long_blob_id,m_rec->qual[ml_idx1].f_long_blob_id)
     AND d.long_blob_id > 0
   ;end delete
   DELETE  FROM dd_ref_template d
    WHERE expand(ml_idx1,1,m_rec->l_cnt,d.dd_ref_template_id,m_rec->qual[ml_idx1].f_ref_template_id)
     AND d.dd_ref_template_id > 0
   ;end delete
   COMMIT
   FOR (ml_idx1 = 1 TO m_del->l_cnt)
    INSERT  FROM dm_info di
     SET di.info_domain = "BHS_MA_REMOVE_DYNDOC_TEMP", di.info_name = concat(m_del->qual[ml_idx1].
       s_title_text," [",trim(format(sysdate,"MM/DD/YYYY HH:mm:ss;;d")),"]"), di.info_date =
      cnvtdatetime(sysdate),
      di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    COMMIT
   ENDFOR
   SELECT INTO  $OUTDEV
    action = "Removed", template = trim(substring(1,100,m_rec->qual[d.seq].s_title_text),3),
    ref_template_id = m_rec->qual[d.seq].f_ref_template_id,
    long_blob_id = m_rec->qual[d.seq].f_long_blob_id
    FROM (dummyt d  WITH seq = m_rec->l_cnt)
    PLAN (d)
    WITH nocounter, heading, maxrow = 1,
     formfeed = none, format, separator = " "
   ;end select
  ELSE
   SELECT INTO value( $OUTDEV)
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     "{CPI/9}{FONT/4}", row 0, col 0,
     CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)), row + 1, row 3,
     col 0,
     CALL print("Report completed. No qualifying data found."), row + 1,
     row 6, col 0,
     CALL print(build2("Execution Date/Time:",format(cnvtdatetime(curdate,curtime),
       "mm/dd/yyyy hh:mm:ss;;q")))
    WITH nocounter, nullreport, maxcol = 300,
     dio = 08
   ;end select
  ENDIF
 ELSEIF (( $L_ACT_TYPE=2))
  SELECT INTO  $OUTDEV
   dyndoc_template = di.info_name, prsnl = p.name_full_formatted, remove_dt = format(di.info_date,
    ";;q")
   FROM dm_info di,
    prsnl p
   PLAN (di
    WHERE di.info_domain="BHS_MA_REMOVE_DYNDOC_TEMP")
    JOIN (p
    WHERE p.person_id=di.updt_id)
   ORDER BY di.info_name
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ENDIF
#exit_script
END GO
