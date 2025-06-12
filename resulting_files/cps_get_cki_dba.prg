CREATE PROGRAM cps_get_cki:dba
 RECORD reply(
   1 mnemonic = vc
   1 source_vocab_mean = vc
   1 source_identifier = vc
   1 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE parse_cki(cki)
   SET source_vocab = fillstring(100," ")
   SET source_ident = fillstring(100," ")
   SET source_vocab = trim(substring(1,(findstring("!",cki) - 1),cki))
   SET source_ident = trim(substring((findstring("!",cki)+ 1),(textlen(cki) - (findstring("!",cki) -
     1)),cki))
 END ;Subroutine
 SUBROUTINE build_cki(source_vocab,source_ident)
  SET cki = fillstring(100," ")
  SET cki = trim(concat(trim(source_vocab),"!",trim(source_ident)))
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET table_name = fillstring(30," ")
 IF ((request->catalog_cd > 0))
  SET table_name = "ORDER_CATALOG"
  SELECT INTO "NL:"
   FROM order_catalog oc
   PLAN (oc
    WHERE (oc.catalog_cd=request->catalog_cd))
   DETAIL
    reply->mnemonic = oc.primary_mnemonic
    IF (oc.cki > " ")
     CALL parse_cki(oc.cki), reply->source_vocab_mean = source_vocab, reply->source_identifier =
     source_ident,
     reply->cki = oc.cki
    ELSE
     CALL build_cki(oc.source_vocab_mean,oc.source_vocab_ident), reply->source_vocab_mean = oc
     .source_vocab_mean, reply->source_identifier = oc.source_vocab_ident,
     reply->cki = cki
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->synonym_id > 0))
  SET table_name = "ORDER_CATALOG_SYNONYM"
  SELECT INTO "NL:"
   FROM order_catalog_synonym os
   PLAN (os
    WHERE (os.synonym_id=request->synonym_id)
     AND os.cki > " ")
   DETAIL
    reply->mnemonic = os.mnemonic,
    CALL parse_cki(os.cki), reply->source_vocab_mean = source_vocab,
    reply->source_identifier = source_ident, reply->cki = os.cki
   WITH nocounter
  ;end select
 ELSE
  SET table_name = "ORDER_CATALOG"
  SELECT INTO "NL:"
   FROM orders o,
    order_catalog oc
   PLAN (o
    WHERE (o.order_id=request->order_id))
    JOIN (oc
    WHERE o.catalog_cd=oc.catalog_cd)
   DETAIL
    reply->mnemonic = oc.primary_mnemonic
    IF (oc.cki > " ")
     CALL parse_cki(oc.cki), reply->source_vocab_mean = source_vocab, reply->source_identifier =
     source_ident,
     reply->cki = oc.cki
    ELSE
     CALL build_cki(oc.source_vocab_mean,oc.source_vocab_ident), reply->source_vocab_mean = oc
     .source_vocab_mean, reply->source_identifier = oc.source_vocab_ident,
     reply->cki = cki
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
