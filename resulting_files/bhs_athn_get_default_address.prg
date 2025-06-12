CREATE PROGRAM bhs_athn_get_default_address
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 FREE RECORD req_fndis_get_org_prov_addr_list
 RECORD req_fndis_get_org_prov_addr_list(
   1 followup_type_flag = i2
   1 followup_id = f8
   1 default_address_type_cd = f8
   1 default_address_type_seq = i2
   1 address_type[*]
     2 address_type_cd = f8
   1 default_phone_type_cd = f8
   1 default_phone_type_seq = i2
   1 phone_type[*]
     2 phone_type_cd = f8
 ) WITH protect
 FREE RECORD rep_fndis_get_org_prov_addr_list
 RECORD rep_fndis_get_org_prov_addr_list(
   1 followup_provider = vc
   1 address[*]
     2 address_id = f8
     2 address_type_cd = f8
     2 address_type_disp = vc
     2 address_type_desc = vc
     2 address_type_seq = i2
     2 default = i2
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 zipcode = vc
   1 phone[*]
     2 phone_id = f8
     2 phone_type_cd = f8
     2 phone_type_disp = vc
     2 phone_type_desc = vc
     2 phone_type_seq = i2
     2 default = i2
     2 phone_number = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF (( $2 <= 0.0)
  AND ( $3 <= 0.0))
  CALL echo("INVALID ORGANIZATION/PERSONNEL ID PARAMETERS...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE c_address_business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE c_address_professional_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,
   "PROFESSIONAL"))
 DECLARE c_phone_business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE c_phone_professional_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,
   "PROFESSIONAL"))
 IF (( $2 > 0.0))
  SET req_fndis_get_org_prov_addr_list->followup_type_flag = 1
  SET req_fndis_get_org_prov_addr_list->followup_id =  $2
 ELSEIF (( $3 > 0.0))
  SET req_fndis_get_org_prov_addr_list->followup_type_flag = 2
  SET req_fndis_get_org_prov_addr_list->followup_id =  $3
 ENDIF
 SET req_fndis_get_org_prov_addr_list->default_address_type_cd = c_address_business_cd
 SET req_fndis_get_org_prov_addr_list->default_address_type_seq = 1
 SET stat = alterlist(req_fndis_get_org_prov_addr_list->address_type,2)
 SET req_fndis_get_org_prov_addr_list->address_type[1].address_type_cd = c_address_business_cd
 SET req_fndis_get_org_prov_addr_list->address_type[2].address_type_cd = c_address_professional_cd
 SET req_fndis_get_org_prov_addr_list->default_phone_type_cd = c_phone_business_cd
 SET req_fndis_get_org_prov_addr_list->default_phone_type_seq = 2
 SET stat = alterlist(req_fndis_get_org_prov_addr_list->phone_type,2)
 SET req_fndis_get_org_prov_addr_list->phone_type[1].phone_type_cd = c_phone_business_cd
 SET req_fndis_get_org_prov_addr_list->phone_type[2].phone_type_cd = c_phone_professional_cd
 EXECUTE fndis_get_org_prov_addr_list  WITH replace("REQUEST","REQ_FNDIS_GET_ORG_PROV_ADDR_LIST"),
 replace("REPLY","REP_FNDIS_GET_ORG_PROV_ADDR_LIST")
 CALL echorecord(rep_fndis_get_org_prov_addr_list)
#exit_script
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  IF ((rep_fndis_get_org_prov_addr_list->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM (dummyt d  WITH seq = value(1))
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1
    DETAIL
     v1 = build("<FollowupProvider>",trim(replace(replace(replace(replace(replace(
            rep_fndis_get_org_prov_addr_list->followup_provider,"&","&amp;",0),"<","&lt;",0),">",
          "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</FollowupProvider>"), col + 1, v1,
     row + 1, col + 1, "<Addresses>",
     row + 1
     FOR (idx = 1 TO size(rep_fndis_get_org_prov_addr_list->address,5))
       col + 1, "<Address>", row + 1,
       v2 = build("<AddressId>",cnvtint(rep_fndis_get_org_prov_addr_list->address[idx].address_id),
        "</AddressId>"), col + 1, v2,
       row + 1, v3 = build("<AddressTypeCd>",cnvtint(rep_fndis_get_org_prov_addr_list->address[idx].
         address_type_cd),"</AddressTypeCd>"), col + 1,
       v3, row + 1, v4 = build("<AddressTypeDisp>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].address_type_disp,"&","&amp;",0),"<",
             "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</AddressTypeDisp>"),
       col + 1, v4, row + 1,
       v5 = build("<AddressTypeDesc>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].address_type_desc,"&","&amp;",0),"<",
             "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</AddressTypeDesc>"), col +
       1, v5,
       row + 1, v6 = build("<AddressTypeSeq>",rep_fndis_get_org_prov_addr_list->address[idx].
        address_type_seq,"</AddressTypeSeq>"), col + 1,
       v6, row + 1, v7 = build("<Default>",rep_fndis_get_org_prov_addr_list->address[idx].default,
        "</Default>"),
       col + 1, v7, row + 1,
       v8 = build("<StreetAddr>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].street_addr,"&","&amp;",0),"<","&lt;",0),
            ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</StreetAddr>"), col + 1, v8,
       row + 1, v9 = build("<StreetAddr2>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].street_addr2,"&","&amp;",0),"<","&lt;",0
             ),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</StreetAddr2>"), col + 1,
       v9, row + 1, v10 = build("<StreetAddr3>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].street_addr3,"&","&amp;",0),"<","&lt;",0
             ),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</StreetAddr3>"),
       col + 1, v10, row + 1,
       v11 = build("<StreetAddr4>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].street_addr4,"&","&amp;",0),"<","&lt;",0
             ),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</StreetAddr4>"), col + 1, v11,
       row + 1, v12 = build("<City>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].city,"&","&amp;",0),"<","&lt;",0),">",
            "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</City>"), col + 1,
       v12, row + 1, v13 = build("<State>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].state,"&","&amp;",0),"<","&lt;",0),">",
            "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</State>"),
       col + 1, v13, row + 1,
       v14 = build("<ZipCode>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->address[idx].zipcode,"&","&amp;",0),"<","&lt;",0),">",
            "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ZipCode>"), col + 1, v14,
       row + 1, col + 1, "</Address>",
       row + 1
     ENDFOR
     col + 1, "</Addresses>", row + 1,
     col + 1, "<Phones>", row + 1
     FOR (idx = 1 TO size(rep_fndis_get_org_prov_addr_list->phone,5))
       col + 1, "<Phone>", row + 1,
       v15 = build("<PhoneId>",cnvtint(rep_fndis_get_org_prov_addr_list->phone[idx].phone_id),
        "</PhoneId>"), col + 1, v15,
       row + 1, v16 = build("<PhoneTypeCd>",cnvtint(rep_fndis_get_org_prov_addr_list->phone[idx].
         phone_type_cd),"</PhoneTypeCd>"), col + 1,
       v16, row + 1, v17 = build("<PhoneTypeDisp>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->phone[idx].phone_type_disp,"&","&amp;",0),"<","&lt;",
             0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PhoneTypeDisp>"),
       col + 1, v17, row + 1,
       v18 = build("<PhoneTypeDesc>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->phone[idx].phone_type_desc,"&","&amp;",0),"<","&lt;",
             0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PhoneTypeDesc>"), col + 1, v18,
       row + 1, v19 = build("<PhoneTypeSeq>",rep_fndis_get_org_prov_addr_list->phone[idx].
        phone_type_seq,"</PhoneTypeSeq>"), col + 1,
       v19, row + 1, v20 = build("<Default>",rep_fndis_get_org_prov_addr_list->phone[idx].default,
        "</Default>"),
       col + 1, v20, row + 1,
       v21 = build("<PhoneNumber>",trim(replace(replace(replace(replace(replace(
              rep_fndis_get_org_prov_addr_list->phone[idx].phone_number,"&","&amp;",0),"<","&lt;",0),
            ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PhoneNumber>"), col + 1, v21,
       row + 1, col + 1, "</Phone>",
       row + 1
     ENDFOR
     col + 1, "</Phones>", row + 1
    FOOT REPORT
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD req_fndis_get_org_prov_addr_list
 FREE RECORD rep_fndis_get_org_prov_addr_list
END GO
