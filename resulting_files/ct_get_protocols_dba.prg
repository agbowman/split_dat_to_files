CREATE PROGRAM ct_get_protocols:dba
 RECORD reply(
   1 cnt = i4
   1 qual[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE concept_cd = f8 WITH protect, noconstant(0.00)
 DECLARE approved_cd = f8 WITH protect, noconstant(0.00)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.00)
 DECLARE closed_cd = f8 WITH protect, noconstant(0.00)
 DECLARE indevelopment_cd = f8 WITH protect, noconstant(0.00)
 DECLARE tempsuspend_cd = f8 WITH protect, noconstant(0.00)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(17274,"CONCEPT",1,concept_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"APPROVED",1,approved_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"INDVLPMENT",1,indevelopment_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"CLOSED",1,closed_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"TEMPSUSPEND",1,tempsuspend_cd)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM prot_master pm
  PLAN (pm
   WHERE pm.prot_master_id != 0.00
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pm.prot_status_cd IN (concept_cd, approved_cd, activated_cd, indevelopment_cd, closed_cd,
   tempsuspend_cd)
    AND pm.prescreen_type_flag=1)
  ORDER BY cnvtupper(pm.primary_mnemonic)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].prot_master_id = pm.prot_master_id, reply->qual[cnt].primary_mnemonic = pm
   .primary_mnemonic
  WITH nocounter
 ;end select
 SET reply->cnt = cnt
 SET stat = alterlist(reply->qual,cnt)
 SET reply->status_data.status = "S"
 SET last_mod = "000"
 SET mod_date = "MAR 29, 2018"
END GO
