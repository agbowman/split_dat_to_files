CREATE PROGRAM cv_utl_sts_res_default:dba
 UPDATE  FROM cv_response
  SET a2 = "CernCorp"
  WHERE response_internal_name="STS_VENDORID"
 ;end update
 UPDATE  FROM cv_response
  SET a2 = "7.8"
  WHERE response_internal_name="STS_SOFTVRSN"
 ;end update
 UPDATE  FROM cv_response
  SET a2 = "2.35"
  WHERE response_internal_name="STS_DATAVRSN"
 ;end update
 UPDATE  FROM cv_response
  SET a3 = "MALE", a4 = "57"
  WHERE response_internal_name="STS_GENDER_MALE"
 ;end update
 UPDATE  FROM cv_response
  SET a3 = "FEMALE", a4 = "57"
  WHERE response_internal_name="STS_GENDER_FEMALE"
 ;end update
 UPDATE  FROM cv_response
  SET a5 = "CAUCASIAN", a4 = "282"
  WHERE response_internal_name="STS_RACE_CAUCASIAN"
 ;end update
 UPDATE  FROM cv_response
  SET a5 = "OTHER", a4 = "282"
  WHERE response_internal_name="STS_RACE_OTHER"
 ;end update
 UPDATE  FROM cv_response
  SET a5 = "NATIVEAMERICAN", a4 = "282"
  WHERE response_internal_name="STS_RACE_NATIVEAMERICAN"
 ;end update
 UPDATE  FROM cv_response
  SET a5 = "HISPANIC", a4 = "282"
  WHERE response_internal_name="STS_RACE_HISPANIC"
 ;end update
 UPDATE  FROM cv_response
  SET a5 = "BLACK", a4 = "282"
  WHERE response_internal_name="STS_RACE_BLACK"
 ;end update
 UPDATE  FROM cv_response
  SET a5 = "ASIAN", a4 = "282"
  WHERE response_internal_name="STS_RACE_ASIAN"
 ;end update
 COMMIT
END GO
