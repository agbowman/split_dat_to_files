CREATE PROGRAM cpmnotify_dcp_demog:dba
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rec_qual = 0
 SET x = 0
 SET y = 0
 SET p_cnt = size(request->entity_list,5)
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 SET sticky_cd = 0.0
 SET sticky_mean = "POWERCHART"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 14122
 SET cdf_meaning = sticky_mean
 EXECUTE cpm_get_cd_for_cdf
 SET sticky_cd = code_value
 SELECT INTO "nl:"
  e.encntr_id, ea.encntr_alias_id, p.person_id,
  sn.sticky_note_id, pa.person_alias_id, ppr.person_prsnl_reltn_id,
  check = decode(p.seq,"p",ea.seq,"e","z"), check2 = decode(sn.seq,"s",pa.seq,"a",ppr.seq,
   "r","z")
  FROM person p,
   encounter e,
   encntr_alias ea,
   sticky_note sn,
   person_alias pa,
   person_prsnl_reltn ppr,
   dummyt d2,
   dummyt d1,
   (dummyt d3  WITH seq = value(p_cnt))
  PLAN (d3)
   JOIN (e
   WHERE (e.encntr_id=request->entity_list[d3.seq].entity_id))
   JOIN (d1)
   JOIN (((p
   WHERE p.person_id=e.person_id)
   JOIN (d2)
   JOIN (((sn
   WHERE sn.parent_entity_id=p.person_id
    AND sn.parent_entity_name="PERSON")
   ) ORJOIN ((((pa
   WHERE pa.person_id=p.person_id)
   ) ORJOIN ((ppr
   WHERE ppr.person_id=p.person_id)
   )) )) ) ORJOIN ((ea
   WHERE ea.encntr_id=e.encntr_id)
   ))
  HEAD REPORT
   x = 0
  HEAD e.encntr_id
   rec_qual = 0
   IF (e.updt_dt_tm > cnvtdatetime(request->last_run_dt_tm))
    rec_qual = 1
   ENDIF
  HEAD p.person_id
   IF (check="p")
    IF (p.updt_dt_tm > cnvtdatetime(request->last_run_dt_tm))
     rec_qual = 1
    ENDIF
   ENDIF
  HEAD ea.encntr_alias_id
   IF (check="e")
    IF (ea.updt_dt_tm > cnvtdatetime(request->last_run_dt_tm))
     rec_qual = 1
    ENDIF
   ENDIF
  DETAIL
   IF (rec_qual=0)
    CASE (check2)
     OF "s":
      IF (sn.updt_dt_tm > cnvtdatetime(request->last_run_dt_tm)
       AND sn.sticky_note_type_cd=sticky_cd)
       rec_qual = 1
      ENDIF
     OF "a":
      IF (pa.updt_dt_tm > cnvtdatetime(request->last_run_dt_tm))
       rec_qual = 1
      ENDIF
     OF "r":
      IF (ppr.updt_dt_tm > cnvtdatetime(request->last_run_dt_tm))
       rec_qual = 1
      ENDIF
    ENDCASE
   ENDIF
  FOOT  e.encntr_id
   IF (rec_qual=1)
    x = (x+ 1), stat = alterlist(reply->entity_list,x), reply->entity_list[x].entity_id = e.encntr_id
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 IF (rec_qual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
