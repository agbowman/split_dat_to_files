CREATE PROGRAM bb_act_get_order_cat_syn_info:dba
 RECORD reply(
   1 synonymlist[*]
     2 synonym_id = f8
     2 oe_format_id = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET synonym_cnt = size(request->synonymlist,5)
 IF (synonym_cnt > 0)
  SET stat = alterlist(reply->synonymlist,5)
  SELECT INTO "nl:"
   *
   FROM order_catalog_synonym ocs,
    (dummyt d  WITH seq = value(synonym_cnt))
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=request->synonymlist[d.seq].synonym_id)
     AND ocs.active_ind=1)
   HEAD REPORT
    record_cnt = 0
   DETAIL
    record_cnt += 1
    IF (mod(record_cnt,5)=0
     AND record_cnt != 1)
     stat = alterlist(reply->synonymlist,(record_cnt+ 4))
    ENDIF
    reply->synonymlist[record_cnt].synonym_id = ocs.synonym_id, reply->synonymlist[record_cnt].
    oe_format_id = ocs.oe_format_id, reply->synonymlist[record_cnt].catalog_type_cd = ocs
    .catalog_type_cd,
    reply->synonymlist[record_cnt].catalog_cd = ocs.catalog_cd, reply->synonymlist[record_cnt].
    mnemonic = ocs.mnemonic
   FOOT REPORT
    stat = alterlist(reply->synonymlist,record_cnt)
   WITH nocounter
  ;end select
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_get_order_cat_syn_info.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "select from order_catalog_synonym table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status != "F"))
  IF (size(reply->synonymlist,5) > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
