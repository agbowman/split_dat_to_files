CREATE PROGRAM bhs_cvis_lab_ord_phy
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Recipient email(s)" = ""
  WITH outdev, recipient_emails
 DECLARE ms_outfile = vc WITH protect, constant(concat("cvis_lab_ord_phy",format(curdate,
    "YYYYMMDD;;D"),".csv"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_recipient_emails = vc WITH protect, constant( $RECIPIENT_EMAILS)
 IF (findstring("@",ms_recipient_emails)=0)
  CALL echo("###########################################")
  CALL echo(build("Invalid email recipients list"))
  CALL echo("###########################################")
  GO TO exit_script
 ENDIF
 SELECT INTO value(ms_outfile)
  ord_first_name = pr.name_first, ord_last_name = pr.name_last, ord_bus_addr = ad.street_addr,
  ord_bus_city = ad.city, ord_bus_state = ad.state, ord_bus_zip = ad.zipcode,
  ord_bus_phone = pp.phone_num, ord_bus_fax = build(rd.area_code,rd.exchange,rd.phone_suffix),
  ord_license_number = pa.alias,
  ord_external_id = ext.alias, pr.username, "Ordering Physician"
  FROM orders o,
   order_catalog oc,
   order_action oa,
   prsnl pr,
   address ad,
   phone pp,
   prsnl_alias pa,
   device_xref dx,
   remote_device rd,
   order_radiology rad,
   prsnl_alias ext
  WHERE ext.person_id=pr.person_id
   AND rad.order_id=o.order_id
   AND dx.parent_entity_id=outerjoin(pr.person_id)
   AND pa.person_id=pr.person_id
   AND pp.parent_entity_id=outerjoin(pr.person_id)
   AND pr.person_id=ad.parent_entity_id
   AND oa.order_provider_id=pr.person_id
   AND oa.order_id=o.order_id
   AND o.catalog_cd=oc.catalog_cd
   AND o.catalog_type_cd=2517
   AND o.active_ind=1
   AND o.activity_type_cd=711
   AND oc.activity_subtype_cd IN (633753, 633748)
   AND ((oc.description="IR*") OR (((oc.description="VL*") OR (oc.description="NV*")) ))
   AND oa.order_status_cd=2550
   AND oa.action_type_cd=2534
   AND ad.active_ind=1
   AND ad.parent_entity_name="PERSON"
   AND ad.address_type_cd=754
   AND pp.phone_type_cd=outerjoin(163)
   AND pp.active_ind=outerjoin(1)
   AND pp.phone_type_seq=1
   AND pa.active_ind=1
   AND pa.prsnl_alias_type_cd=outerjoin(64094777)
   AND rd.device_cd=outerjoin(dx.device_cd)
   AND rad.exam_status_cd IN (4224, 4225, 4229, 4226)
   AND ext.prsnl_alias_type_cd=1086
   AND o.orig_order_dt_tm >= cnvtdatetime("20-FEB-2011")
   AND o.orig_order_dt_tm <= cnvtdatetime("20-MAR-2011")
  ORDER BY ext.alias
  HEAD REPORT
   ms_line = concat('"First Name","Middle Name","Last Name","Suffix"',
    ',"Bus Addr_1","Bus City","Bus State"',',"Bus Zip","Bus Phone","Bus Fax"',
    ',"Pager","License Number","External Id"',',"User Name","Physician Type Relationship"'), col 0,
   ms_line
  HEAD ext.alias
   row + 1, ms_line = build('"',ord_first_name,'","','","',ord_last_name,
    '","','","',ord_bus_addr,'","',ord_bus_city,
    '","',ord_bus_state,'","',ord_bus_zip,'","',
    ord_bus_phone,'","',ord_bus_fax,'","','","',
    ord_license_number,'","',ord_external_id,'","',pr.username,
    '","',"Ordering Physician",'"'), col 0,
   ms_line
  DETAIL
   x = 0
  FOOT REPORT
   row + 1
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 30000, maxrow = 1
 ;end select
 EXECUTE bhs_sys_stand_subroutine
 CALL emailfile(ms_outfile,ms_outfile,ms_recipient_emails,concat("CVIS LAB REPORT for RADIOLOGY "),0)
END GO
