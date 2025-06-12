CREATE PROGRAM djh_phys_bus_addr_chk_grp1:dba
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
    AND pr.name_first_key="xxdummy") OR (((pr.name_last_key="ABARE*"
    AND pr.name_first_key="NATHAN*") OR (((pr.name_last_key="ABERT*"
    AND pr.name_first_key="JULIE*") OR (((pr.name_last_key="ACKER*"
    AND pr.name_first_key="BRIAN*") OR (((pr.name_last_key="ALJUBRAN*"
    AND pr.name_first_key="SALMAN*") OR (((pr.name_last_key="ALKABBANI*"
    AND pr.name_first_key="ABDULRAHMAN*") OR (((pr.name_last_key="ALLI*"
    AND pr.name_first_key="GLENN*") OR (((pr.name_last_key="ALPERN*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="AMSTERDAM*"
    AND pr.name_first_key="DIANE*") OR (((pr.name_last_key="ANCHOR*SAMUELS*"
    AND pr.name_first_key="JESSICA*") OR (((pr.name_last_key="ARENAS*"
    AND pr.name_first_key="RICHARD*") OR (((pr.name_last_key="ARMSTRONG*"
    AND pr.name_first_key="KELLY*") OR (((pr.name_last_key="ARONSON*FOX*"
    AND pr.name_first_key="RISA*") OR (((pr.name_last_key="ATKINSON*"
    AND pr.name_first_key="KATHERINE*") OR (((pr.name_last_key="AULAKH*"
    AND pr.name_first_key="SUDEEP*") OR (((pr.name_last_key="AZOCAR*"
    AND pr.name_first_key="JOSE*") OR (((pr.name_last_key="BAILEY*SARNELLI*"
    AND pr.name_first_key="PATRICIA*") OR (((pr.name_last_key="BALDER*"
    AND pr.name_first_key="ANDREW*") OR (((pr.name_last_key="BANDAK*"
    AND pr.name_first_key="TANIA*") OR (((pr.name_last_key="BARNETT*"
    AND pr.name_first_key="MICHELLE*") OR (((pr.name_last_key="BARNETT*"
    AND pr.name_first_key="SCOTT*") OR (((pr.name_last_key="BARRERA*"
    AND pr.name_first_key="NOELLEMARIE*") OR (((pr.name_last_key="BARTLEY*"
    AND pr.name_first_key="MARY*") OR (((pr.name_last_key="BEDFORD*"
    AND pr.name_first_key="JOHN*") OR (((pr.name_last_key="BELL*"
    AND pr.name_first_key="CARRIE*") OR (((pr.name_last_key="BELLANTONIO*"
    AND pr.name_first_key="SANDRA*") OR (((pr.name_last_key="BERGER*"
    AND pr.name_first_key="RONALD*") OR (((pr.name_last_key="BERMAN*"
    AND pr.name_first_key="KIRSTEN*") OR (((pr.name_last_key="BERNSTEIN*"
    AND pr.name_first_key="LAWRENCE*") OR (((pr.name_last_key="BERTHOLD*"
    AND pr.name_first_key="GINA*") OR (((pr.name_last_key="BHATT*"
    AND pr.name_first_key="RITIKA*") OR (((pr.name_last_key="BOOTH*"
    AND pr.name_first_key="GARY*") OR (((pr.name_last_key="BORDER*"
    AND pr.name_first_key="SAMUEL*") OR (((pr.name_last_key="BOSS*"
    AND pr.name_first_key="EUGENE*") OR (((pr.name_last_key="BOST*"
    AND pr.name_first_key="BRIAN*") OR (((pr.name_last_key="BOURQUE*"
    AND pr.name_first_key="MICHAEL*") OR (((pr.name_last_key="BOYLE*"
    AND pr.name_first_key="ELIZABETH*") OR (((pr.name_last_key="BREWER*"
    AND pr.name_first_key="MELODY*") OR (((pr.name_last_key="BROWN*"
    AND pr.name_first_key="CAROLYN*") OR (((pr.name_last_key="BROWNE*"
    AND pr.name_first_key="MD*") OR (((pr.name_last_key="BROWNSTEIN*"
    AND pr.name_first_key="FREDRIC*") OR (((pr.name_last_key="BURKMAN*"
    AND pr.name_first_key="RONALD*") OR (((pr.name_last_key="CAHILL*"
    AND pr.name_first_key="CHARLES*") OR (((pr.name_last_key="CALVANESE*"
    AND pr.name_first_key="ALPHONSE*") OR (((pr.name_last_key="CAMERON*"
    AND pr.name_first_key="SANDRA*") OR (((pr.name_last_key="CANTY*"
    AND pr.name_first_key="LINDA*") OR (((pr.name_last_key="CARTER*"
    AND pr.name_first_key="BETH*") OR (((pr.name_last_key="CASE*"
    AND pr.name_first_key="CHARLENE*") OR (((pr.name_last_key="CASH*"
    AND pr.name_first_key="SUSAN*") OR (((pr.name_last_key="CASTRILLON*"
    AND pr.name_first_key="ANA*") OR (((pr.name_last_key="CAVAGNARO*"
    AND pr.name_first_key="CHARLES*") OR (((pr.name_last_key="CENNERAZZO*"
    AND pr.name_first_key="ALBERT*") OR (((pr.name_last_key="CHALASANI*"
    AND pr.name_first_key="NAGAMALA*") OR (((pr.name_last_key="CHAUHAN*"
    AND pr.name_first_key="KIRANKUMAR*") OR (((pr.name_last_key="CHESKY*"
    AND pr.name_first_key="ALLA*") OR (((pr.name_last_key="CHEUNG*"
    AND pr.name_first_key="SHERI*") OR (((pr.name_last_key="CHOROWSKI*"
    AND pr.name_first_key="MAX*") OR (((pr.name_last_key="CICHON*"
    AND pr.name_first_key="JOANNA*") OR (((pr.name_last_key="COADY*"
    AND pr.name_first_key="GRETCHEN*") OR (((pr.name_last_key="COOK*"
    AND pr.name_first_key="VICTORIA*") OR (((pr.name_last_key="COSSIN*"
    AND pr.name_first_key="JEFFREY*") OR (((pr.name_last_key="COSTA*"
    AND pr.name_first_key="ROBERT*") OR (((pr.name_last_key="COURTEMANCHE*"
    AND pr.name_first_key="ABBIE*") OR (((pr.name_last_key="CROKE*"
    AND pr.name_first_key="FRANCIS*") OR (((pr.name_last_key="CUADRA*"
    AND pr.name_first_key="HUGO*") OR (((pr.name_last_key="CUTLER*"
    AND pr.name_first_key="WILLIAM*") OR (((pr.name_last_key="DALESSANDRO*"
    AND pr.name_first_key="MICHAEL*") OR (((pr.name_last_key="DARDANO*"
    AND pr.name_first_key="KRISTEN*") OR (((pr.name_last_key="DASH*"
    AND pr.name_first_key="CARY*") OR (((pr.name_last_key="DEBENEDETTO*"
    AND pr.name_first_key="DIANE*") OR (((pr.name_last_key="DENHAM*"
    AND pr.name_first_key="LILIBETH*") OR (((pr.name_last_key="DERDERIAN*"
    AND pr.name_first_key="SHERYL*") OR (((pr.name_last_key="DISANDRO*"
    AND pr.name_first_key="DEBRA*") OR (((pr.name_last_key="DONEY*"
    AND pr.name_first_key="THOMAS*") OR (((pr.name_last_key="DORANTES*"
    AND pr.name_first_key="JENNIFER*") OR (((pr.name_last_key="DRENNAN*"
    AND pr.name_first_key="PETER*") OR (((pr.name_last_key="EGELHOFER*"
    AND pr.name_first_key="JOHN*") OR (((pr.name_last_key="EPSTEIN*"
    AND pr.name_first_key="KEVIN*") OR (pr.name_last_key="EWALL*"
    AND pr.name_first_key="KATHERINE*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
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
