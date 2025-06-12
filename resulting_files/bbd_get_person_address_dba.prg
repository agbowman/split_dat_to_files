CREATE PROGRAM bbd_get_person_address:dba
 RECORD reply(
   1 qual[*]
     2 address_id = f8
     2 address_type_cd = f8
     2 address_type_cd_mean = vc
     2 updt_cnt = i4
     2 address_format_cd = f8
     2 address_format_cd_mean = vc
     2 contact_name = vc
     2 residence_type_cd = f8
     2 residence_type_cd_mean = vc
     2 street_address_one = vc
     2 street_address_two = vc
     2 street_address_three = vc
     2 street_address_four = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 zipcode = vc
     2 postal_barcode_info = vc
     2 county = vc
     2 county_cd = f8
     2 country = vc
     2 country_cd = f8
     2 residence_cd = f8
     2 mail_stop = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  a.*, c.*
  FROM address a,
   code_value c
  PLAN (a
   WHERE (a.parent_entity_id=request->person_id)
    AND a.parent_entity_name="PERSON"
    AND cnvtdatetime(curdate,curtime3) >= a.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= a.end_effective_dt_tm
    AND a.active_ind=1)
   JOIN (c
   WHERE c.code_set=212
    AND c.code_value=a.address_type_cd
    AND cnvtdatetime(curdate,curtime3) >= c.begin_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= c.end_effective_dt_tm
    AND c.active_ind=1
    AND ((c.cdf_meaning="BILLING") OR (((c.cdf_meaning="TEMPORARY") OR (((c.cdf_meaning="BUSINESS")
    OR (((c.cdf_meaning="HOME") OR (c.cdf_meaning="MAILING")) )) )) )) )
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].address_id = a
   .address_id,
   reply->qual[count].address_type_cd = a.address_type_cd, reply->qual[count].address_type_cd_mean =
   c.cdf_meaning, reply->qual[count].updt_cnt = a.updt_cnt,
   reply->qual[count].address_format_cd = a.address_format_cd, reply->qual[count].contact_name = a
   .contact_name, reply->qual[count].residence_type_cd = a.residence_type_cd,
   reply->qual[count].street_address_one = a.street_addr, reply->qual[count].street_address_two = a
   .street_addr2, reply->qual[count].street_address_three = a.street_addr3,
   reply->qual[count].street_address_four = a.street_addr4, reply->qual[count].city = a.city, reply->
   qual[count].state = a.state,
   reply->qual[count].state_cd = a.state_cd, reply->qual[count].zipcode = a.zipcode, reply->qual[
   count].postal_barcode_info = a.postal_barcode_info,
   reply->qual[count].county = a.county, reply->qual[count].county_cd = a.county_cd, reply->qual[
   count].country = a.country,
   reply->qual[count].country_cd = a.country_cd, reply->qual[count].residence_cd = a.residence_cd,
   reply->qual[count].mail_stop = a.mail_stop
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
