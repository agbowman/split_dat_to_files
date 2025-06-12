CREATE PROGRAM cps_get_all_nomencat:dba
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
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 category_id = f8
     2 category_name = vc
     2 category_type_cd = f8
     2 category_type_disp = vc
     2 child_category_ind = i2
     2 child_knt = i4
     2 child[*]
       3 child_category_type_cd = f8
       3 child_category_type_disp = vc
       3 child_category_name = vc
       3 nomen_cat_list_id = f8
       3 child_category_id = f8
       3 list_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt1 = size(request->qual,5)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF (((cnt1 > 0) OR ((request->qual_cnt > 0))) )
   PLAN (d
    WHERE d.seq > 0)
    JOIN (nc
    WHERE (nc.category_type_cd=request->qual[d.seq].cat_type_cd)
     AND ((nc.parent_entity_id < 1) OR (nc.parent_entity_id=null))
     AND nc.nomen_category_id > 0)
    JOIN (d1)
    JOIN (nl
    WHERE nl.parent_category_id=nc.nomen_category_id
     AND nl.child_flag=1)
    JOIN (nc1
    WHERE nc1.nomen_category_id=nl.child_category_id)
  ELSE
   PLAN (d)
    JOIN (nc
    WHERE ((nc.parent_entity_id < 1) OR (nc.parent_entity_id=null))
     AND nc.nomen_category_id > 0)
    JOIN (d1)
    JOIN (nl
    WHERE nl.parent_category_id=nc.nomen_category_id
     AND nl.child_flag=1)
    JOIN (nc1
    WHERE nc1.nomen_category_id=nl.child_category_id)
  ENDIF
  INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   nomen_category nc,
   nomen_cat_list nl,
   dummyt d1,
   nomen_category nc1
  ORDER BY nc.nomen_category_id, nl.list_sequence
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD nc.nomen_category_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].category_id = nc.nomen_category_id, reply->qual[knt].category_name = nc
   .category_name, reply->qual[knt].category_type_cd = nc.category_type_cd
   IF (nl.child_category_id > 0)
    reply->qual[knt].child_category_ind = 1
   ELSE
    reply->qual[knt].child_category_ind = 0
   ENDIF
   c_knt = 0, stat = alterlist(reply->qual[knt].child,10)
  DETAIL
   IF (nl.child_category_id > 0)
    c_knt = (c_knt+ 1)
    IF (mod(c_knt,10)=1
     AND c_knt != 1)
     stat = alterlist(reply->qual[knt].child,(c_knt+ 9))
    ENDIF
    reply->qual[knt].child[c_knt].child_category_id = nl.child_category_id, reply->qual[knt].child[
    c_knt].nomen_cat_list_id = nl.nomen_cat_list_id, reply->qual[knt].child[c_knt].
    child_category_name = nc1.category_name,
    reply->qual[knt].child[c_knt].child_category_type_cd = nc1.category_type_cd, reply->qual[knt].
    child[c_knt].list_sequence = nl.list_sequence
   ENDIF
   CALL echo(build("parent : ",reply->qual[knt].category_name," : ",reply->qual[knt].child[c_knt].
    child_category_name," : ",
    reply->qual[knt].child[c_knt].list_sequence))
  FOOT  nc.nomen_category_id
   reply->qual[knt].child_knt = c_knt, stat = alterlist(reply->qual[knt].child,c_knt)
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "NOMEN_CATEGORY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
#exit_script
END GO
