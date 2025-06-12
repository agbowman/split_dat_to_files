CREATE PROGRAM dcp_get_priv_forms_gen:dba
 RECORD reply(
   1 qual[*]
     2 gendouble = f8
     2 genstring = vc
     2 genind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.dcp_forms_ref_id > 0)
  ORDER BY dfr.description
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->forms_list,5))
    stat = alterlist(reply->forms_list,(count1+ 20))
   ENDIF
   reply->forms_list[count1].gendouble = dfr.dcp_forms_ref_id, reply->forms_list[count1].genstring =
   dfr.description, reply->forms_list[count1].genind = dfr.active_ind
  FOOT REPORT
   reply->forms_cnt = count1, stat = alterlist(reply->forms_list,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
