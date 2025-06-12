CREATE PROGRAM cps_get_all_ref_text:dba
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
   1 qual_knt = i4
   1 qual[*]
     2 text_type_cd = f8
     2 text_type_disp = c40
     2 text_type_mean = c12
     2 refr_text_id = f8
     2 text_type_flag = i2
     2 text_locator = vc
     2 long_text_id = f8
     2 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dvar = 0
 SELECT INTO "nl:"
  rt.text_type_cd, rt.updt_dt_tm
  FROM ref_text_reltn rtr,
   ref_text rt,
   long_text lt
  PLAN (rtr
   WHERE (rtr.parent_entity_name=request->parent_entity_name)
    AND (rtr.parent_entity_id=request->parent_entity_id))
   JOIN (rt
   WHERE rt.refr_text_id=rtr.refr_text_id
    AND rt.text_entity_name="LONG_TEXT"
    AND rt.active_ind=1)
   JOIN (lt
   WHERE lt.long_text_id=rt.text_entity_id)
  ORDER BY rt.text_type_cd, rt.updt_dt_tm DESC
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10), text_type_cd = 0.0
  HEAD rt.text_type_cd
   IF (text_type_cd != rt.text_type_cd)
    text_type_cd = rt.text_type_cd, knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].text_type_cd = rt.text_type_cd, reply->qual[knt].refr_text_id = rt.refr_text_id,
    reply->qual[knt].text_type_flag = rt.text_type_flag,
    reply->qual[knt].text_locator = rt.text_locator, reply->qual[knt].long_text_id = lt.long_text_id,
    reply->qual[knt].text = lt.long_text
   ENDIF
  DETAIL
   dvar = dvar
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REF_TEXT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ELSEIF (curqual < 1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
