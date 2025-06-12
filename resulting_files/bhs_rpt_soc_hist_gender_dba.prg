CREATE PROGRAM bhs_rpt_soc_hist_gender:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Stat Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "encounter type" = 0
  WITH outdev, start_date, end_date,
  enc_type
 RECORD pats(
   1 cnt_pat = i4
   1 enc[*]
     2 person_id = f8
     2 encntr_id = f8
     2 fin = vc
     2 gen_id = vc
     2 sex_or = vc
     2 enc_type = vc
     2 enc_class = vc
     2 reg_date = vc
     2 date_charted = vc
     2 original_enctr_id = f8
     2 nomenclatureid = f8
 )
 DECLARE mf_cs71_triage = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"TRIAGE")), protect
 DECLARE mf_cs4002172_active = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!12883709")),
 protect
 DECLARE mf_cs14003_shxsexualorientation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SHXSEXUALORIENTATION")), protect
 DECLARE mf_cs14003_shxgenderidentity = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SHXGENDERIDENTITY")), protect
 DECLARE mf_cs48_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs_319_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 SELECT INTO "NL:"
  FROM shx_activity sa,
   shx_category_ref scr,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n,
   encounter e,
   encntr_alias fin
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime( $START_DATE) AND cnvtdatetime( $END_DATE)
    AND e.active_ind=1
    AND e.active_status_cd=mf_cs48_active_cd
    AND (e.encntr_type_class_cd= $ENC_TYPE)
    AND e.encntr_type_cd != mf_cs71_triage)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_ind=1
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm
    AND fin.encntr_alias_type_cd=mf_cs_319_fin_cd)
   JOIN (sa
   WHERE sa.person_id=e.person_id
    AND sa.status_cd=mf_cs4002172_active
    AND sa.active_ind=1
    AND sa.end_effective_dt_tm > sysdate)
   JOIN (scr
   WHERE scr.shx_category_ref_id=sa.shx_category_ref_id)
   JOIN (sr
   WHERE sr.shx_activity_id=sa.shx_activity_id
    AND sr.task_assay_cd IN (mf_cs14003_shxsexualorientation, mf_cs14003_shxgenderidentity)
    AND sr.active_ind=1
    AND sr.shx_response_id > 0)
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND n.nomenclature_id > 0)
  ORDER BY sa.person_id, sr.task_assay_cd, sr.shx_activity_id DESC,
   sa.beg_effective_dt_tm DESC, e.reg_dt_tm DESC
  HEAD REPORT
   stat = alterlist(pats->enc,10)
  HEAD e.person_id
   pats->cnt_pat += 1
   IF (mod(pats->cnt_pat,10)=1
    AND (pats->cnt_pat > 1))
    stat = alterlist(pats->enc,(pats->cnt_pat+ 9))
   ENDIF
   pats->enc[pats->cnt_pat].person_id = e.person_id, pats->enc[pats->cnt_pat].encntr_id = e.encntr_id,
   pats->enc[pats->cnt_pat].fin = trim(fin.alias),
   pats->enc[pats->cnt_pat].original_enctr_id = sa.originating_encntr_id, pats->enc[pats->cnt_pat].
   enc_class = trim(uar_get_code_display(e.encntr_type_class_cd)), pats->enc[pats->cnt_pat].enc_type
    = trim(uar_get_code_display(e.encntr_type_cd)),
   pats->enc[pats->cnt_pat].reg_date = format(e.reg_dt_tm,"@SHORTDATE4YR"), pats->enc[pats->cnt_pat].
   date_charted = format(sa.beg_effective_dt_tm,"@SHORTDATE4YR"), pats->enc[pats->cnt_pat].
   nomenclatureid = n.nomenclature_id
  HEAD sr.task_assay_cd
   x = 0
  HEAD sr.shx_activity_id
   null
  DETAIL
   x += 1
   IF (sr.task_assay_cd=mf_cs14003_shxgenderidentity
    AND x=1)
    pats->enc[pats->cnt_pat].gen_id = concat(trim(n.source_string))
   ELSEIF (sr.task_assay_cd=mf_cs14003_shxgenderidentity
    AND x > 1)
    pats->enc[pats->cnt_pat].gen_id = concat(pats->enc[pats->cnt_pat].gen_id,";",trim(n.source_string
      ))
   ENDIF
   IF (sr.task_assay_cd=mf_cs14003_shxsexualorientation
    AND x=1)
    pats->enc[pats->cnt_pat].sex_or = concat(trim(n.source_string))
   ELSEIF (sr.task_assay_cd=mf_cs14003_shxsexualorientation
    AND x > 1)
    pats->enc[pats->cnt_pat].sex_or = concat(pats->enc[pats->cnt_pat].sex_or,";",trim(n.source_string
      ))
   ENDIF
  FOOT  sr.task_assay_cd
   x = 0
  FOOT  e.person_id
   x = 0
  FOOT REPORT
   stat = alterlist(pats->enc,pats->cnt_pat)
  WITH nocounter, time = 300, format,
   separator = " "
 ;end select
 SELECT INTO  $OUTDEV
  person_id = pats->enc[d1.seq].person_id, fin = substring(1,30,pats->enc[d1.seq].fin),
  encounter_type = substring(1,30,pats->enc[d1.seq].enc_type),
  encounter_class = substring(1,30,pats->enc[d1.seq].enc_class), gender_identifier = substring(1,200,
   pats->enc[d1.seq].gen_id), sexual_orientation = substring(1,200,pats->enc[d1.seq].sex_or),
  registration_date = substring(1,20,pats->enc[d1.seq].reg_date), date_charted = substring(1,20,pats
   ->enc[d1.seq].date_charted), nomenclatureid = pats->enc[d1.seq].nomenclatureid
  FROM (dummyt d1  WITH seq = size(pats->enc,5))
  PLAN (d1)
  WITH nocounter, format, separator = " "
 ;end select
END GO
