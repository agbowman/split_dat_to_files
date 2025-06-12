CREATE PROGRAM bed_ext_orgloc
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
       3 parent = vc
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
 SET filename = "bed_ext_orgloc.csv"
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
   location l,
   code_value cv
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
  DETAIL
   orgcnt = (orgcnt+ 1), stat = alterlist(orgs->org,orgcnt), orgs->org[orgcnt].org_id = o
   .organization_id,
   orgs->org[orgcnt].taxid = nullterm(trim(o.federal_tax_id_nbr)), orgs->org[orgcnt].name = nullterm(
    trim(o.org_name)), orgs->org[orgcnt].shortname = nullterm(trim(cv.display))
  WITH nocounter
 ;end select
 FOR (i = 1 TO orgcnt)
   SELECT INTO "nl:"
    FROM location l,
     code_value cv,
     code_value cv2,
     location_group lg,
     code_value cv3
    PLAN (l
     WHERE (l.organization_id=orgs->org[i].org_id))
     JOIN (cv
     WHERE cv.code_value=l.location_type_cd
      AND cv.code_set=222)
     JOIN (cv2
     WHERE cv2.code_value=l.location_cd
      AND cv2.code_set=220)
     JOIN (lg
     WHERE l.location_cd=lg.child_loc_cd)
     JOIN (cv3
     WHERE lg.parent_loc_cd=cv3.code_value)
    HEAD REPORT
     loccnt = 0
    HEAD l.location_cd
     loccnt = loccnt
    DETAIL
     loccnt = (loccnt+ 1), stat = alterlist(orgs->org[i].loclist,loccnt), orgs->org[i].loclist[loccnt
     ].locname = cv2.description,
     orgs->org[i].loclist[loccnt].locshortname = cv2.display
     IF (cv.code_value=amb_cd)
      orgs->org[i].loclist[loccnt].loctype = "Office/Clinic"
     ELSEIF (cv.code_value=unit_cd)
      orgs->org[i].loclist[loccnt].loctype = "Acute Care"
     ELSE
      orgs->org[i].loclist[loccnt].loctype = cv.display
     ENDIF
     orgs->org[i].loclist[loccnt].parent = cv3.display
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
   "parent", ",", "loc_type",
   ",", "location_name", ",",
   "loc_short"
   FOR (i = 1 TO ondx)
     otsize = size(orgs->org[i].typelist,5), locsize = size(orgs->org[i].loclist,5), row + 1,
     col 0, '"', orgs->org[i].taxid,
     '"', ",", '"',
     orgs->org[i].name, '"', ",",
     '"', orgs->org[i].shortname, '"',
     ",", ","
     IF (locsize > 0)
      '"', orgs->org[i].loclist[1].parent, '"',
      ",", '"', orgs->org[i].loclist[1].loctype,
      '"', ",", '"',
      orgs->org[i].loclist[1].locname, '"', ",",
      '"', orgs->org[i].loclist[1].locshortname, '"',
      ","
     ELSE
      ",,,,"
     ENDIF
     IF (locsize > 1)
      FOR (j = 2 TO locsize)
        row + 1, ",,,,", '"',
        orgs->org[i].loclist[j].parent, '"', ",",
        '"', orgs->org[i].loclist[j].loctype, '"',
        ",", '"', orgs->org[i].loclist[j].locname,
        '"', ",", '"',
        orgs->org[i].loclist[j].locshortname, '"', ","
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter, format = variable, noformfeed,
   maxcol = 5000
 ;end select
END GO
