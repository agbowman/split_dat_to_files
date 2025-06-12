CREATE PROGRAM cdi_get_person_demographics_rr:dba
 IF (validate(request)=0)
  RECORD request(
    1 person[*]
      2 person_id = f8
  ) WITH persistscript
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
      2 name_full_formatted = vc
      2 birth_date = dq8
      2 birth_tz = i4
      2 age = vc
      2 gender = vc
      2 language = vc
      2 marital_status = vc
      2 mother_maiden_name = vc
      2 nationality = vc
      2 person_type = vc
      2 vip = vc
      2 address = vc
      2 address_2 = vc
      2 city = vc
      2 state = vc
      2 zip_code = vc
      2 phone = vc
      2 person_alias_cnt = i4
      2 person_alias[*]
        3 person_alias_type_cd = f8
        3 alias = vc
      2 person_prsnl_reltn_cnt = i4
      2 person_prsnl_reltn[*]
        3 person_prsnl_r_cd = f8
        3 prsnl_person_id = f8
        3 prsnl_name = vc
      2 person_name_cnt = i4
      2 person_name[*]
        3 name_type_cd = f8
        3 name_full = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
END GO
