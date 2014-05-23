def l_objlst="&1."
def l_queue_name="&2."

declare
  l_query varchar2(32767) := q'#&l_objlst.#';
  l_obj_csr sys_refcursor;
  l_enq_opt  sys.dbms_aq.enqueue_options_t;
  l_msg_prop sys.dbms_aq.message_properties_t;
  l_msgid     raw(16);
  l_payload xmltype;
begin
  open l_obj_csr for l_query;
  for xml_rec in (
    select owner, name
      from xmltable(
             '/ROWSET/ROW'
             passing xmltype(l_obj_csr)
             columns 
               owner varchar2(30) path 'OWNER',
               name varchar2(30) path 'NAME'
           )
    )
  loop
    select xmlelement(
             "ROWSET",
             xmlelement(
               "ROW",
               xmlelement("OWNER", xml_rec.owner),
               xmlelement("NAME", xml_rec.name)
             )
           )
      into l_payload
      from dual;
    sys.dbms_aq.enqueue( 
      queue_name         => '&l_queue_name.',
      enqueue_options    => l_enq_opt,
      message_properties => l_msg_prop,
      payload            => l_payload,
      msgid              => l_msgid);
  end loop;
  close l_obj_csr;
  commit;
end;
/

undef l_objlst
