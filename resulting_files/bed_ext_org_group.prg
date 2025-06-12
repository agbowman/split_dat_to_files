CREATE PROGRAM bed_ext_org_group
 RECORD orggroups(
   1 orggroup[*]
     2 org_set_id = vc
     2 name = vc
     2 orglist[*]
       3 orgid = vc
       3 orgname = vc
 )
 SET ogcnt = 0
 SET orgcnt = 0
 SET filename = "bed_ext_org_group.csv"
 SELECT INTO "nl:"
  FROM org_set os
  PLAN (os
   WHERE os.active_ind=1)
  DETAIL
   ogcnt = (ogcnt+ 1), stat = alterlist(orggroups->orggroup,ogcnt), orggroups->orggroup[ogcnt].
   org_set_id = cnvtstring(os.org_set_id),
   orggroups->orggroup[ogcnt].name = os.name
  WITH nocounter
 ;end select
 FOR (i = 1 TO ogcnt)
   SELECT INTO "nl:"
    FROM org_set_org_r osor,
     organization o
    PLAN (osor
     WHERE osor.org_set_id=cnvtreal(orggroups->orggroup[i].org_set_id))
     JOIN (o
     WHERE o.organization_id=osor.organization_id)
    HEAD REPORT
     orgcnt = 0
    DETAIL
     orgcnt = (orgcnt+ 1), stat = alterlist(orggroups->orggroup[i].orglist,orgcnt), orggroups->
     orggroup[i].orglist[orgcnt].orgid = cnvtstring(o.organization_id),
     orggroups->orggroup[i].orglist[orgcnt].orgname = o.org_name
    WITH nocounter
   ;end select
 ENDFOR
 SET ondx = size(orggroups->orggroup,5)
 SELECT INTO value(filename)
  ondx = ondx
  HEAD REPORT
   col 0, "org_group_id", ",",
   "org_group_name", ",", "org_id",
   ",", "org_name"
  DETAIL
   FOR (i = 1 TO ondx)
     osize = size(orggroups->orggroup[i].orglist,5), row + 1, col 0,
     orggroups->orggroup[i].org_set_id, ",", '"',
     orggroups->orggroup[i].name, '"', ","
     IF (osize > 0)
      orggroups->orggroup[i].orglist[1].orgid, ",", '"',
      orggroups->orggroup[i].orglist[1].orgname, '"', ","
     ELSE
      ",,"
     ENDIF
     IF (osize > 1)
      FOR (j = 2 TO osize)
        row + 1, ",,", orggroups->orggroup[i].orglist[j].orgid,
        ",", '"', orggroups->orggroup[i].orglist[j].orgname,
        '"', ","
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter, format = variable, noformfeed,
   maxcol = 5000
 ;end select
END GO
