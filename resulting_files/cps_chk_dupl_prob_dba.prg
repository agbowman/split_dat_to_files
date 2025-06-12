CREATE PROGRAM cps_chk_dupl_prob:dba
 FREE SET reply
 RECORD reply(
   1 dupl_ind = i2
   1 dupl_problem_id = f8
   1 vocab_qual = i2
   1 vocab[*]
     2 source_vocab_cd = f8
     2 source_vocab_disp = c40
     2 source_identifier = vc
     2 source_string = vc
   1 dupl_problem_knt = i2
   1 dupl_problem[*]
     2 dupl_ind = i2
     2 dupl_problem_id = f8
     2 nomenclature_id = f8
     2 life_cycle_status_cd = f8
     2 life_cycle_status_display = c40
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 source_vocabulary_mean = c40
     2 source_identifier = vc
     2 source_string = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_mean = c40
     2 classification_cd = f8
     2 classification_disp = c40
     2 classification_mean = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET hold
 RECORD hold(
   1 source_vocab_cd = f8
   1 source_identifier = vc
   1 concept_source_cd = f8
   1 concept_identifier = vc
   1 nomenclature_id = f8
   1 source_string = vc
 )
 SET no_dup = 0
 SET nomid_dup = 1
 SET vocab_dup = 2
 SET concept_dup = 3
 SET string_dup = 4
 SET both_dup = 5
 SET str_conc_dup = 6
 SET reply->dupl_ind = no_dup
 SET reply->vocab_qual = 0
 SET reply->status_data[1].status = "S"
 SET knt = 0
 SET nomen_dup = 0
 SET dup_found = 0
 SET prev_problem_id = 0.0
 IF ((((request->nomenclature_id < 1)
  AND (request->problem_ftdesc=" ")) OR ((request->person_id < 1))) )
  SET reply->status_data[1].status = "F"
  SET reply->status_data[1].subeventstatus[1].operationname = "Validating Input"
  SET reply->status_data[1].subeventstatus[1].operationstatus = "F"
  SET reply->status_data[1].subeventstatus[1].targetobjectvalue =
  "Person_Id and/or Nomenclature_Id <= 0"
  GO TO end_program
 ENDIF
 SET code_set = 12030
 SET cancel_life_cycle = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,"CANCELED",code_cnt,cancel_life_cycle)
 SET hold->source_vocab_cd = 0.0
 SET hold->source_identifier = ""
 SET hold->concept_source_cd = 0.0
 SET hold->concept_identifier = ""
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  PLAN (n
   WHERE (n.nomenclature_id=request->nomenclature_id)
    AND (request->problem_ftdesc=" "))
  DETAIL
   hold->source_vocab_cd = n.source_vocabulary_cd, hold->source_identifier = n.source_identifier,
   hold->concept_source_cd = n.concept_source_cd,
   hold->concept_identifier = n.concept_identifier, hold->source_string = n.source_string
  WITH nocounter
 ;end select
 IF (curqual < 1
  AND (request->nomenclature_id > 0))
  SET reply->status_data[1].status = "F"
  SET reply->status_data[1].subeventstatus[1].operationname = "READING"
  SET reply->status_data[1].subeventstatus[1].operationstatus = "F"
  SET reply->status_data[1].subeventstatus[1].targetobjectname = "NOMENCLATURE"
  SET reply->status_data[1].subeventstatus[1].targetobjectvalue = "Nomenclature_Id"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  p.person_id, p.problem_id
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.problem_id > 0
    AND p.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id))
  ORDER BY p.problem_id, p.problem_instance_id DESC
  HEAD REPORT
   knt = 0, stat = alterlist(reply->dupl_problem,10), vocab_knt = 0,
   stat = alterlist(reply->vocab,10), prev_problem_id = 0
  HEAD p.problem_instance_id
   nomen_dup = 0, dup_found = 0
   IF (p.life_cycle_status_cd != cancel_life_cycle
    AND prev_problem_id != p.problem_id)
    IF ((request->nomenclature_id > 0))
     IF ((request->nomenclature_id=p.nomenclature_id))
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(reply->dupl_problem,(knt+ 9))
      ENDIF
      reply->dupl_problem[knt].nomenclature_id = p.nomenclature_id, reply->dupl_problem[knt].dupl_ind
       = nomid_dup, reply->dupl_ind = nomid_dup,
      nomen_dup = 1, dup_found = 1
     ENDIF
    ELSE
     IF (cnvtupper(p.problem_ftdesc)=cnvtupper(request->problem_ftdesc)
      AND (request->nomenclature_id=0))
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(reply->dupl_problem,(knt+ 9))
      ENDIF
      reply->dupl_problem[knt].source_string = p.problem_ftdesc, reply->dupl_problem[knt].dupl_ind =
      nomid_dup, reply->dupl_ind = nomid_dup,
      dup_found = 1
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (p.life_cycle_status_cd != cancel_life_cycle
    AND prev_problem_id != p.problem_id
    AND n.nomenclature_id > 0)
    IF ((hold->source_identifier > " "))
     IF ((n.source_vocabulary_cd=hold->source_vocab_cd)
      AND (n.source_identifier=hold->source_identifier))
      IF ((request->nomenclature_id > 0)
       AND (request->nomenclature_id != p.nomenclature_id))
       knt = (knt+ 1)
       IF (mod(knt,10)=1
        AND knt != 1)
        stat = alterlist(reply->dupl_problem,(knt+ 9))
       ENDIF
      ENDIF
      IF (nomen_dup=0)
       reply->dupl_ind = vocab_dup, reply->dupl_problem[knt].dupl_ind = vocab_dup, reply->
       dupl_problem[knt].nomenclature_id = p.nomenclature_id,
       dup_found = 1
      ENDIF
      reply->dupl_problem[knt].source_vocabulary_cd = n.source_vocabulary_cd, reply->dupl_problem[knt
      ].source_identifier = n.source_identifier, reply->dupl_problem[knt].source_string = n
      .source_string,
      vocab_knt = (vocab_knt+ 1)
      IF (mod(vocab_knt,10)=1
       AND vocab_knt != 1)
       stat = alterlist(reply->vocab,(vocab_knt+ 9))
      ENDIF
      reply->vocab[vocab_knt].source_vocab_cd = n.source_vocabulary_cd, reply->vocab[vocab_knt].
      source_identifier = n.source_identifier, reply->vocab[vocab_knt].source_string = n
      .source_string,
      hold->nomenclature_id = n.nomenclature_id
     ENDIF
    ELSE
     IF (cnvtupper(hold->source_string)=cnvtupper(n.source_string))
      IF ((request->nomenclature_id > 0)
       AND (request->nomenclature_id != p.nomenclature_id))
       knt = (knt+ 1)
       IF (mod(knt,10)=1
        AND knt != 1)
        stat = alterlist(reply->dupl_problem,(knt+ 9))
       ENDIF
      ENDIF
      IF (nomen_dup=0)
       reply->dupl_ind = string_dup, reply->dupl_problem[knt].dupl_ind = string_dup, reply->
       dupl_problem[knt].nomenclature_id = p.nomenclature_id,
       vocab_knt = (vocab_knt+ 1)
       IF (mod(vocab_knt,10)=1
        AND vocab_knt != 1)
        stat = alterlist(reply->vocab,(vocab_knt+ 9))
       ENDIF
       reply->vocab[vocab_knt].source_vocab_cd = n.source_vocabulary_cd, reply->vocab[vocab_knt].
       source_identifier = n.source_identifier, reply->vocab[vocab_knt].source_string = n
       .source_string,
       dup_found = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((hold->concept_identifier > " "))
     IF ((n.concept_source_cd=hold->concept_source_cd)
      AND (n.concept_identifier=hold->concept_identifier))
      IF (nomen_dup=0)
       IF ((reply->dupl_problem[knt].dupl_ind=vocab_dup))
        reply->dupl_ind = both_dup, reply->dupl_problem[knt].dupl_ind = both_dup
       ELSEIF ((reply->dupl_problem[knt].dupl_ind=string_dup))
        reply->dupl_ind = str_conc_dup, reply->dupl_problem[knt].dupl_ind = str_conc_dup
       ELSE
        IF ((request->nomenclature_id > 0)
         AND (request->nomenclature_id != p.nomenclature_id))
         knt = (knt+ 1)
         IF (mod(knt,10)=1
          AND knt != 1)
          stat = alterlist(reply->dupl_problem,(knt+ 9))
         ENDIF
        ENDIF
        reply->dupl_ind = concept_dup, reply->dupl_problem[knt].dupl_ind = concept_dup, reply->
        dupl_problem[knt].nomenclature_id = p.nomenclature_id,
        reply->dupl_problem[knt].source_vocabulary_cd = n.source_vocabulary_cd, reply->dupl_problem[
        knt].source_identifier = n.source_identifier, reply->dupl_problem[knt].source_string = n
        .source_string,
        vocab_knt = (vocab_knt+ 1)
        IF (mod(vocab_knt,10)=1
         AND vocab_knt != 1)
         stat = alterlist(reply->vocab,(vocab_knt+ 9))
        ENDIF
        reply->vocab[vocab_knt].source_vocab_cd = n.source_vocabulary_cd, reply->vocab[vocab_knt].
        source_identifier = n.source_identifier, reply->vocab[vocab_knt].source_string = n
        .source_string
       ENDIF
      ENDIF
      dup_found = 1
     ENDIF
    ENDIF
   ENDIF
  FOOT  p.problem_instance_id
   IF (dup_found=1)
    reply->dupl_problem[knt].dupl_problem_id = p.problem_id, reply->dupl_problem[knt].
    life_cycle_status_cd = p.life_cycle_status_cd, reply->dupl_problem_id = p.problem_id,
    reply->dupl_problem[knt].life_cycle_status_display = uar_get_code_display(p.life_cycle_status_cd),
    reply->dupl_problem[knt].contributor_system_cd = p.contributor_system_cd, reply->dupl_problem[knt
    ].classification_cd = p.classification_cd,
    CALL echo(build("class_cd : ",reply->dupl_problem[knt].classification_cd))
   ENDIF
   prev_problem_id = p.problem_id
  FOOT REPORT
   reply->vocab_qual = vocab_knt, stat = alterlist(reply->vocab,vocab_knt), reply->dupl_problem_knt
    = knt,
   stat = alterlist(reply->dupl_problem,knt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data[1].status = "S"
  GO TO end_program
 ELSE
  SET reply->status_data[1].status = "S"
  CALL echo("no dups found")
 ENDIF
#end_program
 SET cps_ver = "008 06/09/04 SF3151"
END GO
