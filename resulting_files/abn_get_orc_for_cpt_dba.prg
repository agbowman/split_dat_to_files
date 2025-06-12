CREATE PROGRAM abn_get_orc_for_cpt:dba
 RECORD reply(
   1 list[*]
     2 outreach_synonym = c40
     2 primary_synonym = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET outreach_type_cd = 0.0
 SET primary_type_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(6011,"OUTREACH",code_cnt,outreach_type_cd)
 SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",code_cnt,primary_type_cd)
 IF (((outreach_type_cd=0) OR (primary_type_cd=0)) )
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET count1 = 0
 SELECT INTO "nl:"
  a.catalog_cd, a.cpt_nomen_id, catalog_disp = substring(1,40,uar_get_code_display(a.catalog_cd))
  FROM abn_cross_reference a,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   dummyt d1
  PLAN (a
   WHERE (a.cpt_nomen_id=request->cpt_nomen_id)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=a.catalog_cd
    AND ocs2.mnemonic_type_cd=primary_type_cd
    AND ocs2.active_ind=1)
   JOIN (d1)
   JOIN (ocs
   WHERE ocs.catalog_cd=a.catalog_cd
    AND ocs.mnemonic_type_cd=outreach_type_cd
    AND ocs.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->list,count1), reply->list[count1].primary_synonym =
   ocs2.mnemonic,
   reply->list[count1].outreach_synonym = ocs.mnemonic
  WITH nocounter, orahint("index(ocs XIE1ORDER_CATALOG_SYNONYM)"), orahint(
    "index(ocs2 XIE1ORDER_CATALOG_SYNONYM)"),
   orahint("index(a XIE1ABN_CROSS_REFERENCE)"), dontcare = ocs, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
