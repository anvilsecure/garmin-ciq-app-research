import Toybox.Application;
import Toybox.WatchUi;

class PoCApp extends Application.AppBase {


    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        var view = new PoCView();
        var delegate = new PoCDelegate(view);
        return [ view , delegate ] as Array<Views or InputDelegates>;
    }

}

function getApp() as PoCApp {
    return Application.getApp() as PoCApp;
}