CREATE PROGRAM cps_populate_vocab_axis_cd:dba
 SET hyphen = "-"
 SET comma = ","
 SET true = 1
 SET false = 0
 SET dvar = 0
 SET axis_code_set = 15849
 SET source_vocab_set = 400
 SET cdf_meaning = fillstring(12," ")
 SET snm2_mean = "SNM2"
 SET snmi95_mean = "SNMI95"
 SET snm2_cd = 0
 SET snmi95_cd = 0
 RECORD axis_list(
   1 qual_knt = i2
   1 qual[*]
     2 axis_cd = f8
     2 axis = vc
 )
 RECORD upt_list(
   1 qual_knt = i2
   1 qual[*]
     2 id = f8
     2 code = f8
 )
 SET continue = false
 SET cont_id = 0.0
 SET cont_code = 0.0
 SET cont_axis = 0
 SET max_qual = 10000
 SET knt = 0
 SET upt_list->qual_knt = 0
 SET stat = alterlist(upt_list->qual,upt_list->qual_knt)
 RECORD msg_log(
   1 msg_qual = i2
   1 qual[*]
     2 msg = vc
 )
 SET msg_log->msg_qual = 0
 SET err_level = 0
 SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
 SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
 SET msg_log->qual[msg_log->msg_qual].msg = concat("CPS_POPULATE_VOCAB_AXIS_CD  :begin >",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm;;d"))
 SET code_value = 0
 SET code_set = source_vocab_set
 SET cdf_meaning = snm2_mean
 EXECUTE cpm_get_cd_for_cdf
 SET snm2_cd = code_value
 IF (code_value < 1)
  SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
  SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
  SET msg_log->qual[msg_log->msg_qual].msg = concat("   FAILURE : getting SNM2 code_value")
  SET err_level = 2
  GO TO exit_script
 ENDIF
 SET code_value = 0
 SET code_set = source_vocab_set
 SET cdf_meaning = snmi95_mean
 EXECUTE cpm_get_cd_for_cdf
 SET snmi95_cd = code_value
 IF (code_value < 1)
  SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
  SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
  SET msg_log->qual[msg_log->msg_qual].msg = concat("   FAILURE : getting SNMI95 code_value")
  SET err_level = 2
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.code_value, axis = substring(1,(findstring(comma,c.display) - 1),c.display)
  FROM code_value c
  WHERE c.code_set=axis_code_set
   AND c.display > " "
  ORDER BY axis
  HEAD REPORT
   knt = 0, stat = alterlist(axis_list->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(axis_list->qual,(knt+ 9))
   ENDIF
   axis_list->qual[knt].axis_cd = c.code_value, axis_list->qual[knt].axis = axis
  FOOT REPORT
   stat = alterlist(axis_list->qual,knt), axis_list->qual_knt = knt
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
  SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
  SET msg_log->qual[msg_log->msg_qual].msg = concat(
   "   FAILURE : getting vocab_axis_cd's from code_set ",trim(cnvtstring(axis_code_set)))
  SET err_level = 2
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO axis_list->qual_knt)
   SET error_ind = 0
   SET continue = false
   CALL get_update_list(dvar)
   IF (curqual > 0)
    IF (knt=max_qual)
     SET continue = true
     SET cont_id = upt_list->qual[knt].id
     SET cont_code = upt_list->qual[knt].code
    ENDIF
    CALL update_vocab_axis(dvar)
   ELSE
    SET error_ind = 1
   ENDIF
   WHILE (continue=true)
     SET continue = false
     CALL get_update_list(dvar)
     IF (curqual > 0)
      IF (knt=max_qual)
       SET continue = true
       SET cont_id = upt_list->qual[knt].id
      ENDIF
      CALL update_vocab_axis(dvar)
     ENDIF
   ENDWHILE
   IF (error_ind=0)
    SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
    SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
    SET msg_log->qual[msg_log->msg_qual].msg = concat("   SUCCESS : populating vocab_axis ",trim(
      axis_list->qual[i].axis))
   ELSEIF (error_ind=1)
    SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
    SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
    SET msg_log->qual[msg_log->msg_qual].msg = concat(
     "   WARNING : no nomenclature items found for vocab_axis ",trim(axis_list->qual[i].axis))
    SET err_level = 1
   ENDIF
 ENDFOR
#exit_script
 IF (err_level=0)
  SET err_status = "SUCCESS"
 ELSEIF (err_level=1)
  SET err_status = "WARNING"
 ELSE
  SET err_status = "FAILURE"
 ENDIF
 SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
 SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
 SET msg_log->qual[msg_log->msg_qual].msg = concat("CPS_POPULATE_VOCAB_AXIS_CD  :  end >",err_status,
  "   ",format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm;;d"))
 CALL error_handling(dvar)
 GO TO end_program
 SUBROUTINE get_update_list(lvar)
   SELECT INTO "nl:"
    n.nomenclature_id
    FROM nomenclature n
    PLAN (n
     WHERE n.source_vocabulary_cd IN (snmi95_cd, snm2_cd)
      AND n.vocab_axis_cd IN (0, null)
      AND substring(1,(findstring(hyphen,n.source_identifier) - 1),n.source_identifier)=trim(
      axis_list->qual[i].axis))
    ORDER BY n.nomenclature_id
    HEAD REPORT
     knt = 0, stat = alterlist(upt_list->qual,100)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,100)=1
      AND knt != 1)
      stat = alterlist(upt_list->qual,(knt+ 99))
     ENDIF
     upt_list->qual[knt].id = n.nomenclature_id, upt_list->qual[knt].code = axis_list->qual[i].
     axis_cd
    FOOT REPORT
     upt_list->qual_knt = knt, stat = alterlist(upt_list->qual,knt)
    WITH nocounter, maxqual(n,value(max_qual))
   ;end select
 END ;Subroutine
 SUBROUTINE update_vocab_axis(lvar)
   IF ((upt_list->qual_knt <= 100))
    SET end_index = upt_list->qual_knt
   ELSE
    SET end_index = 100
   ENDIF
   SET beg_index = 1
   WHILE ((end_index <= upt_list->qual_knt))
    UPDATE  FROM nomenclature n,
      (dummyt d  WITH seq = value(end_index))
     SET d.seq = beg_index, n.vocab_axis_cd = upt_list->qual[d.seq].code, n.updt_dt_tm = cnvtdatetime
      (curdate,curtime3)
     PLAN (d
      WHERE d.seq >= beg_index
       AND d.seq <= end_index)
      JOIN (n
      WHERE (n.nomenclature_id=upt_list->qual[d.seq].id))
    ;end update
    IF ((curqual=((end_index - beg_index)+ 1)))
     COMMIT
     SET beg_index = (beg_index+ 100)
     IF (((upt_list->qual_knt - end_index) <= 100)
      AND (upt_list->qual_knt != end_index))
      SET end_index = upt_list->qual_knt
     ELSE
      SET end_index = (end_index+ 100)
     ENDIF
    ELSE
     ROLLBACK
     SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
     SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
     SET msg_log->qual[msg_log->msg_qual].msg = concat(
      "   FAILURE : updating nomencalture items for vocab_axis ",trim(axis_list->qual[i].axis))
     SET errmsg = fillstring(132," ")
     SET errcode = error(errmsg,1)
     SET msg_log->msg_qual = (msg_log->msg_qual+ 1)
     SET stat = alterlist(msg_log->qual,msg_log->msg_qual)
     SET msg_log->qual[msg_log->msg_qual].msg = substring(1,120,errmsg)
     GO TO exit_script
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE error_handling(lvar)
   SELECT INTO "CPS_POP_VOCAB_AXIS.LOG"
    the_msg = substring(1,125,msg_log->qual[d.seq].msg)
    FROM (dummyt d  WITH seq = value(msg_log->msg_qual))
    PLAN (d
     WHERE d.seq > 0)
    DETAIL
     row + 1, col 0, the_msg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = value((msg_log->msg_qual+ 1))
   ;end select
 END ;Subroutine
#end_program
END GO
