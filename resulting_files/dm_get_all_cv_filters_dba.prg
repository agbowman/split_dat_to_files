CREATE PROGRAM dm_get_all_cv_filters:dba
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
 FREE RECORD reply
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 code_value_filter_id = f8
     2 code_set = i4
     2 filter_type_cd = f8
     2 filter_type_disp = c40
     2 filter_ind = i2
     2 parent_entity_name1 = vc
     2 flex1_id = f8
     2 parent_entity_name2 = vc
     2 flex2_id = f8
     2 parent_entity_name3 = vc
     2 flex3_id = f8
     2 parent_entity_name4 = vc
     2 flex4_id = f8
     2 parent_entity_name5 = vc
     2 flex5_id = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF ((request->inactive_ind < 1))
   PLAN (cvf
    WHERE cvf.active_ind=1)
  ELSE
   PLAN (cvf
    WHERE 0=0)
  ENDIF
  INTO "nl:"
  FROM code_value_filter cvf
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,1)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].code_value_filter_id = cvf.code_value_filter_id, reply->qual[knt].code_set = cvf
   .code_set, reply->qual[knt].filter_type_cd = cvf.filter_type_cd,
   reply->qual[knt].filter_ind = cvf.filter_ind, reply->qual[knt].active_ind = cvf.active_ind, reply
   ->qual[knt].parent_entity_name1 = cvf.parent_entity_name1,
   reply->qual[knt].flex1_id = cvf.flex1_id, reply->qual[knt].parent_entity_name2 = cvf
   .parent_entity_name2, reply->qual[knt].flex2_id = cvf.flex2_id,
   reply->qual[knt].parent_entity_name3 = cvf.parent_entity_name3, reply->qual[knt].flex3_id = cvf
   .flex3_id, reply->qual[knt].parent_entity_name4 = cvf.parent_entity_name4,
   reply->qual[knt].flex4_id = cvf.flex4_id, reply->qual[knt].parent_entity_name5 = cvf
   .parent_entity_name5, reply->qual[knt].flex5_id = cvf.flex5_id
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE_FILTER"
  GO TO exit_script
 ENDIF
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GENERATE SEQ"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
