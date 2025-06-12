CREATE PROGRAM bed_get_icd_codes:dba
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 nomenclature_id = f8
     2 code = vc
     2 term = vc
     2 source_vocab
       3 code_value = f8
       3 meaning = vc
       3 display = vc
     2 principle_type
       3 code_value = f8
       3 meaning = vc
       3 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 billable_ind = i2
   1 more_data_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE nparse = vc
 DECLARE iparse = vc
 DECLARE oparse = vc
 SET icd_code = uar_get_code_by("MEANING",400,"ICD9")
 IF ((request->search_type_flag="C"))
  SET nparse = "*"
 ENDIF
 IF ((request->code > " "))
  SET nparse = concat(nparse,trim(cnvtupper(request->code)),"*")
  SET nparse = concat("cnvtupper(n.source_identifier) = '",nparse,"' ")
 ELSEIF ((request->term > " "))
  SET nparse = concat(nparse,trim(cnvtupper(request->term)),"*")
  SET nparse = concat("cnvtupper(n.source_string) = '",nparse,"' ")
 ENDIF
 SET nparse = concat(nparse," and n.source_vocabulary_cd = icd_code ",
  " and n.primary_vterm_ind+0 = 1 and n.active_ind = 1 ")
 IF ((request->obsolete_ind=0))
  SET nparse = concat(nparse," and n.end_effective_dt_tm+0 > cnvtdatetime(curdate,curtime3) ")
 ELSE
  SET nparse = concat(nparse," and not exists(select n2.nomenclature_id from nomenclature n2 ",
   " where n2.source_vocabulary_cd = icd_code and n2.primary_vterm_ind+0 = 1 and n2.active_ind = 1 ",
   " and n2.source_identifier = n.source_identifier and n2.end_effective_dt_tm > ",
   " n.end_effective_dt_tm and n2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))")
 ENDIF
 IF ((request->beg_effective_dt_tm > 0))
  SET nparse = concat(nparse,
   " and n.beg_effective_dt_tm+0 >= cnvtdatetime(request->beg_effective_dt_tm) ")
 ELSE
  SET nparse = concat(nparse," and n.beg_effective_dt_tm+0 <= cnvtdatetime(curdate,curtime3) ")
 ENDIF
 SET iparse = concat("i.source_identifier = n.source_identifier and i.active_ind = 1 ")
 IF ((request->nonbillable_ind=1))
  SET iparse = concat(iparse," and i.valid_flag_desc = 'N' ")
 ENDIF
 SELECT INTO "nl:"
  FROM nomenclature n,
   icd9cm_extension i,
   code_value sv,
   code_value pt
  PLAN (n
   WHERE parser(nparse))
   JOIN (i
   WHERE parser(iparse))
   JOIN (sv
   WHERE sv.code_value=n.source_vocabulary_cd
    AND sv.active_ind=1)
   JOIN (pt
   WHERE pt.code_value=n.principle_type_cd
    AND pt.active_ind=1)
  ORDER BY n.source_identifier, n.end_effective_dt_tm, i.source_identifier,
   i.end_effective_dt_tm
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->codes,100)
  HEAD n.source_identifier
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->codes,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->codes[tcnt].code = n.source_identifier, reply->codes[tcnt].nomenclature_id = n
   .nomenclature_id, reply->codes[tcnt].term = n.source_string,
   reply->codes[tcnt].principle_type.code_value = pt.code_value, reply->codes[tcnt].principle_type.
   meaning = pt.cdf_meaning, reply->codes[tcnt].principle_type.display = pt.display,
   reply->codes[tcnt].source_vocab.code_value = sv.code_value, reply->codes[tcnt].source_vocab.
   meaning = sv.cdf_meaning, reply->codes[tcnt].source_vocab.display = sv.display
  DETAIL
   reply->codes[tcnt].begin_effective_dt_tm = n.beg_effective_dt_tm, reply->codes[tcnt].
   end_effective_dt_tm = n.end_effective_dt_tm
   IF (i.valid_flag_desc="Y")
    reply->codes[tcnt].billable_ind = 1
   ENDIF
  FOOT REPORT
   IF ((request->max_reply < tcnt))
    stat = alterlist(reply->codes,request->max_reply), reply->more_data_ind = 1
   ELSE
    stat = alterlist(reply->codes,tcnt)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
