CREATE PROGRAM catsel_get_keys_call:dba
 DECLARE last_mod = c3 WITH noconstant("000")
 SET reply->status_data.status = "F"
 SET s_cnt = 0
 SET show_inactive_ind = request->show_inactive_ind
 SELECT INTO "NL:"
  ocs.mnemonic
  FROM order_catalog_synonym ocs,
   surgical_procedure sp,
   surg_proc_detail spd
  PLAN (ocs
   WHERE (ocs.mnemonic_key_cap >= request->seed)
    AND ((ocs.active_ind=1) OR (show_inactive_ind > 0))
    AND  $1)
   JOIN (sp
   WHERE sp.catalog_cd=outerjoin(ocs.catalog_cd))
   JOIN (spd
   WHERE spd.catalog_cd=outerjoin(sp.catalog_cd)
    AND spd.surg_area_cd=outerjoin(request->surg_area_cd))
  ORDER BY ocs.mnemonic_key_cap
  HEAD REPORT
   s_cnt = 0
  DETAIL
   IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
    AND spd.catalog_cd > 0) OR (spd.surg_area_cd=0)) )) )
    s_cnt = (s_cnt+ 1)
    IF (mod(s_cnt,10)=1
     AND s_cnt != 1)
     stat = alter(reply->qual,(s_cnt+ 9))
    ENDIF
    reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
    reply->qual[s_cnt].code = ocs.synonym_id
   ENDIF
  WITH maxqual(ocs,100), nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG_SYNONYM"
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->qual_cnt = s_cnt
 SET last_mod = "002"
END GO
