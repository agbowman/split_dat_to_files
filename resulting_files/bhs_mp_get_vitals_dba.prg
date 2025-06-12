CREATE PROGRAM bhs_mp_get_vitals:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 s_min_date = vc
   1 s_max_date = vc
   1 s_min_48_date = vc
   1 heart[*]
     2 s_date = vc
     2 f_result = f8
   1 cvp[*]
     2 s_date = vc
     2 f_result = f8
   1 dbp[*]
     2 s_date = vc
     2 f_result = f8
   1 sbp[*]
     2 s_date = vc
     2 f_result = f8
   1 bp[*]
     2 s_date = vc
     2 f_sbp_result = f8
     2 f_dbp_result = f8
     2 f_avg_result = f8
   1 cam[*]
     2 s_date = vc
     2 f_result = f8
   1 ci[*]
     2 s_date = vc
     2 f_result = f8
   1 urine[*]
     2 s_date = vc
     2 f_result = f8
 )
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE mf_hr1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE mf_hr2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEARTRATEMONITORED"))
 DECLARE mf_cvp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CVP"))
 DECLARE mf_dbp1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURESITTING"))
 DECLARE mf_sbp1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURESITTING"))
 DECLARE mf_dbp2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURELYING"))
 DECLARE mf_sbp2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURELYING"))
 DECLARE mf_dbp3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURESTANDING"))
 DECLARE mf_sbp3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURESTANDING"))
 DECLARE mf_dbp4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_sbp4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE mf_dbp5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICARTERIALBLOODPRESSURE"))
 DECLARE mf_sbp5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICARTERIALBLOODPRESSURE"))
 DECLARE mf_cam_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CAMICUSCORE"))
 DECLARE mf_ci_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CI"))
 DECLARE mf_urine_void_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"URINEVOIDED"))
 DECLARE mf_urine_cath_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"URINECATHETER"
   ))
 DECLARE mf_lnephro_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LNEPHROSTOMY"))
 DECLARE mf_rnephro_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"RNEPHROSTOMY"))
 DECLARE mf_lureter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LURETEROSTOMY"))
 DECLARE mf_rureter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"RURETEROSTOMY"))
 DECLARE mf_supracath_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SUPRAPUBICCATHETER"))
 CALL echo(build2("encounter id: ",mf_encntr_id))
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   CALL echo(p.name_full_formatted)
  WITH nocounter
 ;end select
 SET m_info->s_max_date = trim(format(cnvtlookbehind("5,H",sysdate),"mm-dd-yyyy hh:mm;;d"))
 SET m_info->s_min_date = trim(format(cnvtlookbehind("29,H",sysdate),"mm-dd-yyyy hh:mm;;d"))
 SET m_info->s_min_48_date = trim(format(cnvtlookbehind("53,H",sysdate),"mm-dd-yyyy hh:mm;;d"))
 CALL echo(m_info->s_max_date)
 CALL echo(m_info->s_min_date)
 SELECT INTO "nl:"
  ps_date = trim(format(cnvtlookbehind("5,H",ce.event_end_dt_tm),"mm-dd-yyyy hh:mm;;d")), pl_hr =
  hour(ce.event_end_dt_tm)
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=mf_encntr_id
    AND ce.event_cd IN (mf_hr1_cd, mf_hr2_cd, mf_cvp_cd, mf_dbp1_cd, mf_sbp1_cd,
   mf_dbp2_cd, mf_sbp2_cd, mf_dbp3_cd, mf_sbp3_cd, mf_dbp4_cd,
   mf_sbp4_cd, mf_dbp5_cd, mf_sbp5_cd, mf_cam_cd, mf_ci_cd)
    AND ce.event_end_dt_tm BETWEEN cnvtlookbehind("24,H",sysdate) AND sysdate)
  ORDER BY ce.event_end_dt_tm
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   IF (isnumeric(ce.result_val))
    pf_result_val = cnvtreal(ce.result_val), pl_cnt = 0
    CASE (ce.event_cd)
     OF mf_hr1_cd:
      pl_cnt = (size(m_info->heart,5)+ 1),stat = alterlist(m_info->heart,pl_cnt),m_info->heart[pl_cnt
      ].f_result = pf_result_val,
      m_info->heart[pl_cnt].s_date = ps_date
     OF mf_hr2_cd:
      pl_cnt = (size(m_info->heart,5)+ 1),stat = alterlist(m_info->heart,pl_cnt),m_info->heart[pl_cnt
      ].f_result = pf_result_val,
      m_info->heart[pl_cnt].s_date = ps_date
     OF mf_cvp_cd:
      pl_cnt = (size(m_info->cvp,5)+ 1),stat = alterlist(m_info->cvp,pl_cnt),m_info->cvp[pl_cnt].
      f_result = pf_result_val,
      m_info->cvp[pl_cnt].s_date = ps_date
     OF mf_dbp1_cd:
      pl_cnt = (size(m_info->dbp,5)+ 1),stat = alterlist(m_info->dbp,pl_cnt),m_info->dbp[pl_cnt].
      f_result = pf_result_val,
      m_info->dbp[pl_cnt].s_date = ps_date
     OF mf_sbp1_cd:
      pl_cnt = (size(m_info->sbp,5)+ 1),stat = alterlist(m_info->sbp,pl_cnt),m_info->sbp[pl_cnt].
      f_result = pf_result_val,
      m_info->sbp[pl_cnt].s_date = ps_date
     OF mf_dbp2_cd:
      pl_cnt = (size(m_info->dbp,5)+ 1),stat = alterlist(m_info->dbp,pl_cnt),m_info->dbp[pl_cnt].
      f_result = pf_result_val,
      m_info->dbp[pl_cnt].s_date = ps_date
     OF mf_sbp2_cd:
      pl_cnt = (size(m_info->sbp,5)+ 1),stat = alterlist(m_info->sbp,pl_cnt),m_info->sbp[pl_cnt].
      f_result = pf_result_val,
      m_info->sbp[pl_cnt].s_date = ps_date
     OF mf_dbp3_cd:
      pl_cnt = (size(m_info->dbp,5)+ 1),stat = alterlist(m_info->dbp,pl_cnt),m_info->dbp[pl_cnt].
      f_result = pf_result_val,
      m_info->dbp[pl_cnt].s_date = ps_date
     OF mf_sbp3_cd:
      pl_cnt = (size(m_info->sbp,5)+ 1),stat = alterlist(m_info->sbp,pl_cnt),m_info->sbp[pl_cnt].
      f_result = pf_result_val,
      m_info->sbp[pl_cnt].s_date = ps_date
     OF mf_dbp4_cd:
      pl_cnt = (size(m_info->dbp,5)+ 1),stat = alterlist(m_info->dbp,pl_cnt),m_info->dbp[pl_cnt].
      f_result = pf_result_val,
      m_info->dbp[pl_cnt].s_date = ps_date
     OF mf_sbp4_cd:
      pl_cnt = (size(m_info->sbp,5)+ 1),stat = alterlist(m_info->sbp,pl_cnt),m_info->sbp[pl_cnt].
      f_result = pf_result_val,
      m_info->sbp[pl_cnt].s_date = ps_date
     OF mf_dbp5_cd:
      pl_cnt = (size(m_info->dbp,5)+ 1),stat = alterlist(m_info->dbp,pl_cnt),m_info->dbp[pl_cnt].
      f_result = pf_result_val,
      m_info->dbp[pl_cnt].s_date = ps_date
     OF mf_sbp5_cd:
      pl_cnt = (size(m_info->sbp,5)+ 1),stat = alterlist(m_info->sbp,pl_cnt),m_info->sbp[pl_cnt].
      f_result = pf_result_val,
      m_info->sbp[pl_cnt].s_date = ps_date
     OF mf_cam_cd:
      pl_cnt = (size(m_info->cam,5)+ 1),stat = alterlist(m_info->cam,pl_cnt),m_info->cam[pl_cnt].
      f_result = pf_result_val,
      m_info->cam[pl_cnt].s_date = ps_date
     OF mf_ci_cd:
      pl_cnt = (size(m_info->ci,5)+ 1),stat = alterlist(m_info->ci,pl_cnt),m_info->ci[pl_cnt].
      f_result = pf_result_val,
      m_info->ci[pl_cnt].s_date = ps_date
    ENDCASE
    IF (ce.event_cd IN (mf_dbp1_cd, mf_sbp1_cd, mf_dbp2_cd, mf_sbp2_cd, mf_dbp3_cd,
    mf_sbp3_cd, mf_dbp4_cd, mf_sbp4_cd, mf_dbp5_cd, mf_sbp5_cd))
     pl_cnt = size(m_info->bp,5)
     IF (pl_cnt > 0)
      IF (ce.event_cd IN (mf_dbp1_cd, mf_dbp2_cd, mf_dbp3_cd, mf_dbp4_cd, mf_dbp5_cd))
       IF ((m_info->bp[pl_cnt].f_dbp_result <= 0.0)
        AND (m_info->bp[pl_cnt].s_date=ps_date))
        m_info->bp[pl_cnt].f_dbp_result = pf_result_val
       ELSEIF ((((m_info->bp[pl_cnt].f_dbp_result > 0.0)) OR ((m_info->bp[pl_cnt].s_date != ps_date)
       )) )
        pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->bp,pl_cnt), m_info->bp[pl_cnt].f_dbp_result =
        pf_result_val,
        m_info->bp[pl_cnt].s_date = ps_date
       ENDIF
      ELSEIF (ce.event_cd IN (mf_sbp1_cd, mf_sbp2_cd, mf_sbp3_cd, mf_sbp4_cd, mf_sbp5_cd))
       IF ((m_info->bp[pl_cnt].f_sbp_result <= 0.0)
        AND (m_info->bp[pl_cnt].s_date=ps_date))
        m_info->bp[pl_cnt].f_sbp_result = pf_result_val
       ELSEIF ((((m_info->bp[pl_cnt].f_sbp_result > 0.0)) OR ((m_info->bp[pl_cnt].s_date != ps_date)
       )) )
        pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->bp,pl_cnt), m_info->bp[pl_cnt].f_sbp_result =
        pf_result_val,
        m_info->bp[pl_cnt].s_date = ps_date
       ENDIF
      ENDIF
     ELSE
      pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->bp,pl_cnt)
      IF (ce.event_cd IN (mf_dbp1_cd, mf_dbp2_cd, mf_dbp3_cd, mf_dbp4_cd, mf_dbp5_cd))
       m_info->bp[pl_cnt].f_dbp_result = pf_result_val, m_info->bp[pl_cnt].s_date = ps_date
      ELSE
       m_info->bp[pl_cnt].f_sbp_result = pf_result_val, m_info->bp[pl_cnt].s_date = ps_date
      ENDIF
     ENDIF
     IF ((m_info->bp[pl_cnt].f_dbp_result > 0.0)
      AND (m_info->bp[pl_cnt].f_sbp_result > 0.0))
      m_info->bp[pl_cnt].f_avg_result = ((m_info->bp[pl_cnt].f_sbp_result+ m_info->bp[pl_cnt].
      f_dbp_result)/ 2)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.io_end_dt_tm, ps_date = trim(format(c.io_end_dt_tm,"dd-mmm-yyyy hh:mm;;d"))
  FROM ce_intake_output_result c
  PLAN (c
   WHERE c.encntr_id=mf_encntr_id
    AND c.io_end_dt_tm >= cnvtlookbehind("24, H",sysdate)
    AND c.reference_event_cd IN (mf_urine_void_cd, mf_urine_cath_cd, mf_lnephro_cd, mf_rnephro_cd,
   mf_lureter_cd,
   mf_rureter_cd, mf_supracath_cd))
  ORDER BY c.io_end_dt_tm
  HEAD REPORT
   pl_cnt = 0, pf_vol = 0.0
  HEAD ps_date
   pf_vol = 0.0, pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->urine,pl_cnt)
  DETAIL
   pf_vol = (pf_vol+ c.io_volume)
  FOOT  ps_date
   m_info->urine[pl_cnt].f_result = pf_vol, m_info->urine[pl_cnt].s_date = trim(format(c.io_end_dt_tm,
     "mm/dd/yyyy hh:mm;;d"))
  WITH format(date,"mm/dd/yy hh:mm;;d")
 ;end select
 CALL echo("rectojson")
 CALL echo(cnvtrectojson(m_info))
 CALL echo("echojson")
 CALL echojson(m_info, $OUTDEV)
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
