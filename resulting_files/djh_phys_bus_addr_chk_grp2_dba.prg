CREATE PROGRAM djh_phys_bus_addr_chk_grp2:dba
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
 DECLARE refphys = f8
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
     2 b_country = vc
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
    AND cnvtupper(pr.name_full_formatted) != "*BYPASS*"
    AND ((pr.name_last_key="xxdmmy"
    AND pr.name_first_key="xxdummy") OR (((pr.name_last_key="FAROOQUI*"
    AND pr.name_first_key="MASIH*") OR (((pr.name_last_key="FAY*"
    AND pr.name_first_key="ANDREW*") OR (((pr.name_last_key="FITZGERALD*"
    AND pr.name_first_key="KEVIN*") OR (((pr.name_last_key="FITZPATRICK*"
    AND pr.name_first_key="TIMOTHY*") OR (((pr.name_last_key="FLORES*"
    AND pr.name_first_key="CARLOS*") OR (((pr.name_last_key="FLYNN*"
    AND pr.name_first_key="GLENDA*") OR (((pr.name_last_key="FOULKS*"
    AND pr.name_first_key="DEVON*") OR (((pr.name_last_key="FOX*"
    AND pr.name_first_key="STEPHEN*") OR (((pr.name_last_key="FREEMAN*"
    AND pr.name_first_key="JAMES*") OR (((pr.name_last_key="FULFORD*"
    AND pr.name_first_key="JEFFREY*") OR (((pr.name_last_key="FURCOLO*"
    AND pr.name_first_key="TINA*") OR (((pr.name_last_key="GABERMAN*"
    AND pr.name_first_key="JONNA*") OR (((pr.name_last_key="GERSTEIN*"
    AND pr.name_first_key="ALAN*") OR (((pr.name_last_key="GERSTLE*"
    AND pr.name_first_key="KATHERINE*") OR (((pr.name_last_key="GIOIELLA*"
    AND pr.name_first_key="LAURA*") OR (((pr.name_last_key="GLADING*DILORENZO*"
    AND pr.name_first_key="LISE*") OR (((pr.name_last_key="GLYNN*"
    AND pr.name_first_key="PHILIP*") OR (((pr.name_last_key="GOLDFIELD*"
    AND pr.name_first_key="NORBERT*") OR (((pr.name_last_key="GOLDMAN*"
    AND pr.name_first_key="MARC*") OR (((pr.name_last_key="GRANDISON*"
    AND pr.name_first_key="KATHLEEN*") OR (((pr.name_last_key="GREENBERG*"
    AND pr.name_first_key="ELIOT*") OR (((pr.name_last_key="GROW*"
    AND pr.name_first_key="DANIEL*") OR (((pr.name_last_key="GUHN*"
    AND pr.name_first_key="AUDREY*") OR (((pr.name_last_key="GUPTA*"
    AND pr.name_first_key="ELLA*") OR (((pr.name_last_key="GUTIERREZ*"
    AND pr.name_first_key="RICARDO*") OR (((pr.name_last_key="HAAGRICKERT*"
    AND pr.name_first_key="COLETTE*") OR (((pr.name_last_key="HADDAD*"
    AND pr.name_first_key="HANI*") OR (((pr.name_last_key="HAKIM*"
    AND pr.name_first_key="MICHAEL*") OR (((pr.name_last_key="HARRIS*"
    AND pr.name_first_key="DEBORAH*") OR (((pr.name_last_key="HAYFRON*"
    AND pr.name_first_key="MD*") OR (((pr.name_last_key="HELMUTH*"
    AND pr.name_first_key="PAUL*") OR (((pr.name_last_key="HESSION*"
    AND pr.name_first_key="MELISSA*") OR (((pr.name_last_key="HETZEL*"
    AND pr.name_first_key="PAUL*") OR (((pr.name_last_key="HIGBY*"
    AND pr.name_first_key="DONALD*") OR (((pr.name_last_key="HOWE*"
    AND pr.name_first_key="THERESA*") OR (((pr.name_last_key="HUBBARD*"
    AND pr.name_first_key="SANDRA*") OR (pr.name_last_key="HUSSAIN*"
    AND pr.name_first_key="SYED*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  ORDER BY pr.name_last_key, pr.name_first_key
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
    md_alias->qual[d.seq].b_country = a.country, md_alias->qual[d.seq].b_zip = a.zipcode
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
   "ccl program:", ",", curprog,
   ",", "Run Date: ", curdate,
   row + 1, col 1, ",",
   "Person ID", ",", "Status",
   ",", "Name", ",",
   "Log-in ID", ",", "Position",
   ",", "UPDT", ",",
   "Bus Addr-1", ",", "Bus Addr-2",
   ",", "Bus Addr-3", ",",
   "Bus Addr-4", ",", "Bus City",
   ",", "Bus Sate", ",",
   "Country", ",", "Bus Zip",
   ",", "Bus Phone", ",",
   "Bus FAX", ",", row + 1,
   display_line = build(md_alias->qual[d.seq].name)
   FOR (y = 1 TO size(md_alias->qual[d.seq],5))
     IF ((((md_alias->qual[y].dea_nbr=null)) OR ((((md_alias->qual[y].npi_nbr=null)) OR ((((md_alias
     ->qual[y].b_addr_1=null)
      AND (md_alias->qual[y].b_addr_2=null)) OR ((((md_alias->qual[y].b_phone=null)) OR ((((md_alias
     ->qual[y].b_fax=null)) OR ((((md_alias->qual[y].ez_addr_1=null)
      AND (md_alias->qual[y].ez_addr_2=null)) OR ((md_alias->qual[y].ez_phone=null))) )) )) )) )) ))
     )
      xperson_id = format(md_alias->qual[y].personid,"#########"), output_string = build(y,',"',
       xperson_id,'","',md_alias->qual[y].stat_descr,
       '","',md_alias->qual[y].name,'","',md_alias->qual[y].username,'","',
       md_alias->qual[y].position,'","',format(md_alias->qual[y].demog_updt,"yyyy-mm-dd;;d"),'","',
       md_alias->qual[y].b_addr_1,
       '","',md_alias->qual[y].b_addr_2,'","',md_alias->qual[y].b_addr_3,'","',
       md_alias->qual[y].b_addr_4,'","',md_alias->qual[y].b_city,'","',md_alias->qual[y].b_state,
       '","',md_alias->qual[y].b_country,'","',md_alias->qual[y].b_zip,'","',
       format(md_alias->qual[y].b_phone,"(###)###-####"),'","',format(md_alias->qual[y].b_fax,
        "(###)###-####"),'",'), col 1,
      output_string
      IF ( NOT (curendreport))
       row + 1
      ENDIF
     ENDIF
   ENDFOR
  WITH format = variable, formfeed = none, maxcol = 550
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_PHYS_BUS_addr_info.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - PHYS BUS ADDR info ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
