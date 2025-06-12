CREATE PROGRAM bhs_prax_followup_org
 DECLARE o_org_class_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",396,"FREETEXT"))
 DECLARE o_data_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",8,"AUTHVERIFIED")
  )
 DECLARE otr_org_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",278,
   "FOLLOWUPFACILITY"))
 SELECT DISTINCT INTO  $1
  o.organization_id, o_org_name = trim(replace(replace(replace(replace(replace(o.org_name,"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM organization o,
   org_type_reltn otr
  PLAN (o
   WHERE o.organization_id > 0
    AND o.active_ind=1
    AND o.org_class_cd != o_org_class_cd
    AND o.data_status_cd=o_data_status_cd
    AND o.beg_effective_dt_tm < sysdate
    AND o.end_effective_dt_tm > sysdate)
   JOIN (otr
   WHERE otr.organization_id=o.organization_id
    AND otr.active_ind=1
    AND otr.org_type_cd=otr_org_type_cd)
  ORDER BY o.org_name
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>"
  HEAD o.organization_id
   col + 1, "<Organization>", row + 1,
   org_id = build("<OrganizationId>",cnvtint(o.organization_id),"</OrganizationId>"), col + 1, org_id,
   row + 1, org_name = build("<OrganizationName>",o_org_name,"</OrganizationName>"), col + 1,
   org_name, row + 1, col + 1,
   "</Organization>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, fromfeed = none, format = variable,
   time = 30
 ;end select
END GO
