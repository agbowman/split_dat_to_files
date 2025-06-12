CREATE PROGRAM edw_create_org_files:dba
 DECLARE line = vc
 SELECT INTO value(org_extract)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE (allorg->qual[d.seq].organization_id > 0.0)
  DETAIL
   org_file_cnt = (org_file_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(build(cnvtstring(allorg->qual[d.seq].organization_id,16))), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].org_name,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].street_addr,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].street_addr2,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].street_addr3,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].street_addr4,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].city,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(allorg->qual[d.seq].state_cd,16))), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].state,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].zipcode,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(allorg->qual[d.seq].county_cd,16))), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].county,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(allorg->qual[d.seq].country_cd,16))), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].country,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].phone_number,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].fax_phone,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].email,str_find,str_replace,3),3)), v_bar, v_bar,
   v_bar, v_bar, "0",
   v_bar, v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(allorg->qual[d.seq].location_cd,16))), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].nhs_organization_nbr,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].nhs_trust_nbr,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(allorg->qual[d.seq].nhs_trust_ind))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(allorg->qual[d.seq].src_active_ind,3)), v_bar,
   v_bar, v_bar, v_bar,
   v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].org_npi,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(allorg->qual[d.seq].org_alias,str_find,str_replace,3),3)), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "011 02/11/2016 MF025696"
#end_program
END GO
