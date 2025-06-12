CREATE PROGRAM dcp_get_concept_by_cki:dba
 RECORD temprec(
   1 qual[*]
     2 concept_cki = vc
 )
 RECORD reply(
   1 qual[*]
     2 concept_cki = vc
     2 concept_identifier = vc
     2 concept_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE valcnt = i4 WITH protect, noconstant(size(request->cki_list,5))
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE zero_ind = i2 WITH protect, noconstant(0)
 IF (valcnt=0)
  SET failure = 1
  GO TO failure
 ENDIF
 DECLARE maxexpcnt = i4 WITH protect, constant(20)
 DECLARE expblocksize = i4 WITH protect, constant(ceil(((valcnt * 1.0)/ maxexpcnt)))
 DECLARE ex_concept_start = i4 WITH protect, noconstant(1)
 DECLARE ex_concept_idx = i4 WITH protect, noconstant(1)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE expmaxsize = i4 WITH protect, noconstant((expblocksize * maxexpcnt))
 SET stat = alterlist(temprec->qual,expmaxsize)
 FOR (i = 1 TO valcnt)
   SET temprec->qual[i].concept_cki = request->cki_list[i].cki
 ENDFOR
 FOR (i = (valcnt+ 1) TO expmaxsize)
   SET temprec->qual[i].concept_cki = request->cki_list[valcnt].cki
 ENDFOR
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->qual,expmaxsize)
 CALL echo("Muru")
 SELECT INTO "nl:"
  con.concept_cki, con.concept_name, con.concept_identifier
  FROM (dummyt d1  WITH seq = value(expblocksize)),
   cmt_concept con
  PLAN (d1
   WHERE assign(ex_concept_start,evaluate(d1.seq,1,1,(ex_concept_start+ maxexpcnt))))
   JOIN (con
   WHERE expand(ex_concept_idx,ex_concept_start,((ex_concept_start+ maxexpcnt) - 1),con.concept_cki,
    temprec->qual[ex_concept_idx].concept_cki)
    AND con.active_ind=1)
  DETAIL
   idx = (idx+ 1),
   CALL echo(build("idx:  ",idx)), reply->qual[idx].concept_cki = con.concept_cki,
   reply->qual[idx].concept_name = con.concept_name, reply->qual[idx].concept_identifier = con
   .concept_identifier
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,idx)
 IF (idx=0)
  SET zero_ind = 1
 ELSE
  SET failure_ind = 0
 ENDIF
#failure
 IF (failure_ind=1)
  SET reply->status_data.status = "F"
 ELSEIF (zero_ind=1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE SET temprec
END GO
