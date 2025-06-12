CREATE PROGRAM dcp_upd_prob_icd9_imo_tst:dba
 DECLARE vocab_cs = i4 WITH noconstant(400)
 DECLARE icd9_cd = f8 WITH noconstant(uar_get_code_by("MEANING",vocab_cs,"ICD9"))
 DECLARE snmct_cd = f8 WITH noconstant(uar_get_code_by("MEANING",vocab_cs,"SNMCT"))
 DECLARE imo_cd = f8 WITH noconstant(uar_get_code_by("MEANING",vocab_cs,"IMO"))
 DECLARE map_type_cs = i4 WITH noconstant(29223)
 DECLARE icd9_eq_imo_cd = f8 WITH noconstant(uar_get_code_by("MEANING",map_type_cs,"ICD9=IMO"))
 DECLARE icd9_rel_imo_cd = f8 WITH noconstant(uar_get_code_by("MEANING",map_type_cs,"ICD9CM~IMO"))
 DECLARE snmct_eq_imo_cd = f8 WITH noconstant(uar_get_code_by("MEANING",map_type_cs,"SNMCT=IMO"))
 DECLARE snmct_rel_imo_cd = f8 WITH noconstant(uar_get_code_by("MEANING",map_type_cs,"SNOMED~IMO"))
 DECLARE principle_type_cs = i4 WITH noconstant(401)
 DECLARE diag_cd = f8 WITH noconstant(uar_get_code_by("MEANING",principle_type_cs,"DIAG"))
 DECLARE vocab_axis_cs = i4 WITH noconstant(15849)
 DECLARE icd9_disease_cd = f8 WITH noconstant(uar_get_code_by("MEANING",vocab_axis_cs,"ICD9-DISEASE")
  )
 DECLARE finding_cd = f8 WITH noconstant(uar_get_code_by("MEANING",vocab_axis_cs,"FINDING"))
 DECLARE max_nomen_id = f8 WITH noconstant(0.0)
 DECLARE max_cross_map_id = f8 WITH noconstant(0.0)
 DECLARE max_problem_inst_id = f8 WITH noconstant(0.0)
 DECLARE updt_dt_tm = dq8 WITH noconstant(cnvtdatetime("21-SEP-2013 00:00:00"))
 SELECT INTO "nl:"
  maximum_nomenclature_id = max(nomenclature_id)
  FROM nomenclature
  DETAIL
   max_nomen_id = maximum_nomenclature_id
 ;end select
 SELECT INTO "nl:"
  maximum_cross_map_id = max(cmt_cross_map_id)
  FROM cmt_cross_map
  DETAIL
   max_cross_map_id = maximum_cross_map_id
 ;end select
 SELECT INTO "nl:"
  maximum_problem_inst_id = max(problem_instance_id)
  FROM problem
  DETAIL
   max_problem_inst_id = maximum_problem_inst_id
 ;end select
 DECLARE src_concept_cki_1 = vc WITH noconstant("JUNIT!10001")
 DECLARE src_concept_cki_2 = vc WITH noconstant("JUNIT!10002")
 DECLARE src_concept_cki_3 = vc WITH noconstant("JUNIT!10003")
 DECLARE src_concept_cki_5 = vc WITH noconstant("JUNIT!10005")
 DECLARE src_concept_cki_6 = vc WITH noconstant("JUNIT!10006")
 DECLARE src_concept_cki_7 = vc WITH noconstant("JUNIT!10007")
 DECLARE src_concept_cki_8 = vc WITH noconstant("JUNIT!10008")
 DECLARE src_concept_cki_9 = vc WITH noconstant("JUNIT!10009")
 DECLARE src_concept_cki_10 = vc WITH noconstant("JUNIT!10010")
 DECLARE tgt_concept_cki_1 = vc WITH noconstant("JUNIT!20001")
 DECLARE tgt_concept_cki_2 = vc WITH noconstant("JUNIT!20002")
 DECLARE tgt_concept_cki_3a = vc WITH noconstant("JUNIT!20003")
 DECLARE tgt_concept_cki_3b = vc WITH noconstant("JUNIT!20004")
 DECLARE tgt_concept_cki_3c = vc WITH noconstant("JUNIT!20005")
 DECLARE tgt_concept_cki_6 = vc WITH noconstant("JUNIT!20006")
 DECLARE tgt_concept_cki_7a = vc WITH noconstant("JUNIT!20007")
 DECLARE tgt_concept_cki_7b = vc WITH noconstant("JUNIT!20008")
 DECLARE tgt_concept_cki_7c = vc WITH noconstant("JUNIT!20009")
 DECLARE tgt_concept_cki_8a = vc WITH noconstant("JUNIT!20010")
 DECLARE tgt_concept_cki_8b = vc WITH noconstant("JUNIT!20011")
 DECLARE tgt_concept_cki_8c = vc WITH noconstant("JUNIT!20012")
 DECLARE tgt_concept_cki_9a = vc WITH noconstant("JUNIT!20013")
 DECLARE tgt_concept_cki_9b = vc WITH noconstant("JUNIT!20014")
 DECLARE tgt_concept_cki_10 = vc WITH noconstant("JUNIT!20015")
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_1 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_2 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_3 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_5 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_6 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_7 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_8 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_9 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE src_nomen_id_10 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_2 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_3a = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_3b = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_3c = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_6 = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_7a = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_7b = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_7c = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_8a = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_8b = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_8c = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_9a = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_9b = f8 WITH noconstant(max_nomen_id)
 SET max_nomen_id = (max_nomen_id+ 1)
 DECLARE tgt_nomen_id_10 = f8 WITH noconstant(max_nomen_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_1 = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_2 = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_3a = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_3b = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_3c = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_6 = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_7a = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_7b = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_7c = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_8a = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_8b = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_8c = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_9a = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_9b = f8 WITH noconstant(max_cross_map_id)
 SET max_cross_map_id = (max_cross_map_id+ 1)
 DECLARE crossmap_id_10 = f8 WITH noconstant(max_cross_map_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_1 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_2 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_3 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_4 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_5 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_6 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_7 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_8 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_9 = f8 WITH noconstant(max_problem_inst_id)
 SET max_problem_inst_id = (max_problem_inst_id+ 1)
 DECLARE problem_inst_id_10 = f8 WITH noconstant(max_problem_inst_id)
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_1, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_1, n.concept_cki = src_concept_cki_1, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = icd9_cd, n.vocab_axis_cd = icd9_disease_cd, n.source_string =
   "JUNIT Fracture of arm NOS",
   n.source_string_keycap = "JUNIT FRACTURE OF ARM NOS", n.active_ind = 1, n.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_1, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_1, ccm.concept_cki = src_concept_cki_1, ccm
   .target_concept_cki = tgt_concept_cki_1,
   ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ccm
   .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
   ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_1, p.problem_id = problem_inst_id_1, p
   .originating_nomenclature_id = src_nomen_id_1,
   p.nomenclature_id = src_nomen_id_1, p.problem_type_flag = 0, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_2, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_2, n.concept_cki = src_concept_cki_2, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Adrenal hypertension",
   n.source_string_keycap = "JUNIT ADRENAL HYPERTENSION", n.active_ind = 1, n.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_2, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_2, n.concept_cki = tgt_concept_cki_2, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Adrenal hypertension imo",
   n.source_string_keycap = "JUNIT ADRENAL HYPERTENSION IMO", n.cmti = tgt_concept_cki_2, n
   .active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_2, ccm.concept_cki = src_concept_cki_2, ccm
   .target_concept_cki = tgt_concept_cki_2,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_2, p.problem_id = problem_inst_id_2, p
   .originating_nomenclature_id = src_nomen_id_2,
   p.nomenclature_id = src_nomen_id_2, p.problem_type_flag = 0, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_3, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_3, n.concept_cki = src_concept_cki_3, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Fracture of ankle",
   n.source_string_keycap = "JUNIT FRACTURE OF ANKLE", n.active_ind = 1, n.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_3a, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_3a, n.concept_cki = tgt_concept_cki_3a, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Fracture of ankle imo",
   n.source_string_keycap = "JUNIT FRACTURE OF ANKLE IMO", n.cmti = tgt_concept_cki_3a, n.active_ind
    = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_3b, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_3b, n.concept_cki = tgt_concept_cki_3b, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Fracture_of_ankle_imo",
   n.source_string_keycap = "JUNIT FRACTURE_OF_ANKLE_IMO", n.cmti = tgt_concept_cki_3b, n.active_ind
    = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_3c, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_3c, n.concept_cki = tgt_concept_cki_3c, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Fracture of lower ankle",
   n.source_string_keycap = "JUNIT FRACTURE OF LOWER ANKLE", n.cmti = tgt_concept_cki_3c, n
   .active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_3a, ccm.concept_cki = src_concept_cki_3, ccm
   .target_concept_cki = tgt_concept_cki_3a,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_3b, ccm.concept_cki = src_concept_cki_3, ccm
   .target_concept_cki = tgt_concept_cki_3b,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_3c, ccm.concept_cki = src_concept_cki_3, ccm
   .target_concept_cki = tgt_concept_cki_3c,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_3, p.problem_id = problem_inst_id_3, p
   .originating_nomenclature_id = src_nomen_id_3,
   p.nomenclature_id = src_nomen_id_3, p.problem_type_flag = 0, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_4, p.problem_id = problem_inst_id_4, p.problem_ftdesc
    = "freetext",
   p.annotated_display = "freetext", p.originating_nomenclature_id = 0.0, p.nomenclature_id = 0.0,
   p.problem_type_flag = 0, p.active_ind = 1, p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_5, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_5, n.concept_cki = src_concept_cki_5, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Pregnancy",
   n.source_string_keycap = "JUNIT PREGNANCY", n.active_ind = 1, n.beg_effective_dt_tm = cnvtdatetime
   (curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_5, p.problem_id = problem_inst_id_5, p
   .problem_type_flag = 2,
   p.originating_nomenclature_id = src_nomen_id_5, p.nomenclature_id = src_nomen_id_5, p.active_ind
    = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_6, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_6, n.concept_cki = src_concept_cki_6, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Appendectomy",
   n.source_string_keycap = "JUNIT APPENDECTOMY", n.active_ind = 1, n.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_6, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_6, n.concept_cki = tgt_concept_cki_6, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Appendectomy",
   n.source_string_keycap = "JUNIT APPENDECTOMY", n.cmti = tgt_concept_cki_6, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_6, ccm.concept_cki = src_concept_cki_6, ccm
   .target_concept_cki = tgt_concept_cki_6,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_6, p.problem_id = problem_inst_id_6, p
   .originating_nomenclature_id = src_nomen_id_6,
   p.nomenclature_id = src_nomen_id_6, p.problem_type_flag = 0, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_7, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_7, n.concept_cki = src_concept_cki_7, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Ingrown toenail",
   n.source_string_keycap = "JUNIT INGROWN TOENAIL", n.active_ind = 1, n.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_7a, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_7a, n.concept_cki = tgt_concept_cki_7a, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Outgrown toenail",
   n.source_string_keycap = "JUNIT OUTGROWN TOENAIL", n.cmti = tgt_concept_cki_7a, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_7b, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_7b, n.concept_cki = tgt_concept_cki_7b, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Ingrown toenail",
   n.source_string_keycap = "JUNIT INGROWN TOENAIL", n.cmti = tgt_concept_cki_7b, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_7c, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_7c, n.concept_cki = tgt_concept_cki_7c, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Overgrown toenail",
   n.source_string_keycap = "JUNIT OVERGROWN TOENAIL", n.cmti = tgt_concept_cki_7c, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_7a, ccm.concept_cki = src_concept_cki_7, ccm
   .target_concept_cki = tgt_concept_cki_7a,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_7b, ccm.concept_cki = src_concept_cki_7, ccm
   .target_concept_cki = tgt_concept_cki_7b,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_7c, ccm.concept_cki = src_concept_cki_7, ccm
   .target_concept_cki = tgt_concept_cki_7c,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_7, p.problem_id = problem_inst_id_7, p
   .originating_nomenclature_id = src_nomen_id_7,
   p.nomenclature_id = src_nomen_id_7, p.problem_type_flag = 0, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_8, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_8, n.concept_cki = src_concept_cki_8, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Embedded toenail",
   n.source_string_keycap = "JUNIT EMBEDDED TOENAIL", n.active_ind = 1, n.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_8a, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_8a, n.concept_cki = tgt_concept_cki_8a, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Embedded toenail",
   n.source_string_keycap = "JUNIT EMBEDDED TOENAIL", n.active_ind = 1, n.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_8b, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_8b, n.concept_cki = tgt_concept_cki_8b, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Embedded toenail2",
   n.source_string_keycap = "JUNIT EMBEDDED TOENAIL", n.cmti = tgt_concept_cki_8b, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_8c, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_8c, n.concept_cki = tgt_concept_cki_8c, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Embedded toenail_",
   n.source_string_keycap = "JUNIT EMBEDDED TOENAIL_", n.cmti = tgt_concept_cki_8c, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_8a, ccm.concept_cki = src_concept_cki_8, ccm
   .target_concept_cki = tgt_concept_cki_8a,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_8b, ccm.concept_cki = src_concept_cki_8, ccm
   .target_concept_cki = tgt_concept_cki_8b,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_8c, ccm.concept_cki = src_concept_cki_8, ccm
   .target_concept_cki = tgt_concept_cki_8c,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_8, p.problem_id = problem_inst_id_8, p
   .originating_nomenclature_id = src_nomen_id_8,
   p.nomenclature_id = src_nomen_id_8, p.problem_type_flag = 0, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_9, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_9, n.concept_cki = src_concept_cki_9, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT Furuncle",
   n.source_string_keycap = "JUNIT FURUNCLE", n.active_ind = 1, n.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_9a, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_9a, n.concept_cki = tgt_concept_cki_9a, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string = "JUNIT Furuncle",
   n.source_string_keycap = "JUNIT FURUNCLE", n.cmti = tgt_concept_cki_9a, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_9b, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_9b, n.concept_cki = tgt_concept_cki_9b, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = snmct_cd, n.vocab_axis_cd = finding_cd, n.source_string =
   "JUNIT diabetes",
   n.source_string_keycap = "JUNIT DIABETES", n.cmti = tgt_concept_cki_9b, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_9a, ccm.concept_cki = src_concept_cki_9, ccm
   .target_concept_cki = tgt_concept_cki_9a,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_9b, ccm.concept_cki = src_concept_cki_9, ccm
   .target_concept_cki = tgt_concept_cki_9b,
   ccm.source_vocabulary_cd = snmct_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_9, p.problem_id = problem_inst_id_9, p
   .originating_nomenclature_id = src_nomen_id_9,
   p.nomenclature_id = src_nomen_id_9, p.problem_type_flag = 0, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = src_concept_cki_10, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = src_nomen_id_10, n.concept_cki = src_concept_cki_10, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = icd9_cd, n.vocab_axis_cd = icd9_disease_cd, n.source_string = "Pneumonia",
   n.source_string_keycap = "PNEUMONIA", n.active_ind = 1, n.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_concept c
  SET c.concept_cki = tgt_concept_cki_10, c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = tgt_nomen_id_10, n.concept_cki = tgt_concept_cki_10, n.principle_type_cd =
   diag_cd,
   n.source_vocabulary_cd = imo_cd, n.vocab_axis_cd = finding_cd, n.source_string = "Pneumonia",
   n.source_string_keycap = "PNEUMONIA", n.cmti = tgt_concept_cki_10, n.active_ind = 1,
   n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM cmt_cross_map ccm
  SET ccm.cmt_cross_map_id = crossmap_id_10, ccm.concept_cki = src_concept_cki_10, ccm
   .target_concept_cki = tgt_concept_cki_10,
   ccm.source_vocabulary_cd = imo_cd, ccm.active_ind = 1, ccm.beg_effective_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ccm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ccm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 INSERT  FROM problem p
  SET p.problem_instance_id = problem_inst_id_10, p.problem_id = problem_inst_id_10, p
   .originating_nomenclature_id = src_nomen_id_10,
   p.nomenclature_id = src_nomen_id_10, p.problem_type_flag = 1, p.active_ind = 1,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), p.updt_dt_tm = cnvtdatetime(updt_dt_tm)
 ;end insert
 DELETE  FROM dm_info
  WHERE info_domain="DCP_UPD_PROB_ICD9_SNMCT_IMO"
 ;end delete
 EXECUTE dcp_upd_prob_icd9_snmct_imo_p
 DECLARE mf_readme_num = i4 WITH protect, noconstant(0)
 SET mf_readme_num = 1
 EXECUTE dcp_upd_prob_icd9_snmct_imo_c
 SET mf_readme_num = 2
 EXECUTE dcp_upd_prob_icd9_snmct_imo_c
 SET mf_readme_num = 3
 EXECUTE dcp_upd_prob_icd9_snmct_imo_c
 SET mf_readme_num = 4
 EXECUTE dcp_upd_prob_icd9_snmct_imo_c
 SET mf_readme_num = 5
 EXECUTE dcp_upd_prob_icd9_snmct_imo_c
 EXECUTE dcp_upd_prob_icd9_snmct_imo_p2
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_1)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=src_nomen_id_1)
    CALL echo(":: Success - PROBLEM 1 (Non-Qualifying)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 1 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(src_nomen_id_1)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_2)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=src_nomen_id_2)
    CALL echo(":: Success - PROBLEM 2 (Non-Qualifying)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 2 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(src_nomen_id_2)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_3)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=src_nomen_id_3)
    CALL echo(":: Success - PROBLEM 3 (Non-Qualifying)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 3 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(src_nomen_id_3)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_4)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=0.0)
    CALL echo(":: Success - PROBLEM 4 (Non-Qualifying)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 4 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(0.0)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_5)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=src_nomen_id_5)
    CALL echo(":: Success - PROBLEM 5 (Non-Qualifying)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 5 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(src_nomen_id_5)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_6)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=tgt_nomen_id_6)
    CALL echo(":: Success - PROBLEM 6 (Qualified for update)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 6 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(tgt_nomen_id_6))),
   CALL echo(concat(":: Converted From Begin orig_nomen_id: ",build(src_nomen_id_6)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_7)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=tgt_nomen_id_7b)
    CALL echo(":: Success - PROBLEM 7 (Qualified for update)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 7 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(tgt_nomen_id_7b))),
   CALL echo(concat(":: Converted From Begin orig_nomen_id: ",build(src_nomen_id_7)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_8)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=tgt_nomen_id_8b)
    CALL echo(":: Success - PROBLEM 8 (Qualified for update)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 8 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(tgt_nomen_id_8b))),
   CALL echo(concat(":: Converted From Begin orig_nomen_id: ",build(src_nomen_id_8)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_9)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=tgt_nomen_id_9a)
    CALL echo(":: Success - PROBLEM 9 (Qualified for update)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 9 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(tgt_nomen_id_9a))),
   CALL echo(concat(":: Converted From Begin orig_nomen_id: ",build(src_nomen_id_9)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id, orig_nomen_id = p.originating_nomenclature_id
  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_10)
  DETAIL
   new_orig_nomen_id = orig_nomen_id
   IF (new_orig_nomen_id=tgt_nomen_id_10)
    CALL echo(":: Success - PROBLEM 10 (Qualified for update)")
   ELSE
    CALL echo(
    ":: Failure occurred for PROBLEM 10 - it contains an unexpected originating_nomenclature_id field."
    )
   ENDIF
   CALL echo(concat(":: AFTER README RUN: orig_nomen_id: ",build(new_orig_nomen_id)," Should be: ",
    build(tgt_nomen_id_10))),
   CALL echo(concat(":: Converted From Begin orig_nomen_id: ",build(src_nomen_id_10)))
  WITH nocounter
 ;end select
 DELETE  FROM problem p
  WHERE p.problem_instance_id IN (problem_inst_id_1, problem_inst_id_2, problem_inst_id_3,
  problem_inst_id_4, problem_inst_id_5,
  problem_inst_id_6, problem_inst_id_7, problem_inst_id_8, problem_inst_id_9, problem_inst_id_10)
 ;end delete
 COMMIT
 DELETE  FROM cmt_cross_map ccm
  WHERE ccm.cmt_cross_map_id IN (crossmap_id_1, crossmap_id_2, crossmap_id_3a, crossmap_id_3b,
  crossmap_id_3c,
  crossmap_id_6, crossmap_id_7a, crossmap_id_7b, crossmap_id_7c, crossmap_id_8a,
  crossmap_id_8b, crossmap_id_8c, crossmap_id_9a, crossmap_id_9b, crossmap_id_10)
 ;end delete
 COMMIT
 DELETE  FROM nomenclature n
  WHERE n.nomenclature_id IN (src_nomen_id_1, src_nomen_id_2, src_nomen_id_3, src_nomen_id_5,
  src_nomen_id_6,
  src_nomen_id_7, src_nomen_id_8, src_nomen_id_9, src_nomen_id_10, tgt_nomen_id_2,
  tgt_nomen_id_3a, tgt_nomen_id_3b, tgt_nomen_id_3c, tgt_nomen_id_6, tgt_nomen_id_7a,
  tgt_nomen_id_7b, tgt_nomen_id_7c, tgt_nomen_id_8a, tgt_nomen_id_8b, tgt_nomen_id_8c,
  tgt_nomen_id_9a, tgt_nomen_id_9b, tgt_nomen_id_10)
 ;end delete
 COMMIT
 DELETE  FROM cmt_concept c
  WHERE c.concept_cki IN (src_concept_cki_1, src_concept_cki_2, src_concept_cki_3, src_concept_cki_5,
  src_concept_cki_6,
  src_concept_cki_7, src_concept_cki_8, src_concept_cki_9, src_concept_cki_10, tgt_concept_cki_1,
  tgt_concept_cki_2, tgt_concept_cki_3a, tgt_concept_cki_3b, tgt_concept_cki_3c, tgt_concept_cki_6,
  tgt_concept_cki_7a, tgt_concept_cki_7b, tgt_concept_cki_7c, tgt_concept_cki_8a, tgt_concept_cki_8b,
  tgt_concept_cki_8c, tgt_concept_cki_9a, tgt_concept_cki_9b, tgt_concept_cki_10)
 ;end delete
 COMMIT
END GO
