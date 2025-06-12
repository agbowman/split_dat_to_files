CREATE PROGRAM edw_create_address:dba
 SELECT INTO value(address_extractfile)
  FROM (dummyt d  WITH seq = size(edw_address->qual,5))
  WHERE (edw_address->qual[d.seq].address_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_source_id)),
   v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].address_sk,16))), v_bar,
   CALL print(trim(edw_address->qual[d.seq].src_active_ind,3)), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].address_info_status_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].address_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].address_type_seq))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_address->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(edw_address->qual[d.seq].src_beg_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].src_beg_effective_tm_zn))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_address->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(edw_address->qual[d.seq].src_end_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].src_end_effective_tm_zn))),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].city_txt,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].comment_txt,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].contact_name,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].country_txt,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].country_ref,16))), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].county_txt,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].county_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].district_health_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].address_long_text_sk,16))),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].operations_hours,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].src_parent_entity_sk,16))), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].src_parent_entity_name,str_find,str_replace,3),3)
   ),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].postal_barcode_info,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].postal_identifier,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].postal_identifier_srch,str_find,str_replace,3),3)
   ),
   v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].primary_care_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].residence_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].residence_type_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].source_identifier,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].state_txt,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].state_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].street_addr1,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].street_addr2,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].street_addr3,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].street_addr4,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].zipcode,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_address->qual[d.seq].zipcode_srch,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_address->qual[d.seq].zipcode_group_ref,16))), v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 05/14/2020 BS074648"
END GO
