CREATE PROGRAM dm_ocd_cs_error_check:dba
 SELECT INTO "nl:"
  a.*
  FROM dm_afd_code_value_set a
  WHERE a.alpha_feature_nbr=ocd_number
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM code_value_set b
   WHERE a.code_set=b.code_set)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED CODE VALUE SET REFRESH"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.*
  FROM dm_afd_common_data_foundation a
  WHERE a.alpha_feature_nbr=ocd_number
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM common_data_foundation b
   WHERE a.code_set=b.code_set
    AND a.cdf_meaning=b.cdf_meaning)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED COMMON DATA FOUNDATION REFRESH"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.*
  FROM dm_afd_code_set_extension a
  WHERE a.alpha_feature_nbr=ocd_number
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM code_set_extension b
   WHERE a.code_set=b.code_set
    AND a.field_name=b.field_name)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED CODE SET EXTENSION REFRESH"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.*
  FROM dm_afd_code_value a
  WHERE a.alpha_feature_nbr=ocd_number
   AND a.cki IS NOT null
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM code_value b
   WHERE a.code_set=b.code_set
    AND a.cki=b.cki)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED CODE VALUE REFRESH"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.*
  FROM dm_afd_code_value_alias a
  WHERE a.alpha_feature_nbr=ocd_number
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM code_value_alias b
   WHERE a.code_set=b.code_set
    AND a.alias=b.alias)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED CODE VALUE ALIAS REFRESH"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.*
  FROM dm_afd_code_value_extension a
  WHERE a.alpha_feature_nbr=ocd_number
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM code_value_extension b
   WHERE a.code_set=b.code_set
    AND a.field_name=b.field_name)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED CODE VALUE EXTENSION REFRESH"
  GO TO end_program
 ENDIF
 SET cvg_err_ind = 0
 DECLARE cvg_err_msg = c132
 SET cvg_err_ind = error(cvg_err_msg,1)
 SELECT INTO "nl:"
  FROM dm_afd_code_value_group ag
  WHERE ag.alpha_feature_nbr=ocd_number
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_afd_code_value ac
   WHERE ag.child_code_value=ac.code_value)))
  WITH maxqual(ag,1), nocounter
 ;end select
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED CODE VALUE GROUP REFRESH(MISSING CHILD CODE VALUE)"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.*
  FROM dm_afd_code_value_group a,
   dm_afd_code_value ac1,
   dm_afd_code_value ac2
  PLAN (a
   WHERE a.alpha_feature_nbr=ocd_number)
   JOIN (ac1
   WHERE ac1.alpha_feature_nbr=a.alpha_feature_nbr
    AND ac1.code_set=a.code_set
    AND ac1.code_value=a.parent_code_value)
   JOIN (ac2
   WHERE ac2.code_set=a.child_code_set
    AND ac2.code_value=a.child_code_value
    AND  NOT ( EXISTS (
   (SELECT
    "X"
    FROM code_value_group b,
     code_value cv1,
     code_value cv2
    WHERE b.parent_code_value=cv1.code_value
     AND b.child_code_value=cv2.code_value
     AND cv1.cki=ac1.cki
     AND cv2.cki=ac2.cki))))
  WITH maxqual(a,1), nocounter
 ;end select
 SET cvg_err_ind = error(cvg_err_msg,0)
 IF (cvg_err_ind > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = cvg_err_msg
  GO TO end_program
 ENDIF
 IF (curqual > 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "FAILED CODE VALUE GROUP REFRESH"
  GO TO end_program
 ENDIF
 SET docd_reply->status = "S"
#end_program
END GO
