CREATE PROGRAM cp_get_chart_prsnl_dest:dba
 RECORD reply(
   1 qual[*]
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = c20
     2 prsnl_id = f8
     2 prsnl_reltn[*]
       3 prsnl_reltn_id = f8
       3 organization_id = f8
       3 output_dest_cd = f8
       3 output_device_cd = f8
       3 output_dest_name = vc
       3 device_name = vc
       3 location_cd = f8
       3 dms_service_ident = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE assigned_provider_type = i4 WITH constant(5)
 DECLARE bchartdest = i2 WITH noconstant(0)
 DECLARE borgnodevice = i2 WITH noconstant(0)
 DECLARE reltncnt = i4
 DECLARE qualcnt = i4
 SET qualcnt = size(request->qual,5)
 SET stat = alterlist(reply->qual,qualcnt)
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  pra.prsnl_reltn_id
  FROM (dummyt d  WITH seq = value(qualcnt)),
   prsnl_reltn_activity pra,
   prsnl_reltn pr,
   prsnl_org_reltn por,
   dummyt d1
  PLAN (d)
   JOIN (pra
   WHERE ((pra.prsnl_id+ 0)=request->qual[d.seq].prsnl_person_id)
    AND (((pra.encntr_id=request->qual[d.seq].encntr_id)
    AND (request->qual[d.seq].order_id=0)) OR ((pra.accession_nbr=request->qual[d.seq].accession_nbr)
    AND (request->qual[d.seq].order_id > 0)))
    AND pra.usage_nbr=1)
   JOIN (pr
   WHERE pr.prsnl_reltn_id=pra.prsnl_reltn_id
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm >= cnvtdatetime("31-Dec-2100"))
   JOIN (d1)
   JOIN (por
   WHERE por.prsnl_org_reltn_id=pr.parent_entity_id
    AND por.active_ind=1
    AND por.end_effective_dt_tm >= cnvtdatetime("31-Dec-2100"))
  ORDER BY d.seq, pra.prsnl_reltn_id, 0
  HEAD d.seq
   reply->qual[d.seq].prsnl_id = request->qual[d.seq].prsnl_person_id, reply->qual[d.seq].encntr_id
    = request->qual[d.seq].encntr_id, reply->qual[d.seq].order_id = request->qual[d.seq].order_id,
   reply->qual[d.seq].accession_nbr = request->qual[d.seq].accession_nbr, reltncnt = 0
  DETAIL
   IF (pra.prsnl_reltn_id > 0)
    reltncnt += 1
    IF (mod(reltncnt,5)=1)
     stat = alterlist(reply->qual[d.seq].prsnl_reltn,(reltncnt+ 4))
    ENDIF
    reply->qual[d.seq].prsnl_reltn[reltncnt].prsnl_reltn_id = pra.prsnl_reltn_id
    IF (pr.parent_entity_name="ORGANIZATION")
     reply->qual[d.seq].prsnl_reltn[reltncnt].organization_id = pr.parent_entity_id
    ELSEIF (pr.parent_entity_name="PRSNL_ORG_RELTN"
     AND por.prsnl_org_reltn_id > 0)
     reply->qual[d.seq].prsnl_reltn[reltncnt].organization_id = por.organization_id
    ELSEIF (pr.parent_entity_name="LOCATION")
     reply->qual[d.seq].prsnl_reltn[reltncnt].location_cd = pr.parent_entity_id
    ENDIF
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->qual[d.seq].prsnl_reltn,reltncnt)
   IF (reltncnt > 0)
    bchartdest = 1
   ENDIF
  WITH outerjoin = d, outerjoin = d1, nocounter
 ;end select
 CALL echo(build("chart_dest_ind: ",bchartdest))
 IF (bchartdest=1
  AND (request->route_type_flag=assigned_provider_type))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(qualcnt)),
    (dummyt d2  WITH seq = 1),
    cr_destination_xref xref,
    device d,
    output_dest od,
    remote_device rd,
    remote_device_type rdt,
    dummyt d3
   PLAN (d1
    WHERE maxrec(d2,size(reply->qual[d1.seq].prsnl_reltn,5))
     AND size(reply->qual[d1.seq].prsnl_reltn,5) > 0)
    JOIN (d2)
    JOIN (xref
    WHERE (((xref.parent_entity_id=reply->qual[d1.seq].prsnl_reltn[d2.seq].organization_id)
     AND xref.parent_entity_name="ORGANIZATION") OR ((xref.parent_entity_id=reply->qual[d1.seq].
    prsnl_reltn[d2.seq].location_cd)
     AND xref.parent_entity_name="LOCATION")) )
    JOIN (d
    WHERE d.device_cd=xref.device_cd)
    JOIN (od
    WHERE od.device_cd=xref.device_cd)
    JOIN (d3)
    JOIN (rd
    WHERE rd.device_cd=xref.device_cd)
    JOIN (rdt
    WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
   ORDER BY d1.seq, d2.seq
   DETAIL
    reply->qual[d1.seq].prsnl_reltn[d2.seq].output_dest_cd = od.output_dest_cd, reply->qual[d1.seq].
    prsnl_reltn[d2.seq].output_device_cd = rdt.output_format_cd, reply->qual[d1.seq].prsnl_reltn[d2
    .seq].output_dest_name = od.name,
    reply->qual[d1.seq].prsnl_reltn[d2.seq].dms_service_ident = trim(xref.dms_service_identifier)
    IF (d.name != od.name)
     reply->qual[d1.seq].prsnl_reltn[d2.seq].device_name = d.name
    ENDIF
    IF (od.output_dest_cd=0
     AND size(trim(xref.dms_service_identifier))=0)
     borgnodevice = 1
    ENDIF
   WITH outerjoin = d1, outerjoin = d2, outerjoin = d3,
    nocounter
  ;end select
 ENDIF
 CALL echo(build("bOrgNoDevice= ",borgnodevice))
 IF (bchartdest=0)
  SET reply->status_data.status = "Z"
 ELSEIF (borgnodevice=1)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
