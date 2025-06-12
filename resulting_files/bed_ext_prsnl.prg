CREATE PROGRAM bed_ext_prsnl
 RECORD prec(
   1 prsnl[*]
     2 person_id = f8
     2 first = vc
     2 middle = vc
     2 last = vc
     2 title = vc
     2 suffix = vc
     2 extid = vc
     2 username = vc
     2 position = vc
     2 physician_ind = vc
     2 active_ind = vc
     2 dob = vc
     2 sex = vc
     2 oglist[*]
       3 ogname = vc
     2 orglist[*]
       3 org_alias = vc
       3 org_alpool = vc
     2 cmrn = vc
     2 dea = vc
     2 upin = vc
     2 ssn = vc
     2 addlist[*]
       3 line1 = vc
       3 line2 = vc
       3 line3 = vc
       3 line4 = vc
       3 type = vc
       3 city = vc
       3 state = vc
       3 county = vc
       3 zip = vc
       3 country = vc
       3 contact = vc
       3 comments = vc
     2 pholist[*]
       3 type = vc
       3 number = vc
       3 format = vc
       3 extension = vc
       3 desc = vc
       3 contact = vc
       3 insx = vc
 )
 DECLARE extid_cd = f8
 DECLARE cdoc_cd = f8
 DECLARE dea_cd = f8
 DECLARE upin_cd = f8
 DECLARE ssn_cd = f8
 SET extid = 0.0
 SET cdoc_cd = 0.0
 SET dea_cd = 0.0
 SET upin_cd = 0.0
 SET ssn_cd = 0.0
 SET pcnt = 0
 SET ogcnt = 0
 SET orgcnt = 0
 SET acnt = 0
 SET phcnt = 0
 SET filename = "bed_ext_prsnl.csv"
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=4
   AND c.cdf_meaning="SSN"
  DETAIL
   ssn_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=320
   AND c.cdf_meaning="EXTERNALID"
  DETAIL
   extid_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=320
   AND c.cdf_meaning="DOCDEA"
  DETAIL
   dea_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=320
   AND c.cdf_meaning="DOCCNBR"
  DETAIL
   cdoc_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=320
   AND c.cdf_meaning="DOCUPIN"
  DETAIL
   upin_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM prsnl p,
   person pr,
   prsnl_alias pa1,
   prsnl_alias pa2,
   prsnl_alias pa3,
   prsnl_alias pa4,
   person_name pn,
   person_alias pra,
   code_value cv1,
   code_value cv2,
   dummyt d,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4,
   dummyt d5,
   dummyt d6,
   dummyt d7,
   dummyt d8,
   dummyt d9
  PLAN (p)
   JOIN (d)
   JOIN (cv1
   WHERE p.position_cd=cv1.code_value
    AND cv1.code_set=88)
   JOIN (d1)
   JOIN (pa1
   WHERE p.person_id=pa1.person_id
    AND pa1.prsnl_alias_type_cd=upin_cd)
   JOIN (d2)
   JOIN (pa2
   WHERE p.person_id=pa2.person_id
    AND pa2.prsnl_alias_type_cd=dea_cd)
   JOIN (d3)
   JOIN (pa3
   WHERE p.person_id=pa3.person_id
    AND pa3.prsnl_alias_type_cd=cdoc_cd)
   JOIN (d4)
   JOIN (pa4
   WHERE p.person_id=pa4.person_id
    AND pa4.prsnl_alias_type_cd=extid_cd)
   JOIN (d5)
   JOIN (pra
   WHERE p.person_id=pra.person_id
    AND pra.person_alias_type_cd=ssn_cd)
   JOIN (d6)
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d7)
   JOIN (pr
   WHERE p.person_id=pr.person_id)
   JOIN (d8)
   JOIN (cv2
   WHERE pr.sex_cd=cv2.code_value)
   JOIN (d9)
  ORDER BY p.person_id
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(prec->prsnl,pcnt), prec->prsnl[pcnt].person_id = p.person_id
   IF (p.active_ind=1)
    prec->prsnl[pcnt].active_ind = "Yes"
   ELSE
    prec->prsnl[pcnt].active_ind = "No"
   ENDIF
   prec->prsnl[pcnt].first = trim(p.name_first), prec->prsnl[pcnt].last = trim(p.name_last), prec->
   prsnl[pcnt].middle = trim(pn.name_middle),
   prec->prsnl[pcnt].cmrn = trim(pa3.alias), prec->prsnl[pcnt].dea = trim(pa2.alias), prec->prsnl[
   pcnt].dob = " ",
   prec->prsnl[pcnt].extid = trim(pa4.alias)
   IF (p.physician_ind=1)
    prec->prsnl[pcnt].physician_ind = "Yes"
   ELSE
    prec->prsnl[pcnt].physician_ind = "No"
   ENDIF
   prec->prsnl[pcnt].position = trim(cv1.display), prec->prsnl[pcnt].sex = trim(cv2.display), prec->
   prsnl[pcnt].ssn = trim(pra.alias),
   prec->prsnl[pcnt].suffix = trim(pn.name_suffix), prec->prsnl[pcnt].title = trim(pn.name_title),
   prec->prsnl[pcnt].upin = trim(pa1.alias),
   prec->prsnl[pcnt].username = trim(p.username)
  WITH nocounter, dontcare = cv1, dontcare = pa1,
   dontcare = pa2, dontcare = pa3, dontcare = pa4,
   dontcare = pra, dontcare = cv2, dontcare = pn
 ;end select
 FOR (i = 1 TO pcnt)
   SELECT INTO "nl:"
    FROM address a,
     code_value cv
    PLAN (a
     WHERE a.parent_entity_name="PERSON"
      AND (a.parent_entity_id=prec->prsnl[i].person_id))
     JOIN (cv
     WHERE a.address_type_cd=cv.code_value
      AND cv.code_set=212)
    HEAD REPORT
     acnt = 0
    DETAIL
     acnt = (acnt+ 1), stat = alterlist(prec->prsnl[i].addlist,acnt), prec->prsnl[i].addlist[acnt].
     line1 = trim(a.street_addr),
     prec->prsnl[i].addlist[acnt].line2 = trim(a.street_addr2), prec->prsnl[i].addlist[acnt].line3 =
     trim(a.street_addr3), prec->prsnl[i].addlist[acnt].line4 = trim(a.street_addr4),
     prec->prsnl[i].addlist[acnt].city = trim(a.city), prec->prsnl[i].addlist[acnt].comments = trim(a
      .comment_txt), prec->prsnl[i].addlist[acnt].contact = trim(a.contact_name),
     prec->prsnl[i].addlist[acnt].country = trim(a.country), prec->prsnl[i].addlist[acnt].county =
     trim(a.county), prec->prsnl[i].addlist[acnt].state = trim(a.state),
     prec->prsnl[i].addlist[acnt].type = trim(cv.display), prec->prsnl[i].addlist[acnt].zip = trim(a
      .zipcode)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM phone ph,
     code_value cv,
     code_value cv2,
     dummyt d1
    PLAN (ph
     WHERE ph.parent_entity_name="PERSON"
      AND (ph.parent_entity_id=prec->prsnl[i].person_id)
      AND ph.phone_num > " ")
     JOIN (cv
     WHERE ph.phone_type_cd=cv.code_value
      AND cv.code_set=43)
     JOIN (d1)
     JOIN (cv2
     WHERE ph.phone_format_cd=cv2.code_value
      AND cv2.code_set=281)
    HEAD REPORT
     phcnt = 0
    DETAIL
     phcnt = (phcnt+ 1), stat = alterlist(prec->prsnl[i].pholist,phcnt), prec->prsnl[i].pholist[phcnt
     ].contact = trim(ph.contact),
     prec->prsnl[i].pholist[phcnt].desc = trim(ph.description), prec->prsnl[i].pholist[phcnt].
     extension = trim(ph.extension), prec->prsnl[i].pholist[phcnt].insx = trim(ph.call_instruction),
     prec->prsnl[i].pholist[phcnt].number = trim(ph.phone_num), prec->prsnl[i].pholist[phcnt].type =
     trim(cv.display), prec->prsnl[i].pholist[phcnt].format = trim(cv2.display)
    WITH nocounter, outerjoin = d1
   ;end select
   SELECT INTO "nl:"
    FROM org_set_prsnl_r ospr,
     org_set os
    PLAN (ospr
     WHERE (ospr.prsnl_id=prec->prsnl[i].person_id)
      AND ospr.active_ind=1)
     JOIN (os
     WHERE ospr.org_set_id=os.org_set_id)
    HEAD REPORT
     ogcnt = 0
    DETAIL
     ogcnt = (ogcnt+ 1), stat = alterlist(prec->prsnl[i].oglist,ogcnt), prec->prsnl[i].oglist[ogcnt].
     ogname = trim(os.name)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM prsnl_alias pa,
     code_value cv
    PLAN (pa
     WHERE (pa.person_id=prec->prsnl[i].person_id)
      AND  NOT (pa.prsnl_alias_type_cd IN (extid_cd, dea_cd, upin_cd, cdoc_cd)))
     JOIN (cv
     WHERE pa.alias_pool_cd=cv.code_value
      AND cv.code_set=263)
    HEAD REPORT
     orgcnt = 0
    DETAIL
     orgcnt = (orgcnt+ 1), stat = alterlist(prec->prsnl[i].orglist,orgcnt), prec->prsnl[i].orglist[
     orgcnt].org_alias = trim(pa.alias),
     prec->prsnl[i].orglist[orgcnt].org_alpool = trim(cv.display)
    WITH nocounter
   ;end select
 ENDFOR
 SET pndx = size(prec->prsnl,5)
 SELECT INTO value(filename)
  pndx = pndx
  HEAD REPORT
   col 0, "first_name", ",",
   "middle_name", ",", "last_name",
   ",", "title", ",",
   "Suffix", ",", "external_ID",
   ",", "username", ",",
   "Position", ",", "physician_ind",
   ",", "active_ind", ",",
   "Birthdate", ",", "Sex",
   ",", "org_group", ",",
   "org_id", ",", "org_alias_pool",
   ",", "comm_prov_nbr", ",",
   "dea_nbr", ",", "upin",
   ",", "ssn", ",",
   "address_type", ",", "street1",
   ",", "street2", ",",
   "street3", ",", "street4",
   ",", "City", ",",
   "State", ",", "County",
   ",", "zipcode", ",",
   "Country", ",", "contact_name",
   ",", "address_comments", ",",
   "phone_type", ",", "phone_nbr",
   ",", "phone_format", ",",
   "phone_ext", ",", "phone_desc",
   ",", "phone_contact", ",",
   "phone_inst"
  DETAIL
   FOR (i = 1 TO pndx)
     ogsize = size(prec->prsnl[i].oglist,5), biggest = ogsize, orgsize = size(prec->prsnl[i].orglist,
      5),
     addsize = size(prec->prsnl[i].addlist,5), phosize = size(prec->prsnl[i].pholist,5)
     IF (orgsize > biggest)
      biggest = orgsize
     ENDIF
     IF (addsize > biggest)
      biggest = addsize
     ENDIF
     IF (phosize > biggest)
      biggest = phosize
     ENDIF
     row + 1, col 0, '"',
     prec->prsnl[i].first, '"', ",",
     '"', prec->prsnl[i].middle, '"',
     ",", '"', prec->prsnl[i].last,
     '"', ",", '"',
     prec->prsnl[i].title, '"', ",",
     '"', prec->prsnl[i].suffix, '"',
     ",", prec->prsnl[i].extid, ",",
     prec->prsnl[i].username, ",", prec->prsnl[i].position,
     ",", prec->prsnl[i].physician_ind, ",",
     prec->prsnl[i].active_ind, ",", prec->prsnl[i].dob,
     ",", prec->prsnl[i].sex, ","
     IF (ogsize > 0)
      '"', prec->prsnl[i].oglist[1].ogname, '"',
      ","
     ELSE
      ","
     ENDIF
     IF (orgsize > 0)
      '"', prec->prsnl[i].orglist[1].org_alias, '"',
      ",", '"', prec->prsnl[i].orglist[1].org_alpool,
      '"', ","
     ELSE
      ",,"
     ENDIF
     prec->prsnl[i].cmrn, ",", prec->prsnl[i].dea,
     ",", prec->prsnl[i].upin, ",",
     prec->prsnl[i].ssn, ","
     IF (addsize > 0)
      prec->prsnl[i].addlist[1].type, ",", '"',
      prec->prsnl[i].addlist[1].line1, '"', ",",
      '"', prec->prsnl[i].addlist[1].line2, '"',
      ",", '"', prec->prsnl[i].addlist[1].line3,
      '"', ",", '"',
      prec->prsnl[i].addlist[1].line4, '"', ",",
      '"', prec->prsnl[i].addlist[1].city, '"',
      ",", '"', prec->prsnl[i].addlist[1].state,
      '"', ",", '"',
      prec->prsnl[i].addlist[1].county, '"', ",",
      prec->prsnl[i].addlist[1].zip, ",", '"',
      prec->prsnl[i].addlist[1].country, '"', ",",
      '"', prec->prsnl[i].addlist[1].contact, '"',
      ",", '"', prec->prsnl[i].addlist[1].comments,
      '"', ","
     ELSE
      ",,,,,,,,,,,,"
     ENDIF
     IF (phosize > 0)
      prec->prsnl[i].pholist[1].type, ",", prec->prsnl[i].pholist[1].number,
      ",", prec->prsnl[i].pholist[1].format, ",",
      '"', prec->prsnl[i].pholist[1].extension, '"',
      ",", '"', prec->prsnl[i].pholist[1].desc,
      '"', ",", '"',
      prec->prsnl[i].pholist[1].contact, '"', ",",
      '"', prec->prsnl[i].pholist[1].insx, '"'
     ELSE
      ",,,,,,"
     ENDIF
     IF (biggest > 1)
      FOR (j = 2 TO biggest)
        row + 1, ",,,,,,,,,,,,"
        IF (ogsize >= j)
         '"', prec->prsnl[i].oglist[j].ogname, '"',
         ","
        ELSE
         ","
        ENDIF
        IF (orgsize >= j)
         prec->prsnl[i].orglist[j].org_alias, ",", prec->prsnl[i].orglist[j].org_alpool,
         ","
        ELSE
         ",,"
        ENDIF
        ",,,,"
        IF (addsize >= j)
         prec->prsnl[i].addlist[j].type, ",", '"',
         prec->prsnl[i].addlist[j].line1, '"', ",",
         '"', prec->prsnl[i].addlist[j].line2, '"',
         ",", '"', prec->prsnl[i].addlist[j].line3,
         '"', ",", '"',
         prec->prsnl[i].addlist[j].line4, '"', ",",
         '"', prec->prsnl[i].addlist[j].city, '"',
         ",", prec->prsnl[i].addlist[j].state, ",",
         prec->prsnl[i].addlist[j].county, ",", prec->prsnl[i].addlist[j].zip,
         ",", '"', prec->prsnl[i].addlist[j].country,
         '"', ",", '"',
         prec->prsnl[i].addlist[j].contact, '"', ",",
         '"', prec->prsnl[i].addlist[j].comments, '"',
         ","
        ELSE
         ",,,,,,,,,,,,"
        ENDIF
        IF (phosize >= j)
         prec->prsnl[i].pholist[j].type, ",", prec->prsnl[i].pholist[j].number,
         ",", prec->prsnl[i].pholist[j].format, ",",
         '"', prec->prsnl[i].pholist[j].extension, '"',
         ",", '"', prec->prsnl[i].pholist[j].desc,
         '"', ",", '"',
         prec->prsnl[i].pholist[j].contact, '"', ",",
         '"', prec->prsnl[i].pholist[j].insx, '"'
        ELSE
         ",,,,,,"
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter, format = variable, noformfeed,
   maxcol = 5000
 ;end select
END GO
