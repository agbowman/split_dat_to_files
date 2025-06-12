CREATE PROGRAM bhs_rpt_prsnl_npi_ext_id:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 prsnl[*]
     2 f_prsnl_id = f8
     2 s_name_full = vc
     2 s_npi = vc
     2 s_ext_id = vc
     2 s_ord_doc = vc
 ) WITH protect
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE mf_ext_id_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "EXTERNALIDENTIFIER"))
 DECLARE mf_org_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "ORGANIZATIONDOCTOR"))
 SELECT INTO value( $OUTDEV)
  p.name_full_formatted, p.person_id, npi_alias = pa1.alias,
  external_id_alias = pa2.alias, org_doc = pa3.alias
  FROM prsnl p,
   prsnl_alias pa1,
   prsnl_alias pa2,
   prsnl_alias pa3
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (pa1
   WHERE pa1.person_id=p.person_id
    AND pa1.active_ind=1
    AND pa1.end_effective_dt_tm > sysdate
    AND pa1.prsnl_alias_type_cd=mf_npi_cd)
   JOIN (pa2
   WHERE pa2.person_id=outerjoin(p.person_id)
    AND pa2.active_ind=outerjoin(1)
    AND pa2.end_effective_dt_tm > outerjoin(sysdate)
    AND pa2.prsnl_alias_type_cd=outerjoin(mf_ext_id_cd))
   JOIN (pa3
   WHERE pa3.person_id=outerjoin(p.person_id)
    AND pa3.active_ind=outerjoin(1)
    AND pa3.end_effective_dt_tm > outerjoin(sysdate)
    AND pa3.prsnl_alias_type_cd=outerjoin(mf_org_doc_cd))
  ORDER BY p.name_full_formatted
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
