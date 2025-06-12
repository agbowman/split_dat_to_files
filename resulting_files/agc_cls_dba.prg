CREATE PROGRAM agc_cls:dba
 SET sex_cd = uar_get_code_by("MEANING",57,"FEMALE")
 SELECT INTO  $1
  pid = p.person_id"#########;P0", dob = p.birth_dt_tm"dd-mmm-yyyy;;d", sex = uar_get_code_display(p
   .sex_cd)
  FROM person p
  WHERE p.name_first_key="CAULTON"
  ORDER BY sex, dob DESC
  WITH maxqual = 100
 ;end select
END GO
