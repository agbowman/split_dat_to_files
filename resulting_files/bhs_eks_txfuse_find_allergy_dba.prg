CREATE PROGRAM bhs_eks_txfuse_find_allergy:dba
 PROMPT
  "Type       " = "",
  "SearchList " = ""
  WITH type, searchlist
 SET log_message = "inside bhs_eks_txfuse_find_allergy"
 SET retval = 0
 DECLARE ml_diagcnt = i4 WITH protect, noconstant(0)
 DECLARE mf_all_canceled = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE mf_all_resolved = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"RESOLVED"))
 DECLARE tempval = vc WITH protect, noconstant(" ")
 DECLARE listvals = vc WITH protect, noconstant(" ")
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
 IF (( $TYPE IN ("A", "All")))
  SELECT INTO "nl:"
   FROM allergy a,
    nomenclature n,
    bhs_nomen_list b
   PLAN (a
    WHERE a.person_id=trigger_personid
     AND a.encntr_id=trigger_encntrid
     AND  NOT (a.reaction_status_cd IN (mf_all_canceled, mf_all_resolved))
     AND a.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN a.beg_effective_dt_tm AND a.end_effective_dt_tm)
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id
     AND n.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm)
    JOIN (b
    WHERE b.nomenclature_id=n.nomenclature_id
     AND parser(listvals)
     AND b.active_ind=1)
   DETAIL
    ml_diagcnt = (ml_diagcnt+ 1), num_allerg = (ml_diagcnt - (num_prob+ num_diag)), stat = alterlist(
     allcki->qual,ml_diagcnt),
    allcki->qual[ml_diagcnt].cki = n.concept_cki, allcki->qual[ml_diagcnt].sourcestring = n
    .source_string, allcki->qual[ml_diagcnt].sourcecd = n.source_vocabulary_cd,
    allcki->qual[ml_diagcnt].nomenid = n.nomenclature_id, allcki->qual[ml_diagcnt].type = "A"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET retval = 100
   SET log_message = build2("Allergies found for the personid: ",trigger_personid)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 FREE RECORD allcki
 CALL echo(build("log_misc1 = ",trim(log_misc1)))
END GO
