# This is a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild

from pkg_resources import parse_version
import kaitaistruct
from kaitaistruct import KaitaiStruct, KaitaiStream, BytesIO
from enum import Enum


if parse_version(kaitaistruct.__version__) < parse_version('0.9'):
    raise Exception("Incompatible Kaitai Struct Python API: 0.9 or later is required, but you have %s" % (kaitaistruct.__version__))

class Ciq(KaitaiStruct):

    class AppType(Enum):
        watch_face = 0
        watch_app = 1
        datafield = 2
        widget = 3
        background = 4
        audio_content_provider_app = 5
        glance = 6

    class FieldType(Enum):
        field_null = 0
        field_int = 1
        field_float = 2
        field_string = 3
        field_method = 6
        field_class = 7
        field_symbol = 8
        field_boolean = 9
        field_module = 10
    def __init__(self, _io, _parent=None, _root=None):
        self._io = _io
        self._parent = _parent
        self._root = _root if _root else self
        self._read()

    def _read(self):
        self.sections = []
        i = 0
        while not self._io.is_eof():
            self.sections.append(Ciq.Section(self._io, self, self._root))
            i += 1


    class ConnectIqVersion(KaitaiStruct):
        """Connect IQ Version."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.major = self._io.read_u1()
            self.minor = self._io.read_u1()
            self.micro = self._io.read_u1()


    class ExceptionTableEntry(KaitaiStruct):
        """Exception table entry."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.try_begin = self._io.read_bits_int_be(24)
            self.try_end = self._io.read_bits_int_be(24)
            self.handle_begin = self._io.read_bits_int_be(24)


    class SectionClassDef(KaitaiStruct):
        """Class definition."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)


    class FieldsDef(KaitaiStruct):
        """List of field definitions."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.field = []
            i = 0
            while not self._io.is_eof():
                self.field.append(Ciq.FieldDef(self._io, self, self._root))
                i += 1



    class SectionResourceBlock(KaitaiStruct):
        """Resource block."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)


    class LinkTableEntries(KaitaiStruct):
        """Link table entries."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.link_table_entries = []
            i = 0
            while not self._io.is_eof():
                self.link_table_entries.append(Ciq.LinkTableEntry(self._io, self, self._root))
                i += 1



    class SectionLinkTable(KaitaiStruct):
        """Link table section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.size = self._io.read_u2be()
            self._raw_link_table_entries = self._io.read_bytes((self.size * 8))
            _io__raw_link_table_entries = KaitaiStream(BytesIO(self._raw_link_table_entries))
            self.link_table_entries = Ciq.LinkTableEntries(_io__raw_link_table_entries, self, self._root)


    class StringDef(KaitaiStruct):
        """String definition."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.length = self._io.read_u2be()
            self.data = (self._io.read_bytes((self.length + 1))).decode(u"utf-8")


    class LinkTableEntry(KaitaiStruct):
        """Link table entry."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.module_id = self._io.read_u4be()
            self.class_id = self._io.read_u4be()


    class SectionEnd(KaitaiStruct):
        """End of section, placed at the end of a PRG file, containing no data."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)


    class SectionAppStoreSignatureBlock(KaitaiStruct):
        """App store signature block."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)


    class ExceptionsTable(KaitaiStruct):
        """Exceptions table."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.exceptions_table_entries = []
            i = 0
            while not self._io.is_eof():
                self.exceptions_table_entries.append(Ciq.ExceptionTableEntry(self._io, self, self._root))
                i += 1



    class Permissions(KaitaiStruct):
        """List of permissions."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.permission_entry = []
            i = 0
            while not self._io.is_eof():
                self.permission_entry.append(Ciq.PermissionEntry(self._io, self, self._root))
                i += 1



    class DataEntries(KaitaiStruct):
        """Data entries."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.sentinel = self._io.read_u1()
            _on = self.sentinel
            if _on == 1:
                self.data_entry = Ciq.StringDef(self._io, self, self._root)
            else:
                self.data_entry = Ciq.ClassDef(self._io, self, self._root)


    class PermissionEntry(KaitaiStruct):
        """Permission entry."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.permission_id = self._io.read_u4be()


    class ClassDef(KaitaiStruct):
        """Class definition."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.sentinel_fragment = self._io.read_bytes(3)
            self.extends_offset = self._io.read_u4be()
            self.statics_entry = self._io.read_u4be()
            self.parent_module = self._io.read_u4be()
            self.module_id = self._io.read_u4be()
            self.app_types = self._io.read_u2be()
            self.fields_size = self._io.read_u1()
            self._raw_fields_def = self._io.read_bytes((self.fields_size * 8))
            _io__raw_fields_def = KaitaiStream(BytesIO(self._raw_fields_def))
            self.fields_def = Ciq.FieldsDef(_io__raw_fields_def, self, self._root)

        @property
        def permission_required(self):
            if hasattr(self, '_m_permission_required'):
                return self._m_permission_required if hasattr(self, '_m_permission_required') else None

            self._m_permission_required = (self.app_types & 32768) != 0
            return self._m_permission_required if hasattr(self, '_m_permission_required') else None

        @property
        def actual_app_types(self):
            if hasattr(self, '_m_actual_app_types'):
                return self._m_actual_app_types if hasattr(self, '_m_actual_app_types') else None

            self._m_actual_app_types = ((self.app_types & 4294934527) & 65535)
            return self._m_actual_app_types if hasattr(self, '_m_actual_app_types') else None


    class Offsets(KaitaiStruct):
        """Offsets."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.m_data_offset = self._io.read_u4be()
            self.m_code_offset = self._io.read_u4be()


    class SectionSymbols(KaitaiStruct):
        """Symbols section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.size = self._io.read_u2be()
            self._raw_symbols = self._io.read_bytes((self.size * 8))
            _io__raw_symbols = KaitaiStream(BytesIO(self._raw_symbols))
            self.symbols = Ciq.Symbols(_io__raw_symbols, self, self._root)


    class Section(KaitaiStruct):
        """A PRG section."""

        class SectionMagic(Enum):
            section_magic_end = 0
            section_magic_app_store_signature_block = 20833
            section_magic_exceptions = 248410373
            section_magic_symbols = 1461170197
            section_magic_settings = 1584862309
            section_magic_permissions = 1610668801
            section_magic_entry_points = 1616953566
            section_magic_string_resource_symbols = 3131942229
            section_magic_pc_to_line_num = 3235805873
            section_magic_code = 3235822270
            section_magic_link_table = 3248838577
            section_magic_class_def = 3248840175
            section_magic_head = 3489714176
            section_magic_glance_resource_block = 3490577102
            section_magic_app_unlock = 3490818725
            section_magic_data = 3665476286
            section_magic_background_resource_block = 3741239934
            section_magic_developer_signature_block = 3787513362
            section_magic_resource_block = 4027408397
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.section_type = self._io.read_u4be()
            self.length = self._io.read_u4be()
            _on = self.section_type
            if _on == Ciq.Section.SectionMagic.section_magic_entry_points.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionEntryPoints(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_data.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionData(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_background_resource_block.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionBackgroundResourceBlock(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_pc_to_line_num.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionPcToLineNum(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_settings.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionSettings(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_resource_block.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionResourceBlock(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_link_table.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionLinkTable(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_class_def.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionClassDef(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_permissions.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionPermissions(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_code.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionCode(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_app_store_signature_block.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionAppStoreSignatureBlock(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_string_resource_symbols.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionStringResourceSymbols(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_end.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionEnd(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_head.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionHead(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_developer_signature_block.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionDeveloperSignatureBlock(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_app_unlock.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionAppUnlock(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_glance_resource_block.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionGlanceResourceBlock(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_symbols.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionSymbols(_io__raw_data, self, self._root)
            elif _on == Ciq.Section.SectionMagic.section_magic_exceptions.value:
                self._raw_data = self._io.read_bytes(self.length)
                _io__raw_data = KaitaiStream(BytesIO(self._raw_data))
                self.data = Ciq.SectionExceptions(_io__raw_data, self, self._root)
            else:
                self.data = self._io.read_bytes(self.length)


    class LineNumberEntries(KaitaiStruct):
        """Line number entries."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.line_number_entry = []
            i = 0
            while not self._io.is_eof():
                self.line_number_entry.append(Ciq.LineNumberEntry(self._io, self, self._root))
                i += 1



    class SectionPcToLineNum(KaitaiStruct):
        """PC to line number section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.size = self._io.read_u2be()
            self._raw_line_number_entries = self._io.read_bytes((self.size * 16))
            _io__raw_line_number_entries = KaitaiStream(BytesIO(self._raw_line_number_entries))
            self.line_number_entries = Ciq.LineNumberEntries(_io__raw_line_number_entries, self, self._root)


    class SectionEntryPoints(KaitaiStruct):
        """Entry points section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.size = self._io.read_u2be()
            self.entry_point = []
            i = 0
            while not self._io.is_eof():
                self.entry_point.append(Ciq.EntryPoint(self._io, self, self._root))
                i += 1



    class Symbols(KaitaiStruct):
        """List of symbols."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.symbol = []
            i = 0
            while not self._io.is_eof():
                self.symbol.append(Ciq.Symbol(self._io, self, self._root))
                i += 1



    class SectionGlanceResourceBlock(KaitaiStruct):
        """Glance resource block."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)


    class FieldDef(KaitaiStruct):
        """Field definition."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.code_offset = self._io.read_u4be()
            self.field_value = self._io.read_u4be()

        @property
        def symbol_value(self):
            if hasattr(self, '_m_symbol_value'):
                return self._m_symbol_value if hasattr(self, '_m_symbol_value') else None

            self._m_symbol_value = ((self.code_offset >> 8) & 16777215)
            return self._m_symbol_value if hasattr(self, '_m_symbol_value') else None

        @property
        def value_type(self):
            if hasattr(self, '_m_value_type'):
                return self._m_value_type if hasattr(self, '_m_value_type') else None

            self._m_value_type = (self.code_offset & 15)
            return self._m_value_type if hasattr(self, '_m_value_type') else None

        @property
        def flags(self):
            if hasattr(self, '_m_flags'):
                return self._m_flags if hasattr(self, '_m_flags') else None

            self._m_flags = ((self.code_offset >> 4) & 15)
            return self._m_flags if hasattr(self, '_m_flags') else None


    class Symbol(KaitaiStruct):
        """Symbol."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.symbol = self._io.read_u4be()
            self.label = self._io.read_u4be()


    class SectionBackgroundResourceBlock(KaitaiStruct):
        """Background resource block."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)


    class EntryPoint(KaitaiStruct):
        """Entry point."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.uuid = self._io.read_bytes(16)
            self.module_id = self._io.read_u4be()
            self.class_id = self._io.read_u4be()
            self.label_id = self._io.read_u4be()
            self.icon_label_id = self._io.read_u4be()
            self.app_type = KaitaiStream.resolve_enum(Ciq.AppType, self._io.read_u4be())


    class SectionStringResourceSymbols(KaitaiStruct):
        """String resource symbols section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)


    class SectionPermissions(KaitaiStruct):
        """Permissions section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.size = self._io.read_u2be()
            self._raw_permissions = self._io.read_bytes((self.size * 4))
            _io__raw_permissions = KaitaiStream(BytesIO(self._raw_permissions))
            self.permissions = Ciq.Permissions(_io__raw_permissions, self, self._root)


    class SectionExceptions(KaitaiStruct):
        """Exceptions section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.size = self._io.read_u2be()
            self._raw_exceptions_table = self._io.read_bytes((self.size * 9))
            _io__raw_exceptions_table = KaitaiStream(BytesIO(self._raw_exceptions_table))
            self.exceptions_table = Ciq.ExceptionsTable(_io__raw_exceptions_table, self, self._root)


    class LineNumberEntry(KaitaiStruct):
        """Line number entry."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.pc = self._io.read_u4be()
            self.file = self._io.read_u4be()
            self.symbol = self._io.read_u4be()
            self.line_num = self._io.read_u4be()


    class SectionHead(KaitaiStruct):
        """Head section with metadata such as version."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.unused = self._io.read_u1()
            self.version = Ciq.ConnectIqVersion(self._io, self, self._root)
            self.background_offsets = Ciq.Offsets(self._io, self, self._root)
            self.app_lock_indicator = self._io.read_u1()
            self.unused2 = self._io.read_u4be()
            self.unused3 = self._io.read_u4be()
            self.glance_offsets = Ciq.Offsets(self._io, self, self._root)
            self.flags = self._io.read_u4be()

        @property
        def app_lock(self):
            if hasattr(self, '_m_app_lock'):
                return self._m_app_lock if hasattr(self, '_m_app_lock') else None

            self._m_app_lock = self.app_lock_indicator != 0
            return self._m_app_lock if hasattr(self, '_m_app_lock') else None

        @property
        def glance_support(self):
            if hasattr(self, '_m_glance_support'):
                return self._m_glance_support if hasattr(self, '_m_glance_support') else None

            self._m_glance_support = (self.flags & 1) != 0
            return self._m_glance_support if hasattr(self, '_m_glance_support') else None

        @property
        def profiling_enabled(self):
            if hasattr(self, '_m_profiling_enabled'):
                return self._m_profiling_enabled if hasattr(self, '_m_profiling_enabled') else None

            self._m_profiling_enabled = (self.flags & 2) != 0
            return self._m_profiling_enabled if hasattr(self, '_m_profiling_enabled') else None


    class SectionDeveloperSignatureBlock(KaitaiStruct):
        """Developer signature block section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.signature = self._io.read_bytes(512)
            self.modulus = self._io.read_bytes(512)
            self.exponent = self._io.read_u4be()


    class OpCode(KaitaiStruct):
        """OP code."""

        class OpCodeEnum(Enum):
            op_nop = 0
            op_incsp = 1
            op_popv = 2
            op_addv = 3
            op_subv = 4
            op_mulv = 5
            op_divv = 6
            op_andv = 7
            op_orv = 8
            op_modv = 9
            op_shlv = 10
            op_shrv = 11
            op_xorv = 12
            op_getv = 13
            op_putv = 14
            op_invoke = 15
            op_agetv = 16
            op_aputv = 17
            op_lgetv = 18
            op_lputv = 19
            op_newa = 20
            op_newc = 21
            op_return = 22
            op_ret = 23
            op_news = 24
            op_goto = 25
            op_eq = 26
            op_lt = 27
            op_lte = 28
            op_gt = 29
            op_gte = 30
            op_ne = 31
            op_isnull = 32
            op_isa = 33
            op_canhazplz = 34
            op_jsr = 35
            op_ts = 36
            op_ipush = 37
            op_fpush = 38
            op_spush = 39
            op_bt = 40
            op_bf = 41
            op_frpush = 42
            op_bpush = 43
            op_npush = 44
            op_invv = 45
            op_dup = 46
            op_newd = 47
            op_getm = 48
            op_lpush = 49
            op_dpush = 50
            op_throw = 51
            op_cpush = 52
            op_argc = 53
            op_newba = 54
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.op_code = KaitaiStream.resolve_enum(Ciq.OpCode.OpCodeEnum, self._io.read_u1())
            _on = self.op_code
            if _on == Ciq.OpCode.OpCodeEnum.op_invoke:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_dup:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_bt:
                self.argument = self._io.read_u2be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_lpush:
                self.argument = self._io.read_u8be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_news:
                self.argument = self._io.read_u4be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_bf:
                self.argument = self._io.read_u2be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_shlv:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_cpush:
                self.argument = self._io.read_u4be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_fpush:
                self.argument = self._io.read_u4be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_incsp:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_lgetv:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_dpush:
                self.argument = self._io.read_u8be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_lputv:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_ipush:
                self.argument = self._io.read_u4be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_goto:
                self.argument = self._io.read_u2be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_bpush:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_spush:
                self.argument = self._io.read_u4be()
            elif _on == Ciq.OpCode.OpCodeEnum.op_shrv:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_argc:
                self.argument = self._io.read_u1()
            elif _on == Ciq.OpCode.OpCodeEnum.op_jsr:
                self.argument = self._io.read_u2be()


    class SectionAppUnlock(KaitaiStruct):
        """App unlock section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.flags = self._io.read_u4be()
            self.unit_id = self._io.read_u4le()


    class SectionCode(KaitaiStruct):
        """Code section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.code = []
            i = 0
            while not self._io.is_eof():
                self.code.append(Ciq.OpCode(self._io, self, self._root))
                i += 1



    class SectionData(KaitaiStruct):
        """Data section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data_entries = []
            i = 0
            while not self._io.is_eof():
                self.data_entries.append(Ciq.DataEntries(self._io, self, self._root))
                i += 1



    class SectionSettings(KaitaiStruct):
        """Settings section."""
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.data = self._io.read_bytes(self._parent.length)



