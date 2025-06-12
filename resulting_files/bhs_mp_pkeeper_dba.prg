CREATE PROGRAM bhs_mp_pkeeper:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Personnel ID: " = "",
  "Encounter ID: " = ""
  WITH outdev, ms_prsnl_id, ms_encntr_id
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_bmcmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BMCMRN"))
 DECLARE mf_fmcmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"FMCMRN"))
 DECLARE mf_mlhmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"MLHMRN"))
 DECLARE mf_bwhmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BWHMRN"))
 DECLARE mf_bnhmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BNHMRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_recurringop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"RECURRINGOP")
  )
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_expiredip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE mf_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_jdoe_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"JDOE"))
 DECLARE mf_expiredes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"))
 DECLARE mf_expiredobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE mf_expireddaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDDAYSTAY"))
 DECLARE mf_dischrecurringop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHRECURRINGOP"))
 DECLARE mf_dischrecurofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHRECUROFFICEVISIT"))
 DECLARE mf_recurofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "RECUROFFICEVISIT"))
 DECLARE mf_outpatientrecurring_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTRECURRING"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 FREE RECORD pinfo
 RECORD pinfo(
   1 mf_prsnl_id = f8
   1 mf_encntr_id = f8
   1 ms_username = vc
   1 ms_fin_nbr = vc
   1 ms_dos = vc
   1 ms_pkey = vc
   1 ms_facility = vc
   1 ms_cmrn = vc
   1 mf_person_id = f8
   1 ms_domain = vc
 ) WITH protect
 SET pinfo->mf_prsnl_id = cnvtreal( $MS_PRSNL_ID)
 SET pinfo->mf_encntr_id = cnvtreal( $MS_ENCNTR_ID)
 SET pinfo->ms_pkey = "f5mj7UGT"
 EXECUTE bhs_check_domain
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=pinfo->mf_prsnl_id)
  DETAIL
   pinfo->ms_username = trim(p.username)
  WITH nocounter
 ;end select
 IF ((pinfo->mf_encntr_id != 0.0))
  CALL echo("HERE")
  SELECT INTO "nl:"
   FROM encntr_alias ea
   WHERE (ea.encntr_id=pinfo->mf_encntr_id)
    AND ea.encntr_alias_type_cd IN (mf_fin_cd, mf_mrn_cd)
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ORDER BY ea.beg_effective_dt_tm DESC
   HEAD REPORT
    pinfo->ms_facility = "OTHER"
   DETAIL
    IF (ea.encntr_alias_type_cd=mf_fin_cd)
     pinfo->ms_fin_nbr = trim(ea.alias,3)
    ENDIF
    IF (ea.encntr_alias_type_cd=mf_mrn_cd)
     IF (ea.alias_pool_cd=mf_bmcmrn_cd)
      pinfo->ms_facility = "BMC"
     ENDIF
     IF (ea.alias_pool_cd=mf_fmcmrn_cd)
      pinfo->ms_facility = "FMC"
     ENDIF
     IF (ea.alias_pool_cd=mf_mlhmrn_cd)
      pinfo->ms_facility = "MLH"
     ENDIF
     IF (ea.alias_pool_cd=mf_bwhmrn_cd)
      pinfo->ms_facility = "BWH"
     ENDIF
     IF (ea.alias_pool_cd=mf_bnhmrn_cd)
      pinfo->ms_facility = "BNH"
     ENDIF
    ENDIF
   FOOT REPORT
    FOR (ml_loop = (size(pinfo->ms_fin_nbr)+ 1) TO 10)
      pinfo->ms_fin_nbr = concat("0",pinfo->ms_fin_nbr)
    ENDFOR
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e
   WHERE (e.encntr_id=pinfo->mf_encntr_id)
   DETAIL
    pinfo->mf_person_id = e.person_id
    IF ( NOT (e.encntr_type_cd IN (mf_observation_cd, mf_emergency_cd, mf_recurringop_cd,
    mf_dischip_cd, mf_expiredip_cd,
    mf_disches_cd, mf_dischobv_cd, mf_dischdaystay_cd, mf_daystay_cd, mf_jdoe_cd,
    mf_expiredes_cd, mf_expiredobv_cd, mf_expireddaystay_cd, mf_dischrecurringop_cd,
    mf_dischrecurofficevisit_cd,
    mf_recurofficevisit_cd, mf_outpatientrecurring_cd, mf_inpatient_cd)))
     pinfo->ms_dos = format(e.reg_dt_tm,"DDMMYYYY")
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM person_alias pa
   WHERE (pa.person_id=pinfo->mf_person_id)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pa.person_alias_type_cd=mf_cmrn_cd
   ORDER BY pa.updt_dt_tm
   DETAIL
    pinfo->ms_cmrn = trim(pa.alias,3)
    FOR (ml_loop = (size(pinfo->ms_cmrn)+ 1) TO 7)
      pinfo->ms_cmrn = concat("0",pinfo->ms_cmrn)
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 IF (gl_bhs_prod_flag=1)
  SET pinfo->ms_domain = "P"
 ELSE
  SET pinfo->ms_domain = "T"
 ENDIF
 CALL echorecord(pinfo)
 SET _memory_reply_string = cnvtrectojson(pinfo)
#exit_program
 CALL echo(_memory_reply_string)
END GO
