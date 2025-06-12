CREATE PROGRAM cps_get_prsnl_notify_ppr:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 prsnl_qual = i4
   1 prsnl[*]
     2 prsnl_notify_id = f8
     2 ppr_qual = i4
     2 ppr[*]
       3 ppr_cd = f8
       3 ppr_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->prsnl_qual < 1))
  GO TO get_all
 ELSE
  GO TO get_given
 ENDIF
#get_all
 SELECT INTO "nl:"
  pnp.prsnl_notify_id
  FROM prsnl_notify_ppr pnp
  PLAN (pnp
   WHERE pnp.prsnl_notify_id > 0)
  ORDER BY pnp.prsnl_notify_id
  HEAD REPORT
   knt = 0, stat = alterlist(reply->prsnl,10)
  HEAD pnp.prsnl_notify_id
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->prsnl,(knt+ 9))
   ENDIF
   reply->prsnl[knt].prsnl_notify_id = pnp.prsnl_notify_id, dknt = 0, stat = alterlist(reply->prsnl[
    knt].ppr,10)
  DETAIL
   dknt += 1
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(reply->prsnl[knt].ppr,(dknt+ 9))
   ENDIF
   reply->prsnl[knt].ppr[dknt].ppr_cd = pnp.ppr_cd, reply->prsnl[knt].ppr[dknt].ppr_flag = pnp
   .ppr_flag
  FOOT  pnp.prsnl_notify_id
   reply->prsnl[knt].ppr_qual = dknt, stat = alterlist(reply->prsnl[knt].ppr,dknt)
  FOOT REPORT
   reply->prsnl_qual = knt, stat = alterlist(reply->prsnl,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL_NOTIFY_PPR"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#get_given
 SELECT INTO "nl:"
  pnp.prsnl_notify_id
  FROM prsnl_notify_ppr pnp,
   (dummyt d  WITH seq = value(request->prsnl_qual))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (pnp
   WHERE (pnp.prsnl_notify_id=request->prsnl[d.seq].prsnl_notify_id))
  ORDER BY pnp.prsnl_notify_id
  HEAD REPORT
   knt = 0, stat = alterlist(reply->prsnl,10)
  HEAD pnp.prsnl_notify_id
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->prsnl,(knt+ 9))
   ENDIF
   reply->prsnl[knt].prsnl_notify_id = pnp.prsnl_notify_id, dknt = 0, stat = alterlist(reply->prsnl[
    knt].ppr,10)
  DETAIL
   dknt += 1
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(reply->prsnl[knt].ppr,(dknt+ 9))
   ENDIF
   reply->prsnl[knt].ppr[dknt].ppr_cd = pnp.ppr_cd, reply->prsnl[knt].ppr[dknt].ppr_flag = pnp
   .ppr_flag
  FOOT  pnp.prsnl_notify_id
   reply->prsnl[knt].ppr_qual = dknt, stat = alterlist(reply->prsnl[knt].ppr,dknt)
  FOOT REPORT
   reply->prsnl_qual = knt, stat = alterlist(reply->prsnl,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL_NOTIFY_PPR"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
END GO
