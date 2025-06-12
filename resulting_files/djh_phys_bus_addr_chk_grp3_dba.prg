CREATE PROGRAM djh_phys_bus_addr_chk_grp3:dba
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
    AND pr.name_first_key="xxdummy") OR (((pr.name_last_key="MADERO*"
    AND pr.name_first_key="MD*") OR (((pr.name_last_key="MAHONEY*"
    AND pr.name_first_key="KATHLEEN*") OR (((pr.name_last_key="MANCINI*"
    AND pr.name_first_key="CARMELA*") OR (((pr.name_last_key="MARGUGLIO*"
    AND pr.name_first_key="MARIANNA*") OR (((pr.name_last_key="MARTAGON*VILLAMIL*"
    AND pr.name_first_key="JOSE*") OR (((pr.name_last_key="MARTORELL*"
    AND pr.name_first_key="CLAUDIA*") OR (((pr.name_last_key="MASON*"
    AND pr.name_first_key="HOLLY*") OR (((pr.name_last_key="MATIN*"
    AND pr.name_first_key="SHAUKAT*") OR (((pr.name_last_key="MCCRACKEN*"
    AND pr.name_first_key="HELENA*") OR (((pr.name_last_key="MCKAY*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="MEADE*"
    AND pr.name_first_key="KATHLEEN*") OR (((pr.name_last_key="MEADE*"
    AND pr.name_first_key="LAUREN*") OR (((pr.name_last_key="MECKEL*"
    AND pr.name_first_key="MARIE*") OR (((pr.name_last_key="MERCADANTE*"
    AND pr.name_first_key="GINO*") OR (((pr.name_last_key="MERTENS*"
    AND pr.name_first_key="WILSON*") OR (((pr.name_last_key="METZ*"
    AND pr.name_first_key="STEPHEN*") OR (((pr.name_last_key="MIKICH*"
    AND pr.name_first_key="YELENA*") OR (((pr.name_last_key="MILLER*MACK*"
    AND pr.name_first_key="ELLEN*") OR (((pr.name_last_key="MORAN*"
    AND pr.name_first_key="THOMAS*") OR (((pr.name_last_key="MOSKOVITZ*"
    AND pr.name_first_key="HEIDI*") OR (((pr.name_last_key="MUELLNER*"
    AND pr.name_first_key="HANNO*") OR (((pr.name_last_key="MUGFORD*"
    AND pr.name_first_key="JAMES*") OR (((pr.name_last_key="MUGG*"
    AND pr.name_first_key="WILLIAM*") OR (((pr.name_last_key="MUIGAI*"
    AND pr.name_first_key="NGINA*") OR (((pr.name_last_key="MULLAN*"
    AND pr.name_first_key="MARK*") OR (((pr.name_last_key="NAPIER*"
    AND pr.name_first_key="THOMAS*") OR (((pr.name_last_key="NATHAN*"
    AND pr.name_first_key="MARTHA*") OR (((pr.name_last_key="NEERGHEEN*"
    AND pr.name_first_key="CHABILAL*") OR (((pr.name_last_key="NETTEBURG*"
    AND pr.name_first_key="DANAE*") OR (((pr.name_last_key="OLLARI*"
    AND pr.name_first_key="CHRISTOPHER*") OR (((pr.name_last_key="ONEILL*"
    AND pr.name_first_key="DARREN*") OR (((pr.name_last_key="OOI*"
    AND pr.name_first_key="WEI*") OR (((pr.name_last_key="OREILLY*"
    AND pr.name_first_key="MONICA*") OR (((pr.name_last_key="PADDLEFORD*"
    AND pr.name_first_key="BONNIE*") OR (((pr.name_last_key="PAGE*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="PANITCH*"
    AND pr.name_first_key="DEBORAH*") OR (((pr.name_last_key="PARK*"
    AND pr.name_first_key="HYUN-YOUNG*") OR (((pr.name_last_key="PELUSO*"
    AND pr.name_first_key="JOHN*") OR (((pr.name_last_key="PERKS*"
    AND pr.name_first_key="REBEKAH*") OR (((pr.name_last_key="PETERS*"
    AND pr.name_first_key="VICTORIA*") OR (((pr.name_last_key="PETERSON*"
    AND pr.name_first_key="LAUREN*") OR (((pr.name_last_key="PICCHIONI*"
    AND pr.name_first_key="MICHAEL*") OR (((pr.name_last_key="PLUMMER*"
    AND pr.name_first_key="PIXIE*") OR (((pr.name_last_key="POPKIN*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="POWERS*"
    AND pr.name_first_key="ROBIN*") OR (((pr.name_last_key="PRESTIA*"
    AND pr.name_first_key="CLIFFORD*") OR (((pr.name_last_key="PRYOR*"
    AND pr.name_first_key="RUTH*") OR (((pr.name_last_key="PUTNAM*"
    AND pr.name_first_key="ELLEN*") OR (((pr.name_last_key="QAYYUM*"
    AND pr.name_first_key="MOHAMMAD*") OR (((pr.name_last_key="RAMAN*"
    AND pr.name_first_key="T*") OR (((pr.name_last_key="REYNOLDS*"
    AND pr.name_first_key="DAVID*") OR (((pr.name_last_key="ROTHBERG*"
    AND pr.name_first_key="MICHAEL*") OR (((pr.name_last_key="SALAZAR*"
    AND pr.name_first_key="RODRIGO*") OR (((pr.name_last_key="SALVA*OTERO*"
    AND pr.name_first_key="ROBERTO*") OR (((pr.name_last_key="SAMALE*"
    AND pr.name_first_key="JENNIFER*") OR (((pr.name_last_key="SANTOYO*"
    AND pr.name_first_key="MD*") OR (((pr.name_last_key="SCARSELLETTA*"
    AND pr.name_first_key="SARAH*") OR (((pr.name_last_key="SCAVRON*"
    AND pr.name_first_key="JEFFREY*") OR (((pr.name_last_key="SCHMIDT*"
    AND pr.name_first_key="KEVIN*") OR (((pr.name_last_key="SCHOONOVER*"
    AND pr.name_first_key="LINDA*") OR (((pr.name_last_key="SEARS*"
    AND pr.name_first_key="JOHN*") OR (((pr.name_last_key="SEKIGUCHI*"
    AND pr.name_first_key="MAYU*") OR (((pr.name_last_key="SENGHAS*"
    AND pr.name_first_key="ELLEN*") OR (((pr.name_last_key="SHOUSHTARI*"
    AND pr.name_first_key="NILOUFAR*") OR (((pr.name_last_key="SILVERSTEIN*"
    AND pr.name_first_key="SUZY*") OR (((pr.name_last_key="SIMIKIC*"
    AND pr.name_first_key="BILJANA*") OR (((pr.name_last_key="SINGH*"
    AND pr.name_first_key="ARMINDER*") OR (((pr.name_last_key="SINGH*"
    AND pr.name_first_key="GURMAKTESHWAR*") OR (((pr.name_last_key="SINGH*"
    AND pr.name_first_key="MANMEET*") OR (((pr.name_last_key="SIVALINGAM*"
    AND pr.name_first_key="SENTHIL*") OR (((pr.name_last_key="SOLON*"
    AND pr.name_first_key="MICHAEL*") OR (((pr.name_last_key="SORRENTINO*"
    AND pr.name_first_key="JOHN*") OR (((pr.name_last_key="SPENCER*LONG*"
    AND pr.name_first_key="SALLY*") OR (((pr.name_last_key="STATZ*"
    AND pr.name_first_key="INGRID*") OR (((pr.name_last_key="STEINER*"
    AND pr.name_first_key="STEVEN*") OR (((pr.name_last_key="STEPHENS*"
    AND pr.name_first_key="LISA*") OR (((pr.name_last_key="STEWART*"
    AND pr.name_first_key="REBECCA*") OR (((pr.name_last_key="STIRLACCI*"
    AND pr.name_first_key="FRANK*") OR (((pr.name_last_key="THAU*"
    AND pr.name_first_key="WARREN*") OR (((pr.name_last_key="THURMAYR*"
    AND pr.name_first_key="ANNA*") OR (((pr.name_last_key="TIPTON*"
    AND pr.name_first_key="CATHERINE*") OR (((pr.name_last_key="TOOLE*"
    AND pr.name_first_key="BRIAN*") OR (((pr.name_last_key="TORRES*"
    AND pr.name_first_key="ORLANDO*") OR (((pr.name_last_key="TORRES*MUNIZ*"
    AND pr.name_first_key="NORAYMAR*") OR (((pr.name_last_key="TRIETSCH*"
    AND pr.name_first_key="HOWARD*") OR (((pr.name_last_key="VAILLANT*"
    AND pr.name_first_key="ANNE*") OR (((pr.name_last_key="VANDERLINDE*"
    AND pr.name_first_key="SKY*") OR (((pr.name_last_key="VILLANUEVA*"
    AND pr.name_first_key="ALELI*") OR (((pr.name_last_key="VINAGRE*"
    AND pr.name_first_key="JOSE*") OR (((pr.name_last_key="VINCENT*"
    AND pr.name_first_key="DENISE*") OR (((pr.name_last_key="VON*"
    AND pr.name_first_key="MD*") OR (((pr.name_last_key="WANG*"
    AND pr.name_first_key="JAMES*") OR (((pr.name_last_key="WARNER*"
    AND pr.name_first_key="RICHARD*") OR (((pr.name_last_key="WEBER*"
    AND pr.name_first_key="BRITTANY*") OR (((pr.name_last_key="WESTON*"
    AND pr.name_first_key="CHARLES*") OR (((pr.name_last_key="WICZYK*"
    AND pr.name_first_key="HALINA*") OR (((pr.name_last_key="WILLIAMSON*"
    AND pr.name_first_key="KATHERINE*") OR (((pr.name_last_key="WOOL*"
    AND pr.name_first_key="ROBERT*") OR (((pr.name_last_key="WYCHOWSKI*"
    AND pr.name_first_key="ADAM*") OR (pr.name_last_key="ZACHARIAH*"
    AND pr.name_first_key="REENA*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
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
