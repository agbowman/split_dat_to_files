CREATE PROGRAM bhs_rpt_pcn_allergy:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = value(673936.00),
  "Start Admit date" = "CURDATE",
  "End Admit Date" = "CURDATE"
  WITH outdev, f_facility, s_start_date,
  s_end_date
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_cs71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs6000_pharmacy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),
 protect
 DECLARE cnt_ord = i4 WITH noconstant(0), protect
 DECLARE test = f8
 DECLARE ms_start_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_START_DATE,
     "DD-MMM-YYYY"),0),";;Q")), protect
 DECLARE ms_end_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),
    235959),";;Q")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs_12025_active_allergy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE")),
 protect
 RECORD allergy(
   1 cnt_pat = i4
   1 pats[*]
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_reg_date = vc
     2 s_allergy = vc
     2 s_reac = vc
     2 m_cnt_allergy = i4
     2 f_encntrid = f8
     2 f_personid = f8
     2 orders[*]
       3 order_name = vc
 )
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias fin,
   person p,
   allergy a,
   nomenclature n
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND e.active_status_cd=mf_cs48_active
    AND (e.loc_facility_cd= $F_FACILITY)
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_emergency, mf_cs71_inpatient,
   mf_cs71_observation))
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_status_cd=mf_cs48_active
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND fin.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.substance_nom_id > 0
    AND a.reaction_status_cd=value(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE"))
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate
    AND a.reaction_class_cd=value(uar_get_code_by("DISPLAYKEY",12021,"ALLERGY"))
    AND a.reaction_status_cd=mf_cs_12025_active_allergy)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id
    AND ((n.source_string IN ("penicillin", "penicillins", "amoxicillin", "amoxicillin/clavulanate",
   "piperacillin/tazobactam",
   "ampicillin", "ampicillin/sulbactam", "dicloxacillin", "oxacillin", "nafcillin")) OR (((n
   .source_string="*ampicillin*") OR (n.source_string="*cillin*")) ))
    AND n.active_status_cd=188
    AND n.source_vocabulary_cd IN (value(uar_get_code_by("DISPLAYKEY",400,"MULTUMALLERGYCATEGORY")),
   value(uar_get_code_by("DISPLAYKEY",400,"MULTUMDRUG"))))
  ORDER BY e.encntr_id
  HEAD REPORT
   stat = alterlist(allergy->pats,10)
  HEAD e.encntr_id
   allergy->cnt_pat += 1
   IF (mod(allergy->cnt_pat,10)=1
    AND (allergy->cnt_pat > 1))
    stat = alterlist(allergy->pats,(allergy->cnt_pat+ 9))
   ENDIF
   allergy->pats[allergy->cnt_pat].s_pat_name = trim(p.name_full_formatted,3), allergy->pats[allergy
   ->cnt_pat].s_fin = trim(fin.alias,3), allergy->pats[allergy->cnt_pat].s_reg_date = format(e
    .reg_dt_tm,"mm/dd/yyyy;;d"),
   allergy->pats[allergy->cnt_pat].f_encntrid = e.encntr_id, allergy->pats[allergy->cnt_pat].
   f_personid = e.person_id
  DETAIL
   allergy->pats[allergy->cnt_pat].m_cnt_allergy += 1
   IF ((allergy->pats[allergy->cnt_pat].m_cnt_allergy=1))
    IF (a.severity_cd > 0)
     allergy->pats[allergy->cnt_pat].s_allergy = concat(trim(n.source_string,3),":",
      uar_get_code_display(a.severity_cd))
    ELSE
     allergy->pats[allergy->cnt_pat].s_allergy = trim(n.source_string,3)
    ENDIF
   ELSE
    IF (a.severity_cd > 0)
     allergy->pats[allergy->cnt_pat].s_allergy = concat(allergy->pats[allergy->cnt_pat].s_allergy,",",
      trim(n.source_string,3),":",uar_get_code_display(a.severity_cd))
    ELSE
     allergy->pats[allergy->cnt_pat].s_allergy = concat(allergy->pats[allergy->cnt_pat].s_allergy,",",
      trim(n.source_string,3))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(allergy->pats,allergy->cnt_pat)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pats_f_personid = allergy->pats[d1.seq].f_personid
  FROM (dummyt d1  WITH seq = size(allergy->pats,5)),
   orders o,
   alt_sel_cat a
  PLAN (d1)
   JOIN (o
   WHERE o.catalog_type_cd=mf_cs6000_pharmacy
    AND (o.encntr_id=allergy->pats[d1.seq].f_encntrid))
   JOIN (a
   WHERE a.alt_sel_category_id IN (
   (SELECT
    max(asl.alt_sel_category_id)
    FROM alt_sel_list asl,
     alt_sel_cat ac
    WHERE asl.synonym_id=o.synonym_id
     AND asl.alt_sel_category_id=ac.alt_sel_category_id
     AND ((ac.ahfs_ind+ 0)=1)
     AND cnvtupper(ac.short_description) IN ("12", "13", "22", "222", "223",
    "224", "225", "226", "290", "406",
    "486")
    WITH nocounter)))
  ORDER BY d1.seq, o.synonym_id
  HEAD d1.seq
   stat = alterlist(allergy->pats[d1.seq].orders,10)
  HEAD o.synonym_id
   cnt_ord += 1
   IF (mod(cnt_ord,10)=1
    AND cnt_ord > 1)
    stat = alterlist(allergy->pats[d1.seq].orders,(cnt_ord+ 9))
   ENDIF
   allergy->pats[d1.seq].orders[cnt_ord].order_name = trim(o.ordered_as_mnemonic,3)
  FOOT  d1.seq
   stat = alterlist(allergy->pats[d1.seq].orders,cnt_ord), cnt_ord = 0
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  patient_name = substring(1,30,allergy->pats[d1.seq].s_pat_name), account# = substring(1,30,allergy
   ->pats[d1.seq].s_fin), admit_date = substring(1,30,allergy->pats[d1.seq].s_reg_date),
  allergy_reaction = substring(1,30,allergy->pats[d1.seq].s_allergy), abx_order = substring(1,100,
   allergy->pats[d1.seq].orders[d2.seq].order_name)
  FROM (dummyt d1  WITH seq = size(allergy->pats,5)),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(allergy->pats[d1.seq].orders,5)))
   JOIN (d2)
  WITH nocounter, separator = " ", format
 ;end select
END GO
