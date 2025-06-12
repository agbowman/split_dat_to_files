CREATE PROGRAM bed_exp_ins_emp
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET org
 RECORD org(
   1 org[*]
     2 organization_id = f8
     2 name = vc
     2 type = vc
     2 address_cnt = i4
     2 phone_cnt = i4
     2 alias_cnt = i4
     2 address[*]
       3 address_type = vc
       3 street_addr = vc
       3 street_addr2 = vc
       3 city = vc
       3 state = vc
       3 zip = vc
       3 country = vc
     2 phone[*]
       3 phone_type = vc
       3 phone_num = vc
     2 alias[*]
       3 alias_pool = vc
       3 alias = vc
 )
 FREE SET output
 RECORD output(
   1 line[*]
     2 linestr = vc
 )
#1000_initialize
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 SET log_name = "ccluserdir:bed_exp_ins_emp.csv"
 SET ins_cd = get_code_value(278,"INSCO")
 SET emp_cd = get_code_value(278,"EMPLOYER")
 SET auth_cd = get_code_value(8,"AUTH")
 SET org_cnt = 0
 SELECT INTO "NL:"
  FROM organization o,
   org_type_reltn otr,
   code_value c1,
   code_value c2
  PLAN (otr
   WHERE otr.org_type_cd IN (ins_cd, emp_cd)
    AND otr.active_ind=1)
   JOIN (c1
   WHERE c1.code_value=ins_cd)
   JOIN (c2
   WHERE c2.code_value=emp_cd)
   JOIN (o
   WHERE otr.organization_id=o.organization_id
    AND o.active_ind=1
    AND o.data_status_cd=auth_cd
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY o.organization_id
  HEAD o.organization_id
   org_cnt = (org_cnt+ 1), stat = alterlist(org->org,org_cnt), org->org[org_cnt].organization_id = o
   .organization_id,
   org->org[org_cnt].name = o.org_name
  DETAIL
   IF (otr.org_type_cd=ins_cd)
    IF ((org->org[org_cnt].type=""))
     org->org[org_cnt].type = c1.display
    ELSE
     org->org[org_cnt].type = "Both"
    ENDIF
   ELSE
    IF ((org->org[org_cnt].type=""))
     org->org[org_cnt].type = c2.display
    ELSE
     org->org[org_cnt].type = "Both"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM organization o,
   address a,
   code_value c,
   (dummyt d  WITH seq = org_cnt)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].organization_id))
   JOIN (a
   WHERE a.parent_entity_id=o.organization_id
    AND a.parent_entity_name="ORGANIZATION"
    AND a.active_ind=1)
   JOIN (c
   WHERE c.code_value=a.address_type_cd)
  ORDER BY a.address_id
  HEAD a.address_id
   org->org[d.seq].address_cnt = (org->org[d.seq].address_cnt+ 1), stat = alterlist(org->org[d.seq].
    address,org->org[d.seq].address_cnt)
  DETAIL
   org->org[d.seq].address[org->org[d.seq].address_cnt].address_type = c.display, org->org[d.seq].
   address[org->org[d.seq].address_cnt].street_addr = a.street_addr, org->org[d.seq].address[org->
   org[d.seq].address_cnt].street_addr2 = a.street_addr2,
   org->org[d.seq].address[org->org[d.seq].address_cnt].city = a.city, org->org[d.seq].address[org->
   org[d.seq].address_cnt].state = a.state, org->org[d.seq].address[org->org[d.seq].address_cnt].zip
    = a.zipcode,
   org->org[d.seq].address[org->org[d.seq].address_cnt].country = a.country
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM organization o,
   phone p,
   code_value c,
   (dummyt d  WITH seq = org_cnt)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].organization_id))
   JOIN (p
   WHERE p.parent_entity_id=o.organization_id
    AND p.parent_entity_name="ORGANIZATION"
    AND p.active_ind=1)
   JOIN (c
   WHERE c.code_value=p.phone_type_cd)
  ORDER BY p.phone_id
  HEAD p.phone_id
   org->org[d.seq].phone_cnt = (org->org[d.seq].phone_cnt+ 1), stat = alterlist(org->org[d.seq].phone,
    org->org[d.seq].phone_cnt)
  DETAIL
   org->org[d.seq].phone[org->org[d.seq].phone_cnt].phone_type = c.display, org->org[d.seq].phone[org
   ->org[d.seq].phone_cnt].phone_num = p.phone_num
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM organization o,
   organization_alias oa,
   code_value c,
   (dummyt d  WITH seq = org_cnt)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=org->org[d.seq].organization_id))
   JOIN (oa
   WHERE oa.organization_id=o.organization_id
    AND oa.active_ind=1)
   JOIN (c
   WHERE c.code_value=oa.alias_pool_cd)
  ORDER BY oa.organization_alias_id
  HEAD oa.organization_alias_id
   org->org[d.seq].alias_cnt = (org->org[d.seq].alias_cnt+ 1), stat = alterlist(org->org[d.seq].alias,
    org->org[d.seq].alias_cnt)
  DETAIL
   org->org[d.seq].alias[org->org[d.seq].alias_cnt].alias = oa.alias, org->org[d.seq].alias[org->org[
   d.seq].alias_cnt].alias_pool = c.display
  WITH nocounter
 ;end select
 SET lines = 0
 SELECT INTO "ccluserdir:ins_emp_export.csv"
  FROM (dummyt d  WITH seq = org_cnt)
  HEAD REPORT
   headstr = build('"organization_id","name","type","address_type","street_addr","street_addr2",',
    '"city","state","zip","country","phone_type","phone_num","alias_pool","alias",""'), col 0,
   headstr,
   row + 1
  DETAIL
   lines = maxval(1,org->org[d.seq].address_cnt,org->org[d.seq].alias_cnt,org->org[d.seq].phone_cnt),
   stat = alterlist(output->line,lines)
   FOR (i = 1 TO lines)
     output->line[i].linestr = build('"',org->org[d.seq].organization_id,'","',org->org[d.seq].name,
      '","',
      org->org[d.seq].type,'","')
   ENDFOR
   FOR (i = 1 TO org->org[d.seq].address_cnt)
     output->line[i].linestr = build(output->line[i].linestr,org->org[d.seq].address[i].address_type,
      '","',org->org[d.seq].address[i].street_addr,'","',
      org->org[d.seq].address[i].street_addr2,'","',org->org[d.seq].address[i].city,'","',org->org[d
      .seq].address[i].state,
      '","',org->org[d.seq].address[i].zip,'","',org->org[d.seq].address[i].country,'","')
   ENDFOR
   FOR (i = (org->org[d.seq].address_cnt+ 1) TO lines)
     output->line[i].linestr = build(output->line[i].linestr,'","","","","","","","')
   ENDFOR
   FOR (i = 1 TO org->org[d.seq].phone_cnt)
     output->line[i].linestr = build(output->line[i].linestr,org->org[d.seq].phone[i].phone_type,
      '","',org->org[d.seq].phone[i].phone_num,'","')
   ENDFOR
   FOR (i = (org->org[d.seq].phone_cnt+ 1) TO lines)
     output->line[i].linestr = build(output->line[i].linestr,'","","')
   ENDFOR
   FOR (i = 1 TO org->org[d.seq].alias_cnt)
     output->line[i].linestr = build(output->line[i].linestr,org->org[d.seq].alias[i].alias_pool,
      '","',org->org[d.seq].alias[i].alias,'",""')
   ENDFOR
   FOR (i = (org->org[d.seq].alias_cnt+ 1) TO lines)
     output->line[i].linestr = build(output->line[i].linestr,'","","",""')
   ENDFOR
   FOR (i = 1 TO lines)
     col 0, output->line[i].linestr, row + 1
   ENDFOR
  WITH nocounter, format = pcformat, noformfeed,
   maxcol = 800
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 RETURN
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE get_cv_by_disp(xcodeset,xdisp)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp)))
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
