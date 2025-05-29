meta:
  id: ciq
  file-extension: PRG
  endian: be
  #imports:
  #  - ciq_sdk

seq:
  - id: sections
    doc: List of PRG sections.
    type: section
    repeat: eos

types:
  u3:
    doc: For OP code expecting 3 bytes for their parameters
    seq:
      - id: value
        size: 3  # Read exactly 3 bytes

  section:
    doc: A PRG section.
    seq:
      - id: magic
        type: u4
      - id: length
        type: u4
      - id: content
        size: length
        type:
          switch-on: magic
          cases:
            section_magic::end.to_i: section_end
            section_magic::head.to_i: section_head
            section_magic::head_versioned.to_i: section_head
            section_magic::code.to_i: section_code
            section_magic::data.to_i: section_data
            section_magic::pc_to_line_num.to_i: section_pc_to_line_num
            section_magic::entry_points.to_i: section_entry_points
            section_magic::link_table.to_i: section_link_table
            section_magic::permissions.to_i: section_permissions
            section_magic::exceptions.to_i: section_exceptions
            section_magic::symbols.to_i: section_symbols
            section_magic::string_resource_symbols.to_i: section_not_implemented
            section_magic::settings.to_i: section_not_implemented
            section_magic::app_unlock.to_i: section_app_unlock
            section_magic::resource.to_i: section_not_implemented
            section_magic::background_resource.to_i: section_not_implemented
            section_magic::glance_resource.to_i: section_not_implemented
            section_magic::app_store_signature.to_i: section_not_implemented
            section_magic::developer_signature.to_i: section_developer_signature_block
            section_magic::debug.to_i: section_debug
            section_magic::complication.to_i: section_not_implemented
    instances:
      type:
          value: magic
          enum: section_magic

  ## Section structure
  section_head:
    doc: Head section with metadata such as version.
    seq:
      - id: header_version
        type: u1
      - id: version
        type: connect_iq_version
      - id: background_offsets
        type: offsets
        if: _io.pos < _io.size  # optional
      - id: app_lock_indicator
        type: u1
        if: _io.pos < _io.size  # optional
      - id: unused1
        type: u4
        if: _io.pos < _io.size  # optional
      - id: unused2
        type: u4
        if: _io.pos < _io.size  # optional
      - id: glance_offsets
        type: offsets
        if: _io.pos < _io.size  # optional
      - id: flags
        type: u4
        if: _io.pos < _io.size  # optional
    instances:
      app_lock:
        value: app_lock_indicator != 0
      glance_support:
        value: (flags & 0x1) != 0
      profiling_enabled:
        value: (flags & 0x2) != 0

  section_not_implemented:
    doc: Generic section that is not implemented
    # TODO
    seq:
      - id: data
        size: _parent.length

  section_end:
    doc: End of section, placed at the end of a PRG file, containing no data.
    seq:
      - id: data
        size: _parent.length

  section_entry_points:
    doc: Entry points section.
    seq:
      - id: size
        type: u2
      - id: entry_points
        type: entry_point
        repeat: eos

  section_data:
    doc: Data section
    seq:
      - id: data_entries
        type: data_entry
        repeat: eos

  section_code:
    doc: Code section
    seq:
      - id: code
        type: op_code
        repeat: eos

  section_pc_to_line_num:
    doc: PC to line number section.
    seq:
      - id: size
        type: u2
      - id: line_number_entries
        type: line_number_entries
        size: size * sizeof<line_number_entry>

  section_link_table:
    doc: Link table section.
    seq:
      - id: size
        type: u2
      - id: link_table_entries
        type: link_table_entries
        size: size * sizeof<link_table_entry>

  section_permissions:
    doc: Permissions section.
    seq:
      - id: size
        type: u2
      - id: permissions
        type: permissions
        size: size * sizeof<permission_entry>

  section_exceptions:
    doc: Exceptions section.
    seq:
      - id: size
        type: u2
      - id: exceptions_table
        type: exceptions_table
        size: size * sizeof<exception_table_entry>

  section_symbols:
    doc: Symbols section.
    seq:
      - id: size
        type: u2
      - id: symbols
        type: symbols
        size: size * sizeof<symbol>

  section_app_unlock:
    doc: App unlock section.
    seq:
      - id: flags
        type: u4
      - id: unit_id
        type: u4le

  section_developer_signature_block:
    doc: Developer signature block section
    seq:
      - id: signature
        size: 512
      - id: modulus
        size: 512
      - id: exponent
        type: u4

  section_debug:
    doc: Debug section.
    # TODO
    seq:
      - id: debug_strings
        type: debug_string
        repeat: eos

  ## Section element structures
  symbols:
    doc: List of symbols.
    seq:
      - id: symbol
        type: symbol
        repeat: eos

  symbol:
    doc: Symbol.
    seq:
      - id: symbol
        type: u4
      - id: label
        type: u4

  debug_string:
    doc: Debug string.
    seq:
      - id: sentinel
        contents: [0x01]
      - id: string
        type: string_def

  exceptions_table:
    doc: Exceptions table.
    seq:
      - id: exceptions_table_entries
        type: exception_table_entry
        repeat: eos

  exception_table_entry:
    doc: Exception table entry.
    seq:
      - id: try_begin
        type: b24
      - id: try_end
        type: b24
      - id: handle_begin
        type: b24

  permissions:
    doc: List of permissions.
    seq:
      - id: permission_entry
        type: permission_entry
        repeat: eos

  permission_entry:
    doc: Permission entry.
    seq:
      - id: permission_id
        type: u4

  link_table_entries:
    doc: Link table entries.
    seq:
      - id: link_table_entries
        type: link_table_entry
        repeat: eos

  link_table_entry:
    doc: Link table entry.
    seq:
      - id: module_id
        type: u4
        enum: ciq_sdk_symbols
      - id: class_id
        type: u4
        enum: ciq_sdk_symbols

  line_number_entries:
    doc: Line number entries.
    seq:
      - id: line_number_entry
        type: line_number_entry
        repeat: eos

  line_number_entry:
    doc: Line number entry.
    seq:
      - id: pc
        type: u4
      - id: file
        type: u4
      - id: symbol
        type: u4
      - id: line_num
        type: u4

  op_code:
    doc: OP code
    seq:
      - id: op_code
        type: u1
        enum: op_code_enum
      - id: arg1
        type:
          switch-on: op_code
          cases:
            op_code_enum::lpush: u8
            op_code_enum::dpush: u8
            op_code_enum::ipush: u4
            op_code_enum::fpush: u4
            op_code_enum::spush: u4
            op_code_enum::cpush: u4
            op_code_enum::news: u4
            op_code_enum::goto: u2
            op_code_enum::bt: u2
            op_code_enum::bf: u2
            op_code_enum::jsr: u2
            op_code_enum::shlv: u1
            op_code_enum::shrv: u1
            op_code_enum::lgetv: u1
            op_code_enum::lputv: u1
            op_code_enum::invoke: u1
            op_code_enum::argc: u1
            op_code_enum::incsp: u1
            op_code_enum::bpush: u1
            op_code_enum::dup: u1
            # 2024 update
            op_code_enum::ipush1: u1
            op_code_enum::ipush2: u2
            op_code_enum::ipush3: u3
            op_code_enum::apush: u4
            op_code_enum::bapush: u4
            op_code_enum::hpush: u4
            op_code_enum::getselfv: u4
            op_code_enum::getmv: u4  # takes 2 params, u4 u4, so u8 total
            op_code_enum::getlocalv: u1  # takes 2 params, u1 u4, so u5 total
            op_code_enum::getsv: u4
            op_code_enum::argcincsp: u2
            op_code_enum::lgoto: u4
            # Remaining opcodes do not take arguments.
      - id: arg2
        type:
          switch-on: op_code
          cases:
            op_code_enum::getmv: u4  # takes 2 params, u4 u4, so u8 total
            op_code_enum::getlocalv: u4  # takes 2 params, u1 u4, so u5 total
    instances:
      arg1_symbol_name:
          value: arg1
          enum: ciq_sdk_symbols
          if: op_code == op_code_enum::spush or
              op_code == op_code_enum::getselfv or
              op_code == op_code_enum::getmv or
              op_code == op_code_enum::getsv
      arg2_symbol_name:
          value: arg2
          enum: ciq_sdk_symbols
          if: op_code == op_code_enum::getmv or
              op_code == op_code_enum::getlocalv

  data_entry:
    doc: Data entry.
    seq:
      # FIXME: Sentinal can be 1 or 4 bytes. Currently treating it as 1 byte, and the remaining 3 bytes are consumed by the corresponding data entry.
      - id: sentinel
        type: u1
      - id: data
        type:
          switch-on: sentinel
          cases:
            0x01: string_def
            0x03: container_def
            0xc1: class_def  # 0xc1a55def
            0xc2: class_def  # 0xc2a55def

  connect_iq_version:
    doc: Connect IQ Version.
    seq:
      - id: major
        type: u1
      - id: minor
        type: u1
      - id: micro
        type: u1

  offsets:
    doc: Offsets.
    seq:
      - id: m_data_offset
        type: u4
      - id: m_code_offset
        type: u4

  entry_point:
    doc: Entry point.
    seq:
      - id: uuid
        size: 16
      - id: module_id
        type: u4
        enum: ciq_sdk_symbols
      - id: class_id
        type: u4
      - id: label_id
        type: u4
      - id: icon_label_id
        type: u4
      - id: app_type
        type: u4
        enum: app_type

  class_def:
    doc: Unified class definition (v1 and v2).
    seq:
      - id: sentinel_fragment
        size: 3  # FIXME: See data_entries and how to handle variable-sized sentinels
      - id: flags
        type: u1
        if: _parent.sentinel == 0xc2
      - id: extends_offset
        type: u4
        if: _parent.sentinel == 0xc1
      - id: extended_offsets
        type: u4
        if: _parent.sentinel == 0xc2 and (flags & 1) != 0
      - id: statics_entry
        type: u4
        if: _parent.sentinel == 0xc1
      - id: static_entry
        type: u4
        if: _parent.sentinel == 0xc2 and (flags & 2) != 0
      - id: parent_module_id
        type: u4
        enum: ciq_sdk_symbols
        if: _parent.sentinel == 0xc1 or (_parent.sentinel == 0xc2 and (flags & 4) != 0)
      - id: module_id
        type: u4
        enum: ciq_sdk_symbols
        if: _parent.sentinel == 0xc1 or (_parent.sentinel == 0xc2 and (flags & 8) != 0)
      - id: app_types
        type: u2
      - id: fields_size_raw_u1
        type: u1
        if: _parent.sentinel == 0xc1
      - id: fields_size_raw_u2
        type: u2
        if: _parent.sentinel == 0xc2
      # FIXME: Hardcoding size of v1 (8 bytes) and v2 (9 bytes) field def for now
      - id: fields_def
        type: fields_def(_parent.sentinel == 0xc2)
        # NOTE: Single-quotes to keep valid YAML syntax. See caution note under 6.3.5 in https://doc.kaitai.io/user_guide.html#_operators
        size: '_parent.sentinel == 0xc2 ? fields_size_raw_u2 * 9 : fields_size_raw_u1 * 8'
    instances:
      is_v2:
        value: _parent.sentinel == 0xc2
      fields_size:
        # NOTE: Single-quotes to keep valid YAML syntax. See caution note under 6.3.5 in https://doc.kaitai.io/user_guide.html#_operators
        value: '_parent.sentinel == 0xc1 ? fields_size_raw_u1 : fields_size_raw_u2'
      permission_required:
        value: (app_types & 0x8000) != 0
      actual_app_types:
        value: (app_types & 0xFFFF7FFF) & 0xFFFF

  string_def:
    doc: String definition.
    seq:
      - id: length
        type: u2
      - id: data
        type: str
        encoding: UTF-8
        size: length + 1

  container_def:
    doc: Container (JSON) definition.
    seq:
      - id: len_data
        type: u4
      # TODO: parse the data; magic 0xabcdabcd
      - id: data
        size: len_data

  fields_def:
    doc: List of field definitions
    params:
      - id: is_v2
        type: bool
    seq:
      - id: field
        type: field_def(is_v2)
        repeat: eos

  field_def:
    doc: Unified field definition (v1 and v2)
    params:
      - id: is_v2
        type: bool
    seq:
      - id: code_offset
        type: u4
      - id: type_raw
        type: u1
        if: is_v2
      - id: field_value
        type: u4

    instances:
      symbol_value:
        value: (code_offset >> 8 & 0xFFFFFF)
        enum: ciq_sdk_symbols
      value_type:
        value: (code_offset & 0xF)
      flags:
        value: (code_offset >> 4 & 0xF)
      section_location:
        value: field_value & 0xF0000000
        enum: section_type
      type:
        # NOTE: Single-quotes to keep valid YAML syntax. See caution note under 6.3.5 in https://doc.kaitai.io/user_guide.html#_operators
        value: 'is_v2 ? type_raw : value_type'
        enum: field_type

enums:
  section_magic:
    0x00000000: end
    0xd000d000: head
    0xd000d00d: head_versioned
    0xc0debabe: code
    0xc0de10ad: code_extended
    0xda7ababe: data
    0xc0de7ab1: pc_to_line_num
    0x6060c0de: entry_points
    0xc1a557b1: link_table
    0x6000db01: permissions
    0x0ece7105: exceptions
    0x5717b015: symbols
    0xbaada555: string_resource_symbols
    0x5e771465: settings
    0xd011aaa5: app_unlock
    0xf00d600d: resource
    0xdefeca7e: background_resource
    0xd00dface: glance_resource
    0x00005161: app_store_signature
    0xe1c0de12: developer_signature
    0xd0000d1e: debug
    0xfaceda7a: complication
  app_type:
    0: watch_face
    1: watch_app
    2: datafield
    3: widget
    4: background
    5: audio_content_provider_app
    6: glance
  field_type:
    0: znull
    1: int
    2: float
    3: string
    5: array
    6: method
    7: class
    8: symbol
    9: boolean
    10: module
    11: hash
    14: long
    15: double
    19: char
    20: bytearray
  section_type:
    0x0: data
    0x10000000: code
    0x20000000: api_data
    0x30000000: api_code
    0x40000000: native
    0x80000000: label
  op_code_enum:
    0x00: nop  # 1 byte
    0x01: incsp  # 2 bytes
    0x02: popv  # 1 byte
    0x03: addv  # 1 byte
    0x04: subv  # 1 byte
    0x05: mulv  # 1 byte
    0x06: divv  # 1 byte
    0x07: andv  # 1 byte
    0x08: orv  # 1 byte
    0x09: modv  # 1 byte
    0x0a: shlv  # 2 bytes
    0x0b: shrv  # 2 bytes
    0x0c: xorv  # 1 byte
    0x0d: getv  # 1 byte
    0x0e: putv  # 1 byte
    0x0f: invoke  # 2 bytes
    0x10: agetv  # 1 byte
    0x11: aputv  # 2 bytes
    0x12: lgetv  # 2 bytes
    0x13: lputv  # 2 bytes
    0x14: newa  # 1 byte
    0x15: newc  # 1 byte
    0x16: return  # 1 byte
    0x17: ret  # 1 byte
    0x18: news  # 5 bytes
    0x19: goto  # 3 bytes
    0x1a: eq  # 1 byte
    0x1b: lt  # 1 byte
    0x1c: lte  # 1 byte
    0x1d: gt  # 1 byte
    0x1e: gte  # 1 byte
    0x1f: ne  # 1 byte
    0x20: isnull  # 1 byte
    0x21: isa  # 1 byte
    0x22: canhazplz  # 1 byte
    0x23: jsr  # 3 bytes
    0x24: ts  # 1 byte
    0x25: ipush  # 5 bytes
    0x26: fpush  # 5 bytes
    0x27: spush  # 5 bytes
    0x28: bt  # 3 bytes
    0x29: bf  # 3 bytes
    0x2a: frpush  # 1 byte
    0x2b: bpush  # 2 bytes
    0x2c: npush  # 1 byte
    0x2d: invv  # 1 byte
    0x2e: dup  # 2 bytes
    0x2f: newd  # 1 byte
    0x30: getm  # 1 byte
    0x31: lpush  # 9 bytes
    0x32: dpush  # 9 bytes
    0x33: throw  # 1 byte
    0x34: cpush  # 5 bytes
    0x35: argc  # 2 bytes
    0x36: newba  # 1 byte
    # op code v2
    0x37: ipushz  # 1 byte
    0x38: ipush1  # 2 bytes
    0x39: ipush2  # 3 bytes
    0x3a: ipush3  # 4 bytes
    0x3b: fpushz  # 1 byte
    0x3c: lpushz  # 1 byte
    0x3d: dpushz  # 1 byte
    0x3e: btpush  # 1 byte
    0x3f: bfpush  # 1 byte
    0x40: apush  # 5 bytes
    0x41: bapush  # 5 bytes
    0x42: hpush  # 5 bytes
    0x43: getselfv  # 5 bytes
    0x44: getself  # 1 byte
    0x45: getmv  # 9 bytes
    0x46: getlocalv  # 6 bytes
    0x47: getsv  # 5 bytes
    0x48: invokemz  # 1 byte
    0x49: aputvdup  # 1 byte
    0x4a: argcincsp  # 3 bytes
    0x4b: isnotnull  # 1 byte
    0x4c: lgoto  # 5 bytes

  # FIXME: For some unknown reasons, the import does not seem to resolve 'ciq_sdk::symbols'
  # So I am copying them again here as a temporary solution
  ciq_sdk_symbols:
    8391942: s__toybox_ant_burstpayload___burstdatablob_
    8391943: s__toybox_ant_burstpayload___size_
    8390629: s__toybox_cryptography_cipherbasedmessageauthenticationcode___mcontext_
    8390630: s__toybox_cryptography_cipherbasedmessageauthenticationcode___mkey_
    8390529: s__toybox_cryptography_cipher___mcontext_
    8390528: s__toybox_cryptography_cipher___moptions_
    8390627: s__toybox_cryptography_hashbasedmessageauthenticationcode___mcontext_
    8390628: s__toybox_cryptography_hashbasedmessageauthenticationcode___mkey_
    8390527: s__toybox_cryptography_hash___mcontext_
    8390526: s__toybox_cryptography_hash___moptions_
    8390770: s__toybox_cryptography_keyagreement___mprivatekey_
    8390769: s__toybox_cryptography_keyagreement___mprotocol_
    8390611: s__toybox_cryptography_keyagreement___msharedsecret_
    8390616: s__toybox_cryptography_keypair___malgorithm_
    8390617: s__toybox_cryptography_keypair___mbitsize_
    8390614: s__toybox_cryptography_keypair___mprivatekey_
    8390615: s__toybox_cryptography_keypair___mpublickey_
    8390608: s__toybox_cryptography_key___malgorithm_
    8390607: s__toybox_cryptography_key___mbytes_
    8392165: s__toybox_graphics_affinetransform___mtransform_
    8391772: s__toybox_graphics_bitmapreference___initialize_
    8391777: s__toybox_graphics_bitmaptexture___mbitmap_
    8391778: s__toybox_graphics_bitmaptexture___mxoffset_
    8391779: s__toybox_graphics_bitmaptexture___myoffset_
    8391775: s__toybox_graphics_bufferedbitmapreference___initialize_
    8391765: s__toybox_graphics_bufferedbitmap___miscached_
    8391733: s__toybox_graphics_dc___mblendmode_
    8391734: s__toybox_graphics_dc___mfill_
    8391735: s__toybox_graphics_dc___mstroke_
    8391773: s__toybox_graphics_fontreference___initialize_
    8391774: s__toybox_graphics_resourcereference___allocatebufferedbitmap_
    8391764: s__toybox_graphics_resourcereference___getcached_
    8391762: s__toybox_graphics_resourcereference___mid_
    8391761: s__toybox_graphics_resourcereference___moptions_
    8391763: s__toybox_graphics_resourcereference___mtype_
    8391760: s__toybox_graphics_resourcereference___mweakresourcereference_
    8392218: s__toybox_graphics_vectorfont___initialize_
    8392217: s__toybox_graphics_vectorfont___mfont_
    8390764: s__toybox_media_activecontent___mplaybackstartpos_
    8391044: s__toybox_media_systembutton___mdisabled_
    8391043: s__toybox_media_systembutton___mtype_
    8391881: s__toybox_sensorlogging_sensorlogger___maccelstats_
    8391882: s__toybox_sensorlogging_sensorlogger___mgyrostats_
    8391883: s__toybox_sensorlogging_sensorlogger___mmagstats_
    8391505: s__toybox_system_appinfo___miconid_
    8391862: s__toybox_userprofile_useractivityhistoryiterator___mcount_
    8391861: s__toybox_userprofile_useractivityhistoryiterator___mdata_
    8391860: s__toybox_userprofile_useractivityhistoryiterator___mindex_
    8391430: s__toybox_watchui_animationlayer___animation_
    8392305: s__toybox_watchui_custommenuitem___mdividericon_
    8390746: s__toybox_watchui_custommenuitem___mdrawable_
    8390745: s__toybox_watchui_custommenuitem___mfocused_
    8390744: s__toybox_watchui_custommenuitem___mselected_
    8390733: s__toybox_watchui_custommenu___mbackgroundcolor_
    8390731: s__toybox_watchui_custommenu___mcustomtitle_
    8390730: s__toybox_watchui_custommenu___mfocusitemheight_
    8390732: s__toybox_watchui_custommenu___mfooter_
    8391793: s__toybox_watchui_custommenu___mfooteritemheight_
    8391074: s__toybox_watchui_custommenu___mfooterselected_
    8390734: s__toybox_watchui_custommenu___mforeground_
    8390729: s__toybox_watchui_custommenu___mitemheight_
    8391792: s__toybox_watchui_custommenu___mtitleitemheight_
    8391073: s__toybox_watchui_custommenu___mtitleselected_
    8391432: s__toybox_watchui_layer___dc_
    8391431: s__toybox_watchui_layer___id_
    8391435: s__toybox_watchui_layer___visible_
    8391433: s__toybox_watchui_layer___x_
    8391434: s__toybox_watchui_layer___y_
    8390571: s__toybox_watchui_mapmarker___micon_
    8390572: s__toybox_watchui_mapmarker___mlabel_
    8390570: s__toybox_watchui_mapmarker___mlocation_
    8390573: s__toybox_watchui_mapmarker___mx_
    8390574: s__toybox_watchui_mapmarker___my_
    8390591: s__toybox_watchui_mappolyline___mcolor_
    8390590: s__toybox_watchui_mappolyline___mlocations_
    8390592: s__toybox_watchui_mappolyline___mwidth_
    8390598: s__toybox_watchui_mapview___mdefaultbboxlocationbottomright_
    8390597: s__toybox_watchui_mapview___mdefaultbboxlocationtopleft_
    8390579: s__toybox_watchui_mapview___mmaplocationbottomright_
    8390578: s__toybox_watchui_mapview___mmaplocationtopleft_
    8390577: s__toybox_watchui_mapview___mmarkers_
    8390584: s__toybox_watchui_mapview___mmode_
    8390576: s__toybox_watchui_mapview___mpolyline_
    8390582: s__toybox_watchui_mapview___mscreenareabottomrightx_
    8390583: s__toybox_watchui_mapview___mscreenareabottomrighty_
    8390580: s__toybox_watchui_mapview___mscreenareatopleftx_
    8390581: s__toybox_watchui_mapview___mscreenareatoplefty_
    8391316: s__toybox_watchui_menu___getitemtitle_
    8392048: s__toybox_watchui_reviewresponsetoken___initialize_
    8391313: s__toybox_watchui_textarea___fittexttoarea_
    8391308: s__toybox_watchui_textarea___mbackgroundcolor_
    8391307: s__toybox_watchui_textarea___mcolor_
    8391312: s__toybox_watchui_textarea___mfitfont_
    8391311: s__toybox_watchui_textarea___mfittext_
    8391305: s__toybox_watchui_textarea___mfonts_
    8391306: s__toybox_watchui_textarea___mjustification_
    8391310: s__toybox_watchui_textarea___mpreviousheight_
    8391309: s__toybox_watchui_textarea___mpreviouswidth_
    8391304: s__toybox_watchui_textarea___mtext_
    8391957: s__toybox_watchui_viewloopdelegate___mviewloop_
    8391951: s__toybox_watchui_viewloop___mcolor_
    8391949: s__toybox_watchui_viewloop___mfactory_
    8391954: s__toybox_watchui_viewloop___mid_
    8391950: s__toybox_watchui_viewloop___mindex_
    8391952: s__toybox_watchui_viewloop___mwrap_
    8392057: s__toybox_watchui_view___mclockstate_
    8391891: s__toybox_watchui_view___mcontrolbaroptions_
    8391804: s__toybox_watchui_view___mhourhandposition_
    8391438: s__toybox_watchui_view___mlayers_
    8391803: s__toybox_watchui_view___mminutehandposition_
    8391902: s__toybox_watchui_view___updateclockhandposition_
    8389920: ara
    8389921: bul
    8389352: ces
    8389372: chs
    8389371: cht
    8389353: dan
    8389358: deu
    8389354: dut
    8389355: eng
    8390796: est
    8389356: fin
    8389357: fre
    8389359: gre
    8389919: heb
    8389361: hrv
    8389360: hun
    8389578: ind
    8388632: init
    8389362: ita
    8389373: jpn
    8389696: kor
    8390797: lav
    8390798: lit
    8389363: nob
    8389364: pol
    8389365: por
    8390799: ron
    8389366: rus
    8389367: slo
    8389368: slv
    8389369: spa
    8389370: swe
    8389548: tha
    8389774: tur
    8390800: ukr
    8389351: valyrian
    8390206: vie
    8389579: zsm
    8392156: action_menu_theme_dark
    8392157: action_menu_theme_light
    8391798: alpha_blending_full
    8391800: alpha_blending_none
    8391799: alpha_blending_partial
    8392056: analog_clock_state_holding
    8392054: analog_clock_state_resting
    8392055: analog_clock_state_system_time
    8391280: animation_event_canceled
    8391279: animation_event_complete
    8389007: anim_type_ease_in
    8389009: anim_type_ease_in_out
    8389008: anim_type_ease_out
    8389006: anim_type_linear
    8391677: applog_generic
    8391678: applog_musicsignin
    8392281: app_install_state_event_installed
    8392283: app_install_state_event_uninstalled
    8392282: app_install_state_event_updated
    8391491: app_type_app
    8391494: app_type_audio_content_provider
    8391492: app_type_data_field
    8391490: app_type_watch_face
    8391493: app_type_widget
    8389686: arc_clockwise
    8389685: arc_counter_clockwise
    8390192: accelerometerdata
    8391935: actionmenu
    8391939: actionmenudelegate
    8392155: actionmenuitem
    8390762: activecontent
    8389865: activeminutes
    8388631: activity
    8388633: activitymonitor
    8388638: activityrecording
    8392164: affinetransform
    8390332: albumart
    8391281: animationdelegate
    8391429: animationlayer
    8391278: animationresource
    8388634: ant
    8389410: antplus
    8391209: antplusnotallowedexception
    8389276: appbase
    8391495: appinfo
    8389944: appnotinstalledexception
    8388635: application
    8388766: array
    8389791: assertexception
    8388636: attention
    8390423: audiocontentproviderapp
    8390446: audioformat
    8391867: authentication
    8389417: batt_status_cnt
    8389415: batt_status_critical
    8389412: batt_status_good
    8389416: batt_status_invalid
    8389414: batt_status_low
    8389411: batt_status_new
    8389413: batt_status_ok
    8389072: behavior_next_page
    8389071: behavior_none
    8389075: behavior_on_back
    8389074: behavior_on_menu
    8389076: behavior_on_next_mode
    8389077: behavior_on_previous_mode
    8389618: behavior_on_select
    8389073: behavior_previous_page
    8389431: bike_power_sensor_type_cnt
    8389429: bike_power_sensor_type_crank_torque
    8389430: bike_power_sensor_type_crank_torque_frequency
    8389426: bike_power_sensor_type_none
    8389427: bike_power_sensor_type_power_only
    8389428: bike_power_sensor_type_wheel_torque
    8392224: blend_mode_additive
    8391725: blend_mode_default
    8392223: blend_mode_multiply
    8391726: blend_mode_no_blend
    8392222: blend_mode_source
    8392221: blend_mode_source_over
    8388809: ble_connection_unavailable
    8388801: ble_error
    8388802: ble_host_timeout
    8388804: ble_no_data
    8388806: ble_queue_full
    8388805: ble_request_cancelled
    8388807: ble_request_too_large
    8388803: ble_server_timeout
    8388808: ble_unknown_send_error
    8390252: body_location_left_leg
    8390253: body_location_right_leg
    8390254: body_location_torso_front
    8390256: body_location_waist_front
    8390257: body_location_waist_left
    8390255: body_location_waist_mid_back
    8390258: body_location_waist_right
    8390049: burst_error_out_of_memory
    8390051: burst_error_rf_fail
    8390050: burst_error_sequence_number_fail
    8390052: burst_error_transfer_in_progress
    8391030: button_image_detail
    8391029: button_image_icon
    8391053: button_input_clock
    8389668: button_input_down
    8391054: button_input_down_left
    8391055: button_input_down_right
    8391056: button_input_esc
    8391057: button_input_find
    8391058: button_input_lap
    8391059: button_input_left
    8391060: button_input_light
    8389669: button_input_menu
    8391061: button_input_mode
    8391062: button_input_page
    8391063: button_input_power
    8391064: button_input_reset
    8391065: button_input_right
    8389666: button_input_select
    8391066: button_input_sport
    8391067: button_input_start
    8389667: button_input_up
    8391068: button_input_up_left
    8391069: button_input_up_right
    8391070: button_input_zin
    8391071: button_input_zout
    8391025: button_state_all
    8391021: button_state_default
    8391022: button_state_disabled
    8391027: button_state_negative
    8391028: button_state_neutral
    8391024: button_state_off
    8391023: button_state_on
    8391026: button_state_positive
    8390146: background
    8391451: backgroundrez
    8391723: backlightontoolongexception
    8390444: barrels
    8389976: batterystatus
    8388708: behaviordelegate
    8390659: bikecadence
    8390658: bikecadenceinfo
    8390660: bikecadencelistener
    8390012: bikelight
    8389439: bikepower
    8390017: bikepowerlistener
    8390638: bikeradar
    8390639: bikeradarlistener
    8390663: bikespeed
    8390666: bikespeedcadence
    8390665: bikespeedcadenceinfo
    8390667: bikespeedcadencelistener
    8390662: bikespeedinfo
    8390664: bikespeedlistener
    8389059: bitmap
    8391758: bitmapreference
    8389053: bitmapresource
    8391776: bitmaptexture
    8391234: bledelegate
    8391193: bluetoothlowenergy
    8388762: boolean
    8391806: boundingbox
    8390101: bufferedbitmap
    8391771: bufferedbitmapreference
    8390055: burstlistener
    8390053: burstpayload
    8390054: burstpayloaditerator
    8389885: button
    8390562: bytearray
    8389232: channel_type_rx_not_tx
    8389632: channel_type_rx_only
    8391447: channel_type_shared_bidirectional_receive
    8391448: channel_type_shared_bidirectional_transmit
    8389231: channel_type_tx_not_rx
    8390542: char_encoding_utf8
    8390504: cipher_aes128
    8390505: cipher_aes256
    8389012: click_type_hold
    8389013: click_type_release
    8389011: click_type_tap
    8389160: color_black
    8389167: color_blue
    8389168: color_dk_blue
    8389159: color_dk_gray
    8389166: color_dk_green
    8389162: color_dk_red
    8389165: color_green
    8389158: color_lt_gray
    8389163: color_orange
    8389170: color_pink
    8389169: color_purple
    8389161: color_red
    8389171: color_transparent
    8389157: color_white
    8389164: color_yellow
    8391986: complication_type_altitude
    8391972: complication_type_battery
    8391994: complication_type_body_battery
    8391983: complication_type_calendar_events
    8391974: complication_type_calories
    8392006: complication_type_current_temperature
    8391979: complication_type_current_weather
    8391977: complication_type_date
    8391975: complication_type_floors_climbed
    8391980: complication_type_forecast_weather_1day
    8391981: complication_type_forecast_weather_2day
    8391982: complication_type_forecast_weather_3day
    8391989: complication_type_heart_rate
    8392007: complication_type_high_low_temperature
    8391976: complication_type_intensity_minutes
    8391971: complication_type_invalid
    8392271: complication_type_last_golf_round_score
    8391988: complication_type_notification_count
    8392003: complication_type_pulse_ox
    8392033: complication_type_race_pace_predictor_10k
    8392032: complication_type_race_pace_predictor_5k
    8392034: complication_type_race_pace_predictor_half_marathon
    8392035: complication_type_race_pace_predictor_marathon
    8391999: complication_type_race_predictor_10k
    8391998: complication_type_race_predictor_5k
    8392000: complication_type_race_predictor_half_marathon
    8392001: complication_type_race_predictor_marathon
    8391992: complication_type_recovery_time
    8392004: complication_type_respiration_rate
    8391987: complication_type_sea_level_pressure
    8392005: complication_type_solar_input
    8391973: complication_type_steps
    8391993: complication_type_stress
    8391984: complication_type_sunrise
    8391985: complication_type_sunset
    8391997: complication_type_training_status
    8391996: complication_type_vo2max_bike
    8391995: complication_type_vo2max_run
    8391978: complication_type_weekday_monthday
    8391991: complication_type_weekly_bike_distance
    8391990: complication_type_weekly_run_distance
    8392208: complication_type_wheelchair_pushes
    8391650: condition_chance_of_rain_snow
    8391633: condition_chance_of_showers
    8391649: condition_chance_of_snow
    8391634: condition_chance_of_thunderstorms
    8391606: condition_clear
    8391626: condition_cloudy
    8391651: condition_cloudy_chance_of_rain
    8391653: condition_cloudy_chance_of_rain_snow
    8391652: condition_cloudy_chance_of_snow
    8391637: condition_drizzle
    8391636: condition_dust
    8391646: condition_fair
    8391654: condition_flurries
    8391614: condition_fog
    8391655: condition_freezing_rain
    8391616: condition_hail
    8391645: condition_haze
    8391615: condition_hazy
    8391621: condition_heavy_rain
    8391625: condition_heavy_rain_snow
    8391632: condition_heavy_showers
    8391623: condition_heavy_snow
    8391647: condition_hurricane
    8391640: condition_ice
    8391657: condition_ice_snow
    8391620: condition_light_rain
    8391624: condition_light_rain_snow
    8391630: condition_light_showers
    8391622: condition_light_snow
    8391635: condition_mist
    8391629: condition_mostly_clear
    8391608: condition_mostly_cloudy
    8391628: condition_partly_clear
    8391607: condition_partly_cloudy
    8391609: condition_rain
    8391627: condition_rain_snow
    8391641: condition_sand
    8391643: condition_sandstorm
    8391617: condition_scattered_showers
    8391618: condition_scattered_thunderstorms
    8391631: condition_showers
    8391656: condition_sleet
    8391639: condition_smoke
    8391610: condition_snow
    8391642: condition_squall
    8391658: condition_thin_clouds
    8391612: condition_thunderstorms
    8391638: condition_tornado
    8391648: condition_tropical_storm
    8391659: condition_unknown
    8391619: condition_unknown_precipitation
    8391644: condition_volcanic_ash
    8391611: condition_windy
    8391613: condition_wintry_mix
    8392036: configuration_gps
    8392039: configuration_gps_beidou
    8392038: configuration_gps_galileo
    8392037: configuration_gps_glonass
    8392040: configuration_gps_glonass_galileo_beidou_l1
    8392041: configuration_gps_glonass_galileo_beidou_l1_l5
    8392042: configuration_sat_iq
    8389029: confirm_no
    8389030: confirm_yes
    8390480: connection_state_connected
    8391221: connection_state_disconnected
    8390479: connection_state_not_connected
    8390478: connection_state_not_initialized
    8391383: connect_server_china
    8391382: connect_server_production
    8391385: connect_server_stage
    8391384: connect_server_test
    8391381: connect_server_unknown
    8391707: constellation_galileo
    8391706: constellation_glonass
    8391705: constellation_gps
    8390310: content_type_audio
    8390309: content_type_invalid
    8391887: control_bar_left_button_back
    8391888: control_bar_left_button_cancel
    8391889: control_bar_right_button_accept
    8391890: control_bar_right_button_menu
    8391112: current_time_default
    8391113: current_time_gps
    8391114: current_time_rtc
    8390325: cachestatistics
    8390015: calculatedcadence
    8389433: calculatedpower
    8389435: calculatedwheeldistance
    8389436: calculatedwheelspeed
    8389233: channelassignment
    8389821: char
    8391236: characteristic
    8390390: checkboxmenu
    8390392: checkboxmenuitem
    8390510: cipher
    8390626: cipherbasedmessageauthenticationcode
    8391496: ciqinstallinfo
    8389014: clickevent
    8388709: clocktime
    8389418: commondata
    8388637: communications
    8392013: complication
    8392162: complicationnotfoundexception
    8391962: complications
    8389031: confirmation
    8389032: confirmationdelegate
    8390481: connectioninfo
    8388825: connectionlistener
    8390334: content
    8390336: contentdelegate
    8390335: contentiterator
    8390333: contentmetadata
    8390324: contentref
    8390323: contentrefiterator
    8389959: course
    8390113: cryptoconfig
    8390501: cryptography
    8391660: currentconditions
    8391032: custombutton
    8390727: custommenu
    8390728: custommenuitem
    8389239: data_payload_length
    8389862: data_type_double
    8389861: data_type_float
    8389856: data_type_sint16
    8389858: data_type_sint32
    8389854: data_type_sint8
    8389860: data_type_string
    8389857: data_type_uint16
    8389859: data_type_uint32
    8389855: data_type_uint8
    8390703: day_friday
    8390699: day_monday
    8390704: day_saturday
    8390698: day_sunday
    8390702: day_thursday
    8390700: day_tuesday
    8390701: day_wednesday
    8389262: default_device_number
    8389263: default_device_type
    8390117: default_encryption_id
    8389265: default_message_period
    8389636: default_network_key
    8389266: default_radio_frequency
    8389268: default_search_timeout_high
    8389267: default_search_timeout_low
    8389269: default_threshold
    8389264: default_transmission_type
    8390120: default_user_info_string
    8389420: device_state_closed
    8389423: device_state_cnt
    8389419: device_state_dead
    8389421: device_state_searching
    8389422: device_state_tracking
    8390018: device_type_bike_light
    8389510: device_type_bike_power
    8390641: device_type_bike_radar
    8390672: device_type_cadence
    8390290: device_type_fe
    8390266: device_type_running_dynamics
    8391365: device_type_shifting
    8390668: device_type_spd_cad
    8390670: device_type_speed
    8391947: direction_next
    8391948: direction_previous
    8392290: display_mode_high_power
    8392291: display_mode_low_power
    8392292: display_mode_off
    8392298: divider_type_default
    8392299: divider_type_icon
    8391819: drag_type_continue
    8391818: drag_type_start
    8391820: drag_type_stop
    8391664: dailyforecast
    8389024: datafield
    8391697: datafieldalert
    8389176: dc
    8391359: derailleurstatus
    8391237: descriptor
    8389425: device
    8389234: deviceconfig
    8389979: devicelistener
    8391242: devicepairexception
    8389397: devicesettings
    8389424: devicestate
    8388650: dictionary
    8388761: double
    8391821: dragevent
    8389058: drawable
    8388771: drawables
    8388921: duration
    8388894: e
    8390312: encoding_adts
    8390311: encoding_invalid
    8390314: encoding_m4a
    8390313: encoding_mp3
    8390315: encoding_wav
    8390118: encryption_key_length
    8391203: endian_big
    8391202: endian_little
    8389556: extended_keys
    8390116: encryptioninvalidsettingsexception
    8388768: exception
    8390167: exitdatasizelimitexception
    8392226: filter_mode_bilinear
    8392225: filter_mode_point
    8391917: flashlight_brightness_high
    8391915: flashlight_brightness_low
    8391916: flashlight_brightness_medium
    8391913: flashlight_color_green
    8391914: flashlight_color_red
    8391912: flashlight_color_white
    8391909: flashlight_mode_off
    8391910: flashlight_mode_on
    8391911: flashlight_mode_strobe
    8391930: flashlight_result_failure
    8391927: flashlight_result_invalid_brightness
    8391926: flashlight_result_invalid_color
    8391928: flashlight_result_invalid_mode
    8391929: flashlight_result_invalid_speed
    8391925: flashlight_result_success
    8391920: flashlight_strobe_mode_beacon
    8391918: flashlight_strobe_mode_blink
    8391921: flashlight_strobe_mode_blitz
    8391919: flashlight_strobe_mode_pulse
    8391924: flashlight_strobe_speed_fast
    8391923: flashlight_strobe_speed_medium
    8391922: flashlight_strobe_speed_slow
    8392237: font_aux1
    8392238: font_aux2
    8392251: font_aux3
    8392252: font_aux4
    8392253: font_aux5
    8392254: font_aux6
    8392255: font_aux7
    8392256: font_aux8
    8392257: font_aux9
    8391464: font_glance
    8391465: font_glance_number
    8389156: font_large
    8389155: font_medium
    8389387: font_number_hot
    8389386: font_number_medium
    8389385: font_number_mild
    8389388: font_number_thai_hot
    8389154: font_small
    8389908: font_system_large
    8389907: font_system_medium
    8389911: font_system_number_hot
    8389910: font_system_number_medium
    8389909: font_system_number_mild
    8389912: font_system_number_thai_hot
    8389906: font_system_small
    8389905: font_system_tiny
    8389904: font_system_xtiny
    8389153: font_tiny
    8389152: font_xtiny
    8390506: format_hex_string
    8388919: format_long
    8388918: format_medium
    8388917: format_short
    8391356: front_gear_invalid
    8389863: field
    8390089: filter
    8390090: firfilter
    8389780: fitcontributor
    8390250: fitnessequipment
    8390249: fitnessequipmentdata
    8390251: fitnessequipmentlistener
    8390244: fitnessequipmentmode
    8391822: flickevent
    8388760: float
    8391759: fontreference
    8389052: fontresource
    8388772: fonts
    8389139: gender_female
    8389140: gender_male
    8392211: gender_unspecified
    8389289: geo_deg
    8389290: geo_dm
    8389291: geo_dms
    8389292: geo_mgrs
    8391746: glance_theme_blue
    8391745: glance_theme_default
    8391747: glance_theme_gold
    8391748: glance_theme_green
    8391749: glance_theme_light_blue
    8391752: glance_theme_purple
    8391750: glance_theme_red
    8391751: glance_theme_white
    8389915: goal_type_active_minutes
    8389914: goal_type_floors_climbed
    8389913: goal_type_steps
    8391755: graphics_resource_type_bitmap
    8391756: graphics_resource_type_font
    8389235: genericchannel
    8388884: geometryiterator
    8391459: glancerez
    8391454: glanceview
    8391455: glanceviewdelegate
    8388639: graphics
    8388924: gregorian
    8391850: gyroscopedata
    8390694: hash_md5
    8390502: hash_sha1
    8390503: hash_sha256
    8391107: hls_audio_bandwidth_128k
    8391108: hls_audio_bandwidth_256k
    8391106: hls_audio_bandwidth_48k
    8389755: hr_zone_sport_biking
    8389753: hr_zone_sport_generic
    8389754: hr_zone_sport_running
    8389756: hr_zone_sport_swimming
    8389591: http_request_method_delete
    8389588: http_request_method_get
    8389590: http_request_method_post
    8389589: http_request_method_put
    8391208: http_response_content_type_animation
    8391207: http_response_content_type_animation_manifest
    8390216: http_response_content_type_audio
    8389967: http_response_content_type_fit
    8389966: http_response_content_type_gpx
    8391105: http_response_content_type_hls_download
    8389833: http_response_content_type_json
    8391595: http_response_content_type_prg
    8390650: http_response_content_type_text_plain
    8389834: http_response_content_type_url_encoded
    8390509: hash
    8390625: hashbasedmessageauthenticationcode
    8390652: heartratedata
    8389701: heartrateiterator
    8389700: heartratesample
    8388908: history
    8391662: hourlyforecast
    8389693: image_dithering_floyd_steinberg
    8389692: image_dithering_none
    8390320: image_format_invalid
    8390321: image_format_jpeg
    8390322: image_format_png
    8390657: invalid_cadence
    8389714: invalid_hr_sample
    8388814: invalid_http_body_in_network_response
    8388811: invalid_http_body_in_request
    8388815: invalid_http_header_fields_in_network_response
    8388810: invalid_http_header_fields_in_request
    8388812: invalid_http_method_in_request
    8390661: invalid_speed
    8390394: iconmenuitem
    8392008: id
    8390091: iirfilter
    8388729: info
    8388656: inputdelegate
    8389022: inputevent
    8389941: intent
    8390166: invalidbackgroundtimeexception
    8390143: invalidbitmapresourceexception
    8390538: invalidblocksizeexception
    8390524: invalidhexstringexception
    8390427: invalidkeyexception
    8390391: invalidmenuitemtypeexception
    8390087: invalidoptionsexception
    8390102: invalidpaletteexception
    8390565: invalidpointexception
    8391243: invalidrequestexception
    8389883: invalidselectablestateexception
    8390766: invalidvalueexception
    8389954: iterator
    8390088: jsondata
    8390603: key_agreement_ecdh
    8389562: key_clock
    8388998: key_down
    8388999: key_down_left
    8389000: key_down_right
    8388994: key_enter
    8388995: key_esc
    8388996: key_find
    8389559: key_lap
    8389001: key_left
    8388991: key_light
    8388997: key_menu
    8389563: key_mode
    8389557: key_page
    8390601: key_pair_elliptic_curve_secp224r1
    8390602: key_pair_elliptic_curve_secp256r1
    8388990: key_power
    8389560: key_reset
    8389002: key_right
    8389561: key_sport
    8389558: key_start
    8389003: key_up
    8389004: key_up_left
    8389005: key_up_right
    8388992: key_zin
    8388993: key_zout
    8390604: key
    8390606: keyagreement
    8389010: keyevent
    8390605: keypair
    8391488: kpi
    8391390: language_ara
    8391391: language_bul
    8391392: language_ces
    8391393: language_chs
    8391394: language_cht
    8391395: language_dan
    8391396: language_deu
    8391397: language_dut
    8391398: language_eng
    8391399: language_est
    8391400: language_fin
    8391401: language_fre
    8391402: language_gre
    8391403: language_heb
    8391404: language_hrv
    8391405: language_hun
    8391406: language_ind
    8391407: language_ita
    8391408: language_jpn
    8391409: language_kor
    8391410: language_lav
    8391411: language_lit
    8391412: language_nob
    8391413: language_pol
    8391414: language_por
    8391415: language_ron
    8391416: language_rus
    8391417: language_slo
    8391418: language_slv
    8391419: language_spa
    8391420: language_swe
    8391421: language_tha
    8391422: language_tur
    8391423: language_ukr
    8391424: language_vie
    8391425: language_zsm
    8389613: layout_halign_center
    8389611: layout_halign_left
    8389612: layout_halign_right
    8389614: layout_halign_start
    8389608: layout_valign_bottom
    8389609: layout_valign_center
    8389610: layout_valign_start
    8389607: layout_valign_top
    8389995: light_mode_auto
    8390005: light_mode_custom_1
    8390004: light_mode_custom_2
    8390003: light_mode_custom_3
    8390002: light_mode_custom_4
    8390001: light_mode_custom_5
    8389993: light_mode_fast_flash
    8390000: light_mode_hazard
    8389986: light_mode_off
    8389994: light_mode_random_flash
    8389997: light_mode_signal_left
    8389996: light_mode_signal_left_sc
    8389999: light_mode_signal_right
    8389998: light_mode_signal_right_sc
    8389992: light_mode_slow_flash
    8389991: light_mode_st_0_20
    8389990: light_mode_st_21_40
    8389989: light_mode_st_41_60
    8389988: light_mode_st_61_80
    8389987: light_mode_st_81_100
    8389984: light_network_mode_auto
    8389985: light_network_mode_high_vis
    8389983: light_network_mode_individual
    8389982: light_network_state_formed
    8389981: light_network_state_forming
    8389980: light_network_state_not_formed
    8390006: light_type_headlight
    8390011: light_type_other
    8390008: light_type_signal_config
    8390009: light_type_signal_left
    8390010: light_type_signal_right
    8390007: light_type_taillight
    8389301: location_continuous
    8389302: location_disable
    8389300: location_one_shot
    8388640: lang
    8391428: layer
    8390013: lightnetwork
    8390014: lightnetworklistener
    8391869: localmoment
    8389298: location
    8389784: logger
    8388759: long
    8390564: map_marker_icon_pin
    8390691: map_mode_browse
    8390690: map_mode_preview
    8391358: max_gears_invalid
    8389089: max_size
    8390406: menu_item_label_align_left
    8390405: menu_item_label_align_right
    8392184: menu_theme_blue
    8392185: menu_theme_cyan
    8392183: menu_theme_default
    8392186: menu_theme_green
    8392192: menu_theme_green_yellow
    8392188: menu_theme_orange
    8392190: menu_theme_pink
    8392191: menu_theme_purple
    8392189: menu_theme_red
    8392187: menu_theme_yellow
    8389852: mesg_type_lap
    8389853: mesg_type_record
    8389851: mesg_type_session
    8391346: message_sent_count
    8391345: message_sent_failed
    8391344: message_sent_success
    8391349: message_type_count
    8391347: message_type_manufacturer
    8391348: message_type_page_request
    8390508: mode_cbc
    8390507: mode_ecb
    8390708: month_april
    8390712: month_august
    8390716: month_december
    8390706: month_february
    8390705: month_january
    8390711: month_july
    8390710: month_june
    8390707: month_march
    8390709: month_may
    8390715: month_november
    8390714: month_october
    8390713: month_september
    8388906: move_bar_level_max
    8388907: move_bar_level_min
    8389225: msg_code_channel_id_not_set
    8389224: msg_code_channel_in_wrong_state
    8389222: msg_code_event_channel_closed
    8390112: msg_code_event_crypto_negotiation_fail
    8390111: msg_code_event_crypto_negotiation_success
    8389228: msg_code_event_que_overflow
    8389217: msg_code_event_rx_fail
    8389223: msg_code_event_rx_fail_go_to_search
    8389216: msg_code_event_rx_search_timeout
    8389219: msg_code_event_transfer_rx_failed
    8389220: msg_code_event_transfer_tx_completed
    8389221: msg_code_event_transfer_tx_failed
    8389218: msg_code_event_tx
    8389227: msg_code_invalid_message
    8389215: msg_code_response_no_error
    8389226: msg_code_transfer_in_progress
    8389213: msg_id_acknowledged_data
    8389198: msg_id_assign_channel
    8389212: msg_id_broadcast_data
    8389199: msg_id_channel_id
    8389200: msg_id_channel_period
    8389214: msg_id_channel_response_event
    8389202: msg_id_channel_rf_frequency
    8389205: msg_id_channel_transmit_power
    8389211: msg_id_close_channel
    8389207: msg_id_lib_config
    8389206: msg_id_low_priority_search_timeout
    8389203: msg_id_network_key
    8389210: msg_id_open_channel
    8389208: msg_id_proximity_search
    8389209: msg_id_reset_system
    8389196: msg_id_rf_event
    8389201: msg_id_search_timeout
    8389204: msg_id_transmit_power
    8389197: msg_id_unassign_channel
    8391851: magnetometerdata
    8388820: mailboxiterator
    8389977: manufacturerinfo
    8390566: mapmarker
    8390567: mappolyline
    8390569: maptrackview
    8390568: mapview
    8388641: math
    8390211: media
    8389027: menu
    8390389: menu2
    8390395: menu2inputdelegate
    8389028: menuinputdelegate
    8389090: menuitem
    8389236: message
    8390168: messagesizelimitexception
    8388767: method
    8388920: moment
    8389638: network_key_length_128bit
    8389637: network_key_length_64bit
    8389230: network_plus
    8389631: network_private
    8389229: network_public
    8388813: network_request_timed_out
    8390487: network_response_out_of_memory
    8388816: network_response_too_large
    8391195: number_format_float
    8391196: number_format_sint16
    8391197: number_format_sint32
    8391198: number_format_sint8
    8391199: number_format_uint16
    8391200: number_format_uint32
    8391201: number_format_uint8
    8389040: number_picker_birth_year
    8389039: number_picker_calories
    8389033: number_picker_distance
    8389038: number_picker_height
    8389034: number_picker_time
    8389035: number_picker_time_min_sec
    8389036: number_picker_time_of_day
    8389037: number_picker_weight
    8388758: number
    8389041: numberpicker
    8389042: numberpickerdelegate
    8389831: oauth_result_type_url
    8389832: oauth_signing_method_hmac_sha1
    8389840: oauthmessage
    8389382: obscure_bottom
    8389379: obscure_left
    8389381: obscure_right
    8389380: obscure_top
    8389796: order_newest_first
    8389797: order_oldest_first
    8388684: object
    8390172: objectstoreaccessexception
    8391204: operationnotallowedexception
    8392296: outofgraphicsmemoryexception
    8391903: packing_format_default
    8391906: packing_format_jpg
    8391905: packing_format_png
    8391904: packing_format_yuv
    8388893: pi
    8391020: playback_control_library
    8390467: playback_control_next
    8390464: playback_control_pause
    8390463: playback_control_play
    8391017: playback_control_playback
    8390466: playback_control_previous
    8391016: playback_control_rating
    8390473: playback_control_repeat
    8390465: playback_control_shuffle
    8390469: playback_control_skip_backward
    8390468: playback_control_skip_forward
    8391019: playback_control_source
    8390470: playback_control_thumbs_up_thumbs_down
    8391018: playback_control_volume
    8390308: playback_position_end
    8390307: playback_position_start
    8390318: playback_speed_fast
    8390319: playback_speed_fastest
    8390317: playback_speed_normal
    8390316: playback_speed_slow
    8389055: pop_view
    8391709: positioning_mode_aviation
    8391708: positioning_mode_normal
    8389552: press_type_action
    8389550: press_type_down
    8389551: press_type_up
    8391160: push_notifications_disabled
    8391158: push_notifications_only_show_actionable
    8391159: push_notifications_only_show_actionable_over_lte
    8391157: push_notifications_show_all
    8389054: push_view
    8389437: pedalpowerbalance
    8389953: persistedcontent
    8389534: persistedlocations
    8389938: phoneappmessage
    8389617: picker
    8389616: pickerdelegate
    8389615: pickerfactory
    8390331: playbackprofile
    8391031: playercolors
    8388642: position
    8389945: previousoperationnotcompleteexception
    8389978: productinfo
    8389141: profile
    8391578: profileinfo
    8391241: profileregistrationexception
    8389043: progressbar
    8390425: properties
    8390338: providericoninfo
    8389297: quality_good
    8389294: quality_last_known
    8389293: quality_not_available
    8389295: quality_poor
    8389296: quality_usable
    8392212: radial_text_direction_clockwise
    8392213: radial_text_direction_counter_clockwise
    8391357: rear_gear_invalid
    8390782: repeat_mode_all
    8390780: repeat_mode_off
    8390781: repeat_mode_one
    8390623: representation_byte_array
    8390546: representation_string_base64
    8390547: representation_string_hex
    8390548: representation_string_plain_text
    8390489: request_cancelled
    8390559: request_connection_dropped
    8389593: request_content_type_json
    8389592: request_content_type_url_encoded
    8392052: review_request_status_denied
    8392053: review_request_status_failed
    8392051: review_request_status_granted
    8390640: radartarget
    8391388: realtimeclocknotvalidexception
    8390245: resistancesettings
    8392288: resourceid
    8391757: resourcereference
    8392047: reviewresponsetoken
    8388769: rez
    8389973: route
    8390263: runningdynamics
    8390261: runningdynamicsdata
    8390264: runningdynamicslistener
    8391219: scan_state_off
    8391220: scan_state_scanning
    8389665: screen_shape_rectangle
    8389663: screen_shape_round
    8391880: screen_shape_semi_octagon
    8389664: screen_shape_semi_round
    8388928: seconds_per_day
    8388929: seconds_per_hour
    8388930: seconds_per_minute
    8388927: seconds_per_year
    8390194: secure_connection_required
    8388951: sensor_bikecadence
    8388952: sensor_bikepower
    8388950: sensor_bikespeed
    8388953: sensor_footpod
    8388954: sensor_heartrate
    8391683: sensor_onboard_heartrate
    8391682: sensor_onboard_pulse_oximetry
    8390259: sensor_orientation_right_side_up
    8390260: sensor_orientation_upside_down
    8391681: sensor_pulse_oximetry
    8391684: sensor_technology_ant
    8391685: sensor_technology_ble
    8391686: sensor_technology_onboard
    8388955: sensor_temperature
    8391379: slide_blink
    8389047: slide_down
    8389044: slide_immediate
    8389045: slide_left
    8389046: slide_right
    8389048: slide_up
    8390495: song_event_complete
    8390497: song_event_pause
    8390494: song_event_playback_notify
    8390498: song_event_resume
    8392275: song_event_skip_backward
    8392274: song_event_skip_forward
    8390492: song_event_skip_next
    8390493: song_event_skip_previous
    8390491: song_event_start
    8390496: song_event_stop
    8388843: sport_alpine_skiing
    8388839: sport_american_football
    8391155: sport_auto_racing
    8391151: sport_baseball
    8388836: sport_basketball
    8391125: sport_boating
    8391149: sport_boxing
    8392071: sport_cricket
    8388842: sport_cross_country_skiing
    8388832: sport_cycling
    8392069: sport_disc_golf
    8391126: sport_driving
    8391123: sport_e_biking
    8391131: sport_fishing
    8388834: sport_fitness_equipment
    8391150: sport_floor_climbing
    8391122: sport_flying
    8388830: sport_generic
    8391127: sport_golf
    8392059: sport_grinding
    8391128: sport_hang_gliding
    8392060: sport_health_monitoring
    8392062: sport_hiit
    8388847: sport_hiking
    8392073: sport_hockey
    8391129: sport_horseback_riding
    8391130: sport_hunting
    8391135: sport_ice_skating
    8391132: sport_inline_skating
    8391513: sport_invalid
    8391148: sport_jumpmaster
    8391143: sport_kayaking
    8391146: sport_kitesurfing
    8392074: sport_lacrosse
    8392061: sport_marine
    8392067: sport_meditation
    8391124: sport_motorcycling
    8388846: sport_mountaineering
    8388848: sport_multisport
    8388849: sport_paddling
    8392068: sport_para_sport
    8392064: sport_racket
    8391144: sport_rafting
    8391133: sport_rock_climbing
    8388845: sport_rowing
    8392072: sport_rugby
    8388831: sport_running
    8391134: sport_sailing
    8391154: sport_shooting
    8391136: sport_sky_diving
    8388844: sport_snowboarding
    8391138: sport_snowmobiling
    8391137: sport_snowshoeing
    8388837: sport_soccer
    8391152: sport_softball_fast_pitch
    8391153: sport_softball_slow_pitch
    8391139: sport_stand_up_paddleboarding
    8391140: sport_surfing
    8388835: sport_swimming
    8391147: sport_tactical
    8392070: sport_team_sport
    8388838: sport_tennis
    8388840: sport_training
    8388833: sport_transition
    8392063: sport_video_gaming
    8392075: sport_volleyball
    8391141: sport_wakeboarding
    8392077: sport_wakesurfing
    8388841: sport_walking
    8391142: sport_water_skiing
    8392076: sport_water_tubing
    8392066: sport_wheelchair_push_run
    8392065: sport_wheelchair_push_walk
    8391145: sport_windsurfing
    8392058: sport_winter_sport
    8392240: status_encryption_bond_fail
    8392241: status_encryption_peer_keys_lost
    8392242: status_encryption_security_insufficient
    8392287: status_gatt_insufficient_authentication_fail
    8392239: status_gatt_insufficient_encryption_fail
    8391216: status_not_enough_resources
    8391217: status_read_fail
    8391215: status_success
    8391218: status_write_fail
    8389965: storage_full
    8392133: sub_sport_adventure_race
    8392124: sub_sport_amrap
    8392140: sub_sport_anchor
    8392107: sub_sport_apnea_diving
    8392108: sub_sport_apnea_hunting
    8392115: sub_sport_area_calc
    8392111: sub_sport_assistance
    8392086: sub_sport_atv
    8392088: sub_sport_backcountry
    8392146: sub_sport_badminton
    8392083: sub_sport_bike_to_run_transition
    8392080: sub_sport_bmx
    8392120: sub_sport_bouldering
    8392113: sub_sport_breathing
    8392131: sub_sport_brick
    8388876: sub_sport_cardio_training
    8392081: sub_sport_casual_walking
    8392114: sub_sport_ccr_diving
    8388874: sub_sport_challenge
    8392099: sub_sport_commuting
    8388861: sub_sport_cyclocross
    8388859: sub_sport_downhill
    8392130: sub_sport_duathlon
    8388865: sub_sport_elliptical
    8392125: sub_sport_emom
    8392128: sub_sport_esport
    8388873: sub_sport_exercise
    8392117: sub_sport_expedition
    8392079: sub_sport_e_bike_fitness
    8392098: sub_sport_e_bike_mountain
    8392127: sub_sport_fall_detected
    8392141: sub_sport_field
    8388869: sub_sport_flexibility_training
    8392106: sub_sport_gauge_diving
    8388850: sub_sport_generic
    8392097: sub_sport_gravel_cycling
    8388862: sub_sport_hand_cycling
    8392121: sub_sport_hiit
    8392123: sub_sport_hunting_with_dogs
    8392142: sub_sport_ice
    8392112: sub_sport_incident_detected
    8392119: sub_sport_indoor_climbing
    8388856: sub_sport_indoor_cycling
    8392122: sub_sport_indoor_grinding
    8392139: sub_sport_indoor_hand_cycling
    8388864: sub_sport_indoor_rowing
    8392096: sub_sport_indoor_running
    8388875: sub_sport_indoor_skiing
    8392078: sub_sport_indoor_walking
    8392138: sub_sport_indoor_wheelchair_run
    8392137: sub_sport_indoor_wheelchair_walk
    8391514: sub_sport_invalid
    8388867: sub_sport_lap_swimming
    8392103: sub_sport_map
    8388872: sub_sport_match
    8392100: sub_sport_mixed_surface
    8392087: sub_sport_motocross
    8388858: sub_sport_mountain
    8392105: sub_sport_multi_gas_diving
    8392101: sub_sport_navigate
    8392110: sub_sport_obstacle
    8388868: sub_sport_open_water
    8392136: sub_sport_padel
    8392135: sub_sport_pickleball
    8392095: sub_sport_pilates
    8392144: sub_sport_platform
    8392147: sub_sport_racquetball
    8392090: sub_sport_rc_drone
    8388860: sub_sport_recumbent
    8392089: sub_sport_resort
    8388857: sub_sport_road
    8392084: sub_sport_run_to_bike_transition
    8392116: sub_sport_sail_race
    8392104: sub_sport_single_gas_diving
    8392093: sub_sport_skate_skiing
    8392082: sub_sport_speed_walking
    8388855: sub_sport_spin
    8392145: sub_sport_squash
    8388866: sub_sport_stair_climbing
    8388852: sub_sport_street
    8388870: sub_sport_strength_training
    8392132: sub_sport_swim_run
    8392085: sub_sport_swim_to_bike_transition
    8392126: sub_sport_tabata
    8392148: sub_sport_table_tennis
    8388854: sub_sport_track
    8388863: sub_sport_track_cycling
    8392102: sub_sport_track_me
    8388853: sub_sport_trail
    8388851: sub_sport_treadmill
    8392129: sub_sport_triathlon
    8392134: sub_sport_trucker_workout
    8392143: sub_sport_ultimate
    8392118: sub_sport_ultra
    8392109: sub_sport_virtual_activity
    8388871: sub_sport_warm_up
    8392092: sub_sport_whitewater
    8392091: sub_sport_wingsuit
    8392094: sub_sport_yoga
    8389769: swim_storke_butterfly
    8389767: swim_stroke_backstroke
    8389768: swim_stroke_breaststroke
    8390795: swim_stroke_butterfly
    8389770: swim_stroke_drill
    8389766: swim_stroke_freestyle
    8389772: swim_stroke_im
    8389771: swim_stroke_mixed
    8389017: swipe_down
    8389018: swipe_left
    8389016: swipe_right
    8389015: swipe_up
    8389056: switch_view
    8391238: scanresult
    8389884: selectable
    8389882: selectableevent
    8388643: sensor
    8390071: sensordata
    8389781: sensorhistory
    8389799: sensorhistoryiterator
    8391691: sensorinfo
    8391690: sensorinfoiterator
    8390179: sensorlogger
    8390175: sensorlogging
    8390178: sensorloggingstats
    8390262: sensorposition
    8389798: sensorsample
    8390475: serializationexception
    8391235: service
    8390147: servicedelegate
    8388879: session
    8391361: shifting
    8391362: shiftinglistener
    8391360: shiftingstatus
    8389025: simpledatafield
    8390246: simulationsettings
    8388710: stats
    8390424: storage
    8390215: storagefullexception
    8388763: string
    8389782: stringutil
    8388770: strings
    8389019: swipeevent
    8388765: symbol
    8389949: symbolnotallowedexception
    8388878: symbols
    8390337: syncdelegate
    8388644: system
    8391033: systembutton
    8389173: text_justify_center
    8389174: text_justify_left
    8389172: text_justify_right
    8389175: text_justify_vcenter
    8390632: threat_level_no_threat
    8390633: threat_level_vehicle_approaching
    8390634: threat_level_vehicle_fast_approaching
    8390637: threat_side_left
    8390635: threat_side_no_side
    8390636: threat_side_right
    8391184: timer_event_lap
    8391187: timer_event_next_multisport_leg
    8391182: timer_event_pause
    8391185: timer_event_reset
    8391183: timer_event_resume
    8391180: timer_event_start
    8391181: timer_event_stop
    8391186: timer_event_workout_step_complete
    8389810: timer_state_off
    8389813: timer_state_on
    8389812: timer_state_paused
    8389811: timer_state_stopped
    8388974: tone_alarm
    8388970: tone_alert_hi
    8388971: tone_alert_lo
    8388977: tone_canary
    8388979: tone_distance_alert
    8388984: tone_error
    8388980: tone_failure
    8388973: tone_interval_alert
    8388966: tone_key
    8388976: tone_lap
    8388972: tone_loud_beep
    8388983: tone_low_battery
    8388969: tone_msg
    8388982: tone_power
    8388975: tone_reset
    8388967: tone_start
    8388968: tone_stop
    8388981: tone_success
    8388978: tone_time_alert
    8390241: trainer_bike_weight
    8390243: trainer_gear_ratio
    8390232: trainer_mode
    8390229: trainer_mode_basic_resistance
    8390231: trainer_mode_simulation
    8390230: trainer_mode_target_power
    8390233: trainer_resistance
    8390235: trainer_slope
    8390236: trainer_surface
    8390234: trainer_target_power
    8390240: trainer_user_weight
    8390242: trainer_wheel_diameter
    8390237: trainer_wind_coeff
    8390239: trainer_wind_draft_factor
    8390238: trainer_wind_speed
    8390247: targetpowersettings
    8388649: test
    8389060: text
    8391277: textarea
    8389537: textpicker
    8389538: textpickerdelegate
    8388645: time
    8388646: timer
    8390393: togglemenuitem
    8391275: toneprofile
    8390176: toomanysensordatalistenersexception
    8390016: torqueeffectivenesspedalsmoothness
    8388611: toybox
    8388614: toybox_activity
    8388619: toybox_activitymonitor
    8388617: toybox_activityrecording
    8388628: toybox_ant
    8389409: toybox_antplus
    8388629: toybox_application
    8390209: toybox_application_properties
    8390210: toybox_application_storage
    8388624: toybox_attention
    8391868: toybox_authentication
    8390145: toybox_background
    8391192: toybox_bluetoothlowenergy
    8388616: toybox_communications
    8391960: toybox_complicationpublisher
    8391961: toybox_complicationsubscriber
    8391963: toybox_complications
    8390500: toybox_cryptography
    8391719: toybox_datafieldalert
    8389777: toybox_fitcontributor
    8388627: toybox_graphics
    8391487: toybox_kpi
    8388615: toybox_lang
    8388618: toybox_math
    8390208: toybox_media
    8389952: toybox_persistedcontent
    8389533: toybox_persistedlocations
    8388630: toybox_position
    8391169: toybox_pushnotification
    8388623: toybox_sensor
    8389776: toybox_sensorhistory
    8390174: toybox_sensorlogging
    8389779: toybox_stringutil
    8388613: toybox_system
    8388612: toybox_test
    8388620: toybox_time
    8388621: toybox_time_gregorian
    8388622: toybox_timer
    8388626: toybox_userprofile
    8388625: toybox_watchui
    8391486: toybox_weather
    8389974: track
    8391046: transparentprogressbar
    8391104: unable_to_process_hls
    8391049: unable_to_process_image
    8390922: unable_to_process_media
    8391965: unit_distance
    8391966: unit_elevation
    8391967: unit_height
    8391964: unit_invalid
    8389395: unit_metric
    8391968: unit_speed
    8389396: unit_statute
    8391969: unit_temperature
    8391970: unit_weight
    8388800: unknown_error
    8390455: unsupported_content_type_in_response
    8390119: user_info_string_length
    8389698: unabletoacquirechannelexception
    8390114: unabletoacquireencryptedchannelexception
    8389943: unexpectedapptypeexception
    8389585: unexpectedtypeexception
    8391858: useractivity
    8391859: useractivityhistoryiterator
    8388647: userprofile
    8390248: usersettings
    8391239: uuid
    8391240: uuidformatexception
    8390560: valueoutofboundsexception
    8392216: vectorfont
    8388986: vibeprofile
    8389023: view
    8391946: viewloop
    8391956: viewloopdelegate
    8391944: viewloopfactory
    8391602: wifi_connection_status_airplane_mode_active
    8391600: wifi_connection_status_battery_saver_active
    8391814: wifi_connection_status_cannot_connect_to_access_point
    8391596: wifi_connection_status_low_battery
    8391597: wifi_connection_status_no_access_points
    8391603: wifi_connection_status_powered_down
    8391601: wifi_connection_status_stealth_mode_active
    8391815: wifi_connection_status_transfer_already_in_progress
    8391604: wifi_connection_status_unknown
    8391598: wifi_connection_status_unsupported
    8391599: wifi_connection_status_user_disabled
    8391515: workout_intensity_active
    8391518: workout_intensity_cooldown
    8391520: workout_intensity_interval
    8391521: workout_intensity_invalid
    8391519: workout_intensity_recovery
    8391516: workout_intensity_rest
    8391517: workout_intensity_warmup
    8391526: workout_step_duration_calories
    8391523: workout_step_duration_distance
    8391525: workout_step_duration_hr_greater_than
    8391524: workout_step_duration_hr_less_than
    8391552: workout_step_duration_invalid
    8391527: workout_step_duration_open
    8391545: workout_step_duration_power_10s_greater_than
    8391542: workout_step_duration_power_10s_less_than
    8391546: workout_step_duration_power_30s_greater_than
    8391543: workout_step_duration_power_30s_less_than
    8391544: workout_step_duration_power_3s_greater_than
    8391541: workout_step_duration_power_3s_less_than
    8391537: workout_step_duration_power_greater_than
    8391548: workout_step_duration_power_lap_greater_than
    8391547: workout_step_duration_power_lap_less_than
    8391536: workout_step_duration_power_less_than
    8391531: workout_step_duration_repeat_until_calories
    8391530: workout_step_duration_repeat_until_distance
    8391533: workout_step_duration_repeat_until_hr_greater_than
    8391532: workout_step_duration_repeat_until_hr_less_than
    8391540: workout_step_duration_repeat_until_max_power_last_lap_less_than
    8391535: workout_step_duration_repeat_until_power_greater_than
    8391539: workout_step_duration_repeat_until_power_last_lap_less_than
    8391534: workout_step_duration_repeat_until_power_less_than
    8391528: workout_step_duration_repeat_until_steps_complete
    8391529: workout_step_duration_repeat_until_time
    8391549: workout_step_duration_repeat_until_training_peaks_training_stress_score
    8391550: workout_step_duration_repetition_time
    8391551: workout_step_duration_reps
    8391522: workout_step_duration_time
    8391538: workout_step_duration_training_peaks_training_stress_score
    8391556: workout_step_target_cadence
    8391569: workout_step_target_exhale_duration
    8391570: workout_step_target_exhale_hold_duration
    8391558: workout_step_target_grade
    8391554: workout_step_target_heart_rate
    8391566: workout_step_target_heart_rate_lap
    8391567: workout_step_target_inhale_duration
    8391568: workout_step_target_inhale_hold_duration
    8391572: workout_step_target_invalid
    8391555: workout_step_target_open
    8391557: workout_step_target_power
    8391561: workout_step_target_power_10s
    8391562: workout_step_target_power_30s
    8391560: workout_step_target_power_3s
    8391571: workout_step_target_power_curve
    8391563: workout_step_target_power_lap
    8391559: workout_step_target_resistance
    8391553: workout_step_target_speed
    8391565: workout_step_target_speed_lap
    8391564: workout_step_target_swim_stroke
    8391223: write_type_default
    8391222: write_type_with_response
    8389375: watchface
    8390095: watchfacedelegate
    8390096: watchfacepowerinfo
    8388648: watchui
    8389958: waypoint
    8389654: weakreference
    8391489: weather
    8389960: workout
    8391574: workoutintervalstep
    8391573: workoutstep
    8391575: workoutstepinfo
    8389917: s___version
    8389969: s__data
    8389961: s__id
    8389762: a
    8388774: abs
    8389605: accel
    8390648: accelerometer
    8390077: accelerometerdata_
    8389311: accuracy
    8388895: acos
    8391715: acquisitiontype
    8389877: activeminutes_
    8389870: activeminutesday
    8389869: activeminutesweek
    8389871: activeminutesweekgoal
    8391590: activestep
    8389150: activityclass
    8389649: activitytrackingon
    8388942: add
    8389822: addall
    8391679: addentry
    8389095: additem
    8390612: addkey
    8388880: addlap
    8391439: addlayer
    8390593: addlocation
    8389583: alarmcount
    8390383: album
    8390388: albumart_
    8390520: algorithm
    8390437: alignment
    8390186: allowtrialmessage
    8391801: alphablending
    8388963: altitude
    8390213: ambientpressure
    8392202: angle
    8389020: animate
    8391713: antserialnumber
    8391504: apptype
    8390068: appendparamstourl
    8390093: apply
    8389322: april
    8389948: arguments
    8390384: artist
    8388896: asin
    8389785: assert
    8389787: assertequal
    8389788: assertequalmessage
    8389786: assertmessage
    8389789: assertnotequal
    8389790: assertnotequalmessage
    8388897: atan
    8389716: atan2
    8390361: attemptskipafterthumbsdown
    8390449: audioformat_
    8389326: august
    8391118: autolap
    8391190: autostart
    8388751: averagecadence
    8388756: averagedistance
    8388748: averageheartrate
    8388743: averagepower
    8391700: averagerestingheartrate
    8388739: averagespeed
    8389763: b
    8389892: background_
    8389743: backgroundcolor
    8389635: backgroundscanenabled
    8388988: backlight
    8390289: basicresistance
    8390303: basicresistancesupported
    8388724: battery
    8391854: batteryindays
    8389526: batterystatus_
    8389528: batteryvoltage
    8389929: bearing
    8389930: bearingfromstart
    8389103: behavior
    8390300: bikeweight
    8389151: birthyear
    8390448: bitrate
    8391710: bitmap_
    8392230: bitmapheight
    8390139: bitmapresource_
    8392229: bitmapwidth
    8392227: bitmapx
    8392228: bitmapy
    8391718: bleaddress
    8390485: bluetooth
    8390269: bodylocation
    8391931: brightness
    8391769: bufferedbitmap_
    8390059: burstpayload_
    8390060: burstpayloadindex
    8388959: cadence
    8388737: calories
    8390374: canskip
    8391462: cancelallanimations
    8389679: cancelallrequests
    8390366: capacity
    8391231: cccduuid
    8389717: ceil
    8391955: changeview
    8389237: channeltype
    8389879: chararraytostring
    8391341: characteristics
    8390461: charging
    8391605: checkwificonnection
    8389177: clear
    8390104: clearclip
    8391443: clearlayers
    8389285: clearproperties
    8390429: clearvalues
    8392159: clockstate
    8389257: close
    8390553: codepage
    8390129: coefficients
    8390130: coefficients_a
    8390131: coefficients_b
    8389347: color
    8391722: colordepth
    8391339: companyid
    8388944: compare
    8392272: compareto
    8392014: complicationid
    8389137: compute
    8392175: concatenate
    8391670: condition
    8392043: configuration
    8389647: confirm
    8390482: connectionavailable
    8390483: connectioninfo_
    8391711: constellations
    8390440: contenttype
    8390435: context
    8390296: controlequipment
    8390549: convertencodedstring
    8388898: cos
    8389850: count
    8390802: createboundingbox
    8391770: createbufferedbitmap
    8391731: createcolor
    8389845: createfield
    8391450: createlogfile
    8390767: createpublickey
    8388877: createsession
    8388750: currentcadence
    8388757: currentheading
    8388747: currentheartrate
    8388736: currentlocation
    8388735: currentlocationaccuracy
    8391583: currentoxygensaturation
    8388742: currentpower
    8388738: currentspeed
    8391116: currenttimetype
    8389807: data
    8389242: datahigh
    8389241: datalow
    8388939: day
    8388937: day_of_week
    8389341: days
    8389793: debug
    8389330: december
    8390124: decimationrate
    8391205: decodenumber
    8390517: decrypt
    8389644: defaults
    8389317: degrees
    8391333: delegate
    8391173: deleteactivitycompletedevent
    8392280: deleteappinstallstateevent
    8390328: deletecacheditem
    8390161: deletegoalevent
    8390418: deleteitem
    8390202: deleteoauthresponseevent
    8391594: deletephoneappmessageevent
    8389284: deleteproperty
    8391164: deletepushnotificationevent
    8390157: deletesleepevent
    8390163: deletestepsevent
    8390154: deletetemporalevent
    8390428: deletevalue
    8390159: deletewakeevent
    8391340: descriptors
    8389244: devicenumber
    8389245: devicetype
    8390515: digest
    8392203: direction
    8390127: disableencryption
    8391688: disablesensortype
    8390439: disabled
    8388883: discard
    8388911: distance
    8389923: distancetodestination
    8389926: distancetonextpoint
    8389402: distanceunits
    8389694: dithering
    8388949: divide
    8392306: dividericon
    8392300: dividertype
    8389795: donotdisturb
    8390286: draftfactor
    8389068: draw
    8392215: drawangledtext
    8389687: drawarc
    8389183: drawbitmap
    8392234: drawbitmap2
    8389178: drawcircle
    8389179: drawellipse
    8390741: drawfooter
    8390743: drawforeground
    8390718: drawlayout
    8389184: drawline
    8391736: drawoffsetbitmap
    8389180: drawpoint
    8392214: drawradialtext
    8389181: drawrectangle
    8389182: drawroundedrectangle
    8391737: drawscaledbitmap
    8389190: drawtext
    8390740: drawtitle
    8390756: drawable_
    8388719: dst
    8388935: duration_
    8391584: durationtype
    8391585: durationvalue
    8388989: dutycycle
    8388734: elapseddistance
    8388732: elapsedtime
    8389924: elevationatdestination
    8389927: elevationatnextpoint
    8389404: elevationunits
    8388823: emptymailbox
    8390135: enableaccelerometer
    8390126: enableencryption
    8389303: enablelocationevents
    8388957: enablesensorevents
    8391687: enablesensortype
    8390438: enabled
    8389881: encodebase64
    8391206: encodenumber
    8389565: encodeurl
    8390387: encoding
    8390518: encrypt
    8390121: encryptionid
    8390122: encryptionkey
    8391342: endianness
    8389652: energyexpenditure
    8391119: entry
    8388787: equals
    8388718: error
    8391716: errorcode
    8389104: event
    8390099: executiontimeaverage
    8390100: executiontimelimit
    8388717: exit
    8389942: exitto
    8392219: face
    8390281: fedistance
    8390280: feheartrate
    8390279: fespeed
    8389320: february
    8391672: feelsliketemperature
    8391712: filedownloadprogresscallback
    8389185: fillcircle
    8389186: fillellipse
    8389187: fillpolygon
    8389188: fillrectangle
    8389189: fillroundedrectangle
    8392232: filtermode
    8388796: find
    8389121: finddrawablebyid
    8390421: finditembyid
    8389676: firmwareversion
    8390696: firstdayofweek
    8391331: fittexttoarea
    8389243: flag
    8389718: floor
    8389872: floorsclimbed
    8389874: floorsclimbedgoal
    8389873: floorsdescended
    8390436: focus
    8390752: focusitemheight
    8389348: font
    8392309: fontscale
    8390753: footer
    8391797: footeritemheight
    8391666: forecasttime
    8390754: foreground
    8389742: foregroundcolor
    8388764: format
    8388726: freememory
    8391276: frequency
    8390551: fromrepresentation
    8391363: frontderailleur
    8389815: frontderailleurindex
    8389816: frontderailleurmax
    8389817: frontderailleursize
    8390132: gain
    8391368: gearindex
    8391370: gearmax
    8390302: gearratio
    8391369: gearsize
    8389144: gender
    8390204: generateconnectoauthheader
    8390613: generatesecret
    8389836: generatesignedoauthheader
    8390385: genre
    8388789: get
    8391174: getactivitycompletedeventregistered
    8388728: getactivityinfo
    8389275: getapp
    8390772: getappcourses
    8391506: getappicon
    8390773: getapproutes
    8390774: getapptracks
    8390775: getappwaypoints
    8390776: getappworkouts
    8391271: getappearance
    8391233: getavailableconnectioncount
    8389627: getbackgroundcolor
    8390164: getbackgrounddata
    8390027: getbatterystatus
    8390021: getbikelights
    8391839: getbodybatteryhistory
    8392243: getbondeddevices
    8390609: getbytes
    8390330: getcachestatistics
    8390329: getcachedcontentobj
    8390673: getcadenceinfo
    8390044: getcalculatedcadence
    8389512: getcalculatedpower
    8389514: getcalculatedwheeldistance
    8389515: getcalculatedwheelspeed
    8390042: getcapablemodes
    8391253: getcharacteristic
    8391252: getcharacteristics
    8388714: getclocktime
    8391721: getcolordepth
    8392025: getcomplication
    8392024: getcomplications
    8390028: getcomponentidentifiers
    8391386: getconnectserver
    8390430: getcontentdelegate
    8390377: getcontentiterator
    8390351: getcontentref
    8390326: getcontentrefiter
    8390346: getcontenttype
    8389113: getcoordinates
    8389956: getcourses
    8391661: getcurrentconditions
    8389758: getcurrentsport
    8391115: getcurrenttime
    8392154: getcurrentview
    8391576: getcurrentworkoutstep
    8391665: getdailyforecast
    8391875: getdaylightsavingstimeoffset
    8390110: getdc
    8391249: getdescriptor
    8391248: getdescriptors
    8392178: getdeterminant
    8391254: getdevice
    8389254: getdeviceconfig
    8391267: getdevicename
    8389398: getdevicesettings
    8389479: getdevicestate
    8389106: getdimensions
    8389119: getdirection
    8392295: getdisplaymode
    8391826: getdistance
    8392308: getdividericon
    8389628: getdrawable
    8389802: getelevationhistory
    8390298: getequipmentdata
    8389587: geterrormessage
    8389689: getfontascent
    8389690: getfontdescent
    8389194: getfontheight
    8391283: getframerate
    8388885: getgeometry
    8391753: getglancetheme
    8391457: getglanceview
    8390681: getgoaleventregistered
    8389916: getgoalview
    8389702: getheartratehistory
    8389757: getheartratezones
    8389116: getheight
    8388910: gethistory
    8391663: gethourlyforecast
    8390415: geticon
    8389963: getid
    8391035: getimage
    8392011: getindex
    8388909: getinfo
    8389280: getinitialview
    8391497: getinstallationinfo
    8391498: getinstalledapps
    8389889: getinstance
    8390419: getitem
    8389136: getkey
    8390413: getlabel
    8390155: getlasttemporaleventtime
    8391442: getlayerindex
    8391444: getlayers
    8390575: getlocation
    8388821: getmailbox
    8390029: getmanufacturerinfo
    8391268: getmanufacturerspecificdata
    8391269: getmanufacturerspecificdataiterator
    8390692: getmapmode
    8392179: getmatrix
    8389706: getmax
    8390076: getmaxsamplerate
    8392249: getmaxsamplerateforsensortype
    8390349: getmetadata
    8389707: getmin
    8390453: getmonthfromsymbol
    8389962: getname
    8390019: getnetworkmode
    8390020: getnetworkstate
    8389805: getnewestsampletime
    8391577: getnextworkoutstep
    8391284: getnumberofframes
    8389567: getnumberoftests
    8390683: getoauthresponseeventregistered
    8389383: getobscurityflags
    8391873: getoffset
    8389806: getoldestsampletime
    8391512: getoxygensaturationhistory
    8391227: getpaireddevices
    8390108: getpalette
    8389251: getpayload
    8389516: getpedalpowerbalance
    8391593: getphoneappmessageeventregistered
    8390432: getplaybackconfigurationview
    8390369: getplaybackprofile
    8390763: getplaybackstartposition
    8389801: getpressurehistory
    8389888: getpreviousstate
    8390618: getprivatekey
    8390030: getproductinfo
    8389142: getprofile
    8391579: getprofileinfo
    8390725: getprojectedlocation
    8389282: getproperty
    8390433: getprovidericoninfo
    8390619: getpublickey
    8391165: getpushnotificationeventregistered
    8391161: getpushnotificationpreference
    8391166: getpushnotificationtoken
    8390642: getradarinfo
    8391272: getrawdata
    8391689: getregisteredsensors
    8390292: getresistancesettings
    8391296: getresource
    8389971: getroutes
    8391265: getrssi
    8390267: getrunningdynamics
    8392163: getscreenheight
    8390268: getsensorposition
    8391246: getservice
    8391270: getservicedata
    8390169: getservicedelegate
    8391266: getserviceuuids
    8391245: getservices
    8391703: getsettingsview
    8391366: getshiftingstatus
    8390293: getsimulationsettings
    8389630: getsize
    8390679: getsleepeventregistered
    8390669: getspeedcadenceinfo
    8390671: getspeedinfo
    8389902: getstate
    8390181: getstats
    8391884: getstats2
    8390682: getstepseventregistered
    8391847: getstresshistory
    8390402: getsublabel
    8391802: getsubscreen
    8391864: getsunrise
    8391865: getsunset
    8390434: getsyncconfigurationview
    8390431: getsyncdelegate
    8391047: getsyncicon
    8388715: getsystemstats
    8390294: gettargetpowersettings
    8389800: gettemperaturehistory
    8390678: gettemporaleventregisteredtime
    8389792: gettestname
    8389570: gettestobject
    8391036: gettext
    8389191: gettextdimensions
    8389193: gettextwidthinpixels
    8391874: gettimezoneoffset
    8388713: gettimer
    8390045: gettorqueeffectivenesspedalsmoothness
    8389972: gettracks
    8390291: gettrainermode
    8390187: gettrialdaysremaining
    8389114: gettype
    8391178: getunitid
    8391857: getuseractivityhistory
    8390295: getusersettings
    8391247: getuuid
    8389629: getvalue
    8392220: getvectorfont
    8391825: getvelocity
    8391945: getview
    8390680: getwakeeventregistered
    8389955: getwaypoints
    8389117: getwidth
    8389957: getworkouts
    8391293: getx
    8391294: gety
    8389350: globals
    8388946: greaterthan
    8390271: groundcontactbalance
    8390272: groundcontacttime
    8391852: gyroscope
    8391848: gyroscopedata_
    8389084: handleevent
    8391680: hasaddress
    8392044: hasconfigurationsupport
    8391933: hasflashlightcolor
    8388790: haskey
    8388781: hashcode
    8389594: headers
    8388965: heading
    8390655: heartbeatintervals
    8388960: heartrate
    8390653: heartratedata_
    8389067: height
    8389406: heightunits
    8391667: hightemperature
    8391042: highlightbordercolor
    8391041: highlightfillcolor
    8391110: hlscontenttypemask
    8388720: hour
    8389342: hours
    8389525: hwrevision
    8392158: icon
    8389063: identifier
    8390375: image_format
    8390376: image_offset
    8390137: includepitch
    8390136: includepower
    8390138: includeroll
    8389823: indexof
    8388936: info_
    8390451: initbarrelresources
    8389393: initresources
    8388702: initialize
    8389674: inputbuttons
    8391441: insertlayer
    8391580: intensity
    8391371: invalidinboardshiftcount
    8391372: invalidoutboardshiftcount
    8392177: invert
    8388780: invoke
    8389401: is24hour
    8392250: isactive
    8391484: isappinstalled
    8389633: isbackgroundscanenabled
    8392245: isbonded
    8391766: iscached
    8390398: ischecked
    8391244: isconnected
    8391876: isdaylightsavingstime
    8388792: isempty
    8390404: isenabled
    8392210: isenhancedreadabilitymodeenabled
    8390748: isfocused
    8391076: isfooterselected
    8391461: isglancemodeenabled
    8391886: isnightmodeenabled
    8388881: isrecording
    8391264: issamedevice
    8390747: isselected
    8388915: issleepmode
    8390342: issyncneeded
    8391075: istitleselected
    8389673: istouchscreen
    8390188: istrial
    8391300: isvisible
    8390521: iv
    8389319: january
    8389325: july
    8389324: june
    8389349: justification
    8390522: key_
    8388793: keys
    8389138: label
    8389305: lat
    8389314: latitude
    8392151: launchedfromcomplication
    8391789: launchedfromglance
    8391893: leftbutton
    8389474: leftorcombinedpedalsmoothness
    8389471: lefttorqueeffectiveness
    8388795: length
    8388945: lessthan
    8391717: level
    8391120: lines
    8390198: ln
    8389286: loadproperties
    8389021: loadresource
    8391767: loadresourceex
    8389064: locx
    8389065: locy
    8391877: localmoment_
    8388899: log
    8389306: lon
    8392016: longlabel
    8391229: longtouuid
    8389315: longitude
    8391668: lowtemperature
    8391102: lte
    8390368: maccentcolor
    8392021: maccesslevel
    8390410: malignment
    8391702: mantialias
    8389895: mbackgroundcolor
    8389105: mbitmapdata
    8390107: mbitmapdef
    8390105: mbitmapresource
    8389681: mchannelnumber
    8390396: mchecked
    8388778: mclass
    8389130: mcolor
    8389620: mconfirm
    8390348: mcontentref
    8390344: mcontenttype
    8390516: mcontext
    8392023: mcurappidx
    8390343: mcurindex
    8392022: mcursubidx
    8389901: mcurrentstate
    8388887: mdata
    8388941: mdatetime
    8391871: mdaylightoffset
    8389624: mdefaults
    8389477: mdevicetype
    8389118: mdirection
    8390400: mdisabledsublabel
    8389085: mdisplaystring
    8391824: mdistance
    8392297: mdividertype
    8389195: mdrawcontext
    8390399: menabledsublabel
    8389575: merrorcode
    8389934: mfitcontributorfields
    8390416: mfocus
    8389128: mfont
    8392020: mglancepreview
    8389546: mheight
    8390367: micon
    8392019: miconrez
    8390345: mid
    8390409: midentifier
    8388889: mindex
    8392152: mindices
    8389539: minitialtext
    8389062: minitialvalue
    8389887: minstance
    8391872: misdaylight
    8392294: misdirty
    8389091: mitems
    8389129: mjustification
    8389135: mkey
    8389893: mkeytoselectable
    8390407: mlabel
    8389120: mlayout
    8388888: mlocation
    8389704: mmax
    8389115: mmessage
    8390347: mmetadata
    8388779: mmethod
    8389705: mmin
    8389061: mmode
    8392009: mnativetype
    8389712: mnewestfirst
    8389803: mnewestsampletime
    8389621: mnextarrow
    8388827: moffset
    8389804: moldestsampletime
    8390084: moptions
    8390094: moutputbuffer
    8389623: mpattern
    8389574: mpcstack
    8389622: mpreviousarrow
    8389886: mpreviousstate
    8389086: mprogressvalue
    8389277: mproperties
    8389278: mpropertieschanged
    8390092: msamplebuffer
    8391315: mselectidx
    8391695: msensorindex
    8390177: msensorlogger
    8391696: msensortype
    8389092: msize
    8390180: mstats
    8390408: msublabel
    8391934: msubscreenicon
    8389127: mtext
    8391938: mtheme
    8389710: mtime
    8389093: mtitle
    8389112: mtype
    8391273: muuid
    8391823: mvelocity
    8389545: mwidth
    8389110: mx
    8389111: my
    8391870: mzoneoffset
    8389606: mag
    8391853: magnetometer
    8391849: magnetometerdata_
    8388819: makeimagerequest
    8389659: makeimagerequestnative
    8391908: makeimagerequestnative2
    8388817: makejsonrequest
    8388818: makejsonrequestnative
    8389837: makeoauthrequest
    8392049: makereviewtokenrequest
    8389835: makewebrequest
    8391503: manifestid
    8389520: manufacturerid
    8389321: march
    8391109: maxbandwidth
    8388752: maxcadence
    8388749: maxheartrate
    8389657: maxheight
    8388744: maxpower
    8388740: maxspeed
    8389661: maxwidth
    8391511: maximumallowedapps
    8389323: may
    8391212: mean
    8390212: meansealevelpressure
    8389247: measurementtype
    8390441: mediaencoding
    8389847: mesgtype
    8391812: message_
    8389240: messageid
    8389270: messageperiod
    8391351: messagetype
    8389875: metersclimbed
    8389876: metersdescended
    8388786: method_
    8388721: min
    8389338: minute
    8389343: minutes
    8390041: mode
    8389521: modelnumber
    8389867: moderate
    8388933: moment_
    8388934: momentnative
    8389677: monkeyversion
    8388938: month
    8388914: movebarlevel
    8388948: multiply
    8388892: name
    8389925: nameofdestination
    8389928: nameofnextpoint
    8389936: nativenum
    8389238: network
    8389640: networkkey128bit
    8389639: networkkey64bit
    8388826: next
    8389645: nextarrow
    8391581: notes
    8389584: notificationcount
    8390340: notifysynccomplete
    8390339: notifysyncprogress
    8389329: november
    8388922: now
    8390447: numchannels
    8390046: numcomponents
    8390595: numlocations
    8391510: numberinstalledapps
    8391720: obj
    8391675: observationlocationname
    8391676: observationlocationposition
    8391674: observationtime
    8389328: october
    8389932: offcoursedistance
    8391337: offset
    8391781: offsetx
    8391782: offsety
    8389626: onaccept
    8392235: onactive
    8391171: onactivitycompleted
    8390378: onadaction
    8391314: onanimationevent
    8390788: onappinstall
    8392284: onappinstallstateevent
    8390789: onappupdate
    8391866: onauthenticationrequest
    8389081: onback
    8390170: onbackgrounddata
    8390037: onbatterystatusupdate
    8390675: onbikecadenceupdate
    8390048: onbikelightupdate
    8390643: onbikeradarupdate
    8390676: onbikespeedcadenceupdate
    8390674: onbikespeedupdate
    8390031: oncalculatedcadenceupdate
    8390032: oncalculatedpowerupdate
    8390033: oncalculatedwheeldistanceupdate
    8390034: oncalculatedwheelspeedupdate
    8389541: oncancel
    8391263: oncharacteristicchanged
    8391259: oncharacteristicread
    8391260: oncharacteristicwrite
    8388829: oncomplete
    8391258: onconnectedstatechanged
    8391045: oncustombutton
    8391261: ondescriptorread
    8391262: ondescriptorwrite
    8390040: ondevicestateupdate
    8392289: ondisplaymodechanged
    8390422: ondone
    8391828: ondrag
    8392244: onencryptionstatus
    8392207: onenhancedreadabilitymodechanged
    8389376: onentersleep
    8388828: onerror
    8389377: onexitsleep
    8390306: onfitnessequipmentupdate
    8391827: onflick
    8390751: onfooter
    8391456: onglanceevent
    8390149: ongoalreached
    8389125: onhide
    8389099: onhold
    8392236: oninactive
    8389097: onkey
    8389553: onkeypressed
    8389554: onkeyreleased
    8389122: onlayout
    8390047: onlightnetworkstateupdate
    8390038: onmanufacturerinfoupdate
    8389080: onmenu
    8389109: onmenuitem
    8391211: onmessage
    8389082: onnextmode
    8390686: onnextmultisportleg
    8389078: onnextpage
    8391958: onnextview
    8391885: onnightmodechanged
    8389102: onnumberpicked
    8390200: onoauthresponse
    8390097: onpartialupdate
    8390035: onpedalpowerbalanceupdate
    8391507: onphoneappmessage
    8390098: onpowerbudgetexceeded
    8392031: onpress
    8389083: onpreviousmode
    8389079: onpreviouspage
    8391959: onpreviousview
    8390039: onproductinfoupdate
    8391257: onprofileregister
    8391162: onpushnotification
    8390061: onreceivecomplete
    8390062: onreceivefail
    8389100: onrelease
    8390784: onrepeat
    8389108: onresponse
    8390287: onrunningdynamicsupdate
    8391256: onscanresults
    8391255: onscanstatechange
    8389619: onselect
    8389890: onselectable
    8390288: onsensorpositionupdate
    8391350: onsentmessage
    8389683: onsettingschanged
    8391367: onshiftingupdate
    8389123: onshow
    8390381: onshuffle
    8390151: onsleeptime
    8390382: onsong
    8389279: onstart
    8390341: onstartsync
    8390152: onsteps
    8389281: onstop
    8390459: onstopsync
    8391704: onstoragechanged
    8389101: onswipe
    8389098: ontap
    8390148: ontemporalevent
    8389540: ontextentered
    8390380: onthumbsdown
    8390379: onthumbsup
    8389751: ontimerlap
    8389749: ontimerpause
    8389752: ontimerreset
    8389750: ontimerresume
    8389747: ontimerstart
    8389748: ontimerstop
    8390750: ontitle
    8390036: ontorqueeffectivenesspedalsmoothnessupdate
    8390063: ontransmitcomplete
    8390064: ontransmitfail
    8389124: onupdate
    8391811: onvalidateproperty
    8390150: onwaketime
    8391698: onworkoutstarted
    8390685: onworkoutstepcomplete
    8390749: onwrap
    8389256: open
    8391810: openappsettingseditor
    8389842: openwebpage
    8389527: operatingtime
    8389809: order
    8390270: orientation
    8390519: output
    8391694: oxygensaturation
    8389403: paceunits
    8391907: packingformat
    8392160: page
    8389057: pagectrlnative
    8391352: pagenumber
    8391225: pairdevice
    8389660: palette
    8389299: parse
    8389675: partnumber
    8389643: pattern
    8389503: pedalpowerpercent
    8390371: peeknext
    8390372: peekprevious
    8389808: period
    8389535: persistlocation
    8389543: phoneconnected
    8390081: pitch
    8391298: play
    8390355: playspeedmultipliers
    8388985: playtone
    8390471: playbackcontrols
    8390365: playbacknotificationthreshold
    8391037: playercolors_
    8390688: poollength
    8389050: popview
    8389310: position_
    8388900: pow
    8388961: power
    8389482: powersensortype
    8392176: preconcatenate
    8391669: precipitationchance
    8388964: pressure
    8390370: previous
    8389646: previousarrow
    8391508: prgbytesused
    8391509: prgmaximumbytesallowed
    8388712: print
    8389576: printstacktrace
    8388711: println
    8390621: privatekey
    8391040: progressbarbackgroundcolor
    8391039: progressbarforegroundcolor
    8390620: protocol
    8392206: pushdistance
    8392205: pushgoal
    8389049: pushview
    8392204: pushes
    8388788: put
    8389316: radians
    8389271: radiofrequency
    8389759: radius
    8388901: rand
    8390513: randombytes
    8390646: range
    8392018: ranges
    8390214: rawambientpressure
    8391364: rearderailleur
    8389818: rearderailleurindex
    8389819: rearderailleurmax
    8389820: rearderailleursize
    8392026: registercomplicationchangecallback
    8391172: registerforactivitycompletedevent
    8392279: registerforappinstallstateevent
    8390160: registerforgoalevent
    8389841: registerforoauthmessages
    8390201: registerforoauthresponseevent
    8391592: registerforphoneappmessageevent
    8389939: registerforphoneappmessages
    8391163: registerforpushnotificationevent
    8391168: registerforpushnotifications
    8390156: registerforsleepevent
    8390162: registerforstepsevent
    8390153: registerfortemporalevent
    8390158: registerforwakeevent
    8391232: registerprofile
    8390074: registersensordatalistener
    8391673: relativehumidity
    8389258: release
    8388791: remove
    8389824: removeall
    8391440: removelayer
    8391336: repeatcount
    8390783: repeatmode
    8391589: repetitionnumber
    8390165: requestapplicationwake
    8392246: requestbond
    8391034: requestplaybackprofileupdate
    8391250: requestread
    8389026: requestupdate
    8391251: requestwrite
    8390364: requireplaybacknotification
    8391194: requiresburninprotection
    8390327: resetcontentcache
    8390557: resetcontentiterator
    8391724: resettemporalevent
    8391768: resource
    8391831: respirationrate
    8389843: responsecode
    8389844: responsetype
    8391591: reststep
    8389149: restingheartrate
    8390022: restoreheadlightsnetworkmodecontrol
    8390023: restoretaillightsnetworkmodecontrol
    8391787: resume
    8389825: reverse
    8391167: revokepushnotificationtoken
    8389345: rezid
    8391894: rightbutton
    8389502: rightpedalindicator
    8389475: rightpedalsmoothness
    8389472: righttorqueeffectiveness
    8390082: roll
    8392171: rotate
    8389719: round
    8389248: rssi
    8389568: runtest
    8389147: runningsteplength
    8390182: samplecount
    8390183: sampleperiod
    8390134: samplerate
    8388882: save
    8389287: saveproperties
    8390066: savewaypoint
    8392172: scale
    8389672: screenheight
    8389670: screenshape
    8389671: screenwidth
    8389274: searchthreshold
    8389273: searchtimeouthighpriority
    8389272: searchtimeoutlowpriority
    8388722: sec
    8389339: second
    8389344: seconds
    8389318: semicircles
    8389259: sendacknowledge
    8389260: sendbroadcast
    8390057: sendburst
    8391210: sendmanufacturermessage
    8391176: sendnotification
    8391354: sendpagerequest
    8390184: sensorlogger_
    8389473: separatepedalsmoothnesssupport
    8389327: september
    8389522: serial
    8391012: setalbumart
    8391701: setantialias
    8389896: setbackgroundcolor
    8389634: setbackgroundscan
    8389107: setbitmap
    8391738: setblendmode
    8390058: setburstlistener
    8390397: setchecked
    8390103: setclip
    8391805: setclockhandposition
    8389131: setcolor
    8391892: setcontrolbar
    8389864: setdata
    8391224: setdelegate
    8389255: setdeviceconfig
    8392302: setdirty
    8389088: setdisplaystring
    8392301: setdivider
    8392307: setdividericon
    8392303: setdividertype
    8390737: setdrawable
    8390403: setenabled
    8388956: setenabledsensors
    8391739: setfill
    8391932: setflashlightmode
    8390417: setfocus
    8390739: setfocusitemheight
    8389132: setfont
    8390735: setfooter
    8391795: setfooteritemheight
    8390736: setforeground
    8390024: setheadlightsmode
    8390414: seticon
    8392012: setindex
    8390738: setitemheight
    8389133: setjustification
    8389894: setkeytoselectableinteraction
    8390412: setlabel
    8389126: setlayout
    8389481: setlistener
    8389069: setlocation
    8388822: setmailboxlistener
    8390586: setmapmarker
    8390587: setmapmode
    8390588: setmapvisiblearea
    8392166: setmatrix
    8390350: setmetadata
    8390043: setmode
    8391780: setoffset
    8389625: setoptions
    8390109: setpalette
    8389252: setpayload
    8389192: setpenwidth
    8390585: setpolyline
    8389087: setprogress
    8389283: setproperty
    8391228: setscanstate
    8390589: setscreenvisiblearea
    8389070: setsize
    8389903: setstate
    8390411: setstring
    8391740: setstroke
    8390401: setsublabel
    8390025: settaillightsmode
    8389134: settext
    8392182: settheme
    8391188: settimereventlistener
    8389094: settitle
    8391794: settitleitemheight
    8392167: settorotation
    8392168: settoscale
    8392169: settoshear
    8392170: settotranslation
    8390297: settrainermode
    8392010: setuuid
    8390426: setvalue
    8391299: setvisible
    8390594: setwidth
    8391436: setx
    8391437: sety
    8392173: shear
    8391373: shiftfailurecount
    8392015: shortlabel
    8392153: showactionmenu
    8391699: showalert
    8391940: showtoast
    8390442: shuffle
    8390373: shuffling
    8390305: simulationsupported
    8388902: sin
    8388782: size
    8392277: skipbackwardtimedelta
    8392276: skipforwardtimedelta
    8390563: skippreviousthreshold
    8389146: sleeptime
    8389826: slice
    8390282: slope
    8391693: softwareversion
    8391500: solarintensity
    8392273: sort
    8388958: speed
    8388890: sport
    8388903: sqrt
    8388904: srand
    8390273: stancetime
    8388698: start
    8388730: startlocation
    8388916: startofday
    8390476: startplayback
    8390786: startsync
    8391813: startsync2
    8388731: starttime
    8392050: startuserreview
    8389487: state
    8389897: statedefault
    8389900: statedisabled
    8389898: statehighlighted
    8389899: stateselected
    8388610: statics
    8391213: stdev
    8391582: step
    8390274: stepcount
    8388913: stepgoal
    8390275: steplength
    8388912: steps
    8389655: stillalive
    8388699: stop
    8391463: stopplayback
    8391502: storeid
    8391501: storeversion
    8392278: stressscore
    8391230: stringtouuid
    8392149: strobemode
    8392150: strobespeed
    8388891: subsport
    8392027: subscribetoupdates
    8388797: substring
    8388943: subtract
    8390363: supportsplaylistpreview
    8390285: surfaceresistance
    8391788: suspend
    8389523: swrevisionmain
    8389524: swrevisionsupplemental
    8388753: swimstroketype
    8388754: swimswolf
    8389051: switchtoview
    8389891: symbol_
    8391426: systemlanguage
    8388905: tan
    8390265: targetpower
    8390304: targetpowersupported
    8391586: targettype
    8391588: targetvaluehigh
    8391587: targetvaluelow
    8391692: technology
    8388962: temperature
    8389407: temperatureunits
    8390141: test_
    8390106: testgraphics
    8389304: testinfostring
    8390070: testopcodespeed
    8389346: text_
    8391038: textcolor
    8391941: theme
    8390644: threat
    8390645: threatside
    8389249: thresholdconfiguration
    8391830: timetorecovery
    8388723: timezoneoffset
    8389814: timerstate
    8388733: timertime
    8389250: timestamp
    8392231: tintcolor
    8389642: title
    8391796: titleitemheight
    8391274: tobytearray
    8389830: tochar
    8389828: tochararray
    8389307: todegrees
    8388776: todouble
    8388773: tofloat
    8389309: togeostring
    8389964: tointent
    8388777: tolong
    8391452: tolongwithbase
    8388798: tolower
    8391878: tomoment
    8388775: tonumber
    8389827: tonumberwithbase
    8389308: toradians
    8390552: torepresentation
    8388783: tostring
    8388799: toupper
    8389829: toutf8array
    8388923: today
    8390026: togglesignallight
    8391338: toneprofile_
    8389400: toneson
    8389866: total
    8388745: totalascent
    8388746: totaldescent
    8388727: totalmemory
    8389931: track_
    8390386: tracknumber
    8389651: trainingeffect
    8392233: transform
    8392180: transformpoint
    8392181: transformpoints
    8392174: translate
    8389246: transmissiontype
    8388824: transmit
    8389846: type
    8391499: uninstallapp
    8390457: uniqueidentifier
    8392017: unit
    8389849: units
    8391226: unpairdevice
    8390075: unregistersensordatalistener
    8392029: unsubscribefromallupdates
    8392028: unsubscribefromupdates
    8390514: update
    8392030: updatecomplication
    8390420: updateitem
    8389947: uri
    8388725: usedmemory
    8390123: userinfostring
    8390299: userweight
    8389878: utcinfo
    8389880: utf8arraytostring
    8391334: uuid_
    8390778: validatedrawable
    8392304: validateicon
    8389288: validateproperty
    8388947: value
    8388794: values
    8391214: variance
    8390277: verticaloscillation
    8390278: verticalratio
    8388987: vibrate
    8389399: vibrateon
    8389868: vigorous
    8391445: visibility
    8391829: visible
    8391856: vo2maxcycling
    8391855: vo2maxrunning
    8389145: waketime
    8390276: walkingflag
    8389148: walkingsteplength
    8389794: warning
    8389656: weak
    8389143: weight
    8389405: weightunits
    8390301: wheeldiameter
    8389312: when
    8389066: width
    8390484: wifi
    8391714: wifiavailable
    8391671: windbearing
    8390284: windresistance
    8390283: windspeed
    8392161: wrap
    8391335: writetype
    8390078: x
    8390079: y
    8388940: year
    8389340: years
    8390080: z
