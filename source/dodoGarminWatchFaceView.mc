using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.Activity;
using Toybox.ActivityMonitor;

class dodoGarminWatchFaceView extends WatchUi.WatchFace {

  // the x coordinate for the center
  var center_x;
  // the y coordinate for the center
  var center_y;
  var width;
  var height;
  var vpixel; // minimal virtual resolution

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

  // @func  : drawHourHand
  // @param : (DrawContext) dc; (int) angle;
  // @ret   : (Array) arrow
  // @desc  : Draw a watch hand (polygon)
  function drawHourHand(dc, angle) {
    //
    var HOUMIN_HAND_WIDTH = 30 * vpixel; // (int) Width of the hour and the minute watch hands
    var ARROW_HEIGHT = 30 * vpixel; // (int) Arrow height of the hour and minute watch hands
    var handLength = 80; //base
    // What I want to draw:
    //    _
    //   / \
    //  //^\\    ARROW_HEIGHT
    // //___\\
    //--------------------
    // |     |
    // |     |   handLength
    // |     |
    //-------------------- center
    // |     |
    // |     |   TAIL_LENGTH
    // +-----+
    //  HOUMIN_HAND_WIDTH

    // Coordinates
    var arrow = [
      [-HOUMIN_HAND_WIDTH / 2, -handLength], //L base
      [-(vpixel), -handLength - ARROW_HEIGHT], //L top
      [vpixel, -handLength - ARROW_HEIGHT], //R top
      [HOUMIN_HAND_WIDTH / 2, -handLength] //R base
    ];
    var arrow2 = [
      [-HOUMIN_HAND_WIDTH * 0.25, -handLength], //L base
      [0, -handLength - (ARROW_HEIGHT) * 0.5], //top (sharp corner)
      // [0, -handLength-(ARROW_HEIGHT)*0.5],	// R top
      [HOUMIN_HAND_WIDTH * 0.25, -handLength] //R base
    ];

    // Transform the coordinates
    arrow = transCoords(arrow, angle);
    arrow2 = transCoords(arrow2, angle);

    // Draw hand
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.fillPolygon(arrow);

    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.fillPolygon(arrow2);

    //return arrow;
  }
  // @func  : drawMinHand
  // @param : (DrawContext) dc; (int) angle;
  // @ret   : (Array) arrow
  // @desc  : Draw a watch hand (polygon)
  function drawMinHand(dc, angle) {
    //
    var HOUMIN_HAND_WIDTH = 20 * vpixel; // (int) Width of the hour and the minute watch hands
    var ARROW_HEIGHT = 35 * vpixel; // (int) Arrow height of the hour and minute watch hands
    var handLength = 80; //base
    // What I want to draw:
    //    _
    //   / \
    //  //^\\    ARROW_HEIGHT
    // //___\\
    //--------------------
    // |     |
    // |     |   handLength
    // |     |
    //-------------------- center
    // |     |
    // |     |   TAIL_LENGTH
    // +-----+
    //  HOUMIN_HAND_WIDTH

    // Coordinates
    var arrow = [
      [-HOUMIN_HAND_WIDTH / 2, -handLength], //L base
      [-(vpixel), -handLength - ARROW_HEIGHT], //L top
      [vpixel, -handLength - ARROW_HEIGHT], //R top
      [HOUMIN_HAND_WIDTH / 2, -handLength] //R base
    ];
    var arrow2 = [
      [-HOUMIN_HAND_WIDTH * 0.25, -handLength], //L base
      [0, -handLength - (ARROW_HEIGHT) * 0.5], //top (sharp corner)
      // [0, -handLength-(ARROW_HEIGHT)*0.5],	// R top
      [HOUMIN_HAND_WIDTH * 0.25, -handLength] //R base
    ];

    // Transform the coordinates
    arrow = transCoords(arrow, angle);
    arrow2 = transCoords(arrow2, angle);

    // Draw hand
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.fillPolygon(arrow);

    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.fillPolygon(arrow2);

    //return arrow;
  }

  // Draw the hash mark symbols on the watch-------------------------------------------------------

  function drawHashMarks5Minutes(dc) {
    //thick 5-Minutes marks
    var i;
    var alpha, r1, r2, marks, thicknes;

    //dc.setColor(App.getApp().getProperty("HashmarksColor"), Gfx.COLOR_TRANSPARENT);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    for (var i = 0; i < 12; i++) {
     alpha = (Math.PI / 6) * i;

      //r1 = width / 2 - 12; //inside
      r1 = (height * 0.45);
      //r2 = width / 2 - 2; //outside
      r2 = (height * 0.492);
      thicknes = 0.007;

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
    //var width = dc.getWidth();
    //var height = dc.getHeight();
    var x1 = xCenter + (Math.sin(angle) * r1);
    var y1 = yCenter - (Math.cos(angle) * r1);
    var x2 = xCenter + (Math.sin(angle) * r2);
    var y2 = yCenter - (Math.cos(angle) * r2);
    dc.setColor(color, Graphics.COLOR_BLACK);
    //dc.setPenWidth(4);
    dc.drawLine(x1, y1, x2, y2);
  }

  function drawAngleLine(dc, angle, r1, r2, color) {
    var width = dc.getWidth();
    var height = dc.getHeight();
    drawNonCenterAngleLine(dc, (width / 2), (height / 2), angle, r1, r2, color);
  }

  function drawClockHand(dc, angle, r, handWidth, color) {
    var semiHandWidth = (handWidth - (handWidth % 2)) / 2;
    var xCenter = dc.getWidth() / 2;
    var yCenter = dc.getHeight() / 2;

    drawNonCenterClockHand(dc, xCenter, yCenter, angle, r, handWidth, color);
  }

  function drawNonCenterClockHand(dc, xCenter, yCenter, angle, r, handWidth, color) {
    var semiHandWidth = (handWidth - (handWidth % 2)) / 2;

    var coords = new [4];

    // Координаты 1-й точки у гвоздика [0]
    var x0 = xCenter + (Math.cos(angle) * semiHandWidth);
    var y0 = yCenter + (Math.sin(angle) * semiHandWidth);
    coords[0] = [x0, y0];

    // Координаты вершины [1]
    var x1 = xCenter + (Math.sin(angle) * r);
    var y1 = yCenter - (Math.cos(angle) * r);
    coords[1] = [x1, y1];

    // Координаты 2-й точки у гвоздика [2]
    var x2 = xCenter - (Math.cos(angle) * semiHandWidth);
    var y2 = yCenter - (Math.sin(angle) * semiHandWidth);
    coords[2] = [x2, y2];

    // Координаты хвостика
    var x3 = xCenter - (Math.sin(angle) * r * 0.1);
    var y3 = yCenter + (Math.cos(angle) * r * 0.1);
    coords[3] = [x3, y3];

    dc.setColor(color, Graphics.COLOR_BLACK);
    dc.fillPolygon(coords);
  }

  function drawExtraClockFace(dc, x, y, r, color) {
    dc.setColor(color, Graphics.COLOR_BLACK);
    dc.drawCircle(x, y, r);
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
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      dc.drawText(x, y, Graphics.FONT_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER);
    }
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


  // Load your resources here
  function onLayout(dc) {
    setLayout(Rez.Layouts.WatchFace(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {}

  // Update the view
  function onUpdate(dc) {
    var clockTime = System.getClockTime();
    var day = clockTime.hour;
    var hour = clockTime.hour;
    var min = clockTime.min;
    var sec = clockTime.sec;

    width = dc.getWidth();
    height = dc.getHeight();

    center_x = (width / 2)-1;
    center_y = (height / 2)-1;
    vpixel = Math.round(width / 240); //virtual resolution 1 pixel

    // Fill the background with black
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.fillRectangle(0, 0, width, height);

    // Draw serifs
    for (var i = 0; i < 120; i++) {
      var angle = (Math.PI / 60) * i;
      var r1 = center_x;
      var r2 = r1 * 0.89;
      	if(i > 90) {
	  		drawAngleLine(dc, angle, r1, r2, Graphics.COLOR_RED);
		} else {
      		drawAngleLine(dc, angle, r1, r2, Graphics.COLOR_WHITE);
		}
	}

    drawHashMarks5Minutes(dc);


    dc.setAntiAlias(true); //draw antialiassed graphics

    dc.setPenWidth(4);
    dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_BLACK);
    dc.drawCircle(center_x, center_y, (height / 2)-1);  //outline circle

    dc.setPenWidth(2);
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
    dc.drawArc(center_x, center_y, (height * 0.485), Graphics.ARC_COUNTER_CLOCKWISE, 91, 180); //redline arc

	dc.setPenWidth(2);
	drawMyCircle(dc, center_x, center_y, (width * 0.36)+1, 0x22AAFF);
	drawMyCircle(dc, center_x, center_y, (width * 0.36)+2, 0x22AAFF);
	drawMyCircle(dc, center_x, center_y, (width * 0.36)+3, 0x00AAFF);
	drawMyCircle(dc, center_x, center_y, (width * 0.36)+4, 0x0066FF);
	drawMyCircle(dc, center_x, center_y, (width * 0.36)+5, 0x0066FF);
	drawMyCircle(dc, center_x, center_y, (width * 0.36)+6, 0x0000FF);
	drawMyCircle(dc, center_x, center_y, (width * 0.36)+6, 0x000066);

	dc.setPenWidth(1);

    // Write number marks
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(center_x, (height * 0.03), Graphics.FONT_SYSTEM_XTINY, "12", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText((width * 0.9), (height * 0.44), Graphics.FONT_SYSTEM_XTINY, "3", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText((width * 0.09), (height * 0.44), Graphics.FONT_SYSTEM_XTINY, "9", Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(center_x, (height * 0.85), Graphics.FONT_SYSTEM_XTINY, "6", Graphics.TEXT_JUSTIFY_CENTER);

    // How to draw an hour hand
    var hour12 = hour % 12 + (min / 60.0);
    var hourAngle = (Math.PI / 6) * hour12;
    //drawClockHand(dc, hourAngle, (width / 2) * 0.6, 15, Graphics.COLOR_WHITE);
    drawHourHand(dc, hourAngle);
    //drawAngleLine(dc, hourAngle, 0, (width / 2) * 0.5, Graphics.COLOR_WHITE);

    // How to draw the minute hand
    var minAngle = (Math.PI / 30) * min;
    //drawClockHand(dc, minAngle, (width / 2) * 0.9, 9, Graphics.COLOR_LT_GRAY);
    drawMinHand(dc, minAngle);

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.fillCircle(center_x, center_y, width * 0.36);

    // How to draw a second dial
    //drawExtraClockFace(dc, (width * .5), (height * .75), (width * .15), Graphics.COLOR_DK_GRAY);

    // Draw a cell with a date
    drawDateBox(dc, center_x, (height * 0.73));

    // How to draw the second hand
    //     var secAngle = (Math.PI / 30) * sec;
    //     drawNonCenterClockHand(dc, (width * .5), (height * .75), secAngle, (width * .15), 5, Graphics.COLOR_RED);

    // How to draw a heart pulse
    drawHeartRate(dc, (width * .35), (height * .25));

    // Draw the battery level
    drawBatteryLevel(dc, (width * .65), (height * .25));

    drawSteps(dc, center_x, (height * .35));

    // Draw a carnation in the center
    //dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    //dc.fillCircle(width / 2, height / 2, 3);

    //        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    //        dc.fillCircle((width * .5), (height * .75), 1);
	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
	var timeString = Lang.format("$1$:$2$", [hour, min.format("%02d")]);
	dc.drawText(center_x, (height * .48), Graphics.FONT_SYSTEM_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER);

	dc.drawLine((width * 0.20), (height * 0.45), (width * 0.8), (height * 0.45));

	dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
	var titleString = "dodo";
	dc.drawText(center_x, (height * .15), Graphics.FONT_XTINY, titleString, Graphics.TEXT_JUSTIFY_CENTER);


    //drawHouMinHand(dc, 120);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {}

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {}

}