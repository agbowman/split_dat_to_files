CREATE PROGRAM ce_get_sequence:dba
 DECLARE esrchdictseq = i4 WITH constant(0)
 DECLARE eclinicaleventseq = i4 WITH constant(1)
 DECLARE elongdataseq = i4 WITH constant(2)
 DECLARE ereferenceseq = i4 WITH constant(3)
 DECLARE eocfseq = i4 WITH constant(4)
 SET reply->id_ = 0
 CASE (request->sequence_pool)
  OF esrchdictseq:
   SELECT INTO "nl:"
    dbseq = seq(srch_dict_seq,nextval)
    FROM dual
    DETAIL
     reply->id = cnvtreal(dbseq)
    WITH nocounter
   ;end select
  OF eclinicaleventseq:
   SELECT INTO "nl:"
    dbseq = seq(clinical_event_seq,nextval)
    FROM dual
    DETAIL
     reply->id = cnvtreal(dbseq)
    WITH nocounter
   ;end select
  OF elongdataseq:
   SELECT INTO "nl:"
    dbseq = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     reply->id = cnvtreal(dbseq)
    WITH nocounter
   ;end select
  OF ereferenceseq:
   SELECT INTO "nl:"
    dbseq = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     reply->id = cnvtreal(dbseq)
    WITH nocounter
   ;end select
  OF eocfseq:
   SELECT INTO "nl:"
    dbseq = seq(ocf_seq,nextval)
    FROM dual
    DETAIL
     reply->id = cnvtreal(dbseq)
    WITH nocounter
   ;end select
 ENDCASE
END GO
