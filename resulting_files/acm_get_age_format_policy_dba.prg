CREATE PROGRAM acm_get_age_format_policy:dba
 EXECUTE srvcore
 SUBROUTINE (querykey(key_str=vc,curs=i4(ref)) =vc)
   DECLARE str_max_length = i4 WITH noconstant(132)
   DECLARE buf2 = c132 WITH noconstant(fillstring(132," "))
   DECLARE ret = i4 WITH noconstant(0)
   SET ret = uar_srvquerykey(0,nullterm(key_str),buf2,str_max_length,curs)
   IF (ret=0)
    SET buf2 = ""
   ENDIF
   RETURN(buf2)
 END ;Subroutine
 SUBROUTINE (getkeystring(key_str=vc) =vc)
   DECLARE str_max_length = i4 WITH noconstant(132)
   DECLARE buf = c132 WITH noconstant(fillstring(132," "))
   DECLARE ret = i4 WITH noconstant(0)
   SET ret = uar_srvgetkeystring(0,nullterm(key_str),buf,str_max_length)
   IF (ret=0)
    SET buf = ""
   ENDIF
   RETURN(buf)
 END ;Subroutine
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 age_format_rules[*]
     2 end_point = vc
     2 major_unit = vc
     2 minor_unit = vc
     2 fractional_units = vc
 )
 DECLARE cursor = i4 WITH noconstant(0)
 DECLARE age_format_policy_path = vc WITH constant(
  "/Config/System/Locale/Formatting/Age/DefaultChronologicalPolicy/")
 SET stat = alterlist(reply->age_format_rules,10)
 SET age_format_endpoint_key = trim(querykey(age_format_policy_path,cursor))
 WHILE (age_format_endpoint_key != " ")
   SET reply->age_format_rules[cursor].end_point = age_format_endpoint_key
   SET reply->age_format_rules[cursor].major_unit = trim(getkeystring(build(age_format_policy_path,
      age_format_endpoint_key,"/MajorUnit")))
   SET reply->age_format_rules[cursor].minor_unit = trim(getkeystring(build(age_format_policy_path,
      age_format_endpoint_key,"/MinorUnit")))
   SET reply->age_format_rules[cursor].fractional_units = trim(getkeystring(build(
      age_format_policy_path,age_format_endpoint_key,"/FractionalUnits")))
   SET age_format_endpoint_key = trim(querykey(age_format_policy_path,cursor))
   IF (mod(cursor,10)=1)
    SET stat = alterlist(reply->age_format_rules,10)
   ENDIF
 ENDWHILE
 SET stat = alterlist(reply->age_format_rules,cursor)
END GO
