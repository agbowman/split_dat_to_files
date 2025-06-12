CREATE PROGRAM bhs_mp_hospitalist_tst:dba
 SELECT INTO "nl:"
  pr.name_full_formatted, pr.position_cd, pr.person_id
  FROM prsnl pr
  WHERE pr.name_last_key IN ("MCKENNA*WEISS*", "OYULA*")
  WITH nocounter, uar_code(d)
 ;end select
 SET reqinfo->updt_id = 24762917
 EXECUTE bhs_mp_hospitalist "N"
END GO
