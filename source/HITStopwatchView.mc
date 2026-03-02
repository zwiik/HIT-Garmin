import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.System;
import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Attention;
import Toybox.FitContributor;

class HITStopwatchView extends WatchUi.View {
    private var timerCount = 12;
    private var currentIndex = 0;
    private var timerRunning = false;
    private var startMillis = 0; 
    private var pauseStartMillis = 0;
    private var activitySeconds = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] as Array<Number>;
    private var activityAlerted = [false, false, false, false, false, false, false, false, false, false, false, false] as Array<Boolean>;
    
    // Fit Contributor fields
    private var _machineField = null;
    private var _tulField = null;

    // UI layout constants
    private var screenWidth = 0;
    private var screenHeight = 0;
    private var wheelY = 0;
    private var timerY = 0;
    
    // Drag state
    private var dragging = false;
    private var dragStartX = 0;
    private var recordingSession = null;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        WatchUi.requestUpdate();
    }

    function onLayout(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        wheelY = (screenHeight * 0.22).toNumber(); 
        timerY = (screenHeight * 0.58).toNumber(); 
    }

    function handleTap(x as Number, y as Number) as Boolean {
        if (y < screenHeight / 3) {
            if (x < screenWidth / 3) { changeIndex(-1); } 
            else if (x > (screenWidth * 2 / 3)) { changeIndex(1); }
            return true;
        }
        if (y >= screenHeight / 3) {
            toggleTimer();
            return true;
        }
        return false;
    }

    function handleDrag(x as Number, y as Number, type as Integer) as Boolean {
        if (type == WatchUi.DRAG_TYPE_START) {
            dragging = true;
            dragStartX = x;
            return true;
        } else if (type == 1 /* MOVE */) {
            if (dragging) {
                var diff = x - dragStartX;
                var absDiff = diff < 0 ? -diff : diff;
                if (absDiff > 50) {
                    changeIndex(diff > 0 ? -1 : 1);
                    dragStartX = x;
                }
                return true;
            }
        } else if (type == 2 /* END */) {
            dragging = false;
            return true;
        }
        return false;
    }

    private function changeIndex(delta as Integer) as Void {
        var now = Time.now().value().toNumber();
        if (timerRunning) {
            activitySeconds[currentIndex] += (now - startMillis);
            timerRunning = false;
            pauseStartMillis = now;
        }
        
        // Add a lap if we were recording to keep data segmented
        if (recordingSession != null && recordingSession.isRecording()) {
            // Save current machine name and TUL to the lap data before adding lap
            if (_machineField != null) { _machineField.setData(getCodeString(currentIndex)); }
            if (_tulField != null) { _tulField.setData(activitySeconds[currentIndex]); }
            recordingSession.addLap();
        }

        currentIndex = (currentIndex + delta + timerCount) % timerCount;
        WatchUi.requestUpdate();
    }

    function toggleTimer() as Void {
        var now = Time.now().value().toNumber();
        if (!timerRunning) {
            // Start recording session once for the entire app session
            if (recordingSession == null) {
                var params = {
                    :name => "HIT",
                    :sport => 4 as Toybox.Activity.Sport,
                    :subSport => 0 as Toybox.Activity.SubSport
                };
                recordingSession = ActivityRecording.createSession(params);
                
                if (recordingSession != null) {
                    _machineField = recordingSession.createField("machine", 0, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_LAP, :count => 16});
                    _tulField = recordingSession.createField("tul", 1, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_LAP});
                    recordingSession.start();
                }
            }
            
            startMillis = now;
            timerRunning = true;
        } else {
            activitySeconds[currentIndex] += (now - startMillis);
            timerRunning = false;
            pauseStartMillis = now;
        }
        WatchUi.requestUpdate();
    }

    function saveSession() as Void {
        if (recordingSession != null) {
            // Final data capture for the last lap
            if (_machineField != null) { _machineField.setData(getCodeString(currentIndex)); }
            if (_tulField != null) { _tulField.setData(activitySeconds[currentIndex]); }
            if (recordingSession.isRecording()) { recordingSession.stop(); }
            recordingSession.save();
            recordingSession = null;
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function discardSession() as Void {
        if (recordingSession != null) {
            if (recordingSession.isRecording()) { recordingSession.stop(); }
            recordingSession.discard();
            recordingSession = null;
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function resetCurrentActivity() as Void {
        activitySeconds[currentIndex] = 0;
        activityAlerted[currentIndex] = false;
        if (timerRunning) {
            startMillis = Time.now().value().toNumber();
        } else {
            pauseStartMillis = 0;
        }
        WatchUi.requestUpdate();
    }

    private function getCodeString(idx as Integer) as String {
        var code = Toybox.Application.Storage.getValue("code_" + idx);
        if (code == null || code.equals("  ")) { return (idx + 1).format("%d"); }
        var spaceIdx = code.find(" ");
        if (spaceIdx != null) {
            return code.substring(0, spaceIdx);
        }
        return code;
    }

    private function getMachineName(idx as Integer) as String {
        var code = Toybox.Application.Storage.getValue("code_" + idx);
        if (code == null || code.equals("  ")) { return "Exercise " + (idx + 1); }
        var spaceIdx = code.find(" ");
        if (spaceIdx != null) {
            return code.substring(spaceIdx + 1, code.length());
        }
        return code;
    }

    function onUpdate(dc as Dc) as Void {
        var now = Time.now().value().toNumber();
        var elapsed = activitySeconds[currentIndex];
        var restTime = 0;

        if (timerRunning) {
            elapsed += (now - startMillis);
        } else if (pauseStartMillis != 0) {
            restTime = (now - pauseStartMillis);
        }
        
        // Notification logic: 120s Short Haptic Alert (No beeps)
        if (elapsed >= 120 && !activityAlerted[currentIndex]) {
            activityAlerted[currentIndex] = true;
            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(100, 150)] as Array<VibeProfile>);
            }
        }

        // Determine Colors based on state
        var bgColor = Graphics.COLOR_BLACK;
        var mainTextColor = Graphics.COLOR_WHITE;
        var sideTextColor = Graphics.COLOR_LT_GRAY;
        var dividerColor = Graphics.COLOR_DK_GRAY;

        if (elapsed >= 120) {
            bgColor = Graphics.COLOR_GREEN;
            mainTextColor = Graphics.COLOR_BLACK;
            sideTextColor = Graphics.COLOR_DK_GRAY;
            dividerColor = Graphics.COLOR_BLACK;
        } else if (elapsed >= 90) {
            bgColor = Graphics.COLOR_YELLOW;
            mainTextColor = Graphics.COLOR_BLACK;
            sideTextColor = Graphics.COLOR_DK_GRAY;
            dividerColor = Graphics.COLOR_BLACK;
        } else if (!timerRunning) {
            sideTextColor = Graphics.COLOR_DK_GRAY;
            mainTextColor = Graphics.COLOR_LT_GRAY;
            dividerColor = Graphics.COLOR_DK_RED; // Pause indicator
        }

        dc.setColor(bgColor, bgColor);
        dc.clear();

        // --- DRAW TOP WHEEL ---
        var centerX = screenWidth / 2;
        var spacing = screenWidth / 3;
        
        var prevIdx = (currentIndex - 1 + timerCount) % timerCount;
        var nextIdx = (currentIndex + 1) % timerCount;

        dc.setPenWidth(2);
        dc.setColor(dividerColor, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, screenHeight/3, screenWidth, screenHeight/3);

        // Side indices (Smaller, Dimmer)
        dc.setColor(sideTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - spacing, wheelY, Graphics.FONT_MEDIUM, getCodeString(prevIdx), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + spacing, wheelY, Graphics.FONT_MEDIUM, getCodeString(nextIdx), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Current index (Large, Highlighted)
        dc.setColor(mainTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, wheelY, Graphics.FONT_NUMBER_MEDIUM, getCodeString(currentIndex), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // --- DRAW STOPWATCH ---
        dc.setColor(mainTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, timerY, Graphics.FONT_NUMBER_THAI_HOT, elapsed.format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Machine label
        dc.setColor(sideTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, timerY + 85, Graphics.FONT_TINY, getMachineName(currentIndex), Graphics.TEXT_JUSTIFY_CENTER);

        if (timerRunning) {
            WatchUi.requestUpdate();
        }
    }
}
