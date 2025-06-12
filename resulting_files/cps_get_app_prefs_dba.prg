CREATE PROGRAM cps_get_app_prefs:dba
 FREE RECORD reply
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 app_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 pref_qual = i4
     2 app_prefs_id = f8
     2 pref[*]
       3 pref_id = f8
       3 pref_name = c32
       3 pref_value = vc
       3 sequence = i4
       3 merge_id = f8
       3 merge_name = vc
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE num = i4 WITH noconstant(0)
 SET num1 = 0
 SET ntotal2 = size(request->qual,5)
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(request->qual,ntotal)
 SET nstart = 1
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->qual[idx].prsnl_id = request->qual[ntotal2].prsnl_id
   SET request->qual[idx].position_cd = request->qual[ntotal2].position_cd
   SET request->qual[idx].app_number = request->qual[ntotal2].app_number
 ENDFOR
 SELECT INTO "nl:"
  index = locateval(num1,1,ntotal2,ap.prsnl_id,request->qual[num1].prsnl_id,
   ap.position_cd,request->qual[num1].position_cd,ap.application_number,request->qual[num1].
   app_number)
  FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   app_prefs ap,
   name_value_prefs nvp
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (ap
   WHERE expand(num,nstart,(nstart+ (nsize - 1)),ap.prsnl_id,request->qual[num].prsnl_id,
    ap.position_cd,request->qual[num].position_cd,ap.application_number,request->qual[num].app_number
    )
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.active_ind=1)
  ORDER BY index
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD index
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].app_number = ap.application_number, reply->qual[knt].position_cd = ap.position_cd,
   reply->qual[knt].prsnl_id = ap.prsnl_id,
   reply->qual[knt].app_prefs_id = ap.app_prefs_id, pknt = 0, stat = alterlist(reply->qual[knt].pref,
    10)
  DETAIL
   pknt = (pknt+ 1)
   IF (mod(pknt,10)=1
    AND pknt != 1)
    stat = alterlist(reply->qual[knt].pref,(pknt+ 9))
   ENDIF
   reply->qual[knt].pref[pknt].pref_id = nvp.name_value_prefs_id, reply->qual[knt].pref[pknt].
   pref_name = nvp.pvc_name, reply->qual[knt].pref[pknt].pref_value = nvp.pvc_value,
   reply->qual[knt].pref[pknt].sequence = nvp.sequence, reply->qual[knt].pref[pknt].merge_id = nvp
   .merge_id, reply->qual[knt].pref[pknt].merge_name = nvp.merge_name,
   reply->qual[knt].pref[pknt].active_ind = nvp.active_ind
  FOOT  index
   reply->qual[knt].pref_qual = pknt, stat = alterlist(reply->qual[knt].pref,pknt)
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET script_ver = "001 05/03/05 SF3151"
END GO
