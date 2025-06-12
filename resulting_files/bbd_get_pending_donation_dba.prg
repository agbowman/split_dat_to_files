CREATE PROGRAM bbd_get_pending_donation:dba
 RECORD reply(
   1 qual[*]
     2 donor_name = vc
     2 donor_number = c20
     2 donation_procedure = vc
     2 registered_dt_tm = dq8
     2 person_id = f8
     2 contact_id = f8
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->qual,10)
 SET donate_cd = 0.0
 SET pending_cd = 0.0
 SET stat = 0
 SET qual_index = 0
 SET donorid_code = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_cnt = 0
 SET code_set = 4
 SET cdf_meaning = "DONORID"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donorid_code)
 SET code_set = 14220
 SET cdf_meaning = "DONATE"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donate_cd)
 SET code_set = 14224
 SET cdf_meaning = "PENDING"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,pending_cd)
 CALL echo(pending_cd)
 SELECT DISTINCT INTO "nl:"
  dc.person_id, dc.encntr_id, pra.alias,
  dc.contact_dt_tm, dc.encntr_id, pe.name_full_formatted,
  en.bbd_procedure_cd, procedure = uar_get_code_display(en.bbd_procedure_cd)
  FROM bbd_donor_contact dc,
   person pe,
   encounter en,
   person_alias pra
  PLAN (dc
   WHERE dc.active_ind=1
    AND dc.contact_type_cd=donate_cd
    AND dc.contact_status_cd=pending_cd
    AND dc.contact_id != 0)
   JOIN (en
   WHERE en.encntr_id=dc.encntr_id)
   JOIN (pe
   WHERE pe.person_id=en.person_id)
   JOIN (pra
   WHERE pra.person_alias_type_cd=donorid_code
    AND pra.person_id=pe.person_id)
  ORDER BY cnvtdatetime(dc.contact_dt_tm), dc.contact_id, 0
  DETAIL
   qual_index = (qual_index+ 1)
   IF (mod(qual_index,10)=1
    AND qual_index != 1)
    stat = alterlist(reply->qual,(qual_index+ 9))
   ENDIF
   reply->qual[qual_index].donor_name = pe.name_full_formatted, reply->qual[qual_index].donor_number
    = cnvtalias(pra.alias,pra.alias_pool_cd), reply->qual[qual_index].donation_procedure = procedure,
   reply->qual[qual_index].registered_dt_tm = dc.contact_dt_tm, reply->qual[qual_index].person_id =
   dc.person_id, reply->qual[qual_index].contact_id = dc.contact_id,
   reply->qual[qual_index].encntr_id = dc.encntr_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,qual_index)
 SET reply->status_data.status = "S"
END GO
