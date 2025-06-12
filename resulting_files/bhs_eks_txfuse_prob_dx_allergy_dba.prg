CREATE PROGRAM bhs_eks_txfuse_prob_dx_allergy:dba
 PROMPT
  "Type       " = ""
  WITH type
 SET log_message = "inside bhs_eks_txfuse_prob_dx_allergy"
 SET retval = 0
 DECLARE diagcnt = i2 WITH protect, noconstant(0)
 DECLARE canceled = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"CANCELED"))
 DECLARE resolved = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
 DECLARE inactive = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"INACTIVE"))
 DECLARE all_canceled = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE all_resolved = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"RESOLVED"))
 DECLARE print_out(header_text=vc,level=i2,required=i2,space_ind=i4) = null
 DECLARE beg_doc = vc WITH constant("{\rtf1\ansi\deff0{\fonttbl{\f0\froman times new roman;}}\fs22")
 DECLARE end_doc = c1 WITH constant("}")
 DECLARE beg_bold = c2 WITH constant("\b")
 DECLARE end_bold = c3 WITH constant("\b0")
 DECLARE beg_ital = c2 WITH constant("\i")
 DECLARE end_ital = c3 WITH constant("\i0")
 DECLARE beg_uline = c3 WITH constant("\ul ")
 DECLARE end_uline = c4 WITH constant("\ul0 ")
 DECLARE newline = c6 WITH constant(concat("\par",char(10)))
 DECLARE blank_return = c2 WITH constant(concat(char(10),char(13)))
 DECLARE end_para = c5 WITH constant("\pard ")
 DECLARE indent0 = c4 WITH constant("\li0")
 DECLARE indent1 = c6 WITH constant("\li288")
 DECLARE indent2 = c6 WITH constant("\li576")
 DECLARE indent3 = c6 WITH constant("\li864")
 DECLARE item_found = i1 WITH public
 DECLARE num_diag = i2 WITH noconstant(0), public
 DECLARE num_prob = i2 WITH noconstant(0), public
 DECLARE num_allerg = i2 WITH noconstant(0), public
 DECLARE tempval = vc WITH noconstant(" ")
 DECLARE listvals = vc WITH noconstant(" ")
 FREE RECORD allcki
 RECORD allcki(
   1 qual[*]
     2 sourcestring = vc
     2 cki = vc
     2 nomenid = f8
     2 sourcecd = f8
     2 type = c1
 )
 SET log_misc1 = fillstring(500," ")
 SET temp = fillstring(500," ")
 SET item_found = 0
 SET x = 0
 CALL echo(build("Eperson = ",trigger_personid))
 CALL echo(build("$tyPe = ", $TYPE))
 IF (( $TYPE IN ("P", "All")))
  SELECT INTO "nl:"
   FROM problem p,
    nomenclature n
   PLAN (p
    WHERE p.person_id=trigger_personid
     AND p.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
     AND  NOT (p.life_cycle_status_cd IN (canceled, resolved, inactive)))
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id
     AND n.nomenclature_id IN (2195479, 3500110, 2095574, 2394282, 1151342,
    1841591, 2411130, 2316987, 2168302)
     AND n.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm)
   DETAIL
    diagcnt = (diagcnt+ 1), num_prob = diagcnt, stat = alterlist(allcki->qual,diagcnt),
    allcki->qual[diagcnt].cki = n.concept_cki, allcki->qual[diagcnt].sourcestring = n.source_string,
    allcki->qual[diagcnt].sourcecd = n.source_vocabulary_cd,
    allcki->qual[diagcnt].nomenid = n.nomenclature_id, allcki->qual[diagcnt].type = "P"
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET log_message = build2("No problems found for the personid: ",trigger_personid)
  ELSE
   SET item_found = 1
  ENDIF
 ENDIF
 IF (( $TYPE IN ("D", "All")))
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE d.person_id=trigger_personid
     AND d.encntr_id=trigger_encntrid
     AND d.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id
     AND n.nomenclature_id IN (2195479, 3500110, 2095574, 2394282, 1151342,
    1841591, 2411130, 2316987, 2168302)
     AND n.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm)
   DETAIL
    diagcnt = (diagcnt+ 1), num_diag = (diagcnt - num_prob), stat = alterlist(allcki->qual,diagcnt),
    allcki->qual[diagcnt].cki = n.concept_cki, allcki->qual[diagcnt].sourcestring = n.source_string,
    allcki->qual[diagcnt].sourcecd = n.source_vocabulary_cd,
    allcki->qual[diagcnt].nomenid = n.nomenclature_id, allcki->qual[diagcnt].type = "D"
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET log_message = build2("No problems found for the personid: ",trigger_personid)
  ELSE
   SET item_found = 1
  ENDIF
 ENDIF
 IF (( $TYPE IN ("A", "All")))
  SELECT INTO "nl:"
   FROM allergy a,
    nomenclature n
   PLAN (a
    WHERE a.person_id=trigger_personid
     AND a.encntr_id=trigger_encntrid
     AND  NOT (a.reaction_status_cd IN (all_canceled, all_resolved))
     AND a.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN a.beg_effective_dt_tm AND a.end_effective_dt_tm)
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id
     AND n.nomenclature_id IN (932669, 7531731, 7531478, 932666, 7531936,
    7528754, 2287)
     AND n.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm)
   DETAIL
    diagcnt = (diagcnt+ 1), num_allerg = (diagcnt - (num_prob+ num_diag)), stat = alterlist(allcki->
     qual,diagcnt),
    allcki->qual[diagcnt].cki = n.concept_cki, allcki->qual[diagcnt].sourcestring = n.source_string,
    allcki->qual[diagcnt].sourcecd = n.source_vocabulary_cd,
    allcki->qual[diagcnt].nomenid = n.nomenclature_id, allcki->qual[diagcnt].type = "A"
   WITH nocounter
  ;end select
  IF (curqual <= 0
   AND item_found <= 0)
   SET log_message = build2("No allergies,problems or diagnosis found for the personid: ",
    trigger_personid)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echorecord(allcki)
 CALL echo("comparing projects against problem list")
 SET cnt = 0
 SELECT INTO "nl:"
  type_break = allcki->qual[d.seq].type
  FROM nomenclature n,
   (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d)
   JOIN (n
   WHERE n.nomenclature_id IN (2287, 7528754, 7531936, 932666, 25932669,
   7531478, 7531731, 932669, 2168302, 2316987,
   2411130, 1841591, 1151342, 2394282, 2095574,
   3500110, 2195479, 2195479, 77115005)
    AND (allcki->qual[d.seq].nomenid=n.nomenclature_id)
    AND n.active_ind=1)
  ORDER BY type_break
  HEAD REPORT
   null
  HEAD type_break
   cnt = (cnt+ 1)
   IF (cnt=1)
    log_misc1 = "\par "
   ENDIF
   cnt2 = 0
   IF (type_break="D")
    IF (num_diag=1)
     log_misc1 = concat(trim(log_misc1)," Diagnosis: \par "), cnt = (cnt+ 1)
    ELSE
     log_misc1 = concat(trim(log_misc1)," Diagnoses: \par "), cnt = (cnt+ 1)
    ENDIF
   ELSEIF (type_break="P")
    IF (num_prob=1)
     log_misc1 = concat(trim(log_misc1)," Problem: \par "), cnt = (cnt+ 1)
    ELSE
     log_misc1 = concat(trim(log_misc1)," Problems: \par "), cnt = (cnt+ 1)
    ENDIF
   ELSEIF (type_break="A")
    IF (num_allerg=1)
     log_misc1 = concat(trim(log_misc1)," Allergy: \par "), cnt = (cnt+ 1)
    ELSE
     log_misc1 = concat(trim(log_misc1)," Allergies: \par "), cnt = (cnt+ 1)
    ENDIF
   ENDIF
  DETAIL
   temp = concat(trim(temp)," \tab ",trim(n.source_string,3),"\par "), retval = 100,
   CALL echo(build("cnt details =",cnt))
  FOOT  type_break
   log_misc1 = build(trim(log_misc1),trim(temp)), temp = fillstring(500," ")
  WITH nocounter
 ;end select
 IF (retval=100)
  SET log_message = build2("Qualifying problem found:",log_message,"; for PersonId:",trigger_personid
   )
 ELSE
  SET log_message = build2("Qualifying problem not found for PersonId:",trigger_personid,"D",diagcnt,
   "A")
 ENDIF
#exit_script
 FREE RECORD allcki
 CALL echo(log_message)
 CALL echo(build("log_misc1 = ",trim(log_misc1)))
END GO
