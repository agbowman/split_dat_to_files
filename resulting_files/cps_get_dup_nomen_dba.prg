CREATE PROGRAM cps_get_dup_nomen:dba
 FREE SET reply
 RECORD reply(
   1 duplicate = i2
   1 pure_dup = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET nomen_list
 RECORD nomen_list(
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
   1 srcstr = vc
 )
 SET true = 1
 SET false = 0
 SET a_dup = false
 SET a_pure_dup = false
 SET reply->status_data.status = "F"
 CALL chk_nomen_dup(request->source_vocab_cd,request->source_identifier,request->source_string,
  request->principle_type_cd)
 IF (((a_dup=true) OR (a_pure_dup=true)) )
  SET reply->duplicate = true
  IF (a_pure_dup=true)
   SET reply->pure_dup = true
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 GO TO end_program
 SUBROUTINE chk_nomen_dup(tsrc_vocab_cd,tsrc_ident,tsrc_string,tprin_type_cd)
   SET cap_src_string = cnvtupper(tsrc_string)
   SET a_pure_dup = false
   SET a_dup = false
   SELECT
    IF (tsrc_ident > " ")
     PLAN (n
      WHERE n.source_vocabulary_cd=tsrc_vocab_cd
       AND n.source_identifier=tsrc_ident
       AND ((n.source_string=tsrc_string) OR (cnvtupper(n.source_string)=cap_src_string))
       AND n.principle_type_cd=tprin_type_cd)
    ELSE
     PLAN (n
      WHERE n.source_vocabulary_cd=tsrc_vocab_cd
       AND n.source_identifier <= " "
       AND ((n.source_string=tsrc_string) OR (cnvtupper(n.source_string)=cap_src_string))
       AND n.principle_type_cd=tprin_type_cd)
    ENDIF
    INTO "nl:"
    n.nomenclature_id, n.beg_effective_dt_tm
    FROM nomenclature n
    ORDER BY cnvtdatetime(n.beg_effective_dt_tm) DESC
    HEAD REPORT
     knt = 0, stat = alterlist(nomen_list->qual,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(nomen_list->qual,(knt+ 9))
     ENDIF
     nomen_list->qual[knt].id = n.nomenclature_id, a_dup = true, nomen_list->srcstr = n.source_string
     IF (n.source_string=tsrc_string)
      a_pure_dup = true
     ENDIF
    FOOT REPORT
     nomen_list->qual_knt = knt, stat = alterlist(nomen_list->qual,knt)
    WITH nocounter, orahint("index(n XAK6NOMENCLATURE) ")
   ;end select
 END ;Subroutine
#end_program
END GO
