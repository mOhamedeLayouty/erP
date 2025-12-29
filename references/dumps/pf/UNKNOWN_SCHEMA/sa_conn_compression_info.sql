-- PF: UNKNOWN_SCHEMA.sa_conn_compression_info
-- proc_id: 65
-- generated_at: 2025-12-29T13:53:28.710Z

create procedure dbo.sa_conn_compression_info( in connidparm integer default null ) 
result( 
  Type varchar(20),
  ConnNumber integer,
  Compression varchar(10),
  TotalBytes integer,
  TotalBytesUnComp integer,
  CompRate numeric(5,2),
  CompRateSent numeric(5,2),
  CompRateReceived numeric(5,2),
  TotalPackets integer,
  TotalPacketsUnComp integer,
  CompPktRate numeric(5,2),
  CompPktRateSent numeric(5,2),
  CompPktRateReceived numeric(5,2) ) dynamic result sets 1
begin
  declare connid integer;
  declare bytes_sent integer;
  declare bytes_recv integer;
  declare bytes_uncomp_sent integer;
  declare bytes_uncomp_recv integer;
  declare pkt_sent integer;
  declare pkt_recv integer;
  declare pkt_uncomp_sent integer;
  declare pkt_uncomp_recv integer;
  declare local temporary table t_conn_comp_info(
    Type varchar(20) null,
    ConnNumber integer null,
    Compression varchar(10) null,
    TotalBytes integer null,
    TotalBytesUncomp integer null,
    CompRate numeric(5,2) null,
    CompRateSent numeric(5,2) null,
    CompRateReceived numeric(5,2) null,
    TotalPackets integer null,
    TotalPacketsUncomp integer null,
    CompPktRate numeric(5,2) null,
    CompPktRateSent numeric(5,2) null,
    CompPktRateReceived numeric(5,2) null,
    ) in SYSTEM not transactional;
  if(connidparm is not null) then
    set connid = connection_property('Number',connidparm)
  else
    set connid = next_connection(connid,null)
  end if;
  lbl: loop
    if connid is null then
      leave lbl
    end if;
    set bytes_sent = connection_property('BytesSent',connid);
    set bytes_recv = connection_property('BytesReceived',connid);
    set bytes_uncomp_sent = connection_property('BytesSentUncomp',connid);
    set bytes_uncomp_recv = connection_property('BytesReceivedUncomp',connid);
    set pkt_sent = connection_property('PacketsSent',connid);
    set pkt_recv = connection_property('PacketsReceived',connid);
    set pkt_uncomp_sent = connection_property('PacketsSentUncomp',connid);
    set pkt_uncomp_recv = connection_property('PacketsReceivedUncomp',connid);
    if pkt_sent > 0 and pkt_recv > 0 then
      insert into t_conn_comp_info values
        ( 'Connection',
        connid,
        connection_property('Compression',connid),
        bytes_sent+bytes_recv,
        bytes_uncomp_sent+bytes_uncomp_recv,
        cast(bytes_uncomp_sent+bytes_uncomp_recv-(bytes_sent+bytes_recv) as real)*100
        /cast(bytes_uncomp_sent+bytes_uncomp_recv as real),
        cast(bytes_uncomp_sent-bytes_sent as real)*100
        /cast(bytes_uncomp_sent as real),
        cast(bytes_uncomp_recv-bytes_recv as real)*100
        /cast(bytes_uncomp_recv as real),
        pkt_sent+pkt_recv,
        pkt_uncomp_sent+pkt_uncomp_recv,
        cast(pkt_uncomp_sent+pkt_uncomp_recv-(pkt_sent+pkt_recv) as real)*100
        /cast(pkt_uncomp_sent+pkt_uncomp_recv as real),
        cast(pkt_uncomp_sent-pkt_sent as real)*100
        /cast(pkt_uncomp_sent as real),
        cast(pkt_uncomp_recv-pkt_recv as real)*100
        /cast(pkt_uncomp_recv as real) ) 
    end if;
    if(connidparm is not null) then
      leave lbl
    else
      set connid = next_connection(connid,null)
    end if
  end loop lbl;
  if(connidparm is null) then
    set bytes_sent = property('BytesSent');
    set bytes_recv = property('BytesReceived');
    set bytes_uncomp_sent = property('BytesSentUncomp');
    set bytes_uncomp_recv = property('BytesReceivedUncomp');
    set pkt_sent = property('PacketsSent');
    set pkt_recv = property('PacketsReceived');
    set pkt_uncomp_sent = property('PacketsSentUncomp');
    set pkt_uncomp_recv = property('PacketsReceivedUncomp');
    insert into t_conn_comp_info values
      ( 'Server',
      null,
      null,
      bytes_sent+bytes_recv,
      bytes_uncomp_sent+bytes_uncomp_recv,
      cast(bytes_uncomp_sent+bytes_uncomp_recv-(bytes_sent+bytes_recv) as real)*100
      /cast(bytes_uncomp_sent+bytes_uncomp_recv as real),
      cast(bytes_uncomp_sent-bytes_sent as real)*100
      /cast(bytes_uncomp_sent as real),
      cast(bytes_uncomp_recv-bytes_recv as real)*100
      /cast(bytes_uncomp_recv as real),
      pkt_sent+pkt_recv,
      pkt_uncomp_sent+pkt_uncomp_recv,
      cast(pkt_uncomp_sent+pkt_uncomp_recv-(pkt_sent+pkt_recv) as real)*100
      /cast(pkt_uncomp_sent+pkt_uncomp_recv as real),
      cast(pkt_uncomp_sent-pkt_sent as real)*100
      /cast(pkt_uncomp_sent as real),
      cast(pkt_uncomp_recv-pkt_recv as real)*100
      /cast(pkt_uncomp_recv as real) ) 
  end if;
  select * from t_conn_comp_info
end
