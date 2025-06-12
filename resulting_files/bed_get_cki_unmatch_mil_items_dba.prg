CREATE PROGRAM bed_get_cki_unmatch_mil_items:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 mil_disp = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 mil_name = vc
     2 match_ind = i2
     2 cki = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET fcnt = size(request->flist,5)
 DECLARE oc_filter_string = vc
 SET catalog_type_cd = 0.0
 SET activity_type_cd = 0.0
 IF (fcnt > 0)
  FOR (x = 1 TO fcnt)
    IF (x=1)
     IF ((request->flist[x].filter_type="CATALOG_TYPE"))
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=6000
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        catalog_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET oc_filter_string = concat("oc.catalog_type_cd = ",cnvtstring(catalog_type_cd))
     ELSEIF ((request->flist[x].filter_type="ACTIVITY_TYPE"))
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=106
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        activity_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET oc_filter_string = concat("oc.activity_type_cd = ",cnvtstring(activity_type_cd))
     ENDIF
    ELSE
     IF ((request->flist[x].filter_type="CATALOG_TYPE"))
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=6000
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        catalog_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET oc_filter_string = concat(trim(oc_filter_string)," and oc.catalog_type_cd = ",cnvtstring(
        catalog_type_cd))
     ELSEIF ((request->flist[x].filter_type="ACTIVITY_TYPE"))
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=106
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        activity_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET oc_filter_string = concat(trim(oc_filter_string)," and oc.activity_type_cd = ",cnvtstring(
        activity_type_cd))
     ENDIF
    ENDIF
  ENDFOR
 ELSE
  SET oc_filter_string = "oc.catalog_cd > 0"
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE parser(oc_filter_string)
    AND oc.concept_cki > " ")
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].mil_name = oc.primary_mnemonic,
   temp->qual[cnt].cki = oc.concept_cki
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_auto_order_catalog oc
  PLAN (oc
   WHERE parser(oc_filter_string)
    AND oc.concept_cki > " ")
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].mil_name = oc.primary_mnemonic,
   temp->qual[cnt].cki = oc.concept_cki
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   br_cki_match b
  PLAN (d)
   JOIN (b
   WHERE (b.client_id=request->client_id)
    AND (b.data_type_id=request->data_type_id)
    AND (b.concept_cki=temp->qual[d.seq].cki))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].match_ind = 1
  WITH nocounter
 ;end select
 SET mcnt = 0
 FOR (x = 1 TO size(temp->qual,5))
   IF ((temp->qual[x].match_ind=0))
    SET mcnt = (mcnt+ 1)
    SET stat = alterlist(reply->qual,mcnt)
    SET reply->qual[mcnt].mil_disp = temp->qual[x].mil_name
    SET reply->qual[mcnt].concept_cki = temp->qual[x].cki
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
