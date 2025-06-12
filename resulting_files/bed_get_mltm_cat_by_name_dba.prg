CREATE PROGRAM bed_get_mltm_cat_by_name:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 category_list1[*]
      2 category_name = vc
      2 category_id = f8
      2 category_type_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE catcount = i4 WITH noconstant(0)
 DECLARE searchstr = vc WITH noconstant("")
 DECLARE icattypeind = i2 WITH noconstant(0)
 IF (validate(request->category_type_ind)=1)
  IF ((request->category_type_ind=1))
   SET icattypeind = request->category_type_ind
  ENDIF
 ENDIF
 IF ((request->category_name > " "))
  SET searchstr = concat(request->category_name,"*")
 ELSE
  SET searchstr = "a*"
 ENDIF
 CALL echo(concat("SEARCH STRING:  ",searchstr))
 IF (icattypeind=0)
  SELECT INTO "nl:"
   FROM mltm_drug_categories mdc
   PLAN (mdc
    WHERE mdc.category_name=patstring(searchstr))
   ORDER BY mdc.category_name
   HEAD REPORT
    catcount = 0
   DETAIL
    catcount = (catcount+ 1)
    IF (mod(catcount,5)=1)
     stat = alterlist(reply->category_list1,(catcount+ 4))
    ENDIF
    reply->category_list1[catcount].category_id = mdc.multum_category_id, reply->category_list1[
    catcount].category_name = mdc.category_name
   FOOT REPORT
    stat = alterlist(reply->category_list1,catcount)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM mltm_alr_category mdc
   PLAN (mdc
    WHERE mdc.category_description=patstring(searchstr))
   ORDER BY mdc.category_description
   HEAD REPORT
    catcount = 0
   DETAIL
    catcount = (catcount+ 1)
    IF (mod(catcount,5)=1)
     stat = alterlist(reply->category_list1,(catcount+ 4))
    ENDIF
    reply->category_list1[catcount].category_id = mdc.alr_category_id, reply->category_list1[catcount
    ].category_name = mdc.category_description
   FOOT REPORT
    stat = alterlist(reply->category_list1,catcount)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("End of script")
 CALL echorecord(reply)
END GO
