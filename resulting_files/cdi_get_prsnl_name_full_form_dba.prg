CREATE PROGRAM cdi_get_prsnl_name_full_form:dba
 RECORD reply(
   1 get_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 doc_nbr_alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE m = i4 WITH noconstant(0)
 DECLARE faliastypecd = f8 WITH noconstant(0.0)
 SET faliastypecd = uar_get_code_by("MEANING",320,"DOCNBR")
 SET m = value(size(request->person_list,5))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  psl.person_id, psl.name_full_formatted, a.alias
  FROM prsnl psl,
   prsnl_alias a
  PLAN (psl
   WHERE expand(i,1,m,psl.person_id,request->person_list[i].person_id)
    AND psl.active_ind=1
    AND psl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND psl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (a
   WHERE ((a.person_id=psl.person_id
    AND ((a.prsnl_alias_type_cd+ 0)=faliastypecd)) OR (a.person_id=0)) )
  ORDER BY psl.person_id, a.prsnl_alias_id
  HEAD REPORT
   count1 = 0
  HEAD psl.person_id
   count1 = (count1+ 1)
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].person_id = psl.person_id, reply->get_list[count1].name_full_formatted =
   psl.name_full_formatted
  DETAIL
   IF (a.person_id != 0
    AND a.active_ind=1
    AND size(reply->get_list[count1].doc_nbr_alias,1) < 1)
    reply->get_list[count1].doc_nbr_alias = a.alias
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
