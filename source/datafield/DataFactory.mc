using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.SensorHistory as SensorHistory;

using Toybox.UserProfile;
using Toybox.Time;
using Toybox.Time.Gregorian as Date;

enum /* FIELD_TYPES */ {
	FIELD_TYPE_HEART_RATE = 0,
	FIELD_TYPE_BATTERY,
	FIELD_TYPE_CALORIES,
	FIELD_TYPE_DISTANCE,
	FIELD_TYPE_MOVE,
	FIELD_TYPE_STEP,
	FIELD_TYPE_ACTIVE,
	
	FIELD_TYPE_DATE,
	FIELD_TYPE_TIME,
	FIELD_TYPE_EMPTY,
	
	FIELD_TYPE_NOTIFICATIONS = 10,
	FIELD_TYPE_ALARMS,
	FIELD_TYPE_ALTITUDE,
	FIELD_TYPE_TEMPERATURE,
	FIELD_TYPE_SUNRISE_SUNSET,
	FIELD_TYPE_FLOOR,
	FIELD_TYPE_GROUP_NOTI,
	FIELD_TYPE_DISTANCE_WEEK,
	FIELD_TYPE_BAROMETER,
	FIELD_TYPE_TIME_SECONDARY,
	FIELD_TYPE_PHONE_STATUS,
}

function buildFieldObject(type) {
	if (type==FIELD_TYPE_HEART_RATE) {
		return new HRField(FIELD_TYPE_HEART_RATE);
	} else if (type==FIELD_TYPE_BATTERY) {
		return new BatteryField(FIELD_TYPE_BATTERY);
	} else if (type==FIELD_TYPE_CALORIES) {
		return new CaloField(FIELD_TYPE_CALORIES);
	} else if (type==FIELD_TYPE_DISTANCE) {
		return new DistanceField(FIELD_TYPE_DISTANCE);
	} else if (type==FIELD_TYPE_MOVE) {
		return new MoveField(FIELD_TYPE_MOVE);
	} else if (type==FIELD_TYPE_STEP) {
		return new StepField(FIELD_TYPE_STEP);
	} else if (type==FIELD_TYPE_ACTIVE) {
		return new ActiveField(FIELD_TYPE_ACTIVE);
	} else if (type==FIELD_TYPE_DATE) {
		return new DateField(FIELD_TYPE_DATE);
	} else if (type==FIELD_TYPE_TIME) {
		return new TimeField(FIELD_TYPE_TIME);
	} else if (type==FIELD_TYPE_EMPTY) {
		return new EmptyDataField(FIELD_TYPE_EMPTY);
	} else if (type==FIELD_TYPE_NOTIFICATIONS) {
		return new NotifyField(FIELD_TYPE_NOTIFICATIONS);
	} else if (type==FIELD_TYPE_ALARMS) {
		return new AlarmField(FIELD_TYPE_ALARMS);
	} else if (type==FIELD_TYPE_ALTITUDE) {
		return new AltitudeField(FIELD_TYPE_ALTITUDE);
	} else if (type==FIELD_TYPE_TEMPERATURE) {
		return new TemparatureField(FIELD_TYPE_TEMPERATURE);
	} else if (type==FIELD_TYPE_SUNRISE_SUNSET) {
		return new SunField(FIELD_TYPE_SUNRISE_SUNSET);
	} else if (type==FIELD_TYPE_FLOOR) {
		return new FloorField(FIELD_TYPE_FLOOR);
	} else if (type==FIELD_TYPE_GROUP_NOTI) {
		return new GroupNotiField(FIELD_TYPE_GROUP_NOTI);
	} else if (type==FIELD_TYPE_DISTANCE_WEEK) {
		return new WeekDistanceField(FIELD_TYPE_DISTANCE_WEEK);
	} else if (type==FIELD_TYPE_BAROMETER) {
		return new BarometerField(FIELD_TYPE_BAROMETER);
	} else if (type==FIELD_TYPE_TIME_SECONDARY) {
		return new TimeSecondaryField(FIELD_TYPE_TIME_SECONDARY);
	} else if (type==FIELD_TYPE_PHONE_STATUS) {
		return new PhoneField(FIELD_TYPE_PHONE_STATUS);
	}
	
	return new EmptyDataField(FIELD_TYPE_EMPTY);
}

class BaseDataField {
	
	function initialize(id) {
		_field_id = id;
	}

	private var _field_id;

	function field_id() {
		return _field_id;
	}

	function have_secondary() {
		return false;
	}

	function min_val() {
    	return 50.0;
	}
	
	function max_val() {
	    return 120.0;
	}
	
	function cur_val() {
		return min_val()+0.01;
	}
	
	function sec_val() {
		return min_val()+0.01;
	}
	
	function min_label(value) {
		return "min";
	}
	
	function max_label(value) {
		return "max";
	}
	
	function cur_label(value) {
		return "cur";
	}
	
	function sec_label(value) {
		return "sec";
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function need_draw() {
		return true;
	}
	
	function bar_data() {
		return false;
	}
}

class EmptyDataField {

	function initialize(id) {
		_field_id = id;
	}

	private var _field_id;

	function field_id() {
		return _field_id;
	}
	
	function need_draw() {
		return false;
	}
}

//////////////////////////
// time secondary stage //
//////////////////////////

class TimeSecondaryField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		var currentSettings = System.getDeviceSettings();
		var clockTime = Sys.getClockTime();     
		var to_utc_second = clockTime.timeZoneOffset;
		
		var target = App.getApp().getProperty("utc_timezone");
		var shift_val = App.getApp().getProperty("utc_shift") ? 0.5 : 0.0;
    	var secondary_zone_delta = (target+shift_val)*3600 - to_utc_second;
    	
 		var now = Time.now();
		var now_target_zone_delta = new Time.Duration(secondary_zone_delta);
		var now_target_zone = now.add(now_target_zone_delta);
		var target_zone = Date.info(now_target_zone, Time.FORMAT_SHORT);
		
//		System.print("UTC "+target+", ");
//		System.print(target_zone.hour);  // 2003
//		System.print(", ");
//		System.print(target_zone.min); // May
//		System.print(", ");
//		System.println(target_zone.sec);   // 16
    	        		
    	var hour = target_zone.hour;
    	var minute = target_zone.min;      		
    	var mark = "";
		if(!currentSettings.is24Hour) {
			if (hour>=12) {
				mark = "pm";
			} else {
				mark = "am";
			}
			hour = hour % 12;
        	hour = (hour == 0) ? 12 : hour;  
        }    
        return Lang.format("$1$:$2$ $3$",[hour, minute.format("%02d"), mark]);
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

//////////////////////////////
// end time secondary stage //
//////////////////////////////

////////////////
// baro stage //
////////////////

class BarometerField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 50.0;
	}
	
	function max_val() {
	    return 120.0;
	}
	
	function cur_val() {
		var presure_data = _retrieveBarometer();
		return presure_data;
	}
	
	function min_label(value) {
		return value.format("%d");
	}
	
	function max_label(value) {
		return value.format("%d");
	}
	
	function cur_label(value) {
		if (value == null) {
			return "BARO --";
		} else {
			var hector_pascal = value/100.0;
			return Lang.format("BARO $1$",[hector_pascal.format("%d")]);
		}
	}
	
	function min_pad() {
		return -2;
	}
	
	function max_pad() {
		return -2;
	}
	
	function cur_pad() {
		return 0;
	}
	
	// Create a method to get the SensorHistoryIterator object
	function _getIterator() {
	    // Check device for SensorHistory compatibility
	    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
	        return Toybox.SensorHistory.getPressureHistory({});
	    }
	    return null;
	}
	
	function _retrieveBarometer() {
		var iter = _getIterator();
		// Print out the next entry in the iterator
		if (iter != null) {
			var sample = iter.next();
			if ((sample != null) && (sample has :data)) {
				return sample.data;
			}
		}
		return null;
	}
	
}

////////////////////
// end baro stage //
////////////////////

/////////////////////////
// distance week stage //
/////////////////////////

class WeekDistanceField extends BaseDataField {

	var days;
	
	function initialize(id) {
		BaseDataField.initialize(id);
		days = {Date.DAY_MONDAY => "MON", 
				Date.DAY_TUESDAY => "TUE", 
				Date.DAY_WEDNESDAY => "WED", 
				Date.DAY_THURSDAY => "THU", 
				Date.DAY_FRIDAY => "FRI", 
				Date.DAY_SATURDAY => "SAT", 
				Date.DAY_SUNDAY => "SUN"};
	}

	function min_val() {
    	return 50.0;
	}
	
	function max_val() {
		var datas = _retriveWeekValues();
	    return datas[1];
	}
	
	function cur_val() {
		var datas = _retriveWeekValues();
		return datas[0];
	}
	
	function min_label(value) {
		return value.format("%d");
	}
	
	function max_label(value) {
		return value.format("%d");
	}
	
	function cur_label(value) {
		var datas = _retriveWeekValues();
		var total_distance = datas[0];
		
		var need_minimal = App.getApp().getProperty("minimal_data");
		var settings = Sys.getDeviceSettings();
		
		var value2 = total_distance;
		var kilo = value2/100000;
		
		var unit = "Km";
		if (settings.distanceUnits == System.UNIT_METRIC) {					
		} else {
			kilo *= 0.621371;
			unit = "Mi";
		}
		
		if (need_minimal) {
			return Lang.format("$1$ $2$",[kilo.format("%0.2f"), unit]);
		} else {
	    	var valKp = (kilo - kilo.toLong())*10.0;
	    	return Lang.format("DIS $1$.$2$$3$",[kilo.format("%d"), valKp.format("%d"), unit]);
    	}
	}
	
	function min_pad() {
		return -2;
	}
	
	function max_pad() {
		return -2;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function day_of_week(activity) {
		var moment = activity.startOfDay;
		var date = Date.info(moment, Time.FORMAT_SHORT);
		return date.day_of_week;
	}
	
	function today_of_week() {
		var now = Time.now();
		var date = Date.info(now, Time.FORMAT_SHORT);
		return date.day_of_week;
	}
	
	function _retriveWeekValues() {
		var settings = System.getDeviceSettings();
		var firstDayOfWeek = settings.firstDayOfWeek;
		
		var activities = [];
		var activityInfo = ActivityMonitor.getInfo();
		activities.add(activityInfo);
			
		if (today_of_week() != firstDayOfWeek) {
			if (ActivityMonitor has :getHistory) {
				var his = ActivityMonitor.getHistory();
				for (var i = 0; i < his.size(); i++ ) {
					var activity = his[i];
					activities.add(activity);
					if (day_of_week(activity)==firstDayOfWeek) {
						break;
					}
				}
			}
		}
		
		var total = 0.0;
		for (var i = 0; i<activities.size();i++) {
			total += activities[i].distance;
		}
		return [total, 10.0];
	}
	
	function bar_data() {
		return true;
	}
}

/////////////////////////////
// end distance week stage //
/////////////////////////////

////////////////////////
// phone status stage //
////////////////////////

class PhoneField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		if (settings.phoneConnected) {
			return "CON";
		} else {
			return "DIS";
		}
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

////////////////////////////
// end phone status stage //
////////////////////////////

//////////////////////
// group noti stage //
//////////////////////

class GroupNotiField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		var value = settings.alarmCount;
		var alarm_str = Lang.format("A$1$",[value.format("%d")]);
		value = settings.notificationCount;
		var noti_str = Lang.format("N$1$",[value.format("%d")]);
		
		if (settings.phoneConnected) {
			return Lang.format("$1$-$2$-C",[noti_str, alarm_str]);
		} else {
			return Lang.format("$1$-$2$-D",[noti_str, alarm_str]);
		}
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

//////////////////////////
// end group noti stage //
//////////////////////////

/////////////////
// floor stage //
/////////////////

class FloorField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
		var activityInfo = ActivityMonitor.getInfo();
		if (activityInfo has :floorsClimbedGoal) {
			return activityInfo.floorsClimbedGoal.toFloat();
		} else {
			return 1.0;
		}
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
		if (activityInfo has :floorsClimbed) {
			return activityInfo.floorsClimbed.toFloat();
		} else {
			return 0.0;
		}
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
    	return value.format("%d");
	}
	
	function cur_label(value) {
		if (value==null) {
			return "FLOOR --";
		}
	   	return Lang.format("FLOOR $1$",[value.format("%d")]);
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function bar_data() {
		return true;
	}
}

/////////////////////
// end floor stage //
/////////////////////

///////////////
// sun stage //
///////////////

class SunField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		if (gLocationLat != null) {
			var value = "";
			var nextSunEvent = 0;
			var isSunriseNext = false;
			var now = Date.info(Time.now(), Time.FORMAT_SHORT);
	
			// Convert to same format as sunTimes, for easier comparison. Add a minute, so that e.g. if sun rises at
			// 07:38:17, then 07:38 is already consided daytime (seconds not shown to user).
//			now = now.hour + ((now.min + 1) / 60.0);
			now = now.hour + ((now.min) / 60.0);
			//Sys.println(now);
	
			// Get today's sunrise/sunset times in current time zone.
			var sunTimes = getSunTimes(gLocationLat, gLocationLng, null, /* tomorrow */ false);
			//Sys.println(sunTimes);
	
			// If sunrise/sunset happens today.
			var sunriseSunsetToday = ((sunTimes[0] != null) && (sunTimes[1] != null));
			if (sunriseSunsetToday) {
	
				// Before sunrise today: today's sunrise is next.
				if (now < sunTimes[0]) {
					nextSunEvent = sunTimes[0];
					isSunriseNext = true;
	
				// After sunrise today, before sunset today: today's sunset is next.
				} else if (now < sunTimes[1]) {
					nextSunEvent = sunTimes[1];
	
				// After sunset today: tomorrow's sunrise (if any) is next.
				} else {
					sunTimes = getSunTimes(gLocationLat, gLocationLng, null, /* tomorrow */ true);
					nextSunEvent = sunTimes[0];
					isSunriseNext = true;
				}
			}
	
			// Sun never rises/sets today.
			if (!sunriseSunsetToday) {
				// Sun never rises: sunrise is next, but more than a day from now.
				if (sunTimes[0] == null) {
					isSunriseNext = true;
				}
				return "SUN --";
			// We have a sunrise/sunset time.
			} else {
				var need_minimal = App.getApp().getProperty("minimal_data");
				var hour = Math.floor(nextSunEvent).toLong() % 24;
				var min = Math.floor((nextSunEvent - Math.floor(nextSunEvent)) * 60); // Math.floor(fractional_part * 60)
				var ftime = getFormattedTime(hour, min);
//				var timestr = ftime[:hour] + ":" + ftime[:min] + ftime[:amPm]; 
				var timestr = ftime[:hour] + ":" + ftime[:min]; 
				
				var riseicon = isSunriseNext ? "RISE" : "SET";
				if (need_minimal) {
					riseicon = isSunriseNext ? "RI" : "SE";
				}
				return Lang.format("$1$ $2$", [riseicon, timestr]);
			}
	
		// Waiting for location.
		} else {
			return "SUN --";
		}
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	/**
	* With thanks to ruiokada. Adapted, then translated to Monkey C, from:
	* https://gist.github.com/ruiokada/b28076d4911820ddcbbc
	*
	* Calculates sunrise and sunset in local time given latitude, longitude, and tz.
	*
	* Equations taken from:
	* https://en.wikipedia.org/wiki/Julian_day#Converting_Julian_or_Gregorian_calendar_date_to_Julian_Day_Number
	* https://en.wikipedia.org/wiki/Sunrise_equation#Complete_calculation_on_Earth
	*
	* @method getSunTimes
	* @param {Float} lat Latitude of location (South is negative)
	* @param {Float} lng Longitude of location (West is negative)
	* @param {Integer || null} tz Timezone hour offset. e.g. Pacific/Los Angeles is -8 (Specify null for system timezone)
	* @param {Boolean} tomorrow Calculate tomorrow's sunrise and sunset, instead of today's.
	* @return {Array} Returns array of length 2 with sunrise and sunset as floats.
	*                 Returns array with [null, -1] if the sun never rises, and [-1, null] if the sun never sets.
	*/
	function getSunTimes(lat, lng, tz, tomorrow) {

		// Use double precision where possible, as floating point errors can affect result by minutes.
		lat = lat.toDouble();
		lng = lng.toDouble();

		var now = Time.now();
		if (tomorrow) {
			now = now.add(new Time.Duration(24 * 60 * 60));
		}
		var d = Date.info(Time.now(), Time.FORMAT_SHORT);
		var rad = Math.PI / 180.0d;
		var deg = 180.0d / Math.PI;
		
		// Calculate Julian date from Gregorian.
		var a = Math.floor((14 - d.month) / 12);
		var y = d.year + 4800 - a;
		var m = d.month + (12 * a) - 3;
		var jDate = d.day
			+ Math.floor(((153 * m) + 2) / 5)
			+ (365 * y)
			+ Math.floor(y / 4)
			- Math.floor(y / 100)
			+ Math.floor(y / 400)
			- 32045;

		// Number of days since Jan 1st, 2000 12:00.
		var n = jDate - 2451545.0d + 0.0008d;
		//Sys.println("n " + n);

		// Mean solar noon.
		var jStar = n - (lng / 360.0d);
		//Sys.println("jStar " + jStar);

		// Solar mean anomaly.
		var M = 357.5291d + (0.98560028d * jStar);
		var MFloor = Math.floor(M);
		var MFrac = M - MFloor;
		M = MFloor.toLong() % 360;
		M += MFrac;
		//Sys.println("M " + M);

		// Equation of the centre.
		var C = 1.9148d * Math.sin(M * rad)
			+ 0.02d * Math.sin(2 * M * rad)
			+ 0.0003d * Math.sin(3 * M * rad);
		//Sys.println("C " + C);

		// Ecliptic longitude.
		var lambda = (M + C + 180 + 102.9372d);
		var lambdaFloor = Math.floor(lambda);
		var lambdaFrac = lambda - lambdaFloor;
		lambda = lambdaFloor.toLong() % 360;
		lambda += lambdaFrac;
		//Sys.println("lambda " + lambda);

		// Solar transit.
		var jTransit = 2451545.5d + jStar
			+ 0.0053d * Math.sin(M * rad)
			- 0.0069d * Math.sin(2 * lambda * rad);
		//Sys.println("jTransit " + jTransit);

		// Declination of the sun.
		var delta = Math.asin(Math.sin(lambda * rad) * Math.sin(23.44d * rad));
		//Sys.println("delta " + delta);

		// Hour angle.
		var cosOmega = (Math.sin(-0.83d * rad) - Math.sin(lat * rad) * Math.sin(delta))
			/ (Math.cos(lat * rad) * Math.cos(delta));
		//Sys.println("cosOmega " + cosOmega);

		// Sun never rises.
		if (cosOmega > 1) {
			return [null, -1];
		}
		
		// Sun never sets.
		if (cosOmega < -1) {
			return [-1, null];
		}
		
		// Calculate times from omega.
		var omega = Math.acos(cosOmega) * deg;
		var jSet = jTransit + (omega / 360.0);
		var jRise = jTransit - (omega / 360.0);
		var deltaJSet = jSet - jDate;
		var deltaJRise = jRise - jDate;

		var tzOffset = (tz == null) ? (Sys.getClockTime().timeZoneOffset / 3600) : tz;
		return [
			/* localRise */ (deltaJRise * 24) + tzOffset,
			/* localSet */ (deltaJSet * 24) + tzOffset
		];
	}
	
	// Return a formatted time dictionary that respects is24Hour and HideHoursLeadingZero settings.
	// - hour: 0-23.
	// - min:  0-59.
	function getFormattedTime(hour, min) {
		var amPm = "";

		if (!Sys.getDeviceSettings().is24Hour) {

			// #6 Ensure noon is shown as PM.
			var isPm = (hour >= 12);
			if (isPm) {
				
				// But ensure noon is shown as 12, not 00.
				if (hour > 12) {
					hour = hour - 12;
				}
				amPm = "p";
			} else {
				
				// #27 Ensure midnight is shown as 12, not 00.
				if (hour == 0) {
					hour = 12;
				}
				amPm = "a";
			}
		}

		// #10 If in 12-hour mode with Hide Hours Leading Zero set, hide leading zero. Otherwise, show leading zero.
		// #69 Setting now applies to both 12- and 24-hour modes.
		hour = hour.format("%2d");

		return {
			:hour => hour,
			:min => min.format("%02d"),
			:amPm => amPm
		};
	}
}

///////////////////
// end sun stage //
///////////////////

///////////////////////
// temparature stage //
///////////////////////

class TemparatureField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		var value = 0;
		var settings = Sys.getDeviceSettings();
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
			var sample = SensorHistory.getTemperatureHistory(null).next();
			if ((sample != null) && (sample.data != null)) {
				var temperature = sample.data;
				if (settings.temperatureUnits == System.UNIT_STATUTE) {
					temperature = (temperature * (9.0 / 5)) + 32; // Convert to Farenheit: ensure floating point division.
				}
				value = temperature.format("%d") + "°";
				if (need_minimal) {
					return value;
				} else {
					return Lang.format("TEMP $1$",[value]);
				}
			} else {
				if (need_minimal) {
					return "--";
				} else {
					return "TEMP --";
				}
			}
		} else {
			if (need_minimal) {
					return "--";
				} else {
					return "TEMP --";
				}
		}
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

///////////////////////////
// end temparature stage //
///////////////////////////

////////////////////
// altitude stage //
////////////////////

class AltitudeField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		var value = 0;
		// #67 Try to retrieve altitude from current activity, before falling back on elevation history.
		// Note that Activity::Info.altitude is supported by CIQ 1.x, but elevation history only on select CIQ 2.x
		// devices.
		var settings = Sys.getDeviceSettings();
		var activityInfo = Activity.getActivityInfo();
		var altitude = activityInfo.altitude;
		if ((altitude == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
			var sample = SensorHistory.getElevationHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST })
				.next();
			if ((sample != null) && (sample.data != null)) {
				altitude = sample.data;
			}
		}
		if (altitude != null) {
			var unit = "";
			// Metres (no conversion necessary).
			if (settings.elevationUnits == System.UNIT_METRIC) {
				unit = "m";
			// Feet.
			} else {
				altitude *= /* FT_PER_M */ 3.28084;
				unit = "ft";
			}
	
			value = altitude.format("%d");
			value += unit;
			if (need_minimal) {
				return value;
			} else {
				var temp = Lang.format("ALTI $1$",[value]);
				if (temp.length() > 10) {
					return Lang.format("$1$",[value]);
				}
				return temp;
			}
		} else {
			if (need_minimal) {
				return "--";
			} else {
				return "ALTI --";
			}
		}
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

////////////////////////
// end altitude stage //
////////////////////////

/////////////////
// alarm stage //
/////////////////

class AlarmField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		var value = settings.alarmCount;
		return Lang.format("ALAR $1$",[value.format("%d")]);
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

/////////////////////
// end alarm stage //
/////////////////////

////////////////////////
// notification stage //
////////////////////////

class NotifyField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		var settings = Sys.getDeviceSettings();
		var value = settings.notificationCount;
		return Lang.format("NOTIF $1$",[value.format("%d")]);
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

////////////////////////////
// end notification stage //
////////////////////////////

////////////////
// time stage //
////////////////

class TimeField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		return getTimeString();
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function getTimeString() {
		var currentSettings = System.getDeviceSettings();
    	var clockTime = Sys.getClockTime();        		
    	var hour = clockTime.hour;
		var minute = clockTime.min;		
		var mark = "";
		if(!currentSettings.is24Hour) {
			if (hour>=12) {
				mark = "pm";
			} else {
				mark = "am";
			}
			hour = hour % 12;
        	hour = (hour == 0) ? 12 : hour;  
        }    
        return Lang.format("$1$:$2$ $3$",[hour, minute.format("%02d"), mark]);
    }
}

////////////////////
// end time stage //
////////////////////

////////////////
// date stage //
////////////////

class DateField extends BaseDataField {
	
	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function have_secondary() {
		return true;
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 1.0;
	}
	
	function cur_val() {
	    return 0.999;
	}
	
	function sec_val() {
		return 0.99;
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return "0";
	}
	
	function cur_label(value) {
		return Application.getApp().getFormatedDate();
//		var now = Time.now();
//		if (Application.getApp().getProperty("force_date_english")) {
//			var date = Date.info(now, Time.FORMAT_SHORT);
//			var day_of_weak = date.day_of_week;
//			return Lang.format("$1$ $2$",[days[day_of_weak], date.day.format("%d")]);
//		} else {
//			var date = Date.info(now, Time.FORMAT_LONG);
//			var day_of_weak = date.day_of_week;
//			return Lang.format("$1$ $2$",[day_of_weak.toUpper(), date.day.format("%d")]);
//		}
	}
	
	function sec_label(value) {
		var now = Time.now();
		var date = Date.info(now, Time.FORMAT_LONG);
		return date.day_of_week.toUpper();
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
}

////////////////////
// end date stage //
////////////////////

//////////////////
// active stage //
//////////////////

class ActiveField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
		var activityInfo = ActivityMonitor.getInfo();
	    return activityInfo.activeMinutesWeekGoal.toFloat();
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
	    return activityInfo.activeMinutesWeek.total.toFloat();
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		return value.format("%d");
	}
	
	function cur_label(value) {
		return Lang.format("ACT $1$",[value.format("%d")]);
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function bar_data() {
		return true;
	}
}

//////////////////////
// end active stage //
//////////////////////

////////////////////
// distance stage //
////////////////////

class DistanceField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 300000.0;
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
		var value = activityInfo.distance.toFloat();
//		var settings = Sys.getDeviceSettings();
//		if (settings.distanceUnits == System.UNIT_METRIC) {					
//		} else {
//			value *= 0.621371;
//		}
//		var maxx = max_val();
//		if (value>maxx) {
//			return maxx-0.01;
//		}
		return value;
	}
	
	function min_label(value) {
		return "00";
	}
	
	function max_label(value) {
		var valK = value/1000.0;
		valK = valK/100.0; // convert cm to km
    	var valKp = (valK - valK.toLong())*10.0;
    	return Lang.format("$1$,$2$K",[valK.format("%d"), valKp.format("%d")]);
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		var settings = Sys.getDeviceSettings();
//		var activityInfo = ActivityMonitor.getInfo();
		
		var value2 = value;
		var kilo = value2/100000;
		
		var unit = "Km";
		if (settings.distanceUnits == System.UNIT_METRIC) {					
		} else {
			kilo *= 0.621371;
			unit = "Mi";
		}
		
		if (need_minimal) {
			return Lang.format("$1$ $2$",[kilo.format("%0.2f"), unit]);
		} else {
	    	var valKp = (kilo - kilo.toLong())*10.0;
	    	return Lang.format("DIS $1$.$2$$3$",[kilo.format("%d"), valKp.format("%d"), unit]);
    	}
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function bar_data() {
		return true;
	}
}

////////////////////////
// end distance stage //
////////////////////////

////////////////////
// calories stage //
////////////////////

class CaloField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 3000.0;
	}
	
	function cur_val() {
		var activityInfo = ActivityMonitor.getInfo();
		return activityInfo.calories.toFloat();
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		var valK = value/1000.0;
    	var valKp = (valK - valK.toLong())*10.0;
    	return Lang.format("$1$,$2$K",[valK.format("%d"), valKp.format("%d")]);
	}
	
	function cur_label(value) {
		var activeCalories = active_calories(value);
		var need_minimal = App.getApp().getProperty("minimal_data");
		if (need_minimal) {
			return Lang.format("$1$-$2$",[value.format("%d"), activeCalories.format("%d")]);
		} else {
			var valK = value/1000.0;
	    	var valKp = (valK - valK.toLong())*100.0;
	    	return Lang.format("$1$.$2$K-$3$",[valK.format("%d"), valKp.format("%d"), activeCalories.format("%d")]);
    	}
	}
	
	function active_calories(value) {
		var now = Time.now();
		var date = Date.info(now, Time.FORMAT_SHORT);
		
		var profile = UserProfile.getProfile();
		var bonus = profile.gender == UserProfile.GENDER_MALE ? 5.0 : -161.0;
		var age = (date.year-profile.birthYear).toFloat();
		var weight = profile.weight.toFloat()/1000.0;
		var height = profile.height.toFloat();
//		var bmr = 0.01*weight + 6.25*height + 5.0*age + bonus; // method 1
		var bmr = -6.1*age + 7.6*height + 12.1*weight + 9.0; // method 2
		var current_segment = (date.hour*60.0+date.min).toFloat()/1440.0;
//		var nonActiveCalories = 1.604*bmr*current_segment; // method 1
		var nonActiveCalories = 1.003*bmr*current_segment; // method 2
		var activeCalories = value - nonActiveCalories;
		activeCalories = (activeCalories>0 ? activeCalories : 0).toNumber();
//		Sys.print("hour ");
//		Sys.print(date.hour);
//		Sys.print("min ");
//		Sys.print(date.min);
//		Sys.print("bonus ");
//		Sys.print(bonus);
//		Sys.print("age ");
//		Sys.print(age);
//		Sys.print("weight ");
//		Sys.print(weight);
//		Sys.print("bmr ");
//		Sys.print(bmr);
//		Sys.print("current_segment ");
//		Sys.print(current_segment);
//		Sys.print("nonActiveCalories ");
//		Sys.print(nonActiveCalories);
//		Sys.print("activeCalories ");
//		Sys.println(activeCalories);
		return activeCalories;
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function bar_data() {
		return true;
	}
}

////////////////////////
// end calories stage //
////////////////////////

////////////////
// move stage //
////////////////

class MoveField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return ActivityMonitor.MOVE_BAR_LEVEL_MIN;
	}
	
	function max_val() {
	    return ActivityMonitor.MOVE_BAR_LEVEL_MAX;
	}
	
	function cur_val() {
		var info = ActivityMonitor.getInfo();
		var currentBar = info.moveBarLevel.toFloat();
		return currentBar.toFloat();
	}
	
	function min_label(value) {
		return value.format("%d");
	}
	
	function max_label(value) {
		return Lang.format("$1$",[(value).format("%d")]);
	}
	
	function cur_label(value) {
    	return Lang.format("MOVE $1$",[value.format("%d")]);
	}
	
	function min_pad() {
		return -2;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function bar_data() {
		return true;
	}
}

////////////////////
// end move stage //
////////////////////

/////////////////
// steps stage //
/////////////////

class StepField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return ActivityMonitor.getInfo().stepGoal.toFloat();
	}
	
	function cur_val() {
		var currentStep = ActivityMonitor.getInfo().steps;
		return currentStep.toFloat();
	}
	
	function min_label(value) {
		return "0";
	}
	
	function max_label(value) {
		var valK = value/1000.0;
    	var valKp = (valK - valK.toLong())*10.0;
    	return Lang.format("$1$.$2$K",[valK.format("%d"), valKp.format("%d")]);
	}
	
	function cur_label(value) {
		var need_minimal = App.getApp().getProperty("minimal_data");
		var currentStep = value;
		if (need_minimal) {
			if (currentStep > 999) {
				return currentStep.format("%d");
			} else {
				return Lang.format("STEP $1$",[currentStep.format("%d")]);
			}
		} else {
	    	var valK = currentStep/1000.0;
	    	var valKp = (valK - valK.toLong())*10.0;
	    	return Lang.format("STEP $1$.$2$K",[valK.format("%d"), valKp.format("%d")]);
    	}
	}
	
	function min_pad() {
		return 0;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function bar_data() {
		return true;
	}
}

/////////////////////
// end steps stage //
/////////////////////

///////////////////
// battery stage //
///////////////////

class BatteryField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 0.0;
	}
	
	function max_val() {
	    return 100.0;
	}
	
	function cur_val() {
		return Sys.getSystemStats().battery;
	}
	
	function min_label(value) {
		return "b";
	}
	
	function max_label(value) {
		return "P";
	}
	
	function cur_label(value) {
		return Lang.format("BAT $1$%",[value.format("%d")]);
	}
	
	function min_pad() {
		return -2;
	}
	
	function max_pad() {
		return 0;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function bar_data() {
		return true;
	}
}

///////////////////////
// end battery stage //
///////////////////////

//////////////
// HR stage //
//////////////

class HRField extends BaseDataField {

	function initialize(id) {
		BaseDataField.initialize(id);
	}

	function min_val() {
    	return 50.0;
	}
	
	function max_val() {
	    return 120.0;
	}
	
	function cur_val() {
		var heartRate = _retrieveHeartrate();
		return heartRate.toFloat();
	}
	
	function min_label(value) {
		return value.format("%d");
	}
	
	function max_label(value) {
		return value.format("%d");
	}
	
	function cur_label(value) {
		var heartRate = value;
//		if(doesDeviceSupportHeartrate()) {
//			heartRate = _retrieveHeartrate();
//		}
		if (heartRate<=1) {
			return "HR --";
		}
		return Lang.format("HR $1$",[heartRate.format("%d")]);
	}
	
	function min_pad() {
		return -2;
	}
	
	function max_pad() {
		return -2;
	}
	
	function cur_pad() {
		return 0;
	}
	
	function doesDeviceSupportHeartrate() {
		return ActivityMonitor has :INVALID_HR_SAMPLE;
	}
	
	function _retrieveHeartrate() {
		var currentHeartrate = 0.0;
		var activityInfo = Activity.getActivityInfo();
		var sample = activityInfo.currentHeartRate;
		if (sample != null) {
			currentHeartrate = sample;
		} else if (ActivityMonitor has :getHeartRateHistory) {
			sample = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true)
				.next();
			if ((sample != null) && (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
				currentHeartrate = sample.heartRate;
			}
		}
		return currentHeartrate.toFloat();
	}
	
	function bar_data() {
		return true;
	}
}

//////////////////
// end HR stage //
//////////////////

