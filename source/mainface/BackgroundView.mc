using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Time.Gregorian as Date;

class BackgroundView extends Ui.Drawable {
   hidden var bgcir_font, bgcir_info;

   var radius;
   var mark_length = 10;

   function initialize(params) {
      Drawable.initialize(params);
      radius = center_x - ((10 * center_x) / 120).toNumber();
      if (center_x == 195) {
         mark_length = 20;
      }
   }

   function draw(dc) {
      var isFull = false;

      dc.setPenWidth(4);
      dc.setColor(gsecondary_color, Graphics.COLOR_TRANSPARENT);

      for (var i = 0; i < 6; i += 1) {
         var rad = (i.toFloat() / 6.0) * 2 * Math.PI;
         dc.drawLine(
            convertCoorX(rad, radius - mark_length / 2),
            convertCoorY(rad, radius - mark_length / 2),
            convertCoorX(rad, radius + mark_length / 2),
            convertCoorY(rad, radius + mark_length / 2)
         );
      }

      var ticks_style = Application.getApp().getProperty("ticks_style");
      var use_analog = Application.getApp().getProperty("use_analog");
      var digital_style = Application.getApp().getProperty("digital_style");
      var left_digital_info =
         Application.getApp().getProperty("left_digital_info");

      if (ticks_style == 0) {
         return;
      } else if (ticks_style == 1) {
         var excluded = 0;
         if (use_analog == 1) {
            excluded = -1;
         } else {
            if (digital_style == 1 || digital_style == 3) {
               excluded = -1;
            } else if (left_digital_info) {
               excluded = 2;
            }
         }

         dc.setPenWidth(2);
         dc.setColor(garc_color, Graphics.COLOR_TRANSPARENT);
         for (var i = 0; i < 6; i += 1) {
            if (i == excluded) {
               continue;
            }
            var rad = (i.toFloat() / 6.0) * 360;
            dc.drawArc(
               center_x,
               center_y,
               radius - 15,
               dc.ARC_COUNTER_CLOCKWISE,
               rad + 5,
               rad + 55
            );
         }
      } else if (ticks_style == 2 || ticks_style == 3 || ticks_style == 4 || ticks_style == 5) {
         dc.setColor(garc_color, Graphics.COLOR_TRANSPARENT);
         var bonus = 0;
         if (center_x == 130) {
            bonus = 2;
         } else if (center_x == 140) {
            bonus = 3;
         } else if (center_x == 109) {
            bonus = -2;
         } else if (center_x == 195) {
            bonus = 8;
         }

         for (var i = 0; i < 60; i += 1) {
            if (skipTick(i, use_analog, digital_style, left_digital_info, ticks_style)) {
               continue;
            }

            var rad = (i.toFloat() / (5 * 12.0)) * 2 * Math.PI - 0.5 * Math.PI;
            if (i % 5 == 0) {
               dc.setPenWidth(3);
            } else {
               dc.setPenWidth(1);
            }

            dc.drawLine(
               convertCoorX(rad, radius - 20 - bonus),
               convertCoorY(rad, radius - 20 - bonus),
               convertCoorX(rad, radius - 13),
               convertCoorY(rad, radius - 13)
            );
         }
      }
   }

   function skipTick(tick_number, use_analog, digital_style, left_digital_info, ticks_style) {
      var skip = false;
      // Not analog, and using big or xbig digital style
      // Skip ticks for digital info on left or right
      if (use_analog != 1 && (digital_style == 0 || digital_style == 2)) {
         if (left_digital_info) {
            if (tick_number > 45 && tick_number < 55) {
               skip = true;
            }
         } else {
            if (tick_number > 5 && tick_number < 15) {
               skip = true;
            }
         }
      }
      // Skip ticks for top graph number
      if (ticks_style == 3 || ticks_style == 5) {
         if (tick_number > 58 || tick_number < 2) {
            skip = true;
         }
      }
      // Skip ticks for bottom graph number
      if (ticks_style == 4 || ticks_style == 5) {
         if (tick_number > 28 && tick_number < 32) {
            skip = true;
         }
      }
      return skip;
   }
}
