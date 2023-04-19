import Toybox.System;
import Toybox.WatchUi;

class PoCDelegate extends WatchUi.InputDelegate {

    private var _view;

    function initialize(view) {
        WatchUi.InputDelegate.initialize();
        me._view = view;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        switch (key) {
            case WatchUi.KEY_ENTER:
                me._view.resetCount();
                return true;
            case WatchUi.KEY_UP:
                me._view.decCount();
                return true;
            case WatchUi.KEY_DOWN:
                me._view.incCount();
                return true;
        }
        return false;
    }
}