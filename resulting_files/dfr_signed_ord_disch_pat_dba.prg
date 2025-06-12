CREATE PROGRAM dfr_signed_ord_disch_pat:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
 EXECUTE cclseclogin
 FREE RECORD signed
 SET call_echo = 1
 RECORD signed(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pat_name = c100
     2 person_id = f8
     2 encntr_id = f8
     2 mrn = vc
     2 fin = vc
     2 dob = dq8
     2 sex_desc = vc
     2 pat_type_desc = vc
     2 doc_name = vc
     2 res_doc_name = vc
     2 fac_desc = vc
     2 nur_sta = vc
     2 room = vc
     2 bed = vc
     2 ord_cnt = i4
     2 ord_qual[*]
       3 order_id = f8
       3 ord_dttm = dq8
       3 catalog_disp = vc
       3 clin_disp_line = vc
       3 cat_type_cd = f8
       3 cat_type_desc = vc
       3 order_status_cd = f8
       3 ord_status_disp = vc
 )
 DECLARE es_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 DECLARE att_doc = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE res_doc = f8 WITH public
 SET res_doc = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=333
   AND cv.active_ind=1
   AND cv.display_key="RESIDENT"
  DETAIL
   res_doc = cv.code_value
  WITH check, nocounter
 ;end select
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cnt = i4
 SET cnt = 0
 IF (call_echo)
  CALL echo(build("es_cd =",es_cd))
  CALL echo(build("att_doc =",att_doc))
  CALL echo(build("res_doc =",res_doc))
  CALL echo(build("mrn_cd =",mrn_cd))
  CALL echo(build("fin_cd =",fin_cd))
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted, e.disch_dt_tm"dd-mmm-yyyy hh:mm:ss;;d", e.disch_disposition_cd,
  e_disch_disposition_disp = uar_get_code_display(e.disch_disposition_cd), e.encntr_id, e.person_id,
  pa.alias, ea.alias, p.birth_dt_tm,
  p.sex_cd, e.encntr_type_cd, e.encntr_status_cd,
  e_encntr_status_disp = uar_get_code_display(e.encntr_status_cd), e.encntr_class_cd,
  e_encntr_class_disp = uar_get_code_display(e.encntr_class_cd),
  e.loc_facility_cd, e.loc_building_cd, e_loc_building_disp = uar_get_code_display(e.loc_building_cd),
  e.loc_nurse_unit_cd, e.loc_room_cd, e.loc_bed_cd,
  e.reason_for_visit, p1.name_full_formatted, p2.name_full_formatted
  FROM encounter e,
   person p,
   encntr_alias ea,
   person_alias pa,
   encntr_prsnl_reltn epr1,
   prsnl p1,
   encntr_prsnl_reltn epr2,
   prsnl p2,
   dummyt d
  PLAN (e
   WHERE e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND e.disch_dt_tm BETWEEN cnvtdatetime((curdate - 6),0000) AND cnvtdatetime((curdate - 6),2359))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.person_alias_type_cd=mrn_cd)
   JOIN (epr1
   WHERE epr1.encntr_id=e.encntr_id
    AND epr1.encntr_prsnl_r_cd=att_doc
    AND epr1.active_ind=1)
   JOIN (p1
   WHERE p1.person_id=epr1.prsnl_person_id)
   JOIN (d)
   JOIN (epr2
   WHERE epr2.encntr_id=e.encntr_id
    AND epr2.encntr_prsnl_r_cd=res_doc
    AND epr2.active_ind=1)
   JOIN (p2
   WHERE p2.person_id=epr2.prsnl_person_id)
  DETAIL
   cnt = (cnt+ 1), signed->pat_cnt = cnt, stat = alterlist(signed->pat_qual,cnt),
   signed->pat_qual[cnt].pat_name = p.name_full_formatted, signed->pat_qual[cnt].person_id = e
   .person_id, signed->pat_qual[cnt].encntr_id = e.encntr_id,
   signed->pat_qual[cnt].mrn = pa.alias, signed->pat_qual[cnt].fin = ea.alias, signed->pat_qual[cnt].
   dob = p.birth_dt_tm,
   signed->pat_qual[cnt].sex_desc = trim(uar_get_code_display(p.sex_cd)), signed->pat_qual[cnt].
   pat_type_desc = trim(uar_get_code_display(e.encntr_type_cd)), signed->pat_qual[cnt].doc_name =
   trim(p1.name_full_formatted),
   signed->pat_qual[cnt].res_doc_name = trim(p2.name_full_formatted), signed->pat_qual[cnt].fac_desc
    = trim(uar_get_code_display(e.loc_facility_cd)), signed->pat_qual[cnt].nur_sta = trim(
    uar_get_code_display(e.loc_nurse_unit_cd)),
   signed->pat_qual[cnt].room = trim(uar_get_code_display(e.loc_room_cd)), signed->pat_qual[cnt].bed
    = trim(uar_get_code_display(e.loc_bed_cd))
  WITH check, outerjoin = d
 ;end select
 SELECT
  o.order_id, o.orig_order_dt_tm, o.catalog_cd,
  catalog_desc = uar_get_code_display(o.catalog_cd), o.clinical_display_line, o.catalog_type_cd,
  cat_type_desc = uar_get_code_display(o.catalog_type_cd), o.order_status_cd, ord_status_disp =
  uar_get_code_display(o.order_status_cd),
  pat_name = signed->pat_qual[d.seq].pat_name, psid = signed->pat_qual[d.seq].person_id, enbr =
  signed->pat_qual[d.seq].encntr_id
  FROM (dummyt d  WITH seq = value(signed->pat_cnt)),
   orders o
  PLAN (d
   WHERE d.seq > 0)
   JOIN (o
   WHERE (o.person_id=signed->pat_qual[d.seq].person_id)
    AND (o.encntr_id=signed->pat_qual[d.seq].encntr_id))
  WITH check
 ;end select
 IF (call_echo)
  FOR (i = 1 TO signed->pat_cnt)
    CALL echo(build("signed-> pat_qual[",i,"].pat_name =",signed->pat_qual[i].pat_name))
    CALL echo(build("signed-> pat_qual[",i,"].person_id = ",signed->pat_qual[i].person_id))
    CALL echo(build("signed-> pat_qual[",i,"].encntr_id =",signed->pat_qual[i].encntr_id))
    CALL echo(build("signed-> pat_qual[",i,"].mrn = ",signed->pat_qual[i].mrn))
    CALL echo(build("signed-> pat_qual[",i,"].fin = ",signed->pat_qual[i].fin))
    CALL echo(build("signed-> pat_qual[",i,"].dob = ",signed->pat_qual[i].dob))
    CALL echo(build("signed-> pat_qual[",i,"].sex_desc = ",signed->pat_qual[i].sex_desc))
    CALL echo(build("signed-> pat_qual[",i,"].pat_type_desc =",signed->pat_qual[i].pat_type_desc))
    CALL echo(build("signed-> pat_qual[",i,"].doc_name = ",signed->pat_qual[i].doc_name))
    CALL echo(build("signed-> pat_qual[",i,"].res_doc_name =",signed->pat_qual[i].res_doc_name))
    CALL echo(build("signed-> pat_qual[",i,"].fac_desc =",signed->pat_qual[i].fac_desc))
    CALL echo(build("signed-> pat_qual[",i,"].nur_sta = ",signed->pat_qual[i].nur_sta))
    CALL echo(build("signed-> pat_qual[",i,"].room =",signed->pat_qual[i].room))
    CALL echo(build("signed-> pat_qual[",i,"].bed =",signed->pat_qual[i].bed))
  ENDFOR
 ENDIF
END GO
