CREATE PROGRAM bhs_sys_chk_npi:dba
 DECLARE plname = vc WITH protect, noconstant(" ")
 DECLARE pfname = vc WITH protect, noconstant(" ")
 DECLARE pmid = vc WITH protect, noconstant(" ")
 DECLARE ord_num = vc WITH protect, noconstant(" ")
 DECLARE sfx = vc WITH protect, noconstant(" ")
 DECLARE prov_cnt = i4
 DECLARE msg = vc
 DECLARE msgsubject = vc
 DECLARE hnasetup = i2
 DECLARE sendto = vc
 DECLARE ignore = i2
 DECLARE name_mismatch = vc
 SET plname = prov_lname
 SET pfname = build(prov_fname,pmid)
 SET pmid = middle_init
 SET ord_num = shlds_ord_num
 SET sfx = suffix
 SET name_mismatch = "N"
 SET ignore = 0
 SET prov_cnt = 0
 IF (cnvtupper(oen_reply->order_group[1].orc[1].order_ctrl)="SN")
  SELECT INTO "nl:"
   FROM prsnl_alias pa,
    prsnl p
   PLAN (pa
    WHERE (pa.alias= $1)
     AND pa.prsnl_alias_type_cd=64094777.00
     AND pa.active_ind=1)
    JOIN (p
    WHERE p.person_id=pa.person_id
     AND p.active_ind=1)
   DETAIL
    prov_cnt = (prov_cnt+ 1)
    IF (pa.alias_pool_cd <= 0)
     hnasetup = 1
    ELSE
     hnasetup = 2
    ENDIF
    IF (((p.name_first != pfname) OR (p.name_last != plname)) )
     name_mismatch = "Y"
    ENDIF
   WITH nocounter
  ;end select
  IF (((prov_cnt=0) OR (((cnvtint(npi)=0) OR (hnasetup=1)) )) )
   SET find_npi = 0
   SET ignore = 1
   SET process_nssmr = "Y"
   IF (hnasetup=0)
    SET msg = concat(" Shields ORD# ",ord_num)
    SET msgsubject = concat("NPI ",npi," Not Found in HNAUser for Prov: ",plname," ",
     pfname," ",pmid," ",sfx)
   ELSEIF (hnasetup=1
    AND name_mismatch != "Y")
    SET msg = concat(" Shields ORD# ",ord_num)
    SET msgsubject = concat("NPI ",npi," Has Invalid Setup for Prov: ",plname," ",
     pfname," ",pmid," ",sfx)
   ELSEIF (hnasetup=1
    AND name_mismatch="Y")
    SET msg = concat(" Shields ORD# ",ord_num)
    SET msgsubject = concat("NPI ",npi," Has a Name Mismatch for Prov: ",plname," ",
     pfname," ",pmid," ",sfx)
   ENDIF
  ELSEIF (prov_cnt > 1)
   SET ignore = 1
   SET process_nssmr = "Y"
   CALL echo(build("process_nssmr2 = ",process_nssmr))
   SET msg = concat(" Shields ORD# ",ord_num)
   SET msgsubject = concat("Multiple Providers in HNAUser have NPI#:",npi)
  ELSE
   SET msg = concat(pname,"-","Found NPI:",npi)
   SET msgsubject = concat(pname,"-","Found NPI:",npi)
   SET process_nssmr = "G"
   CALL echo(build("found npi:",npi))
  ENDIF
  DECLARE msgpriority = i4
  SET msgpriority = 5
  SET sendto = "joshua.wherry"
  SET msgcls = "IPM.NOTE"
  SET sender = "ShieldsMRI"
  IF (ignore=1)
   CALL uar_send_mail(nullterm(sendto),nullterm(msgsubject),nullterm(msg),nullterm(sender),
    msgpriority,
    nullterm(msgcls))
   SET sendto = "Rodolfo.Valdez@baystatehealth.org"
   CALL uar_send_mail(nullterm(sendto),nullterm(msgsubject),nullterm(msg),nullterm(sender),
    msgpriority,
    nullterm(msgcls))
   SET sendto = "Jeffery.Picard@baystatehealth.org"
   CALL uar_send_mail(nullterm(sendto),nullterm(msgsubject),nullterm(msg),nullterm(sender),
    msgpriority,
    nullterm(msgcls))
   SET sendto = "Infosys.OSG@bhs.org"
   CALL uar_send_mail(nullterm(sendto),nullterm(msgsubject),nullterm(msg),nullterm(sender),
    msgpriority,
    nullterm(msgcls))
  ENDIF
 ENDIF
END GO
