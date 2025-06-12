CREATE PROGRAM bed_ext_all_orgs
 RECORD orgs(
   1 org[*]
     2 org_id = f8
     2 name = vc
     2 shortname = vc
     2 taxid = vc
     2 typelist[*]
       3 orgtype = vc
     2 address1 = vc
     2 address2 = vc
     2 city = vc
     2 state = vc
     2 county = vc
     2 zip = vc
     2 country = vc
     2 phone = vc
 )
 SET otcnt = 0
 SET orgcnt = 0
 SET filename = "bed_ext_all_orgs.csv"
 SELECT INTO "nl:"
  FROM organization o,
   address a,
   phone ph,
   dummyt d1,
   dummyt d2
  PLAN (o
   WHERE o.active_ind=1)
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
    trim(o.org_name)), orgs->org[orgcnt].address1 = nullterm(trim(a.street_addr)),
   orgs->org[orgcnt].address2 = nullterm(trim(a.street_addr2)), orgs->org[orgcnt].city = nullterm(
    trim(a.city)), orgs->org[orgcnt].state = nullterm(trim(a.state)),
   orgs->org[orgcnt].county = nullterm(trim(a.county)), orgs->org[orgcnt].zip = nullterm(trim(a
     .zipcode)), orgs->org[orgcnt].country = nullterm(trim(a.country)),
   orgs->org[orgcnt].phone = nullterm(trim(ph.phone_num))
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 FOR (i = 1 TO orgcnt)
   SELECT INTO "nl:"
    FROM org_type_reltn otr,
     code_value cv
    PLAN (otr
     WHERE (otr.organization_id=orgs->org[i].org_id))
     JOIN (cv
     WHERE cv.code_value=otr.org_type_cd)
    HEAD REPORT
     otcnt = 0
    DETAIL
     otcnt = (otcnt+ 1), stat = alterlist(orgs->org[i].typelist,otcnt), orgs->org[i].typelist[otcnt].
     orgtype = cv.display
    WITH nocounter
   ;end select
 ENDFOR
 SET ondx = size(orgs->org,5)
 SELECT INTO value(filename)
  ondx = ondx
  HEAD REPORT
   col 0, "tax_id", ",",
   "org_name", ",", "type",
   ",", "address1", ",",
   "address2", ",", "city",
   ",", "state", ",",
   "County", ",", "zip",
   ",", "country", ",",
   "phone"
  DETAIL
   FOR (i = 1 TO ondx)
     otsize = size(orgs->org[i].typelist,5), row + 1, col 0,
     '"', orgs->org[i].taxid, '"',
     ",", '"', orgs->org[i].name,
     '"', ",", '"',
     orgs->org[i].typelist[1].orgtype, '"', ",",
     '"', orgs->org[i].address1, '"',
     ",", '"', orgs->org[i].address2,
     '"', ",", '"',
     orgs->org[i].city, '"', ",",
     '"', orgs->org[i].state, '"',
     ",", '"', orgs->org[i].county,
     '"', ",", '"',
     orgs->org[i].zip, '"', ",",
     '"', orgs->org[i].country, '"',
     ",", '"', orgs->org[i].phone,
     '"'
     IF (otsize > 1)
      FOR (j = 2 TO otsize)
        row + 1, ",,", '"',
        orgs->org[i].typelist[j].orgtype, '"', ",,,,,,,,"
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter, format = variable, noformfeed,
   maxcol = 5000
 ;end select
END GO
