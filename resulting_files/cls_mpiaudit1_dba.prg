CREATE PROGRAM cls_mpiaudit1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET echo_ind = 1
 DECLARE corp_cd = f8
 SET corp_cd = 0.0
 SET corp_cd = uar_get_code_by("DISPLAYKEY",263,"BHSCMRN")
 DECLARE bmcmrn_cd = f8
 SET bmcmrn_cd = 0.0
 SET bmcmrn_cd = uar_get_code_by("DISPLAYKEY",263,"BMCMRN")
 DECLARE fmcmrn_cd = f8
 SET fmcmrn_cd = 0.0
 SET fmcmrn_cd = uar_get_code_by("DISPLAYKEY",263,"FMCMRN")
 DECLARE mlhmrn_cd = f8
 SET mlhmrn_cd = 0.0
 SET mlhmrn_cd = uar_get_code_by("DISPLAYKEY",263,"MLHMRN")
 DECLARE ssn_cd = f8
 SET ssn_cd = 0.0
 SET ssn_cd = uar_get_code_by("DISPLAYKEY",263,"SSN")
 SELECT INTO value( $OUTDEV)
  p.name_last, p.name_first, sex = uar_get_code_display(p.sex_cd),
  p.birth_dt_tm"yyyy-mm-dd;3;q", pa1.alias, pa2.alias,
  pa3.alias, pa4.alias, pa5.alias
  FROM person p,
   person_alias pa1,
   person_alias pa2,
   person_alias pa3,
   person_alias pa4,
   person_alias pa5
  PLAN (p)
   JOIN (pa1
   WHERE p.person_id=pa1.person_id
    AND pa1.alias_pool_cd=corp_cd
    AND pa1.active_ind=1
    AND pa1.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (pa2
   WHERE p.person_id=pa2.person_id
    AND pa2.alias_pool_cd=bmcmrn_cd
    AND pa2.active_ind=1
    AND pa2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (pa3
   WHERE p.person_id=pa3.person_id
    AND pa3.alias_pool_cd=fmcmrn_cd
    AND pa3.active_ind=1
    AND pa3.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (pa4
   WHERE p.person_id=pa4.person_id
    AND pa4.alias_pool_cd=mlhmrn_cd
    AND pa4.active_ind=1
    AND pa4.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (pa5
   WHERE p.person_id=pa5.person_id
    AND pa5.alias_pool_cd=ssn_cd
    AND pa5.active_ind=1
    AND pa5.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
  ORDER BY pa1.alias
  HEAD REPORT
   r_cnt = 0, finalpad = fillstring(8," ")
  DETAIL
   r_cnt = (r_cnt+ 1), row r_cnt, shortsex = substring(1,1,sex),
   short_last = substring(1,20,p.name_last), short_first = substring(1,15,p.name_first), col 000,
   pa1.alias"#######;RP0", col 010, pa2.alias"#######;RP0",
   col 020, pa3.alias"#######;RP0", col 030,
   pa4.alias"#######;RP0", col 040, short_last,
   col 070, short_first, col 090,
   p.birth_dt_tm, col 100, shortsex,
   col 101, pa5.alias"###-##-####;RP0", col 112,
   finalpad
  WITH check, nocounter, maxcol = 121,
   maxrow = 30000, outerjoin = d1, nullreport
 ;end select
END GO
