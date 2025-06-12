CREATE PROGRAM cp_activate_14005_code:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET updt_nbr = 0
 SET act_nbr = 0
 SET updt_nbr1 = 0
 SET inact_nbr = 0
 SET roll_back_nbr = 0
 UPDATE  FROM code_value
  SET active_ind = 1, updt_dt_tm = cnvtdatetime(sysdate)
  WHERE code_set=14005
   AND cdf_meaning IN ("180", "540", "640", "1730", "1740",
  "1750", "1760", "330", "350", "1230",
  "1335", "1601", "1606", "1680", "1010",
  "115", "976", "986")
 ;end update
 SET updt_nbr = curqual
 SET readme_data->message = build("Activated code values for code set 14005: ",curqual)
 EXECUTE dm_readme_status
 COMMIT
 UPDATE  FROM code_value
  SET active_ind = 1, updt_dt_tm = cnvtdatetime(sysdate)
  WHERE code_set=14284
   AND cdf_meaning IN ("50005", "50006")
 ;end update
 SET updt_nbr += curqual
 SET readme_data->message = build("Activated code values for code set 14284: ",curqual)
 EXECUTE dm_readme_status
 COMMIT
 SELECT INTO "nl:"
  FROM code_value
  WHERE code_set=14005
   AND cdf_meaning IN ("180", "540", "640", "1730", "1740",
  "1750", "1760", "330", "350", "1230",
  "1335", "1601", "1606", "1680", "1010",
  "115", "976", "986")
   AND active_ind=1
 ;end select
 SET act_nbr = curqual
 SELECT INTO "nl:"
  FROM code_value
  WHERE code_set=14284
   AND cdf_meaning IN ("50005", "50006")
   AND active_ind=1
 ;end select
 SET act_nbr += curqual
 IF (updt_nbr != act_nbr)
  SET roll_back_nbr += 1
  ROLLBACK
  SET readme_data->message = build(
   "Total activated code values are not correct. Roll back to original value.")
  EXECUTE dm_readme_status
  COMMIT
  CALL echo("Failed to activate codes in 14005 and 14284!")
 ELSE
  SET readme_data->message = build("Total activated code values:",updt_nbr)
  EXECUTE dm_readme_status
  CALL echo("Succeeded to activate codes in 14005 and 14284!")
  COMMIT
 ENDIF
 UPDATE  FROM code_value
  SET active_ind = 0, updt_dt_tm = cnvtdatetime(sysdate)
  WHERE code_set=14005
   AND cdf_meaning IN ("60", "240", "500", "560", "780",
  "820", "840", "860", "880", "920",
  "1180", "1240", "1380", "1420", "1440",
  "1460", "1480", "1500", "1610", "1620",
  "1630", "1640", "1650", "1660", "1670",
  "9000")
 ;end update
 SET updt_nbr1 = curqual
 SET readme_data->message = build("Inactivated code values for code set 14005: ",curqual)
 EXECUTE dm_readme_status
 COMMIT
 UPDATE  FROM code_value
  SET active_ind = 0, updt_dt_tm = cnvtdatetime(sysdate)
  WHERE code_set=14284
   AND cdf_meaning IN ("40005", "40006", "40007", "40008", "40009")
 ;end update
 SET updt_nbr1 += curqual
 SET readme_data->message = build("Inactivated code values for code set 14284: ",curqual)
 EXECUTE dm_readme_status
 COMMIT
 SELECT INTO "nl:"
  FROM code_value
  WHERE code_set=14005
   AND cdf_meaning IN ("60", "240", "500", "560", "780",
  "820", "840", "860", "880", "920",
  "1180", "1240", "1380", "1420", "1440",
  "1460", "1480", "1500", "1610", "1620",
  "1630", "1640", "1650", "1660", "1670",
  "9000")
   AND active_ind=0
 ;end select
 SET inact_nbr = curqual
 SELECT INTO "nl:"
  FROM code_value
  WHERE code_set=14284
   AND cdf_meaning IN ("40005", "40006", "40007", "40008", "40009")
   AND active_ind=0
 ;end select
 SET inact_nbr += curqual
 IF (updt_nbr1 != inact_nbr)
  SET roll_back_nbr += 1
  ROLLBACK
  SET readme_data->message = build(
   "Total inactivated code values are not correct. Roll back to original value.")
  EXECUTE dm_readme_status
  COMMIT
  CALL echo("Failed to inactivate codes in 14005 and 14284!")
 ELSE
  SET readme_data->message = build("Total inactivated code values:",updt_nbr1)
  EXECUTE dm_readme_status
  CALL echo("Succeeded to inactivate codes in 14005 and 14284 !")
  COMMIT
 ENDIF
 IF (roll_back_nbr > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to activate/inactivate codes in 14005 and 14284."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Succeeded to activate/inactivate codes in 14005 and 14284."
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO
