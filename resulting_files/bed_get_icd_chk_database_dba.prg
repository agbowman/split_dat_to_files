CREATE PROGRAM bed_get_icd_chk_database:dba
 FREE SET reply
 RECORD reply(
   1 load_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET icd_code = uar_get_code_by("MEANING",400,"ICD9")
 SELECT INTO "nl:"
  FROM nomenclature n,
   nomenclature_load_ns ns
  PLAN (n
   WHERE n.source_vocabulary_cd=icd_code
    AND ((n.primary_vterm_ind+ 0)=1)
    AND ((n.active_ind+ 0)=1)
    AND ((n.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((n.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
   JOIN (ns
   WHERE ns.source_identifier=n.source_identifier
    AND ns.primary_vterm_ind IN (0, null)
    AND ns.source_vocabulary_mean="ICD9"
    AND ns.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ns.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ns.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    n2.cmti
    FROM nomenclature n2
    WHERE n2.cmti=ns.cmti))))
  DETAIL
   reply->load_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
