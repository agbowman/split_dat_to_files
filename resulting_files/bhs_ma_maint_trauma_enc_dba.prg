CREATE PROGRAM bhs_ma_maint_trauma_enc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN:" = "",
  "Remove encounter from list (optional)" = 0,
  "Add encounter to list (optional)" = 0
  WITH outdev, s_fin, f_rem_enc_id,
  f_add_enc_id
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rem
 RECORD m_rem(
   1 l_cnt = i4
   1 qual[*]
     2 s_info_name = vc
     2 f_info_long_id = f8
     2 s_fin = vc
 ) WITH protect
 FREE RECORD m_add
 RECORD m_add(
   1 l_cnt = i4
   1 qual[*]
     2 s_info_name = vc
     2 f_info_long_id = f8
     2 s_fin = vc
 ) WITH protect
 FREE RECORD m_smry
 RECORD m_smry(
   1 l_cnt = i4
   1 qual[*]
     2 s_fin = vc
     2 s_action = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM dm_info di,
   encntr_alias ea
  PLAN (di
   WHERE di.info_domain="BHS_MA_TRAUMA_ADDITIONAL_ENC"
    AND (di.info_long_id= $F_REM_ENC_ID)
    AND di.info_number=1)
   JOIN (ea
   WHERE ea.encntr_id=di.info_long_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd
    AND ea.encntr_id > 0)
  ORDER BY ea.encntr_id
  HEAD ea.encntr_id
   m_rem->l_cnt += 1, stat = alterlist(m_rem->qual,m_rem->l_cnt), m_rem->qual[m_rem->l_cnt].
   s_info_name = di.info_name,
   m_rem->qual[m_rem->l_cnt].s_fin = trim(ea.alias,3), m_rem->qual[m_rem->l_cnt].f_info_long_id = di
   .info_long_id
  WITH nocounter
 ;end select
 IF ((m_rem->l_cnt > 0))
  UPDATE  FROM dm_info di
   SET di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->
    updt_id,
    di.info_number = 0
   PLAN (di
    WHERE di.info_domain="BHS_MA_TRAUMA_ADDITIONAL_ENC"
     AND expand(ml_idx1,1,m_rem->l_cnt,di.info_name,m_rem->qual[ml_idx1].s_info_name)
     AND di.info_number=1)
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea
  PLAN (e
   WHERE (e.encntr_id= $F_ADD_ENC_ID)
    AND e.active_ind=1
    AND e.encntr_id > 0)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_add->l_cnt += 1, stat = alterlist(m_add->qual,m_add->l_cnt), m_add->qual[m_add->l_cnt].s_fin =
   trim(ea.alias,3),
   m_add->qual[m_add->l_cnt].s_info_name = trim(cnvtstring(e.encntr_id,20,0),3), m_add->qual[m_add->
   l_cnt].f_info_long_id = e.encntr_id
  WITH nocounter
 ;end select
 IF ((m_add->l_cnt > 0))
  FOR (ml_idx1 = 1 TO m_add->l_cnt)
    UPDATE  FROM dm_info di
     SET di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo
      ->updt_id,
      di.info_number = 1
     PLAN (di
      WHERE di.info_domain="BHS_MA_TRAUMA_ADDITIONAL_ENC"
       AND (di.info_name=m_add->qual[ml_idx1].s_info_name))
     WITH nocounter
    ;end update
    COMMIT
    IF (curqual < 1)
     INSERT  FROM dm_info di
      SET di.info_domain = "BHS_MA_TRAUMA_ADDITIONAL_ENC", di.info_name = m_add->qual[ml_idx1].
       s_info_name, di.info_long_id = m_add->qual[ml_idx1].f_info_long_id,
       di.info_date = cnvtdatetime(sysdate), di.info_number = 1, di.updt_dt_tm = cnvtdatetime(sysdate
        ),
       di.updt_cnt = 0, di.updt_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
 FOR (ml_idx1 = 1 TO m_rem->l_cnt)
   SET m_smry->l_cnt += 1
   SET stat = alterlist(m_smry->qual,m_smry->l_cnt)
   SET m_smry->qual[m_smry->l_cnt].s_action = "Remove"
   SET m_smry->qual[m_smry->l_cnt].s_fin = m_rem->qual[ml_idx1].s_fin
 ENDFOR
 FOR (ml_idx1 = 1 TO m_add->l_cnt)
   SET m_smry->l_cnt += 1
   SET stat = alterlist(m_smry->qual,m_smry->l_cnt)
   SET m_smry->qual[m_smry->l_cnt].s_action = "Add"
   SET m_smry->qual[m_smry->l_cnt].s_fin = m_add->qual[ml_idx1].s_fin
 ENDFOR
 SELECT INTO  $OUTDEV
  fin = trim(substring(1,100,m_smry->qual[d1.seq].s_fin),3), action = trim(substring(1,30,m_smry->
    qual[d1.seq].s_action),3)
  FROM (dummyt d1  WITH seq = value(m_smry->l_cnt))
  PLAN (d1)
  ORDER BY action, fin
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
