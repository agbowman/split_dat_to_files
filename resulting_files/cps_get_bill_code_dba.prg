CREATE PROGRAM cps_get_bill_code:dba
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
     2 catalog_cd = f8
     2 bill_knt = i4
     2 bill[*]
       3 sequence = f8
       3 cpt4_code = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET bill_type_cd = 0.0
 SET parent_contrib_cd = 0.0
 SET stat = 0
 SET code_value = 0.0
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,parent_contrib_cd)
 IF (parent_contrib_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for ",trim(cdf_meaning)," on code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,bill_type_cd)
 IF (bill_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for ",trim(cdf_meaning)," on code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, bm.key2_id
  FROM (dummyt d  WITH seq = value(request->qual_knt)),
   bill_item b,
   bill_item_modifier bm,
   code_value cv
  PLAN (d
   WHERE d.seq > 0)
   JOIN (b
   WHERE (b.ext_parent_reference_id=request->qual[d.seq].catalog_cd)
    AND b.ext_parent_contributor_cd=parent_contrib_cd
    AND ((b.ext_child_reference_id+ 0)=0)
    AND ((b.ext_child_contributor_cd+ 0)=0)
    AND b.active_ind=1
    AND b.child_seq IN (0, null))
   JOIN (bm
   WHERE bm.bill_item_id=b.bill_item_id
    AND bm.bill_item_type_cd=bill_type_cd
    AND bm.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=bm.key1_id
    AND ((cv.code_set+ 0)=14002)
    AND cv.cdf_meaning="CPT4")
  ORDER BY d.seq, bm.key2_id
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD d.seq
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].catalog_cd = request->qual[d.seq].catalog_cd, bknt = 0, stat = alterlist(reply->
    qual[knt].bill,10)
  DETAIL
   IF (bm.bill_item_mod_id > 0)
    bknt = (bknt+ 1)
    IF (mod(bknt,10)=1
     AND bknt != 1)
     stat = alterlist(reply->qual[knt].bill,(bknt+ 9))
    ENDIF
    reply->qual[knt].bill[bknt].sequence = bm.key2_id, reply->qual[knt].bill[bknt].cpt4_code = trim(
     bm.key6)
   ENDIF
  FOOT  d.seq
   reply->qual[knt].bill_knt = bknt, stat = alterlist(reply->qual[knt].bill,bknt)
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "BILL_ITEM"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->qual_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "002 04/28/01 SF3151 Use XIE1BILL_ITEM index"
END GO
