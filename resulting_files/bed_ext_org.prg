CREATE PROGRAM bed_ext_org
 RECORD orgs(
   1 org[*]
     2 org_id = f8
     2 name = vc
     2 shortname = vc
     2 taxid = vc
     2 typelist[*]
       3 orgtype = vc
     2 loclist[*]
       3 loctype = vc
       3 locname = vc
       3 locshortname = vc
     2 address1 = vc
     2 address2 = vc
     2 city = vc
     2 state = vc
     2 county = vc
     2 zip = vc
     2 country = vc
     2 phone = vc
 )
 DECLARE fac_cd = f8
 DECLARE org_facilty_cd = f8
 DECLARE unit_cd = f8
 DECLARE amb_cd = f8
 SET fac_cd = 0.0
 SET unit_cd = 0.0
 SET amb_cd = 0.0
 SET org_facility_cd = 0.0
 SET loccnt = 0
 SET orgcnt = 0
 SET filename = "bed_ext_org.csv"
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.cdf_meaning="FACILITY"
    AND c.code_set=222)
  DETAIL
   fac_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.cdf_meaning="AMBULATORY"
    AND c.code_set=222)
  DETAIL
   amb_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.cdf_meaning="NURSEUNIT"
    AND c.code_set=222)
  DETAIL
   unit_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.cdf_meaning="FACILITY"
    AND c.code_set=278)
  DETAIL
   org_facility_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM organization o,
   org_type_reltn otr,
   address a,
   location l,
   code_value cv,
   phone ph,
   dummyt d1,
   dummyt d2
  PLAN (o
   WHERE o.active_ind=1)
   JOIN (otr
   WHERE o.organization_id=otr.organization_id
    AND otr.org_type_cd=org_facility_cd)
   JOIN (l
   WHERE l.organization_id=o.organization_id
    AND l.location_type_cd=fac_cd)
   JOIN (cv
   WHERE cv.code_value=l.location_cd)
   JOIN (d1)
   JOIN (a
   WHERE o.organization_id=a.parent_entity_id
    AND a.parent_entity_name="ORGANIZATION")
   JOIN (d2)
   JOIN (ph
   WHERE o.organization_id=ph.parent_entity_id
    AND ph.parent_entity_name="ORGANIZATION")
  DETAIL
   orgcnt = (orgcnt+ 1), stat = alterlist(orgs->org,orgcnt), orgs->org[orgcnt].org_id = o
   .organization_id,
   orgs->org[orgcnt].taxid = nullterm(trim(o.federal_tax_id_nbr)), orgs->org[orgcnt].name = nullterm(
    trim(o.org_name)), orgs->org[orgcnt].shortname = nullterm(trim(cv.display)),
   orgs->org[orgcnt].address1 = nullterm(trim(a.street_addr)), orgs->org[orgcnt].address2 = nullterm(
    trim(a.street_addr2)), orgs->org[orgcnt].city = nullterm(trim(a.city)),
   orgs->org[orgcnt].state = nullterm(trim(a.state)), orgs->org[orgcnt].county = nullterm(trim(a
     .county)), orgs->org[orgcnt].zip = nullterm(trim(a.zipcode)),
   orgs->org[orgcnt].country = nullterm(trim(a.country)), orgs->org[orgcnt].phone = nullterm(trim(ph
     .phone_num))
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 FOR (i = 1 TO orgcnt)
   SELECT INTO "nl:"
    FROM location l,
     code_value cv,
     code_value cv2
    PLAN (l
     WHERE (l.organization_id=orgs->org[i].org_id))
     JOIN (cv
     WHERE cv.code_value=l.location_type_cd
      AND ((cv.code_value=amb_cd) OR (cv.code_value=unit_cd))
      AND cv.code_set=222)
     JOIN (cv2
     WHERE cv2.code_value=l.location_cd
      AND cv2.code_set=220)
    HEAD REPORT
     loccnt = 0
    DETAIL
     loccnt = (loccnt+ 1), stat = alterlist(orgs->org[i].loclist,loccnt), orgs->org[i].loclist[loccnt
     ].locname = cv2.description,
     orgs->org[i].loclist[loccnt].locshortname = cv2.display
     IF (cv.code_value=amb_cd)
      orgs->org[i].loclist[loccnt].loctype = "Office/Clinic"
     ELSE
      orgs->org[i].loclist[loccnt].loctype = "Acute Care"
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET ondx = size(orgs->org,5)
 SELECT INTO value(filename)
  ondx = ondx
  HEAD REPORT
   col 0, "tax_id", ",",
   "org_name", ",", "org_short",
   ",", "time_zone", ",",
   "loc_type", ",", "location_name",
   ",", "loc_short", ",",
   "address1", ",", "address2",
   ",", "city", ",",
   "state", ",", "County",
   ",", "zip", ",",
   "country", ",", "phone"
  DETAIL
   FOR (i = 1 TO ondx)
     otsize = size(orgs->org[i].typelist,5), locsize = size(orgs->org[i].loclist,5), row + 1,
     col 0, '"', orgs->org[i].taxid,
     '"', ",", '"',
     orgs->org[i].name, '"', ",",
     '"', orgs->org[i].shortname, '"',
     ",", ","
     IF (locsize > 0)
      '"', orgs->org[i].loclist[1].loctype, '"',
      ",", '"', orgs->org[i].loclist[1].locname,
      '"', ","
     ELSE
      ",,"
     ENDIF
     '"', orgs->org[i].loclist[1].locshortname, '"',
     ",", '"', orgs->org[i].address1,
     '"', ",", '"',
     orgs->org[i].address2, '"', ",",
     '"', orgs->org[i].city, '"',
     ",", '"', orgs->org[i].state,
     '"', ",", '"',
     orgs->org[i].county, '"', ",",
     '"', orgs->org[i].zip, '"',
     ",", '"', orgs->org[i].country,
     '"', ",", '"',
     orgs->org[i].phone, '"'
     IF (locsize > 1)
      FOR (j = 2 TO locsize)
        row + 1, ",,,,", '"',
        orgs->org[i].loclist[j].loctype, '"', ",",
        '"', orgs->org[i].loclist[j].locname, '"',
        ",", '"', orgs->org[i].loclist[j].locshortname,
        '"', ",", ",,,,,,,"
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter, format = variable, noformfeed,
   maxcol = 5000
 ;end select
END GO
