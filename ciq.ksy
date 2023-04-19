meta:
  id: ciq
  file-extension: PRG
  endian: be

seq:
  - id: sections
    doc: List of PRG sections.
    type: section
    repeat: eos

types:
  section:
    doc: A PRG section.
    seq:
      - id: section_type
        type: u4
      - id: length
        type: u4
      - id: data
        size: length
        type:
          switch-on: section_type
          cases:
            section_magic::section_magic_end.to_i: section_end
            section_magic::section_magic_head.to_i: section_head
            section_magic::section_magic_code.to_i: section_code
            section_magic::section_magic_data.to_i: section_data
            section_magic::section_magic_pc_to_line_num.to_i: section_pc_to_line_num
            section_magic::section_magic_entry_points.to_i: section_entry_points
            section_magic::section_magic_link_table.to_i: section_link_table
            section_magic::section_magic_permissions.to_i: section_permissions
            section_magic::section_magic_exceptions.to_i: section_exceptions
            section_magic::section_magic_symbols.to_i: section_symbols
            section_magic::section_magic_string_resource_symbols.to_i: section_string_resource_symbols
            section_magic::section_magic_settings.to_i: section_settings
            section_magic::section_magic_app_unlock.to_i: section_app_unlock
            section_magic::section_magic_resource_block.to_i: section_resource_block
            section_magic::section_magic_background_resource_block.to_i: section_background_resource_block
            section_magic::section_magic_glance_resource_block.to_i: section_glance_resource_block
            section_magic::section_magic_app_store_signature_block.to_i: section_app_store_signature_block
            section_magic::section_magic_developer_signature_block.to_i: section_developer_signature_block
            section_magic::section_magic_class_def.to_i: section_class_def
    enums:
      section_magic:
        0x00000000: section_magic_end
        0xd000d000: section_magic_head
        0xc0debabe: section_magic_code
        0xda7ababe: section_magic_data
        0xc0de7ab1: section_magic_pc_to_line_num
        0x6060c0de: section_magic_entry_points
        0xc1a557b1: section_magic_link_table
        0x6000db01: section_magic_permissions
        0x0ece7105: section_magic_exceptions
        0x5717b015: section_magic_symbols
        0xbaada555: section_magic_string_resource_symbols
        0x5e771465: section_magic_settings
        0xd011aaa5: section_magic_app_unlock
        0xf00d600d: section_magic_resource_block
        0xdefeca7e: section_magic_background_resource_block
        0xd00dface: section_magic_glance_resource_block
        0x00005161: section_magic_app_store_signature_block
        0xe1c0de12: section_magic_developer_signature_block
        0xc1a55def: section_magic_class_def

  section_head:
    doc: Head section with metadata such as version.
    seq:
      - id: unused
        type: u1
      - id: version
        type: connect_iq_version
      - id: background_offsets
        type: offsets
      - id: app_lock_indicator
        type: u1
      - id: unused2
        type: u4
      - id: unused3
        type: u4
      - id: glance_offsets
        type: offsets
      - id: flags
        type: u4
    instances:
      app_lock:
        value: app_lock_indicator != 0
      glance_support:
        value: (flags & 0x1) != 0
      profiling_enabled:
        value: (flags & 0x2) != 0

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
      - id: entry_point
        type: entry_point
        repeat: eos

  section_data:
    doc: Data section
    seq:
      - id: data_entries
        type: data_entries
        repeat: eos

  section_code:
    doc: Code section
    seq:
      - id: code
        type: op_code
        repeat: eos

  section_resource_block:
    doc: Resource block.
    # TODO
    seq:
      - id: data
        size: _parent.length

  section_background_resource_block:
    doc: Background resource block.
    # TODO
    seq:
      - id: data
        size: _parent.length

  section_glance_resource_block:
    doc: Glance resource block.
    # TODO
    seq:
      - id: data
        size: _parent.length

  section_class_def:
    doc: Class definition.
    # TODO
    seq:
      - id: data
        size: _parent.length

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

  section_string_resource_symbols:
    doc: String resource symbols section.
    # TODO
    seq:
      - id: data
        size: _parent.length

  section_settings:
    doc: Settings section.
    # TODO
    seq:
      - id: data
        size: _parent.length

  section_app_unlock:
    doc: App unlock section.
    seq:
      - id: flags
        type: u4
      - id: unit_id
        type: u4le

  section_app_store_signature_block:
    doc: App store signature block.
    # TODO
    seq:
      - id: data
        size: _parent.length

  section_developer_signature_block:
    doc: Developer signature block section
    seq:
      - id: signature
        size: 512
      - id: modulus
        size: 512
      - id: exponent
        type: u4

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
      - id: class_id
        type: u4

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
      - id: argument
        type:
          switch-on: op_code
          cases:
            op_code_enum::op_lpush: u8
            op_code_enum::op_dpush: u8
            op_code_enum::op_ipush: u4
            op_code_enum::op_fpush: u4
            op_code_enum::op_spush: u4
            op_code_enum::op_cpush: u4
            op_code_enum::op_news: u4
            op_code_enum::op_goto: u2
            op_code_enum::op_bt: u2
            op_code_enum::op_bf: u2
            op_code_enum::op_jsr: u2
            op_code_enum::op_shlv: u1
            op_code_enum::op_shrv: u1
            op_code_enum::op_lgetv: u1
            op_code_enum::op_lputv: u1
            op_code_enum::op_invoke: u1
            op_code_enum::op_argc: u1
            op_code_enum::op_incsp: u1
            op_code_enum::op_bpush: u1
            op_code_enum::op_dup: u1
            # Remaining opcodes do not take arguments.
    enums:
      op_code_enum:
        0x00: op_nop  # 1 byte
        0x01: op_incsp  # 2 bytes
        0x02: op_popv  # 1 byte
        0x03: op_addv  # 1 byte
        0x04: op_subv  # 1 byte
        0x05: op_mulv  # 1 byte
        0x06: op_divv  # 1 byte
        0x07: op_andv  # 1 byte
        0x08: op_orv  # 1 byte
        0x09: op_modv  # 1 byte
        0x0a: op_shlv  # 2 bytes
        0x0b: op_shrv  # 2 bytes
        0x0c: op_xorv  # 1 byte
        0x0d: op_getv  # 1 byte
        0x0e: op_putv  # 1 byte
        0x0f: op_invoke  # 2 bytes
        0x10: op_agetv  # 1 byte
        0x11: op_aputv  # 2 bytes
        0x12: op_lgetv  # 2 bytes
        0x13: op_lputv  # 2 bytes
        0x14: op_newa  # 1 byte
        0x15: op_newc  # 1 byte
        0x16: op_return  # 1 byte
        0x17: op_ret  # 1 byte
        0x18: op_news  # 5 bytes
        0x19: op_goto  # 3 bytes
        0x1a: op_eq  # 1 byte
        0x1b: op_lt  # 1 byte
        0x1c: op_lte  # 1 byte
        0x1d: op_gt  # 1 byte
        0x1e: op_gte  # 1 byte
        0x1f: op_ne  # 1 byte
        0x20: op_isnull  # 1 byte
        0x21: op_isa  # 1 byte
        0x22: op_canhazplz  # 1 byte
        0x23: op_jsr  # 3 bytes
        0x24: op_ts  # 1 byte
        0x25: op_ipush  # 5 bytes
        0x26: op_fpush  # 5 bytes
        0x27: op_spush  # 5 bytes
        0x28: op_bt  # 3 bytes
        0x29: op_bf  # 3 bytes
        0x2a: op_frpush  # 1 byte
        0x2b: op_bpush  # 2 bytes
        0x2c: op_npush  # 1 byte
        0x2d: op_invv  # 1 byte
        0x2e: op_dup  # 2 bytes
        0x2f: op_newd  # 1 byte
        0x30: op_getm  # 1 byte
        0x31: op_lpush  # 9 bytes
        0x32: op_dpush  # 9 bytes
        0x33: op_throw  # 1 byte
        0x34: op_cpush  # 5 bytes
        0x35: op_argc  # 2 bytes
        0x36: op_newba  # 1 byte

  data_entries:
    doc: Data entries.
    seq:
      # FIXME: Sentinal can be 1 or 4 bytes. Currently treating it as 1 byte, and the remaining 3 bytes are consumed by the corresponding data entry.
      - id: sentinel
        type: u1
      - id: data_entry
        type:
          switch-on: sentinel
          cases:
            0x01: string_def
            _: class_def  # 0xc1a55def

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
    doc: Class definition.
    seq:
      - id: sentinel_fragment
        size: 3  # FIXME: See data_entries and how to handle variable-sized sentinels
      - id: extends_offset
        type: u4
      - id: statics_entry
        type: u4
      - id: parent_module
        type: u4
      - id: module_id
        type: u4
      - id: app_types
        type: u2
      - id: fields_size
        type: u1
      - id: fields_def
        type: fields_def
        size: fields_size * sizeof<field_def>
    instances:
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
        encoding: utf-8
        size: length + 1

  fields_def:
    doc: List of field definitions.
    seq:
      - id: field
        type: field_def
        repeat: eos

  field_def:
    doc: Field definition.
    seq:
      - id: code_offset
        type: u4
      - id: field_value
        type: u4

    instances:
      symbol_value:
        value: (code_offset >> 8 & 0xFFFFFF)
      value_type:
        value: (code_offset & 0xF)
      flags:
        value: (code_offset >> 4 & 0xF)

enums:
  app_type:
    0: watch_face
    1: watch_app
    2: datafield
    3: widget
    4: background
    5: audio_content_provider_app
    6: glance
  field_type:
    0: field_null
    1: field_int
    2: field_float
    3: field_string
    6: field_method
    7: field_class
    8: field_symbol
    9: field_boolean
    10: field_module
