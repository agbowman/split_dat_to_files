CREATE PROGRAM cps_get_allergy:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 person_org_sec_on = i2
   1 allergy_qual = i4
   1 allergy[*]
     2 allergy_id = f8
     2 allergy_instance_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 source_string = vc
     2 substance_nom_id = f8
     2 substance_ftdesc = vc
     2 substance_type_cd = f8
     2 substance_type_disp = c40
     2 substance_type_mean = c12
     2 reaction_class_cd = f8
     2 reaction_class_disp = c40
     2 reaction_class_mean = c12
     2 severity_cd = f8
     2 severity_disp = c40
     2 severity_mean = c12
     2 source_of_info_cd = f8
     2 source_of_info_disp = c40
     2 source_of_info_mean = c12
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 onset_precision_cd = f8
     2 onset_precision_disp = c40
     2 onset_precision_flag = i2
     2 reaction_status_cd = f8
     2 reaction_status_disp = c40
     2 reaction_status_mean = c12
     2 reaction_status_dt_tm = dq8
     2 created_dt_tm = dq8
     2 created_prsnl_id = f8
     2 created_prsnl_name = vc
     2 reviewed_dt_tm = dq8
     2 reviewed_tz = i4
     2 reviewed_prsnl_id = f8
     2 reviewed_prsnl_name = vc
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c40
     2 active_ind = i2
     2 orig_prsnl_id = f8
     2 orig_prsnl_name = vc
     2 updt_id = f8
     2 updt_name = vc
     2 updt_dt_tm = dq8
     2 cki = vc
     2 concept_source_cd = f8
     2 concept_source_disp = c40
     2 concept_source_mean = c12
     2 concept_identifier = vc
     2 cancel_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 cancel_prsnl_name = vc
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 source_of_info_ft = vc
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 rec_src_identifier = vc
     2 rec_src_string = vc
     2 rec_src_vocab_cd = f8
     2 verified_status_flag = i2
     2 reaction_qual = i4
     2 cmb_instance_id = f8
     2 cmb_flag = i2
     2 cmb_prsnl_id = f8
     2 cmb_prsnl_name = vc
     2 cmb_person_id = f8
     2 cmb_person_name = vc
     2 cmb_dt_tm = dq8
     2 cmb_tz = i4
     2 reaction[*]
       3 allergy_instance_id = f8
       3 reaction_id = f8
       3 reaction_nom_id = f8
       3 source_string = vc
       3 reaction_ftdesc = vc
       3 beg_effective_dt_tm = dq8
       3 active_ind = i2
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 cmb_reaction_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_prsnl_name = vc
       3 cmb_person_id = f8
       3 cmb_person_name = vc
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
     2 comment_qual = i4
     2 comment[*]
       3 allergy_comment_id = f8
       3 allergy_instance_id = f8
       3 organization_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 allergy_comment = vc
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 active_ind = i4
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 cmb_comment_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_prsnl_name = vc
       3 cmb_person_id = f8
       3 cmb_person_name = vc
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
     2 sub_concept_cki = vc
     2 source_vocab_cd = f8
     2 primary_vterm_ind = i2
     2 active_status_prsnl_name = vc
   1 adr_knt = i4
   1 adr[*]
     2 activity_data_reltn_id = f8
     2 person_id = f8
     2 activity_entity_name = vc
     2 activity_entity_id = f8
     2 activity_entity_inst_id = f8
     2 reltn_entity_name = vc
     2 reltn_entity_id = f8
     2 reltn_entity_all_ind = i2
   1 display_allergy_mode = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE nallergydispalymode = vc WITH public, noconstant("-1")
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE mul_algcat_cd = f8 WITH public, noconstant(0.0)
 DECLARE mul_drug_cd = f8 WITH public, noconstant(0.0)
 DECLARE dgddbmolcd = f8 WITH public, noconstant(0.0)
 DECLARE dgddbsubstcd = f8 WITH public, noconstant(0.0)
 DECLARE dgddbprodlncd = f8 WITH public, noconstant(0.0)
 DECLARE dgddbactgrpcd = f8 WITH public, noconstant(0.0)
 DECLARE idx = i4 WITH noconstant(0), public
 DECLARE i_pos = i4 WITH noconstant(0), public
 DECLARE dminfo_ok = i2 WITH private, noconstant(false)
 DECLARE encntr_org_sec_on = i2 WITH public, noconstant(false)
 DECLARE person_org_sec_on = i2 WITH public, noconstant(false)
 DECLARE network_var = f8 WITH constant(uar_get_code_by("MEANING",28881,"NETWORK")), public
 SET code_set = 12100
 SET cdf_meaning = "MUL.ALGCAT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,mul_algcat_cd)
 IF (mul_algcat_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "MUL.DRUG"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,mul_drug_cd)
 IF (mul_drug_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "GDDB.MOL"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,dgddbmolcd)
 IF (dgddbmolcd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "GDDB.SUBST"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,dgddbsubstcd)
 IF (dgddbsubstcd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "GDDB.PRODLN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,dgddbprodlncd)
 IF (dgddbprodlncd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "GDDB.ACTGRP"
 SET code_set = 12100
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,dgddbactgrpcd)
 IF (dgddbactgrpcd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 CALL display_allergy_mode_pref(null)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  a.allergy_id
  FROM allergy a,
   nomenclature n,
   reaction r,
   nomenclature n2,
   prsnl p,
   person ps,
   prsnl p1,
   prsnl p2,
   prsnl p3,
   prsnl p4,
   prsnl p5,
   prsnl p6,
   person p7,
   prsnl p8
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
   JOIN (r
   WHERE (r.allergy_id= Outerjoin(a.allergy_id))
    AND (r.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (r.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (n2
   WHERE (n2.nomenclature_id= Outerjoin(r.reaction_nom_id)) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(r.cmb_prsnl_id)) )
   JOIN (ps
   WHERE (ps.person_id= Outerjoin(r.cmb_person_id)) )
   JOIN (p1
   WHERE (p1.person_id= Outerjoin(a.created_prsnl_id)) )
   JOIN (p3
   WHERE (p3.person_id= Outerjoin(a.reviewed_prsnl_id)) )
   JOIN (p4
   WHERE (p4.person_id= Outerjoin(a.orig_prsnl_id)) )
   JOIN (p5
   WHERE (p5.person_id= Outerjoin(a.updt_id)) )
   JOIN (p6
   WHERE (p6.person_id= Outerjoin(a.cmb_prsnl_id)) )
   JOIN (p7
   WHERE (p7.person_id= Outerjoin(a.cmb_person_id)) )
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(a.cancel_prsnl_id)) )
   JOIN (p8
   WHERE (p8.person_id= Outerjoin(a.active_status_prsnl_id)) )
  ORDER BY a.allergy_id
  HEAD REPORT
   knt = 0
  HEAD a.allergy_id
   r_cnt = 0, ac_cnt = 0, knt += 1
   IF (mod(knt,10)=1)
    stat = alterlist(reply->allergy,(knt+ 10))
   ENDIF
   reply->allergy[knt].allergy_id = a.allergy_id, reply->allergy[knt].allergy_instance_id = a
   .allergy_instance_id, reply->allergy[knt].encntr_id = a.encntr_id,
   reply->allergy[knt].organization_id = a.organization_id, reply->allergy[knt].substance_nom_id = a
   .substance_nom_id, reply->allergy[knt].source_string = n.source_string,
   reply->allergy[knt].substance_ftdesc = a.substance_ftdesc, reply->allergy[knt].substance_type_cd
    = a.substance_type_cd, reply->allergy[knt].reaction_class_cd = a.reaction_class_cd,
   reply->allergy[knt].severity_cd = a.severity_cd, reply->allergy[knt].source_of_info_cd = a
   .source_of_info_cd, reply->allergy[knt].source_of_info_ft = a.source_of_info_ft,
   reply->allergy[knt].onset_dt_tm = a.onset_dt_tm, reply->allergy[knt].onset_tz = a.onset_tz, reply
   ->allergy[knt].onset_precision_cd = a.onset_precision_cd,
   reply->allergy[knt].onset_precision_flag = a.onset_precision_flag, reply->allergy[knt].
   reaction_status_cd = a.reaction_status_cd, reply->allergy[knt].reaction_status_dt_tm = a
   .reaction_status_dt_tm,
   reply->allergy[knt].created_dt_tm = a.created_dt_tm, reply->allergy[knt].created_prsnl_id = a
   .created_prsnl_id, reply->allergy[knt].reviewed_dt_tm = a.reviewed_dt_tm,
   reply->allergy[knt].reviewed_tz = a.reviewed_tz, reply->allergy[knt].reviewed_prsnl_id = a
   .reviewed_prsnl_id, reply->allergy[knt].cancel_reason_cd = a.cancel_reason_cd,
   reply->allergy[knt].active_ind = a.active_ind, reply->allergy[knt].orig_prsnl_id = a.orig_prsnl_id,
   reply->allergy[knt].updt_id = a.updt_id,
   reply->allergy[knt].updt_dt_tm = a.updt_dt_tm, fstat = assign(validate(reply->allergy[knt].
     source_vocab_cd),n.source_vocabulary_cd)
   IF (n.concept_source_cd IN (mul_algcat_cd, mul_drug_cd, dgddbmolcd, dgddbsubstcd, dgddbprodlncd,
   dgddbactgrpcd))
    reply->allergy[knt].cki = concat(trim(uar_get_code_meaning(n.concept_source_cd)),"!",trim(n
      .concept_identifier)), reply->allergy[knt].concept_source_cd = n.concept_source_cd, reply->
    allergy[knt].concept_identifier = n.concept_identifier,
    istat = assign(validate(reply->allergy[knt].primary_vterm_ind),n.primary_vterm_ind)
   ENDIF
   reply->allergy[knt].cancel_dt_tm = a.cancel_dt_tm, reply->allergy[knt].cancel_prsnl_id = a
   .cancel_prsnl_id, reply->allergy[knt].beg_effective_dt_tm = a.beg_effective_dt_tm,
   reply->allergy[knt].beg_effective_tz = a.beg_effective_tz, reply->allergy[knt].end_effective_dt_tm
    = a.end_effective_dt_tm, reply->allergy[knt].data_status_dt_tm = a.data_status_dt_tm,
   reply->allergy[knt].data_status_cd = a.data_status_cd, reply->allergy[knt].data_status_prsnl_id =
   a.data_status_prsnl_id, reply->allergy[knt].contributor_system_cd = a.contributor_system_cd,
   reply->allergy[knt].active_ind = a.active_ind, reply->allergy[knt].active_status_cd = a
   .active_status_cd, reply->allergy[knt].active_status_prsnl_id = a.active_status_prsnl_id,
   reply->allergy[knt].active_status_dt_tm = a.active_status_dt_tm, reply->allergy[knt].
   rec_src_identifier = a.rec_src_identifer, reply->allergy[knt].rec_src_string = a.rec_src_string,
   reply->allergy[knt].rec_src_vocab_cd = a.rec_src_vocab_cd, reply->allergy[knt].
   verified_status_flag = a.verified_status_flag, reply->allergy[knt].cmb_instance_id = a
   .cmb_instance_id,
   reply->allergy[knt].cmb_flag = a.cmb_flag, reply->allergy[knt].cmb_prsnl_id = a.cmb_prsnl_id,
   reply->allergy[knt].cmb_person_id = a.cmb_person_id,
   reply->allergy[knt].cmb_dt_tm = a.cmb_dt_tm, reply->allergy[knt].cmb_tz = a.cmb_tz, reply->
   allergy[knt].created_prsnl_name = p1.name_full_formatted,
   reply->allergy[knt].cancel_prsnl_name = p2.name_full_formatted, reply->allergy[knt].
   reviewed_prsnl_name = p3.name_full_formatted, reply->allergy[knt].orig_prsnl_name = p4
   .name_full_formatted,
   reply->allergy[knt].updt_name = p5.name_full_formatted, reply->allergy[knt].cmb_prsnl_name = p6
   .name_full_formatted, reply->allergy[knt].cmb_person_name = p7.name_full_formatted,
   sstat = assign(validate(reply->allergy[knt].sub_concept_cki),a.sub_concept_cki), sstat = assign(
    validate(reply->allergy[knt].active_status_prsnl_name),p8.name_full_formatted)
  DETAIL
   IF (r.reaction_id > 0)
    r_cnt += 1
    IF (mod(r_cnt,10)=1)
     stat = alterlist(reply->allergy[knt].reaction,(r_cnt+ 10))
    ENDIF
    reply->allergy[knt].reaction[r_cnt].allergy_instance_id = r.allergy_instance_id, reply->allergy[
    knt].reaction[r_cnt].reaction_id = r.reaction_id, reply->allergy[knt].reaction[r_cnt].
    reaction_nom_id = r.reaction_nom_id,
    reply->allergy[knt].reaction[r_cnt].source_string = n2.source_string, reply->allergy[knt].
    reaction[r_cnt].reaction_ftdesc = r.reaction_ftdesc, reply->allergy[knt].reaction[r_cnt].
    beg_effective_dt_tm = r.beg_effective_dt_tm,
    reply->allergy[knt].reaction[r_cnt].active_ind = r.active_ind, reply->allergy[knt].reaction[r_cnt
    ].data_status_dt_tm = r.data_status_dt_tm, reply->allergy[knt].reaction[r_cnt].
    data_status_prsnl_id = r.data_status_prsnl_id,
    reply->allergy[knt].reaction[r_cnt].data_status_cd = r.data_status_cd, reply->allergy[knt].
    reaction[r_cnt].contributor_system_cd = r.contributor_system_cd, reply->allergy[knt].reaction[
    r_cnt].active_status_cd = r.active_status_cd,
    reply->allergy[knt].reaction[r_cnt].active_status_dt_tm = r.active_status_dt_tm, reply->allergy[
    knt].reaction[r_cnt].active_status_prsnl_id = r.active_status_prsnl_id, reply->allergy[knt].
    reaction[r_cnt].cmb_reaction_id = r.cmb_reaction_id,
    reply->allergy[knt].reaction[r_cnt].cmb_flag = r.cmb_flag, reply->allergy[knt].reaction[r_cnt].
    cmb_prsnl_id = r.cmb_prsnl_id, reply->allergy[knt].reaction[r_cnt].cmb_prsnl_name = p
    .name_full_formatted,
    reply->allergy[knt].reaction[r_cnt].cmb_person_id = r.cmb_person_id, reply->allergy[knt].
    reaction[r_cnt].cmb_person_name = ps.name_full_formatted, reply->allergy[knt].reaction[r_cnt].
    cmb_dt_tm = r.cmb_dt_tm,
    reply->allergy[knt].reaction[r_cnt].cmb_tz = r.cmb_tz
   ENDIF
  FOOT  a.allergy_id
   reply->allergy[knt].reaction_qual = r_cnt, stat = alterlist(reply->allergy[knt].reaction,r_cnt)
  FOOT REPORT
   reply->allergy_qual = knt, stat = alterlist(reply->allergy,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ALLERGY"
  GO TO exit_script
 ENDIF
 SET sstat = assign(validate(reply->display_allergy_mode),nallergydispalymode)
 IF ((reply->allergy_qual < 1))
  GO TO exit_script
 ENDIF
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  SET encntr_org_sec_on = ccldminfo->sec_org_reltn
  SET person_org_sec_on = ccldminfo->person_org_sec
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "PERSON_ORG_SEC")
     AND di.info_number=1)
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_on = 1
    ELSEIF (di.info_name="PERSON_ORG_SEC")
     person_org_sec_on = 1
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "DM_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (person_org_sec_on=true
  AND encntr_org_sec_on=true)
  SET reply->person_org_sec_on = true
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM activity_data_reltn adr
   PLAN (adr
    WHERE expand(idx,1,reply->allergy_qual,adr.activity_entity_id,reply->allergy[idx].allergy_id)
     AND adr.activity_entity_name="ALLERGY")
   HEAD REPORT
    knt = 0, stat = alterlist(reply->adr,10)
   DETAIL
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->adr,(knt+ 9))
    ENDIF
    reply->adr[knt].activity_data_reltn_id = adr.activity_data_reltn_id, reply->adr[knt].person_id =
    request->person_id, reply->adr[knt].activity_entity_name = adr.activity_entity_name,
    reply->adr[knt].activity_entity_id = adr.activity_entity_id, reply->adr[knt].
    activity_entity_inst_id = adr.activity_entity_inst_id, reply->adr[knt].reltn_entity_name = adr
    .reltn_entity_name,
    reply->adr[knt].reltn_entity_id = adr.reltn_entity_id, reply->adr[knt].reltn_entity_all_ind = adr
    .reltn_entity_all_ind
   FOOT REPORT
    reply->adr_knt = knt, stat = alterlist(reply->adr,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ACTIVITY_DATA_RELTN"
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "NL:"
  d1.seq
  FROM allergy_comment ac,
   allergy a,
   prsnl p,
   prsnl p2,
   person ps
  PLAN (ac
   WHERE expand(idx,1,reply->allergy_qual,ac.allergy_id,reply->allergy[idx].allergy_id)
    AND ac.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ac.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE a.allergy_instance_id=ac.allergy_instance_id)
   JOIN (p
   WHERE (p.person_id= Outerjoin(ac.comment_prsnl_id)) )
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(ac.cmb_prsnl_id)) )
   JOIN (ps
   WHERE (ps.person_id= Outerjoin(ac.cmb_person_id)) )
  ORDER BY ac.allergy_id
  HEAD ac.allergy_id
   i_pos = 0, i_pos = locateval(i_pos,1,reply->allergy_qual,ac.allergy_id,reply->allergy[i_pos].
    allergy_id), ac_cnt = 0,
   stat = alterlist(reply->allergy[i_pos].comment,10)
  DETAIL
   IF (i_pos > 0)
    ac_cnt += 1
    IF (mod(ac_cnt,10)=1
     AND ac_cnt != 1)
     stat = alterlist(reply->allergy[i_pos].comment,(ac_cnt+ 9))
    ENDIF
    reply->allergy[i_pos].comment[ac_cnt].allergy_instance_id = ac.allergy_instance_id, reply->
    allergy[i_pos].comment[ac_cnt].organization_id = a.organization_id, reply->allergy[i_pos].
    comment[ac_cnt].allergy_comment_id = ac.allergy_comment_id,
    reply->allergy[i_pos].comment[ac_cnt].allergy_comment = ac.allergy_comment, reply->allergy[i_pos]
    .comment[ac_cnt].comment_dt_tm = ac.comment_dt_tm, reply->allergy[i_pos].comment[ac_cnt].
    comment_tz = ac.comment_tz,
    reply->allergy[i_pos].comment[ac_cnt].comment_prsnl_id = ac.comment_prsnl_id, reply->allergy[
    i_pos].comment[ac_cnt].beg_effective_dt_tm = ac.beg_effective_dt_tm, reply->allergy[i_pos].
    comment[ac_cnt].beg_effective_tz = ac.beg_effective_tz,
    reply->allergy[i_pos].comment[ac_cnt].active_ind = ac.active_ind, reply->allergy[i_pos].comment[
    ac_cnt].comment_prsnl_name = p.name_full_formatted, reply->allergy[i_pos].comment[ac_cnt].
    data_status_dt_tm = ac.data_status_dt_tm,
    reply->allergy[i_pos].comment[ac_cnt].data_status_prsnl_id = ac.data_status_prsnl_id, reply->
    allergy[i_pos].comment[ac_cnt].data_status_cd = ac.data_status_cd, reply->allergy[i_pos].comment[
    ac_cnt].contributor_system_cd = ac.contributor_system_cd,
    reply->allergy[i_pos].comment[ac_cnt].active_status_cd = ac.active_status_cd, reply->allergy[
    i_pos].comment[ac_cnt].active_status_dt_tm = ac.active_status_dt_tm, reply->allergy[i_pos].
    comment[ac_cnt].active_status_prsnl_id = ac.active_status_prsnl_id,
    reply->allergy[i_pos].comment[ac_cnt].cmb_comment_id = ac.cmb_comment_id, reply->allergy[i_pos].
    comment[ac_cnt].cmb_flag = ac.cmb_flag, reply->allergy[i_pos].comment[ac_cnt].cmb_prsnl_id = ac
    .cmb_prsnl_id,
    reply->allergy[i_pos].comment[ac_cnt].cmb_prsnl_name = p2.name_full_formatted, reply->allergy[
    i_pos].comment[ac_cnt].cmb_person_id = ac.cmb_person_id, reply->allergy[i_pos].comment[ac_cnt].
    cmb_person_name = ps.name_full_formatted,
    reply->allergy[i_pos].comment[ac_cnt].cmb_dt_tm = ac.cmb_dt_tm, reply->allergy[i_pos].comment[
    ac_cnt].cmb_tz = ac.cmb_tz
   ENDIF
  FOOT  ac.allergy_id
   reply->allergy[i_pos].comment_qual = ac_cnt, stat = alterlist(reply->allergy[i_pos].comment,ac_cnt
    )
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ALLERGY_COMMENT"
  GO TO exit_script
 ENDIF
 SUBROUTINE display_allergy_mode_pref(null)
   DECLARE iseqview = i4
   SELECT INTO "nl:"
    FROM view_prefs v
    WHERE v.frame_type="CHART"
     AND v.view_name="ALLERGY"
     AND v.application_number=600005
     AND v.prsnl_id=0.0
     AND v.position_cd=0.0
     AND v.active_ind=1
    DETAIL
     iseqview = v.view_seq
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM name_value_prefs n,
     detail_prefs vp
    WHERE n.pvc_name="ALLERGY_DISPLAY_MODE"
     AND n.parent_entity_id=vp.detail_prefs_id
     AND vp.view_name="ALLERGY"
     AND vp.comp_name="ALLERGY"
     AND vp.application_number=600005
     AND vp.active_ind=1
     AND vp.position_cd=0.0
     AND vp.prsnl_id=0.0
     AND vp.view_seq=iseqview
    DETAIL
     nallergydispalymode = n.pvc_value,
     CALL echo(build("***********************App Preference   pvc_value :",n.pvc_value)),
     CALL echo(build("***********************App Preference   nAllergyDispalyMode :",
      nallergydispalymode))
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->allergy_qual > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET cps_script_versoin = "025 03/17/05 SF3151"
END GO
