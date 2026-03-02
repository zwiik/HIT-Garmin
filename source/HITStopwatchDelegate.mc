import Toybox.Lang;
import Toybox.WatchUi;

class SaveConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var _view as HITStopwatchView;

    function initialize(view as HITStopwatchView) {
        ConfirmationDelegate.initialize();
        _view = view;
    }

    function onResponse(response as Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _view.saveSession();
        } else {
            _view.discardSession();
        }
        return true;
    }
}

class HITStopwatchDelegate extends WatchUi.BehaviorDelegate {
    private var view as HITStopwatchView;

    function initialize(view as HITStopwatchView) {
        BehaviorDelegate.initialize();
        me.view = view;
    }

    // Touch toggles start/pause or selects activity
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        var coords = evt.getCoordinates();
        return me.view.handleTap(coords[0], coords[1]);
    }

    // Handle dragging for the clickwheel
    function onDrag(evt as WatchUi.DragEvent) as Boolean {
        var coords = evt.getCoordinates();
        var type = evt.getType();
        return me.view.handleDrag(coords[0], coords[1], type);
    }

    // Button press toggles start/pause
    function onSelect() as Boolean {
        me.view.toggleTimer();
        return true;
    }

    // Menu button to save session
    function onMenu() as Boolean {
        me.view.saveSession();
        return true;
    }
    
    function onHold(evt as WatchUi.ClickEvent) as Boolean {
        me.view.resetCurrentActivity();
        return true;
    }

    // Back button behavior
    function onBack() as Boolean {
        var confirm = new WatchUi.Confirmation("Save Session?");
        var delegate = new SaveConfirmationDelegate(view);
        WatchUi.pushView(confirm, delegate, WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}
