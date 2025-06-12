CREATE PROGRAM bhs_resident_info_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@baystatehealth.org"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 DECLARE anesmd = f8
 DECLARE assopro = f8
 DECLARE cardsrgmd = f8
 DECLARE cardmd = f8
 DECLARE critmd = f8
 DECLARE edmd = f8
 DECLARE gimd = f8
 DECLARE gpedmd = f8
 DECLARE gsrgmd = f8
 DECLARE infmd = f8
 DECLARE mwife = f8
 DECLARE neonmd = f8
 DECLARE neurmd = f8
 DECLARE nonstfmd = f8
 DECLARE obgynmd = f8
 DECLARE oncolmd = f8
 DECLARE orthmd = f8
 DECLARE pcoassopro = f8
 DECLARE physiatrymd = f8
 DECLARE physgenmd = f8
 DECLARE physphysmd = f8
 DECLARE psychmd = f8
 DECLARE pulmd = f8
 DECLARE rresphys = f8
 DECLARE radmd = f8
 DECLARE renmd = f8
 DECLARE resphys = f8
 DECLARE thormd = f8
 DECLARE urolmd = f8
 DECLARE refphys = f8
 SET anesmd = uar_get_code_by("display",88,"BHS Anesthesiology MD")
 SET assopro = uar_get_code_by("display",88,"BHS Associate Professional")
 SET cardsrgmd = uar_get_code_by("display",88,"BHS Cardiac Surgery MD")
 SET cardmd = uar_get_code_by("display",88,"BHS Cardiology MD")
 SET critmd = uar_get_code_by("display",88,"BHS Critical Care MD")
 SET edmd = uar_get_code_by("display",88,"BHS ED Medicine MD")
 SET gimd = uar_get_code_by("display",88,"BHS GI MD")
 SET gpedmd = uar_get_code_by("display",88,"BHS General Pediatrics MD")
 SET gsrgmd = uar_get_code_by("display",88,"BHS General Surgery MD")
 SET infmd = uar_get_code_by("display",88,"BHS Infectious Disease MD")
 SET mwife = uar_get_code_by("display",88,"BHS Midwife")
 SET neonmd = uar_get_code_by("display",88,"BHS Neonatal MD")
 SET neurmd = uar_get_code_by("display",88,"BHS Neurology MD")
 SET nonstfmd = uar_get_code_by("display",88,"BHS Non Med Staff MD")
 SET obgynmd = uar_get_code_by("display",88,"BHS OB/GYN MD")
 SET oncolmd = uar_get_code_by("display",88,"BHS Oncology MD")
 SET orthmd = uar_get_code_by("display",88,"BHS Orthopedics MD")
 SET pcoassopro = uar_get_code_by("display",88,"BHS PCO Associate Professional")
 SET physiatrymd = uar_get_code_by("display",88,"BHS Physiatry MD")
 SET physgenmd = uar_get_code_by("display",88,"BHS Physician (General Medicine)")
 SET physphysmd = uar_get_code_by("display",88,"BHS Physician -Physician Practices")
 SET psychmd = uar_get_code_by("display",88,"BHS Psychiatry MD")
 SET pulmd = uar_get_code_by("display",88,"BHS Pulmonary MD")
 SET rresphys = uar_get_code_by("display",88,"BHS Rad Resident")
 SET radmd = uar_get_code_by("display",88,"BHS Radiology MD")
 SET renmd = uar_get_code_by("display",88,"BHS Renal MD")
 SET resphys = uar_get_code_by("display",88,"BHS Resident")
 SET thormd = uar_get_code_by("display",88,"BHS Thoracic MD")
 SET urolmd = uar_get_code_by("display",88,"BHS Urology MD")
 SET refphys = uar_get_code_by("display",88,"Reference Physician")
 RECORD md_alias(
   1 qual[*]
     2 name = vc
     2 stat_cd = f8
     2 stat_descr = vc
     2 last_name = vc
     2 first_name = vc
     2 username = vc
     2 phys_flg = i2
     2 position = vc
     2 personid = f8
     2 demog_updt = dq8
     2 dea_nbr = vc
     2 npi_nbr = vc
     2 org_id = vc
     2 doc_upin = vc
     2 license_nbr = vc
     2 ext_id = vc
     2 b_addr_1 = vc
     2 b_addr_2 = vc
     2 b_addr_3 = vc
     2 b_addr_4 = vc
     2 b_city = vc
     2 b_state = vc
     2 b_zip = vc
     2 b_phone = vc
     2 b_fax = vc
     2 ez_addr_1 = vc
     2 ez_addr_2 = vc
     2 ez_addr_3 = vc
     2 ez_addr_4 = vc
     2 ez_city = vc
     2 ez_state = vc
     2 ez_zip = vc
     2 ez_phone = vc
 )
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE pr.physician_ind=1
    AND pr.active_ind=1
    AND pr.active_status_cd=188
    AND cnvtupper(pr.name_full_formatted) != "*BYPASS*"
    AND ((pr.position_cd=resphys) OR (pr.position_cd=rresphys)) )
  ORDER BY pr.person_id
  HEAD REPORT
   cnt1 = 0
  HEAD pr.person_id
   cnt1 = (cnt1+ 1), stat = alterlist(md_alias->qual,cnt1), md_alias->qual[cnt1].name = pr
   .name_full_formatted,
   md_alias->qual[cnt1].stat_cd = pr.active_status_cd, md_alias->qual[cnt1].stat_descr =
   uar_get_code_display(pr.active_status_cd), md_alias->qual[cnt1].username = pr.username,
   md_alias->qual[cnt1].last_name = pr.name_last, md_alias->qual[cnt1].first_name = pr.name_first,
   md_alias->qual[cnt1].phys_flg = pr.physician_ind,
   md_alias->qual[cnt1].position = uar_get_code_display(pr.position_cd), md_alias->qual[cnt1].
   personid = pr.person_id, md_alias->qual[cnt1].demog_updt = pr.updt_dt_tm
  WITH nocounter, time = 90
 ;end select
 SELECT INTO "nl:"
  FROM prsnl_alias pa,
   (dummyt d  WITH seq = value(size(md_alias->qual,5)))
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=md_alias->qual[d.seq].personid))
  ORDER BY pa.person_id
  DETAIL
   IF (pa.prsnl_alias_type_cd=1084
    AND pa.active_ind=1)
    md_alias->qual[d.seq].dea_nbr = pa.alias
   ENDIF
   IF (pa.prsnl_alias_type_cd=1088
    AND pa.active_ind=1)
    md_alias->qual[d.seq].org_id = pa.alias
   ENDIF
   IF (pa.prsnl_alias_type_cd=64094777
    AND pa.active_ind=1)
    md_alias->qual[d.seq].npi_nbr = pa.alias
   ENDIF
   IF (pa.prsnl_alias_type_cd=1085
    AND pa.active_ind=1)
    md_alias->qual[d.seq].doc_upin = pa.alias
   ENDIF
   IF (pa.prsnl_alias_type_cd=1087
    AND pa.active_ind=1)
    md_alias->qual[d.seq].license_nbr = pa.alias
   ENDIF
   IF (pa.prsnl_alias_type_cd=1086
    AND pa.active_ind=1)
    md_alias->qual[d.seq].ext_id = pa.alias
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address a,
   (dummyt d  WITH seq = value(size(md_alias->qual,5)))
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=md_alias->qual[d.seq].personid))
  ORDER BY a.parent_entity_id
  DETAIL
   IF (a.address_type_cd=754
    AND a.active_ind=1)
    md_alias->qual[d.seq].b_addr_1 = a.street_addr, md_alias->qual[d.seq].b_addr_2 = a.street_addr2,
    md_alias->qual[d.seq].b_addr_3 = a.street_addr3,
    md_alias->qual[d.seq].b_addr_4 = a.street_addr4, md_alias->qual[d.seq].b_city = a.city, md_alias
    ->qual[d.seq].b_state = a.state,
    md_alias->qual[d.seq].b_zip = a.zipcode
   ENDIF
   IF (a.address_type_cd=78188909
    AND a.active_ind=1)
    md_alias->qual[d.seq].ez_addr_1 = a.street_addr, md_alias->qual[d.seq].ez_addr_2 = a.street_addr2,
    md_alias->qual[d.seq].ez_addr_3 = a.street_addr3,
    md_alias->qual[d.seq].ez_addr_4 = a.street_addr4, md_alias->qual[d.seq].ez_city = a.city,
    md_alias->qual[d.seq].ez_state = a.state,
    md_alias->qual[d.seq].ez_zip = a.zipcode
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph,
   (dummyt d  WITH seq = value(size(md_alias->qual,5)))
  PLAN (d)
   JOIN (ph
   WHERE (ph.parent_entity_id=md_alias->qual[d.seq].personid))
  ORDER BY ph.parent_entity_id
  DETAIL
   IF (ph.phone_type_cd=163
    AND ph.active_ind=1
    AND ph.active_status_cd=188)
    md_alias->qual[d.seq].b_phone = ph.phone_num
   ENDIF
   IF (ph.phone_type_cd=78189133
    AND ph.active_ind=1
    AND ph.active_status_cd=188)
    md_alias->qual[d.seq].ez_phone = ph.phone_num
   ENDIF
   IF (ph.phone_type_cd=78189133
    AND ph.active_ind=1
    AND ph.active_status_cd=188)
    md_alias->qual[d.seq].b_fax = ph.phone_num
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(output_dest)
  md_alias->qual[d.seq].personid
  FROM (dummyt d  WITH seq = size(md_alias->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   col 1, ",", "Node:",
   ",", curnode, ",",
   curprog, ",", ",",
   "Run Date: ", curdate, row + 1,
   col 1, ",", "Person ID",
   ",", "Status", ",",
   "Name", ",", "Log-in ID",
   ",", "Position", ",",
   "UPDT", ",", "DEA nbr",
   ",", "NPI nbr", ",",
   "ORG ID", ",", "UPIN",
   ",", "License", ",",
   "Ext ID", ",", "Bus Addr-1",
   ",", "Bus Addr-2", ",",
   "Bus Addr-3", ",", "Bus Addr-4",
   ",", "Bus City", ",",
   "Bus Sate", ",", "Bus Zip",
   ",", "Bus Phone", ",",
   "Bus FAX", ",", "EZ Addr-1",
   ",", "EZ Addr-2", ",",
   "EZ Addr-3", ",", "EZ Addr-4",
   ",", "EZ City", ",",
   "EZ Sate", ",", "EZ Zip",
   ",", "EZ Phone", ",",
   row + 1, display_line = build(md_alias->qual[d.seq].name)
   FOR (y = 1 TO size(md_alias->qual[d.seq],5))
     xperson_id = format(md_alias->qual[y].personid,"#########"), output_string = build(y,',"',
      xperson_id,'","',md_alias->qual[y].stat_descr,
      '","',md_alias->qual[y].name,'","',md_alias->qual[y].username,'","',
      md_alias->qual[y].position,'","',format(md_alias->qual[y].demog_updt,"yyyy-mm-dd;;d"),'","',
      md_alias->qual[y].dea_nbr,
      '","',md_alias->qual[y].npi_nbr,'","',md_alias->qual[y].org_id,'","',
      md_alias->qual[y].doc_upin,'","',md_alias->qual[y].license_nbr,'","',md_alias->qual[y].ext_id,
      '","',md_alias->qual[y].b_addr_1,'","',md_alias->qual[y].b_addr_2,'","',
      md_alias->qual[y].b_addr_3,'","',md_alias->qual[y].b_addr_4,'","',md_alias->qual[y].b_city,
      '","',md_alias->qual[y].b_state,'","',md_alias->qual[y].b_zip,'","',
      format(md_alias->qual[y].b_phone,"(###)###-####"),'","',format(md_alias->qual[y].b_fax,
       "(###)###-####"),'","',md_alias->qual[y].ez_addr_1,
      '","',md_alias->qual[y].ez_addr_2,'","',md_alias->qual[y].ez_addr_3,'","',
      md_alias->qual[y].ez_addr_4,'","',md_alias->qual[y].ez_city,'","',md_alias->qual[y].ez_state,
      '","',md_alias->qual[y].ez_zip,'","',format(md_alias->qual[y].ez_phone,"(###)###-####"),'",'),
     col 1,
     output_string
     IF ( NOT (curendreport))
      row + 1
     ENDIF
   ENDFOR
  WITH format = variable, formfeed = none, maxcol = 550
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_Active_Residents.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - Active Residents ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
