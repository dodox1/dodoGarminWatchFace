using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Application;

class dodoGarminWatchFaceView extends WatchUi.WatchFace {

  // the x coordinate for the center
  hidden var center_x;
  // the y coordinate for the center
  hidden var center_y;
  hidden var width;
  hidden var height;
  hidden var vpixel; // minimal virtual resolution
  hidden var heartRate;
  hidden var heartRateTypeR;
  var save_min;


  function initialize() {
    WatchFace.initialize();
  }

  // @func  : transCoords
  // @param : (Array) coords; (int) angle
  // @ret   : (Array) coords
  // @desc  : Update the coordinates depending on an angle and the center point
  function transCoords(coords, angle) {

    var cos = Math.cos(angle);
    var sin = Math.sin(angle);

    for (var i = 0; i < coords.size(); i++) {
      var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
      var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

      coords[i] = [center_x + x, center_y + y];
    }

    return coords;
  }

  function drawHand(dc, angle, hand_width, arrow_height, hand_lenght) {
    //
    // What I want to draw:
    //    _
    //   / \
    //  //^\\    arrow_height
    // //___\\
    // |     |
    // |     |   handLength
    // |     |
    // +-----+
    //  hand_width

    // Coordinates
    var arrow = [
      [-hand_width / 2, -hand_lenght], //L base
      [-(vpixel), -hand_lenght - arrow_height], //L top
      [vpixel, -hand_lenght - arrow_height], //R top
      [hand_width / 2, -hand_lenght] //R base
    ];
    var arrow2 = [
      [-hand_width * 0.25, -hand_lenght], //L base
      [0, -hand_lenght - (arrow_height) * 0.5], //top (sharp corner)
      [hand_width * 0.25, -hand_lenght] //R base
    ];

    // Transform the coordinates
    arrow = transCoords(arrow, angle);
    arrow2 = transCoords(arrow2, angle);

    // Draw hand
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.fillPolygon(arrow);

    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.fillPolygon(arrow2);

  }

  function drawHashMarks(dc) {
    //thick 5-Minutes marks
    var i;
    var alpha, r1, r2, marks, thicknes, angle;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    // Draw serifs
    for (i = 0; i < 120; i++) {
      angle = (Math.PI / 60) * i;
      r1 = center_x;
      //r1 = center_x-4;
      r2 = r1 * 0.89;
      	if(i > 90) {
	  		drawAngleLine(dc, angle, r1, r2, Graphics.COLOR_RED);
		} else {
      		drawAngleLine(dc, angle, r1, r2, Graphics.COLOR_WHITE);
		}
	}

	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    for (i = 0; i < 12; i++) {
	  alpha = (Math.PI / 6) * i;
      //r1 = (height * 0.44); //inside
      //if (i == 0 or i == 3 or i == 6 or i == 9 ) {
       r1 = (height * 0.445); //inside - smaller
      //}
      r2 = (height * 0.492); //outside
     // r2 = center_x-4; //outside
     //r1 = r2 * 0.89;
      thicknes = 0.01;

      marks = [
        [center_x + r1 * Math.sin(alpha - thicknes), center_y - r1 * Math.cos(alpha - thicknes)],
        [center_x + r2 * Math.sin(alpha - thicknes), center_y - r2 * Math.cos(alpha - thicknes)],
        [center_x + r2 * Math.sin(alpha + thicknes), center_y - r2 * Math.cos(alpha + thicknes)],
        [center_x + r1 * Math.sin(alpha + thicknes), center_y - r1 * Math.cos(alpha + thicknes)]
      ];

		if(i == 9) {
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
		}
      dc.fillPolygon(marks);
    }

  }

  function drawNonCenterAngleLine(dc, xCenter, yCenter, angle, r1, r2, color) {
    var x1 = xCenter + (Math.sin(angle) * r1);
    var y1 = yCenter - (Math.cos(angle) * r1);
    var x2 = xCenter + (Math.sin(angle) * r2);
    var y2 = yCenter - (Math.cos(angle) * r2);
    dc.setColor(color, Graphics.COLOR_BLACK);
    dc.drawLine(x1, y1, x2, y2);
  }

  function drawAngleLine(dc, angle, r1, r2, color) {
    drawNonCenterAngleLine(dc, center_x, center_y, angle, r1, r2, color);
  }


  function drawDateBox(dc, x, y) {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.fillRoundedRectangle(x - 15, y, 30, 26, 7);

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.drawRoundedRectangle(x - 15, y, 30, 26, 7);

    var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    var dateStr = Lang.format("$1$", [info.day]);

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
  }

  function drawHeartRate(dc, x, y) {
    var value = Activity.getActivityInfo().currentHeartRate;

    if (value != null) {
      //dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      dc.setColor(0xFF0055, Graphics.COLOR_BLACK);
      dc.drawText(x, y, Graphics.FONT_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER);
    }
   // return value;
  }

  function drawBatteryLevel(dc, x, y) {
    var stats = System.getSystemStats();
    var charging = stats.charging;
    var batteryLevel = stats.battery;
    var batteryText = "N/A";

    if (batteryLevel != null) {
      var batteryValue = batteryLevel.toNumber();
      batteryText = batteryValue + "%";
      var color = Graphics.COLOR_GREEN;
      if (batteryValue < 50) {
        color = Graphics.COLOR_YELLOW;
      }
      if (batteryValue < 20) {
        color = Graphics.COLOR_RED;
      }
      if (charging == true) {
        color = Graphics.COLOR_WHITE;
      }
      dc.setColor(color, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, Graphics.FONT_MEDIUM, batteryText, Graphics.TEXT_JUSTIFY_CENTER);
    }
  }

  function drawSteps(dc, x, y) {
  	var actsteps = ActivityMonitor.getInfo().steps;

    if (actsteps != null) {
      var stepsStr = Lang.format("$1$", [actsteps]);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, Graphics.FONT_TINY, stepsStr, Graphics.TEXT_JUSTIFY_CENTER);
    }
  }

  function drawMyCircle(dc, x, y, r, color) {
      dc.setColor(color, Graphics.COLOR_TRANSPARENT);
      dc.drawCircle(x, y, r);
  }

  //===================================================================================
  // Load your resources here
  function onLayout(dc) {
    setLayout(Rez.Layouts.WatchFace(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
  	//save_min = null; //force redraw
  	//WatchUi.requestUpdate();
  }

  // Update the view
  function onUpdate(dc) {
  //System.println("onUpdate()");
    var clockTime = System.getClockTime();
    var day = clockTime.hour;
    var hour = clockTime.hour;
    var min = clockTime.min;
    var sec = clockTime.sec;
    var HR_threshold = (Application.getApp().getProperty("HR_threshold"));
    var Logo = (Application.getApp().getProperty("Logo"));

    width = dc.getWidth();
    height = dc.getHeight();

    center_x = (width / 2)-1;
    center_y = (height / 2)-1;
    //vpixel = Math.round(width / 240); //virtual resolution 1 pixel
    vpixel = ((width / 2.40)+5).toNumber().toFloat()/100; //

	if ( save_min != min ) { //one minute update =======================================================
	//System.println("onUpdate()1min");
	//save_min = min; //comment out to disable 1minute update saving
    // Fill the background with black
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.fillRectangle(0, 0, width, height);

	//Draw serifs
    drawHashMarks(dc);

    dc.setPenWidth(4);
    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_BLACK);
    dc.drawCircle(center_x, center_y, (height / 2)-1);  //outline circle

    dc.setPenWidth(3);
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
//    dc.setColor(0xFF0000, Graphics.COLOR_BLACK);
    dc.drawArc(center_x, center_y, (height * 0.482), Graphics.ARC_COUNTER_CLOCKWISE, 91, 180); //redline arc
	//Draw background
	dc.setPenWidth(2);
	var center_width =  width * 0.35; //center ring radius
	heartRate = Activity.getActivityInfo().currentHeartRate;
	if ( heartRate == null ) { heartRate=0;  }
	if ( heartRate < HR_threshold ) {
		drawMyCircle(dc, center_x, center_y, center_width+1, 0x00AAFF); //blue
		drawMyCircle(dc, center_x, center_y, center_width+2, 0x0055FF);
		drawMyCircle(dc, center_x, center_y, center_width+3, 0x0055FF);
		drawMyCircle(dc, center_x, center_y, center_width+4, 0x0055FF);
		drawMyCircle(dc, center_x, center_y, center_width+5, 0x0000FF);
		drawMyCircle(dc, center_x, center_y, center_width+6, 0x0000FF);
		drawMyCircle(dc, center_x, center_y, center_width+7, 0x0000AA);
		drawMyCircle(dc, center_x, center_y, center_width+8, 0x0000AA);
		drawMyCircle(dc, center_x, center_y, center_width+9, 0x000055);
	} else {
		drawMyCircle(dc, center_x, center_y, center_width+1, 0xFFAA00); //typeR
		drawMyCircle(dc, center_x, center_y, center_width+2, 0xFF5500);
		drawMyCircle(dc, center_x, center_y, center_width+3, 0xFF5500);
		drawMyCircle(dc, center_x, center_y, center_width+4, 0xFF0000);
		drawMyCircle(dc, center_x, center_y, center_width+5, 0xFF0000);
		drawMyCircle(dc, center_x, center_y, center_width+6, 0xAA0000);
		drawMyCircle(dc, center_x, center_y, center_width+7, 0xAA0000);
		drawMyCircle(dc, center_x, center_y, center_width+8, 0x550000);
		drawMyCircle(dc, center_x, center_y, center_width+9, 0x550000);
	}
	dc.setPenWidth(1);

	if ( dc has :setAntiAlias ) {
		dc.setAntiAlias(true); //draw antialiassed graphics
	}

    // Write number marks
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(center_x, (height * 0.03), Graphics.FONT_SYSTEM_TINY, "12", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText((width * 0.9), (height * 0.44), Graphics.FONT_SYSTEM_TINY, "3", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText((width * 0.09), (height * 0.44), Graphics.FONT_SYSTEM_TINY, "9", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(center_x, (height * 0.84), Graphics.FONT_SYSTEM_TINY, "6", Graphics.TEXT_JUSTIFY_CENTER);

    // Draw an hour hand
    var hour12 = hour % 12 + (min / 60.0);
    var hourAngle = (Math.PI / 6) * hour12;

    drawHand(dc, hourAngle, height* 0.123, height* 0.113, height* 0.33); //hour hand

    // Draw the minute hand
    var minAngle = (Math.PI / 30) * min;

	drawHand(dc, minAngle, height* 0.08, height* 0.15, height* 0.33); //minute hand

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.fillCircle(center_x, center_y, center_width); //clean surface in the center

    // Draw a cell with a date
    drawDateBox(dc, center_x, (height * 0.73));

    // Draw the battery level
    drawBatteryLevel(dc, (width * .65), (height * .25));

	// Draw steps
    drawSteps(dc, center_x, (height * .35));

	// Draw line
	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

	// Draw my logo
	dc.drawLine((width * 0.20), (height * 0.45), (width * 0.8), (height * 0.45));
	//var titleString = "dodo";
	dc.drawText(center_x, (height * .15), Graphics.FONT_XTINY, Logo, Graphics.TEXT_JUSTIFY_CENTER);

	} //one minute update =============================================================================
	//System.println("onUpdate()1sec");

    // Draw HR
    drawHeartRate(dc, (width * .35), (height * .25));

	// Draw BT link state
	var deviceSettings = System.getDeviceSettings();
	if (deviceSettings.phoneConnected) {
		dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle((width * 0.6), (height * 0.78), vpixel*4 );
	} else {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle((width * 0.6), (height * 0.78), vpixel*4 );
	}


	// Draw digital time
	var timeString = Lang.format("$1$:$2$", [hour, min.format("%02d")]);

//	var view = View.findDrawableById("TimeLabel");
//	view.setText(timeString);
//	View.onUpdate(dc);
	//use24hclock = System.getDeviceSettings().is24Hour;
	//var fy = dc.getFontHeight(Graphics.FONT_NUMBER_HOT);
	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	//var mySettings = System.getDeviceSettings();
	//FONT_NUMBER_MEDIUM = 6
	//FONT_NUMBER_HOT
	if ( height <= 240 ) {
	var fy = dc.getFontHeight(Graphics.FONT_SYSTEM_NUMBER_HOT);
	dc.drawText(center_x, (height * .7)-fy, Graphics.FONT_SYSTEM_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER);
	} else {
	var fy = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
	dc.drawText(center_x, (height * .7)-fy, Graphics.FONT_NUMBER_MEDIUM, timeString, Graphics.TEXT_JUSTIFY_CENTER);
	}

  }

  function onPartialUpdate( dc ) {
	//onUpdate(dc);
  }



  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {
  	//save_min = null; //force redraw
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
  	//save_min = null; //force redraw
  	//WatchUi.requestUpdate();
  }


  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
  	//WatchUi.requestUpdate();
  }


}
