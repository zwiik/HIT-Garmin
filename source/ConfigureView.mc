import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

class HITConfigureView extends WatchUi.View {
    static const KIESER_MACHINES = [
        "A1 Hip Extension",
        "A2 Torso Flexion",
        "A3 Hip Abduction",
        "A4 Hip Adduction",
        "A5 Pelvic Floor",
        "B1 Leg Extension",
        "B2 Leg Curl",
        "B3 Foot Pronation",
        "B4 Foot Supination",
        "B5 Prone Leg Curl",
        "B6 Leg Press",
        "B7 Seated Leg Curl",
        "B8 Tibia Dorsiflexion",
        "C1 Pullover",
        "C3 Torso Arm",
        "C5 Rowing",
        "C7 Lat Pulldown",
        "D5 Arm Cross",
        "D6 Chest Press",
        "D7 Seated Dip",
        "E1 Neck Press",
        "E2 Lateral Raise",
        "E3 Overhead Press",
        "E4 Int. Rotation",
        "E5 Ext. Rotation",
        "F1.1 Rotary Torso",
        "F2.1 Abdominal",
        "F3.1 Lower Back",
        "G1 Neck/Shoulder",
        "H1 Biceps Curl",
        "LE Lumbar Ext",
        "CE Cervical Ext"
    ];

    private var _slotIndex = 0;
    private var _machineIndex = 0;
    private var _screenWidth = 0;
    private var _screenHeight = 0;
    
    // Local copy of mappings to allow "Cancel"
    private var _tempMappings = new [12] as Array<String>;

    function initialize() {
        View.initialize();
        for (var i = 0; i < 12; i++) {
            var val = Storage.getValue("code_" + i);
            _tempMappings[i] = (val != null) ? val : "None";
        }
        updateMachineIndex();
    }

    function onLayout(dc as Dc) as Void {
        _screenWidth = dc.getWidth();
        _screenHeight = dc.getHeight();
    }

    private function updateMachineIndex() as Void {
        var currentMachine = _tempMappings[_slotIndex];
        _machineIndex = 0;
        for (var i = 0; i < KIESER_MACHINES.size(); i++) {
            if (KIESER_MACHINES[i].equals(currentMachine)) {
                _machineIndex = i;
                break;
            }
        }
    }

    function changeSlot(delta as Integer) as Void {
        _slotIndex = (_slotIndex + delta + 12) % 12;
        updateMachineIndex();
        WatchUi.requestUpdate();
    }

    function changeMachine(delta as Integer) as Void {
        _machineIndex = (_machineIndex + delta + KIESER_MACHINES.size()) % KIESER_MACHINES.size();
        _tempMappings[_slotIndex] = KIESER_MACHINES[_machineIndex];
        WatchUi.requestUpdate();
    }

    function saveAndExit() as Void {
        for (var i = 0; i < 12; i++) {
            Storage.setValue("code_" + i, _tempMappings[i]);
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = _screenWidth / 2;
        var columnWidth = _screenWidth / 2;
        var rowHeight = 45;
        var centerY = _screenHeight / 2 - 20;

        // --- DRAW HEADERS ---
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX / 2, 40, Graphics.FONT_XTINY, "SLOT", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX + centerX / 2, 40, Graphics.FONT_XTINY, "MACHINE", Graphics.TEXT_JUSTIFY_CENTER);

        // --- LEFT WHEEL (Slots) ---
        drawVerticalWheel(dc, centerX / 2, centerY, _slotIndex, 12, null, Graphics.FONT_NUMBER_MEDIUM);

        // --- RIGHT WHEEL (Machines) ---
        drawVerticalWheel(dc, centerX + centerX / 2, centerY, _machineIndex, KIESER_MACHINES.size(), KIESER_MACHINES, Graphics.FONT_TINY);

        // --- SELECTION HIGHLIGHT (Horizontal Bar) ---
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(10, centerY - rowHeight / 2, _screenWidth - 20, rowHeight);

        // --- OK BUTTON ---
        var btnW = 80;
        var btnH = 40;
        var btnY = _screenHeight - 60;
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(centerX - btnW/2, btnY, btnW, btnH, 10);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, btnY + btnH/2, Graphics.FONT_SMALL, "OK", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawVerticalWheel(dc as Dc, x as Number, centerY as Number, currentIdx as Integer, total as Integer, data as Array<String>?, font as FontDefinition) as Void {
        var spacing = 45;
        for (var i = -2; i <= 2; i++) {
            var idx = (currentIdx + i + total) % total;
            var y = centerY + (i * spacing);
            
            var alpha = (i == 0) ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY;
            dc.setColor(alpha, Graphics.COLOR_TRANSPARENT);
            
            var text = (data != null) ? data[idx] : (idx + 1).format("%d");
            // Truncate machine names for the wheel if they are too long
            if (data != null && text.length() > 6) {
                var spaceIdx = text.find(" ");
                if (spaceIdx != null) { text = text.substring(0, spaceIdx); }
            }

            dc.drawText(x, y, (i == 0) ? font : Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function getOkButtonBounds() {
        return [_screenWidth/2 - 40, _screenHeight - 60, 80, 40];
    }
}

class HITConfigureDelegate extends WatchUi.BehaviorDelegate {
    private var _view as HITConfigureView;

    function initialize(view as HITConfigureView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(evt as ClickEvent) as Boolean {
        var coords = evt.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var screenW = System.getDeviceSettings().screenWidth;
        var screenH = System.getDeviceSettings().screenHeight;

        // Check OK Button
        var btn = _view.getOkButtonBounds();
        if (x >= btn[0] && x <= btn[0]+btn[2] && y >= btn[1] && y <= btn[1]+btn[3]) {
            _view.saveAndExit();
            return true;
        }

        // Left side tap (Up/Down)
        if (x < screenW / 2) {
            if (y < screenH / 2 - 20) { _view.changeSlot(-1); }
            else if (y > screenH / 2 + 20) { _view.changeSlot(1); }
        } 
        // Right side tap (Up/Down)
        else {
            if (y < screenH / 2 - 20) { _view.changeMachine(-1); }
            else if (y > screenH / 2 + 20) { _view.changeMachine(1); }
        }
        return true;
    }

    function onSwipe(evt as SwipeEvent) as Boolean {
        var dir = evt.getDirection();
        // Simple swipe logic - could be improved to detect left/right half
        if (dir == WatchUi.SWIPE_UP) { _view.changeMachine(1); }
        else if (dir == WatchUi.SWIPE_DOWN) { _view.changeMachine(-1); }
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
