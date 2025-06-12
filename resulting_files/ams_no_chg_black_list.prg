CREATE PROGRAM ams_no_chg_black_list
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Mode" = 0,
  "Enter the CATALOG_CD to Blacklist" = "",
  "Verify the Order Catalog Information" = 0,
  "Select the Facility at Which to Black List the Orderable" = 0
  WITH outdev, mode, catalogtext,
  catalog_cd, facility
 RECORD org(
   1 org[*]
     2 org_id = f8
 )
 DECLARE found_ind = i2
 DECLARE logdomain(p1=f8) = f8
 DECLARE orgfilter(p1=f8) = i2
 DECLARE user_logical_domain = f8
 DECLARE num = i4
 SET found_ind = 0
 SET user_logical_domain = logdomain(reqinfo->updt_id)
 CALL echo(user_logical_domain)
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_name=cnvtstring( $FACILITY)
   AND d.info_number=user_logical_domain
   AND (d.info_domain_id= $CATALOG_CD)
   AND d.info_domain="NOCHG-GENLAB"
  DETAIL
   found_ind = 1
  WITH nocounter
 ;end select
 IF (( $MODE=1))
  IF (found_ind=0)
   INSERT  FROM dm_info d
    SET d.info_domain = "NOCHG-GENLAB", d.info_name = trim(cnvtstring( $FACILITY)), d.info_number =
     user_logical_domain,
     d.info_domain_id =  $CATALOG_CD, d.info_date = cnvtdatetime(curdate,curtime3), d.updt_id =
     reqinfo->updt_id
    WITH nocounter
   ;end insert
   COMMIT
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "ORDERABLE BLACKLISTED FOR SELECTED FACILITY."
    WITH nocounter
   ;end select
  ELSEIF (found_ind=1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "ORDERABLE IS ALREADY BLACKLISTED FOR THIS FACILITY."
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF (( $MODE=2))
  IF (found_ind=1)
   DELETE  FROM dm_info d
    WHERE d.info_domain="NOCHG-GENLAB"
     AND d.info_name=trim(cnvtstring( $FACILITY))
     AND d.info_number=user_logical_domain
     AND (d.info_domain_id= $CATALOG_CD)
    WITH nocounter
   ;end delete
   COMMIT
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "ORDERABLE UNBLACKLISTED FOR THIS FACILITY."
    WITH nocounter
   ;end select
  ELSEIF (found_ind=0)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "ORDERABLE WAS NOT BLACKLISTED FOR THIS FACILITY."
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF (( $MODE=3))
  SET has_orgs = orgfilter(reqinfo->updt_id)
  SELECT INTO  $OUTDEV
   org.org_name, org.organization_id, o.primary_mnemonic,
   o.catalog_cd, updt_dt_tm = format(d.info_date,"mm/dd/yyyy hh:mm;;q")
   FROM dm_info d,
    order_catalog o,
    organization org
   PLAN (d
    WHERE d.info_domain="NOCHG-GENLAB"
     AND d.info_number=user_logical_domain)
    JOIN (o
    WHERE d.info_domain_id=o.catalog_cd)
    JOIN (org
    WHERE cnvtreal(d.info_name)=org.organization_id
     AND expand(num,1,size(org->org,5),org.organization_id,org->org[num].org_id))
   WITH nocounter, format, separator = " ",
    maxcol = 5000
  ;end select
 ENDIF
 SUBROUTINE logdomain(person_id)
   DECLARE logical_domain_id = f8
   SET logical_domain_id = 0.0
   SELECT INTO "nl:"
    p.logical_domain_id
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     IF (p.person_id > 0)
      logical_domain_id = p.logical_domain_id
     ENDIF
    WITH nocounter
   ;end select
   RETURN(logical_domain_id)
 END ;Subroutine
 SUBROUTINE orgfilter(person_id)
   DECLARE has_orgs = i2
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(org->org,cnt), org->org[cnt].org_id = por.organization_id
    FOOT REPORT
     IF (cnt > 0)
      has_orgs = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(has_orgs)
 END ;Subroutine
END GO
