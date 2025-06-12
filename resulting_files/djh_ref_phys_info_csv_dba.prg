CREATE PROGRAM djh_ref_phys_info_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
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
 RECORD md_alias(
   1 qual[*]
     2 name = vc
     2 last_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 suffix = vc
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
 )
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE pr.physician_ind >= 0
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pr.username="RF*")
  ORDER BY pr.person_id
  HEAD REPORT
   cnt1 = 0
  HEAD pr.person_id
   cnt1 = (cnt1+ 1), stat = alterlist(md_alias->qual,cnt1), md_alias->qual[cnt1].name = pr
   .name_full_formatted,
   md_alias->qual[cnt1].username = pr.username, md_alias->qual[cnt1].last_name = pr.name_last,
   md_alias->qual[cnt1].first_name = pr.name_first,
   md_alias->qual[cnt1].phys_flg = pr.physician_ind, md_alias->qual[cnt1].position =
   uar_get_code_display(pr.position_cd), md_alias->qual[cnt1].personid = pr.person_id,
   md_alias->qual[cnt1].demog_updt = pr.updt_dt_tm
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
   IF (ph.phone_type_cd=166
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
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Middle Name", ",", "Suffix",
   ",", "Bus Addr-1", ",",
   "Bus Addr-2", ",", "Bus Addr-3",
   ",", "Bus Addr-4", ",",
   "Bus City", ",", "Bus Sate",
   ",", "Bus Zip", ",",
   "Bus Phone", ",", "Bus FAX",
   ",", "Pager", ",",
   "License", ",", "Person ID",
   ",", "Log-in ID", ",",
   "Position", ",", "UPDT",
   ",", "DEA nbr", ",",
   "NPI nbr", ",", "ORG ID",
   ",", "UPIN", ",",
   "Ext ID", ",", "Name - Full",
   ",", row + 1, display_line = build(md_alias->qual[d.seq].name)
   FOR (y = 1 TO size(md_alias->qual[d.seq],5))
     xperson_id = format(md_alias->qual[y].personid,"#########"), d_update = format(md_alias->qual[y]
      .demog_updt,"yyyy-mm-dd;;d"), xphysflg =
     IF ((md_alias->qual[y].phys_flg=1)) "*"
     ELSE "XX"
     ENDIF
     ,
     output_string = build(y,',"',md_alias->qual[y].last_name,'","',md_alias->qual[y].first_name,
      '","','","','","',md_alias->qual[y].b_addr_1,'","',
      md_alias->qual[y].b_addr_2,'","',md_alias->qual[y].b_addr_3,'","',md_alias->qual[y].b_addr_4,
      '","',md_alias->qual[y].b_city,'","',md_alias->qual[y].b_state,'","',
      md_alias->qual[y].b_zip,'","',md_alias->qual[y].b_phone,'","',md_alias->qual[y].b_fax,
      '","','","',md_alias->qual[y].license_nbr,'","',xperson_id,
      '","',md_alias->qual[y].username,'","',md_alias->qual[y].position,'","',
      d_update,'","',md_alias->qual[y].dea_nbr,'","',md_alias->qual[y].npi_nbr,
      '","',md_alias->qual[y].org_id,'","',md_alias->qual[y].doc_upin,'","',
      md_alias->qual[y].ext_id,'","',md_alias->qual[y].name,'",'), col 1, output_string
     IF ( NOT (curendreport))
      row + 1
     ENDIF
   ENDFOR
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "??"
   ENDIF
  FOOT REPORT
   row + 1, col 1, ",",
   "Node:", ",", curnode,
   ",", ms_domain, row + 1,
   col 1, ",", "Prog:",
   ",", curprog
  WITH format = variable, formfeed = none, maxcol = 600
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_Ref_Phys_ADDR_Info.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - Ref Phys Info ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
