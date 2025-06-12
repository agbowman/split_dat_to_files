CREATE PROGRAM cls_reslist_w_sn
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 name = vc
     2 unit = vc
     2 room = vc
     2 bed = vc
     2 mrn = vc
     2 gender = vc
     2 age = vc
     2 dob = vc
     2 dos = i4
     2 admit = vc
     2 disch = vc
     2 admitdoc = vc
     2 ptp = vc
     2 finclass = vc
     2 sn_qual_cnt = i4
     2 sn_qual[*]
       3 sn_text = vc
       3 sn_prsnl = vc
 )
 DECLARE life_mrn_alias_cd = f8
 DECLARE mrn_alias_cd = f8
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET count = 0
 SET xxx = fillstring(50," ")
 SET uname = fillstring(50," ")
 SET tempfile1a = fillstring(27," ")
 SET g = fillstring(27,"_")
 SET k = fillstring(34,"_")
 SET ops_ind = "N"
 SET life_mrn_alias_cd = 0.0
 SET mrn_alias_cd = 0.0
 IF ((request->batch_selection > " "))
  SET ops_ind = "Y"
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fin_alias_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "CMRN"
 EXECUTE cpm_get_cd_for_cdf
 SET life_mrn_alias_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET list_name = fillstring(40," ")
 FOR (x = 1 TO request->nv_cnt)
   IF ((request->nv[x].pvc_name="LISTNAME"))
    SET list_name = trim(request->nv[x].pvc_value)
   ENDIF
 ENDFOR
 IF ((request->visit_cnt > 0))
  SELECT DISTINCT INTO "nl:"
   e.encntr_id, e.reg_dt_tm, p.name_full_formatted,
   p.birth_dt_tm, pl.name_full_formatted, e.loc_nurse_unit_cd,
   e.loc_room_cd, e.loc_bed_cd, e.financial_class_cd,
   epr.seq, pl3.name_full_formatted
   FROM (dummyt d  WITH seq = value(request->visit_cnt)),
    encounter e,
    person p,
    person_alias pa,
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl pl,
    sticky_note sn,
    (dummyt d4  WITH seq = 1),
    prsnl pl2,
    person_prsnl_reltn ppr,
    (dummyt d5  WITH seq = 1),
    prsnl pl3,
    person_prsnl_reltn ppr1,
    (dummyt d6  WITH seq = 1),
    prsnl pl4
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=request->visit[d.seq].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (d1)
    JOIN (sn
    WHERE sn.parent_entity_id=p.person_id)
    JOIN (d4)
    JOIN (pl2
    WHERE pl2.person_id=sn.updt_id)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=life_mrn_alias_cd
     AND pa.active_ind=1)
    JOIN (d2)
    JOIN (epr
    WHERE epr.encntr_id=e.encntr_id
     AND epr.encntr_prsnl_r_cd=attend_doc_cd
     AND epr.active_ind=1
     AND ((epr.expiration_ind != 1) OR (epr.expiration_ind=null))
     AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pl
    WHERE pl.person_id=epr.prsnl_person_id)
    JOIN (d5)
    JOIN (ppr
    WHERE ppr.person_id=p.person_id
     AND ppr.person_prsnl_r_cd=72569)
    JOIN (pl3
    WHERE pl3.person_id=ppr.prsnl_person_id)
    JOIN (d6)
    JOIN (ppr1
    WHERE ppr1.person_id=p.person_id
     AND ppr1.person_prsnl_r_cd=98778)
    JOIN (pl4
    WHERE pl4.person_id=ppr1.prsnl_person_id)
   ORDER BY d.seq, sn.sticky_note_id DESC
  ;end select
 ENDIF
END GO
