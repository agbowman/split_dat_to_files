CREATE PROGRAM bhs_eks_txfuse_find_prob_dx:dba
 PROMPT
  "Type       " = "",
  "SearchList " = ""
  WITH type, searchlist
 SET log_message = "inside bhs_health_maint_find_prob"
 SET retval = 0
 DECLARE diagcnt = i2 WITH protect, noconstant(0)
 DECLARE canceled = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"CANCELED"))
 DECLARE resolved = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
 DECLARE inactive = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"INACTIVE"))
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
 DECLARE tempval = vc WITH noconstant(" ")
 DECLARE listvals = vc WITH noconstant(" ")
 DECLARE num_diag = i2 WITH noconstant(0), public
 DECLARE num_prob = i2 WITH noconstant(0), public
 DECLARE problems_found = i1 WITH public
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
 SET x = 0
 SET problems_found = 0
 SET listvals = "b.nomen_list_key in ("
 SET opt_param =  $SEARCHLIST
 IF (validate(eksdata->tqual))
  SET opt_param = replace(opt_param,"'","")
  CALL echo(build("opt_param == ",opt_param))
 ELSE
  DECLARE log_misc1 = vc
 ENDIF
 WHILE (x < 100
  AND x != 100)
   SET x = (x+ 1)
   SET tempval = piece(opt_param,"|",x,"1",0)
   IF (tempval="1"
    AND x=1)
    SET listvals = build(listvals,"'",trim(opt_param,3),"'")
   ELSEIF (tempval != "1")
    IF (x > 1)
     SET listvals = build(listvals,",")
    ENDIF
    SET listvals = build(listvals,"'",trim(tempval,3),"'")
   ELSE
    SET x = 100
   ENDIF
 ENDWHILE
 SET listvals = replace(listvals,"''","'")
 SET listvals = build(listvals,")")
 CALL echo(build("opt_param == ",opt_param))
 CALL echo(listvals)
 CALL echo(build("Eperson = ",trigger_personid))
 CALL echo(build("$tyPe = ", $TYPE))
 IF (( $TYPE IN ("P", "All")))
  SELECT INTO "nl:"
   FROM problem p,
    nomenclature n,
    bhs_nomen_list b
   PLAN (p
    WHERE p.person_id=trigger_personid
     AND p.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
     AND  NOT (p.life_cycle_status_cd IN (canceled, resolved, inactive)))
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id
     AND n.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm)
    JOIN (b
    WHERE b.nomenclature_id=n.nomenclature_id
     AND parser(listvals)
     AND b.active_ind=1)
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
   SET problems_found = 1
  ENDIF
 ENDIF
 IF (( $TYPE IN ("D", "All")))
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n,
    bhs_nomen_list b
   PLAN (d
    WHERE d.person_id=trigger_personid
     AND d.encntr_id=trigger_encntrid
     AND d.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id
     AND n.active_ind=1)
    JOIN (b
    WHERE b.nomenclature_id=n.nomenclature_id
     AND parser(listvals)
     AND b.active_ind=1)
   DETAIL
    diagcnt = (diagcnt+ 1), num_diag = (diagcnt - num_prob), stat = alterlist(allcki->qual,diagcnt),
    allcki->qual[diagcnt].cki = n.concept_cki, allcki->qual[diagcnt].sourcestring = n.source_string,
    allcki->qual[diagcnt].sourcecd = n.source_vocabulary_cd,
    allcki->qual[diagcnt].nomenid = n.nomenclature_id, allcki->qual[diagcnt].type = "D"
   WITH nocounter
  ;end select
  IF (curqual <= 0
   AND problems_found=0)
   SET log_message = build2("No problems or Diagnosis found for the personid: ",trigger_personid)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echorecord(allcki)
 CALL echo("comparing projects against problem list")
 SET cnt = 0
 CALL echo(build("list values = ",listvals))
 SELECT INTO "nl:"
  type_break = allcki->qual[d.seq].type
  FROM bhs_nomen_list b,
   nomenclature n,
   (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d)
   JOIN (b
   WHERE (b.nomenclature_id=allcki->qual[d.seq].nomenid)
    AND parser(listvals)
    AND b.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=b.nomenclature_id)
  ORDER BY type_break, b.nomen_list_key
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
   ENDIF
  DETAIL
   temp = concat(trim(temp)," \tab ",trim(n.source_string,3),"\par "), retval = 100,
   CALL echo(build("cnt details =",cnt)),
   CALL echo(n.source_string)
  FOOT  type_break
   log_misc1 = build(trim(log_misc1),trim(temp)), temp = fillstring(500," ")
  WITH nocounter
 ;end select
 IF (retval=100)
  SET log_message = build2("Qualifying problem found = ",num_prob,"Qualifying diagonoses found = ",
   num_diag," for PersonId:",
   trigger_personid)
 ELSE
  SET log_message = build2(opt_param,"Qualifying problem not found for PersonId:",trigger_personid,
   listvals,"D",
   diagcnt,"A")
 ENDIF
#exit_script
 FREE RECORD allcki
 CALL echo(build("log_misc1 = ",trim(log_misc1)))
END GO
