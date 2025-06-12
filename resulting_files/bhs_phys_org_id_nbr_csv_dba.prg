CREATE PROGRAM bhs_phys_org_id_nbr_csv:dba
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
    AND cnvtupper(pr.name_full_formatted) != "*BYPASS*"
    AND ((pr.position_cd=resphys) OR (((pr.position_cd=anesmd) OR (((pr.position_cd=assopro) OR (((pr
   .position_cd=cardsrgmd) OR (((pr.position_cd=cardmd) OR (((pr.position_cd=critmd) OR (((pr
   .position_cd=edmd) OR (((pr.position_cd=gimd) OR (((pr.position_cd=gpedmd) OR (((pr.position_cd=
   gsrgmd) OR (((pr.position_cd=infmd) OR (((pr.position_cd=mwife) OR (((pr.position_cd=neonmd) OR (
   ((pr.position_cd=neurmd) OR (((pr.position_cd=nonstfmd) OR (((pr.position_cd=obgynmd) OR (((pr
   .position_cd=oncolmd) OR (((pr.position_cd=orthmd) OR (((pr.position_cd=pcoassopro) OR (((pr
   .position_cd=physiatrymd) OR (((pr.position_cd=physgenmd) OR (((pr.position_cd=physphysmd) OR (((
   pr.position_cd=psychmd) OR (((pr.position_cd=pulmd) OR (((pr.position_cd=rresphys) OR (((pr
   .position_cd=radmd) OR (((pr.position_cd=renmd) OR (((pr.position_cd=thormd) OR (((pr.position_cd=
   urolmd) OR (pr.position_cd=refphys)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )
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
   IF (pa.prsnl_alias_type_cd=1088
    AND pa.active_ind=1)
    md_alias->qual[d.seq].org_id = pa.alias
   ENDIF
   IF (pa.prsnl_alias_type_cd=1086
    AND pa.active_ind=1)
    md_alias->qual[d.seq].ext_id = pa.alias
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(output_dest)
  md_alias->qual[d.seq].personid
  FROM (dummyt d  WITH seq = size(md_alias->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   col 1, ",", "Run Date: ",
   curdate, row + 1, col 1,
   ",", "Name", ",",
   "Position", ",", "ORG ID",
   ",", "Ext ID", ",",
   row + 1, display_line = build(md_alias->qual[d.seq].name)
   FOR (y = 1 TO size(md_alias->qual[d.seq],5))
     xperson_id = format(md_alias->qual[y].personid,"#########"), output_string = build(y,',"',
      md_alias->qual[y].name,'","',md_alias->qual[y].position,
      '","',md_alias->qual[y].org_id,'","',md_alias->qual[y].ext_id,'",'), col 1,
     output_string
     IF ( NOT (curendreport))
      row + 1
     ENDIF
   ENDFOR
   row + 1, output_string = build(',"','","',"End of Report",'",'), col 1,
   output_string, row + 2, output_string = build(',"',"Node: ",curnode,'","',"prog: ",
    curprog,'",'),
   col 1, output_string
  WITH format = variable, formfeed = none, maxcol = 550
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_PHYS_ORG_DOC_nbr.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - PHYS ORG ID nbr ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
