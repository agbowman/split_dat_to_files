CREATE PROGRAM bed_get_erx_inact_alias:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl_reltns[*]
      2 prsnl_reltn_id = f8
      2 alias[*]
        3 alias_id = f8
        3 alias_type
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 alias = vc
        3 alias_pool
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 alias_reltn_seq = i4
        3 active_ind = i2
        3 effective_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE reqcnt = i4 WITH protect, constant(size(request->prsnl_reltns,5))
 SET cs48active = uar_get_code_by("MEANING",48,"ACTIVE")
 IF (reqcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE prsnlcnt = i4 WITH protect, noconstant(0)
 DECLARE aliascnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = reqcnt),
   prsnl_reltn_child prc,
   prsnl_alias pa,
   code_value c,
   code_value c2
  PLAN (d)
   JOIN (prc
   WHERE (prc.prsnl_reltn_id=request->prsnl_reltns[d.seq].prsnl_reltn_id)
    AND prc.parent_entity_name="PRSNL_ALIAS"
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pa
   WHERE pa.prsnl_alias_id=prc.parent_entity_id
    AND ((pa.active_ind=0) OR (((pa.active_status_cd != cs48active) OR (pa.end_effective_dt_tm <
   cnvtdatetime(curdate,curtime3))) )) )
   JOIN (c
   WHERE c.code_value=pa.prsnl_alias_type_cd
    AND c.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=outerjoin(pa.alias_pool_cd)
    AND c2.active_ind=outerjoin(1))
  ORDER BY d.seq, prc.prsnl_reltn_child_id, pa.prsnl_alias_id
  HEAD d.seq
   prsnlcnt = (prsnlcnt+ 1), aliascnt = 0, stat = alterlist(reply->prsnl_reltns,prsnlcnt),
   reply->prsnl_reltns[prsnlcnt].prsnl_reltn_id = request->prsnl_reltns[d.seq].prsnl_reltn_id
  HEAD pa.prsnl_alias_id
   aliascnt = (aliascnt+ 1), stat = alterlist(reply->prsnl_reltns[prsnlcnt].alias,aliascnt), reply->
   prsnl_reltns[prsnlcnt].alias[aliascnt].alias_id = pa.prsnl_alias_id,
   reply->prsnl_reltns[prsnlcnt].alias[aliascnt].alias = pa.alias, reply->prsnl_reltns[prsnlcnt].
   alias[aliascnt].active_ind =
   IF (((pa.active_ind=0) OR (pa.active_status_cd != cs48active)) ) 0
   ELSE 1
   ENDIF
   , reply->prsnl_reltns[prsnlcnt].alias[aliascnt].effective_ind =
   IF (pa.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)) 0
   ELSE 1
   ENDIF
   IF (c2.code_value > 0)
    reply->prsnl_reltns[prsnlcnt].alias[aliascnt].alias_pool.code_value = pa.alias_pool_cd, reply->
    prsnl_reltns[prsnlcnt].alias[aliascnt].alias_pool.display = c2.display, reply->prsnl_reltns[
    prsnlcnt].alias[aliascnt].alias_pool.meaning = c2.cdf_meaning
   ENDIF
   reply->prsnl_reltns[prsnlcnt].alias[aliascnt].alias_type.code_value = pa.prsnl_alias_type_cd,
   reply->prsnl_reltns[prsnlcnt].alias[aliascnt].alias_type.display = c.display, reply->prsnl_reltns[
   prsnlcnt].alias[aliascnt].alias_type.meaning = c.cdf_meaning
  WITH nocounter
 ;end select
 CALL bederrorcheck("GetAliasError")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
