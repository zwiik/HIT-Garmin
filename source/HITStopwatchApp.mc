import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;

import Rez.Layouts;

// -------- Start Page View & Delegate --------
class StartView extends WatchUi.View {
    private var options = ["Start Activity", "Configure", "Quit"] as Array<String>;
    private var currentIndex = 0;
    private var screenWidth = 0;
    private var screenHeight = 0;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = screenWidth / 2;
        var topHeight = screenHeight / 3;

        // --- DRAW TOP QUARTER ---
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var titleY = topHeight / 2;
        dc.drawText(centerX, titleY - 22, Graphics.FONT_MEDIUM, "HIT", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, titleY + 22, Graphics.FONT_MEDIUM, "Stopwatch", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Divider
        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, topHeight, screenWidth, topHeight);

        // --- DRAW PICKER (Bottom Area) ---
        var pickerCenterY = topHeight + (screenHeight - topHeight) / 2;
        var spacing = 50;

        for (var i = 0; i < options.size(); i++) {
            var y = pickerCenterY + (i - currentIndex) * spacing;
            
            if (y > topHeight && y < screenHeight) {
                if (i == currentIndex) {
                    var font = Graphics.FONT_LARGE;
                    var textWidth = dc.getTextWidthInPixels(options[i], font);
                    var pillW = textWidth + 40;
                    var pillH = dc.getFontHeight(font) + 10;
                    
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                    dc.fillRoundedRectangle(centerX - pillW/2, y - pillH/2, pillW, pillH, pillH/2);

                    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(centerX, y, font, options[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                } else {
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(centerX, y, Graphics.FONT_SMALL, options[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                }
            }
        }
    }

    function changeIndex(delta as Integer) as Void {
        currentIndex = (currentIndex + delta + options.size()) % options.size();
        WatchUi.requestUpdate();
    }

    function selectOption() as Void {
        if (currentIndex == 0) { // Start Activity
            var workoutView = new HITStopwatchView();
            var workoutDelegate = new HITStopwatchDelegate(workoutView);
            WatchUi.pushView(workoutView, workoutDelegate, WatchUi.SLIDE_UP);
        } else if (currentIndex == 1) { // Configure
            var configView = new HITConfigureView();
            WatchUi.pushView(configView, new HITConfigureDelegate(configView), WatchUi.SLIDE_UP);
        } else if (currentIndex == 2) { // Quit
            System.exit();
        }
    }

    function onTap(x as Number, y as Number) as Boolean {
        if (y < screenHeight / 3) {
            return false;
        }
        var pickerCenterY = (screenHeight / 3) + (screenHeight * 2 / 3) / 2;
        if (y < pickerCenterY - 30) {
            changeIndex(-1);
        } else if (y > pickerCenterY + 30) {
            changeIndex(1);
        } else {
            selectOption();
        }
        return true;
    }
}

class StartDelegate extends WatchUi.BehaviorDelegate {
    private var view as StartView;
    function initialize(view as StartView) {
        BehaviorDelegate.initialize();
        me.view = view;
    }
    function onSelect() as Boolean {
        view.selectOption();
        return true;
    }
    function onTap(evt as ClickEvent) as Boolean {
        var coords = evt.getCoordinates();
        return view.onTap(coords[0], coords[1]);
    }
    function onSwipe(evt as SwipeEvent) as Boolean {
        var dir = evt.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            view.changeIndex(1);
            return true;
        } else if (dir == WatchUi.SWIPE_DOWN) {
            view.changeIndex(-1);
            return true;
        }
        return false;
    }
}

// --------------------------------------------------

class HITStopwatchApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }
    function onStart(state as Dictionary?) as Void {}
    function onStop(state as Dictionary?) as Void {}
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var start = new StartView();
        return [ start, new StartDelegate(start) ];
    }
}

function getApp() as HITStopwatchApp {
    return Application.getApp() as HITStopwatchApp;
}
