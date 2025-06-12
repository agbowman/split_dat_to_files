CREATE PROGRAM bhs_cvis_lab_con_phy
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Recipient email(s)" = ""
  WITH outdev, recipient_emails
 DECLARE ms_outfile = vc WITH protect, constant(concat("cvis_lab_con_phy",format(curdate,
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
  con_first_name = pcon.name_first, con_last_name = pcon.name_last, con_bus_addr = adcon.street_addr,
  con_bus_city = adcon.city, con_bus_state = adcon.state, con_bus_zip = adcon.zipcode,
  con_bus_phone = ppcon.phone_num, con_bus_fax = build(rdcon.area_code,rdcon.exchange,rdcon
   .phone_suffix), license_number = pacon.alias,
  con_external_id = extcon.alias, pcon.username, physician_type_relationship = uar_get_code_display(
   odcon.oe_field_id)
  FROM orders ocon,
   order_catalog orcon,
   order_radiology ordcon,
   order_detail odcon,
   prsnl pcon,
   address adcon,
   phone ppcon,
   prsnl_alias pacon,
   prsnl_alias extcon,
   device_xref dxcon,
   remote_device rdcon
  WHERE dxcon.parent_entity_id=outerjoin(pcon.person_id)
   AND extcon.person_id=pcon.person_id
   AND pacon.person_id=pcon.person_id
   AND ppcon.parent_entity_id=outerjoin(pcon.person_id)
   AND adcon.parent_entity_id=pcon.person_id
   AND pcon.person_id=odcon.oe_field_value
   AND odcon.order_id=ordcon.order_id
   AND ordcon.order_id=ocon.order_id
   AND ocon.catalog_cd=orcon.catalog_cd
   AND ocon.catalog_type_cd=2517
   AND ocon.active_ind=1
   AND ocon.activity_type_cd=711
   AND orcon.activity_subtype_cd IN (633753, 633748)
   AND ((orcon.description="IR*") OR (((orcon.description="VL*") OR (orcon.description="NV*")) ))
   AND ordcon.exam_status_cd IN (4224, 4225, 4229, 4226)
   AND odcon.oe_field_id=12581
   AND pcon.active_ind=1
   AND adcon.active_ind=1
   AND adcon.parent_entity_name="PERSON"
   AND adcon.address_type_cd=754
   AND ppcon.phone_type_cd=outerjoin(163)
   AND ppcon.active_ind=outerjoin(1)
   AND ppcon.phone_type_seq=outerjoin(1)
   AND pacon.active_ind=1
   AND pacon.prsnl_alias_type_cd=64094777
   AND extcon.prsnl_alias_type_cd=1086
   AND rdcon.device_cd=outerjoin(dxcon.device_cd)
   AND ocon.orig_order_dt_tm >= cnvtdatetime("20-FEB-2011")
   AND ocon.orig_order_dt_tm <= cnvtdatetime("20-MAR-2011")
  ORDER BY extcon.alias
  HEAD REPORT
   ms_line = concat('"First Name","Middle Name","Last Name","Suffix"',
    ',"Bus Addr_1","Bus City","Bus State"',',"Bus Zip","Bus Phone","Bus Fax"',
    ',"Pager","License Number","External Id"',',"User Name","Physician Type Relationship"'), col 0,
   ms_line
  HEAD extcon.alias
   row + 1, ms_line = build('"',con_first_name,'","','","',con_last_name,
    '","','","',con_bus_addr,'","',con_bus_city,
    '","',con_bus_state,'","',con_bus_zip,'","',
    con_bus_phone,'","',con_bus_fax,'","','","',
    license_number,'","',con_external_id,'","',pcon.username,
    '","',physician_type_relationship,'"'), col 0,
   ms_line
  DETAIL
   row + 0
  FOOT REPORT
   row + 1
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 30000, maxrow = 1
 ;end select
 EXECUTE bhs_sys_stand_subroutine
 CALL emailfile(ms_outfile,ms_outfile,ms_recipient_emails,concat("CVIS LAB REPORT for RADIOLOGY "),0)
END GO
