CREATE PROGRAM bed_get_oc_all_types:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 catalog_type_cd = f8
     2 catalog_type_display = c40
     2 catalog_type_cdf_meaning = c12
     2 catalog_type_desc = c60
     2 alist[*]
       3 activity_type_cd = f8
       3 activity_type_display = c40
       3 activity_type_cdf_meaning = c12
       3 activity_type_desc = c60
       3 slist[*]
         4 activity_subtype_cd = f8
         4 activity_subtype_display = c40
         4 activity_subtype_cdf_meaning = c12
         4 activity_subtype_desc = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET acnt = 0
 SET scnt = 0
 DECLARE oc_parse = vc
 IF ((request->load_inactives_ind=1))
  SET oc_parse = "(oc.active_ind = 1 or oc.active_ind = 0)"
 ELSE
  SET oc_parse = "oc.active_ind = 1"
 ENDIF
 DECLARE orderable_type_flag_cnt = i4
 SET orderable_type_flag_cnt = 0
 IF (validate(request->orderable_type_flags))
  SET orderable_type_flag_cnt = size(request->orderable_type_flags,5)
 ENDIF
 IF (orderable_type_flag_cnt > 0)
  SET oc_parse = concat(oc_parse," and oc.orderable_type_flag in (")
  FOR (i = 1 TO orderable_type_flag_cnt)
   IF (i > 1)
    SET oc_parse = concat(oc_parse,", ")
   ENDIF
   SET oc_parse = build(oc_parse,request->orderable_type_flags[i].flag)
  ENDFOR
  SET oc_parse = concat(oc_parse,")")
 ELSE
  SET oc_parse = concat(oc_parse," and oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2")
 ENDIF
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (cv1
   WHERE cv1.code_value=oc.catalog_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_type_cd
    AND cv2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(oc.activity_subtype_cd)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY cv1.display, oc.catalog_type_cd, cv2.display,
   oc.activity_type_cd, cv3.display, oc.activity_subtype_cd
  HEAD oc.catalog_type_cd
   ccnt = (ccnt+ 1), stat = alterlist(reply->clist,ccnt), reply->clist[ccnt].catalog_type_cd = cv1
   .code_value,
   reply->clist[ccnt].catalog_type_display = cv1.display, reply->clist[ccnt].catalog_type_cdf_meaning
    = cv1.cdf_meaning, reply->clist[ccnt].catalog_type_desc = cv1.description,
   acnt = 0, scnt = 0
  HEAD oc.activity_type_cd
   acnt = (acnt+ 1), stat = alterlist(reply->clist[ccnt].alist,acnt), reply->clist[ccnt].alist[acnt].
   activity_type_cd = cv2.code_value,
   reply->clist[ccnt].alist[acnt].activity_type_display = cv2.display, reply->clist[ccnt].alist[acnt]
   .activity_type_cdf_meaning = cv2.cdf_meaning, reply->clist[ccnt].alist[acnt].activity_type_desc =
   cv2.description,
   scnt = 0
  HEAD oc.activity_subtype_cd
   IF (oc.activity_subtype_cd > 0)
    scnt = (scnt+ 1), stat = alterlist(reply->clist[ccnt].alist[acnt].slist,scnt), reply->clist[ccnt]
    .alist[acnt].slist[scnt].activity_subtype_cd = cv3.code_value,
    reply->clist[ccnt].alist[acnt].slist[scnt].activity_subtype_display = cv3.display, reply->clist[
    ccnt].alist[acnt].slist[scnt].activity_subtype_cdf_meaning = cv3.cdf_meaning, reply->clist[ccnt].
    alist[acnt].slist[scnt].activity_subtype_desc = cv3.description
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
