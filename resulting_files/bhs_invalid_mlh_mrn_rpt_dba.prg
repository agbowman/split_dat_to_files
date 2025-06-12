CREATE PROGRAM bhs_invalid_mlh_mrn_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_mrn_alias_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE mf_cmrn_alias_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_mlh_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"MLHMRN"))
 SELECT INTO  $OUTDEV
  mrn_type = uar_get_code_display(p.alias_pool_cd), mrn = p.alias, cmrn = p2.alias,
  contrib_sys = uar_get_code_display(p.contributor_system_cd), create_date = p.beg_effective_dt_tm
  FROM person_alias p,
   person_alias p2
  WHERE p.person_alias_type_cd=mf_mrn_alias_type_cd
   AND p.alias_pool_cd=mf_mlh_pool_cd
   AND p.alias="M*"
   AND p.active_ind=1
   AND p.end_effective_dt_tm > sysdate
   AND p.person_id=p2.person_id
   AND p.beg_effective_dt_tm > cnvtdatetime("28-SEP-2017")
   AND p2.person_alias_type_cd=mf_cmrn_alias_type_cd
   AND p2.active_ind=1
   AND p2.end_effective_dt_tm > sysdate
  ORDER BY p.beg_effective_dt_tm DESC
  WITH format, separator = " "
 ;end select
END GO
