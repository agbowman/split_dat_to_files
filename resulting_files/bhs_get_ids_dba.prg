CREATE PROGRAM bhs_get_ids:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Alias" = "",
  "Alias Type" = "FIN"
  WITH outdev, s_alias, s_alias_type
 DECLARE ms_alias_type = vc WITH protect, constant(cnvtupper(trim( $S_ALIAS_TYPE,3)))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_alias = vc WITH protect, noconstant(trim(cnvtupper( $S_ALIAS)))
 CALL echo(ms_alias_type)
 IF (ms_alias_type="FIN")
  SET mf_alias_type_cd = mf_fin_cd
 ELSEIF (ms_alias_type="MRN")
  SET mf_alias_type_cd = mf_mrn_cd
 ELSEIF (ms_alias_type="CMRN")
  SET mf_alias_type_cd = mf_cmrn_cd
 ENDIF
 IF (mf_alias_type_cd=mf_fin_cd)
  CALL echo("get alias by FIN")
  SELECT DISTINCT INTO value( $OUTDEV)
   p.name_full_formatted, e.person_id, e.encntr_id,
   e.active_ind, e.end_effective_dt_tm, fin = ea1.alias,
   mrn = ea2.alias, cmrn = pa.alias, facility = uar_get_code_display(e.loc_facility_cd),
   facility_cd = e.loc_facility_cd, e.reg_dt_tm, e.disch_dt_tm
   FROM encounter e,
    encntr_alias ea1,
    encntr_alias ea2,
    person p,
    person_alias pa
   PLAN (ea1
    WHERE ea1.alias=ms_alias
     AND ea1.encntr_alias_type_cd=mf_fin_cd)
    JOIN (e
    WHERE e.encntr_id=ea1.encntr_id
     AND e.active_ind=1
     AND e.end_effective_dt_tm > sysdate)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1
     AND p.end_effective_dt_tm > sysdate)
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
    JOIN (ea2
    WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
     AND (ea2.active_ind= Outerjoin(1))
     AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (mf_alias_type_cd=mf_mrn_cd)
  CALL echo("get alias by MRN")
  SELECT DISTINCT INTO value( $OUTDEV)
   p.name_full_formatted, e.person_id, e.encntr_id,
   e.active_ind, e.end_effective_dt_tm, fin = ea2.alias,
   mrn = ea1.alias, cmrn = pa.alias, facility = uar_get_code_display(e.loc_facility_cd),
   facility_cd = e.loc_facility_cd, e.reg_dt_tm, e.disch_dt_tm
   FROM encounter e,
    encntr_alias ea1,
    encntr_alias ea2,
    person p,
    person_alias pa
   PLAN (ea1
    WHERE ea1.alias=ms_alias
     AND ea1.encntr_alias_type_cd=mf_mrn_cd)
    JOIN (e
    WHERE e.encntr_id=ea1.encntr_id
     AND e.active_ind=1
     AND e.end_effective_dt_tm > sysdate)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1
     AND p.end_effective_dt_tm > sysdate)
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
    JOIN (ea2
    WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
     AND (ea2.active_ind= Outerjoin(1))
     AND (ea2.encntr_alias_type_cd= Outerjoin(mf_fin_cd)) )
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (mf_alias_type_cd=mf_cmrn_cd)
  CALL echo("get alias by CMRN")
  SELECT DISTINCT INTO value( $OUTDEV)
   p.name_full_formatted, pa.person_id, e.encntr_id,
   e.active_ind, e.end_effective_dt_tm, fin = ea1.alias,
   mrn = ea2.alias, cmrn = pa.alias, facility = uar_get_code_display(e.loc_facility_cd),
   facility_cd = e.loc_facility_cd, e.reg_dt_tm, e.disch_dt_tm
   FROM person_alias pa,
    encounter e,
    person p,
    encntr_alias ea1,
    encntr_alias ea2
   PLAN (pa
    WHERE pa.active_ind=1
     AND pa.alias=ms_alias
     AND pa.person_alias_type_cd=mf_alias_type_cd)
    JOIN (e
    WHERE e.person_id=pa.person_id)
    JOIN (p
    WHERE p.person_id=pa.person_id)
    JOIN (ea1
    WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
     AND (ea1.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
     AND (ea1.active_ind= Outerjoin(1)) )
    JOIN (ea2
    WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
     AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
     AND (ea2.active_ind= Outerjoin(1)) )
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (ms_alias_type IN ("PERSON_ID", "ENCNTR_ID"))
  IF (ms_alias_type="PERSON_ID")
   CALL echo("get alias by PERSON_ID")
   SELECT DISTINCT INTO value( $OUTDEV)
    p.name_full_formatted, p.person_id, e.encntr_id,
    e.reg_dt_tm, e.disch_dt_tm, e.end_effective_dt_tm,
    fin = ea1.alias, mrn = ea2.alias, cmrn = pa.alias,
    facility = uar_get_code_display(e.loc_facility_cd), facility_cd = e.loc_facility_cd, e.reg_dt_tm,
    e.disch_dt_tm
    FROM person p,
     encounter e,
     person_alias pa,
     encntr_alias ea1,
     encntr_alias ea2
    PLAN (p
     WHERE p.person_id=cnvtreal(ms_alias)
      AND p.active_ind=1)
     JOIN (e
     WHERE e.person_id=p.person_id
      AND e.active_ind=1)
     JOIN (pa
     WHERE (pa.active_ind= Outerjoin(1))
      AND (pa.person_id= Outerjoin(p.person_id))
      AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
     JOIN (ea1
     WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
      AND (ea1.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
      AND (ea1.active_ind= Outerjoin(1)) )
     JOIN (ea2
     WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
      AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
      AND (ea2.active_ind= Outerjoin(1)) )
    ORDER BY e.disch_dt_tm DESC
    WITH nocounter, format, separator = " "
   ;end select
  ELSEIF (ms_alias_type="ENCNTR_ID")
   CALL echo("get alias by ENCNTR_ID")
   SELECT DISTINCT INTO value( $OUTDEV)
    p.name_full_formatted, p.person_id, e.encntr_id,
    e.reg_dt_tm, e.disch_dt_tm, e.end_effective_dt_tm,
    fin = ea1.alias, mrn = ea2.alias, cmrn = pa.alias,
    facility = uar_get_code_display(e.loc_facility_cd), facility_cd = e.loc_facility_cd, e.reg_dt_tm,
    e.disch_dt_tm
    FROM person p,
     encounter e,
     person_alias pa,
     encntr_alias ea1,
     encntr_alias ea2
    PLAN (e
     WHERE e.encntr_id=cnvtreal(ms_alias))
     JOIN (p
     WHERE p.person_id=e.person_id)
     JOIN (pa
     WHERE (pa.active_ind= Outerjoin(1))
      AND (pa.person_id= Outerjoin(p.person_id))
      AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
     JOIN (ea1
     WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
      AND (ea1.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
      AND (ea1.active_ind= Outerjoin(1)) )
     JOIN (ea2
     WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
      AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
      AND (ea2.active_ind= Outerjoin(1)) )
    ORDER BY e.disch_dt_tm DESC
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 ELSEIF (ms_alias_type="NAME_LAST")
  CALL echo("get alias by NAME_LAST")
  SELECT DISTINCT INTO value( $OUTDEV)
   p.name_full_formatted, p.person_id, e.encntr_id,
   e.reg_dt_tm, e.disch_dt_tm, e.end_effective_dt_tm,
   fin = ea1.alias, mrn = ea2.alias, cmrn = pa.alias,
   facility = uar_get_code_display(e.loc_facility_cd), facility_cd = e.loc_facility_cd, e.reg_dt_tm,
   e.disch_dt_tm
   FROM person p,
    encounter e,
    person_alias pa,
    encntr_alias ea1,
    encntr_alias ea2
   PLAN (p
    WHERE p.name_last_key=value(concat(ms_alias,"*"))
     AND p.active_ind=1)
    JOIN (e
    WHERE e.person_id=p.person_id
     AND e.active_ind=1)
    JOIN (pa
    WHERE (pa.active_ind= Outerjoin(1))
     AND (pa.person_id= Outerjoin(p.person_id))
     AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
    JOIN (ea1
    WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
     AND (ea1.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
     AND (ea1.active_ind= Outerjoin(1)) )
    JOIN (ea2
    WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
     AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
     AND (ea2.active_ind= Outerjoin(1)) )
   ORDER BY e.disch_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
